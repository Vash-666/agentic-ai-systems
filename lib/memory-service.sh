#!/bin/bash
# =============================================================================
# Memory Service API - Centralized Context Injection for OpenClaw
# =============================================================================
# Sprint 3: Memory Service API Implementation
# Provides semantic memory search, context injection, and automated curation
#
# Usage: source /Users/rohitvashist/.openclaw/workspace/lib/memory-service.sh
#        memory_inject <agent_id> <task_description>
#        memory_search <query> [corpus]
#        memory_get <path> [lines] [from_line]
#        memory_flush <session_data_file>
#        memory_curate [--dry-run]
#
# Environment:
#   MEMORY_SERVICE_ENABLED=true|false (default: true)
#   MEMORY_LOG_LEVEL=debug|info|warn|error (default: info)
#   MEMORY_BASE_PATH=/path/to/workspace (default: auto-detect)
# =============================================================================

# -----------------------------------------------------------------------------
# Configuration & State
# -----------------------------------------------------------------------------

# Service version
readonly MEMORY_SERVICE_VERSION="1.0.0"

# Feature flag - can be disabled for backward compatibility
MEMORY_SERVICE_ENABLED="${MEMORY_SERVICE_ENABLED:-true}"

# Logging level
MEMORY_LOG_LEVEL="${MEMORY_LOG_LEVEL:-info}"

# Base path detection
if [[ -z "$MEMORY_BASE_PATH" ]]; then
    # Auto-detect based on script location or fallback
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    MEMORY_BASE_PATH="$(dirname "$SCRIPT_DIR")"
fi

# Memory paths
MEMORY_DIR="${MEMORY_BASE_PATH}/grok/memory"
MEMORY_MD="${MEMORY_BASE_PATH}/grok/MEMORY.md"
AGENTS_MD="${MEMORY_BASE_PATH}/grok/AGENTS.md"
SOUL_MD="${MEMORY_BASE_PATH}/grok/SOUL.md"
TOOLS_MD="${MEMORY_BASE_PATH}/grok/TOOLS.md"
USER_MD="${MEMORY_BASE_PATH}/grok/USER.md"

# Metrics and logging
MEMORY_METRICS_FILE="${MEMORY_DIR}/.memory-metrics.json"
MEMORY_INJECTION_LOG="${MEMORY_DIR}/.injection-log.jsonl"
MEMORY_CURATION_LOG="${MEMORY_DIR}/.curation-log.json"

# Curation settings
MEMORY_CURATION_DAYS=7
MEMORY_MAX_DAILY_FILES=30

# Relevance scoring weights
WEIGHT_STRATEGIC=0.35      # MEMORY.md content
WEIGHT_RECENT=0.30         # Recent daily notes
WEIGHT_PROCEDURAL=0.20     # AGENTS.md procedures
WEIGHT_TOOLS=0.10          # TOOLS.md specifics
WEIGHT_USER=0.05           # USER.md preferences

# -----------------------------------------------------------------------------
# Logging Functions
# -----------------------------------------------------------------------------

_memory_log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Log level numeric values (using case instead of associative array for compatibility)
    local current_level
    case "$MEMORY_LOG_LEVEL" in
        debug) current_level=0 ;;
        info)  current_level=1 ;;
        warn)  current_level=2 ;;
        error) current_level=3 ;;
        *)     current_level=1 ;;
    esac
    
    local msg_level
    case "$level" in
        debug) msg_level=0 ;;
        info)  msg_level=1 ;;
        warn)  msg_level=2 ;;
        error) msg_level=3 ;;
        *)     msg_level=1 ;;
    esac
    
    if [[ $msg_level -ge $current_level ]]; then
        echo "[$timestamp] [memory-service] [$level] $message" >&2
    fi
}

_memory_debug() { _memory_log "debug" "$1"; }
_memory_info() { _memory_log "info" "$1"; }
_memory_warn() { _memory_log "warn" "$1"; }
_memory_error() { _memory_log "error" "$1"; }

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------

# Check if memory service is enabled
_memory_check_enabled() {
    if [[ "$MEMORY_SERVICE_ENABLED" != "true" ]]; then
        _memory_debug "Memory service is disabled (MEMORY_SERVICE_ENABLED=$MEMORY_SERVICE_ENABLED)"
        return 1
    fi
    return 0
}

# Ensure memory directory exists
_memory_ensure_dir() {
    if [[ ! -d "$MEMORY_DIR" ]]; then
        mkdir -p "$MEMORY_DIR"
        _memory_info "Created memory directory: $MEMORY_DIR"
    fi
}

# Get today's date in YYYY-MM-DD format
_memory_today() {
    date +"%Y-%m-%d"
}

# Get date N days ago
_memory_days_ago() {
    local days="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS date command
        date -v-${days}d +"%Y-%m-%d"
    else
        # Linux date command
        date -d "$days days ago" +"%Y-%m-%d"
    fi
}

# Calculate simple relevance score based on keyword matching
# Returns score between 0.0 and 1.0
_memory_calculate_relevance() {
    local content="$1"
    local query="$2"
    local base_weight="${3:-1.0}"
    
    # Convert to lowercase for matching (using tr for compatibility)
    local content_lower
    content_lower=$(echo "$content" | tr '[:upper:]' '[:lower:]')
    local query_lower
    query_lower=$(echo "$query" | tr '[:upper:]' '[:lower:]')
    
    # Extract keywords from query (remove common words)
    local keywords
    keywords=$(echo "$query_lower" | tr ' ' '\n' | grep -vE '^(the|a|an|and|or|but|in|on|at|to|for|of|with|by|is|are|was|were|be|been|have|has|had|do|does|did|will|would|could|should|may|might|can|this|that|these|those|i|you|he|she|it|we|they|me|him|her|us|them|my|your|his|her|its|our|their)$' | sort -u)
    
    local total_keywords
    total_keywords=$(echo "$keywords" | grep -c '^' || echo "0")
    
    if [[ "$total_keywords" -eq 0 ]]; then
        echo "0.0"
        return
    fi
    
    local matched=0
    while IFS= read -r keyword; do
        if [[ -n "$keyword" && "$content_lower" == *"$keyword"* ]]; then
            ((matched++))
        fi
    done <<< "$keywords"
    
    # Calculate score with base weight
    local score
    score=$(echo "scale=4; ($matched / $total_keywords) * $base_weight" | bc -l 2>/dev/null || echo "0.0")
    
    # Ensure we output a valid number
    if [[ -z "$score" || "$score" == "." ]]; then
        score="0.0"
    fi
    
    echo "$score"
}

# Record injection event for metrics
_memory_record_injection() {
    local agent_id="$1"
    local task="$2"
    local context_size="$3"
    local relevance_score="$4"
    local sources="$5"
    
    _memory_ensure_dir
    
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    local entry
    entry=$(cat <<EOF
{"timestamp":"$timestamp","agent_id":"$agent_id","task_hash":"$(echo "$task" | md5sum | cut -d' ' -f1 | head -c 16)","context_size":$context_size,"relevance_score":$relevance_score,"sources":"$sources"}
EOF
)
    
    echo "$entry" >> "$MEMORY_INJECTION_LOG"
    _memory_debug "Recorded injection event for agent: $agent_id"
}

# Update metrics file
_memory_update_metrics() {
    local injection_count=0
    local total_relevance="0.0"
    local total_context_size=0
    
    if [[ -f "$MEMORY_INJECTION_LOG" ]]; then
        # Count injections and calculate averages
        while IFS= read -r line; do
            ((injection_count++))
            local rel
            rel=$(echo "$line" | grep -o '"relevance_score":[0-9.]*' | cut -d':' -f2)
            if [[ -n "$rel" ]]; then
                total_relevance=$(echo "$total_relevance + $rel" | bc -l 2>/dev/null || echo "$total_relevance")
            fi
            local size
            size=$(echo "$line" | grep -o '"context_size":[0-9]*' | cut -d':' -f2)
            if [[ -n "$size" ]]; then
                total_context_size=$((total_context_size + size))
            fi
        done < "$MEMORY_INJECTION_LOG"
    fi
    
    local avg_relevance="0.0"
    if [[ $injection_count -gt 0 ]]; then
        avg_relevance=$(echo "scale=4; $total_relevance / $injection_count" | bc -l 2>/dev/null || echo "0.0")
    fi
    
    local metrics
    metrics=$(cat <<EOF
{
  "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_injections": $injection_count,
  "average_relevance": $avg_relevance,
  "total_context_bytes": $total_context_size,
  "service_version": "$MEMORY_SERVICE_VERSION",
  "enabled": $([[ "$MEMORY_SERVICE_ENABLED" == "true" ]] && echo "true" || echo "false")
}
EOF
)
    
    echo "$metrics" > "$MEMORY_METRICS_FILE"
}

# -----------------------------------------------------------------------------
# Core Memory Functions
# -----------------------------------------------------------------------------

# Read MEMORY.md for strategic context
_memory_read_strategic() {
    if [[ ! -f "$MEMORY_MD" ]]; then
        _memory_debug "MEMORY.md not found at $MEMORY_MD"
        return
    fi
    
    local content
    content=$(cat "$MEMORY_MD" 2>/dev/null)
    
    if [[ -n "$content" ]]; then
        echo "## Strategic Context (MEMORY.md)"
        echo ""
        echo "$content"
        echo ""
    fi
}

# Read recent daily memory files
_memory_read_recent() {
    local days="${1:-7}"
    local count=0
    local output=""
    
    for ((i=0; i<days; i++)); do
        local date_str
        date_str=$(_memory_days_ago "$i")
        
        # Check for files matching pattern memory/YYYY-MM-DD*.md
        for file in "$MEMORY_DIR"/${date_str}*.md; do
            if [[ -f "$file" ]]; then
                local basename
                basename=$(basename "$file")
                output+="## Recent Activity: $basename"
                output+=$'\n\n'
                output+=$(cat "$file")
                output+=$'\n\n'
                ((count++))
            fi
        done
    done
    
    if [[ $count -gt 0 ]]; then
        echo "## Recent Activity (Last $days days)"
        echo ""
        echo "$output"
    else
        _memory_debug "No recent daily memory files found"
    fi
}

# Read AGENTS.md for procedures
_memory_read_procedural() {
    if [[ ! -f "$AGENTS_MD" ]]; then
        _memory_debug "AGENTS.md not found at $AGENTS_MD"
        return
    fi
    
    local content
    content=$(cat "$AGENTS_MD" 2>/dev/null)
    
    if [[ -n "$content" ]]; then
        echo "## Procedures & Guidelines (AGENTS.md)"
        echo ""
        echo "$content"
        echo ""
    fi
}

# Read TOOLS.md for environment specifics
_memory_read_tools() {
    if [[ ! -f "$TOOLS_MD" ]]; then
        _memory_debug "TOOLS.md not found at $TOOLS_MD"
        return
    fi
    
    local content
    content=$(cat "$TOOLS_MD" 2>/dev/null)
    
    if [[ -n "$content" ]]; then
        echo "## Environment Specifics (TOOLS.md)"
        echo ""
        echo "$content"
        echo ""
    fi
}

# Read USER.md for user preferences
_memory_read_user() {
    if [[ ! -f "$USER_MD" ]]; then
        _memory_debug "USER.md not found at $USER_MD"
        return
    fi
    
    local content
    content=$(cat "$USER_MD" 2>/dev/null)
    
    if [[ -n "$content" ]]; then
        echo "## User Preferences (USER.md)"
        echo ""
        echo "$content"
        echo ""
    fi
}

# Read SOUL.md for identity
_memory_read_soul() {
    if [[ ! -f "$SOUL_MD" ]]; then
        _memory_debug "SOUL.md not found at $SOUL_MD"
        return
    fi
    
    local content
    content=$(cat "$SOUL_MD" 2>/dev/null)
    
    if [[ -n "$content" ]]; then
        echo "## Identity & Principles (SOUL.md)"
        echo ""
        echo "$content"
        echo ""
    fi
}

# Filter content by relevance to task
_memory_filter_by_relevance() {
    local content="$1"
    local task="$2"
    local threshold="${3:-0.1}"
    
    # Simple paragraph-based filtering
    local filtered=""
    local paragraph=""
    
    while IFS= read -r line; do
        if [[ -z "$line" ]]; then
            # End of paragraph, check relevance
            if [[ -n "$paragraph" ]]; then
                local score
                score=$(_memory_calculate_relevance "$paragraph" "$task" 1.0)
                
                # Compare scores using bc
                local keep
                keep=$(echo "$score >= $threshold" | bc -l 2>/dev/null)
                
                if [[ "$keep" == "1" ]]; then
                    filtered+="$paragraph"
                    filtered+=$'\n\n'
                fi
            fi
            paragraph=""
        else
            paragraph+="$line"
            paragraph+=$'\n'
        fi
    done <<< "$content"
    
    # Handle last paragraph
    if [[ -n "$paragraph" ]]; then
        local score
        score=$(_memory_calculate_relevance "$paragraph" "$task" 1.0)
        local keep
        keep=$(echo "$score >= $threshold" | bc -l 2>/dev/null)
        
        if [[ "$keep" == "1" ]]; then
            filtered+="$paragraph"
        fi
    fi
    
    echo "$filtered"
}

# -----------------------------------------------------------------------------
# Public API Functions
# -----------------------------------------------------------------------------

# memory_inject - Returns relevant context for an agent task
# Usage: memory_inject <agent_id> <task_description>
# Returns: Formatted context block on stdout
memory_inject() {
    local agent_id="${1:-unknown}"
    local task="${2:-}"
    
    _memory_info "Injecting context for agent: $agent_id"
    _memory_debug "Task: ${task:0:100}..."
    
    # Check if service is enabled
    if ! _memory_check_enabled; then
        _memory_info "Memory service disabled, returning empty context"
        echo ""
        return 0
    fi
    
    # Validate inputs
    if [[ -z "$task" ]]; then
        _memory_warn "Empty task provided to memory_inject"
        echo ""
        return 0
    fi
    
    _memory_ensure_dir
    
    # Collect context from various sources
    local context=""
    local sources=""
    local total_score="0.0"
    local source_count=0
    
    # 1. Strategic context (MEMORY.md) - always include if exists
    local strategic
    strategic=$(_memory_read_strategic)
    if [[ -n "$strategic" ]]; then
        context+="$strategic"
        context+=$'\n---\n\n'
        sources+="strategic,"
        total_score=$(echo "$total_score + $WEIGHT_STRATEGIC" | bc -l)
        ((source_count++))
    fi
    
    # 2. Recent activity (last 7 days)
    local recent
    recent=$(_memory_read_recent 7)
    if [[ -n "$recent" ]]; then
        # Filter by relevance if task is provided
        if [[ -n "$task" ]]; then
            recent=$(_memory_filter_by_relevance "$recent" "$task" 0.05)
        fi
        
        if [[ -n "$recent" ]]; then
            context+="$recent"
            context+=$'\n---\n\n'
            sources+="recent,"
            total_score=$(echo "$total_score + $WEIGHT_RECENT" | bc -l)
            ((source_count++))
        fi
    fi
    
    # 3. Procedural context (AGENTS.md)
    local procedural
    procedural=$(_memory_read_procedural)
    if [[ -n "$procedural" ]]; then
        # Filter to relevant sections
        if [[ -n "$task" ]]; then
            procedural=$(_memory_filter_by_relevance "$procedural" "$task" 0.1)
        fi
        
        if [[ -n "$procedural" ]]; then
            context+="$procedural"
            context+=$'\n---\n\n'
            sources+="procedural,"
            total_score=$(echo "$total_score + $WEIGHT_PROCEDURAL" | bc -l)
            ((source_count++))
        fi
    fi
    
    # 4. Tools context (TOOLS.md)
    local tools
    tools=$(_memory_read_tools)
    if [[ -n "$tools" ]]; then
        context+="$tools"
        context+=$'\n---\n\n'
        sources+="tools,"
        total_score=$(echo "$total_score + $WEIGHT_TOOLS" | bc -l)
        ((source_count++))
    fi
    
    # 5. User context (USER.md)
    local user_ctx
    user_ctx=$(_memory_read_user)
    if [[ -n "$user_ctx" ]]; then
        context+="$user_ctx"
        context+=$'\n---\n\n'
        sources+="user,"
        total_score=$(echo "$total_score + $WEIGHT_USER" | bc -l)
        ((source_count++))
    fi
    
    # Calculate average relevance score
    local avg_score="0.0"
    if [[ $source_count -gt 0 ]]; then
        avg_score=$(echo "scale=4; $total_score / $source_count" | bc -l)
    fi
    
    # Record metrics
    local context_size=${#context}
    _memory_record_injection "$agent_id" "$task" "$context_size" "$avg_score" "${sources%,}"
    _memory_update_metrics
    
    _memory_info "Context injection complete: $source_count sources, relevance: $avg_score"
    
    # Output the formatted context
    echo "<!-- Memory Service Context Injection v${MEMORY_SERVICE_VERSION} -->"
    echo "<!-- Agent: $agent_id | Sources: ${sources%,} | Relevance: $avg_score -->"
    echo ""
    echo "$context"
}

# memory_flush - Persist session data to long-term memory
# Usage: memory_flush <session_data_file>
# Returns: 0 on success, 1 on failure
memory_flush() {
    local session_data_file="$1"
    
    _memory_info "Flushing session data to long-term memory"
    
    if ! _memory_check_enabled; then
        _memory_info "Memory service disabled, skipping flush"
        return 0
    fi
    
    if [[ -z "$session_data_file" ]]; then
        _memory_error "No session data file provided to memory_flush"
        return 1
    fi
    
    if [[ ! -f "$session_data_file" ]]; then
        _memory_error "Session data file not found: $session_data_file"
        return 1
    fi
    
    _memory_ensure_dir
    
    # Generate timestamped memory file
    local timestamp
    timestamp=$(date +"%Y-%m-%d-%H%M")
    local memory_file="${MEMORY_DIR}/${timestamp}.md"
    
    # Read session data
    local session_data
    session_data=$(cat "$session_data_file")
    
    # Create memory entry with metadata
    cat > "$memory_file" <<EOF
# Session Memory: $timestamp

**Flushed at:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Source:** $session_data_file
**Size:** ${#session_data} bytes

## Content

$session_data

---
*Auto-generated by Memory Service v${MEMORY_SERVICE_VERSION}*
EOF
    
    _memory_info "Session data flushed to: $memory_file"
    
    # Update metrics
    _memory_update_metrics
    
    return 0
}

# memory_search - Semantic search across memory corpus
# Usage: memory_search <query> [corpus]
#   corpus: all|memory|daily|procedural (default: all)
# Returns: Matching excerpts on stdout
memory_search() {
    local query="$1"
    local corpus="${2:-all}"
    
    _memory_info "Searching memory corpus: query='${query:0:50}...', corpus=$corpus"
    
    if ! _memory_check_enabled; then
        _memory_info "Memory service disabled, returning empty results"
        echo ""
        return 0
    fi
    
    if [[ -z "$query" ]]; then
        _memory_warn "Empty query provided to memory_search"
        echo ""
        return 0
    fi
    
    local results=""
    local match_count=0
    
    # Search MEMORY.md
    if [[ "$corpus" == "all" || "$corpus" == "memory" || "$corpus" == "strategic" ]]; then
        if [[ -f "$MEMORY_MD" ]]; then
            local content
            content=$(cat "$MEMORY_MD")
            local score
            score=$(_memory_calculate_relevance "$content" "$query" 1.0)
            local is_match
            is_match=$(echo "$score > 0.1" | bc -l)
            
            if [[ "$is_match" == "1" ]]; then
                results+="## Match in MEMORY.md (score: $score)"
                results+=$'\n\n'
                # Return first 500 chars of relevant section
                results+=$(echo "$content" | head -c 500)
                results+=$'\n\n'
                ((match_count++))
            fi
        fi
    fi
    
    # Search daily memory files
    if [[ "$corpus" == "all" || "$corpus" == "daily" ]]; then
        for file in "$MEMORY_DIR"/*.md; do
            if [[ -f "$file" && "$(basename "$file")" != .* ]]; then
                local content
                content=$(cat "$file")
                local score
                score=$(_memory_calculate_relevance "$content" "$query" 1.0)
                local is_match
                is_match=$(echo "$score > 0.15" | bc -l)
                
                if [[ "$is_match" == "1" ]]; then
                    local basename
                    basename=$(basename "$file")
                    results+="## Match in $basename (score: $score)"
                    results+=$'\n\n'
                    results+=$(echo "$content" | head -c 500)
                    results+=$'\n\n'
                    ((match_count++))
                fi
            fi
        done
    fi
    
    # Search AGENTS.md
    if [[ "$corpus" == "all" || "$corpus" == "procedural" ]]; then
        if [[ -f "$AGENTS_MD" ]]; then
            local content
            content=$(cat "$AGENTS_MD")
            local score
            score=$(_memory_calculate_relevance "$content" "$query" 1.0)
            local is_match
            is_match=$(echo "$score > 0.1" | bc -l)
            
            if [[ "$is_match" == "1" ]]; then
                results+="## Match in AGENTS.md (score: $score)"
                results+=$'\n\n'
                results+=$(echo "$content" | head -c 500)
                results+=$'\n\n'
                ((match_count++))
            fi
        fi
    fi
    
    _memory_info "Search complete: $match_count matches found"
    
    if [[ $match_count -eq 0 ]]; then
        echo "No matches found for query."
    else
        echo "# Memory Search Results"
        echo ""
        echo "**Query:** $query"
        echo "**Corpus:** $corpus"
        echo "**Matches:** $match_count"
        echo ""
        echo "$results"
    fi
}

# memory_get - Exact excerpt read from memory file
# Usage: memory_get <path> [lines] [from_line]
# Returns: File excerpt on stdout
memory_get() {
    local path="$1"
    local lines="${2:-50}"
    local from_line="${3:-1}"
    
    _memory_debug "Getting excerpt: $path (lines $from_line-$((from_line + lines - 1)))"
    
    if ! _memory_check_enabled; then
        _memory_info "Memory service disabled, attempting direct read"
        # Fallback to direct read
        if [[ -f "$path" ]]; then
            tail -n "+$from_line" "$path" | head -n "$lines"
        fi
        return $?
    fi
    
    if [[ -z "$path" ]]; then
        _memory_error "No path provided to memory_get"
        return 1
    fi
    
    # Resolve path
    local full_path
    if [[ "$path" == /* ]]; then
        full_path="$path"
    else
        # Assume relative to memory base
        full_path="${MEMORY_BASE_PATH}/grok/$path"
    fi
    
    if [[ ! -f "$full_path" ]]; then
        _memory_error "File not found: $full_path"
        return 1
    fi
    
    # Validate line parameters
    if ! [[ "$lines" =~ ^[0-9]+$ ]]; then
        lines=50
    fi
    if ! [[ "$from_line" =~ ^[0-9]+$ ]]; then
        from_line=1
    fi
    
    # Extract excerpt
    tail -n "+$from_line" "$full_path" | head -n "$lines"
    
    return 0
}

# memory_curate - Weekly automated curation
# Usage: memory_curate [--dry-run]
# Returns: Curation report on stdout
memory_curate() {
    local dry_run=false
    if [[ "$1" == "--dry-run" ]]; then
        dry_run=true
    fi
    
    _memory_info "Starting memory curation (dry-run: $dry_run)"
    
    if ! _memory_check_enabled; then
        _memory_info "Memory service disabled, skipping curation"
        return 0
    fi
    
    _memory_ensure_dir
    
    local report="# Memory Curation Report"
    report+=$'\n\n'
    report+="**Date:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    report+=$'\n'
    report+="**Mode:** $([[ "$dry_run" == "true" ]] && echo "DRY RUN" || echo "LIVE")"
    report+=$'\n\n'
    
    local archived_count=0
    local deleted_count=0
    local kept_count=0
    
    # Calculate cutoff date
    local cutoff_date
    cutoff_date=$(_memory_days_ago "$MEMORY_CURATION_DAYS")
    
    report+="## Daily Memory Files"
    report+=$'\n\n'
    
    # Process daily memory files
    for file in "$MEMORY_DIR"/*.md; do
        if [[ -f "$file" && "$(basename "$file")" != .* ]]; then
            local basename
            basename=$(basename "$file")
            local file_date
            file_date=$(echo "$basename" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2}' || echo "")
            
            if [[ -n "$file_date" ]]; then
                # Compare dates
                if [[ "$file_date" < "$cutoff_date" ]]; then
                    # Old file - archive or delete
                    if [[ "$dry_run" == "false" ]]; then
                        # Create archive directory
                        local archive_dir="${MEMORY_DIR}/archive"
                        mkdir -p "$archive_dir"
                        mv "$file" "$archive_dir/"
                    fi
                    report+="- [ARCHIVED] $basename (date: $file_date)"
                    ((archived_count++))
                else
                    report+="- [KEPT] $basename (date: $file_date)"
                    ((kept_count++))
                fi
                report+=$'\n'
            fi
        fi
    done
    
    report+=$'\n'
    report+="## Summary"
    report+=$'\n\n'
    report+="- Files kept: $kept_count"
    report+=$'\n'
    report+="- Files archived: $archived_count"
    report+=$'\n'
    report+="- Retention period: $MEMORY_CURATION_DAYS days"
    report+=$'\n'
    report+="- Cutoff date: $cutoff_date"
    report+=$'\n\n'
    
    # Log curation event
    if [[ "$dry_run" == "false" ]]; then
        local curation_entry
        curation_entry=$(cat <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "kept": $kept_count,
  "archived": $archived_count,
  "cutoff_date": "$cutoff_date"
}
EOF
)
        echo "$curation_entry" > "$MEMORY_CURATION_LOG"
    fi
    
    _memory_info "Curation complete: $kept_count kept, $archived_count archived"
    
    echo "$report"
}

# memory_metrics - Display current metrics
# Usage: memory_metrics
memory_metrics() {
    if [[ -f "$MEMORY_METRICS_FILE" ]]; then
        cat "$MEMORY_METRICS_FILE"
    else
        echo '{"error": "No metrics available"}'
    fi
}

# memory_status - Display service status
# Usage: memory_status
memory_status() {
    echo "Memory Service Status"
    echo "====================="
    echo ""
    echo "Version: $MEMORY_SERVICE_VERSION"
    echo "Enabled: $MEMORY_SERVICE_ENABLED"
    echo "Log Level: $MEMORY_LOG_LEVEL"
    echo "Base Path: $MEMORY_BASE_PATH"
    echo ""
    echo "Paths:"
    echo "  Memory Dir: $MEMORY_DIR"
    echo "  MEMORY.md: $MEMORY_MD"
    echo "  AGENTS.md: $AGENTS_MD"
    echo ""
    echo "Metrics:"
    memory_metrics | sed 's/^/  /'
    echo ""
    echo "Recent Injections:"
    if [[ -f "$MEMORY_INJECTION_LOG" ]]; then
        tail -5 "$MEMORY_INJECTION_LOG" | sed 's/^/  /'
    else
        echo "  No injection log found"
    fi
}

# -----------------------------------------------------------------------------
# Integration Helpers
# -----------------------------------------------------------------------------

# Helper to update spawn functions to use memory_inject
# This can be sourced in spawn scripts
memory_prepare_context() {
    local agent_id="$1"
    local task="$2"
    
    if [[ "$MEMORY_SERVICE_ENABLED" == "true" ]]; then
        memory_inject "$agent_id" "$task"
    else
        # Fallback: direct file reads for backward compatibility
        echo "<!-- Memory Service Disabled - Fallback Mode -->"
        echo ""
        [[ -f "$AGENTS_MD" ]] && cat "$AGENTS_MD"
    fi
}

# -----------------------------------------------------------------------------
# Test Suite
# -----------------------------------------------------------------------------

_memory_run_tests() {
    echo "Memory Service Test Suite v${MEMORY_SERVICE_VERSION}"
    echo "================================================"
    echo ""
    
    local passed=0
    local failed=0
    
    # Test 1: Service enabled check
    echo "Test 1: Service enabled check..."
    if _memory_check_enabled; then
        echo "  ✓ Service is enabled"
        ((passed++))
    else
        echo "  ✗ Service is disabled"
        ((failed++))
    fi
    echo ""
    
    # Test 2: Directory creation
    echo "Test 2: Directory creation..."
    _memory_ensure_dir
    if [[ -d "$MEMORY_DIR" ]]; then
        echo "  ✓ Memory directory exists: $MEMORY_DIR"
        ((passed++))
    else
        echo "  ✗ Memory directory not found"
        ((failed++))
    fi
    echo ""
    
    # Test 3: Relevance calculation
    echo "Test 3: Relevance calculation..."
    local test_content="This is a test about machine learning and AI systems"
    local test_query="machine learning AI"
    local score
    score=$(_memory_calculate_relevance "$test_content" "$test_query" 1.0)
    if [[ -n "$score" && "$score" != "0.0" ]]; then
        echo "  ✓ Relevance score calculated: $score"
        ((passed++))
    else
        echo "  ✗ Failed to calculate relevance"
        ((failed++))
    fi
    echo ""
    
    # Test 4: Date calculations
    echo "Test 4: Date calculations..."
    local today
    today=$(_memory_today)
    local week_ago
    week_ago=$(_memory_days_ago 7)
    if [[ -n "$today" && -n "$week_ago" ]]; then
        echo "  ✓ Today: $today"
        echo "  ✓ 7 days ago: $week_ago"
        ((passed++))
    else
        echo "  ✗ Date calculation failed"
        ((failed++))
    fi
    echo ""
    
    # Test 5: Context injection (basic)
    echo "Test 5: Context injection..."
    local context
    context=$(memory_inject "test-agent" "test task for memory system")
    if [[ -n "$context" ]]; then
        echo "  ✓ Context generated (${#context} bytes)"
        ((passed++))
    else
        echo "  ✗ Context injection returned empty"
        ((failed++))
    fi
    echo ""
    
    # Test 6: Memory search
    echo "Test 6: Memory search..."
    local search_results
    search_results=$(memory_search "test" "all")
    if [[ -n "$search_results" ]]; then
        echo "  ✓ Search executed"
        ((passed++))
    else
        echo "  ✗ Search returned empty"
        ((failed++))
    fi
    echo ""
    
    # Test 7: Memory get
    echo "Test 7: Memory get..."
    if [[ -f "$AGENTS_MD" ]]; then
        local excerpt
        excerpt=$(memory_get "AGENTS.md" 10 1)
        if [[ -n "$excerpt" ]]; then
            echo "  ✓ Excerpt retrieved (${#excerpt} bytes)"
            ((passed++))
        else
            echo "  ✗ Failed to get excerpt"
            ((failed++))
        fi
    else
        echo "  ⚠ Skipped (AGENTS.md not found)"
    fi
    echo ""
    
    # Test 8: Curation dry-run
    echo "Test 8: Curation (dry-run)..."
    local curation_report
    curation_report=$(memory_curate --dry-run)
    if [[ -n "$curation_report" ]]; then
        echo "  ✓ Curation report generated"
        ((passed++))
    else
        echo "  ✗ Curation failed"
        ((failed++))
    fi
    echo ""
    
    # Test 9: Metrics
    echo "Test 9: Metrics..."
    local metrics
    metrics=$(memory_metrics)
    if [[ -n "$metrics" ]]; then
        echo "  ✓ Metrics retrieved"
        ((passed++))
    else
        echo "  ✗ Metrics not available"
        ((failed++))
    fi
    echo ""
    
    # Test 10: Status
    echo "Test 10: Status..."
    local status
    status=$(memory_status)
    if [[ -n "$status" ]]; then
        echo "  ✓ Status retrieved"
        ((passed++))
    else
        echo "  ✗ Status not available"
        ((failed++))
    fi
    echo ""
    
    # Summary
    echo "================================================"
    echo "Test Results: $passed passed, $failed failed"
    echo ""
    
    if [[ $failed -eq 0 ]]; then
        echo "✓ All tests passed!"
        return 0
    else
        echo "✗ Some tests failed"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# CLI Interface
# -----------------------------------------------------------------------------

# Handle command-line invocation
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        --test|-t)
            _memory_run_tests
            exit $?
            ;;
        --status)
            memory_status
            exit 0
            ;;
        --metrics)
            memory_metrics
            exit 0
            ;;
        --inject)
            if [[ -z "${2:-}" || -z "${3:-}" ]]; then
                echo "Usage: $0 --inject <agent_id> <task>"
                exit 1
            fi
            memory_inject "$2" "$3"
            exit 0
            ;;
        --search)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 --search <query> [corpus]"
                exit 1
            fi
            memory_search "$2" "${3:-all}"
            exit 0
            ;;
        --get)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 --get <path> [lines] [from_line]"
                exit 1
            fi
            memory_get "$2" "${3:-50}" "${4:-1}"
            exit 0
            ;;
        --flush)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 --flush <session_data_file>"
                exit 1
            fi
            memory_flush "$2"
            exit $?
            ;;
        --curate)
            memory_curate "${2:-}"
            exit 0
            ;;
        --help|-h)
            cat <<'EOF'
Memory Service API v1.0.0

USAGE:
    memory-service.sh [COMMAND] [OPTIONS]

COMMANDS:
    --test, -t              Run test suite
    --status                Show service status
    --metrics               Show metrics
    --inject <agent> <task> Inject context for agent task
    --search <query> [corp] Search memory corpus
    --get <path> [n] [from] Get file excerpt
    --flush <file>          Flush session data to memory
    --curate [--dry-run]    Run weekly curation
    --help, -h              Show this help

ENVIRONMENT:
    MEMORY_SERVICE_ENABLED  Enable/disable service (default: true)
    MEMORY_LOG_LEVEL        Logging level (debug|info|warn|error)
    MEMORY_BASE_PATH        Base path for memory files

EXAMPLES:
    # Run tests
    ./memory-service.sh --test

    # Get context for a task
    ./memory-service.sh --inject "coder-agent" "fix login bug"

    # Search memories
    ./memory-service.sh --search "deployment" "daily"

    # Get file excerpt
    ./memory-service.sh --get "memory/2026-05-23.md" 20 1

    # Flush session data
    ./memory-service.sh --flush /tmp/session-data.txt

    # Run curation (dry-run)
    ./memory-service.sh --curate --dry-run
EOF
            exit 0
            ;;
        "")
            echo "Memory Service API v${MEMORY_SERVICE_VERSION}"
            echo "Use --help for usage information"
            echo ""
            memory_status
            exit 0
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
fi
