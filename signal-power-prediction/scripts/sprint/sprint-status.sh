#!/bin/bash
# Sprint Status Monitor
# Real-time view of sprint progress and agent performance
# Usage: ./sprint-status.sh [--sprint-dir <path>] [--watch]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

SPRINT_DIR=""
WATCH_MODE=false
WATCH_INTERVAL=5
SHOW_ALL=false

# ============================================
# LOGGING
# ============================================

log() { echo -e "${BLUE}$1${NC}"; }
success() { echo -e "${GREEN}$1${NC}"; }
warn() { echo -e "${YELLOW}$1${NC}"; }
error() { echo -e "${RED}$1${NC}"; }
info() { echo -e "${CYAN}$1${NC}"; }
header() { echo -e "${BOLD}${MAGENTA}$1${NC}"; }
dim() { echo -e "${GRAY}$1${NC}"; }

# ============================================
# HELP
# ============================================

show_help() {
    cat << EOF
${BOLD}Sprint Status Monitor${NC}

Usage: $(basename "$0") [OPTIONS]

Optional:
  -d, --sprint-dir <path>  Specific sprint to monitor
  -w, --watch              Watch mode (auto-refresh)
  -i, --interval <sec>     Refresh interval (default: 5s)
  -a, --all                Show all sprints
  -h, --help               Show this help

Examples:
  $(basename "$0")                    # Show active sprint status
  $(basename "$0") -w                 # Watch mode
  $(basename "$0") -d ../sprints/...  # Specific sprint
  $(basename "$0") -a                 # All sprints overview

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
            -w|--watch)
                WATCH_MODE=true
                shift
                ;;
            -i|--interval)
                WATCH_INTERVAL="$2"
                shift 2
                ;;
            -a|--all)
                SHOW_ALL=true
                shift
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
# STATUS DISPLAY
# ============================================

get_status_emoji() {
    case "$1" in
        planning) echo "🟡" ;;
        active) echo "🟢" ;;
        review) echo "🔵" ;;
        completed) echo "✅" ;;
        failed) echo "❌" ;;
        *) echo "⚪" ;;
    esac
}

get_priority_emoji() {
    case "$1" in
        critical) echo "🔴" ;;
        high) echo "🟠" ;;
        medium) echo "🟡" ;;
        low) echo "🟢" ;;
        *) echo "⚪" ;;
    esac
}

render_progress_bar() {
    local percent=$1
    local width=20
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    
    printf "%s %3d%%" "$bar" "$percent"
}

# ============================================
# SPRINT STATUS
# ============================================

find_active_sprint() {
    if [[ -f "${PROJECT_ROOT}/.active-sprint" ]]; then
        cat "${PROJECT_ROOT}/.active-sprint"
        return
    fi
    
    # Find most recent active sprint
    local sprints_dir="${PROJECT_ROOT}/sprints"
    if [[ -d "$sprints_dir" ]]; then
        for sprint in "$sprints_dir"/*/; do
            if [[ -f "${sprint}/sprint.json" ]]; then
                local status
                status=$(jq -r '.status' "${sprint}/sprint.json" 2>/dev/null || echo "unknown")
                if [[ "$status" == "active" ]]; then
                    echo "$sprint"
                    return
                fi
            fi
        done
    fi
}

show_sprint_header() {
    local sprint_file="$1"
    local level name status started total_xp
    
    level=$(jq -r '.level' "$sprint_file")
    name=$(jq -r '.name' "$sprint_file")
    status=$(jq -r '.status' "$sprint_file")
    started=$(jq -r '.started_at // "Not started"' "$sprint_file")
    total_xp=$(jq -r '.base_xp + .bonus_xp' "$sprint_file")
    
    local status_emoji
    status_emoji=$(get_status_emoji "$status")
    
    header "╔═══════════════════════════════════════════════════════════╗"
    header "║  🎮 LEVEL $level SPRINT                                    "
    header "║  $name"
    header "║  Status: $status_emoji ${status^^}"
    header "╚═══════════════════════════════════════════════════════════╝"
    echo
    info "Started: $started"
    info "XP Pool: $total_xp"
    echo
}

show_task_summary() {
    local sprint_dir="$1"
    local tasks_dir="${sprint_dir}/tasks"
    
    if [[ ! -d "$tasks_dir" ]]; then
        warn "No tasks directory found"
        return
    fi
    
    header "📋 TASK SUMMARY"
    echo
    
    local total=0 pending=0 active=0 completed=0
    
    for task_file in "$tasks_dir"/*.md; do
        [[ -f "$task_file" ]] || continue
        total=$((total + 1))
        
        local content
        content=$(cat "$task_file")
        
        if echo "$content" | grep -q "Status.*✅\|Status:.*Completed"; then
            completed=$((completed + 1))
        elif echo "$content" | grep -q "Status.*🟡\|Status:.*In Progress"; then
            active=$((active + 1))
        else
            pending=$((pending + 1))
        fi
    done
    
    local percent=0
    [[ $total -gt 0 ]] && percent=$((completed * 100 / total))
    
    printf "  Total:     %s%d%s\n" "$BOLD" "$total" "$NC"
    printf "  Pending:   %s%d%s\n" "$YELLOW" "$pending" "$NC"
    printf "  Active:    %s%d%s\n" "$BLUE" "$active" "$NC"
    printf "  Completed: %s%d%s\n" "$GREEN" "$completed" "$NC"
    echo
    printf "  Progress:  %s\n" "$(render_progress_bar $percent)"
    echo
}

show_agent_status() {
    local sprint_dir="$1"
    local agents_dir="${sprint_dir}/agent-assignments"
    
    header "👥 AGENT STATUS"
    echo
    
    if [[ ! -d "$agents_dir" ]]; then
        dim "  No agent assignments found"
        echo
        return
    fi
    
    for agent_file in "$agents_dir"/*.md; do
        [[ -f "$agent_file" ]] || continue
        
        local agent_name
        agent_name=$(basename "$agent_file" .md)
        
        local total assigned completed
        total=$(grep -c "^\- \[" "$agent_file" 2>/dev/null || echo "0")
        completed=$(grep -c "^\- \[x\]" "$agent_file" 2>/dev/null || echo "0")
        assigned=$((total))
        
        local percent=0
        [[ $assigned -gt 0 ]] && percent=$((completed * 100 / assigned))
        
        printf "  @%-15s %3d/%d tasks  %s\n" "$agent_name" "$completed" "$assigned" "$(render_progress_bar $percent)"
    done
    echo
}

show_task_details() {
    local sprint_dir="$1"
    local tasks_dir="${sprint_dir}/tasks"
    
    header "📋 TASK DETAILS"
    echo
    
    if [[ ! -d "$tasks_dir" ]]; then
        dim "  No tasks found"
        return
    fi
    
    printf "  %-4s %-30s %-12s %-10s %s\n" "#" "Task" "Type" "Priority" "Status"
    dim "  ─────────────────────────────────────────────────────────────────"
    
    local idx=1
    for task_file in "$tasks_dir"/*.md; do
        [[ -f "$task_file" ]] || continue
        
        local title type priority status status_emoji
        title=$(grep "^# " "$task_file" | head -1 | sed 's/^# //' | cut -c1-28)
        type=$(grep "Type:" "$task_file" | head -1 | sed 's/.*Type: \*\*//' | sed 's/\*\*.*//' | cut -c1-10)
        priority=$(grep "Priority:" "$task_file" | head -1 | sed 's/.*Priority: \*\*//' | sed 's/\*\*.*//' | cut -c1-8)
        
        if grep -q "Status.*✅\|Status:.*Completed" "$task_file" 2>/dev/null; then
            status="Done"
            status_emoji="✅"
        elif grep -q "Status.*🟡\|Status:.*In Progress" "$task_file" 2>/dev/null; then
            status="Active"
            status_emoji="🟡"
        else
            status="Pending"
            status_emoji="🔴"
        fi
        
        local priority_emoji
        priority_emoji=$(get_priority_emoji "$priority")
        
        printf "  %-4d %-30s %-12s %s %-6s %s %s\n" "$idx" "$title" "$type" "$priority_emoji" "$priority" "$status_emoji" "$status"
        idx=$((idx + 1))
    done
    echo
}

show_all_sprints() {
    local sprints_dir="${PROJECT_ROOT}/sprints"
    
    header "📊 ALL SPRINTS OVERVIEW"
    echo
    
    if [[ ! -d "$sprints_dir" ]]; then
        warn "No sprints directory found"
        return
    fi
    
    printf "  %-8s %-25s %-12s %-10s %s\n" "Level" "Name" "Status" "Progress" "XP"
    dim "  ──────────────────────────────────────────────────────────────────────────"
    
    for sprint in "$sprints_dir"/*/; do
        [[ -d "$sprint" ]] || continue
        
        local sprint_file="${sprint}/sprint.json"
        [[ -f "$sprint_file" ]] || continue
        
        local level name status total_xp
        level=$(jq -r '.level' "$sprint_file")
        name=$(jq -r '.name' "$sprint_file" | cut -c1-23)
        status=$(jq -r '.status' "$sprint_file")
        total_xp=$(jq -r '.base_xp + .bonus_xp' "$sprint_file")
        
        local status_emoji
        status_emoji=$(get_status_emoji "$status")
        
        # Calculate progress
        local tasks_dir="${sprint}/tasks"
        local total=0 completed=0 percent=0
        if [[ -d "$tasks_dir" ]]; then
            for task_file in "$tasks_dir"/*.md; do
                [[ -f "$task_file" ]] || continue
                total=$((total + 1))
                if grep -q "Status.*✅\|Status:.*Completed" "$task_file" 2>/dev/null; then
                    completed=$((completed + 1))
                fi
            done
            [[ $total -gt 0 ]] && percent=$((completed * 100 / total))
        fi
        
        printf "  L%-7d %-25s %s %-10s %3d%%       %d\n" "$level" "$name" "$status_emoji" "$status" "$percent" "$total_xp"
    done
    echo
}

show_system_status() {
    header "🔧 SYSTEM STATUS"
    echo
    
    # Check for active sprint
    local active_sprint
    active_sprint=$(find_active_sprint)
    
    if [[ -n "$active_sprint" ]]; then
        success "  ● Active sprint detected"
        info "    Location: $(basename "$active_sprint")"
    else
        warn "  ○ No active sprint"
    fi
    
    # Count total sprints
    local sprints_dir="${PROJECT_ROOT}/sprints"
    local sprint_count=0
    if [[ -d "$sprints_dir" ]]; then
        sprint_count=$(find "$sprints_dir" -name "sprint.json" | wc -l)
    fi
    info "  Total sprints: $sprint_count"
    
    # Check notifications
    local notif_count=0
    if [[ -d "${PROJECT_ROOT}/notifications" ]]; then
        notif_count=$(find "${PROJECT_ROOT}/notifications" -name "*.json" 2>/dev/null | wc -l)
    fi
    if [[ $notif_count -gt 0 ]]; then
        warn "  Pending notifications: $notif_count"
    else
        success "  No pending notifications"
    fi
    
    echo
}

# ============================================
# MAIN DISPLAY
# ============================================

clear_screen() {
    printf '\033[2J\033[H'
}

show_status() {
    if [[ "$SHOW_ALL" == "true" ]]; then
        show_all_sprints
        show_system_status
        return
    fi
    
    local sprint_dir="${SPRINT_DIR:-$(find_active_sprint)}"
    
    if [[ -z "$sprint_dir" || ! -d "$sprint_dir" ]]; then
        error "No active sprint found!"
        echo
        info "To create a sprint:"
        echo "  ./init-sprint.sh --level <N> --name \"Sprint Name\""
        echo
        return
    fi
    
    local sprint_file="${sprint_dir}/sprint.json"
    
    if [[ ! -f "$sprint_file" ]]; then
        error "Invalid sprint directory: $sprint_dir"
        return
    fi
    
    show_sprint_header "$sprint_file"
    show_task_summary "$sprint_dir"
    show_agent_status "$sprint_dir"
    show_task_details "$sprint_dir"
    
    dim "Last updated: $(date '+%H:%M:%S')"
    
    if [[ "$WATCH_MODE" == "true" ]]; then
        echo
        dim "Press Ctrl+C to exit watch mode"
    fi
}

# ============================================
# MAIN
# ============================================

main() {
    parse_args "$@"
    
    if [[ "$WATCH_MODE" == "true" ]]; then
        while true; do
            clear_screen
            show_status
            sleep "$WATCH_INTERVAL"
        done
    else
        show_status
    fi
}

trap 'echo; exit 0' INT

main "$@"
