#!/bin/bash
# validate-system.sh — Prevent documentation drift
# Version: 3.1.1
# Usage: ./validate-system.sh [--strict]

set -euo pipefail

V3_DIR="$(cd "$(dirname "$0")/.." && pwd)"
STRICT=${1:-""}
ERRORS=0

echo "========================================"
echo "  System Validation v3.1.1"
echo "========================================"

# 1. Verify agents on disk match state.json
echo ""
echo "[1/5] Agent Filesystem Check..."
STATE_AGENTS=$(python3 -c "
import json
with open('$V3_DIR/state/current.json') as f:
    data = json.load(f)
print(' '.join(data.get('agents', {}).keys()))
" 2>/dev/null || echo "")

DISK_AGENTS=$(ls -1 "$V3_DIR/agents/" | sort | tr '\n' ' ')

for agent in $STATE_AGENTS; do
    if [ ! -d "$V3_DIR/agents/$agent" ]; then
        echo "  ❌ Agent '$agent' in state.json but missing from disk"
        ((ERRORS++))
    else
        echo "  ✅ $agent"
    fi
done

for agent in $(ls -1 "$V3_DIR/agents/"); do
    if ! echo "$STATE_AGENTS" | grep -qw "$agent"; then
        echo "  ⚠️  Agent '$agent' on disk but not in state.json"
    fi
done

# 2. Verify RELEASE-v3.1.md claims match reality
echo ""
echo "[2/5] RELEASE Document Check..."
if [ -f "$V3_DIR/RELEASE-v3.1.md" ]; then
    CLAIMED=$(grep -oE '@[a-zA-Z0-9_]+' "$V3_DIR/RELEASE-v3.1.md" | sort -u | grep -v switch | grep -v quality || true)
    for agent in $CLAIMED; do
        agent_name=${agent#@}
        if [ ! -d "$V3_DIR/agents/$agent_name" ]; then
            echo "  ❌ RELEASE claims $agent but not on disk"
            ((ERRORS++))
        else
            echo "  ✅ $agent verified"
        fi
    done
else
    echo "  ⚠️  RELEASE-v3.1.md not found"
fi

# 3. Verify README claims
echo ""
echo "[3/5] README Check..."
if [ -f "$V3_DIR/../README.md" ]; then
    README_CLAIMED=$(grep -oE '@[a-zA-Z0-9_]+' "$V3_DIR/../README.md" | sort -u | grep -v switch | grep -v quality || true)
    for agent in $README_CLAIMED; do
        agent_name=${agent#@}
        if [ ! -d "$V3_DIR/agents/$agent_name" ]; then
            echo "  ❌ README claims $agent but not on disk"
            ((ERRORS++))
        else
            echo "  ✅ $agent verified"
        fi
    done
else
    echo "  ⚠️  README.md not found"
fi

# 4. Verify checkpoint counts
echo ""
echo "[4/5] Checkpoint Count Check..."
if [ -f "$V3_DIR/state/state.db" ]; then
    ACTUAL=$(sqlite3 "$V3_DIR/state/state.db" "SELECT COUNT(*) FROM checkpoints;" 2>/dev/null || echo "0")
    # Extract claimed from RELEASE
    CLAIMED=$(grep -oP '\d+(?=\s+checkpoints)' "$V3_DIR/RELEASE-v3.1.md" 2>/dev/null || echo "0")
    if [ "$CLAIMED" != "0" ] && [ "$ACTUAL" != "$CLAIMED" ]; then
        echo "  ⚠️  Claimed $CLAIMED checkpoints, found $ACTUAL"
        [ "$STRICT" = "--strict" ] && ((ERRORS++))
    else
        echo "  ✅ Checkpoints: $ACTUAL"
    fi
else
    echo "  ⚠️  state.db not found"
fi

# 5. Verify AGENT-ROSTER.md if exists
echo ""
echo "[5/5] Roster Check..."
if [ -f "$V3_DIR/AGENT-ROSTER.md" ]; then
    ROSTER_AGENTS=$(grep -oE '@[a-zA-Z0-9_]+' "$V3_DIR/AGENT-ROSTER.md" | sort -u || true)
    for agent in $ROSTER_AGENTS; do
        agent_name=${agent#@}
        if [ ! -d "$V3_DIR/agents/$agent_name" ]; then
            echo "  ❌ ROSTER claims $agent but not on disk"
            ((ERRORS++))
        else
            echo "  ✅ $agent verified"
        fi
    done
else
    echo "  ⚠️  AGENT-ROSTER.md not found (optional)"
fi

# Summary
echo ""
echo "========================================"
if [ $ERRORS -eq 0 ]; then
    echo "  ✅ VALIDATION PASSED"
    echo "========================================"
    exit 0
else
    echo "  ❌ VALIDATION FAILED: $ERRORS error(s)"
    echo "========================================"
    exit 1
fi
