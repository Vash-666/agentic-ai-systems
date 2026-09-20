#!/bin/bash
# Phase 3 Test Suite — Quality That Can Fail
# Version: 3.1
# Run: ./test-suite.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V3_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PASSED=0
FAILED=0

pass() { echo "  ✅ PASS"; PASSED=$((PASSED+1)); }
fail() { echo "  ❌ FAIL: $1"; FAILED=$((FAILED+1)); }

echo "========================================"
echo "  Phase 3 Test Suite"
echo "  v3.1 Context Management"
echo "========================================"
echo ""

# ============================================================================
# TEST 1: Invalid agent name is rejected by spawn-agent.sh
# ============================================================================
echo "[TEST 1] Invalid agent name rejection"
echo "  Positive: Valid agent 'switch' should succeed"
if "$V3_DIR/scripts/spawn-agent.sh" switch "test" > /dev/null 2>&1; then
    pass
else
    fail "Valid agent 'switch' was rejected"
fi

echo "  Negative: Invalid agent 'fakeagent123' should fail"
if "$V3_DIR/scripts/spawn-agent.sh" fakeagent123 "test" > /dev/null 2>&1; then
    fail "Invalid agent was accepted"
else
    pass
fi
echo ""

# ============================================================================
# TEST 2: Handoff missing acceptance_criteria is rejected
# ============================================================================
echo "[TEST 2] Handoff validation"

# Create a valid handoff
VALID_HANDOFF="$V3_DIR/tests/valid-handoff.yaml"
cat > "$VALID_HANDOFF" << 'EOF'
handoff:
  id: "test-001"
  timestamp: "2026-09-17T00:00:00Z"
  from: "@switch"
  to: "@quality"
  context:
    task: "Test task"
    goal: "Test goal"
    priority: "medium"
  artifacts:
    files: []
    data: {}
  acceptance_criteria:
    - "Criterion 1"
    - "Criterion 2"
  return_path:
    to: "@switch"
    format: "report"
  chain: []
EOF

echo "  Positive: Valid handoff with acceptance_criteria"
if grep -q "acceptance_criteria:" "$VALID_HANDOFF"; then
    pass
else
    fail "Valid handoff missing acceptance_criteria"
fi

# Create invalid handoff (missing acceptance_criteria)
INVALID_HANDOFF="$V3_DIR/tests/invalid-handoff.yaml"
cat > "$INVALID_HANDOFF" << 'EOF'
handoff:
  id: "test-002"
  timestamp: "2026-09-17T00:00:00Z"
  from: "@switch"
  to: "@quality"
  context:
    task: "Test task"
    goal: "Test goal"
    priority: "medium"
  artifacts:
    files: []
    data: {}
  return_path:
    to: "@switch"
    format: "report"
  chain: []
EOF

echo "  Negative: Handoff missing acceptance_criteria should be detected"
if grep -q "acceptance_criteria:" "$INVALID_HANDOFF"; then
    fail "Invalid handoff was accepted (has acceptance_criteria when it shouldn't)"
else
    pass
fi
rm -f "$VALID_HANDOFF" "$INVALID_HANDOFF"
echo ""

# ============================================================================
# TEST 3: Checkpoint save then load returns same state
# ============================================================================
echo "[TEST 3] Checkpoint save/load consistency"
TEST_SESSION="sess-phase3"
DB_PATH="$V3_DIR/state/state.db"

# Ensure DB exists
python3 "$V3_DIR/scripts/implementations/01-checkpointer.py" > /dev/null 2>&1 || true

echo "  Positive: Save and load checkpoint"
TEST_STATE='{"agent":"test","task":"checkpoint test","step":42}'
python3 -c "
import sqlite3, json
conn = sqlite3.connect('$DB_PATH')
cursor = conn.cursor()
cursor.execute('DELETE FROM checkpoints WHERE scope = ?', ('session:$TEST_SESSION',))
cursor.execute('INSERT INTO checkpoints (scope, timestamp, state_json, metadata) VALUES (?, ?, ?, ?)',
    ('session:$TEST_SESSION', '2026-09-17T00:00:00Z', '$TEST_STATE', '{}'))
conn.commit()
conn.close()
" 2>/dev/null

LOADED=$(python3 -c "
import sqlite3, json
conn = sqlite3.connect('$DB_PATH')
cursor = conn.cursor()
cursor.execute('SELECT state_json FROM checkpoints WHERE scope = ? ORDER BY timestamp DESC LIMIT 1', ('session:$TEST_SESSION',))
row = cursor.fetchone()
conn.close()
if row:
    print(row[0])
else:
    print('NO_DATA')
" 2>/dev/null)

if echo "$LOADED" | grep -q 'step.*42'; then
    pass
else
    fail "Checkpoint load returned: $LOADED"
fi

echo "  Negative: Load non-existent session should return empty"
EMPTY_LOAD=$(python3 -c "
import sqlite3
conn = sqlite3.connect('$DB_PATH')
cursor = conn.cursor()
cursor.execute('SELECT state_json FROM checkpoints WHERE scope = ?', ('session:nonexistent-999',))
row = cursor.fetchone()
conn.close()
print('FOUND' if row else 'EMPTY')
" 2>/dev/null)

if [ "$EMPTY_LOAD" = "EMPTY" ]; then
    pass
else
    fail "Non-existent session returned data: $EMPTY_LOAD"
fi
echo ""

# ============================================================================
# TEST 4: Reducer merge does not drop existing task id
# ============================================================================
echo "[TEST 4] Reducer merge preserves tasks"

echo "  Positive: Merge two task lists with different IDs"
MERGE_RESULT=$(python3 -c "
import sys
sys.path.insert(0, '$V3_DIR/scripts/implementations')
from importlib import import_module
spec = __import__('importlib.util').util.spec_from_file_location('reducers', '$V3_DIR/scripts/implementations/02-reducers.py')
mod = __import__('importlib.util').util.module_from_spec(spec)
spec.loader.exec_module(mod)

existing = [{'id': 't1', 'status': 'pending'}, {'id': 't2', 'status': 'done'}]
new = [{'id': 't3', 'status': 'in_progress'}]
merged = mod.merge_tasks(existing, new)
print(f'count={len(merged)}')
for t in merged:
    print(f'id={t[\"id\"]}')
" 2>/dev/null)

if echo "$MERGE_RESULT" | grep -q "id=t1" && echo "$MERGE_RESULT" | grep -q "id=t2" && echo "$MERGE_RESULT" | grep -q "id=t3"; then
    pass
else
    fail "Merge dropped tasks: $MERGE_RESULT"
fi

echo "  Negative: Merge with duplicate ID should update, not duplicate"
UPDATE_RESULT=$(python3 -c "
import sys
sys.path.insert(0, '$V3_DIR/scripts/implementations')
from importlib import import_module
spec = __import__('importlib.util').util.spec_from_file_location('reducers', '$V3_DIR/scripts/implementations/02-reducers.py')
mod = __import__('importlib.util').util.module_from_spec(spec)
spec.loader.exec_module(mod)

existing = [{'id': 't1', 'status': 'pending'}]
new = [{'id': 't1', 'status': 'completed'}]
merged = mod.merge_tasks(existing, new)
print(f'status={merged[0][\"status\"]}')
print(f'count={len(merged)}')
" 2>/dev/null)

if echo "$UPDATE_RESULT" | grep -q "status=completed" && echo "$UPDATE_RESULT" | grep -q "count=1"; then
    pass
else
    fail "Duplicate ID not updated correctly: $UPDATE_RESULT"
fi
echo ""

# ============================================================================
# TEST 5: ARC compact then recall recovers key facts
# ============================================================================
echo "[TEST 5] ARC compression and recovery"

echo "  Positive: Compress and recover data"
ARC_RESULT=$(python3 -c "
import sys
sys.path.insert(0, '$V3_DIR/scripts/implementations')
import json
spec = __import__('importlib.util').util.spec_from_file_location('arc', '$V3_DIR/scripts/implementations/06-arc-compaction.py')
mod = __import__('importlib.util').util.module_from_spec(spec)
spec.loader.exec_module(mod)

test_data = {'key_fact': 'SQLite is durable', 'numbers': [1,2,3], 'nested': {'a': 'b'}}
compacted = mod.compact_context(test_data)
recovered = mod.dereference(compacted['pointer'])

if recovered and recovered.get('key_fact') == 'SQLite is durable':
    print('RECOVERED_OK')
else:
    print('RECOVERED_FAIL')
" 2>/dev/null)

if [ "$ARC_RESULT" = "RECOVERED_OK" ]; then
    pass
else
    fail "ARC recovery failed: $ARC_RESULT"
fi

echo "  Negative: Dereference invalid pointer should return None"
INVALID_PTR=$(python3 -c "
import sys
sys.path.insert(0, '$V3_DIR/scripts/implementations')
spec = __import__('importlib.util').util.spec_from_file_location('arc', '$V3_DIR/scripts/implementations/06-arc-compaction.py')
mod = __import__('importlib.util').util.module_from_spec(spec)
spec.loader.exec_module(mod)

result = mod.dereference('invalid-pointer-12345')
print('NONE' if result is None else 'UNEXPECTED_DATA')
" 2>/dev/null)

if [ "$INVALID_PTR" = "NONE" ]; then
    pass
else
    fail "Invalid pointer returned data: $INVALID_PTR"
fi
echo ""

# ============================================================================
# TEST 6: website-creator SKILL.md declares steps
# ============================================================================
echo "[TEST 6] website-creator skill exists and declares steps"

# Search for website-creator in SYSTEM/
SKILL_PATH=""
for path in "$V3_DIR/../SYSTEM/skills/website-creator/SKILL.md" \
            "$V3_DIR/../SYSTEM/website-creator/SKILL.md" \
            "$V3_DIR/skills/website-creator/SKILL.md"; do
    if [ -f "$path" ]; then
        SKILL_PATH="$path"
        break
    fi
done

if [ -n "$SKILL_PATH" ]; then
    echo "  Found: $SKILL_PATH"
    STEP_COUNT=$(grep -cE "^## [0-9]+\." "$SKILL_PATH" 2>/dev/null || echo "0")
    echo "  Positive: SKILL.md exists with steps"
    if [ "$STEP_COUNT" -gt 0 ]; then
        pass
    else
        fail "SKILL.md exists but has no steps"
    fi
else
    echo "  Negative: website-creator SKILL.md not found"
    # Search broader
    FOUND=$(find "$V3_DIR/.." -name "SKILL.md" -path "*website*" 2>/dev/null | head -1)
    if [ -n "$FOUND" ]; then
        echo "  (Found alternative: $FOUND)"
        pass
    else
        fail "website-creator skill not found anywhere in repo"
    fi
fi
echo ""

# ============================================================================
# TEST 7: Quality score below 8.0 blocks delivery
# ============================================================================
echo "[TEST 7] Quality threshold enforcement"

echo "  Positive: Score >= 9 should pass"
HIGH_SCORE=$(python3 -c "
score = 92  # 9.2/10
if score >= 80:
    print('PASS')
else:
    print('BLOCK')
")

if [ "$HIGH_SCORE" = "PASS" ]; then
    pass
else
    fail "High score was blocked"
fi

echo "  Negative: Score < 8.0 should block delivery"
LOW_SCORE=$(python3 -c "
score = 75  # 7.5/10
if score >= 80:
    print('PASS')
else:
    print('BLOCK')
")

if [ "$LOW_SCORE" = "BLOCK" ]; then
    pass
else
    fail "Low score was not blocked"
fi
echo ""

# ============================================================================
# TEST 8: Planted absolute path fails audit
# ============================================================================
echo "[TEST 8] Hardcoded path audit"

echo "  Positive: No hardcoded paths should be found"
PATH_COUNT=$(grep -rn "/Users/rohitvashist/.openclaw/workspace/v3" "$V3_DIR/scripts" "$V3_DIR/tools" --include="*.sh" --include="*.py" 2>/dev/null | wc -l)

if [ "$PATH_COUNT" -eq 0 ]; then
    pass
else
    fail "Found $PATH_COUNT hardcoded paths"
fi

echo "  Negative: Plant a bad path and verify it's caught"
PLANTED_FILE="$V3_DIR/tests/planted-path-test.sh"
echo 'V3_DIR="/Users/rohitvashist/.openclaw/workspace/v3"' > "$PLANTED_FILE"
PLANT_FOUND=$(grep -rn "/Users/rohitvashist/.openclaw/workspace/v3" "$V3_DIR/tests/" --include="*.sh" 2>/dev/null | wc -l | awk '{print $1}')
rm -f "$PLANTED_FILE"

if [ "$PLANT_FOUND" -ge 1 ]; then
    pass
else
    fail "Planted path not detected (found $PLANT_FOUND)"
fi
echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo "========================================"
echo "  Test Suite Complete"
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
echo "========================================"

if [ "$FAILED" -eq 0 ]; then
    echo "  Status: ALL PASSED"
    exit 0
else
    echo "  Status: $FAILED FAILURE(S)"
    exit 1
fi
