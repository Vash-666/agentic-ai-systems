#!/bin/bash
#
# Memory Quality Metrics Script
# Tracks and scores memory system performance and quality
#

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/memory-quality.jsonl"
TREND_FILE="${SCRIPT_DIR}/.memory-quality-history.json"
ALERT_STATE_FILE="${SCRIPT_DIR}/.memory-quality-alerts.json"
MEMORY_DIR="${SCRIPT_DIR}/../memory"
PRODUCT_DIR="${SCRIPT_DIR}/../product"

# Scoring weights
WEIGHT_RETRIEVAL=30
WEIGHT_FRESHNESS=25
WEIGHT_COVERAGE=20
WEIGHT_CURATION=25

# Thresholds
TARGET_SCORE=8.0
ALERT_THRESHOLD=7.0
ALERT_CONSECUTIVE_DAYS=3
MAX_HISTORY_DAYS=30

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Flags
FLAG_TREND=false
FLAG_REPORT=false
FLAG_ALERT=false
FLAG_JSON=false
FLAG_CHECK=false

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --trend)
                FLAG_TREND=true
                shift
                ;;
            --report)
                FLAG_REPORT=true
                shift
                ;;
            --alert)
                FLAG_ALERT=true
                shift
                ;;
            --json)
                FLAG_JSON=true
                shift
                ;;
            --check)
                FLAG_CHECK=true
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
Memory Quality Metrics for OpenClaw

Usage: $(basename "$0") [OPTIONS]

Options:
    --trend     Show 7-day trend graph (ASCII)
    --report    Generate weekly summary report
    --alert     Check and display alerts for low scores
    --json      Output results as JSON
    --check     Run metrics check only (no table output)
    --help, -h  Show this help message

Examples:
    $(basename "$0")              # Pretty-print metrics table
    $(basename "$0") --json       # Output JSON
    $(basename "$0") --trend      # Show trend graph
    $(basename "$0") --report     # Weekly summary
    $(basename "$0") --alert      # Check for alerts
EOF
}

# Initialize log files
init_logs() {
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
    fi
    if [[ ! -f "$TREND_FILE" ]]; then
        echo "[]" > "$TREND_FILE"
    fi
    if [[ ! -f "$ALERT_STATE_FILE" ]]; then
        echo '{"consecutive_low_days": 0, "last_alert_date": null}' > "$ALERT_STATE_FILE"
    fi
}

# Calculate retrieval accuracy (% of queries that found relevant context)
calculate_retrieval_accuracy() {
    local accuracy=0
    local total_queries=0
    local successful_queries=0
    
    # Check memory search logs if available
    if [[ -f "$LOG_FILE" ]]; then
        # Count successful vs failed retrievals from recent logs
        local recent_logs
        recent_logs=$(tail -100 "$LOG_FILE" 2>/dev/null || echo "")
        
        if [[ -n "$recent_logs" ]]; then
            total_queries=$(echo "$recent_logs" | grep -c '"retrieval_accuracy"' || echo "0")
            successful_queries=$(echo "$recent_logs" | grep '"retrieval_accuracy":' | grep -v '"retrieval_accuracy": 0' | wc -l || echo "0")
            
            if [[ "$total_queries" -gt 0 ]]; then
                accuracy=$(echo "scale=2; ($successful_queries / $total_queries) * 100" | bc 2>/dev/null || echo "0")
            fi
        fi
    fi
    
    # If no log data, estimate based on memory file coverage
    if [[ "$accuracy" == "0" ]]; then
        local memory_files=0
        local indexed_files=0
        
        if [[ -d "$MEMORY_DIR" ]]; then
            memory_files=$(find "$MEMORY_DIR" -type f -name "*.md" 2>/dev/null | wc -l || echo "0")
        fi
        
        # Estimate: assume 85% accuracy if memory system exists
        if [[ "$memory_files" -gt 0 ]]; then
            accuracy=85.0
        else
            accuracy=0.0
        fi
    fi
    
    # Normalize to 0-10 scale
    local normalized
    normalized=$(echo "scale=2; $accuracy / 10" | bc 2>/dev/null || echo "0")
    
    echo "$normalized|$accuracy"
}

# Calculate context freshness (average age of injected context in hours)
calculate_freshness() {
    local freshness_score=0
    local avg_age_hours=0
    local total_files=0
    local weighted_age=0
    
    if [[ -d "$MEMORY_DIR" ]]; then
        local now
        now=$(date +%s)
        
        while IFS= read -r -d '' file; do
            local mtime
            mtime=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null || echo "$now")
            local age_hours=$(( (now - mtime) / 3600 ))
            
            # Weight by file size (larger files = more important context)
            local size
            size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
            
            weighted_age=$(( weighted_age + (age_hours * size) ))
            total_files=$((total_files + 1))
        done < <(find "$MEMORY_DIR" -type f -name "*.md" -print0 2>/dev/null || true)
        
        if [[ "$total_files" -gt 0 ]]; then
            # Calculate average age using bc for floating point
            local avg_size=1000
            if [[ -d "$MEMORY_DIR" ]]; then
                avg_size=$(find "$MEMORY_DIR" -type f -name "*.md" -exec stat -f%z {} \; 2>/dev/null | awk '{sum+=$1; count++} END {print (count>0 ? sum/count : 1000)}' || echo "1000")
            fi
            # Use bc for floating point calculation
            if command -v bc &> /dev/null; then
                avg_age_hours=$(echo "scale=0; $weighted_age / $total_files / ($avg_size / 1000 + 1)" | bc 2>/dev/null || echo "0")
            else
                avg_age_hours=$(( weighted_age / total_files / (avg_size / 1000 + 1) ))
            fi
        fi
    fi
    
    # Score: 10 = <1 day old, 0 = >30 days old
    if [[ "$avg_age_hours" -lt 24 ]]; then
        freshness_score=10.0
    elif [[ "$avg_age_hours" -gt 720 ]]; then  # 30 days
        freshness_score=0.0
    else
        # Linear decay from 10 to 0 between 1-30 days
        freshness_score=$(echo "scale=2; 10 - (($avg_age_hours - 24) / 69.6)" | bc 2>/dev/null || echo "5")
    fi
    
    echo "$freshness_score|$avg_age_hours"
}

# Calculate memory coverage (% of relevant files indexed)
calculate_coverage() {
    local coverage_score=0
    local coverage_percent=0
    
    local memory_files=0
    local expected_files=5  # Minimum expected: MEMORY.md, daily notes, etc.
    
    if [[ -d "$MEMORY_DIR" ]]; then
        memory_files=$(find "$MEMORY_DIR" -type f \( -name "*.md" -o -name "*.txt" \) 2>/dev/null | wc -l || echo "0")
        
        # Count product directory memory files too
        if [[ -d "$PRODUCT_DIR" ]]; then
            local product_memory
            product_memory=$(find "$PRODUCT_DIR" -maxdepth 1 -type f \( -name "MEMORY.md" -o -name "AGENTS.md" -o -name "SOUL.md" -o -name "USER.md" \) 2>/dev/null | wc -l || echo "0")
            memory_files=$((memory_files + product_memory))
        fi
    fi
    
    # Also check for AGENTS.md, TOOLS.md, etc. in product dir
    local product_files=0
    if [[ -d "$PRODUCT_DIR" ]]; then
        for file in AGENTS.md TOOLS.md MEMORY.md SOUL.md USER.md BOOTSTRAP.md; do
            if [[ -f "$PRODUCT_DIR/$file" ]]; then
                product_files=$((product_files + 1))
            fi
        done
    fi
    
    memory_files=$((memory_files + product_files))
    
    # Calculate coverage percentage
    if [[ "$expected_files" -gt 0 ]]; then
        coverage_percent=$(echo "scale=2; ($memory_files / $expected_files) * 100" | bc 2>/dev/null || echo "0")
        if (( $(echo "$coverage_percent > 100" | bc -l 2>/dev/null || echo "0") )); then
            coverage_percent=100
        fi
    fi
    
    # Normalize to 0-10 scale
    coverage_score=$(echo "scale=2; $coverage_percent / 10" | bc 2>/dev/null || echo "0")
    
    echo "$coverage_score|$coverage_percent|$memory_files"
}

# Calculate curation quality (truth density score)
calculate_curation_quality() {
    local quality_score=0
    local truth_density=0
    
    if [[ -d "$MEMORY_DIR" ]]; then
        local total_lines=0
        local content_lines=0
        
        while IFS= read -r -d '' file; do
            local lines
            lines=$(wc -l < "$file" 2>/dev/null || echo "0")
            total_lines=$((total_lines + lines))
            
            # Count non-empty, non-comment lines as content
            local content
            content=$(grep -v '^[[:space:]]*$' "$file" 2>/dev/null | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*<!--' | wc -l || echo "0")
            content_lines=$((content_lines + content))
        done < <(find "$MEMORY_DIR" -type f -name "*.md" -print0 2>/dev/null || true)
        
        # Also check product MEMORY.md
        if [[ -f "$PRODUCT_DIR/MEMORY.md" ]]; then
            local lines
            lines=$(wc -l < "$PRODUCT_DIR/MEMORY.md" 2>/dev/null || echo "0")
            total_lines=$((total_lines + lines))
            local content
            content=$(grep -v '^[[:space:]]*$' "$PRODUCT_DIR/MEMORY.md" 2>/dev/null | grep -v '^[[:space:]]*#' | wc -l || echo "0")
            content_lines=$((content_lines + content))
        fi
        
        if [[ "$total_lines" -gt 0 ]]; then
            truth_density=$(echo "scale=2; ($content_lines / $total_lines) * 100" | bc 2>/dev/null || echo "0")
        fi
    fi
    
    # Score based on truth density (ideal: 60-80% content, not too sparse, not too dense)
    if (( $(echo "$truth_density >= 60 && $truth_density <= 85" | bc -l 2>/dev/null || echo "0") )); then
        quality_score=10.0
    elif (( $(echo "$truth_density >= 40 && $truth_density < 60" | bc -l 2>/dev/null || echo "0") )); then
        quality_score=$(echo "scale=2; 5 + (($truth_density - 40) / 4)" | bc 2>/dev/null || echo "7.5")
    elif (( $(echo "$truth_density > 85 && $truth_density <= 95" | bc -l 2>/dev/null || echo "0") )); then
        quality_score=$(echo "scale=2; 10 - (($truth_density - 85) / 2)" | bc 2>/dev/null || echo "7.5")
    elif (( $(echo "$truth_density < 40" | bc -l 2>/dev/null || echo "0") )); then
        quality_score=$(echo "scale=2; $truth_density / 8" | bc 2>/dev/null || echo "2.5")
    else
        quality_score=5.0
    fi
    
    echo "$quality_score|$truth_density"
}

# Calculate usage patterns (which memories accessed most)
calculate_usage_patterns() {
    local usage_score=0
    local access_count=0
    local top_accessed=""
    
    # Check log file for access patterns
    if [[ -f "$LOG_FILE" ]]; then
        # Get recent access counts
        access_count=$(wc -l < "$LOG_FILE" 2>/dev/null || echo "0")
        
        # Find most accessed memory files
        if command -v jq &> /dev/null; then
            top_accessed=$(jq -r 'select(.most_accessed_memory) | .most_accessed_memory' "$LOG_FILE" 2>/dev/null | sort | uniq -c | sort -rn | head -3 | awk '{$1=$1; print}' || echo "")
        fi
    fi
    
    # Score based on access frequency (more accesses = better engagement)
    if [[ "$access_count" -gt 100 ]]; then
        usage_score=10.0
    elif [[ "$access_count" -gt 0 ]]; then
        usage_score=$(echo "scale=2; ($access_count / 100) * 10" | bc 2>/dev/null || echo "5")
    else
        usage_score=5.0  # Neutral if no data
    fi
    
    echo "$usage_score|$access_count|$top_accessed"
}

# Calculate overall weighted score
calculate_overall_score() {
    local retrieval=$1
    local freshness=$2
    local coverage=$3
    local curation=$4
    
    local overall
    overall=$(echo "scale=2; ($retrieval * $WEIGHT_RETRIEVAL + $freshness * $WEIGHT_FRESHNESS + $coverage * $WEIGHT_COVERAGE + $curation * $WEIGHT_CURATION) / 100" | bc 2>/dev/null || echo "0")
    
    echo "$overall"
}

# Update trend history
update_trend_history() {
    local date_str=$1
    local overall_score=$2
    local retrieval=$3
    local freshness=$4
    local coverage=$5
    local curation=$6
    
    if command -v jq &> /dev/null; then
        local entry
        entry=$(jq -n \
            --arg date "$date_str" \
            --argjson overall "$overall_score" \
            --argjson r "$retrieval" \
            --argjson f "$freshness" \
            --argjson c "$coverage" \
            --argjson u "$curation" \
            '{date: $date, overall: $overall, retrieval: $r, freshness: $f, coverage: $c, curation: $u}')
        
        # Read current history, add new entry, keep only last 30 days
        local updated
        updated=$(jq --argjson entry "$entry" '. + [$entry] | sort_by(.date) | unique_by(.date) | .[-'$MAX_HISTORY_DAYS':]' "$TREND_FILE" 2>/dev/null || echo "[$entry]")
        
        echo "$updated" > "$TREND_FILE"
    fi
}

# Check for alerts
check_alerts() {
    local current_score=$1
    local date_str=$2
    
    local alert_triggered=false
    local alert_message=""
    
    # Read alert state
    local consecutive_low=0
    local last_alert_date="null"
    
    if command -v jq &> /dev/null && [[ -f "$ALERT_STATE_FILE" ]]; then
        consecutive_low=$(jq -r '.consecutive_low_days // 0' "$ALERT_STATE_FILE" 2>/dev/null || echo "0")
        last_alert_date=$(jq -r '.last_alert_date // "null"' "$ALERT_STATE_FILE" 2>/dev/null || echo "null")
    fi
    
    # Check if score is below threshold
    if (( $(echo "$current_score < $ALERT_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        consecutive_low=$((consecutive_low + 1))
        
        if [[ "$consecutive_low" -ge "$ALERT_CONSECUTIVE_DAYS" ]]; then
            alert_triggered=true
            alert_message="ALERT: Memory quality score has been below $ALERT_THRESHOLD for $consecutive_low consecutive days (current: $current_score)"
        fi
    else
        consecutive_low=0
    fi
    
    # Update alert state
    if command -v jq &> /dev/null; then
        jq -n \
            --argjson low "$consecutive_low" \
            --arg date "$date_str" \
            '{consecutive_low_days: $low, last_alert_date: $date}' > "$ALERT_STATE_FILE"
    fi
    
    echo "$alert_triggered|$alert_message|$consecutive_low"
}

# Generate ASCII trend graph
generate_trend_graph() {
    if ! command -v jq &> /dev/null || [[ ! -f "$TREND_FILE" ]]; then
        echo "Trend data not available (jq required)"
        return
    fi
    
    local history
    history=$(jq '.[-7:]' "$TREND_FILE" 2>/dev/null || echo "[]")
    
    if [[ "$history" == "[]" ]] || [[ "$history" == "null" ]]; then
        echo "No trend data available yet. Run metrics collection first."
        return
    fi
    
    echo ""
    echo -e "${BOLD}Memory Quality Score - 7 Day Trend${NC}"
    echo ""
    
    # Get values for scaling
    local max_val=10
    local min_val=0
    
    # Build graph
    local graph_height=10
    local width=50
    
    echo -e "${CYAN}    Score${NC}"
    echo -e "${CYAN}    10.0 ┤${NC}"
    
    for ((row=graph_height-1; row>=0; row--)); do
        local threshold
        threshold=$(echo "scale=1; $row" | bc 2>/dev/null || echo "$row")
        printf "${CYAN}%6.1f ┤${NC} " "$threshold"
        
        # Print data points
        local count
        count=$(echo "$history" | jq 'length')
        for ((i=0; i<count; i++)); do
            local score
            score=$(echo "$history" | jq -r ".[$i].overall // 0")
            if (( $(echo "$score >= $threshold" | bc -l 2>/dev/null || echo "0") )); then
                echo -n "${GREEN}█${NC} "
            else
                echo -n "  "
            fi
        done
        echo ""
    done
    
    echo -e "${CYAN}     0.0 ┴${NC}────────────────────────────────────"
    echo -e "${CYAN}           ${NC}$(echo "$history" | jq -r '.[].date' | xargs | sed 's/ /  /g')"
    echo ""
    
    # Show target line
    echo -e "${YELLOW}Target: ${TARGET_SCORE}/10${NC}  |  ${RED}Alert Threshold: ${ALERT_THRESHOLD}/10${NC}"
    echo ""
}

# Generate weekly report
generate_weekly_report() {
    if ! command -v jq &> /dev/null || [[ ! -f "$TREND_FILE" ]]; then
        echo "Report data not available (jq required)"
        return
    fi
    
    local history
    history=$(jq '.[-7:]' "$TREND_FILE" 2>/dev/null || echo "[]")
    
    if [[ "$history" == "[]" ]] || [[ "$history" == "null" ]]; then
        echo "No data available for weekly report."
        return
    fi
    
    local avg_score
    avg_score=$(echo "$history" | jq '[.[].overall] | add / length' 2>/dev/null || echo "0")
    local min_score
    min_score=$(echo "$history" | jq '[.[].overall] | min' 2>/dev/null || echo "0")
    local max_score
    max_score=$(echo "$history" | jq '[.[].overall] | max' 2>/dev/null || echo "0")
    local trend_direction="stable"
    
    # Determine trend
    local first_score
    first_score=$(echo "$history" | jq '.[0].overall // 0' 2>/dev/null || echo "0")
    local last_score
    last_score=$(echo "$history" | jq '.[-1].overall // 0' 2>/dev/null || echo "0")
    
    if (( $(echo "$last_score > $first_score + 0.5" | bc -l 2>/dev/null || echo "0") )); then
        trend_direction="improving 📈"
    elif (( $(echo "$last_score < $first_score - 0.5" | bc -l 2>/dev/null || echo "0") )); then
        trend_direction="declining 📉"
    fi
    
    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║           Weekly Memory Quality Report                       ║${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Period: ${CYAN}$(echo "$history" | jq -r '.[0].date')${NC} to ${CYAN}$(echo "$history" | jq -r '.[-1].date')${NC}"
    echo ""
    echo -e "${BOLD}Summary:${NC}"
    printf "  Average Score:    %.2f/10\n" "$avg_score"
    printf "  Minimum Score:    %.2f/10\n" "$min_score"
    printf "  Maximum Score:    %.2f/10\n" "$max_score"
    echo "  Trend Direction:  $trend_direction"
    echo ""
    
    # Component breakdown
    echo -e "${BOLD}Component Averages:${NC}"
    local avg_retrieval
    avg_retrieval=$(echo "$history" | jq '[.[].retrieval] | add / length' 2>/dev/null || echo "0")
    local avg_freshness
    avg_freshness=$(echo "$history" | jq '[.[].freshness] | add / length' 2>/dev/null || echo "0")
    local avg_coverage
    avg_coverage=$(echo "$history" | jq '[.[].coverage] | add / length' 2>/dev/null || echo "0")
    local avg_curation
    avg_curation=$(echo "$history" | jq '[.[].curation] | add / length' 2>/dev/null || echo "0")
    
    printf "  • Retrieval Accuracy:  %.2f/10\n" "$avg_retrieval"
    printf "  • Context Freshness:   %.2f/10\n" "$avg_freshness"
    printf "  • Memory Coverage:     %.2f/10\n" "$avg_coverage"
    printf "  • Curation Quality:    %.2f/10\n" "$avg_curation"
    echo ""
    
    # Recommendations
    echo -e "${BOLD}Recommendations:${NC}"
    if (( $(echo "$avg_retrieval < 7" | bc -l 2>/dev/null || echo "0") )); then
        echo "  ⚠️  Review memory search configuration for better retrieval accuracy"
    fi
    if (( $(echo "$avg_freshness < 7" | bc -l 2>/dev/null || echo "0") )); then
        echo "  ⚠️  Update stale memory files to improve freshness"
    fi
    if (( $(echo "$avg_coverage < 7" | bc -l 2>/dev/null || echo "0") )); then
        echo "  ⚠️  Add missing core memory files (AGENTS.md, TOOLS.md, etc.)"
    fi
    if (( $(echo "$avg_curation < 7" | bc -l 2>/dev/null || echo "0") )); then
        echo "  ⚠️  Clean up empty lines and improve content density"
    fi
    
    if (( $(echo "$avg_score >= 8" | bc -l 2>/dev/null || echo "0") )); then
        echo -e "  ${GREEN}✓ Memory quality is meeting targets. Keep it up!${NC}"
    fi
    echo ""
}

# Print pretty metrics table
print_metrics_table() {
    local retrieval_score=$1
    local retrieval_raw=$2
    local freshness_score=$3
    local freshness_raw=$4
    local coverage_score=$5
    local coverage_raw=$6
    local coverage_files=$7
    local curation_score=$8
    local curation_raw=$9
    local overall_score=${10}
    local usage_count=${11}
    
    echo ""
    echo -e "${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║           Memory Quality Metrics                               ║${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Overall score with color
    local score_color="$GREEN"
    if (( $(echo "$overall_score < $ALERT_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
        score_color="$RED"
    elif (( $(echo "$overall_score < $TARGET_SCORE" | bc -l 2>/dev/null || echo "0") )); then
        score_color="$YELLOW"
    fi
    
    printf "${BOLD}Overall Quality Score: ${score_color}%.2f/10${NC}\n" "$overall_score"
    echo ""
    
    # Metrics table
    echo -e "${BLUE}┌─────────────────────────┬───────────┬─────────────────────────────┬──────────┐${NC}"
    echo -e "${BLUE}│${NC} ${BOLD}Metric${NC}                  ${BLUE}│${NC} ${BOLD}Weight${NC}    ${BLUE}│${NC} ${BOLD}Score / Raw Value${NC}           ${BLUE}│${NC} ${BOLD}Status${NC}   ${BLUE}│${NC}"
    echo -e "${BLUE}├─────────────────────────┼───────────┼─────────────────────────────┼──────────┤${NC}"
    
    # Retrieval Accuracy
    local r_status="${GREEN}✓${NC}"
    if (( $(echo "$retrieval_score < 7" | bc -l 2>/dev/null || echo "0") )); then
        r_status="${YELLOW}⚠${NC}"
    fi
    if (( $(echo "$retrieval_score < 5" | bc -l 2>/dev/null || echo "0") )); then
        r_status="${RED}✗${NC}"
    fi
    printf "${BLUE}│${NC} %-23s ${BLUE}│${NC} %8s%% ${BLUE}│${NC} %5.1f/10  (%.1f%% accurate)   ${BLUE}│${NC}   %s    ${BLUE}│${NC}\n" \
        "Retrieval Accuracy" "$WEIGHT_RETRIEVAL" "$retrieval_score" "$retrieval_raw" "$r_status"
    
    # Context Freshness
    local f_status="${GREEN}✓${NC}"
    if (( $(echo "$freshness_score < 7" | bc -l 2>/dev/null || echo "0") )); then
        f_status="${YELLOW}⚠${NC}"
    fi
    printf "${BLUE}│${NC} %-23s ${BLUE}│${NC} %8s%% ${BLUE}│${NC} %5.1f/10  (~%d hrs avg)       ${BLUE}│${NC}   %s    ${BLUE}│${NC}\n" \
        "Context Freshness" "$WEIGHT_FRESHNESS" "$freshness_score" "$freshness_raw" "$f_status"
    
    # Memory Coverage
    local c_status="${GREEN}✓${NC}"
    if (( $(echo "$coverage_score < 7" | bc -l 2>/dev/null || echo "0") )); then
        c_status="${YELLOW}⚠${NC}"
    fi
    printf "${BLUE}│${NC} %-23s ${BLUE}│${NC} %8s%% ${BLUE}│${NC} %5.1f/10  (%.0f%% - %d files) ${BLUE}│${NC}   %s    ${BLUE}│${NC}\n" \
        "Memory Coverage" "$WEIGHT_COVERAGE" "$coverage_score" "$coverage_raw" "$coverage_files" "$c_status"
    
    # Curation Quality
    local u_status="${GREEN}✓${NC}"
    if (( $(echo "$curation_score < 7" | bc -l 2>/dev/null || echo "0") )); then
        u_status="${YELLOW}⚠${NC}"
    fi
    printf "${BLUE}│${NC} %-23s ${BLUE}│${NC} %8s%% ${BLUE}│${NC} %5.1f/10  (%.1f%% density)    ${BLUE}│${NC}   %s    ${BLUE}│${NC}\n" \
        "Curation Quality" "$WEIGHT_CURATION" "$curation_score" "$curation_raw" "$u_status"
    
    echo -e "${BLUE}└─────────────────────────┴───────────┴─────────────────────────────┴──────────┘${NC}"
    echo ""
    
    # Usage stats
    echo -e "${BOLD}Usage Statistics:${NC}"
    echo "  Total metric records: $usage_count"
    echo ""
    
    # Thresholds
    echo -e "${BOLD}Thresholds:${NC}"
    echo -e "  Target Score:        ${GREEN}≥${TARGET_SCORE}/10${NC}"
    echo -e "  Alert Threshold:     ${RED}<${ALERT_THRESHOLD}/10${NC} for ${ALERT_CONSECUTIVE_DAYS}+ days"
    echo ""
}

# Run all metrics calculations and output results
run_metrics() {
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%SZ")
    local date_str
    date_str=$(date +"%Y-%m-%d" 2>/dev/null || echo "unknown")
    
    # Calculate individual metrics
    local retrieval_result
    retrieval_result=$(calculate_retrieval_accuracy)
    local retrieval_score=$(echo "$retrieval_result" | cut -d'|' -f1)
    local retrieval_raw=$(echo "$retrieval_result" | cut -d'|' -f2)
    
    local freshness_result
    freshness_result=$(calculate_freshness)
    local freshness_score=$(echo "$freshness_result" | cut -d'|' -f1)
    local freshness_raw=$(echo "$freshness_result" | cut -d'|' -f2)
    
    local coverage_result
    coverage_result=$(calculate_coverage)
    local coverage_score=$(echo "$coverage_result" | cut -d'|' -f1)
    local coverage_raw=$(echo "$coverage_result" | cut -d'|' -f2)
    local coverage_files=$(echo "$coverage_result" | cut -d'|' -f3)
    
    local curation_result
    curation_result=$(calculate_curation_quality)
    local curation_score=$(echo "$curation_result" | cut -d'|' -f1)
    local curation_raw=$(echo "$curation_result" | cut -d'|' -f2)
    
    local usage_result
    usage_result=$(calculate_usage_patterns)
    local usage_score=$(echo "$usage_result" | cut -d'|' -f1)
    local usage_count=$(echo "$usage_result" | cut -d'|' -f2)
    
    # Calculate overall score
    local overall_score
    overall_score=$(calculate_overall_score "$retrieval_score" "$freshness_score" "$coverage_score" "$curation_score")
    
    # Update trend history (ensure numeric values)
    local overall_num=$(echo "$overall_score" | grep -oE '^[0-9]+\.?[0-9]*' || echo "0")
    local ret_num=$(echo "$retrieval_score" | grep -oE '^[0-9]+\.?[0-9]*' || echo "0")
    local fresh_num=$(echo "$freshness_score" | grep -oE '^[0-9]+\.?[0-9]*' || echo "0")
    local cov_num=$(echo "$coverage_score" | grep -oE '^[0-9]+\.?[0-9]*' || echo "0")
    local cur_num=$(echo "$curation_score" | grep -oE '^[0-9]+\.?[0-9]*' || echo "0")
    update_trend_history "$date_str" "$overall_num" "$ret_num" "$fresh_num" "$cov_num" "$cur_num"
    
    # Check alerts
    local alert_result
    alert_result=$(check_alerts "$overall_score" "$date_str")
    local alert_triggered=$(echo "$alert_result" | cut -d'|' -f1)
    local alert_message=$(echo "$alert_result" | cut -d'|' -f2)
    local consecutive_low=$(echo "$alert_result" | cut -d'|' -f3)
    
    # Build JSON output
    local json_output
    json_output=$(cat << EOF
{
    "timestamp": "$timestamp",
    "date": "$date_str",
    "overall_score": $overall_score,
    "target_score": $TARGET_SCORE,
    "alert_threshold": $ALERT_THRESHOLD,
    "metrics": {
        "retrieval_accuracy": {
            "score": $retrieval_score,
            "raw_percent": $retrieval_raw,
            "weight": $WEIGHT_RETRIEVAL
        },
        "context_freshness": {
            "score": $freshness_score,
            "avg_age_hours": $freshness_raw,
            "weight": $WEIGHT_FRESHNESS
        },
        "memory_coverage": {
            "score": $coverage_score,
            "coverage_percent": $coverage_raw,
            "files_indexed": $coverage_files,
            "weight": $WEIGHT_COVERAGE
        },
        "curation_quality": {
            "score": $curation_score,
            "truth_density_percent": $curation_raw,
            "weight": $WEIGHT_CURATION
        }
    },
    "usage": {
        "total_records": $usage_count
    },
    "alerts": {
        "triggered": $alert_triggered,
        "message": "$alert_message",
        "consecutive_low_days": $consecutive_low
    }
}
EOF
)
    
    # Store for other functions
    echo "$json_output"
}

# Log results to JSONL
log_results() {
    local json_data="$1"
    echo "$json_data" >> "$LOG_FILE"
    
    # Rotate if too large
    if [[ -f "$LOG_FILE" ]]; then
        local size
        size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo "0")
        if [[ "$size" -gt 52428800 ]]; then  # 50MB
            mv "$LOG_FILE" "${LOG_FILE}.old"
            touch "$LOG_FILE"
        fi
    fi
}

# Main execution
main() {
    parse_args "$@"
    init_logs
    
    # Handle specific flags first
    if $FLAG_TREND; then
        generate_trend_graph
        return 0
    fi
    
    if $FLAG_REPORT; then
        generate_weekly_report
        return 0
    fi
    
    # Run metrics collection
    local json_data
    json_data=$(run_metrics)
    
    # Parse values for display
    local overall_score retrieval_score retrieval_raw freshness_score freshness_raw
    local coverage_score coverage_raw coverage_files curation_score curation_raw usage_count
    
    overall_score=$(echo "$json_data" | grep -oE '"overall_score": [0-9.]+' | grep -oE '[0-9.]+' | head -1 || echo "0")
    retrieval_score=$(echo "$json_data" | grep -oE '"retrieval_accuracy": \{[^}]+\}' | grep -oE '"score": [0-9.]+' | grep -oE '[0-9.]+' | head -1 || echo "0")
    retrieval_raw=$(echo "$json_data" | grep -oE '"retrieval_accuracy": \{[^}]+\}' | grep -oE '"raw_percent": [0-9.]+' | grep -oE '[0-9.]+' | head -1 || echo "0")
    freshness_score=$(echo "$json_data" | grep -oE '"context_freshness": \{[^}]+\}' | grep -oE '"score": [0-9.]+' | grep -oE '[0-9.]+' | head -1 || echo "0")
    freshness_raw=$(echo "$json_data" | grep -oE '"context_freshness": \{[^}]+\}' | grep -oE '"avg_age_hours": [0-9]+' | grep -oE '[0-9]+' | head -1 || echo "0")
    coverage_score=$(echo "$json_data" | grep -oE '"memory_coverage": \{[^}]+\}' | grep -oE '"score": [0-9.]+' | grep -oE '[0-9.]+' | head -1 || echo "0")
    coverage_raw=$(echo "$json_data" | grep -oE '"memory_coverage": \{[^}]+\}' | grep -oE '"coverage_percent": [0-9.]+' | grep -oE '[0-9.]+' | head -1 || echo "0")
    coverage_files=$(echo "$json_data" | grep -oE '"memory_coverage": \{[^}]+\}' | grep -oE '"files_indexed": [0-9]+' | grep -oE '[0-9]+' | head -1 || echo "0")
    curation_score=$(echo "$json_data" | grep -oE '"curation_quality": \{[^}]+\}' | grep -oE '"score": [0-9.]+' | grep -oE '[0-9.]+' | head -1 || echo "0")
    curation_raw=$(echo "$json_data" | grep -oE '"curation_quality": \{[^}]+\}' | grep -oE '"truth_density_percent": [0-9.]+' | grep -oE '[0-9.]+' | head -1 || echo "0")
    usage_count=$(echo "$json_data" | grep -oE '"total_records": [0-9]+' | grep -oE '[0-9]+' | head -1 || echo "0")
    
    # Output based on flags
    if $FLAG_JSON; then
        echo "$json_data"
    elif $FLAG_CHECK; then
        # Check only mode - minimal output
        if $FLAG_ALERT; then
            local alert_triggered
            alert_triggered=$(echo "$json_data" | grep -oE '"triggered": (true|false)' | cut -d: -f2 | tr -d ' ' || echo "false")
            if [[ "$alert_triggered" == "true" ]]; then
                local alert_message
                alert_message=$(echo "$json_data" | grep -oE '"message": "[^"]+"' | cut -d'"' -f4 || echo "Alert triggered")
                echo -e "${RED}ALERT: $alert_message${NC}"
                return 1
            else
                echo -e "${GREEN}Memory quality score: ${overall_score}/10 - No alerts${NC}"
            fi
        fi
    else
        # Default: pretty table
        print_metrics_table "$retrieval_score" "$retrieval_raw" "$freshness_score" "$freshness_raw" \
                           "$coverage_score" "$coverage_raw" "$coverage_files" "$curation_score" "$curation_raw" \
                           "$overall_score" "$usage_count"
        
        if $FLAG_ALERT; then
            local alert_triggered
            alert_triggered=$(echo "$json_data" | grep -oE '"triggered": (true|false)' | cut -d: -f2 | tr -d ' ' || echo "false")
            if [[ "$alert_triggered" == "true" ]]; then
                local alert_message
                alert_message=$(echo "$json_data" | grep -oE '"message": "[^"]+"' | cut -d'"' -f4 || echo "Alert triggered")
                echo -e "${RED}${BOLD}$alert_message${NC}"
                echo ""
            fi
        fi
    fi
    
    # Always log results
    log_results "$json_data"
}

# Run main
main "$@"
