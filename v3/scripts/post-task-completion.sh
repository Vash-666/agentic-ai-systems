#!/bin/bash
# post-task-completion.sh — Trigger fact extraction after agent task completes
# Version: 3.1
# Usage: ./post-task-completion.sh <agent_name> <task_id> <task_status> [output_file]

set -e

# Resolve V3_DIR from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V3_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

AGENT="$1"
TASK_ID="$2"
TASK_STATUS="${3:-completed}"
OUTPUT_FILE="$4"

if [ -z "$AGENT" ] || [ -z "$TASK_ID" ]; then
    echo "Usage: ./post-task-completion.sh <agent_name> <task_id> [task_status] [output_file]"
    echo "  task_status: completed (default) | failed"
    exit 1
fi

echo "========================================"
echo "  Post-Task Completion"
echo "  Agent: @$AGENT"
echo "  Task: $TASK_ID"
echo "  Status: $TASK_STATUS"
echo "========================================"

# Read task output if file provided
TASK_OUTPUT=""
if [ -n "$OUTPUT_FILE" ] && [ -f "$OUTPUT_FILE" ]; then
    TASK_OUTPUT=$(cat "$OUTPUT_FILE")
    echo "✓ Loaded task output from $OUTPUT_FILE"
elif [ -n "$OUTPUT_FILE" ]; then
    echo "⚠ Output file not found: $OUTPUT_FILE"
fi

# Also check for task output in state
STATE_FILE="$V3_DIR/state/current.json"
if [ -f "$STATE_FILE" ] && [ -z "$TASK_OUTPUT" ]; then
    TASK_OUTPUT=$(python3 -c "
import json
try:
    with open('$STATE_FILE') as f:
        state = json.load(f)
    for task in state.get('tasks', []):
        if task.get('id') == '$TASK_ID':
            print(task.get('output', task.get('result', '')))
            break
except:
    pass
" 2>/dev/null)
fi

# Trigger Auto Fact Extractor v2
FACT_EXTRACTOR_PY="$V3_DIR/scripts/implementations/04-fact-extractor-v2.py"
if [ -f "$FACT_EXTRACTOR_PY" ]; then
    echo ""
    echo "Triggering Auto Fact Extractor v2..."
    
    python3 -c "
import sys, importlib.util, os
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = importlib.util.spec_from_file_location('fact_extractor', '$FACT_EXTRACTOR_PY')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)

# Get output text
task_output = '''$TASK_OUTPUT'''
if not task_output.strip():
    task_output = 'Task $TASK_ID completed by @$AGENT with status: $TASK_STATUS'

result = mod.trigger_after_task('$AGENT', task_output, task_id='$TASK_ID', task_status='$TASK_STATUS')

print(f'  ✓ Fact extraction complete')
print(f'    Facts extracted: {result[\"facts_extracted\"]}')
print(f'    Avg confidence: {result.get(\"avg_confidence\", 0)}')
print(f'    Task status: {result[\"task_status\"]}')
if result.get('error'):
    print(f'    Error: {result[\"error\"]}')
" 2>/dev/null || echo "  ⚠ Fact extraction failed"
else
    echo "  ⚠ Fact extractor module not found"
fi

# Update task status in state with reducers
echo ""
echo "Updating task status in state..."
REDUCERS_PY="$V3_DIR/scripts/implementations/02-reducers.py"
if [ -f "$REDUCERS_PY" ] && [ -f "$STATE_FILE" ]; then
    python3 -c "
import json, sys
from datetime import datetime

REDUCERS_PY = '$V3_DIR/scripts/implementations/02-reducers.py'

try:
    with open('$STATE_FILE') as f:
        existing = json.load(f)
    
    delta = {
        'tasks': [{
            'id': '$TASK_ID',
            'status': '$TASK_STATUS',
            'completed_at': datetime.utcnow().isoformat(),
            '_priority': 'agent_output'
        }]
    }
    
    try:
        import importlib.util
        spec = importlib.util.spec_from_file_location('reducers', REDUCERS_PY)
        reducers_mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(reducers_mod)
        merged = reducers_mod.reduce_state(existing, delta)
        reducers_loaded = True
    except Exception:
        merged = existing.copy()
        for task in merged.get('tasks', []):
            if task.get('id') == '$TASK_ID':
                task['status'] = '$TASK_STATUS'
                task['completed_at'] = datetime.utcnow().isoformat()
        reducers_loaded = False
    
    merged['last_updated'] = datetime.utcnow().isoformat()
    
    with open('$STATE_FILE', 'w') as f:
        json.dump(merged, f, indent=2)
    
    if reducers_loaded:
        print('  ✓ Task status updated with reducers')
    else:
        print('  ✓ Task status updated')
except Exception as e:
    print(f'  ⚠ State update warning: {e}')
" 2>/dev/null || echo "  ⚠ State update skipped"
fi

# Check ARC compaction after task completion
echo ""
echo "Checking ARC compaction..."
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
    print(f'    Savings: {result.get(\"savings_bytes\", 0)} bytes')
elif result.get('action') == 'none':
    print(f'  ✓ Context size healthy')
else:
    print(f'  ℹ ARC: {result.get(\"reason\", \"unknown\")}')
" 2>/dev/null || echo "  ⚠ ARC check skipped"
fi

echo ""
echo "========================================"
echo "  Post-task completion finished"
echo "========================================"
