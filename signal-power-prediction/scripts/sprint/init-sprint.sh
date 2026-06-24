#!/bin/bash
# Sprint Initialization Script
# Signal Power Prediction System - Level-Game Infrastructure
# Usage: ./init-sprint.sh --level <N> --name "Sprint Name" [--agents "@agent1,@agent2"]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Default values
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SPRINT_LEVEL=""
SPRINT_NAME=""
AGENTS=""
TEMPLATE="default"
DRY_RUN=false
VERBOSE=false

# Database connection (override with env vars)
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-signal_power}"
DB_USER="${DB_USER:-spp_user}"
DB_PASS="${DB_PASS:-}"

# ============================================
# UTILITY FUNCTIONS
# ============================================

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] ✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] ⚠${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ✗${NC} $1"
}

log_info() {
    echo -e "${CYAN}[$(date +'%H:%M:%S')] ℹ${NC} $1"
}

verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        log_info "$1"
    fi
}

# ============================================
# HELP
# ============================================

show_help() {
    cat << EOF
${BOLD}Sprint Initialization Script${NC}

Usage: $(basename "$0") [OPTIONS]

Required:
  -l, --level <N>          Sprint level number (1-10)
  -n, --name <name>        Sprint name

Optional:
  -a, --agents <list>      Comma-separated agent handles (e.g., "@architect,@builder")
  -t, --template <name>    Sprint template (default|architecture|feature|bugfix)
  -d, --dry-run            Show what would be created without creating
  -v, --verbose            Verbose output
  -h, --help               Show this help

Environment:
  DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS

Examples:
  $(basename "$0") -l 1 -n "Foundation Setup"
  $(basename "$0") -l 3 -n "API Development" -a "@architect,@builder,@tester"
  $(basename "$0") -l 5 -n "Performance Optimization" -t performance

EOF
}

# ============================================
# ARGUMENT PARSING
# ============================================

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -l|--level)
                SPRINT_LEVEL="$2"
                shift 2
                ;;
            -n|--name)
                SPRINT_NAME="$2"
                shift 2
                ;;
            -a|--agents)
                AGENTS="$2"
                shift 2
                ;;
            -t|--template)
                TEMPLATE="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
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
                show_help
                exit 1
                ;;
        esac
    done
}

# ============================================
# VALIDATION
# ============================================

validate_inputs() {
    local has_error=false
    
    if [[ -z "$SPRINT_LEVEL" ]]; then
        log_error "Level is required. Use -l or --level"
        has_error=true
    elif ! [[ "$SPRINT_LEVEL" =~ ^[0-9]+$ ]]; then
        log_error "Level must be a number"
        has_error=true
    elif [[ "$SPRINT_LEVEL" -lt 1 || "$SPRINT_LEVEL" -gt 10 ]]; then
        log_error "Level must be between 1 and 10"
        has_error=true
    fi
    
    if [[ -z "$SPRINT_NAME" ]]; then
        log_error "Sprint name is required. Use -n or --name"
        has_error=true
    fi
    
    if [[ "$has_error" == "true" ]]; then
        echo
        show_help
        exit 1
    fi
}

# ============================================
# DATABASE FUNCTIONS
# ============================================

db_query() {
    local query="$1"
    PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "$query" 2>/dev/null || echo ""
}

db_exec() {
    local query="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would execute: $query"
    else
        PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "$query" > /dev/null 2>&1
    fi
}

get_level_info() {
    local level_num="$1"
    db_query "SELECT level_name, description, status FROM levels WHERE level_number = $level_num;"
}

check_level_unlocked() {
    local level_num="$1"
    local status
    status=$(db_query "SELECT status FROM levels WHERE level_number = $level_num;" | xargs)
    if [[ "$status" != "unlocked" && "$status" != "completed" ]]; then
        return 1
    fi
    return 0
}

# ============================================
# TEMPLATE FUNCTIONS
# ============================================

get_template_tasks() {
    local template="$1"
    local level="$2"
    
    case "$template" in
        default)
            cat << EOF
[
    {"title": "Sprint Planning & Setup", "type": "planning", "priority": "high", "xp": 15},
    {"title": "Architecture Design", "type": "design", "priority": "high", "xp": 25},
    {"title": "Implementation", "type": "code", "priority": "critical", "xp": 40},
    {"title": "Code Review", "type": "review", "priority": "high", "xp": 15},
    {"title": "Testing & Validation", "type": "test", "priority": "high", "xp": 20},
    {"title": "Documentation", "type": "docs", "priority": "medium", "xp": 10},
    {"title": "Sprint Retrospective", "type": "review", "priority": "medium", "xp": 10}
]
EOF
            ;;
        architecture)
            cat << EOF
[
    {"title": "Requirements Analysis", "type": "analysis", "priority": "critical", "xp": 20},
    {"title": "System Architecture Design", "type": "design", "priority": "critical", "xp": 35},
    {"title": "Component Interface Design", "type": "design", "priority": "high", "xp": 25},
    {"title": "Technical Specification", "type": "docs", "priority": "high", "xp": 20},
    {"title": "Architecture Review", "type": "review", "priority": "critical", "xp": 20},
    {"title": "Proof of Concept", "type": "code", "priority": "medium", "xp": 25}
]
EOF
            ;;
        feature)
            cat << EOF
[
    {"title": "Feature Specification", "type": "planning", "priority": "high", "xp": 15},
    {"title": "UI/UX Design", "type": "design", "priority": "high", "xp": 20},
    {"title": "Backend Implementation", "type": "code", "priority": "critical", "xp": 35},
    {"title": "Frontend Implementation", "type": "code", "priority": "critical", "xp": 30},
    {"title": "Integration Testing", "type": "test", "priority": "high", "xp": 20},
    {"title": "User Acceptance Testing", "type": "test", "priority": "high", "xp": 15}
]
EOF
            ;;
        bugfix)
            cat << EOF
[
    {"title": "Bug Analysis & Reproduction", "type": "analysis", "priority": "critical", "xp": 15},
    {"title": "Root Cause Identification", "type": "analysis", "priority": "critical", "xp": 20},
    {"title": "Fix Implementation", "type": "code", "priority": "critical", "xp": 25},
    {"title": "Regression Testing", "type": "test", "priority": "high", "xp": 15},
    {"title": "Hotfix Deployment", "type": "deploy", "priority": "critical", "xp": 10}
]
EOF
            ;;
        performance)
            cat << EOF
[
    {"title": "Performance Baseline", "type": "analysis", "priority": "critical", "xp": 15},
    {"title": "Bottleneck Identification", "type": "analysis", "priority": "critical", "xp": 25},
    {"title": "Optimization Implementation", "type": "code", "priority": "critical", "xp": 40},
    {"title": "Benchmark Validation", "type": "test", "priority": "high", "xp": 20},
    {"title": "Performance Report", "type": "docs", "priority": "medium", "xp": 15}
]
EOF
            ;;
        *)
            get_template_tasks "default" "$level"
            ;;
    esac
}

get_success_criteria() {
    local level="$1"
    cat << EOF
{
    "all_tasks_completed": true,
    "code_review_passed": true,
    "tests_passing": true,
    "no_critical_bugs": true,
    "documentation_complete": true,
    "level_specific": "Meet level $level objectives"
}
EOF
}

get_deliverables() {
    local template="$1"
    
    case "$template" in
        architecture)
            echo '["architecture-diagram.svg", "api-spec.yaml", "tech-spec.md", "poc-code/"]'
            ;;
        feature)
            echo '["feature-implementation/", "tests/", "documentation.md", "changelog-entry.md"]'
            ;;
        bugfix)
            echo '["bugfix-patch.diff", "test-case.md", "root-cause-analysis.md"]'
            ;;
        performance)
            echo '["optimization-report.md", "benchmark-results.json", "performance-dashboard/"]'
            ;;
        *)
            echo '["code/", "tests/", "docs/", "deployment-notes.md"]'
            ;;
    esac
}

# ============================================
# SPRINT CREATION
# ============================================

create_sprint() {
    local level="$1"
    local name="$2"
    local template="$3"
    
    log "Creating sprint: ${BOLD}Level $level - $name${NC}"
    verbose "Template: $template"
    
    # Get level info
    local level_info
    level_info=$(get_level_info "$level")
    local level_name
    level_name=$(echo "$level_info" | cut -d'|' -f1 | xargs)
    
    # Check if level is unlocked
    if ! check_level_unlocked "$level"; then
        log_warn "Level $level is not yet unlocked!"
        log_info "Complete previous levels first or use --force to override"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Calculate XP
    local base_xp=$((100 + (level * 50)))
    local bonus_xp=$((level * 25))
    
    # Get template data
    local tasks_json
    tasks_json=$(get_template_tasks "$template" "$level")
    local success_criteria
    success_criteria=$(get_success_criteria "$level")
    local deliverables
    deliverables=$(get_deliverables "$template")
    
    # Generate sprint ID
    local sprint_id
    sprint_id=$(uuidgen 2>/dev/null || echo "$(date +%s)-$RANDOM")
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Sprint would be created with:"
        log_info "  - Level: $level ($level_name)"
        log_info "  - Name: $name"
        log_info "  - Base XP: $base_xp"
        log_info "  - Bonus XP: $bonus_xp"
        log_info "  - Tasks: $(echo "$tasks_json" | jq length)"
        return 0
    fi
    
    # Create sprint directory structure
    local sprint_dir="${PROJECT_ROOT}/sprints/level-${level}-$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    mkdir -p "$sprint_dir"/{tasks,docs,artifacts,code,tests}
    
    # Create sprint manifest
    cat > "${sprint_dir}/sprint.json" << EOF
{
    "id": "$sprint_id",
    "level": $level,
    "level_name": "$level_name",
    "name": "$name",
    "template": "$template",
    "status": "planning",
    "base_xp": $base_xp,
    "bonus_xp": $bonus_xp,
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "success_criteria": $success_criteria,
    "deliverables": $deliverables,
    "agents": [$(echo "$AGENTS" | tr ',' '\n' | while read -r agent; do
        echo "\"$agent\","
    done | sed '$s/,$//')],
    "tasks": $tasks_json
}
EOF
    
    # Create task files
    local task_count=0
    echo "$tasks_json" | jq -c '.[]' | while read -r task; do
        task_count=$((task_count + 1))
        local task_title
        task_title=$(echo "$task" | jq -r '.title')
        local task_type
        task_type=$(echo "$task" | jq -r '.type')
        local task_priority
        task_priority=$(echo "$task" | jq -r '.priority')
        local task_xp
        task_xp=$(echo "$task" | jq -r '.xp')
        
        local task_file="${sprint_dir}/tasks/$(printf "%02d" $task_count)-$(echo "$task_title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-').md"
        
        cat > "$task_file" << EOF
# $task_title

**Type:** $task_type  
**Priority:** $task_priority  
**XP Reward:** $task_xp  
**Status:** 🔴 Pending

## Description

[Describe the task here]

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Notes

[Additional notes, references, etc.]

---
**Assigned to:** [Agent Handle]  
**Started:** [Date]  
**Completed:** [Date]
EOF
    done
    
    # Create README
    cat > "${sprint_dir}/README.md" << EOF
# Level $level: $name

**Status:** 🟡 Planning  
**Template:** $template  
**Total XP Available:** $((base_xp + bonus_xp))

## Objective

[Primary sprint objective]

## Success Criteria

$(echo "$success_criteria" | jq -r 'keys[] | "- [ ] " + .')

## Deliverables

$(echo "$deliverables" | jq -r '.[] | "- " + .')

## Tasks

| # | Task | Type | Priority | Status | XP |
|---|------|------|----------|--------|-----|
$(echo "$tasks_json" | jq -r 'to_entries | .[] | "| \(.key + 1) | \(.value.title) | \(.value.type) | \(.value.priority) | 🔴 Pending | \(.value.xp) |"')

## Agents

$(if [[ -n "$AGENTS" ]]; then
    echo "$AGENTS" | tr ',' '\n' | while read -r agent; do
        echo "- $agent"
    done
else
    echo "*No agents assigned yet*"
fi)

## Timeline

- **Started:** [Date]
- **Target Completion:** [Date]

## Progress

\`\`\`
[████████░░░░░░░░░░░░] 0%
\`\`\`

---
*Generated by Sprint Initialization Script*
EOF
    
    log_success "Sprint directory created: $sprint_dir"
    
    # Output sprint info
    echo
    echo -e "${BOLD}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║${NC}           ${CYAN}🎮 SPRINT INITIALIZED${NC}                      ${BOLD}║${NC}"
    echo -e "${BOLD}╠════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}║${NC} Level:     ${YELLOW}$level${NC} - $level_name"
    echo -e "${BOLD}║${NC} Name:      ${GREEN}$name${NC}"
    echo -e "${BOLD}║${NC} Template:  $template"
    echo -e "${BOLD}║${NC} XP:        ${CYAN}$base_xp${NC} base + ${CYAN}$bonus_xp${NC} bonus"
    echo -e "${BOLD}║${NC} Tasks:     $(echo "$tasks_json" | jq length)"
    echo -e "${BOLD}║${NC} Location:  ${BLUE}$sprint_dir${NC}"
    echo -e "${BOLD}╚════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Next steps
    log_info "Next steps:"
    echo "  1. Review sprint manifest: ${sprint_dir}/sprint.json"
    echo "  2. Assign agents to tasks in the tasks/ directory"
    echo "  3. Start sprint with: ${SCRIPT_DIR}/start-sprint.sh --sprint-dir $sprint_dir"
    echo
}

# ============================================
# MAIN
# ============================================

main() {
    echo -e "${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║     🚀 SIGNAL POWER PREDICTION - SPRINT INITIALIZER       ║"
    echo "║              Level-Game Infrastructure v1.0               ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    parse_args "$@"
    validate_inputs
    create_sprint "$SPRINT_LEVEL" "$SPRINT_NAME" "$TEMPLATE"
}

main "$@"
