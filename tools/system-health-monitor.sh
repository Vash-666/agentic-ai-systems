#!/bin/bash
#
# System Health Monitor Script
# Monitors OpenClaw agent health, system components, and performance metrics
#

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/system-health.jsonl"
BASELINE_COST_FILE="${SCRIPT_DIR}/.cost-baselines.json"
ALERT_THRESHOLD_RESPONSE=30
ALERT_THRESHOLD_COST=1.5
FAILURE_THRESHOLD=3

# Memory quality metrics integration
MEMORY_METRICS_SCRIPT="${SCRIPT_DIR}/memory-quality-metrics.sh"

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Flags
FLAG_CHECK=false
FLAG_JSON=false
FLAG_ALERT=false

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check)
                FLAG_CHECK=true
                shift
                ;;
            --json)
                FLAG_JSON=true
                shift
                ;;
            --alert)
                FLAG_ALERT=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    cat << EOF
System Health Monitor for OpenClaw

Usage: $(basename "$0") [OPTIONS]

Options:
    --check     Run health checks only (no status output)
    --json      Output results as JSON
    --alert     Send alerts for critical issues
    --help, -h  Show this help message

Examples:
    $(basename "$0")              # Pretty-print status table
    $(basename "$0") --json       # Output JSON
    $(basename "$0") --check --alert  # Check health and alert on issues
EOF
}

# Initialize log file
init_log() {
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
    fi
}

# Get list of active agent sessions
get_active_agents() {
    local agents=""
    
    # Check for openclaw sessions
    if command -v openclaw &> /dev/null; then
        agents=$(openclaw sessions list 2>/dev/null | grep -E '^agent:' || true)
    fi
    
    # Also check for running node processes
    if [[ -z "$agents" ]]; then
        agents=$(ps aux 2>/dev/null | grep -E 'openclaw|claw' | grep -v grep | awk '{print $11}' | sort -u || true)
    fi
    
    # If still no agents, use some defaults for testing
    if [[ -z "$agents" ]]; then
        agents="agent:main:main"
    fi
    
    echo "$agents"
}

# Check if agent is responsive
check_agent_responsive() {
    local agent="$1"
    local start_time end_time duration
    
    start_time=$(date +%s 2>/dev/null || echo "0")
    
    # Try to ping the agent
    local response="TIMEOUT"
    if command -v openclaw &> /dev/null; then
        response=$(timeout 3 openclaw sessions describe "$agent" 2>/dev/null && echo "ACTIVE" || echo "TIMEOUT")
    else
        # Fallback: check if process exists
        if pgrep -f "$agent" > /dev/null 2>&1; then
            response="ACTIVE"
        fi
    fi
    
    end_time=$(date +%s 2>/dev/null || echo "0")
    duration=$((end_time - start_time))
    
    if [[ "$response" == "TIMEOUT" ]] || [[ -z "$response" ]]; then
        echo "UNRESPONSIVE|$duration|1"
        return 1
    else
        echo "HEALTHY|$duration|0"
        return 0
    fi
}

# Check model consistency
check_model_consistency() {
    local agent="$1"
    local actual_model="unknown"
    local preferred_model="unknown"
    
    # Get actual model from agent
    if command -v openclaw &> /dev/null; then
        actual_model=$(openclaw sessions describe "$agent" 2>/dev/null | grep -oE 'model=[^[:space:]]+' | cut -d= -f2 || echo "unknown")
    fi
    
    # Get preferred model from config (if exists)
    local config_file="${SCRIPT_DIR}/../.agent-config/${agent}.conf"
    if [[ -f "$config_file" ]]; then
        preferred_model=$(grep -E '^preferred_model' "$config_file" 2>/dev/null | cut -d= -f2 | tr -d ' "' || echo "$actual_model")
    else
        preferred_model="$actual_model"
    fi
    
    echo "$actual_model|$preferred_model"
}

# Get cost metrics for agent
get_agent_cost() {
    local agent="$1"
    local cost=0
    
    # Try to get cost from session data
    if command -v openclaw &> /dev/null; then
        cost=$(openclaw sessions describe "$agent" 2>/dev/null | grep -oE 'cost=[0-9.]+' | cut -d= -f2 || echo "0")
    fi
    
    # Fallback: estimate from log
    if [[ "$cost" == "0" ]] && [[ -f "$LOG_FILE" ]]; then
        cost=$(grep "\"agent\":\"$agent\"" "$LOG_FILE" 2>/dev/null | tail -1 | grep -oE '"cost":[0-9.]+' | cut -d: -f2 || echo "0")
    fi
    
    echo "${cost:-0}"
}

# Check cost against baseline
check_cost_alert() {
    local agent="$1"
    local current_cost
    
    current_cost=$(get_agent_cost "$agent")
    
    # Get baseline from file
    local baseline="$current_cost"
    if [[ -f "$BASELINE_COST_FILE" ]] && command -v jq &> /dev/null; then
        baseline=$(jq -r ".[\"$agent\"] // $current_cost" "$BASELINE_COST_FILE" 2>/dev/null || echo "$current_cost")
    else
        # Save baseline
        mkdir -p "$(dirname "$BASELINE_COST_FILE")"
        echo "{\"$agent\": $current_cost}" > "$BASELINE_COST_FILE"
    fi
    
    if [[ "$baseline" != "0" ]] && command -v bc &> /dev/null; then
        local ratio
        ratio=$(echo "scale=2; $current_cost / $baseline" | bc 2>/dev/null || echo "1")
        if (( $(echo "$ratio > $ALERT_THRESHOLD_COST" | bc -l 2>/dev/null || echo "0") )); then
            echo "$current_cost|ALERT"
            return 1
        fi
    fi
    echo "$current_cost|OK"
    return 0
}

# Check vector retriever status
check_vector_retriever() {
    local status="UNKNOWN"
    local response_time="N/A"
    
    # Check if vector store is accessible
    if command -v curl &> /dev/null; then
        local start_time end_time
        start_time=$(date +%s 2>/dev/null || echo "0")
        
        # Try to reach vector retriever endpoint (adjust URL as needed)
        if curl -sf http://localhost:8000/health > /dev/null 2>&1 || \
           curl -sf http://localhost:11434/api/tags > /dev/null 2>&1; then
            status="HEALTHY"
        else
            status="UNREACHABLE"
        fi
        
        end_time=$(date +%s 2>/dev/null || echo "0")
        response_time=$(( (end_time - start_time) * 1000 ))
    fi
    
    echo "$status|$response_time"
}

# Check memory system health
check_memory_system() {
    local status="UNKNOWN"
    local memory_usage="N/A"
    local memory_quality_score="N/A"
    
    # Check memory files exist and are writable
    local memory_dir="${SCRIPT_DIR}/../memory"
    if [[ -d "$memory_dir" ]]; then
        if [[ -r "$memory_dir" ]] && [[ -w "$memory_dir" ]]; then
            status="HEALTHY"
            # Get memory usage
            if command -v du &> /dev/null; then
                memory_usage=$(du -sh "$memory_dir" 2>/dev/null | cut -f1 || echo "N/A")
            fi
        else
            status="PERMISSION_DENIED"
        fi
    else
        status="NOT_FOUND"
    fi
    
    # Get memory quality score if available
    if [[ -x "$MEMORY_METRICS_SCRIPT" ]]; then
        memory_quality_score=$($MEMORY_METRICS_SCRIPT --json 2>/dev/null | grep -oE '"overall_score": [0-9.]+' | grep -oE '[0-9.]+' | head -1 || echo "N/A")
    fi
    
    echo "$status|$memory_usage|$memory_quality_score"
}

# Run memory quality check and include in health data
run_memory_quality_check() {
    local memory_quality_json="{}"
    
    if [[ -x "$MEMORY_METRICS_SCRIPT" ]]; then
        # Run memory quality metrics in check mode
        $MEMORY_METRICS_SCRIPT --check >/dev/null 2>&1 || true
        
        # Get the latest metrics as JSON
        memory_quality_json=$($MEMORY_METRICS_SCRIPT --json 2>/dev/null || echo "{}")
    fi
    
    echo "$memory_quality_json"
}

# Check Grok CLI availability
check_grok_cli() {
    local status="UNKNOWN"
    local version="N/A"
    
    if command -v grok &> /dev/null; then
        status="AVAILABLE"
        version=$(grok --version 2>/dev/null | head -1 || echo "unknown")
    else
        status="NOT_FOUND"
    fi
    
    echo "$status|$version"
}

# Check circuit breaker states
check_circuit_breakers() {
    local cb_file="${SCRIPT_DIR}/../.circuit-breakers.json"
    local status="UNKNOWN"
    local tripped_count=0
    
    if [[ -f "$cb_file" ]]; then
        if command -v jq &> /dev/null; then
            tripped_count=$(jq '[.[] | select(.state == "OPEN")] | length' "$cb_file" 2>/dev/null || echo "0")
            if [[ "$tripped_count" -gt 0 ]]; then
                status="WARNING"
            else
                status="HEALTHY"
            fi
        else
            status="NO_JQ"
        fi
    else
        status="NO_BREAKERS"
    fi
    
    echo "$status|$tripped_count"
}

# Run all health checks and output results
run_health_checks() {
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")
    
    # Check agents
    local agents
    agents=$(get_active_agents)
    
    # Arrays to store results
    local agent_results=""
    local has_critical=false
    local has_warning=false
    
    while IFS= read -r agent; do
        [[ -z "$agent" ]] && continue
        
        # Check agent responsive
        local agent_check
        agent_check=$(check_agent_responsive "$agent")
        local status=$(echo "$agent_check" | cut -d'|' -f1)
        local response_time=$(echo "$agent_check" | cut -d'|' -f2)
        local failures=$(echo "$agent_check" | cut -d'|' -f3)
        
        # Check model
        local model_check
        model_check=$(check_model_consistency "$agent")
        local actual_model=$(echo "$model_check" | cut -d'|' -f1)
        local preferred_model=$(echo "$model_check" | cut -d'|' -f2)
        
        # Check cost
        local cost_check
        cost_check=$(check_cost_alert "$agent")
        local cost=$(echo "$cost_check" | cut -d'|' -f1)
        local cost_alert=$(echo "$cost_check" | cut -d'|' -f2)
        
        # Determine alert level
        local alert_level="normal"
        if [[ "$status" == "UNRESPONSIVE" ]] || [[ "$failures" -ge "$FAILURE_THRESHOLD" ]]; then
            alert_level="critical"
            has_critical=true
        elif [[ "$response_time" -gt "$ALERT_THRESHOLD_RESPONSE" ]] || [[ "$cost_alert" == "ALERT" ]]; then
            alert_level="warning"
            has_warning=true
        fi
        
        # Build agent JSON
        local agent_json
        agent_json=$(cat << AGENTJSON
        {
            "name": "$agent",
            "status": "$status",
            "response_time": $response_time,
            "cost": $cost,
            "model": "$actual_model",
            "preferred_model": "$preferred_model",
            "consecutive_failures": $failures,
            "alert_level": "$alert_level"
        }
AGENTJSON
)
        
        if [[ -n "$agent_results" ]]; then
            agent_results="$agent_results,"
        fi
        agent_results="$agent_results$agent_json"
        
    done <<< "$agents"
    
    # Check system components
    local vr_check=$(check_vector_retriever)
    local vr_status=$(echo "$vr_check" | cut -d'|' -f1)
    local vr_time=$(echo "$vr_check" | cut -d'|' -f2)
    
    local mem_check=$(check_memory_system)
    local mem_status=$(echo "$mem_check" | cut -d'|' -f1)
    local mem_usage=$(echo "$mem_check" | cut -d'|' -f2)
    local mem_quality=$(echo "$mem_check" | cut -d'|' -f3)
    
    # Get full memory quality metrics
    local memory_quality_json
    memory_quality_json=$(run_memory_quality_check)
    
    local grok_check=$(check_grok_cli)
    local grok_status=$(echo "$grok_check" | cut -d'|' -f1)
    local grok_version=$(echo "$grok_check" | cut -d'|' -f2)
    
    local cb_check=$(check_circuit_breakers)
    local cb_status=$(echo "$cb_check" | cut -d'|' -f1)
    local cb_tripped=$(echo "$cb_check" | cut -d'|' -f2)
    
    # Check for system warnings/criticals
    if [[ "$vr_status" != "HEALTHY" ]] || [[ "$mem_status" != "HEALTHY" ]] || [[ "$grok_status" == "NOT_FOUND" ]]; then
        has_critical=true
    elif [[ "$cb_status" == "WARNING" ]]; then
        has_warning=true
    fi
    
    # Determine overall status
    local overall_status="HEALTHY"
    if $has_critical; then
        overall_status="CRITICAL"
    elif $has_warning; then
        overall_status="WARNING"
    fi
    
    # Build final JSON
    cat << EOF
{
    "timestamp": "$timestamp",
    "overall_status": "$overall_status",
    "agents": [$agent_results],
    "system": {
        "vector_retriever": {
            "status": "$vr_status",
            "response_time_ms": "$vr_time"
        },
        "memory_system": {
            "status": "$mem_status",
            "usage": "$mem_usage",
            "quality_score": "$mem_quality",
            "quality_details": $memory_quality_json
        },
        "grok_cli": {
            "status": "$grok_status",
            "version": "$grok_version"
        },
        "circuit_breakers": {
            "status": "$cb_status",
            "tripped_count": $cb_tripped
        }
    }
}
EOF
}

# Pretty print status table
print_status_table() {
    local json_data="$1"
    
    echo ""
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║           OpenClaw System Health Monitor                       ║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local overall_status
    overall_status=$(echo "$json_data" | grep -oE '"overall_status": "[^"]+"' | cut -d'"' -f4)
    
    case "$overall_status" in
        HEALTHY)
            echo -e "Overall Status: ${GREEN}✓ $overall_status${NC}"
            ;;
        WARNING)
            echo -e "Overall Status: ${YELLOW}⚠ $overall_status${NC}"
            ;;
        CRITICAL)
            echo -e "Overall Status: ${RED}✗ $overall_status${NC}"
            ;;
    esac
    echo ""
    
    # Agent Status Table
    echo -e "${BOLD}Agent Status:${NC}"
    echo -e "${BLUE}┌─────────────────────────┬────────────┬──────────────┬──────────────────┬─────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${BOLD}Agent${NC}                   ${BLUE}│${NC} ${BOLD}Status${NC}     ${BLUE}│${NC} ${BOLD}Response (s)${NC} ${BLUE}│${NC} ${BOLD}Model${NC}            ${BLUE}│${NC} ${BOLD}Cost${NC}        ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────────────────────┼────────────┼──────────────┼──────────────────┼─────────────┤${NC}"
    
    # Parse agents from JSON
    echo "$json_data" | grep -oE '"name": "[^"]+", "status": "[^"]+", "response_time": [0-9]+, "cost": [0-9.]+, "model": "[^"]+"' | while read -r line; do
        local agent=$(echo "$line" | grep -oE '"name": "[^"]+"' | cut -d'"' -f4)
        local status=$(echo "$line" | grep -oE '"status": "[^"]+"' | cut -d'"' -f4)
        local response=$(echo "$line" | grep -oE '"response_time": [0-9]+' | grep -oE '[0-9]+')
        local cost=$(echo "$line" | grep -oE '"cost": [0-9.]+' | grep -oE '[0-9.]+')
        local model=$(echo "$line" | grep -oE '"model": "[^"]+"' | cut -d'"' -f4)
        
        # Truncate long names
        local display_agent="$agent"
        if [[ ${#agent} -gt 23 ]]; then
            display_agent="${agent:0:20}..."
        fi
        
        # Color status
        local status_color="$GREEN"
        if [[ "$status" == "UNRESPONSIVE" ]]; then
            status_color="$RED"
        fi
        
        # Truncate model name
        if [[ ${#model} -gt 16 ]]; then
            model="${model:0:13}..."
        fi
        
        printf "${BLUE}│${NC} %-23s ${BLUE}│${NC} ${status_color}%-10s${NC} ${BLUE}│${NC} %12s ${BLUE}│${NC} %-16s ${BLUE}│${NC} %11s ${BLUE}│${NC}\n" \
            "$display_agent" "$status" "$response" "$model" "$cost"
    done
    
    echo -e "${BLUE}└─────────────────────────┴────────────┴──────────────┴──────────────────┴─────────────┘${NC}"
    echo ""
    
    # System Components Table
    echo -e "${BOLD}System Components:${NC}"
    echo -e "${BLUE}┌─────────────────────┬────────────────┬─────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${BOLD}Component${NC}           ${BLUE}│${NC} ${BOLD}Status${NC}         ${BLUE}│${NC} ${BOLD}Details${NC}                                     ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────────────────┼────────────────┼─────────────────────────────────────────────┤${NC}"
    
    # Vector Retriever
    local vr_status=$(echo "$json_data" | grep -oE '"vector_retriever": \{[^}]+\}' | grep -oE '"status": "[^"]+"' | cut -d'"' -f4)
    local vr_color="$GREEN"
    [[ "$vr_status" != "HEALTHY" ]] && vr_color="$RED"
    local vr_time=$(echo "$json_data" | grep -oE '"vector_retriever": \{[^}]+\}' | grep -oE '"response_time_ms": "[^"]+"' | cut -d'"' -f4)
    local vr_details="Response: ${vr_time} ms"
    printf "${BLUE}│${NC} %-19s ${BLUE}│${NC} ${vr_color}%-14s${NC} ${BLUE}│${NC} %-43s ${BLUE}│${NC}\n" "Vector Retriever" "$vr_status" "$vr_details"
    
    # Memory System
    local mem_status=$(echo "$json_data" | grep -oE '"memory_system": \{[^}]+\}' | grep -oE '"status": "[^"]+"' | cut -d'"' -f4)
    local mem_color="$GREEN"
    [[ "$mem_status" != "HEALTHY" ]] && mem_color="$RED"
    local mem_usage=$(echo "$json_data" | grep -oE '"memory_system": \{[^}]+\}' | grep -oE '"usage": "[^"]+"' | cut -d'"' -f4)
    local mem_quality=$(echo "$json_data" | grep -oE '"memory_system": \{[^}]+\}' | grep -oE '"quality_score": "[^"]+"' | cut -d'"' -f4)
    local mem_details="Usage: $mem_usage, Quality: ${mem_quality}/10"
    [[ ${#mem_details} -gt 43 ]] && mem_details="Q:${mem_quality}/10 | $mem_usage"
    printf "${BLUE}│${NC} %-19s ${BLUE}│${NC} ${mem_color}%-14s${NC} ${BLUE}│${NC} %-43s ${BLUE}│${NC}\n" "Memory System" "$mem_status" "$mem_details"
    
    # Grok CLI
    local grok_status=$(echo "$json_data" | grep -oE '"grok_cli": \{[^}]+\}' | grep -oE '"status": "[^"]+"' | cut -d'"' -f4)
    local grok_color="$GREEN"
    [[ "$grok_status" != "AVAILABLE" ]] && grok_color="$YELLOW"
    local grok_version=$(echo "$json_data" | grep -oE '"grok_cli": \{[^}]+\}' | grep -oE '"version": "[^"]+"' | cut -d'"' -f4)
    [[ ${#grok_version} -gt 43 ]] && grok_version="${grok_version:0:40}..."
    printf "${BLUE}│${NC} %-19s ${BLUE}│${NC} ${grok_color}%-14s${NC} ${BLUE}│${NC} %-43s ${BLUE}│${NC}\n" "Grok CLI" "$grok_status" "$grok_version"
    
    # Circuit Breakers
    local cb_status=$(echo "$json_data" | grep -oE '"circuit_breakers": \{[^}]+\}' | grep -oE '"status": "[^"]+"' | cut -d'"' -f4)
    local cb_color="$GREEN"
    [[ "$cb_status" == "WARNING" ]] && cb_color="$YELLOW"
    [[ "$cb_status" == "UNKNOWN" ]] && cb_color="$YELLOW"
    local cb_tripped=$(echo "$json_data" | grep -oE '"circuit_breakers": \{[^}]+\}' | grep -oE '"tripped_count": [0-9]+' | grep -oE '[0-9]+')
    local cb_details="Tripped: $cb_tripped"
    printf "${BLUE}│${NC} %-19s ${BLUE}│${NC} ${cb_color}%-14s${NC} ${BLUE}│${NC} %-43s ${BLUE}│${NC}\n" "Circuit Breakers" "$cb_status" "$cb_details"
    
    echo -e "${BLUE}└─────────────────────┴────────────────┴─────────────────────────────────────────────┘${NC}"
    echo ""
    
    # Thresholds Legend
    echo -e "${BOLD}Alert Thresholds:${NC}"
    echo -e "  • Response time > ${ALERT_THRESHOLD_RESPONSE}s = ${YELLOW}WARNING${NC}"
    echo -e "  • Cost > ${ALERT_THRESHOLD_COST}x baseline = ${YELLOW}ALERT${NC}"
    echo -e "  • ${FAILURE_THRESHOLD} consecutive failures = ${RED}CRITICAL${NC}"
    echo ""
}

# Send alerts for critical issues
send_alerts() {
    local json_data="$1"
    local has_alerts=false
    
    # Parse agents for alerts
    echo "$json_data" | grep -oE '\{[^{}]*"name"[^}]*"alert_level"[^}]*\}' | while read -r agent_block; do
        local agent=$(echo "$agent_block" | grep -oE '"name": "[^"]+"' | cut -d'"' -f4)
        local status=$(echo "$agent_block" | grep -oE '"status": "[^"]+"' | cut -d'"' -f4)
        local alert_level=$(echo "$agent_block" | grep -oE '"alert_level": "[^"]+"' | cut -d'"' -f4)
        local failures=$(echo "$agent_block" | grep -oE '"consecutive_failures": [0-9]+' | grep -oE '[0-9]+')
        local response_time=$(echo "$agent_block" | grep -oE '"response_time": [0-9]+' | grep -oE '[0-9]+')
        
        if [[ "$alert_level" == "critical" ]]; then
            if ! $has_alerts; then
                echo -e "${RED}${BOLD}ALERTS:${NC}"
                has_alerts=true
            fi
            if [[ "$status" == "UNRESPONSIVE" ]]; then
                echo -e "  ${RED}•${NC} CRITICAL: Agent '$agent' is unresponsive"
            else
                echo -e "  ${RED}•${NC} CRITICAL: Agent '$agent' has $failures consecutive failures"
            fi
        elif [[ "$alert_level" == "warning" ]]; then
            if ! $has_alerts; then
                echo -e "${RED}${BOLD}ALERTS:${NC}"
                has_alerts=true
            fi
            echo -e "  ${YELLOW}•${NC} WARNING: Agent '$agent' response time (${response_time}s) exceeds threshold"
        fi
    done
    
    # Check system components
    local vr_status=$(echo "$json_data" | grep -oE '"vector_retriever": \{[^}]+\}' | grep -oE '"status": "[^"]+"' | cut -d'"' -f4)
    local mem_status=$(echo "$json_data" | grep -oE '"memory_system": \{[^}]+\}' | grep -oE '"status": "[^"]+"' | cut -d'"' -f4)
    local cb_status=$(echo "$json_data" | grep -oE '"circuit_breakers": \{[^}]+\}' | grep -oE '"status": "[^"]+"' | cut -d'"' -f4)
    local cb_tripped=$(echo "$json_data" | grep -oE '"circuit_breakers": \{[^}]+\}' | grep -oE '"tripped_count": [0-9]+' | grep -oE '[0-9]+')
    
    if [[ "$vr_status" != "HEALTHY" ]]; then
        if ! $has_alerts; then
            echo -e "${RED}${BOLD}ALERTS:${NC}"
            has_alerts=true
        fi
        echo -e "  ${RED}•${NC} CRITICAL: Vector retriever is $vr_status"
    fi
    
    if [[ "$mem_status" != "HEALTHY" ]]; then
        if ! $has_alerts; then
            echo -e "${RED}${BOLD}ALERTS:${NC}"
            has_alerts=true
        fi
        echo -e "  ${RED}•${NC} CRITICAL: Memory system is $mem_status"
    fi
    
    # Check memory quality alerts
    local mem_quality_score=$(echo "$json_data" | grep -oE '"memory_system": \{[^}]+\}' | grep -oE '"quality_score": "[^"]+"' | cut -d'"' -f4)
    if [[ "$mem_quality_score" != "N/A" ]] && [[ "$mem_quality_score" != "" ]]; then
        if command -v bc &> /dev/null; then
            if (( $(echo "$mem_quality_score < 7.0" | bc -l 2>/dev/null || echo "0") )); then
                if ! $has_alerts; then
                    echo -e "${RED}${BOLD}ALERTS:${NC}"
                    has_alerts=true
                fi
                echo -e "  ${YELLOW}•${NC} WARNING: Memory quality score is low ($mem_quality_score/10)"
            fi
        fi
    fi
    
    if [[ "$cb_status" == "WARNING" ]]; then
        if ! $has_alerts; then
            echo -e "${RED}${BOLD}ALERTS:${NC}"
            has_alerts=true
        fi
        echo -e "  ${YELLOW}•${NC} WARNING: $cb_tripped circuit breakers are tripped"
    fi
    
    if $has_alerts; then
        echo ""
        return 1
    else
        echo -e "${GREEN}No alerts - all systems operational${NC}"
        return 0
    fi
}

# Log results to JSONL
log_results() {
    local json_data="$1"
    
    # Append to log file
    echo "$json_data" >> "$LOG_FILE"
    
    # Rotate log if too large (> 100MB)
    if [[ -f "$LOG_FILE" ]]; then
        local size
        size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo "0")
        if [[ "$size" -gt 104857600 ]]; then
            mv "$LOG_FILE" "${LOG_FILE}.old"
            touch "$LOG_FILE"
        fi
    fi
}

# Main execution
main() {
    parse_args "$@"
    init_log
    
    # Run health checks and get JSON output
    local json_data
    json_data=$(run_health_checks)
    
    if $FLAG_JSON; then
        echo "$json_data"
    elif $FLAG_CHECK; then
        if $FLAG_ALERT; then
            send_alerts "$json_data"
        fi
    else
        print_status_table "$json_data"
        if $FLAG_ALERT; then
            send_alerts "$json_data"
        fi
    fi
    
    # Always log results
    log_results "$json_data"
}

# Run main
main "$@"
