#!/bin/bash
# Agent Coordination Hook
# Handles agent notifications, task assignments, and XP awards
# Usage: ./agent-hook.sh --action <type> [options]

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

# Action type
ACTION=""
AGENT=""
TASK=""
SPRINT_DIR=""
XP_AMOUNT=0
REASON=""
MESSAGE=""

# ============================================
# LOGGING
# ============================================

log() { echo -e "${BLUE}[HOOK]${NC} $1"; }
success() { echo -e "${GREEN}[HOOK]${NC} $1"; }
warn() { echo -e "${YELLOW}[HOOK]${NC} $1"; }
error() { echo -e "${RED}[HOOK]${NC} $1"; }
info() { echo -e "${CYAN}[HOOK]${NC} $1"; }

# ============================================
# HELP
# ============================================

show_help() {
    cat << EOF
${BOLD}Agent Coordination Hook${NC}

Usage: $(basename "$0") --action <type> [options]

Actions:
  notify          Send notification to agent
  assign          Assign task to agent
  complete        Mark task complete and award XP
  xp-award        Award XP to agent
  level-check     Check for level up
  status          Get agent status

Options:
  -a, --agent <handle>      Agent handle (e.g., @builder)
  -t, --task <path>         Task file path
  -s, --sprint-dir <path>   Sprint directory
  -x, --xp <amount>         XP amount to award
  -r, --reason <text>       Reason for XP award
  -m, --message <text>      Notification message
  -h, --help                Show this help

Examples:
  $(basename "$0") --action notify --agent @builder --message "Task assigned"
  $(basename "$0") --action assign --agent @builder --task ./tasks/01-task.md
  $(basename "$0") --action complete --agent @builder --task ./tasks/01-task.md
  $(basename "$0") --action xp-award --agent @builder --xp 25 --reason "Great work!"

EOF
}

# ============================================
# ARGUMENT PARSING
# ============================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --action)
                ACTION="$2"
                shift 2
                ;;
            -a|--agent)
                AGENT="$2"
                shift 2
                ;;
            -t|--task)
                TASK="$2"
                shift 2
                ;;
            -s|--sprint-dir)
                SPRINT_DIR="$2"
                shift 2
                ;;
            -x|--xp)
                XP_AMOUNT="$2"
                shift 2
                ;;
            -r|--reason)
                REASON="$2"
                shift 2
                ;;
            -m|--message)
                MESSAGE="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

# ============================================
# UTILITY FUNCTIONS
# ============================================

get_agent_clean() {
    echo "$1" | tr -d '@' | tr '[:upper:]' '[:lower:]'
}

ensure_sprint_dir() {
    if [[ -z "$SPRINT_DIR" ]]; then
        if [[ -f "${PROJECT_ROOT}/.active-sprint" ]]; then
            SPRINT_DIR=$(cat "${PROJECT_ROOT}/.active-sprint")
        else
            error "No sprint directory specified and no active sprint found"
            exit 1
        fi
    fi
    
    if [[ ! -d "$SPRINT_DIR" ]]; then
        error "Sprint directory not found: $SPRINT_DIR"
        exit 1
    fi
}

load_sprint_data() {
    SPRINT_FILE="${SPRINT_DIR}/sprint.json"
    if [[ ! -f "$SPRINT_FILE" ]]; then
        error "No sprint.json found in $SPRINT_DIR"
        exit 1
    fi
    
    SPRINT_ID=$(jq -r '.id' "$SPRINT_FILE")
    SPRINT_LEVEL=$(jq -r '.level' "$SPRINT_FILE")
    SPRINT_NAME=$(jq -r '.name' "$SPRINT_FILE")
}

# ============================================
# ACTION: NOTIFY
# ============================================

action_notify() {
    if [[ -z "$AGENT" ]]; then
        error "Agent required for notify action"
        exit 1
    fi
    
    ensure_sprint_dir
    load_sprint_data
    
    local agent_clean
    agent_clean=$(get_agent_clean "$AGENT")
    
    local notif_dir="${PROJECT_ROOT}/notifications"
    mkdir -p "$notif_dir"
    
    local notif_file="${notif_dir}/${agent_clean}-$(date +%s).json"
    
    cat > "$notif_file" << EOF
{
    "type": "agent_notification",
    "agent": "$AGENT",
    "message": "${MESSAGE:-You have a new notification}",
    "sprint": {
        "id": "$SPRINT_ID",
        "level": $SPRINT_LEVEL,
        "name": "$SPRINT_NAME"
    },
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "priority": "normal"
}
EOF
    
    success "Notification sent to $AGENT"
    info "Notification file: $notif_file"
}

# ============================================
# ACTION: ASSIGN
# ============================================

action_assign() {
    if [[ -z "$AGENT" || -z "$TASK" ]]; then
        error "Agent and task required for assign action"
        exit 1
    fi
    
    if [[ ! -f "$TASK" ]]; then
        error "Task file not found: $TASK"
        exit 1
    fi
    
    ensure_sprint_dir
    load_sprint_data
    
    # Update task file
    local tmp_file=$(mktemp)
    sed "s/\\*\\*Assigned to:\\*\\* \\[Agent Handle\\]/\\*\\*Assigned to:\\*\\* $AGENT/" "$TASK" > "$tmp_file"
    sed -i.bak 's/Status: 🔴 Pending/Status: 🟡 In Progress/' "$tmp_file"
    sed -i.bak "s/\\*\\*Started:\\*\\* \\[Date\\]/\\*\\*Started:\\*\\* $(date '+%Y-%m-%d')/" "$tmp_file"
    mv "$tmp_file" "$TASK"
    rm -f "${tmp_file}.bak"
    
    # Update agent assignment file
    local agent_clean
    agent_clean=$(get_agent_clean "$AGENT")
    local agent_file="${SPRINT_DIR}/agent-assignments/${agent_clean}.md"
    
    if [[ -f "$agent_file" ]]; then
        local task_name
        task_name=$(grep "^# " "$TASK" | head -1 | sed 's/^# //')
        
        if ! grep -q "$task_name" "$agent_file"; then
            echo "- [ ] $task_name" >> "$agent_file"
        fi
    fi
    
    # Create event
    local events_dir="${PROJECT_ROOT}/events"
    mkdir -p "$events_dir"
    
    cat > "${events_dir}/task-assigned-$(date +%s).json" << EOF
{
    "event_type": "task_assigned",
    "agent": "$AGENT",
    "task_file": "$TASK",
    "sprint_id": "$SPRINT_ID",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    success "Task assigned to $AGENT"
    info "Task: $(basename "$TASK")"
}

# ============================================
# ACTION: COMPLETE
# ============================================

action_complete() {
    if [[ -z "$AGENT" || -z "$TASK" ]]; then
        error "Agent and task required for complete action"
        exit 1
    fi
    
    if [[ ! -f "$TASK" ]]; then
        error "Task file not found: $TASK"
        exit 1
    fi
    
    ensure_sprint_dir
    load_sprint_data
    
    # Get task XP
    local task_xp
    task_xp=$(grep "XP Reward:" "$TASK" | sed 's/.*XP Reward:\*\* //' | sed 's/ .*//' || echo "10")
    
    # Update task file
    local tmp_file=$(mktemp)
    sed 's/Status: 🟡 In Progress/Status: ✅ Completed/' "$TASK" > "$tmp_file"
    sed -i.bak "s/\\*\\*Completed:\\*\\* \\[Date\\]/\\*\\*Completed:\\*\\* $(date '+%Y-%m-%d')/" "$tmp_file"
    mv "$tmp_file" "$TASK"
    rm -f "${tmp_file}.bak"
    
    # Update agent assignment file
    local agent_clean
    agent_clean=$(get_agent_clean "$AGENT")
    local agent_file="${SPRINT_DIR}/agent-assignments/${agent_clean}.md"
    
    if [[ -f "$agent_file" ]]; then
        local task_name
        task_name=$(grep "^# " "$TASK" | head -1 | sed 's/^# //')
        
        # Mark task complete in agent file
        sed -i.bak "s/- \[ \] $task_name/- [x] $task_name/" "$agent_file"
        rm -f "${agent_file}.bak"
    fi
    
    # Award XP
    action_xp_award_internal "$AGENT" "$task_xp" "Task completed: $(basename "$TASK" .md)"
    
    # Create event
    local events_dir="${PROJECT_ROOT}/events"
    mkdir -p "$events_dir"
    
    cat > "${events_dir}/task-completed-$(date +%s).json" << EOF
{
    "event_type": "task_completed",
    "agent": "$AGENT",
    "task_file": "$TASK",
    "xp_awarded": $task_xp,
    "sprint_id": "$SPRINT_ID",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    success "Task marked complete!"
    info "Awarded $task_xp XP to $AGENT"
}

# ============================================
# ACTION: XP-AWARD
# ============================================

action_xp_award() {
    if [[ -z "$AGENT" || "$XP_AMOUNT" -eq 0 ]]; then
        error "Agent and XP amount required for xp-award action"
        exit 1
    fi
    
    ensure_sprint_dir
    load_sprint_data
    
    action_xp_award_internal "$AGENT" "$XP_AMOUNT" "${REASON:-XP Award}"
}

action_xp_award_internal() {
    local agent="$1"
    local xp="$2"
    local reason="$3"
    
    local agent_clean
    agent_clean=$(get_agent_clean "$agent")
    
    local xp_dir="${PROJECT_ROOT}/xp-awards"
    mkdir -p "$xp_dir"
    
    local xp_file="${xp_dir}/$(date +%s)-${agent_clean}.json"
    
    cat > "$xp_file" << EOF
{
    "agent": "$agent",
    "xp_amount": $xp,
    "reason": "$reason",
    "sprint_id": "$SPRINT_ID",
    "sprint_level": $SPRINT_LEVEL,
    "awarded_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    success "Awarded $xp XP to $agent"
    
    # Check for level up
    action_level_check_internal "$agent"
}

# ============================================
# ACTION: LEVEL-CHECK
# ============================================

action_level_check() {
    if [[ -z "$AGENT" ]]; then
        error "Agent required for level-check action"
        exit 1
    fi
    
    action_level_check_internal "$AGENT"
}

action_level_check_internal() {
    local agent="$1"
    
    # Calculate total XP from awards
    local agent_clean
    agent_clean=$(get_agent_clean "$agent")
    
    local total_xp=0
    local xp_dir="${PROJECT_ROOT}/xp-awards"
    
    if [[ -d "$xp_dir" ]]; then
        for xp_file in "$xp_dir"/*-${agent_clean}.json; do
            [[ -f "$xp_file" ]] || continue
            local xp
            xp=$(jq -r '.xp_amount' "$xp_file")
            total_xp=$((total_xp + xp))
        done
    fi
    
    # Calculate level (formula: sqrt(xp / 100) + 1)
    local new_level
    new_level=$(echo "scale=0; sqrt($total_xp / 100) + 1" | bc -l)
    
    info "$agent has $total_xp XP (Level $new_level)"
    
    # Check if this is a new level
    # (In a real implementation, we'd track current level and compare)
    if [[ "$new_level" -gt 1 ]]; then
        success "$agent is at Level $new_level!"
    fi
}

# ============================================
# ACTION: STATUS
# ============================================

action_status() {
    ensure_sprint_dir
    load_sprint_data
    
    echo
    info "═══════════════════════════════════════════════════════════"
    info "  AGENT STATUS - Level $SPRINT_LEVEL: $SPRINT_NAME"
    info "═══════════════════════════════════════════════════════════"
    echo
    
    local agents_dir="${SPRINT_DIR}/agent-assignments"
    
    if [[ ! -d "$agents_dir" ]]; then
        warn "No agent assignments found"
        return
    fi
    
    for agent_file in "$agents_dir"/*.md; do
        [[ -f "$agent_file" ]] || continue
        
        local agent_name
        agent_name=$(basename "$agent_file" .md)
        
        local total_tasks
        total_tasks=$(grep -c "^\- \[" "$agent_file" 2>/dev/null || echo "0")
        
        local completed_tasks
        completed_tasks=$(grep -c "^\- \[x\]" "$agent_file" 2>/dev/null || echo "0")
        
        local percent=0
        [[ $total_tasks -gt 0 ]] && percent=$((completed_tasks * 100 / total_tasks))
        
        printf "  @%-15s %3d/%d tasks  [%3d%%]\n" "$agent_name" "$completed_tasks" "$total_tasks" "$percent"
    done
    
    echo
}

# ============================================
# MAIN
# ============================================

main() {
    parse_args "$@"
    
    if [[ -z "$ACTION" ]]; then
        error "Action required. Use --action <type>"
        show_help
        exit 1
    fi
    
    case "$ACTION" in
        notify)
            action_notify
            ;;
        assign)
            action_assign
            ;;
        complete)
            action_complete
            ;;
        xp-award)
            action_xp_award
            ;;
        level-check)
            action_level_check
            ;;
        status)
            action_status
            ;;
        *)
            error "Unknown action: $ACTION"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
