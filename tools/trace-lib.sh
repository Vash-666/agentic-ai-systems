#!/bin/bash
#
# Trace Library v1.0
# Distributed tracing utilities for OpenClaw agent ecosystem
# Source this file to use trace functions in other scripts
#

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

TRACE_BASE_DIR="${TRACE_BASE_DIR:-$HOME/.openclaw/workspace/traces}"
TRACE_ENABLED="${TRACE_ENABLED:-true}"
TRACE_VERSION="1.0"

# Colors for output (optional)
TRACE_COLOR_ENABLED="${TRACE_COLOR_ENABLED:-true}"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Generate a unique trace ID (UUID v4 style)
function trace_generate_id() {
    local uuid=$(uuidgen 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())" 2>/dev/null || echo "$(date +%s%N)-$$-$RANDOM")
    echo "$uuid"
}

# Generate a short span ID (8 hex chars)
function trace_generate_span_id() {
    local span_id=$(openssl rand -hex 4 2>/dev/null || python3 -c "import secrets; print(secrets.token_hex(4))" 2>/dev/null || echo "$(date +%s%N | md5 | head -c 8)")
    echo "$span_id"
}

# Get current timestamp in ISO 8601 format
function trace_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%S.000Z"
}

# Get current timestamp in seconds (for duration calculation)
function trace_timestamp_sec() {
    date +%s.%N
}

# Ensure trace directory exists
function trace_ensure_dir() {
    local date_dir=$(date +%Y-%m-%d)
    local trace_dir="$TRACE_BASE_DIR/$date_dir"
    mkdir -p "$trace_dir"
    echo "$trace_dir"
}

# ============================================================================
# CORE TRACE FUNCTIONS
# ============================================================================

# Initialize a new trace
# Usage: trace_init <trace_name> [parent_trace_id] [parent_span_id]
# Returns: trace_id
function trace_init() {
    local trace_name="${1:-unnamed-trace}"
    local parent_trace_id="${2:-}"
    local parent_span_id="${3:-}"
    
    if [ "$TRACE_ENABLED" != "true" ]; then
        echo ""
        return 0
    fi
    
    local trace_id=$(trace_generate_id)
    local root_span_id=$(trace_generate_span_id)
    local timestamp=$(trace_timestamp)
    local trace_dir=$(trace_ensure_dir)
    
    # Create initial trace structure
    local trace_file="$trace_dir/${trace_id}.json"
    
    cat > "$trace_file" <<EOF
{
  "trace_id": "$trace_id",
  "trace_name": "$trace_name",
  "version": "$TRACE_VERSION",
  "start_time": "$timestamp",
  "end_time": null,
  "duration_ms": null,
  "status": "in_progress",
  "parent_trace_id": "$parent_trace_id",
  "root_span_id": "$root_span_id",
  "spans": [
    {
      "span_id": "$root_span_id",
      "parent_span_id": null,
      "name": "root",
      "service": "openclaw",
      "start_time": "$timestamp",
      "end_time": null,
      "duration_ms": null,
      "status": "in_progress",
      "attributes": {
        "trace_name": "$trace_name",
        "initiator": "${USER:-unknown}",
        "hostname": "$(hostname)",
        "pid": $$,
        "parent_trace_id": "$parent_trace_id",
        "parent_span_id": "$parent_span_id"
      },
      "events": [
        {
          "timestamp": "$timestamp",
          "name": "trace_init",
          "attributes": {
            "message": "Trace initialized"
          }
        }
      ]
    }
  ],
  "metadata": {
    "created_by": "${USER:-unknown}",
    "hostname": "$(hostname)",
    "platform": "$(uname -s)",
    "trace_lib_version": "$TRACE_VERSION"
  }
}
EOF
    
    # Store current trace context in environment for child processes
    export TRACE_ID="$trace_id"
    export TRACE_SPAN_ID="$root_span_id"
    export TRACE_FILE="$trace_file"
    
    # Output the trace ID
    echo "$trace_id"
}

# Initialize a new trace and output export statements for parent shell
# Usage: eval $(trace_init_export "trace_name" [parent_trace_id] [parent_span_id])
function trace_init_export() {
    # Generate trace data
    local trace_name="${1:-unnamed-trace}"
    local parent_trace_id="${2:-}"
    local parent_span_id="${3:-}"
    
    local trace_id=$(trace_generate_id)
    local root_span_id=$(trace_generate_span_id)
    local timestamp=$(trace_timestamp)
    local trace_dir=$(trace_ensure_dir)
    local trace_file="$trace_dir/${trace_id}.json"
    
    # Create trace file
    cat > "$trace_file" <<EOF
{
  "trace_id": "$trace_id",
  "trace_name": "$trace_name",
  "version": "$TRACE_VERSION",
  "start_time": "$timestamp",
  "end_time": null,
  "duration_ms": null,
  "status": "in_progress",
  "parent_trace_id": "$parent_trace_id",
  "root_span_id": "$root_span_id",
  "spans": [
    {
      "span_id": "$root_span_id",
      "parent_span_id": null,
      "name": "root",
      "service": "openclaw",
      "start_time": "$timestamp",
      "end_time": null,
      "duration_ms": null,
      "status": "in_progress",
      "attributes": {
        "trace_name": "$trace_name",
        "initiator": "${USER:-unknown}",
        "hostname": "$(hostname)",
        "pid": $$,
        "parent_trace_id": "$parent_trace_id",
        "parent_span_id": "$parent_span_id"
      },
      "events": [
        {
          "timestamp": "$timestamp",
          "name": "trace_init",
          "attributes": {
            "message": "Trace initialized"
          }
        }
      ]
    }
  ],
  "metadata": {
    "created_by": "${USER:-unknown}",
    "hostname": "$(hostname)",
    "platform": "$(uname -s)",
    "trace_lib_version": "$TRACE_VERSION"
  }
}
EOF
    
    # Output export statements
    echo "export TRACE_ID='$trace_id'"
    echo "export TRACE_SPAN_ID='$root_span_id'"
    echo "export TRACE_FILE='$trace_file'"
}

# Start a new span within the current trace
# Usage: trace_start_span <span_name> [service_name] [attributes_json]
# Returns: span_id
function trace_start_span() {
    local span_name="${1:-unnamed-span}"
    local service_name="${2:-openclaw}"
    local attributes="${3:-}"
    if [ -z "$attributes" ]; then
        attributes="{}"
    fi
    local parent_span_id="${TRACE_SPAN_ID:-}"
    
    if [ "$TRACE_ENABLED" != "true" ] || [ -z "$TRACE_FILE" ] || [ ! -f "$TRACE_FILE" ]; then
        echo ""
        return 0
    fi
    
    local span_id=$(trace_generate_span_id)
    local timestamp=$(trace_timestamp)
    
    # Create span JSON (no leading whitespace for valid JSON)
    local span_json=$(cat <<EOF
{
  "span_id": "$span_id",
  "parent_span_id": "$parent_span_id",
  "name": "$span_name",
  "service": "$service_name",
  "start_time": "$timestamp",
  "end_time": null,
  "duration_ms": null,
  "status": "in_progress",
  "attributes": $attributes,
  "events": [
    {
      "timestamp": "$timestamp",
      "name": "span_start",
      "attributes": {
        "message": "Span started"
      }
    }
  ]
}
EOF
)
    
    # Add span to trace file using Python for JSON manipulation
    python3 <<PYEOF
import json
import sys

try:
    with open('$TRACE_FILE', 'r') as f:
        trace = json.load(f)
    
    span = json.loads('''$span_json''')
    trace['spans'].append(span)
    
    with open('$TRACE_FILE', 'w') as f:
        json.dump(trace, f, indent=2)
    
    sys.exit(0)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
PYEOF
    
    # Update current span context
    export TRACE_SPAN_ID="$span_id"
    
    # Output the span_id
    echo "$span_id"
}

# End a span
# Usage: trace_end_span [span_id] [status] [attributes_json]
function trace_end_span() {
    local span_id="${1:-$TRACE_SPAN_ID}"
    local span_status="${2:-ok}"
    local attributes="${3:-}"
    if [ -z "$attributes" ]; then
        attributes="{}"
    fi
    
    if [ "$TRACE_ENABLED" != "true" ] || [ -z "$TRACE_FILE" ] || [ ! -f "$TRACE_FILE" ]; then
        return 0
    fi
    
    local timestamp=$(trace_timestamp)
    
    python3 <<PYEOF
import json
import sys
from datetime import datetime

try:
    with open('$TRACE_FILE', 'r') as f:
        trace = json.load(f)
    
    # Find and update the span
    for span in trace['spans']:
        if span['span_id'] == '$span_id':
            span['end_time'] = '$timestamp'
            span['status'] = '$span_status'
            
            # Calculate duration
            start = datetime.fromisoformat(span['start_time'].replace('Z', '+00:00'))
            end = datetime.fromisoformat('$timestamp'.replace('Z', '+00:00'))
            duration_ms = (end - start).total_seconds() * 1000
            span['duration_ms'] = round(duration_ms, 3)
            
            # Add end event
            span['events'].append({
                "timestamp": "$timestamp",
                "name": "span_end",
                "attributes": {
                    "message": "Span ended",
                    "status": "$span_status",
                    **json.loads('$attributes')
                }
            })
            break
    
    with open('$TRACE_FILE', 'w') as f:
        json.dump(trace, f, indent=2)
    
    sys.exit(0)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

# End the entire trace
# Usage: trace_end [status] [attributes_json]
function trace_end() {
    local trace_status="${1:-completed}"
    local attributes="${2:-{}}"
    
    if [ "$TRACE_ENABLED" != "true" ] || [ -z "$TRACE_FILE" ] || [ ! -f "$TRACE_FILE" ]; then
        return 0
    fi
    
    local timestamp=$(trace_timestamp)
    
    python3 <<PYEOF
import json
import sys
from datetime import datetime

try:
    with open('$TRACE_FILE', 'r') as f:
        trace = json.load(f)
    
    # Update trace end time and status
    trace['end_time'] = '$timestamp'
    trace['status'] = '$trace_status'
    
    # Calculate total duration from root span
    root_span = None
    for span in trace['spans']:
        if span['span_id'] == trace['root_span_id']:
            root_span = span
            break
    
    if root_span:
        start = datetime.fromisoformat(root_span['start_time'].replace('Z', '+00:00'))
        end = datetime.fromisoformat('$timestamp'.replace('Z', '+00:00'))
        duration_ms = (end - start).total_seconds() * 1000
        trace['duration_ms'] = round(duration_ms, 3)
        
        # End root span too
        root_span['end_time'] = '$timestamp'
        root_span['status'] = '$trace_status'
        start_root = datetime.fromisoformat(root_span['start_time'].replace('Z', '+00:00'))
        root_span['duration_ms'] = round((end - start_root).total_seconds() * 1000, 3)
    
    # Add completion event
    trace['metadata']['completed_at'] = '$timestamp'
    trace['metadata']['final_status'] = '$trace_status'
    
    with open('$TRACE_FILE', 'w') as f:
        json.dump(trace, f, indent=2)
    
    sys.exit(0)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
PYEOF
    
    # Clear trace context
    unset TRACE_ID
    unset TRACE_SPAN_ID
    unset TRACE_FILE
}

# Add an event to a span
# Usage: trace_add_event <span_id> <event_name> [attributes_json]
function trace_add_event() {
    local span_id="${1:-$TRACE_SPAN_ID}"
    local event_name="${2:-event}"
    local attributes="${3:-}"
    if [ -z "$attributes" ]; then
        attributes="{}"
    fi
    
    if [ "$TRACE_ENABLED" != "true" ] || [ -z "$TRACE_FILE" ] || [ ! -f "$TRACE_FILE" ]; then
        return 0
    fi
    
    local timestamp=$(trace_timestamp)
    
    python3 <<PYEOF
import json
import sys

try:
    with open('$TRACE_FILE', 'r') as f:
        trace = json.load(f)
    
    # Find the span and add event
    for span in trace['spans']:
        if span['span_id'] == '$span_id':
            span['events'].append({
                "timestamp": "$timestamp",
                "name": "$event_name",
                "attributes": json.loads('''$attributes''')
            })
            break
    
    with open('$TRACE_FILE', 'w') as f:
        json.dump(trace, f, indent=2)
    
    sys.exit(0)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

# Add an attribute to a span
# Usage: trace_add_attribute <span_id> <key> <value>
function trace_add_attribute() {
    local span_id="${1:-$TRACE_SPAN_ID}"
    local key="$2"
    local value="$3"
    
    if [ "$TRACE_ENABLED" != "true" ] || [ -z "$TRACE_FILE" ] || [ ! -f "$TRACE_FILE" ]; then
        return 0
    fi
    
    python3 <<PYEOF
import json
import sys

try:
    with open('$TRACE_FILE', 'r') as f:
        trace = json.load(f)
    
    # Find the span and add attribute
    for span in trace['spans']:
        if span['span_id'] == '$span_id':
            span['attributes']['$key'] = '$value'
            break
    
    with open('$TRACE_FILE', 'w') as f:
        json.dump(trace, f, indent=2)
    
    sys.exit(0)
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

# ============================================================================
# TRACE HEADERS FOR CROSS-SERVICE PROPAGATION
# ============================================================================

# Generate trace context headers for HTTP/API calls
# Usage: trace_get_headers
# Output: JSON string with trace headers
function trace_get_headers() {
    local trace_id="${TRACE_ID:-}"
    local span_id="${TRACE_SPAN_ID:-}"
    
    if [ -z "$trace_id" ]; then
        echo "{}"
        return 0
    fi
    
    cat <<EOF
{
  "X-Trace-ID": "$trace_id",
  "X-Span-ID": "$span_id",
  "X-Trace-Version": "$TRACE_VERSION"
}
EOF
}

# Parse trace headers from environment or input
# Usage: trace_parse_headers <headers_json>
function trace_parse_headers() {
    local headers="${1:-{}}"
    
    python3 <<PYEOF
import json
import sys

try:
    headers = json.loads('''$headers''')
    trace_id = headers.get('X-Trace-ID', '')
    span_id = headers.get('X-Span-ID', '')
    
    if trace_id:
        print(f"export TRACE_ID={trace_id}")
    if span_id:
        print(f"export TRACE_SPAN_ID={span_id}")
    
    sys.exit(0)
except Exception as e:
    print(f"# Error parsing headers: {e}")
    sys.exit(0)
PYEOF
}

# Export trace context for child processes
# Usage: trace_export_context
function trace_export_context() {
    if [ -n "$TRACE_ID" ]; then
        echo "export TRACE_ID='$TRACE_ID'"
        echo "export TRACE_SPAN_ID='$TRACE_SPAN_ID'"
        echo "export TRACE_FILE='$TRACE_FILE'"
        echo "export TRACE_ENABLED='$TRACE_ENABLED'"
    fi
}

# ============================================================================
# TRACE QUERY FUNCTIONS
# ============================================================================

# Get trace file path by trace ID
# Usage: trace_get_file <trace_id>
function trace_get_file() {
    local trace_id="$1"
    
    if [ -z "$trace_id" ]; then
        echo ""
        return 1
    fi
    
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
    
    echo ""
    return 1
}

# List all traces
# Usage: trace_list [date_filter]
function trace_list() {
    local date_filter="${1:-}"
    
    if [ -n "$date_filter" ]; then
        local search_dir="$TRACE_BASE_DIR/$date_filter"
        if [ -d "$search_dir" ]; then
            ls -1 "$search_dir"/*.json 2>/dev/null | while read f; do
                basename "$f" .json
            done
        fi
    else
        find "$TRACE_BASE_DIR" -name "*.json" -type f 2>/dev/null | while read f; do
            basename "$f" .json
        done
    fi
}

# ============================================================================
# UTILITY EXPORTS
# ============================================================================

# Export functions for use in other scripts
export -f trace_generate_id
export -f trace_generate_span_id
export -f trace_timestamp
export -f trace_timestamp_sec
export -f trace_ensure_dir
export -f trace_init
export -f trace_start_span
export -f trace_end_span
export -f trace_end
export -f trace_add_event
export -f trace_add_attribute
export -f trace_get_headers
export -f trace_parse_headers
export -f trace_export_context
export -f trace_get_file
export -f trace_list
