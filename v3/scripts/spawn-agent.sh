#!/bin/bash
# spawn-agent.sh — Automated Agent Spawning with Context Injection
# Version: 3.1
# Usage: ./spawn-agent.sh <agent_name> <task_description>

set -e

# Resolve V3_DIR from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V3_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

AGENT="$1"
TASK="$2"
SESSION_ID="${SESSION_ID:-sess-$(date +%s)}"

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
echo "  Session: $SESSION_ID"
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

# Write SQLite checkpoint and merge state with reducers
DB_PATH="$V3_DIR/state/state.db"
CHECKPOINTER_ENABLED="${CHECKPOINTER_ENABLED:-true}"

echo "Writing checkpoint to SQLite..."

if [ "$CHECKPOINTER_ENABLED" != "true" ]; then
    echo "  ℹ Checkpointer disabled via CHECKPOINTER_ENABLED"
elif [ -f "$DB_PATH" ] || [ -d "$V3_DIR/state" ]; then
    # Use reducers implementation for SQLite-aware merge
    REDUCERS_PY="$V3_DIR/scripts/implementations/02-reducers.py"
    if [ -f "$REDUCERS_PY" ]; then
        python3 -c "
import sys, importlib.util
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('reducers', '$REDUCERS_PY')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
from datetime import datetime

# Build delta for this agent spawn
delta = {
    'agents': {
        '$AGENT': {
            'status': 'working',
            'currentTask': '$TASK',
            'last_update': datetime.utcnow().isoformat(),
            '_priority': 'agent_output'
        }
    },
    'tasks': [{
        'id': 'task-${HANDOFF_ID}',
        'description': '$TASK',
        'status': 'in_progress',
        'assignee': '@$AGENT',
        'handoff_id': '$HANDOFF_ID',
        '_priority': 'agent_output'
    }]
}

# Load from SQLite, merge with reducers, save back to SQLite
merged = mod.merge_and_save_sqlite(delta, scope='global')
cp_id = merged.get('_checkpoint_id')
print(f'  ✓ Checkpoint saved to SQLite (id: {cp_id})')
print(f'  ✓ State merged with reducers (agent: $AGENT -> working)')
print(f'    Tasks: {len(merged.get(\"tasks\", []))}')
print(f'    Agents: {list(merged.get(\"agents\", {}).keys())}')
" 2>/dev/null
    else
        # Fallback: inline SQL (no reducer merge)
        python3 -c "
import sqlite3, json, sys
from datetime import datetime

try:
    conn = sqlite3.connect('$DB_PATH')
    cursor = conn.cursor()

    # Ensure table exists
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS checkpoints (
            checkpoint_id INTEGER PRIMARY KEY AUTOINCREMENT,
            scope TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            state_json TEXT NOT NULL,
            parent_id INTEGER,
            metadata TEXT
        )
    ''')

    state = {
        'session_id': '$SESSION_ID',
        'agent': '$AGENT',
        'task': '$TASK',
        'handoff_id': '$HANDOFF_ID',
        'status': 'spawned',
        'timestamp': '$TIMESTAMP'
    }

    cursor.execute('''
        INSERT INTO checkpoints (scope, timestamp, state_json, metadata)
        VALUES (?, ?, ?, ?)
    ''', (
        'session:$SESSION_ID',
        datetime.utcnow().isoformat(),
        json.dumps(state),
        json.dumps({'version': '3.1', 'action': 'spawn'})
    ))

    conn.commit()
    conn.close()
    print('  ✓ Checkpoint saved to SQLite')
except Exception as e:
    print(f'  ✗ Checkpoint failed: {e}')
    sys.exit(1)
" 2>/dev/null || echo "  ⚠ SQLite checkpoint skipped (Python/SQLite unavailable)"
    fi
else
    echo "  ⚠ No state.db found (will be created on first use)"
fi

# Load scoped memory for agent context
echo ""
echo "Loading scoped memory context..."
SCOPED_MEMORY_PY="$V3_DIR/scripts/implementations/03-scoped-memory.py"
if [ -f "$SCOPED_MEMORY_PY" ]; then
    python3 -c "
import sys, importlib.util
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('scoped_memory', '$SCOPED_MEMORY_PY')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

context = mod.load_context_for_startup('$AGENT', '$SESSION_ID', '$HANDOFF_ID')
total = sum(len(v) for v in context.values())
print(f'  ✓ Scoped memory loaded: {total} entries')
for scope, entries in context.items():
    if entries:
        print(f'    - {scope}: {len(entries)} entries')
" 2>/dev/null || echo "  ⚠ Scoped memory load skipped"
else
    echo "  ⚠ Scoped memory module not found"
fi

# Load agent context
echo ""
echo "Loading agent context..."
cat "$V3_DIR/agents/$AGENT/AGENT.md" | head -20
echo ""

# Check if ARC compaction is needed after state update
echo ""
echo "Checking context size for ARC compaction..."
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
    print(f'    Compression: {result.get(\"compression_ratio\", 1)}x')
elif result.get('action') == 'none':
    print(f'  ✓ Context size healthy ({result.get(\"size_bytes\", 0)} bytes)')
else:
    print(f'  ℹ ARC status: {result.get(\"reason\", \"unknown\")}')
" 2>/dev/null || echo "  ⚠ ARC check skipped"
else
    echo "  ⚠ ARC compaction module not found"
fi

echo ""
echo "========================================"
echo "  Agent @$AGENT spawned"
echo "  Handoff ID: $HANDOFF_ID"
echo "  Session ID: $SESSION_ID"
echo "  Status: RUNNING"
echo "========================================"
