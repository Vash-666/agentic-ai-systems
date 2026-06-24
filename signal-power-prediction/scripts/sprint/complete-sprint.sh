#!/bin/bash
# Sprint Completion Script
# Finalizes a sprint, awards XP, and unlocks next level
# Usage: ./complete-sprint.sh --sprint-dir <path> [--rating <1-5>]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GOLD='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

SPRINT_DIR=""
RATING=3
FORCE=false
SKIP_LEVEL_UNLOCK=false

# ============================================
# LOGGING
# ============================================

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
log_success() { echo -e "${GREEN}[$(date +'%H:%M:%S')] ✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠${NC} $1"; }
log_error() { echo -e "${RED}[$(date +'%H:%M:%S')] ✗${NC} $1"; }
log_info() { echo -e "${CYAN}[$(date +'%H:%M:%S')] ℹ${NC} $1"; }
announce() { echo -e "${MAGENTA}${BOLD}$1${NC}"; }
celebrate() { echo -e "${GOLD}${BOLD}$1${NC}"; }

# ============================================
# HELP
# ============================================

show_help() {
    cat << EOF
${BOLD}Sprint Completion Script${NC}

Usage: $(basename "$0") [OPTIONS]

Required:
  -d, --sprint-dir <path>  Path to sprint directory

Optional:
  -r, --rating <1-5>       Sprint performance rating (default: 3)
  -f, --force              Force complete even if tasks pending
  --skip-level-unlock      Don't unlock next level
  -h, --help               Show this help

Examples:
  $(basename "$0") -d ../sprints/level-1-foundation-setup
  $(basename "$0") -d ../sprints/level-3-api-development -r 5

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
            -r|--rating)
                RATING="$2"
                shift 2
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            --skip-level-unlock)
                SKIP_LEVEL_UNLOCK=true
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
        log_error "Sprint directory is required"
        exit 1
    fi
    
    if [[ ! -f "${SPRINT_DIR}/sprint.json" ]]; then
        log_error "Invalid sprint directory: $SPRINT_DIR"
        exit 1
    fi
}

# ============================================
# DATA LOADING
# ============================================

load_sprint_data() {
    local sprint_file="${SPRINT_DIR}/sprint.json"
    SPRINT_ID=$(jq -r '.id' "$sprint_file")
    SPRINT_LEVEL=$(jq -r '.level' "$sprint_file")
    SPRINT_NAME=$(jq -r '.name' "$sprint_file")
    SPRINT_STATUS=$(jq -r '.status' "$sprint_file")
    SPRINT_BASE_XP=$(jq -r '.base_xp' "$sprint_file")
    SPRINT_BONUS_XP=$(jq -r '.bonus_xp' "$sprint_file")
    SPRINT_AGENTS=$(jq -r '.agents | join(",")' "$sprint_file")
    
    log_info "Loaded sprint: $SPRINT_NAME (Level $SPRINT_LEVEL)"
}

check_completion_criteria() {
    local tasks_dir="${SPRINT_DIR}/tasks"
    local pending_tasks=0
    local completed_tasks=0
    local total_tasks=0
    
    if [[ -d "$tasks_dir" ]]; then
        for task_file in "$tasks_dir"/*.md; do
            if [[ -f "$task_file" ]]; then
                total_tasks=$((total_tasks + 1))
                if grep -q "Status.*✅ Completed" "$task_file" 2>/dev/null || \
                   grep -q "Status:.*Completed" "$task_file" 2>/dev/null; then
                    completed_tasks=$((completed_tasks + 1))
                else
                    pending_tasks=$((pending_tasks + 1))
                fi
            fi
        done
    fi
    
    TASKS_TOTAL=$total_tasks
    TASKS_COMPLETED=$completed_tasks
    TASKS_PENDING=$pending_tasks
    
    log_info "Task completion: $completed_tasks/$total_tasks"
    
    if [[ $pending_tasks -gt 0 && "$FORCE" != "true" ]]; then
        log_warn "$pending_tasks task(s) not marked complete!"
        read -p "Complete sprint anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# ============================================
# XP CALCULATION
# ============================================

calculate_xp() {
    local base=$SPRINT_BASE_XP
    local bonus=$SPRINT_BONUS_XP
    local rating_multiplier=1.0
    
    case $RATING in
        1) rating_multiplier=0.5 ;;
        2) rating_multiplier=0.75 ;;
        3) rating_multiplier=1.0 ;;
        4) rating_multiplier=1.25 ;;
        5) rating_multiplier=1.5 ;;
    esac
    
    # Task completion bonus
    local completion_rate=0
    if [[ $TASKS_TOTAL -gt 0 ]]; then
        completion_rate=$((TASKS_COMPLETED * 100 / TASKS_TOTAL))
    fi
    
    local completion_bonus=0
    if [[ $completion_rate -eq 100 ]]; then
        completion_bonus=$((bonus / 2))  # 50% bonus for 100% completion
    fi
    
    TOTAL_XP=$(echo "($base + $bonus + $completion_bonus) * $rating_multiplier" | bc | cut -d. -f1)
    COMPLETION_BONUS=$completion_bonus
    
    log_info "XP Calculation:"
    log_info "  Base XP: $base"
    log_info "  Sprint Bonus: $bonus"
    log_info "  Completion Bonus: $completion_bonus"
    log_info "  Rating Multiplier: ${rating_multiplier}x"
    log_info "  TOTAL: $TOTAL_XP"
}

# ============================================
# COMPLETION OPERATIONS
# ============================================

finalize_sprint() {
    log "Finalizing sprint..."
    
    local tmp_file=$(mktemp)
    jq --arg status "completed" \
       --arg completed_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       --arg rating "$RATING" \
       --argjson total_xp "$TOTAL_XP" \
       '.status = $status | .completed_at = $completed_at | .rating = ($rating | tonumber) | .total_xp_awarded = $total_xp' \
       "${SPRINT_DIR}/sprint.json" > "$tmp_file"
    mv "$tmp_file" "${SPRINT_DIR}/sprint.json"
    
    # Update README
    local readme_file="${SPRINT_DIR}/README.md"
    if [[ -f "$readme_file" ]]; then
        sed -i.bak 's/🟢 Active/✅ Completed/' "$readme_file"
        sed -i.bak "s/\\*\\*Status:\\*\\* .*/\\*\\*Status:\\*\\* ✅ Completed (Rating: $RATING\\/5)/" "$readme_file"
        sed -i.bak "s/\\[████████░░░░░░░░░░░░\\] 0%/\\[████████████████████\\] 100%/" "$readme_file"
        rm -f "${readme_file}.bak"
    fi
    
    # Clear active sprint marker
    if [[ -f "${PROJECT_ROOT}/.active-sprint" ]]; then
        rm -f "${PROJECT_ROOT}/.active-sprint"
    fi
    
    log_success "Sprint marked as completed"
}

award_xp() {
    log "Awarding XP to agents..."
    
    IFS=',' read -ra AGENT_LIST <<< "$SPRINT_AGENTS"
    local agent_count=${#AGENT_LIST[@]}
    
    if [[ $agent_count -eq 0 ]]; then
        log_warn "No agents to award XP to"
        return
    fi
    
    local xp_per_agent=$((TOTAL_XP / agent_count))
    
    for agent in "${AGENT_LIST[@]}"; do
        local agent_clean=$(echo "$agent" | tr -d '@' | tr '[:upper:]' '[:lower:]')
        
        # Create XP award record
        local xp_file="${PROJECT_ROOT}/xp-awards/$(date +%s)-${agent_clean}.json"
        mkdir -p "${PROJECT_ROOT}/xp-awards"
        
        cat > "$xp_file" << EOF
{
    "agent": "$agent",
    "sprint_id": "$SPRINT_ID",
    "sprint_level": $SPRINT_LEVEL,
    "sprint_name": "$SPRINT_NAME",
    "xp_amount": $xp_per_agent,
    "awarded_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "reason": "Sprint completion: $SPRINT_NAME"
}
EOF
        
        log_success "Awarded $xp_per_agent XP to $agent"
    done
}

unlock_next_level() {
    if [[ "$SKIP_LEVEL_UNLOCK" == "true" ]]; then
        log_info "Skipping level unlock (flag set)"
        return
    fi
    
    local next_level=$((SPRINT_LEVEL + 1))
    
    if [[ $next_level -gt 10 ]]; then
        celebrate "🏆 MAXIMUM LEVEL REACHED! 🏆"
        return
    fi
    
    log "Unlocking Level $next_level..."
    
    # Create level unlock event
    local events_dir="${PROJECT_ROOT}/events"
    mkdir -p "$events_dir"
    
    cat > "${events_dir}/level-unlock-$(date +%s).json" << EOF
{
    "event_type": "level_unlocked",
    "level": $next_level,
    "unlocked_by_sprint": "$SPRINT_ID",
    "unlocked_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    log_success "Level $next_level unlocked!"
}

generate_report() {
    log "Generating completion report..."
    
    local report_file="${SPRINT_DIR}/COMPLETION-REPORT.md"
    
    cat > "$report_file" << EOF
# Sprint Completion Report

## Overview

| Field | Value |
|-------|-------|
| **Sprint** | $SPRINT_NAME |
| **Level** | $SPRINT_LEVEL |
| **Status** | ✅ Completed |
| **Rating** | $RATING/5 |
| **Completed** | $(date '+%Y-%m-%d %H:%M') |

## Task Summary

- **Total Tasks:** $TASKS_TOTAL
- **Completed:** $TASKS_COMPLETED
- **Completion Rate:** $(( TASKS_TOTAL > 0 ? TASKS_COMPLETED * 100 / TASKS_TOTAL : 0 ))%

## XP Awards

| Agent | XP Awarded |
|-------|------------|
$(IFS=','; for agent in $SPRINT_AGENTS; do echo "| $agent | $((TOTAL_XP / $(echo "$SPRINT_AGENTS" | tr ',' '\n' | wc -l))) |"; done)

**Total XP Distributed:** $TOTAL_XP

## Deliverables

[Check off completed deliverables]

- [ ] All code committed
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] Deployment notes created

## Retrospective

### What Went Well

[Document successes]

### What Could Improve

[Document challenges]

### Lessons Learned

[Key takeaways]

## Next Steps

$(if [[ $SPRINT_LEVEL -lt 10 ]]; then echo "- Level $((SPRINT_LEVEL + 1)) is now unlocked!"; else echo "- 🏆 All levels completed!"; fi)

---
*Generated by Sprint Completion Script*
EOF
    
    log_success "Report saved to: $report_file"
}

print_victory_banner() {
    echo
    celebrate "╔═══════════════════════════════════════════════════════════╗"
    celebrate "║                                                           ║"
    celebrate "║              🎉 SPRINT COMPLETED! 🎉                      ║"
    celebrate "║                                                           ║"
    celebrate "╠═══════════════════════════════════════════════════════════╣"
    celebrate "║  Level $SPRINT_LEVEL: $SPRINT_NAME"
    celebrate "║  Rating: $(printf '%s' $(seq $RATING | sed 's/.*/★/') | sed 's/\(\\.\\)/\1 /g')"
    celebrate "║  XP Awarded: $TOTAL_XP"
    celebrate "║  Tasks: $TASKS_COMPLETED/$TASKS_TOTAL completed"
    if [[ $SPRINT_LEVEL -lt 10 ]]; then
        celebrate "║                                                           ║"
        celebrate "║  🚀 LEVEL $((SPRINT_LEVEL + 1)) UNLOCKED! 🚀"
    else
        celebrate "║                                                           ║"
        celebrate "║  🏆 ALL LEVELS COMPLETE - LEGEND STATUS! 🏆"
    fi
    celebrate "╚═══════════════════════════════════════════════════════════╝"
    echo
}

# ============================================
# MAIN
# ============================================

main() {
    parse_args "$@"
    validate_sprint
    load_sprint_data
    
    if [[ "$SPRINT_STATUS" == "completed" ]]; then
        log_warn "Sprint already completed!"
        exit 0
    fi
    
    check_completion_criteria
    calculate_xp
    
    echo
    read -p "Complete this sprint with rating $RATING/5? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        exit 0
    fi
    
    finalize_sprint
    award_xp
    unlock_next_level
    generate_report
    
    print_victory_banner
    
    log_info "Sprint complete! Check the report at: ${SPRINT_DIR}/COMPLETION-REPORT.md"
}

main "$@"
