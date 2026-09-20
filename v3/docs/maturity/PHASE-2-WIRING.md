# PHASE 2 — WIRE v3.1 INTO DEFAULT PATH

**Status:** PARTIAL WIRE  
**Date:** 2026-09-17  
**Executed by:** @switch (direct)

---

## Changes Made

### 1. session-startup.sh
**File:** `v3/scripts/session-startup.sh`

**Before:**
- Hardcoded `V3_DIR="/Users/rohitvashist/.openclaw/workspace/v3"`
- Only catted markdown files
- No checkpoint loading
- 6 steps

**After:**
- Relative path: `V3_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"`
- Step 0: Loads checkpoint from SQLite for session scope
- Falls back to fresh start if no checkpoint
- 7 steps (added v3.1 feature status check)
- Fixed glob expansion bug in feature status loop

### 2. spawn-agent.sh
**File:** `v3/scripts/spawn-agent.sh`

**Before:**
- Hardcoded `V3_DIR`
- Wrote YAML handoff only
- Updated JSON state file only

**After:**
- Relative path resolution
- Writes YAML handoff (unchanged)
- **NEW:** Writes SQLite checkpoint with session state
- Includes SESSION_ID tracking

### 3. quality-score.sh
**File:** `v3/scripts/quality-score.sh`
- Fixed: Relative path instead of hardcoded

### 4. evaluate.sh
**File:** `v3/tools/evaluate.sh`
- Fixed: Relative path instead of hardcoded

### 5. implementations/*.py (7 files)
- Fixed: All hardcoded `/Users/rohitvashist/.openclaw/workspace/v3/` paths → `../../`

---

## Smoke Test

### Test: Start session → Spawn agent → Restart → Resume

```bash
# Step 1: Start session
$ export SESSION_ID=sess-verify-001
$ ./session-startup.sh switch
  ⚠ No checkpoint for session sess-verify-001 (fresh start)
  ✓ SOUL.md, HANDOFF.md, QUALITY.md, MEMORY.md
  ✓ agents/switch/AGENT.md

# Step 2: Spawn agent
$ ./spawn-agent.sh quality "Verify same session"
  ✓ Checkpoint saved to SQLite
  ✓ Agent @quality spawned

# Step 3: Restart with same session
$ SESSION_ID=sess-verify-001 ./session-startup.sh switch
  ✓ Checkpoint loaded for session sess-verify-001
  {
    "session_id": "sess-verify-001",
    "agent": "quality",
    "task": "Verify same session",
    "handoff_id": "ho-1789615891-fd58d89b"
  }
```

**Result:** ✅ Checkpoint resume works

---

## v3.1 Module Wiring Status

| Module | File | Status | Wired To |
|--------|------|--------|----------|
| **SQLite Checkpointer** | `01-checkpointer.py` | ✅ Wired | session-startup.sh, spawn-agent.sh |
| **State Reducers** | `02-reducers.py` | ⚠️ Standalone | Not wired to any script |
| **Scoped Memory** | `03-scoped-memory.py` | ⚠️ Standalone | Not wired to any script |
| **Fact Extractor** | `04-fact-extractor-v2.py` | ⚠️ Standalone | Not wired to any script |
| **Composite Recall** | `05-composite-recall.py` | ⚠️ Standalone | Not wired to any script |
| **ARC Compaction** | `06-arc-compaction.py` | ⚠️ Standalone | Not wired to any script |

**Honest assessment:** Only checkpointer is wired. The other 5 modules exist but are not invoked by any script.

---

## Hardcoded Paths Fixed

| File | Before | After |
|------|--------|-------|
| session-startup.sh | `/Users/rohitvashist/...` | `$(cd "$SCRIPT_DIR/.." && pwd)` |
| spawn-agent.sh | `/Users/rohitvashist/...` | `$(cd "$SCRIPT_DIR/.." && pwd)` |
| quality-score.sh | `/Users/rohitvashist/...` | `$(cd "$SCRIPT_DIR/.." && pwd)` |
| evaluate.sh | `/Users/rohitvashist/...` | `$(cd "$SCRIPT_DIR/.." && pwd)` |
| 01-checkpointer.py | `/Users/rohitvashist/...` | `../../` |
| 03-scoped-memory.py | `/Users/rohitvashist/...` | `../../` |
| 04-fact-extractor.py | `/Users/rohitvashist/...` | `../../` |
| 04-fact-extractor-v2.py | `/Users/rohitvashist/...` | `../../` |
| 06-arc-compaction.py | `/Users/rohitvashist/...` | `../../` |
| fact_extractor.py | `/Users/rohitvashist/...` | `../../` |
| fact_extractor_v2.py | `/Users/rohitvashist/...` | `../../` |

**Total: 11 files fixed**

---

## Acceptance Criteria

| # | Criterion | Status |
|---|-----------|--------|
| 1 | session-startup.sh opens/creates state.db | ✅ |
| 2 | Loads latest checkpoint for session scope | ✅ |
| 3 | Resumes from last checkpoint on restart | ✅ |
| 4 | spawn-agent.sh writes YAML + SQLite checkpoint | ✅ |
| 5 | Relative paths used in all scripts | ✅ (11/11 files) |

---

## Blockers / Honest Gaps

1. **5 of 6 v3.1 modules are standalone** — exist but not wired
2. **No integration between modules** — checkpointer doesn't call reducers, etc.
3. **Handoff YAML is stdout only** — now also saved to `v3/memory/handoffs/`
4. **Feature status check was broken** — fixed glob expansion

---

## Next: Phase 3 — Quality That Can Fail

Requires: Real test suite with positive AND negative cases.

**Frozen. Waiting for "proceed to Phase 3".**
