#!/bin/bash
# Level Up Automation Script
# Handles level progression, unlocks, and celebrations
# Usage: ./level-up.sh --level <N> [--auto-complete]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GOLD='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

LEVEL=""
AUTO_COMPLETE=false
FORCE=false

# Level definitions
LEVEL_NAMES=(
    ""
    "Initiate"
    "Apprentice"
    "Journeyman"
    "Specialist"
    "Expert"
    "Master"
    "Grandmaster"
    "Legend"
    "Mythic"
    "Transcendent"
)

LEVEL_DESCRIPTIONS=(
    ""
    "First steps into the system"
    "Building foundational skills"
    "Complex problem solving"
    "Domain expertise"
    "Leading sprints"
    "Architecting solutions"
    "System-wide impact"
    "Transformative achievements"
    "Beyond conventional limits"
    "The pinnacle"
)

# ============================================
# LOGGING
# ============================================

log() { echo -e "${BLUE}[LEVEL-UP]${NC} $1"; }
success() { echo -e "${GREEN}[LEVEL-UP]${NC} $1"; }
warn() { echo -e "${YELLOW}[LEVEL-UP]${NC} $1"; }
error() { echo -e "${RED}[LEVEL-UP]${NC} $1"; }
info() { echo -e "${CYAN}[LEVEL-UP]${NC} $1"; }
celebrate() { echo -e "${GOLD}${BOLD}$1${NC}"; }

# ============================================
# HELP
# ============================================

show_help() {
    cat << EOF
${BOLD}Level Up Automation Script${NC}

Usage: $(basename "$0") [OPTIONS]

Required:
  -l, --level <N>          Level number to unlock (1-10)

Optional:
  --auto-complete          Automatically mark prerequisite sprints complete
  -f, --force              Force unlock even if requirements not met
  -h, --help               Show this help

Examples:
  $(basename "$0") -l 2                    # Unlock Level 2
  $(basename "$0") -l 5 --auto-complete    # Unlock Level 5 with auto-complete

EOF
}

# ============================================
# ARGUMENT PARSING
# ============================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -l|--level)
                LEVEL="$2"
                shift 2
                ;;
            --auto-complete)
                AUTO_COMPLETE=true
                shift
                ;;
            -f|--force)
                FORCE=true
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
# VALIDATION
# ============================================

validate() {
    if [[ -z "$LEVEL" ]]; then
        error "Level is required. Use -l or --level"
        exit 1
    fi
    
    if ! [[ "$LEVEL" =~ ^[0-9]+$ ]]; then
        error "Level must be a number"
        exit 1
    fi
    
    if [[ "$LEVEL" -lt 1 || "$LEVEL" -gt 10 ]]; then
        error "Level must be between 1 and 10"
        exit 1
    fi
    
    # Check if previous level is complete
    if [[ "$LEVEL" -gt 1 && "$FORCE" != "true" ]]; then
        local prev_level=$((LEVEL - 1))
        local prev_complete=false
        
        # Check for completed sprint at previous level
        if [[ -d "${PROJECT_ROOT}/sprints" ]]; then
            for sprint in "${PROJECT_ROOT}/sprints"/*/; do
                if [[ -f "${sprint}/sprint.json" ]]; then
                    local s_level s_status
                    s_level=$(jq -r '.level' "${sprint}/sprint.json" 2>/dev/null || echo "0")
                    s_status=$(jq -r '.status' "${sprint}/sprint.json" 2>/dev/null || echo "unknown")
                    
                    if [[ "$s_level" == "$prev_level" && "$s_status" == "completed" ]]; then
                        prev_complete=true
                        break
                    fi
                fi
            done
        fi
        
        if [[ "$prev_complete" != "true" ]]; then
            error "Level $prev_level must be completed before unlocking Level $LEVEL"
            info "Use --force to override (not recommended)"
            exit 1
        fi
    fi
}

# ============================================
# LEVEL OPERATIONS
# ============================================

unlock_level() {
    local level="$1"
    local level_name="${LEVEL_NAMES[$level]}"
    local level_desc="${LEVEL_DESCRIPTIONS[$level]}"
    
    log "Unlocking Level $level: $level_name"
    
    # Create level unlock event
    local events_dir="${PROJECT_ROOT}/events"
    mkdir -p "$events_dir"
    
    cat > "${events_dir}/level-unlock-$(date +%s).json" << EOF
{
    "event_type": "level_unlocked",
    "level": $level,
    "level_name": "$level_name",
    "description": "$level_desc",
    "unlocked_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "unlocked_by": "${USER:-system}"
}
EOF
    
    # Create level directory structure
    local level_dir="${PROJECT_ROOT}/levels/level-${level}"
    mkdir -p "$level_dir"/{sprints,challenges,achievements}
    
    # Create level info file
    cat > "${level_dir}/level-info.json" << EOF
{
    "number": $level,
    "name": "$level_name",
    "description": "$level_desc",
    "status": "unlocked",
    "unlocked_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "required_xp": $(( (level - 1) * 100 + (level - 1) * (level - 1) * 50 )),
    "max_sprints": $(( 2 + level )),
    "difficulty": $(if [[ $level -le 3 ]]; then echo '"easy"'; elif [[ $level -le 6 ]]; then echo '"medium"'; elif [[ $level -le 8 ]]; then echo '"hard"'; else echo '"expert"'; fi),
    "perks": $(get_level_perks "$level")
}
EOF
    
    success "Level $level unlocked!"
}

get_level_perks() {
    local level="$1"
    case "$level" in
        1) echo '["basic_access"]' ;;
        2) echo '["basic_access", "task_creation", "self_assignment"]' ;;
        3) echo '["basic_access", "task_creation", "self_assignment", "code_review"]' ;;
        4) echo '["basic_access", "task_creation", "self_assignment", "code_review", "mentoring"]' ;;
        5) echo '["basic_access", "task_creation", "self_assignment", "code_review", "mentoring", "sprint_lead"]' ;;
        6) echo '["basic_access", "task_creation", "self_assignment", "code_review", "mentoring", "sprint_lead", "task_delegation"]' ;;
        7) echo '["basic_access", "task_creation", "self_assignment", "code_review", "mentoring", "sprint_lead", "task_delegation", "cross_team_coordination"]' ;;
        8) echo '["basic_access", "task_creation", "self_assignment", "code_review", "mentoring", "sprint_lead", "task_delegation", "cross_team_coordination", "strategic_planning"]' ;;
        9) echo '["basic_access", "task_creation", "self_assignment", "code_review", "mentoring", "sprint_lead", "task_delegation", "cross_team_coordination", "strategic_planning", "system_ownership"]' ;;
        10) echo '["basic_access", "task_creation", "self_assignment", "code_review", "mentoring", "sprint_lead", "task_delegation", "cross_team_coordination", "strategic_planning", "system_ownership", "full_autonomy", "legend_status"]' ;;
    esac
}

create_welcome_sprint() {
    local level="$1"
    local level_name="${LEVEL_NAMES[$level]}"
    
    log "Creating welcome sprint for Level $level..."
    
    # Use init-sprint.sh to create the sprint
    local sprint_name="Level $level: $level_name - Welcome"
    
    "${SCRIPT_DIR}/init-sprint.sh" \
        --level "$level" \
        --name "$sprint_name" \
        --template default \
        --agents "@coordinator,@architect" || true
    
    success "Welcome sprint created for Level $level"
}

notify_agents() {
    local level="$1"
    local level_name="${LEVEL_NAMES[$level]}"
    
    log "Notifying agents of level unlock..."
    
    local notif_dir="${PROJECT_ROOT}/notifications"
    mkdir -p "$notif_dir"
    
    # Create broadcast notification
    cat > "${notif_dir}/broadcast-level-${level}-$(date +%s).json" << EOF
{
    "type": "level_unlock_broadcast",
    "level": $level,
    "level_name": "$level_name",
    "message": "🎉 Level $level ($level_name) is now unlocked! New challenges await!",
    "priority": "high",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
    
    success "Notifications sent"
}

# ============================================
# VISUAL EFFECTS
# ============================================

print_unlock_banner() {
    local level="$1"
    local level_name="${LEVEL_NAMES[$level]}"
    local level_desc="${LEVEL_DESCRIPTIONS[$level]}"
    
    echo
    celebrate "╔═══════════════════════════════════════════════════════════╗"
    celebrate "║                                                           ║"
    celebrate "║              🔓 LEVEL UNLOCKED! 🔓                        ║"
    celebrate "║                                                           ║"
    celebrate "╠═══════════════════════════════════════════════════════════╣"
    celebrate "║                                                           ║"
    celebrate "║              Level $level: $level_name"
    celebrate "║                                                           ║"
    celebrate "║     $level_desc"
    celebrate "║                                                           ║"
    
    if [[ "$level" -eq 10 ]]; then
        celebrate "║                                                           ║"
        celebrate "║              🏆 MAXIMUM LEVEL REACHED! 🏆                 ║"
        celebrate "║                                                           ║"
    fi
    
    celebrate "╚═══════════════════════════════════════════════════════════╝"
    echo
}

print_level_perks() {
    local level="$1"
    
    info "Level $level Perks:"
    
    case "$level" in
        1)
            echo "  ✓ Basic system access"
            echo "  ✓ Join sprints"
            echo "  ✓ Complete assigned tasks"
            ;;
        2)
            echo "  ✓ Create new tasks"
            echo "  ✓ Self-assign tasks"
            ;;
        3)
            echo "  ✓ Review code submissions"
            echo "  ✓ Mentor Level 1 agents"
            ;;
        4)
            echo "  ✓ Input on architecture decisions"
            echo "  ✓ Make technical recommendations"
            ;;
        5)
            echo "  ✓ Lead sprints"
            echo "  ✓ Delegate tasks to other agents"
            ;;
        6)
            echo "  ✓ Full leadership capabilities"
            echo "  ✓ Propose process changes"
            ;;
        7)
            echo "  ✓ Coordinate across teams"
            echo "  ✓ Strategic planning input"
            ;;
        8)
            echo "  ✓ Strategic decision making"
            echo "  ✓ System-wide impact"
            ;;
        9)
            echo "  ✓ System ownership"
            echo "  ✓ Architectural authority"
            ;;
        10)
            echo "  ✓ Full autonomy"
            echo "  ✓ Legend status"
            echo "  ✓ Unlimited capabilities"
            ;;
    esac
    echo
}

# ============================================
# MAIN
# ============================================

main() {
    parse_args "$@"
    validate
    
    log "Initializing Level Up sequence..."
    echo
    
    unlock_level "$LEVEL"
    
    if [[ "$AUTO_COMPLETE" == "true" ]]; then
        create_welcome_sprint "$LEVEL"
    fi
    
    notify_agents "$LEVEL"
    
    print_unlock_banner "$LEVEL"
    print_level_perks "$LEVEL"
    
    info "Next steps:"
    echo "  1. Create a sprint: ./init-sprint.sh --level $LEVEL --name \"Sprint Name\""
    echo "  2. Check level info: cat levels/level-${LEVEL}/level-info.json"
    echo "  3. View all levels:  ls -la levels/"
    echo
}

main "$@"
