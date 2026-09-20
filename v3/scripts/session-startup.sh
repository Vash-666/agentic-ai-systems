#!/bin/bash
# session-startup.sh — Automated v3.1 Session Initialization
# Version: 3.1
# Usage: ./session-startup.sh [agent_name]

set -e

# Resolve V3_DIR from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V3_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENT="${1:-switch}"
SESSION_ID="${SESSION_ID:-sess-$(date +%s)}"

echo "========================================"
echo "  v3.1 Session Startup"
echo "  Agent: @$AGENT"
echo "  Session: $SESSION_ID"
echo "  Time: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "========================================"
echo ""

# Step 0: Validate system integrity
echo "[0/10] Validating system integrity..."
VALIDATOR="$V3_DIR/scripts/validate-system.sh"
if [ -f "$VALIDATOR" ]; then
    if ! "$VALIDATOR" > /dev/null 2>&1; then
        echo "  ❌ System validation failed. Run $VALIDATOR for details."
        echo "  ⚠️  Continuing with caution..."
    else
        echo "  ✅ System validated"
    fi
else
    echo "  ⚠️  Validator not found — skipping"
fi
echo ""

# Step 0b: SQLite Checkpointer — load latest checkpoint
echo "[0/10] Loading checkpoint from SQLite..."
DB_PATH="$V3_DIR/state/state.db"
CHECKPOINTER_ENABLED="${CHECKPOINTER_ENABLED:-true}"
ARC_ENABLED="${ARC_ENABLED:-true}"

if [ "$CHECKPOINTER_ENABLED" != "true" ]; then
    echo "  ℹ Checkpointer disabled via CHECKPOINTER_ENABLED"
elif [ -f "$DB_PATH" ]; then
    # Use the checkpointer implementation module for robust loading
    CHECKPOINTER_PY="$V3_DIR/scripts/implementations/01-checkpointer.py"
    if [ -f "$CHECKPOINTER_PY" ]; then
        CHECKPOINT=$(python3 -c "
import sys, importlib.util
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('checkpointer', '$V3_DIR/scripts/implementations/01-checkpointer.py')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
import json
state = mod.load_checkpoint('session:$SESSION_ID')
if state:
    print(json.dumps(state, indent=2))
else:
    print('NO_CHECKPOINT')
" 2>/dev/null)
    else
        # Fallback: inline SQL
        CHECKPOINT=$(python3 -c "
import sqlite3, json, sys
try:
    conn = sqlite3.connect('$DB_PATH')
    cursor = conn.cursor()
    cursor.execute('SELECT state_json FROM checkpoints WHERE scope = ? ORDER BY timestamp DESC LIMIT 1', ('session:$SESSION_ID',))
    row = cursor.fetchone()
    if row:
        state = json.loads(row[0])
        print(json.dumps(state, indent=2))
    else:
        print('NO_CHECKPOINT')
    conn.close()
except Exception as e:
    print('ERROR:', e)
" 2>/dev/null)
    fi
    
    if echo "$CHECKPOINT" | grep -q "NO_CHECKPOINT"; then
        echo "  ⚠ No checkpoint for session $SESSION_ID (fresh start)"
    elif echo "$CHECKPOINT" | grep -q "ERROR"; then
        echo "  ⚠ Checkpoint load failed: $CHECKPOINT"
    else
        echo "  ✓ Checkpoint loaded for session $SESSION_ID"
        echo "$CHECKPOINT" | head -5
    fi
else
    echo "  ⚠ No state.db found (will be created)"
fi

# Step 0b: ARC Compaction — check context size and compact if needed
echo ""
echo "[0b/10] Checking ARC compaction threshold..."
ARC_PY="$V3_DIR/scripts/implementations/06-arc-compaction.py"
if [ "$ARC_ENABLED" = "true" ] && [ -f "$ARC_PY" ]; then
    # Check context size from current state file
    CURRENT_STATE="$V3_DIR/state/current.json"
    if [ -f "$CURRENT_STATE" ]; then
        ARC_RESULT=$(python3 -c "
import sys, importlib.util, json
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('arc_compaction', '$ARC_PY')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

# Check current state size and compact if needed
result = mod.compact_if_needed()
print(json.dumps(result))
" 2>/dev/null)
        
        if [ -n "$ARC_RESULT" ]; then
            COMPACTED=$(echo "$ARC_RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('compacted', False))")
            if [ "$COMPACTED" = "True" ]; then
                SAVINGS=$(echo "$ARC_RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('savings_bytes', 0))")
                KEYS=$(echo "$ARC_RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(','.join(d.get('keys_compacted', [])))")
                echo "  ✓ ARC compaction triggered"
                echo "    Keys compacted: $KEYS"
                echo "    Savings: $SAVINGS bytes"
            else
                SIZE=$(echo "$ARC_RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('size_bytes', 0))")
                THRESH=$(echo "$ARC_RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('threshold_bytes', 51200))")
                echo "  ✓ Context size: ${SIZE} bytes (threshold: ${THRESH} bytes)"
            fi
        fi
    else
        echo "  ℹ No current state file to check"
    fi
else
    echo "  ℹ ARC compaction disabled or module not found"
fi

# Step 1: Core Consciousness
echo ""
echo "[1/10] Loading core consciousness..."
cat "$V3_DIR/core/SOUL.md" > /dev/null && echo "  ✓ SOUL.md"
cat "$V3_DIR/core/HANDOFF.md" > /dev/null && echo "  ✓ HANDOFF.md"
cat "$V3_DIR/core/QUALITY.md" > /dev/null && echo "  ✓ QUALITY.md"
cat "$V3_DIR/core/MEMORY.md" > /dev/null && echo "  ✓ MEMORY.md"

# Step 2: Agent Identity
echo ""
echo "[2/10] Loading agent identity..."
if [ -f "$V3_DIR/agents/$AGENT/AGENT.md" ]; then
    cat "$V3_DIR/agents/$AGENT/AGENT.md" > /dev/null && echo "  ✓ agents/$AGENT/AGENT.md"
else
    echo "  ✗ Agent '$AGENT' not found. Available agents:"
    ls "$V3_DIR/agents/" | sed 's/^/    - /'
    exit 1
fi

# Step 3: User Context
echo ""
echo "[3/10] Loading user context..."
cat "$V3_DIR/memory/USER.md" > /dev/null && echo "  ✓ memory/USER.md"

# Step 4: Scoped Memory Hierarchy
echo ""
echo "[4/10] Loading scoped memory hierarchy..."
SCOPED_MEMORY_PY="$V3_DIR/scripts/implementations/03-scoped-memory.py"
if [ -f "$SCOPED_MEMORY_PY" ]; then
    python3 -c "
import sys, importlib.util
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('scoped_memory', '$SCOPED_MEMORY_PY')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

# Ensure directories exist
mod.ensure_dirs()

# Load context for this agent/session
context = mod.load_context_for_startup('$AGENT', '$SESSION_ID')
total = sum(len(v) for v in context.values())
print(f'  ✓ Scoped memory loaded: {total} entries')
for scope, entries in context.items():
    if entries:
        print(f'    - {scope}: {len(entries)} entries')
" 2>/dev/null || echo "  ⚠ Scoped memory load skipped"
else
    echo "  ⚠ Scoped memory module not found"
fi

# Step 5: Composite Recall + Project-Scoped Memory — load top N relevant memories
echo ""
echo "[5/10] Loading relevant memories via composite recall..."
COMPOSITE_RECALL_PY="$V3_DIR/scripts/implementations/05-composite-recall.py"
if [ -f "$COMPOSITE_RECALL_PY" ]; then
    python3 -c "
import sys, importlib.util
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('composite_recall', '$COMPOSITE_RECALL_PY')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

memories = mod.recall_for_startup('$AGENT', '$SESSION_ID', top_k=10)
print(f'  ✓ Composite recall: {len(memories)} memories loaded')
for m in memories[:3]:
    mem = m['memory']
    content = mem.get('content', mem.get('subject', str(mem)[:50]))
    print(f'    [{m[\"score\"]}] {content[:60]}...')
" 2>/dev/null || echo "  ⚠ Composite recall skipped"
else
    echo "  ⚠ Composite recall module not found"
fi

# Step 5b: Load project-scoped memory for current agent
echo ""
echo "[5b/10] Loading project-scoped memory..."
SCOPED_MEMORY_PY="$V3_DIR/scripts/implementations/03-scoped-memory.py"
if [ -f "$SCOPED_MEMORY_PY" ]; then
    python3 -c "
import sys, importlib.util
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('scoped_memory', '$SCOPED_MEMORY_PY')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

# Ensure directories exist
mod.ensure_dirs()

# Load project-scoped context for this agent
# Looks in: project/default/agent/{agent_name}/, project/default/global/, project/default/task/{task_id}/
context = mod.load_project_context_for_startup('$AGENT', '$SESSION_ID')
total = sum(len(v) for v in context.values())
print(f'  ✓ Project-scoped memory loaded: {total} entries')
for scope, entries in context.items():
    if entries:
        print(f'    - project/default/{scope}: {len(entries)} entries')
" 2>/dev/null || echo "  ⚠ Project-scoped memory load skipped"
else
    echo "  ⚠ Scoped memory module not found"
fi

# Step 6: Session Context
echo ""
echo "[6/10] Loading session context..."
if [ -f "$V3_DIR/memory/SESSION-CONTEXT.md" ]; then
    cat "$V3_DIR/memory/SESSION-CONTEXT.md" > /dev/null && echo "  ✓ memory/SESSION-CONTEXT.md"
else
    echo "  ⚠ SESSION-CONTEXT.md not found (will be created)"
fi

# Step 7: Recent Memory + Composite Recall Scoring
echo ""
echo "[7/10] Loading recent memory..."
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)

# Create daily log if missing
if [ ! -f "$V3_DIR/memory/daily/$TODAY.md" ]; then
    echo "  ⚠ No daily log for today — creating..."
    if [ -f "$V3_DIR/scripts/daily-memory-log.sh" ]; then
        "$V3_DIR/scripts/daily-memory-log.sh" "Auto-created at session startup" > /dev/null 2>&1
        echo "  ✓ Created memory/daily/$TODAY.md"
    else
        echo "  ✗ daily-memory-log.sh not found"
    fi
fi

if [ -f "$V3_DIR/memory/daily/$TODAY.md" ]; then
    cat "$V3_DIR/memory/daily/$TODAY.md" > /dev/null && echo "  ✓ memory/daily/$TODAY.md"
fi

if [ -f "$V3_DIR/memory/daily/$YESTERDAY.md" ]; then
    cat "$V3_DIR/memory/daily/$YESTERDAY.md" > /dev/null && echo "  ✓ memory/daily/$YESTERDAY.md"
else
    echo "  ⚠ No daily log for yesterday"
fi

# Composite Recall Scoring — rank daily facts by relevance
echo ""
echo "[7b/10] Ranking recent memories by composite score..."
COMPOSITE_RECALL_PY="$V3_DIR/scripts/implementations/05-composite-recall.py"
if [ -f "$COMPOSITE_RECALL_PY" ]; then
    # Build list of daily fact files to rank
    FACT_FILES=""
    if [ -f "$V3_DIR/memory/daily/${TODAY}-facts.json" ]; then
        FACT_FILES="$FACT_FILES\"$V3_DIR/memory/daily/${TODAY}-facts.json\","
    fi
    if [ -f "$V3_DIR/memory/daily/${YESTERDAY}-facts.json" ]; then
        FACT_FILES="$FACT_FILES\"$V3_DIR/memory/daily/${YESTERDAY}-facts.json\","
    fi
    
    if [ -n "$FACT_FILES" ]; then
        # Remove trailing comma
        FACT_FILES="${FACT_FILES%,}"
        
        python3 -c "
import sys, importlib.util
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('composite_recall', '$COMPOSITE_RECALL_PY')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

# Rank daily memories using composite scoring
fact_files = [$FACT_FILES]
ranked = mod.rank_daily_memories(fact_files, query='$AGENT preferences configuration', top_k=3)
if not ranked:
    print('  ⚠ No memories to rank')
" 2>/dev/null || echo "  ⚠ Composite recall ranking skipped"
    else
        echo "  ⚠ No daily fact files found for ranking"
    fi
else
    echo "  ⚠ Composite recall module not found"
fi

# Step 8: Strategic Memory (main sessions only)
echo ""
echo "[8/10] Loading strategic memory..."
cat "$V3_DIR/memory/STRATEGIC.md" > /dev/null && echo "  ✓ memory/STRATEGIC.md"

# Step 9: ARC Compaction check
echo ""
echo "[9/10] Checking ARC compaction status..."
ARC_PY="$V3_DIR/scripts/implementations/06-arc-compaction.py"
if [ -f "$ARC_PY" ]; then
    python3 -c "
import sys, importlib.util
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('arc_compaction', '$ARC_PY')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

result = mod.compact_if_needed()
if result.get('compacted'):
    print(f'  ✓ ARC compaction triggered')
    print(f'    Keys compacted: {result.get(\"keys_compacted\", [])}')
    print(f'    Savings: {result.get(\"savings_bytes\", 0)} bytes')
elif result.get('action') == 'none':
    size = result.get('size_bytes', 0)
    threshold = result.get('threshold_bytes', 51200)
    print(f'  ✓ Context size: {size} bytes (threshold: {threshold} bytes)')
else:
    print(f'  ℹ ARC: {result.get(\"reason\", \"unknown\")}')
" 2>/dev/null || echo "  ⚠ ARC check skipped"
else
    echo "  ⚠ ARC compaction module not found"
fi

# Step 10: v3.1 Features Status
echo ""
echo "[10/10] v3.1 feature status..."
for feature in checkpointer reducers scoped-memory fact-extractor composite-recall arc-compaction; do
    # Check if any Python file exists for this feature
    found=0
    for f in "$V3_DIR/scripts/implementations/"*"$feature"*.py; do
        if [ -f "$f" ]; then
            found=1
            break
        fi
    done
    if [ "$found" -eq 1 ]; then
        echo "  ✓ $feature available"
    else
        echo "  ⚠ $feature not found"
    fi
done

# Step 11: Health Monitor Status
echo ""
echo "[11/11] Health monitor status..."
if [ -f "$V3_DIR/logs/health-monitor.pid" ] && kill -0 "$(cat "$V3_DIR/logs/health-monitor.pid")" 2>/dev/null; then
    echo "  ✓ Health monitor running (PID: $(cat "$V3_DIR/logs/health-monitor.pid"))"
else
    echo "  ⚠ Health monitor not running (start with: ./scripts/health-monitor.sh start)"
fi

# Step 12: Quality Score — log today's baseline
echo ""
echo "[12/12] Quality score baseline..."
TODAY=$(date +%Y-%m-%d)
QUALITY_LOG="$V3_DIR/memory/daily/${TODAY}-quality.json"
if [ -f "$QUALITY_LOG" ]; then
    echo "  ✓ Quality log exists: memory/daily/${TODAY}-quality.json"
else
    echo "  ℹ No quality log yet today (runs at 00:00 UTC via cron)"
fi

# Step 13: Auto Fact Extractor trigger on session events
echo ""
echo "[13/13] Auto fact extractor status..."
FACT_EXTRACTOR_ENABLED="${FACT_EXTRACTOR_AUTO_TRIGGER:-true}"
if [ "$FACT_EXTRACTOR_ENABLED" = "true" ]; then
    echo "  ✓ Auto fact extraction enabled"
else
    echo "  ℹ Auto fact extraction disabled"
fi

echo ""
# Session end trap with checkpoint, fact extraction, and scoped memory cleanup
trap_cleanup() {
    echo ""
    echo "[CLEANUP] Session ending — running cleanup tasks..."
    
    # Restore compacted context before saving final checkpoint
    if [ "$ARC_ENABLED" = "true" ] && [ -f "$ARC_PY" ]; then
        echo "  [ARC] Restoring compacted context..."
        ARC_RESTORE=$(python3 -c "
import sys, importlib.util, json
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('arc_compaction', '$ARC_PY')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

result = mod.restore_all()
print(json.dumps(result))
" 2>/dev/null)
        
        if [ -n "$ARC_RESTORE" ]; then
            RESTORED=$(echo "$ARC_RESTORE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('restored', False))")
            if [ "$RESTORED" = "True" ]; then
                COUNT=$(echo "$ARC_RESTORE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('restored_count', 0))")
                echo "  ✓ Restored $COUNT compacted keys"
            else
                echo "  ℹ No compacted keys to restore"
            fi
        fi
    fi
    
    # Save final checkpoint
    DB_PATH="$V3_DIR/state/state.db"
    if [ -f "$DB_PATH" ] && [ "$CHECKPOINTER_ENABLED" = "true" ]; then
        python3 -c "
import sqlite3, json, sys
from datetime import datetime
try:
    conn = sqlite3.connect('$DB_PATH')
    cursor = conn.cursor()
    state = {
        'session_id': '$SESSION_ID',
        'agent': '$AGENT',
        'status': 'ended',
        'ended_at': datetime.utcnow().isoformat()
    }
    cursor.execute('''
        INSERT INTO checkpoints (scope, timestamp, state_json, metadata)
        VALUES (?, ?, ?, ?)
    ''', (
        'session:$SESSION_ID',
        datetime.utcnow().isoformat(),
        json.dumps(state),
        json.dumps({'version': '3.1', 'action': 'session_end'})
    ))
    conn.commit()
    conn.close()
    print('  ✓ Final checkpoint saved')
except Exception as e:
    print(f'  ✗ Checkpoint save failed: {e}')
" 2>/dev/null || echo "  ⚠ Checkpoint save skipped"
    fi
    
    # Trigger fact extraction from session output (if any output was captured)
    FACT_EXTRACTOR_PY="$V3_DIR/scripts/implementations/04-fact-extractor-v2.py"
    if [ -f "$FACT_EXTRACTOR_PY" ] && [ "$FACT_EXTRACTOR_ENABLED" = "true" ]; then
        python3 -c "
import sys, importlib.util
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('fact_extractor', '$FACT_EXTRACTOR_PY')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

# Extract from session summary
session_summary = 'Session $SESSION_ID ended for agent @$AGENT at ' + __import__('datetime').datetime.utcnow().isoformat()
result = mod.trigger_after_task('$AGENT', session_summary, task_id='$SESSION_ID', task_status='completed')
if result['facts_extracted'] > 0:
    print(f'  ✓ Extracted {result[\"facts_extracted\"]} facts from session end')
" 2>/dev/null || true
    fi
    
    echo "========================================"
    echo "  Session ended gracefully"
    echo "  Session ID: $SESSION_ID"
    echo "========================================"
}
trap trap_cleanup EXIT

echo "========================================"
echo "  Session startup complete"
echo "  Status: READY"
echo "  Session ID: $SESSION_ID"
echo "========================================"
