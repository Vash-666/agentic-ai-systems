# System Upgrade Requirements Document

**Version:** 3.1  
**Date:** 2026-09-18  
**Author:** Product Manager (Subagent)  
**Status:** Draft → Ready for Review  

---

## Executive Summary

This document details the requirements for completing the v3.1 system upgrade, addressing missing feature wiring, health monitoring activation, quality tracking, cleanup tasks, and documentation fixes. All items are derived from the MISSING FEATURES LIST and organized by priority and dependency chain.

**Current System Baseline (from memory):**
- Quality Score: 8.79/10
- Context Utilization: 100%
- Cost Savings: 88%
- Active Agents: 4
- GitHub Showcase: Posted

---

## 1. v3.1 Feature Wiring (P1 - Critical)

### Overview
Six core features developed in v3.1 remain unwired to the runtime. This epic ensures each feature is properly integrated into session lifecycle, agent operations, and memory management.

---

### 1.1 SQLite Checkpointer → Wire to Session Startup/End

**Requirement ID:** REQ-1.1  
**Priority:** P1  
**Effort:** 3 days  

#### Detailed Requirements
- On session startup, initialize SQLite checkpointer connection and verify schema version
- On session end (graceful or error), persist final checkpoint state to SQLite
- Implement checkpoint recovery on startup: detect unclean shutdown and offer recovery
- Add configuration option: `checkpointer.enabled` (default: true)
- Ensure thread-safe access to SQLite from concurrent agents
- Log checkpoint operations at DEBUG level

#### Acceptance Criteria
- [ ] AC1.1.1: Session startup completes within 500ms even with large checkpoint data
- [ ] AC1.1.2: Session end persists state within 1 second
- [ ] AC1.1.3: Recovery mode restores last known good state after crash
- [ ] AC1.1.4: Concurrent agents do not corrupt SQLite database
- [ ] AC1.1.5: Checkpointer can be disabled via config without breaking startup

#### Dependencies
- SQLite schema must be finalized (assumed complete)
- Session lifecycle hooks must exist (assumed complete)

---

### 1.2 State Reducers → Wire to Concurrent Agent Operations

**Requirement ID:** REQ-1.2  
**Priority:** P1  
**Effort:** 4 days  

#### Detailed Requirements
- Integrate state reducers into the agent task execution pipeline
- When multiple agents operate concurrently, reducer merges partial states into canonical state
- Implement reducer priority: user overrides > agent output > system defaults
- Add reducer conflict resolution logging
- Support custom reducers per agent type

#### Acceptance Criteria
- [ ] AC1.2.1: Two concurrent agents updating same state key resolve without data loss
- [ ] AC1.2.2: Reducer output is deterministic (same inputs → same output)
- [ ] AC1.2.3: Conflict resolution logs are human-readable
- [ ] AC1.2.4: Custom reducer for memory agent does not affect orchestrator agent
- [ ] AC1.2.5: Performance: reducer completes in <100ms for 10 concurrent agents

#### Dependencies
- REQ-1.1 (SQLite Checkpointer) - reducers need persistent state to merge
- Agent concurrency framework must exist

---

### 1.3 Scoped Memory Hierarchy → Wire to Agent Context Loading

**Requirement ID:** REQ-1.3  
**Priority:** P1  
**Effort:** 5 days  

#### Detailed Requirements
- On agent context load, apply scoped memory hierarchy:
  - Global scope: all agents see this
  - Session scope: only current session agents see this
  - Agent scope: only specific agent instance sees this
  - Task scope: only current task sees this
- Implement scope resolution order: task → agent → session → global
- Add memory scope metadata to all stored facts
- Provide agent API: `memory.get(key, scope_hint)`

#### Acceptance Criteria
- [ ] AC1.3.1: Agent A cannot read Agent B's agent-scoped memory
- [ ] AC1.3.2: Session-scoped memory is shared among all agents in session
- [ ] AC1.3.3: Task-scoped memory is garbage collected after task completion
- [ ] AC1.3.4: Global memory is accessible to all agents across all sessions
- [ ] AC1.3.5: Scope resolution completes in <50ms per lookup

#### Dependencies
- REQ-1.2 (State Reducers) - scoped memory needs reduced state
- Memory storage backend must support metadata

---

### 1.4 Auto Fact Extractor v2 → Trigger After Agent Tasks Complete

**Requirement ID:** REQ-1.4  
**Priority:** P1  
**Effort:** 4 days  

#### Detailed Requirements
- After any agent task completes (success or failure), trigger Auto Fact Extractor v2
- Extractor analyzes task input, output, and side effects
- Generated facts are stored with appropriate scope (task → session → global promotion rules)
- Implement rate limiting: max 1 extraction per 30 seconds per agent
- Add configuration: `fact_extractor.auto_trigger` (default: true)
- Facts must include confidence score (0.0-1.0) and source attribution

#### Acceptance Criteria
- [ ] AC1.4.1: Task completion always triggers extractor (when enabled)
- [ ] AC1.4.2: Extracted facts are stored within 5 seconds of task completion
- [ ] AC1.4.3: Rate limiter prevents extraction spam
- [ ] AC1.4.4: Facts include confidence score and source task ID
- [ ] AC1.4.5: Disabling auto_trigger does not break task execution
- [ ] AC1.4.6: Extractor handles task failures gracefully (no crash)

#### Dependencies
- REQ-1.3 (Scoped Memory Hierarchy) - facts need scope assignment
- REQ-1.1 (SQLite Checkpointer) - facts need persistence

---

### 1.5 Composite Recall → Wire to Memory Retrieval

**Requirement ID:** REQ-1.5  
**Priority:** P1  
**Effort:** 5 days  

#### Detailed Requirements
- Replace simple memory retrieval with Composite Recall on all `memory.recall()` calls
- Composite Recall combines:
  - Semantic search (vector similarity)
  - Keyword search (exact and fuzzy)
  - Temporal search (recency-weighted)
  - Hierarchical search (scope-aware)
- Implement result ranking: weighted combination of all search modalities
- Add configuration: `recall.composite_weights` (customizable per agent)
- Fallback to simple search if composite fails

#### Acceptance Criteria
- [ ] AC1.5.1: Memory recall returns results from all search modalities
- [ ] AC1.5.2: Top-ranked result is relevant to query in >90% of test cases
- [ ] AC1.5.3: Composite recall completes in <2 seconds for 10k memory items
- [ ] AC1.5.4: Fallback to simple search is transparent to agents
- [ ] AC1.5.5: Weights can be customized per agent type

#### Dependencies
- REQ-1.3 (Scoped Memory Hierarchy) - recall must respect scopes
- REQ-1.4 (Auto Fact Extractor v2) - more facts = better recall
- Vector search index must exist

---

### 1.6 ARC Compaction → Trigger When Context Grows Large

**Requirement ID:** REQ-1.6  
**Priority:** P1  
**Effort:** 6 days  

#### Detailed Requirements
- Monitor context size continuously during session
- When context exceeds threshold (default: 80% of max), trigger ARC Compaction
- ARC (Adaptive Replacement Cache) compaction:
  - Identify least-recently and least-frequently used context items
  - Archive to long-term storage (SQLite)
  - Summarize archived content and keep summary in active context
- Implement gradual compaction: compact 10% at a time to avoid spikes
- Add configuration: `compaction.threshold` and `compaction.batch_size`
- Never compact user-active or locked context items

#### Acceptance Criteria
- [ ] AC1.6.1: Context at 85% triggers compaction within 30 seconds
- [ ] AC1.6.2: After compaction, context drops to <70%
- [ ] AC1.6.3: Archived content is recoverable via recall
- [ ] AC1.6.4: User-active items are never compacted
- [ ] AC1.6.5: Compaction does not interrupt ongoing agent tasks
- [ ] AC1.6.6: Summary of compacted content is retained in context

#### Dependencies
- REQ-1.1 (SQLite Checkpointer) - archive target
- REQ-1.5 (Composite Recall) - archived content must be recallable
- Context size monitoring must exist

---

## 2. Health Monitor Activation (P1 - Critical)

**Requirement ID:** REQ-2  
**Priority:** P1  
**Effort:** 2 days  

### Detailed Requirements
- Activate `ollama-fallback-monitor.sh` script for continuous health monitoring
- Configure cron job to run monitor every 5 minutes
- Integrate Telegram notification channel for alerts
- Monitor checks:
  - Ollama API availability
  - Model load status
  - Response latency
  - Fallback trigger conditions
- Alert thresholds:
  - API down >2 minutes → CRITICAL alert
  - Latency >5 seconds → WARNING alert
  - Model unload → INFO alert

### Acceptance Criteria
- [ ] AC2.1: `ollama-fallback-monitor.sh` starts successfully and runs daemonized
- [ ] AC2.2: Cron job is configured and persists across reboots
- [ ] AC2.3: Telegram notifications are received for all alert levels
- [ ] AC2.4: Monitor detects Ollama outage within 5 minutes
- [ ] AC2.5: Monitor logs are written to `logs/health-monitor.log`
- [ ] AC2.6: Monitor can be stopped/started independently

### Dependencies
- `ollama-fallback-monitor.sh` must exist and be executable
- Telegram bot token must be configured
- Cron must be available on host

---

## 3. Quality Score Tracking (P1 - Critical)

**Requirement ID:** REQ-3  
**Priority:** P1  
**Effort:** 2 days  

### Detailed Requirements
- Schedule `quality-score.sh` to run daily at 00:00 UTC
- Log results to `memory/daily/YYYY-MM-DD-quality.json`
- Track metrics:
  - Overall quality score (0-10)
  - Context utilization percentage
  - Cost savings percentage
  - Active agent count
  - Error rate
- Alert if quality score drops below 9.0:
  - Send Telegram notification
  - Log detailed diagnostic snapshot
  - Trigger automatic health check
- Maintain 30-day rolling history

### Acceptance Criteria
- [ ] AC3.1: `quality-score.sh` runs automatically every 24 hours
- [ ] AC3.2: Results are logged to `memory/daily/` with correct date format
- [ ] AC3.3: Alert is triggered when score < 9.0
- [ ] AC3.4: Alert includes current score and 7-day trend
- [ ] AC3.5: Historical data is queryable for trend analysis
- [ ] AC3.6: Manual run of `quality-score.sh` also logs correctly

### Dependencies
- `quality-score.sh` must exist and be executable
- Telegram notification channel (shared with REQ-2)
- `memory/daily/` directory must exist or be auto-created

---

## 4. Duplicate File Cleanup (P2 - Important)

**Requirement ID:** REQ-4  
**Priority:** P2  
**Effort:** 1 day  

### Detailed Requirements
- Identify 3 duplicate fact extractor files in the codebase
- Determine canonical version for each duplicate set
- Delete non-canonical duplicates
- Update all imports/references to point to canonical versions
- Document canonical file locations in `docs/file-locations.md`

### Acceptance Criteria
- [ ] AC4.1: Exactly 3 duplicate files are identified and listed
- [ ] AC4.2: Canonical version is determined (newest, most complete, or designated)
- [ ] AC4.3: Non-canonical files are deleted (not just moved)
- [ ] AC4.4: All references updated — no broken imports
- [ ] AC4.5: System tests pass after cleanup

### Dependencies
- None (cleanup task)

---

## 5. Stale Memory Cleanup (P2 - Important)

**Requirement ID:** REQ-5  
**Priority:** P2  
**Effort:** 2 days  

### Detailed Requirements
- Deduplicate `STRATEGIC.md`:
  - Identify duplicate entries
  - Merge without losing unique information
  - Preserve chronological order where relevant
- Update `state/current.json`:
  - Remove stale fields
  - Update values to reflect current system state
  - Validate JSON schema after changes
- Remove test artifacts:
  - Identify files in `test/artifacts/` older than 30 days
  - Archive (not delete) before removal
  - Log cleanup actions

### Acceptance Criteria
- [ ] AC5.1: `STRATEGIC.md` has no duplicate entries
- [ ] AC5.2: `state/current.json` is valid JSON and reflects current state
- [ ] AC5.3: Test artifacts older than 30 days are archived
- [ ] AC5.4: Cleanup log is written to `logs/cleanup-YYYY-MM-DD.log`
- [ ] AC5.5: No active/test-in-use artifacts are removed

### Dependencies
- None (cleanup task)

---

## 6. Documentation Fixes (P2 - Important)

**Requirement ID:** REQ-6  
**Priority:** P2  
**Effort:** 1 day  

### Detailed Requirements
- Add disclaimer to `blog-post-v3-launch.md`:
  - "This document reflects the planned v3.0 state. Some features may be in beta."
- Update `README.md`:
  - Replace "100%" claims with actual metrics (current: 8.79/10 quality)
  - Update feature list to reflect actually shipped features
  - Add "Current Status" section with live metrics
- Remove all "100%" claims from documentation:
  - Search all `.md` files for "100%"
  - Replace with actual measured values or remove

### Acceptance Criteria
- [ ] AC6.1: `blog-post-v3-launch.md` contains disclaimer
- [ ] AC6.2: `README.md` has no "100%" claims
- [ ] AC6.3: `README.md` includes current status section with actual metrics
- [ ] AC6.4: All `.md` files searched — no remaining "100%" claims
- [ ] AC6.5: Documentation builds/preview renders correctly

### Dependencies
- None (documentation task)

---

## Implementation Priority Order

### Phase 1: Foundation (Week 1)
1. **REQ-1.1** — SQLite Checkpointer (3 days)
2. **REQ-1.2** — State Reducers (4 days, starts after 1.1)
3. **REQ-2** — Health Monitor Activation (2 days, parallel with 1.1)

### Phase 2: Core Features (Week 2)
4. **REQ-1.3** — Scoped Memory Hierarchy (5 days)
5. **REQ-1.4** — Auto Fact Extractor v2 (4 days, parallel with 1.3)
6. **REQ-3** — Quality Score Tracking (2 days, parallel)

### Phase 3: Intelligence (Week 3)
7. **REQ-1.5** — Composite Recall (5 days)
8. **REQ-1.6** — ARC Compaction (6 days, parallel with 1.5)

### Phase 4: Cleanup (Week 3-4 overlap)
9. **REQ-4** — Duplicate File Cleanup (1 day)
10. **REQ-5** — Stale Memory Cleanup (2 days)
11. **REQ-6** — Documentation Fixes (1 day)

---

## Dependency Graph

```
REQ-1.1 (SQLite Checkpointer)
    ├── REQ-1.2 (State Reducers)
    │       ├── REQ-1.3 (Scoped Memory)
    │       │       ├── REQ-1.4 (Fact Extractor)
    │       │       └── REQ-1.5 (Composite Recall)
    │       └── REQ-1.6 (ARC Compaction)
    ├── REQ-1.6 (ARC Compaction)
    └── REQ-2 (Health Monitor) — parallel

REQ-1.5 (Composite Recall)
    └── REQ-1.6 (ARC Compaction)

REQ-2 (Health Monitor) — independent, parallel
REQ-3 (Quality Tracking) — independent, parallel
REQ-4 (Duplicate Cleanup) — independent
REQ-5 (Stale Cleanup) — independent
REQ-6 (Documentation) — independent
```

---

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| SQLite schema incompatible | High | Verify schema version before wiring |
| Concurrent agent deadlocks | High | Implement timeout in reducers |
| ARC compaction loses data | Critical | Always archive before compacting |
| Telegram token invalid | Medium | Test notifications before going live |
| Quality score false alerts | Low | Use 3-day average before alerting |

---

## Success Metrics

- All P1 features wired and passing acceptance criteria
- Health monitor running continuously with <1% downtime
- Quality score tracked daily with 30-day history
- Zero duplicate files
- Zero stale test artifacts
- Documentation accurate and current

---

## Appendix: Current System Metrics (Baseline)

| Metric | Value | Date |
|--------|-------|------|
| Quality Score | 8.79/10 | 2026-07-22 |
| Context Utilization | 100% | 2026-07-22 |
| Cost Savings | 88% | 2026-07-22 |
| Active Agents | 4 | 2026-07-22 |
| GitHub Showcase | Posted | 2026-07-22 |

---

*Document generated by Product Manager Subagent*  
*Ready for engineering review and sprint planning*
