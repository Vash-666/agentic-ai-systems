#!/bin/bash
# spawn-with-context.sh — Auto-context injection for agent spawns with distributed tracing
# Usage: ./spawn-with-context.sh <agent_id> <task_description> [optional: fork]
#
# Environment variables for tracing:
#   TRACE_ID - Existing trace ID to continue (auto-generated if not set)
#   TRACE_SPAN_ID - Parent span ID for nested calls
#

set -e

AGENT_ID="$1"
TASK="$2"
FORK_MODE="${3:-}"

WORKSPACE="/Users/rohitvashist/.openclaw/workspace"
AGENT_DIR="$WORKSPACE/agents"
TOOLS_DIR="$WORKSPACE/tools"
TRACE_LIB="$TOOLS_DIR/trace-lib.sh"

# Source trace library if available
if [ -f "$TRACE_LIB" ]; then
    source "$TRACE_LIB"
fi

# Validate inputs
if [ -z "$AGENT_ID" ] || [ -z "$TASK" ]; then
    echo "Usage: ./spawn-with-context.sh <agent_id> <task_description> [fork]"
    echo "Example: ./spawn-with-context.sh content 'Write a LinkedIn post about agentic AI'"
    echo ""
    echo "Tracing:"
    echo "  Set TRACE_ID to continue an existing trace"
    echo "  Set TRACE_SPAN_ID to specify parent span"
    exit 1
fi

# Initialize or continue trace
SPAWN_TRACE_ID=""
SPAWN_SPAN_ID=""
if [ -f "$TRACE_LIB" ]; then
    if [ -z "$TRACE_ID" ]; then
        # Create new trace for this spawn
        SPAWN_TRACE_ID=$(trace_init "agent-spawn-$AGENT_ID")
        SPAWN_SPAN_ID=$(trace_start_span "spawn-preparation" "spawn-context" '{"agent_id": "'$AGENT_ID'"}')
    else
        # Continue existing trace
        SPAWN_TRACE_ID="$TRACE_ID"
        export TRACE_ID="$SPAWN_TRACE_ID"
        export TRACE_SPAN_ID="${TRACE_SPAN_ID:-}"
        export TRACE_FILE=$(trace_get_file "$SPAWN_TRACE_ID")
        SPAWN_SPAN_ID=$(trace_start_span "spawn-preparation" "spawn-context" '{"agent_id": "'$AGENT_ID'", "continued": true}')
    fi
fi

# Read context files
MISSION_CONTEXT=""
if [ -f "$WORKSPACE/MISSION-CONTEXT.md" ]; then
    MISSION_CONTEXT=$(cat "$WORKSPACE/MISSION-CONTEXT.md")
fi

SOUL=""
if [ -f "$WORKSPACE/SOUL.md" ]; then
    SOUL=$(cat "$WORKSPACE/SOUL.md")
fi

USER_CTX=""
if [ -f "$WORKSPACE/USER.md" ]; then
    USER_CTX=$(cat "$WORKSPACE/USER.md")
fi

# Get agent brief from agent-directory.json
AGENT_BRIEF=""
if [ -f "$WORKSPACE/agent-directory.json" ]; then
    AGENT_BRIEF=$(python3 -c "
import json
import sys
try:
    with open('$WORKSPACE/agent-directory.json') as f:
        data = json.load(f)
    agent = data.get('agents', {}).get('$AGENT_ID', {})
    print(f\"Role: {agent.get('role', 'N/A')}\")
    print(f\"Description: {agent.get('description', 'N/A')}\")
    print(f\"Skills: {', '.join(agent.get('skills', []))}\")
    print(f\"Quality: {agent.get('quality', 'N/A')}/10\")
except Exception as e:
    print(f'Error: {e}')
    sys.exit(1)
" 2>/dev/null || echo "Agent: $AGENT_ID")
fi

# Get preferred model
PREFERRED_MODEL=""
if [ -f "$WORKSPACE/agent-directory.json" ]; then
    PREFERRED_MODEL=$(python3 -c "
import json
try:
    with open('$WORKSPACE/agent-directory.json') as f:
        data = json.load(f)
    agent = data.get('agents', {}).get('$AGENT_ID', {})
    print(agent.get('preferred_model', agent.get('model', 'moonshot/kimi-k2.5')))
except:
    print('moonshot/kimi-k2.5')
" 2>/dev/null || echo "moonshot/kimi-k2.5")
fi

# Add trace context to task
TRACE_CONTEXT=""
if [ -n "$SPAWN_TRACE_ID" ]; then
    TRACE_CONTEXT="
=== DISTRIBUTED TRACE CONTEXT ===
Trace ID: $SPAWN_TRACE_ID
Parent Span ID: ${SPAWN_SPAN_ID:-root}
Spawn Time: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

The child agent should propagate this trace ID in any API calls or sub-spawns.
"
fi

# Build the full context
FULL_TASK="[AUTO-SPAWN] Method: direct_route

=== THE BIGGER PICTURE ===
$MISSION_CONTEXT

=== WHO YOU ARE ===
$SOUL

=== WHO YOU'RE HELPING ===
$USER_CTX

=== YOUR ROLE ===
$AGENT_BRIEF

=== YOUR TASK ===
$TASK
$TRACE_CONTEXT

=== REMEMBER ===
- You're not just doing a task — you're contributing to agentic AI mastery
- Quality Equation: 65% Prompts + 20% Memory + 10% Model + 5% Tools
- Target: ≥9.0/10 quality, replicable, teachable
- Ask: Does this move us toward the mission?

Handoff: inline"

# End the preparation span
if [ -n "$SPAWN_SPAN_ID" ]; then
    trace_add_attribute "$SPAWN_SPAN_ID" "agent_id" "$AGENT_ID"
    trace_add_attribute "$SPAWN_SPAN_ID" "model" "$PREFERRED_MODEL"
    trace_add_attribute "$SPAWN_SPAN_ID" "task_length" "${#TASK}"
    trace_end_span "$SPAWN_SPAN_ID" "ok"
    
    # Start a span for the actual spawn (will remain open until child completes)
    trace_start_span "agent-execution-$AGENT_ID" "$AGENT_ID" '{"status": "spawned"}' > /dev/null
    trace_end "in_progress"
fi

# Output the spawn command
echo "=== SPAWN COMMAND ==="
echo ""
echo "Agent: $AGENT_ID"
echo "Model: $PREFERRED_MODEL"
if [ -n "$SPAWN_TRACE_ID" ]; then
    echo "Trace ID: $SPAWN_TRACE_ID"
fi
echo ""
echo "sessions_spawn("
echo "    agentId=\"$AGENT_ID\","
echo "    model=\"$PREFERRED_MODEL\","
if [ "$FORK_MODE" = "fork" ]; then
    echo "    context=\"fork\","
fi
if [ -n "$SPAWN_TRACE_ID" ]; then
    echo "    # Trace context for distributed tracing"
    echo "    # TRACE_ID=$SPAWN_TRACE_ID"
fi
echo "    task=\"\"\"$FULL_TASK\"\"\""
echo ")"
echo ""
echo "=== CONTEXT SUMMARY ==="
echo "- Mission Context: $(echo "$MISSION_CONTEXT" | wc -l) lines"
echo "- Soul: $(echo "$SOUL" | wc -l) lines"
echo "- User Context: $(echo "$USER_CTX" | wc -l) lines"
echo "- Agent Brief: $(echo "$AGENT_BRIEF" | wc -l) lines"
echo "- Task: $(echo "$TASK" | wc -l) lines"
echo "- Total: $(echo "$FULL_TASK" | wc -l) lines"
if [ -n "$SPAWN_TRACE_ID" ]; then
    echo "- Trace ID: $SPAWN_TRACE_ID"
    echo ""
    echo "View trace: trace-viewer.sh $SPAWN_TRACE_ID"
fi
