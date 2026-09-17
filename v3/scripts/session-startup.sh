#!/bin/bash
# session-startup.sh — Automated v3.0 Session Initialization
# Version: 3.0
# Usage: ./session-startup.sh [agent_name]

set -e

V3_DIR="/Users/rohitvashist/.openclaw/workspace/v3"
AGENT="${1:-switch}"

echo "========================================"
echo "  v3.0 Session Startup"
echo "  Agent: @$AGENT"
echo "  Time: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "========================================"
echo ""

# Step 1: Core Consciousness
echo "[1/6] Loading core consciousness..."
cat "$V3_DIR/core/SOUL.md" > /dev/null && echo "  ✓ SOUL.md"
cat "$V3_DIR/core/HANDOFF.md" > /dev/null && echo "  ✓ HANDOFF.md"
cat "$V3_DIR/core/QUALITY.md" > /dev/null && echo "  ✓ QUALITY.md"
cat "$V3_DIR/core/MEMORY.md" > /dev/null && echo "  ✓ MEMORY.md"

# Step 2: Agent Identity
echo ""
echo "[2/6] Loading agent identity..."
if [ -f "$V3_DIR/agents/$AGENT/AGENT.md" ]; then
    cat "$V3_DIR/agents/$AGENT/AGENT.md" > /dev/null && echo "  ✓ agents/$AGENT/AGENT.md"
else
    echo "  ✗ Agent '$AGENT' not found. Available agents:"
    ls "$V3_DIR/agents/" | sed 's/^/    - /'
    exit 1
fi

# Step 3: User Context
echo ""
echo "[3/6] Loading user context..."
cat "$V3_DIR/memory/USER.md" > /dev/null && echo "  ✓ memory/USER.md"

# Step 4: Session Context
echo ""
echo "[4/6] Loading session context..."
if [ -f "$V3_DIR/memory/SESSION-CONTEXT.md" ]; then
    cat "$V3_DIR/memory/SESSION-CONTEXT.md" > /dev/null && echo "  ✓ memory/SESSION-CONTEXT.md"
else
    echo "  ⚠ SESSION-CONTEXT.md not found (will be created)"
fi

# Step 5: Recent Memory
echo ""
echo "[5/6] Loading recent memory..."
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)

if [ -f "$V3_DIR/memory/daily/$TODAY.md" ]; then
    cat "$V3_DIR/memory/daily/$TODAY.md" > /dev/null && echo "  ✓ memory/daily/$TODAY.md"
else
    echo "  ⚠ No daily log for today"
fi

if [ -f "$V3_DIR/memory/daily/$YESTERDAY.md" ]; then
    cat "$V3_DIR/memory/daily/$YESTERDAY.md" > /dev/null && echo "  ✓ memory/daily/$YESTERDAY.md"
else
    echo "  ⚠ No daily log for yesterday"
fi

# Step 6: Strategic Memory (main sessions only)
echo ""
echo "[6/6] Loading strategic memory..."
cat "$V3_DIR/memory/STRATEGIC.md" > /dev/null && echo "  ✓ memory/STRATEGIC.md"

echo ""
echo "========================================"
echo "  Session startup complete"
echo "  Status: READY"
echo "========================================"
