#!/bin/bash
#
# Grok Hybrid Wrapper Script v1.1 (with Distributed Tracing)
# Auto-routes tasks between grok-bridge.sh (fast/simple) and native grok CLI (complex/tools)
# Usage: grok-hybrid.sh "Your question"
#        grok-hybrid.sh --complex "Complex coding task"
#        grok-hybrid.sh --simple "Quick question"
#        grok-hybrid.sh --chat "Interactive session"
#        grok-hybrid.sh --agent "Multi-step agent task"
#

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

WORKSPACE="/Users/rohitvashist/.openclaw/workspace"
TOOLS_DIR="$WORKSPACE/tools"
LOG_FILE="$WORKSPACE/grok-bridge-log.md"
COST_LOG="$WORKSPACE/grok-cost-tracker.jsonl"
HYBRID_LOG="$WORKSPACE/grok-hybrid-log.jsonl"

BRIDGE_SCRIPT="$TOOLS_DIR/grok-bridge.sh"
NATIVE_GROK="grok"
TRACE_LIB="$TOOLS_DIR/trace-lib.sh"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S %Z")
START_TIME=$(date +%s.%N)

# Source trace library if available
if [ -f "$TRACE_LIB" ]; then
    source "$TRACE_LIB"
fi

# Cost tracking (estimated USD per million tokens)
BRIDGE_COST_INPUT=0.50
BRIDGE_COST_OUTPUT=1.50
NATIVE_COST_INPUT=0.50
NATIVE_COST_OUTPUT=1.50

# Complexity thresholds
COMPLEXITY_THRESHOLD_CHARS=500
COMPLEXITY_THRESHOLD_WORDS=100
COMPLEXITY_THRESHOLD_LINES=20

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function log_hybrid_event() {
    local event_type="$1"
    local routing_decision="$2"
    local details="$3"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local trace_id="${TRACE_ID:-}"
    local span_id="${SPAN_ID:-}"

    mkdir -p "$(dirname "$HYBRID_LOG")"

    cat >> "$HYBRID_LOG" <<EOF
{"timestamp":"$timestamp","event":"$event_type","routing":"$routing_decision","details":"$details","trace_id":"$trace_id","span_id":"$span_id"}
EOF
}

function log_to_bridge_log() {
    local user_message="$1"
    local grok_response="$2"
    local model="$3"
    local response_time="$4"
    local route="$5"
    local estimated_cost="$6"

    mkdir -p "$(dirname "$LOG_FILE")"

    cat >> "$LOG_FILE" <<EOF
## $TIMESTAMP

**Model:** $model  
**Route:** $route  
**Input:** ${#user_message} chars  
**Response:** ${#grok_response} chars  
**Time:** ${response_time}s  
**Cost:** \$${estimated_cost:-unknown}
**Trace ID:** ${TRACE_ID:-none}

**Question:**  
$user_message

**Response:**  
$grok_response

---

EOF
}

function count_words() {
    echo "$1" | wc -w | tr -d ' '
}

function count_lines() {
    echo "$1" | wc -l | tr -d ' '
}

function detect_complexity_signals() {
    local message="$1"
    local signals=""

    # Check for complex task indicators
    local complex_patterns=(
        "code\|script\|function\|implement\|create\|build\|develop"
        "debug\|fix\|error\|bug\|issue\|troubleshoot"
        "analyze\|review\|audit\|assess\|evaluate"
        "architecture\|design\|pattern\|structure"
        "refactor\|rewrite\|optimize\|improve"
        "test\|unittest\|integration\|coverage"
        "database\|query\|schema\|migration"
        "api\|endpoint\|rest\|graphql"
        "file\|directory\|folder\|path"
        "git\|commit\|branch\|merge\|repository"
        "docker\|container\|kubernetes\|deploy"
        "multi-step\|workflow\|pipeline\|automation"
        "complex\|complicated\|sophisticated\|advanced"
        "project\|application\|service\|system"
        "config\|configuration\|setup\|environment"
    )

    for pattern in "${complex_patterns[@]}"; do
        if echo "$message" | grep -qiE "$pattern"; then
            signals="${signals}$(echo "$pattern" | sed 's/\\|/, /g'), "
        fi
    done

    # Remove trailing comma and space
    signals=$(echo "$signals" | sed 's/, $//')
    echo "$signals"
}

function calculate_complexity_score() {
    local message="$1"
    local score=0

    local char_count=${#message}
    local word_count=$(count_words "$message")
    local line_count=$(count_lines "$message")

    # Length-based scoring
    if [ "$char_count" -gt 2000 ]; then
        score=$((score + 40))
    elif [ "$char_count" -gt 1000 ]; then
        score=$((score + 30))
    elif [ "$char_count" -gt 500 ]; then
        score=$((score + 20))
    elif [ "$char_count" -gt 200 ]; then
        score=$((score + 10))
    fi

    # Word count scoring
    if [ "$word_count" -gt 300 ]; then
        score=$((score + 25))
    elif [ "$word_count" -gt 150 ]; then
        score=$((score + 15))
    elif [ "$word_count" -gt 75 ]; then
        score=$((score + 5))
    fi

    # Line count scoring
    if [ "$line_count" -gt 50 ]; then
        score=$((score + 25))
    elif [ "$line_count" -gt 20 ]; then
        score=$((score + 15))
    elif [ "$line_count" -gt 5 ]; then
        score=$((score + 5))
    fi

    # Complexity signals scoring (higher weight for technical terms)
    local signals=$(detect_complexity_signals "$message")
    if [ -n "$signals" ]; then
        local signal_count=$(echo "$signals" | tr ',' '\n' | wc -l | tr -d ' ')
        # Higher weight: 10 points per signal
        score=$((score + signal_count * 10))
    fi

    # Code block detection (strong indicator)
    if echo "$message" | grep -qE '```'; then
        score=$((score + 25))
    elif echo "$message" | grep -qE '`[^`]+`'; then
        score=$((score + 10))
    fi

    # File path detection (indicates file operations)
    if echo "$message" | grep -qE '[a-zA-Z0-9_]+\.[a-zA-Z]{2,4}'; then
        score=$((score + 10))
    fi

    # Multiple instruction keywords
    local instruction_count=$(echo "$message" | grep -oEi '\b(create|build|implement|write|develop|make|set up|configure|design|refactor|debug|fix|analyze|review)\b' | wc -l | tr -d ' ')
    if [ "$instruction_count" -gt 2 ]; then
        score=$((score + 15))
    elif [ "$instruction_count" -gt 1 ]; then
        score=$((score + 8))
    fi

    # Question count (multiple questions = more complex)
    local question_count=$(echo "$message" | grep -oE '\?' | wc -l | tr -d ' ')
    if [ "$question_count" -gt 3 ]; then
        score=$((score + 10))
    fi

    # Multi-step indicators (strong signal for complex tasks)
    if echo "$message" | grep -qiE '(step|first|then|next|finally|after|before)'; then
        score=$((score + 15))
    fi

    # Numbered lists (strong indicator of multi-step work)
    local numbered_items=$(echo "$message" | grep -cE '^[0-9]+[.\)]' 2>/dev/null | tr -d ' ' || echo "0")
    numbered_items=$(echo "$numbered_items" | head -1)
    if [ "$numbered_items" -gt 3 ] 2>/dev/null; then
        score=$((score + 20))
    elif [ "$numbered_items" -gt 1 ] 2>/dev/null; then
        score=$((score + 10))
    fi

    echo "$score"
}

function determine_route() {
    local message="$1"
    local force_route="$2"

    # If forced route specified, use it
    if [ -n "$force_route" ]; then
        echo "$force_route"
        return
    fi

    # Calculate complexity
    local complexity=$(calculate_complexity_score "$message")

    # Route based on complexity threshold
    # 30+ = complex enough for native grok with tools
    if [ "$complexity" -ge 30 ]; then
        echo "native"
    else
        echo "bridge"
    fi
}

function format_cost() {
    local cost="$1"
    if [ -z "$cost" ] || [ "$cost" = "0" ]; then
        echo "0.000000"
    else
        printf "%.6f" "$cost"
    fi
}

# ============================================================================
# ROUTING FUNCTIONS
# ============================================================================

function route_to_bridge() {
    local message="$1"
    local model="${2:-grok-4.20-reasoning}"

    echo -e "${CYAN}🌉 Routing to Grok Bridge (fast/simple)${NC}"
    echo ""

    local bridge_start=$(date +%s.%N)
    
    # Start bridge span
    local bridge_span_id=""
    if [ -f "$TRACE_LIB" ] && [ -n "$TRACE_ID" ]; then
        bridge_span_id=$(trace_start_span "bridge-api-call" "grok-bridge" '{"model": "'$model'"}')
    fi

    # Call grok-bridge.sh with trace context
    local response
    local trace_args=""
    if [ -n "$TRACE_ID" ] && [ -n "$bridge_span_id" ]; then
        trace_args="--trace-id $TRACE_ID --parent-span-id $bridge_span_id"
    fi
    
    if ! response=$(bash "$BRIDGE_SCRIPT" $trace_args --model "$model" "$message" 2>&1); then
        echo -e "${RED}❌ Bridge call failed${NC}"
        log_hybrid_event "bridge_error" "bridge" "Bridge script failed"
        if [ -n "$bridge_span_id" ]; then
            trace_end_span "$bridge_span_id" "error"
        fi
        return 1
    fi

    local bridge_end=$(date +%s.%N)
    local response_time=$(echo "$bridge_end - $bridge_start" | bc | awk '{printf "%.2f", $1}')

    # Extract estimated cost from response
    local estimated_cost=$(echo "$response" | grep -oE '\$[0-9.]+' | head -1 | tr -d '$')
    estimated_cost=$(format_cost "$estimated_cost")

    # Log the call
    log_to_bridge_log "$message" "$response" "$model" "$response_time" "bridge" "$estimated_cost"
    log_hybrid_event "bridge_complete" "bridge" "chars=${#message},time=${response_time}s,cost=${estimated_cost}"

    echo "$response"
    return 0
}

function route_to_native() {
    local message="$1"
    local mode="$2"
    
    # Default to single-turn if no mode specified
    if [ -z "$mode" ]; then
        mode="single"
    fi

    echo -e "${MAGENTA}🚀 Routing to Native Grok (full tools)${NC}"
    echo -e "${YELLOW}   Mode: $mode${NC}"
    echo ""

    local native_start=$(date +%s.%N)
    
    # Start native span
    local native_span_id=""
    if [ -f "$TRACE_LIB" ] && [ -n "$TRACE_ID" ]; then
        native_span_id=$(trace_start_span "native-grok-call" "grok-native" '{"mode": "'$mode'"}')
    fi

    # Check if grok CLI is available
    if ! command -v "$NATIVE_GROK" &> /dev/null; then
        echo -e "${RED}❌ Native grok CLI not found${NC}"
        echo -e "${YELLOW}   Falling back to bridge...${NC}"
        log_hybrid_event "native_not_found" "fallback" "Native grok CLI not in PATH"
        if [ -n "$native_span_id" ]; then
            trace_add_event "$native_span_id" "fallback" '{"reason": "cli_not_found"}'
            trace_end_span "$native_span_id" "error"
        fi
        route_to_bridge "$message"
        return $?
    fi

    # Skip auth check - assume authenticated if grok command exists
    # (Auth was completed via 'grok login' earlier)
    log_hybrid_event "native_auth" "native" "Assuming authenticated (previously logged in)"

    local native_end=$(date +%s.%N)
    local response_time=$(echo "$native_end - $native_start" | bc | awk '{printf "%.2f", $1}')

    log_hybrid_event "native_start" "native" "mode=$mode"

    case "$mode" in
        chat)
            # Interactive chat mode - opens TUI
            echo -e "${GREEN}Starting interactive Grok session...${NC}"
            echo -e "${YELLOW}Type 'exit' to quit.${NC}"
            echo ""

            # Launch grok TUI with initial message
            "$NATIVE_GROK" -p "$message" 2>&1 || true
            ;;

        agent)
            # Agent mode with full tool access - opens TUI
            echo -e "${GREEN}Starting Grok agent mode...${NC}"
            echo ""

            # Launch grok TUI
            "$NATIVE_GROK" -p "$message" 2>&1 || true
            ;;

        single|"")
            # Single-turn with -p flag and plain output (non-interactive)
            local response
            response=$("$NATIVE_GROK" -p "$message" --output-format plain 2>&1) || {
                echo -e "${RED}❌ Native grok call failed${NC}"
                log_hybrid_event "native_error" "fallback" "Native call failed"
                if [ -n "$native_span_id" ]; then
                    trace_add_event "$native_span_id" "error" '{"reason": "native_call_failed"}'
                    trace_end_span "$native_span_id" "error"
                fi
                route_to_bridge "$message"
                return $?
            }

            echo "$response"
            ;;

        *)
            echo -e "${RED}❌ Unknown mode: $mode${NC}"
            log_hybrid_event "native_error" "fallback" "Unknown mode: $mode"
            if [ -n "$native_span_id" ]; then
                trace_end_span "$native_span_id" "error"
            fi
            route_to_bridge "$message"
            return 1
            ;;
    esac

    # Estimate cost (native grok doesn't return token counts, so we estimate)
    local estimated_cost="0.000100"  # Base cost estimate

    log_to_bridge_log "$message" "[Native Grok Response - see TUI output]" "grok-build" "$response_time" "native-$mode" "$estimated_cost"
    log_hybrid_event "native_complete" "native" "mode=$mode,time=${response_time}s"
    
    if [ -n "$native_span_id" ]; then
        trace_end_span "$native_span_id" "ok"
    fi

    return 0
}

# ============================================================================
# ANALYSIS FUNCTIONS
# ============================================================================

function analyze_task() {
    local message="$1"

    echo -e "${BLUE}🔍 Analyzing task complexity...${NC}"
    echo ""

    local char_count=${#message}
    local word_count=$(count_words "$message")
    local line_count=$(count_lines "$message")
    local complexity=$(calculate_complexity_score "$message")
    local signals=$(detect_complexity_signals "$message")

    echo "Task Analysis:"
    echo "  Characters: $char_count"
    echo "  Words: $word_count"
    echo "  Lines: $line_count"
    echo "  Complexity Score: $complexity/100"
    echo ""

    if [ -n "$signals" ]; then
        echo "Detected Complexity Signals:"
        echo "  $signals" | tr ',' '\n' | sed 's/^ */  - /'
        echo ""
    fi

    local route=$(determine_route "$message" "")

    echo "Routing Decision:"
    if [ "$route" = "native" ]; then
        echo -e "  ${MAGENTA}→ Native Grok CLI (complex task)${NC}"
    else
        echo -e "  ${CYAN}→ Grok Bridge (simple task)${NC}"
    fi
    echo ""

    log_hybrid_event "analysis" "$route" "score=$complexity,chars=$char_count,words=$word_count"
}

function show_stats() {
    echo -e "${BLUE}📊 Grok Hybrid Statistics${NC}"
    echo ""

    # Bridge stats
    if [ -f "$COST_LOG" ]; then
        echo "Bridge Usage:"
        local bridge_calls=$(grep -c "bridge" "$COST_LOG" 2>/dev/null || echo "0")
        local bridge_cost=$(grep "bridge" "$COST_LOG" 2>/dev/null | jq -s 'map(.estimated_cost) | add' 2>/dev/null || echo "0")
        echo "  Calls: $bridge_calls"
        echo "  Estimated Cost: \$$bridge_cost"
        echo ""
    fi

    # Hybrid routing stats
    if [ -f "$HYBRID_LOG" ]; then
        echo "Routing Decisions:"
        local bridge_routes=$(grep -c '"routing":"bridge"' "$HYBRID_LOG" 2>/dev/null || echo "0")
        local native_routes=$(grep -c '"routing":"native"' "$HYBRID_LOG" 2>/dev/null || echo "0")
        local fallback_routes=$(grep -c '"routing":"fallback"' "$HYBRID_LOG" 2>/dev/null || echo "0")
        echo "  Bridge: $bridge_routes"
        echo "  Native: $native_routes"
        echo "  Fallback: $fallback_routes"
        echo ""
    fi

    # Recent activity
    if [ -f "$LOG_FILE" ]; then
        echo "Recent Activity (last 5 calls):"
        grep -E "^## " "$LOG_FILE" | tail -5 | sed 's/^/  /'
    fi
}

function show_help() {
    cat <<EOF
Grok Hybrid Wrapper - Auto-routing between Bridge and Native CLI

Usage:
  grok-hybrid.sh [OPTIONS] "Your question or task"
  echo "Your question" | grok-hybrid.sh [OPTIONS]

Options:
  --simple          Force route to grok-bridge.sh (fast, stateless)
  --complex         Force route to native grok CLI (full tools)
  --chat            Start interactive chat session with native grok
  --agent           Start agent mode with native grok (TUI)
  --analyze         Analyze task complexity without executing
  --stats           Show usage statistics
  --help            Show this help message

Auto-Detection:
  The script automatically detects task complexity based on:
  - Message length (chars, words, lines)
  - Presence of code blocks or technical terms
  - Multiple questions or complex instructions
  - Keywords indicating multi-step work

Tracing:
  Each request generates a trace ID for distributed tracing.
  View traces with: trace-viewer.sh <trace_id>

Examples:
  # Simple question (auto-routed to bridge)
  grok-hybrid.sh "What is the capital of France?"

  # Complex coding task (auto-routed to native)
  grok-hybrid.sh "Create a Python script to process CSV files"

  # Force simple mode
  grok-hybrid.sh --simple "Quick question"

  # Force complex mode with agent tools
  grok-hybrid.sh --agent "Debug this error and fix the code"

  # Interactive chat
  grok-hybrid.sh --chat "Let's discuss architecture"

Environment:
  WORKSPACE         Base workspace directory (default: ~/.openclaw/workspace)
  BRIDGE_SCRIPT     Path to grok-bridge.sh
  NATIVE_GROK       Native grok CLI command (default: grok)

Logs:
  $LOG_FILE
  $COST_LOG
  $HYBRID_LOG

EOF
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

# Parse arguments
FORCE_ROUTE=""
MODE=""
USER_MESSAGE=""
ACTION="execute"

while [[ $# -gt 0 ]]; do
    case $1 in
        --simple)
            FORCE_ROUTE="bridge"
            shift
            ;;
        --complex)
            FORCE_ROUTE="native"
            MODE=""
            shift
            ;;
        --chat)
            FORCE_ROUTE="native"
            MODE="chat"
            shift
            ;;
        --agent)
            FORCE_ROUTE="native"
            MODE="agent"
            shift
            ;;
        --analyze)
            ACTION="analyze"
            shift
            ;;
        --stats)
            ACTION="stats"
            shift
            ;;
        --help|-h)
            ACTION="help"
            shift
            ;;
        *)
            USER_MESSAGE="$1"
            shift
            ;;
    esac
done

# Handle special actions
if [ "$ACTION" = "help" ]; then
    show_help
    exit 0
fi

if [ "$ACTION" = "stats" ]; then
    show_stats
    exit 0
fi

# If no message provided, check if piped
if [ -z "$USER_MESSAGE" ] && ! [ -t 0 ]; then
    USER_MESSAGE=$(cat)
fi

# Validate input for execute/analyze actions
if [ "$ACTION" != "help" ] && [ "$ACTION" != "stats" ]; then
    if [ -z "$USER_MESSAGE" ]; then
        echo -e "${RED}❌ Error: No message provided${NC}"
        echo ""
        show_help
        exit 1
    fi
fi

# Check if bridge script exists
if [ ! -f "$BRIDGE_SCRIPT" ]; then
    echo -e "${RED}❌ Error: Bridge script not found at $BRIDGE_SCRIPT${NC}"
    exit 1
fi

# Initialize trace for this request
if [ -f "$TRACE_LIB" ]; then
    TRACE_ID=$(trace_init "grok-hybrid-request")
    export SPAN_ID=$(trace_start_span "hybrid-routing" "grok-hybrid" '{"action": "'$ACTION'"}')
fi

# Log startup
log_hybrid_event "startup" "init" "action=$ACTION"

# Execute based on action
case "$ACTION" in
    analyze)
        analyze_task "$USER_MESSAGE"
        if [ -n "$SPAN_ID" ]; then
            trace_end_span "$SPAN_ID" "ok"
            trace_end "completed"
        fi
        ;;

    execute)
        echo -e "${BLUE}🤖 Grok Hybrid Wrapper${NC}"
        if [ -n "$TRACE_ID" ]; then
            echo -e "${CYAN}📊 Trace ID: $TRACE_ID${NC}"
        fi
        echo ""

        # Determine route
        ROUTE=$(determine_route "$USER_MESSAGE" "$FORCE_ROUTE")

        if [ -n "$FORCE_ROUTE" ]; then
            echo -e "${YELLOW}⚡ Forced route: $ROUTE${NC}"
            echo ""
        fi

        # Route to appropriate handler
        if [ "$ROUTE" = "native" ]; then
            route_to_native "$USER_MESSAGE" "$MODE"
        else
            route_to_bridge "$USER_MESSAGE"
        fi
        ;;

    *)
        echo -e "${RED}❌ Unknown action: $ACTION${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Complete${NC}"
if [ -n "$TRACE_ID" ]; then
    echo -e "${CYAN}📊 Trace: trace-viewer.sh $TRACE_ID${NC}"
fi
