#!/bin/bash
# Sprint Start Script
# Activates a sprint and notifies all assigned agents
# Usage: ./start-sprint.sh --sprint-dir <path> [--notify]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

SPRINT_DIR=""
NOTIFY=false
FORCE=false
VERBOSE=false

# ============================================
# LOGGING
# ============================================

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
log_success() { echo -e "${GREEN}[$(date +'%H:%M:%S')] ✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠${NC} $1"; }
log_error() { echo -e "${RED}[$(date +'%H:%M:%S')] ✗${NC} $1"; }
log_info() { echo -e "${CYAN}[$(date +'%H:%M:%S')] ℹ${NC} $1"; }
announce() { echo -e "${MAGENTA}${BOLD}$1${NC}"; }

# ============================================
# HELP
# ============================================

show_help() {
    cat << EOF
${BOLD}Sprint Start Script${NC}

Usage: $(basename "$0") [OPTIONS]

Required:
  -d, --sprint-dir <path>  Path to sprint directory

Optional:
  -n, --notify             Notify assigned agents
  -f, --force              Force start even if validation fails
  -v, --verbose            Verbose output
  -h, --help               Show this help

Examples:
  $(basename "$0") -d ../sprints/level-1-foundation-setup
  $(basename "$0") -d ../sprints/level-3-api-development --notify

EOF
}

# ============================================
# ARGUMENT PARSING
# ============================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--sprint-dir)
                SPRINT_DIR="$2"
                shift 2
                ;;
            -n|--notify)
                NOTIFY=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

# ============================================
# VALIDATION
# ============================================

validate_sprint() {
    if [[ -z "$SPRINT_DIR" ]]; then
        log_error "Sprint directory is required. Use -d or --sprint-dir"
        exit 1
    fi
    
    if [[ ! -d "$SPRINT_DIR" ]]; then
        log_error "Sprint directory does not exist: $SPRINT_DIR"
        exit 1
    fi
    
    if [[ ! -f "${SPRINT_DIR}/sprint.json" ]]; then
        log_error "No sprint.json found in: $SPRINT_DIR"
        log_info "This doesn't appear to be a valid sprint directory"
        exit 1
    fi
    
    log_success "Sprint directory validated"
}

# ============================================
# SPRINT OPERATIONS
# ============================================

load_sprint_data() {
    local sprint_file="${SPRINT_DIR}/sprint.json"
    SPRINT_ID=$(jq -r '.id' "$sprint_file")
    SPRINT_LEVEL=$(jq -r '.level' "$sprint_file")
    SPRINT_NAME=$(jq -r '.name' "$sprint_file")
    SPRINT_STATUS=$(jq -r '.status' "$sprint_file")
    SPRINT_AGENTS=$(jq -r '.agents | join(",")' "$sprint_file")
    SPRINT_XP=$(jq -r '.base_xp + .bonus_xp' "$sprint_file")
    
    log_info "Loaded sprint: $SPRINT_NAME (Level $SPRINT_LEVEL)"
}

check_sprint_status() {
    if [[ "$SPRINT_STATUS" == "active" ]]; then
        log_warn "Sprint is already active!"
        if [[ "$FORCE" != "true" ]]; then
            read -p "Restart sprint? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 0
            fi
        fi
    elif [[ "$SPRINT_STATUS" == "completed" ]]; then
        log_warn "Sprint has already been completed!"
        if [[ "$FORCE" != "true" ]]; then
            exit 1
        fi
    fi
}

activate_sprint() {
    log "Activating sprint..."
    
    # Update sprint.json
    local tmp_file=$(mktemp)
    jq '.status = "active" | .started_at = now | .activated_at = now' "${SPRINT_DIR}/sprint.json" > "$tmp_file"
    mv "$tmp_file" "${SPRINT_DIR}/sprint.json"
    
    # Update README
    local readme_file="${SPRINT_DIR}/README.md"
    if [[ -f "$readme_file" ]]; then
        sed -i.bak 's/🟡 Planning/🟢 Active/' "$readme_file"
        sed -i.bak "s/\\*\\*Started:\\*\\* \\[Date\\]/\\*\\*Started:\\*\\* $(date '+%Y-%m-%d %H:%M')/" "$readme_file"
        rm -f "${readme_file}.bak"
    fi
    
    # Create active sprint marker
    echo "$SPRINT_DIR" > "${PROJECT_ROOT}/.active-sprint"
    
    log_success "Sprint activated!"
}

generate_agent_tasks() {
    log "Generating agent task assignments..."
    
    local tasks_dir="${SPRINT_DIR}/tasks"
    local agents_dir="${SPRINT_DIR}/agent-assignments"
    mkdir -p "$agents_dir"
    
    # Read agents from sprint
    IFS=',' read -ra AGENT_LIST <<< "$SPRINT_AGENTS"
    
    # Distribute tasks among agents
    local task_files=("${tasks_dir}"/*.md)
    local agent_count=${#AGENT_LIST[@]}
    local task_count=${#task_files[@]}
    
    if [[ $agent_count -eq 0 ]]; then
        log_warn "No agents assigned to sprint"
        return
    fi
    
    local tasks_per_agent=$(( (task_count + agent_count - 1) / agent_count ))
    
    local agent_idx=0
    local task_idx=0
    
    for agent in "${AGENT_LIST[@]}"; do
        local agent_clean=$(echo "$agent" | tr -d '@' | tr '[:upper:]' '[:lower:]')
        local agent_file="${agents_dir}/${agent_clean}.md"
        
        cat > "$agent_file" << EOF
# Task Assignment: $agent

**Sprint:** Level $SPRINT_LEVEL - $SPRINT_NAME  
**Assigned:** $(date '+%Y-%m-%d %H:%M')

## Your Tasks

EOF
        
        # Assign tasks round-robin
        local assigned=0
        while [[ $assigned -lt $tasks_per_agent && $task_idx -lt $task_count ]]; do
            local task_file="${task_files[$task_idx]}"
            local task_name=$(grep "^# " "$task_file" | head -1 | sed 's/^# //')
            
            echo "- [ ] $task_name" >> "$agent_file"
            
            # Update task file with assignment
            local task_tmp=$(mktemp)
            sed "s/\\*\\*Assigned to:\\*\\* \\[Agent Handle\\]/\\*\\*Assigned to:\\*\\* $agent/" "$task_file" > "$task_tmp"
            mv "$task_tmp" "$task_file"
            
            assigned=$((assigned + 1))
            task_idx=$((task_idx + 1))
        done
        
        echo "" >> "$agent_file"
        echo "---" >> "$agent_file"
        echo "*Auto-generated by Sprint Start Script*" >> "$agent_file"
        
        log_success "Generated task list for $agent"
    done
}

notify_agents() {
    if [[ "$NOTIFY" != "true" ]]; then
        return
    fi
    
    log "Notifying assigned agents..."
    
    IFS=',' read -ra AGENT_LIST <<< "$SPRINT_AGENTS"
    
    for agent in "${AGENT_LIST[@]}"; do
        local agent_clean=$(echo "$agent" | tr -d '@' | tr '[:upper:]' '[:lower:]')
        local notification_file="${PROJECT_ROOT}/notifications/${agent_clean}-$(date +%s).json"
        
        mkdir -p "${PROJECT_ROOT}/notifications"
        
        cat > "$notification_file" << EOF
{
    "type": "sprint_start",
    "agent": "$agent",
    "sprint": {
        "id": "$SPRINT_ID",
        "level": $SPRINT_LEVEL,
        "name": "$SPRINT_NAME",
        "xp_available": $SPRINT_XP
    },
    "notification": {
        "title": "🎮 Sprint Started: Level $SPRINT_LEVEL",
        "message": "You have been assigned to '$SPRINT_NAME'. Check your task list!",
        "priority": "high",
        "action_required": true,
        "action_url": "${SPRINT_DIR}/agent-assignments/${agent_clean}.md"
    },
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
        
        log_success "Notification queued for $agent"
    done
    
    log_info "Notifications written to: ${PROJECT_ROOT}/notifications/"
}

create_sprint_event() {
    local events_dir="${PROJECT_ROOT}/events"
    mkdir -p "$events_dir"
    
    cat > "${events_dir}/sprint-start-$(date +%s).json" << EOF
{
    "event_type": "sprint_started",
    "sprint_id": "$SPRINT_ID",
    "sprint_level": $SPRINT_LEVEL,
    "sprint_name": "$SPRINT_NAME",
    "agents": [$(echo "$SPRINT_AGENTS" | tr ',' '\n' | while read -r a; do echo "\"$a\","; done | sed '$s/,$//')],
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "requires_action": true
}
EOF
}

print_banner() {
    echo
    announce "╔═══════════════════════════════════════════════════════════╗"
    announce "║                                                           ║"
    announce "║     🚀 SPRINT ACTIVATED - LEVEL $SPRINT_LEVEL                              ║"
    announce "║                                                           ║"
    announce "╠═══════════════════════════════════════════════════════════╣"
    announce "║  Sprint: $SPRINT_NAME"
    announce "║  XP Pool: ${SPRINT_XP}"
    announce "║  Agents: ${SPRINT_AGENTS:-None assigned}"
    announce "║  Status: 🟢 ACTIVE"
    announce "╚═══════════════════════════════════════════════════════════╝"
    echo
}

# ============================================
# MAIN
# ============================================

main() {
    parse_args "$@"
    validate_sprint
    load_sprint_data
    check_sprint_status
    
    log "Starting sprint activation sequence..."
    echo
    
    activate_sprint
    generate_agent_tasks
    notify_agents
    create_sprint_event
    
    print_banner
    
    log_info "Sprint is now ACTIVE!"
    echo
    echo "Next steps:"
    echo "  1. Agents check their assignments in: ${SPRINT_DIR}/agent-assignments/"
    echo "  2. Update task status as work progresses"
    echo "  3. Run progress check: ${SCRIPT_DIR}/sprint-status.sh"
    echo "  4. Complete sprint with: ${SCRIPT_DIR}/complete-sprint.sh --sprint-dir $SPRINT_DIR"
    echo
}

main "$@"
