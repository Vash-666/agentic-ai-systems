#!/bin/bash
#
# Trace Viewer v1.0
# Visual timeline viewer for distributed traces
# Usage: trace-viewer.sh <trace_id> [--format timeline|json|flame]
#

set -e

# Configuration
WORKSPACE="${WORKSPACE:-$HOME/.openclaw/workspace}"
TRACE_BASE_DIR="${TRACE_BASE_DIR:-$WORKSPACE/traces}"
DEFAULT_FORMAT="timeline"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function show_help() {
    cat <<EOF
Trace Viewer - Visualize distributed traces across the agent ecosystem

Usage:
  trace-viewer.sh <trace_id> [OPTIONS]
  trace-viewer.sh --list [DATE]
  trace-viewer.sh --latest

Options:
  --format FORMAT    Output format: timeline (default), json, flame, tree
  --list [DATE]      List all traces (optionally filter by YYYY-MM-DD)
  --latest           Show the most recent trace
  --stats            Show trace statistics
  --help             Show this help message

Examples:
  trace-viewer.sh abc-123-def-456
  trace-viewer.sh abc-123-def-456 --format flame
  trace-viewer.sh --list 2026-06-08
  trace-viewer.sh --latest --format tree

Formats:
  timeline  Visual timeline with bars showing span durations
  json      Raw JSON output (pretty-printed)
  flame     Flame graph style (ASCII)
  tree      Hierarchical tree view of spans

EOF
}

function error() {
    echo -e "${RED}❌ Error: $1${NC}" >&2
    exit 1
}

function info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# ============================================================================
# TRACE LOOKUP
# ============================================================================

function find_trace_file() {
    local trace_id="$1"
    
    # Search in all date directories
    for date_dir in "$TRACE_BASE_DIR"/*/; do
        if [ -d "$date_dir" ]; then
            local trace_file="${date_dir}${trace_id}.json"
            if [ -f "$trace_file" ]; then
                echo "$trace_file"
                return 0
            fi
        fi
    done
    
    return 1
}

function find_latest_trace() {
    local latest_file=$(find "$TRACE_BASE_DIR" -name "*.json" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
    if [ -n "$latest_file" ]; then
        echo "$latest_file"
        return 0
    fi
    return 1
}

function list_traces() {
    local date_filter="${1:-}"
    
    echo -e "${BOLD}Available Traces:${NC}"
    echo ""
    
    if [ -n "$date_filter" ]; then
        local search_dir="$TRACE_BASE_DIR/$date_filter"
        if [ ! -d "$search_dir" ]; then
            error "No traces found for date: $date_filter"
        fi
        
        echo -e "${CYAN}Date: $date_filter${NC}"
        echo ""
        
        for trace_file in "$search_dir"/*.json; do
            if [ -f "$trace_file" ]; then
                local trace_id=$(basename "$trace_file" .json)
                local trace_time=$(stat -f %Sm -t "%H:%M:%S" "$trace_file" 2>/dev/null || stat -c %y "$trace_file" 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f1)
                local trace_size=$(du -h "$trace_file" | cut -f1)
                echo "  $trace_id  ${GRAY}($trace_time, $trace_size)${NC}"
            fi
        done
    else
        for date_dir in "$TRACE_BASE_DIR"/*/; do
            if [ -d "$date_dir" ]; then
                local date_name=$(basename "$date_dir")
                local count=$(ls -1 "$date_dir"/*.json 2>/dev/null | wc -l)
                
                if [ "$count" -gt 0 ]; then
                    echo -e "${CYAN}$date_name${NC} (${count} traces)"
                    
                    for trace_file in "$date_dir"/*.json; do
                        if [ -f "$trace_file" ]; then
                            local trace_id=$(basename "$trace_file" .json)
                            local trace_time=$(stat -f %Sm -t "%H:%M" "$trace_file" 2>/dev/null || stat -c %y "$trace_file" 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f1 | cut -d: -f1,2)
                            echo "  └─ $trace_id  ${GRAY}($trace_time)${NC}"
                        fi
                    done
                    echo ""
                fi
            fi
        done
    fi
}

# ============================================================================
# FORMAT FUNCTIONS
# ============================================================================

function format_timeline() {
    local trace_file="$1"
    
    python3 <<PYEOF
import json
import sys
from datetime import datetime

def format_duration(ms):
    if ms is None:
        return "in progress"
    if ms < 1:
        return f"{ms*1000:.0f}μs"
    elif ms < 1000:
        return f"{ms:.1f}ms"
    else:
        return f"{ms/1000:.2f}s"

def format_timeline_bar(duration_ms, total_ms, width=40):
    if duration_ms is None or total_ms == 0:
        return "░" * width
    filled = int((duration_ms / total_ms) * width)
    return "█" * filled + "░" * (width - filled)

try:
    with open('$trace_file', 'r') as f:
        trace = json.load(f)
    
    BOLD = '\033[1m'
    NC = '\033[0m'
    CYAN = '\033[0;36m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    RED = '\033[0;31m'
    GRAY = '\033[0;90m'
    
    print(f"\n{BOLD}Trace: {trace['trace_id']}{NC}")
    print(f"Name: {trace.get('trace_name', 'unnamed')}")
    print(f"Status: {trace.get('status', 'unknown')}")
    print(f"Start: {trace['start_time']}")
    if trace.get('end_time'):
        print(f"End: {trace['end_time']}")
        print(f"Total Duration: {format_duration(trace.get('duration_ms'))}")
    else:
        print(f"End: {YELLOW}in progress{NC}")
    print("")
    
    # Calculate total duration for scaling
    total_duration = trace.get('duration_ms', 1000)
    if total_duration is None or total_duration == 0:
        total_duration = 1000
    
    # Build span tree
    spans = trace.get('spans', [])
    span_map = {s['span_id']: s for s in spans}
    
    # Find root spans
    root_spans = [s for s in spans if s.get('parent_span_id') is None]
    
    print(f"{BOLD}Span Timeline:{NC}")
    print(f"{'Service':<15} {'Name':<25} {'Duration':<12} {'Timeline'}")
    print("-" * 100)
    
    def print_span(span, depth=0):
        service = span.get('service', 'unknown')[:14]
        name = span.get('name', 'unnamed')[:24]
        duration = format_duration(span.get('duration_ms'))
        bar = format_timeline_bar(span.get('duration_ms'), total_duration)
        
        indent = "  " * depth
        status_color = GREEN if span.get('status') == 'ok' else YELLOW if span.get('status') == 'in_progress' else RED
        
        print(f"{service:<15} {indent}{name:<25} {duration:<12} {bar}")
        
        # Print events if any
        events = span.get('events', [])
        if events and depth < 2:  # Limit event display for deep nesting
            for event in events[:3]:  # Show max 3 events
                event_name = event.get('name', 'event')
                event_time = event.get('timestamp', '')[11:19]  # HH:MM:SS
                print(f"{'':<15} {indent}  {GRAY}└─ {event_name} at {event_time}{NC}")
        
        # Find and print children
        children = [s for s in spans if s.get('parent_span_id') == span['span_id']]
        for child in sorted(children, key=lambda x: x['start_time']):
            print_span(child, depth + 1)
    
    for root in sorted(root_spans, key=lambda x: x['start_time']):
        print_span(root)
    
    print("")
    print(f"{BOLD}Summary:{NC}")
    print(f"  Total Spans: {len(spans)}")
    print(f"  Services: {len(set(s.get('service', 'unknown') for s in spans))}")
    
    # Count by status
    status_counts = {}
    for s in spans:
        status = s.get('status', 'unknown')
        status_counts[status] = status_counts.get(status, 0) + 1
    
    print(f"  Status: ", end="")
    for status, count in status_counts.items():
        color = GREEN if status == 'ok' else YELLOW if status == 'in_progress' else RED
        print(f"{color}{status}={count}{NC} ", end="", flush=True)
    print("")
    
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

function format_json() {
    local trace_file="$1"
    python3 -m json.tool "$trace_file"
}

function format_flame() {
    local trace_file="$1"
    
    python3 <<PYEOF
import json
import sys

def format_flame_graph(trace_file):
    with open(trace_file, 'r') as f:
        trace = json.load(f)
    
    spans = trace.get('spans', [])
    span_map = {s['span_id']: s for s in spans}
    
    # Build tree
    def get_children(span_id):
        return [s for s in spans if s.get('parent_span_id') == span_id]
    
    def print_flame(span, depth=0, prefix=""):
        name = span.get('name', 'unnamed')
        service = span.get('service', 'unknown')
        duration = span.get('duration_ms', 0)
        span_status = span.get('status', 'unknown')
        
        # Color based on status
        if span_status == 'ok':
            color = '\033[42m'  # Green bg
        elif span_status == 'in_progress':
            color = '\033[43m'  # Yellow bg
        else:
            color = '\033[41m'  # Red bg
        
        # Width based on duration (log scale)
        if duration:
            width = max(10, int(50 + (duration / 100) * 10))
        else:
            width = 20
        
        text = f"{service}.{name}"
        padded = text[:width].ljust(width)
        
        indent = "  " * depth
        print(f"{indent}{color}{padded}\033[0m {duration:.1f}ms")
        
        # Print children
        children = get_children(span['span_id'])
        for child in sorted(children, key=lambda x: x.get('duration_ms', 0), reverse=True):
            print_flame(child, depth + 1)
    
    BOLD = '\033[1m'
    NC = '\033[0m'
    
    print(f"\n{BOLD}Flame Graph: {trace['trace_id']}{NC}\n")
    
    # Find root spans
    root_spans = [s for s in spans if s.get('parent_span_id') is None]
    for root in root_spans:
        print_flame(root)
    
    print("\nLegend: \033[42m OK \033[0m \033[43m In Progress \033[0m \033[41m Error \033[0m")

try:
    format_flame_graph('$trace_file')
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

function format_tree() {
    local trace_file="$1"
    
    python3 <<PYEOF
import json
import sys

def format_tree(trace_file):
    with open(trace_file, 'r') as f:
        trace = json.load(f)
    
    spans = trace.get('spans', [])
    
    def get_children(span_id):
        return [s for s in spans if s.get('parent_span_id') == span_id]
    
    def format_duration(ms):
        if ms is None:
            return "⏳"
        if ms < 1:
            return f"{ms*1000:.0f}μs"
        elif ms < 1000:
            return f"{ms:.1f}ms"
        else:
            return f"{ms/1000:.2f}s"
    
    BOLD = '\033[1m'
    NC = '\033[0m'
    CYAN = '\033[0;36m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    RED = '\033[0;31m'
    GRAY = '\033[0;90m'
    
    def print_tree(span, prefix="", is_last=True):
        name = span.get('name', 'unnamed')
        service = span.get('service', 'unknown')
        duration = format_duration(span.get('duration_ms'))
        span_status = span.get('status', 'unknown')
        span_id = span.get('span_id', '')[:8]
        
        # Status indicator
        if span_status == 'ok':
            indicator = f"{GREEN}✓{NC}"
        elif span_status == 'in_progress':
            indicator = f"{YELLOW}⟳{NC}"
        else:
            indicator = f"{RED}✗{NC}"
        
        # Tree connectors
        connector = "└── " if is_last else "├── "
        
        print(f"{prefix}{connector}{indicator} {CYAN}{service}{NC}.{name} {GRAY}({duration}) [{span_id}...]{NC}")
        
        # Print children
        children = get_children(span['span_id'])
        child_prefix = prefix + ("    " if is_last else "│   ")
        
        for i, child in enumerate(sorted(children, key=lambda x: x['start_time'])):
            is_last_child = (i == len(children) - 1)
            print_tree(child, child_prefix, is_last_child)
    
    print(f"\n{BOLD}Trace Tree: {trace['trace_id']}{NC}")
    print(f"Name: {trace.get('trace_name', 'unnamed')}")
    print(f"Status: {trace.get('status', 'unknown')}")
    print("")
    
    # Find and print root spans
    root_spans = [s for s in spans if s.get('parent_span_id') is None]
    for root in root_spans:
        print_tree(root, "", True)
    
    print("")

try:
    format_tree('$trace_file')
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

function show_stats() {
    echo -e "${BOLD}Trace Statistics${NC}\n"
    
    local total_traces=0
    local total_size=0
    
    for date_dir in "$TRACE_BASE_DIR"/*/; do
        if [ -d "$date_dir" ]; then
            local date_name=$(basename "$date_dir")
            local count=$(ls -1 "$date_dir"/*.json 2>/dev/null | wc -l)
            local size=$(du -sh "$date_dir" 2>/dev/null | cut -f1)
            
            total_traces=$((total_traces + count))
            
            echo "  $date_name: $count traces ($size)"
        fi
    done
    
    echo ""
    echo "  Total: $total_traces traces"
    
    # Show trace directory size
    if [ -d "$TRACE_BASE_DIR" ]; then
        local total_dir_size=$(du -sh "$TRACE_BASE_DIR" 2>/dev/null | cut -f1)
        echo "  Storage: $total_dir_size"
    fi
}

# ============================================================================
# MAIN
# ============================================================================

# Parse arguments
TRACE_ID=""
FORMAT="$DEFAULT_FORMAT"
ACTION="view"

while [[ $# -gt 0 ]]; do
    case $1 in
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --list)
            ACTION="list"
            if [[ $# -gt 1 && ! "$2" =~ ^-- ]]; then
                DATE_FILTER="$2"
                shift 2
            else
                shift
            fi
            ;;
        --latest)
            ACTION="latest"
            shift
            ;;
        --stats)
            ACTION="stats"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        -*)
            error "Unknown option: $1"
            ;;
        *)
            TRACE_ID="$1"
            shift
            ;;
    esac
done

# Execute action
case "$ACTION" in
    list)
        list_traces "${DATE_FILTER:-}"
        ;;
    
    stats)
        show_stats
        ;;
    
    latest)
        TRACE_FILE=$(find_latest_trace) || error "No traces found"
        TRACE_ID=$(basename "$TRACE_FILE" .json)
        info "Showing latest trace: $TRACE_ID"
        
        case "$FORMAT" in
            json)
                format_json "$TRACE_FILE"
                ;;
            flame)
                format_flame "$TRACE_FILE"
                ;;
            tree)
                format_tree "$TRACE_FILE"
                ;;
            timeline|*)
                format_timeline "$TRACE_FILE"
                ;;
        esac
        ;;
    
    view)
        if [ -z "$TRACE_ID" ]; then
            show_help
            exit 1
        fi
        
        TRACE_FILE=$(find_trace_file "$TRACE_ID") || error "Trace not found: $TRACE_ID"
        
        case "$FORMAT" in
            json)
                format_json "$TRACE_FILE"
                ;;
            flame)
                format_flame "$TRACE_FILE"
                ;;
            tree)
                format_tree "$TRACE_FILE"
                ;;
            timeline|*)
                format_timeline "$TRACE_FILE"
                ;;
        esac
        ;;
esac
