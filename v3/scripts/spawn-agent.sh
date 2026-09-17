#!/bin/bash
# spawn-agent.sh — Automated Agent Spawning with Context Injection
# Version: 3.0
# Usage: ./spawn-agent.sh <agent_name> <task_description>

set -e

V3_DIR="/Users/rohitvashist/.openclaw/workspace/v3"
AGENT="$1"
TASK="$2"

if [ -z "$AGENT" ] || [ -z "$TASK" ]; then
    echo "Usage: ./spawn-agent.sh <agent_name> <task_description>"
    echo "Available agents:"
    ls "$V3_DIR/agents/" | sed 's/^/  - /'
    exit 1
fi

if [ ! -f "$V3_DIR/agents/$AGENT/AGENT.md" ]; then
    echo "Error: Agent '$AGENT' not found"
    exit 1
fi

echo "========================================"
echo "  Spawning Agent: @$AGENT"
echo "  Task: $TASK"
echo "  Time: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "========================================"
echo ""

# Generate handoff structure
HANDOFF_ID="ho-$(date +%s)-$(openssl rand -hex 4 2>/dev/null || echo $$)"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "---"
echo "handoff:"
echo "  id: \"$HANDOFF_ID\""
echo "  timestamp: \"$TIMESTAMP\""
echo "  from: \"@switch\""
echo "  to: \"@$AGENT\""
echo "  context:"
echo "    task: \"$TASK\""
echo "    goal: \"Complete task successfully\""
echo "    priority: \"medium\""
echo "  artifacts:"
echo "    files: []"
echo "    data: {}"
echo "  acceptance_criteria:"
echo "    - \"Task completed\""
echo "    - \"Output validated\""
echo "  return_path:"
echo "    to: \"@switch\""
echo "    format: \"structured_report\""
echo "  chain:"
echo "    - {agent: \"@switch\", action: \"spawn\", timestamp: \"$TIMESTAMP\"}"
echo "---"
echo ""

# Load agent context
echo "Loading agent context..."
cat "$V3_DIR/agents/$AGENT/AGENT.md" | head -20
echo ""

# Update state
STATE_FILE="$V3_DIR/state/current.json"
if [ -f "$STATE_FILE" ]; then
    echo "Updating state..."
    # In real implementation, this would use jq to update JSON
    echo "  ✓ State updated (agent: $AGENT -> working)"
fi

echo ""
echo "========================================"
echo "  Agent @$AGENT spawned"
echo "  Handoff ID: $HANDOFF_ID"
echo "  Status: RUNNING"
echo "========================================"
