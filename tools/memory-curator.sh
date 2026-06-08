#!/bin/bash
#
# Memory Curator - Automated Weekly Memory Curation System
# Transforms raw daily logs into strategic long-term memory
#
# Usage: ./memory-curator.sh [options]
#   --dry-run       Preview changes without modifying files
#   --force         Skip confirmations
#   --date-range START END   Custom date range (YYYY-MM-DD format)
#   --help          Show this help message
#
# Cron: 0 17 * * 5 (Fridays at 5 PM)
#

set -euo pipefail

# Configuration
WORKSPACE_DIR="/Users/rohitvashist/.openclaw/workspace/content"
MEMORY_DIR="${WORKSPACE_DIR}/memory"
ARCHIVE_DIR="${MEMORY_DIR}/archive"
LOG_FILE="${MEMORY_DIR}/curation-log.md"
MEMORY_MD="${WORKSPACE_DIR}/MEMORY.md"

# Default: past 7 days
DAYS_BACK=7
DRY_RUN=false
FORCE=false
START_DATE=""
END_DATE=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Show help
show_help() {
    cat << EOF
Memory Curator - Automated Weekly Memory Curation System

Usage: $(basename "$0") [options]

Options:
    --dry-run              Preview changes without modifying files
    --force                Skip all confirmations
    --date-range START END Process custom date range (YYYY-MM-DD format)
    --help                 Show this help message

Examples:
    $(basename "$0")                          # Process last 7 days
    $(basename "$0") --dry-run                # Preview only
    $(basename "$0") --date-range 2026-04-01 2026-04-15  # Custom range

Cron Setup:
    0 17 * * 5 $(readlink -f "$0")  # Fridays at 5 PM

EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --date-range)
                if [[ -n "${2:-}" && -n "${3:-}" ]]; then
                    START_DATE="$2"
                    END_DATE="$3"
                    shift 3
                else
                    log_error "--date-range requires START and END dates (YYYY-MM-DD)"
                    exit 1
                fi
                ;;
            --help)
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

# Initialize directories
init_dirs() {
    if [[ "$DRY_RUN" == false ]]; then
        mkdir -p "$MEMORY_DIR" "$ARCHIVE_DIR"
    fi
}

# Calculate date range
calculate_date_range() {
    if [[ -n "$START_DATE" && -n "$END_DATE" ]]; then
        log_info "Using custom date range: $START_DATE to $END_DATE"
        return
    fi

    # Default: past 7 days
    END_DATE=$(date +%Y-%m-%d)
    START_DATE=$(date -v-${DAYS_BACK}d +%Y-%m-%d 2>/dev/null || date -d "$DAYS_BACK days ago" +%Y-%m-%d 2>/dev/null || echo "")

    if [[ -z "$START_DATE" ]]; then
        # Fallback for different date command syntax
        START_DATE=$(python3 -c "from datetime import datetime, timedelta; print((datetime.now() - timedelta(days=$DAYS_BACK)).strftime('%Y-%m-%d'))")
    fi

    log_info "Processing last $DAYS_BACK days: $START_DATE to $END_DATE"
}

# Generate list of dates to process
generate_date_list() {
    local dates=()
    local current="$START_DATE"
    local end_epoch start_epoch

    # Convert dates to epoch for comparison
    end_epoch=$(date -j -f "%Y-%m-%d" "$END_DATE" +%s 2>/dev/null || date -d "$END_DATE" +%s 2>/dev/null || python3 -c "import time; print(int(time.mktime(time.strptime('$END_DATE', '%Y-%m-%d'))))")

    while true; do
        # Check if we've passed the end date
        local current_epoch=$(date -j -f "%Y-%m-%d" "$current" +%s 2>/dev/null || date -d "$current" +%s 2>/dev/null || python3 -c "import time; print(int(time.mktime(time.strptime('$current', '%Y-%m-%d'))))")

        if [[ $current_epoch -gt $end_epoch ]]; then
            break
        fi

        if [[ -f "${MEMORY_DIR}/${current}.md" ]]; then
            dates+=("$current")
        fi

        # Increment date
        current=$(date -v+1d -j -f "%Y-%m-%d" "$current" +%Y-%m-%d 2>/dev/null || \
                  date -d "$current + 1 day" +%Y-%m-%d 2>/dev/null || \
                  python3 -c "from datetime import datetime, timedelta; d = datetime.strptime('$current', '%Y-%m-%d'); print((d + timedelta(days=1)).strftime('%Y-%m-%d'))")
    done

    echo "${dates[@]}"
}

# Extract key information from a daily log
extract_key_info() {
    local file="$1"
    local date=$(basename "$file" .md)

    log_info "Processing: $date"

    # Extract sections using common patterns
    local decisions=$(grep -iE "^#{1,3}.*(decision|decided|chose|selected)" -A 5 "$file" 2>/dev/null | head -50 || echo "")
    local learnings=$(grep -iE "^#{1,3}.*(learn|lesson|insight|discovered|realized)" -A 5 "$file" 2>/dev/null | head -50 || echo "")
    local projects=$(grep -iE "^#{1,3}.*(project|sprint|milestone|deliverable)" -A 5 "$file" 2>/dev/null | head -50 || echo "")
    local achievements=$(grep -iE "^#{1,3}.*(complete|finished|achieved|delivered|success)" -A 5 "$file" 2>/dev/null | head -50 || echo "")

    # Build summary
    cat << EOF

## $date

EOF

    if [[ -n "$decisions" ]]; then
        echo "### Key Decisions"
        echo "$decisions" | sed 's/^#/####/' | head -20
        echo ""
    fi

    if [[ -n "$learnings" ]]; then
        echo "### Learnings"
        echo "$learnings" | sed 's/^#/####/' | head -20
        echo ""
    fi

    if [[ -n "$projects" ]]; then
        echo "### Project Updates"
        echo "$projects" | sed 's/^#/####/' | head -20
        echo ""
    fi

    if [[ -n "$achievements" ]]; then
        echo "### Achievements"
        echo "$achievements" | sed 's/^#/####/' | head -20
        echo ""
    fi
}

# Check for secrets in content
security_check() {
    local content="$1"
    local issues=()

    # Patterns to check
    local patterns=(
        "api[_-]?key.*=.*['\"][a-zA-Z0-9]{20,}['\"]"
        "password.*=.*['\"][^'\"]+['\"]"
        "secret.*=.*['\"][a-zA-Z0-9]{16,}['\"]"
        "token.*=.*['\"][a-zA-Z0-9]{20,}['\"]"
        "AKIA[0-9A-Z]{16}"  # AWS Access Key
        "ghp_[a-zA-Z0-9]{36}"  # GitHub token
        "sk-[a-zA-Z0-9]{48}"   # OpenAI key
    )

    for pattern in "${patterns[@]}"; do
        if echo "$content" | grep -qiE "$pattern" 2>/dev/null; then
            issues+=("Potential secret found matching: $pattern")
        fi
    done

    if [[ ${#issues[@]} -gt 0 ]]; then
        log_warn "Security issues found:"
        printf '%s\n' "${issues[@]}" | while read -r issue; do
            echo "  - $issue"
        done
        return 1
    fi

    return 0
}

# Calculate truth density (simple heuristic)
calculate_truth_density() {
    local content="$1"

    # Count sentences
    local total_sentences=$(echo "$content" | grep -oE '[.!?]+' | wc -l | tr -d ' ')

    if [[ -z "$total_sentences" || "$total_sentences" -eq 0 ]]; then
        echo "100"
        return
    fi

    # Count "fluff" indicators
    local fluff_patterns=(
        "great question"
        "i'd be happy to"
        "i'm glad to"
        "wonderful"
        "amazing"
        "fantastic"
        "awesome"
        "breakthrough"
        "victory"
        "revolutionary"
    )

    local fluff_count=0
    for pattern in "${fluff_patterns[@]}"; do
        local count=$(echo "$content" | grep -ci "$pattern" 2>/dev/null | head -1)
        count=${count:-0}
        fluff_count=$((fluff_count + count))
    done

    # Ensure fluff_count is a number
    fluff_count=${fluff_count:-0}

    # Calculate density (100 - fluff percentage)
    local density=$((100 - (fluff_count * 100 / total_sentences)))

    # Cap at 100, floor at 0
    if [[ $density -gt 100 ]]; then
        density=100
    elif [[ $density -lt 0 ]]; then
        density=0
    fi

    echo "$density"
}

# Validate markdown formatting
validate_markdown() {
    local content="$1"
    local issues=()

    # Check for unclosed code blocks
    local code_blocks=$(echo "$content" | grep -c '^\s*\`\`\`' 2>/dev/null | head -1)
    code_blocks=${code_blocks:-0}
    if [[ $((code_blocks % 2)) -ne 0 ]]; then
        issues+=("Unclosed code block detected")
    fi

    # Check for broken links
    local broken_links=$(echo "$content" | grep -oE '\[([^\]]+)\]([^\(]|$)' 2>/dev/null | wc -l | tr -d ' ')
    broken_links=${broken_links:-0}
    if [[ "$broken_links" -gt 0 ]]; then
        issues+=("$broken_links potential broken link(s)")
    fi

    # Check for inconsistent headers
    local h1_count=$(echo "$content" | grep -c '^# ' 2>/dev/null | head -1)
    h1_count=${h1_count:-0}
    if [[ "$h1_count" -gt 1 ]]; then
        issues+=("Multiple H1 headers (should only have one)")
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        log_warn "Markdown issues found:"
        printf '%s\n' "${issues[@]}" | while read -r issue; do
            echo "  - $issue"
        done
        return 1
    fi

    return 0
}

# Create curation summary
create_summary() {
    local dates=("$@")
    local summary=""

    cat << EOF
# Weekly Memory Curation Summary

**Date:** $(date +%Y-%m-%d)  
**Period:** $START_DATE to $END_DATE  
**Files Processed:** ${#dates[@]}

## Overview

EOF

    for date in "${dates[@]}"; do
        local file="${MEMORY_DIR}/${date}.md"
        if [[ -f "$file" ]]; then
            local word_count=$(wc -w < "$file" | tr -d ' ')
            echo "- **$date**: $word_count words"
        fi
    done

    echo ""
    echo "## Key Extracts"
    echo ""

    for date in "${dates[@]}"; do
        local file="${MEMORY_DIR}/${date}.md"
        if [[ -f "$file" ]]; then
            extract_key_info "$file"
        fi
    done

    echo ""
    echo "---"
    echo ""
    echo "*Generated by Memory Curator v1.0*"
}

# Archive old daily logs
archive_old_logs() {
    local dates=("$@")
    local archive_date=$(date +%Y-%m-%d)
    local archive_name="daily-logs-${START_DATE}-to-${END_DATE}.tar.gz"
    local archive_path="${ARCHIVE_DIR}/${archive_name}"

    if [[ ${#dates[@]} -eq 0 ]]; then
        log_warn "No files to archive"
        return
    fi

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would archive ${#dates[@]} files to: $archive_path"
        return
    fi

    # Create temp file list for tar
    local file_list=$(mktemp)
    for date in "${dates[@]}"; do
        local file="${MEMORY_DIR}/${date}.md"
        if [[ -f "$file" ]]; then
            echo "${date}.md" >> "$file_list"
        fi
    done

    if [[ -s "$file_list" ]]; then
        # Create archive from memory directory with relative paths
        tar -czf "$archive_path" -C "$MEMORY_DIR" -T "$file_list"
        log_success "Archived to: $archive_path"

        # Remove original files after archiving
        if [[ "$FORCE" == true ]]; then
            for date in "${dates[@]}"; do
                local file="${MEMORY_DIR}/${date}.md"
                if [[ -f "$file" ]]; then
                    rm "$file"
                fi
            done
            log_info "Original files removed after archiving"
        fi
    else
        log_warn "No files found to archive"
    fi

    # Cleanup temp file
    rm -f "$file_list"
}

# Update curation log
update_curation_log() {
    local dates=("$@")
    local entry=""

    entry=$(cat << EOF

## Curation Entry: $(date +%Y-%m-%d)

- **Period:** $START_DATE to $END_DATE
- **Files Processed:** ${#dates[@]}
- **Archive:** daily-logs-${START_DATE}-to-${END_DATE}.tar.gz
- **Status:** ✅ Complete

EOF
)

    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] Would update curation log"
        return
    fi

    # Create log file if it doesn't exist
    if [[ ! -f "$LOG_FILE" ]]; then
        cat > "$LOG_FILE" << 'EOF'
# Memory Curation Log

This file tracks all memory curation activities.

EOF
    fi

    echo "$entry" >> "$LOG_FILE"
    log_success "Updated curation log: $LOG_FILE"
}

# Generate MEMORY.md update suggestions
generate_memory_update() {
    local summary="$1"

    cat << EOF

---

## Suggested MEMORY.md Update

Based on the curation, consider adding the following to MEMORY.md:

### New Strategic Insights
$(echo "$summary" | grep -A 3 "### Key Decisions" | grep "^####" | sed 's/^####/-/' | head -10)

### Project Updates
$(echo "$summary" | grep -A 3 "### Project Updates" | grep "^####" | sed 's/^####/-/' | head -10)

### Action Items
- [ ] Review extracted insights above
- [ ] Update relevant sections in MEMORY.md
- [ ] Remove outdated information
- [ ] Verify security (no secrets exposed)

EOF
}

# Send notification (placeholder - customize as needed)
send_notification() {
    local message="$1"

    # Telegram notification (if configured)
    if command -v telegram-send &> /dev/null; then
        echo "$message" | telegram-send --stdin 2>/dev/null || true
    fi

    # macOS notification
    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"$message\" with title \"Memory Curator\"" 2>/dev/null || true
    fi

    log_info "Notification: $message"
}

# Main execution
main() {
    log_info "Memory Curator v1.0"
    log_info "===================="

    if [[ "$DRY_RUN" == true ]]; then
        log_warn "DRY-RUN MODE: No files will be modified"
    fi

    # Initialize
    init_dirs
    calculate_date_range

    # Get list of dates with files
    local dates_str=$(generate_date_list)
    local dates=($dates_str)

    if [[ ${#dates[@]} -eq 0 ]]; then
        log_warn "No daily log files found for the specified period"
        exit 0
    fi

    log_info "Found ${#dates[@]} daily log files to process"

    # Generate summary
    local summary=$(create_summary "${dates[@]}")

    # Quality checks
    log_info "Running quality checks..."

    local all_content=""
    for date in "${dates[@]}"; do
        all_content="$all_content $(cat "${MEMORY_DIR}/${date}.md" 2>/dev/null || echo "")"
    done

    # Security check
    if ! security_check "$all_content"; then
        if [[ "$FORCE" == false && "$DRY_RUN" == false ]]; then
            log_error "Security check failed. Use --force to proceed anyway."
            exit 1
        fi
    fi

    # Truth density check
    local density=$(calculate_truth_density "$all_content")
    log_info "Truth density: ${density}%"

    if [[ $density -lt 80 ]]; then
        log_warn "Truth density below 80% (${density}%)"
        if [[ "$FORCE" == false && "$DRY_RUN" == false ]]; then
            log_error "Quality check failed. Use --force to proceed anyway."
            exit 1
        fi
    fi

    # Markdown validation
    if ! validate_markdown "$all_content"; then
        log_warn "Markdown validation issues found"
    fi

    # Display summary
    echo ""
    echo "========================================"
    echo "CURATION SUMMARY"
    echo "========================================"
    echo "$summary"
    echo ""

    # Generate MEMORY.md suggestions
    generate_memory_update "$summary"

    # Archive files
    archive_old_logs "${dates[@]}"

    # Update curation log
    update_curation_log "${dates[@]}"

    # Send notification
    send_notification "Memory curation complete: ${#dates[@]} files processed"

    log_success "Curation complete!"

    if [[ "$DRY_RUN" == true ]]; then
        log_info "This was a dry run. No files were modified."
        log_info "Run without --dry-run to apply changes."
    fi
}

# Run main function
parse_args "$@"
main
