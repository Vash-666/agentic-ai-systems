# Missing Features Audit: v3.0 → v3.1 Migration

**Date:** 2026-09-18
**Auditor:** @switch
**Status:** Analysis Complete — Implementation In Progress

---

## Executive Summary

The v3.1 upgrade added 6 context management features but **broke or omitted several critical v3.0 features**. This audit identifies what's missing and provides a recovery plan.

| Category | Missing Count | Priority |
|----------|--------------|----------|
| **Daily Memory Logging** | 1 | 🔴 P0 |
| **Automation & Monitoring** | 4 | 🟡 P1 |
| **Integration & Wiring** | 5 | 🟡 P1 |
| **Documentation Accuracy** | 3 | 🟢 P2 |
| **Hygiene & Cleanup** | 3 | 🟢 P2 |

---

## 🔴 P0 — Critical Missing Features

### 1. Daily Memory Logging (`memory/YYYY-MM-DD.md`)

**What it was:**
- Daily markdown files capturing sessions, decisions, facts
- Loaded automatically by `session-startup.sh` (Step 5)
- Referenced in `MEMORY.md` as "Layer 2: Short-Term Memory"

**Current state:**
- `memory/` directory exists but only contains:
  - `compacted/` (test artifacts)
  - `SESSION-CONTEXT.md` (stale)
  - `STRATEGIC.md` (polluted with duplicate facts)
  - `USER.md` (minimal)
- **No `daily/` subdirectory**
- **No daily logs since September 9, 2026**

**Impact:**
- No session continuity between restarts
- No historical record of decisions/conversations
- Memory system is effectively offline for daily logging
- `session-startup.sh` reports "⚠ No daily log for today/yesterday" on every startup

**Evidence:**
```bash
# Session startup output:
[5/7] Loading recent memory...
  ⚠ No daily log for today
  ⚠ No daily log for yesterday
```

**Fix required:**
- Create `v3/memory/daily/` directory
- Implement daily memory generation at session end
- Update `session-startup.sh` to create template if missing

---

## 🟡 P1 — High Priority Missing Features

### 2. Automated Health Monitoring

**What existed before:**
- `tools/ollama-fallback-monitor.sh` — Auto-restart Ollama, health checks, Telegram notifications
- Cron job for persistent monitoring

**Current state:**
- Script exists but is **not running**
- No cron job configured
- No automated health checks

**Evidence from Sep 9 SYSTEM-UPDATE:**
> "Fallback monitor not running — Auto-recovery not active"

### 3. API Key Monitoring

**What existed before:**
- `env-secrets.sh` with API keys
- Health check commands for each provider
- Automatic fallback activation

**Current state:**
- Keys configured in OpenClaw auth profiles
- **No automated key validation**
- **No proactive billing alerts**
- Moonshot had auth_error on Sep 9 (now resolved)

### 4. Quality Score Tracking

**What existed before:**
- Daily quality metrics: 8.79/10 (Jul 21-22)
- Tracked: Quality, Context, Cost Savings, Active Agents

**Current state:**
- `scripts/quality-score.sh` exists but **not wired**
- No automated quality tracking
- Last recorded score: 8.79/10 (Sep 9)
- Target ≥9.0/10 not being monitored

### 5. v3.1 Feature Wiring (6 Features)

**All 6 v3.1 features are implemented but NOT integrated:**

| Feature | File | Status | Wired? |
|---------|------|--------|--------|
| SQLite Checkpointer | `01-checkpointer.py` | ✅ Tested | ❌ No |
| State Reducers | `02-reducers.py` | ✅ Tested | ❌ No |
| Scoped Memory | `03-scoped-memory.py` | ✅ Tested | ❌ No |
| Fact Extractor v2 | `04-fact-extractor-v2.py` | ✅ Tested | ❌ No |
| Composite Recall | `05-composite-recall.py` | ✅ Tested | ❌ No |
| ARC Compaction | `06-arc-compaction.py` | ✅ Tested | ❌ No |

**Impact:**
- Features are "proof-of-concept islands"
- No production code uses them
- Session startup loads from files, not SQLite
- No automatic fact extraction after tasks
- No context compaction happening

**Evidence from PHASE-1-AUDIT:**
> "All 6 features are implemented as standalone Python scripts with `if __name__ == '__main__'` test blocks. **None are imported, wired, or triggered by the actual system.**"

---

## 🟢 P2 — Medium Priority Issues

### 6. Duplicate Files

**What exists:**
- `04-fact-extractor.py` ≈ `fact_extractor.py`
- `04-fact-extractor-v2.py` ≈ `fact_extractor_v2.py`
- 4 files for 1 feature

**Impact:**
- Confusion about which to use
- Maintenance burden
- No canonical version

### 7. Stale/Polluted Memory

**Issues:**
- `STRATEGIC.md` has 7 identical "100% test pass rate" entries
- `state/current.json` shows "initializing" and "0h 0m" uptime
- Facts were auto-extracted from test strings, not real data

### 8. Documentation Drift

**Issues:**
- `README.md` claims "7 agents" but only 6 configured
- Blog post claims metrics (9.15/10, 21x compression) with no evidence
- `CAPABILITIES.md` defines tools that don't exist
- Agent model assignments are aspirational, not actual

---

## Recovery Plan

### Phase A: Immediate (Today)
1. ✅ **Fix scaffolder model** (kimi-k2.5 → kimi-k2.6) — DONE
2. 🔧 **Create daily memory logging system**
3. 🔧 **Create `memory/daily/` directory structure**

### Phase B: This Week
4. **Wire v3.1 features into session startup**
   - SQLite checkpointer on session start/end
   - Fact extractor after agent tasks
   - ARC compaction when context grows
5. **Start health monitor**
   - Configure cron job
   - Test Telegram notifications
6. **Clean up duplicates**
   - Delete 3 duplicate fact extractor files
   - Consolidate to canonical versions

### Phase C: This Month
7. **Implement quality tracking**
   - Run `quality-score.sh` daily
   - Log to `memory/daily/`
   - Alert if score drops below 9.0
8. **Fix documentation**
   - Add disclaimer to blog post
   - Update README with actual state
   - Remove "100%" claims
9. **Clean polluted memory**
   - Deduplicate STRATEGIC.md
   - Update state/current.json
   - Remove test artifacts

---

## Files Status Summary

| Path | Status | Action Needed |
|------|--------|---------------|
| `memory/daily/` | ❌ MISSING | Create directory + logging |
| `scripts/session-startup.sh` | ⚠️ Partial | Add daily log creation |
| `scripts/spawn-agent.sh` | ⚠️ Partial | Wire SQLite checkpoint |
| `scripts/quality-score.sh` | ⚠️ Orphaned | Wire to daily run |
| `tools/evaluate.sh` | ⚠️ Orphaned | Wire to CI/pre-commit |
| `tools/ollama-fallback-monitor.sh` | ⚠️ Not running | Start + cron |
| `scripts/implementations/*.py` (×6) | ⚠️ Standalone | Wire to system |
| `memory/STRATEGIC.md` | ⚠️ Polluted | Clean duplicates |
| `state/current.json` | ⚠️ Stale | Update or remove |
| `blog-post-v3-launch.md` | ⚠️ Unverified claims | Add disclaimer |

---

*Audit complete. Ready for implementation.*
