# Sprint P0 — Requirements Document

**Sprint Goal:** Fix critical system issues (stale state, orphaned agents, missing tracking)  
**Duration:** 1 day  
**Total Effort:** 30 minutes  
**Features:** 3

---

## Feature 1: P0-001 — Fix Stale Task

### Current State
- `task-ho-1789739006` shows `"status": "in_progress"` since 2026-09-18
- Task description: "Test task for Phase 1"
- No completion timestamp

### Requirement
- Mark task as `"completed"` with `completed_at` timestamp
- Add `_priority: "agent_output"` if missing
- Ensure no other tasks reference this as active

### Acceptance Criteria
- [ ] state.json shows task status as "completed"
- [ ] `completed_at` field exists with valid ISO timestamp
- [ ] No agent shows this as currentTask

### Implementation
```bash
# Edit state/current.json — update task entry
# Set status: "completed"
# Add completed_at: "2026-09-20T..."
```

---

## Feature 2: P0-002 — Sync v3.1.1 Work to State

### Current State
- v3.1.1 deployed but state.json shows version "3.1.1" (correct)
- No tasks track: validator creation, AGENT-ROSTER.md, RELEASE fix
- Missing from task history

### Requirement
- Add completed tasks for v3.1.1 work:
  1. "Create validate-system.sh agent manifest validator"
  2. "Create AGENT-ROSTER.md canonical agent list"
  3. "Fix RELEASE-v3.1.md documentation drift"
  4. "Update session-startup.sh with validation step"

### Acceptance Criteria
- [ ] All 4 tasks appear in state.json tasks array
- [ ] All marked "completed" with timestamps
- [ ] Version remains "3.1.1"

### Implementation
```bash
# Append to state/current.json tasks array
# Each task: id, description, status, completed_at, assignee
```

---

## Feature 3: P0-003 — Fix Scaffolder Orphaned Status

### Current State
```json
"scaffolder": {
  "status": "working",
  "currentTask": "Test task for Phase 1",
  "last_update": "2026-09-18T13:43:26.411963"
}
```

### Requirement
- Set scaffolder status to `"idle"`
- Set currentTask to `null`
- Update last_update to current timestamp

### Acceptance Criteria
- [ ] scaffolder.status == "idle"
- [ ] scaffolder.currentTask == null
- [ ] last_update is recent (within today)

### Implementation
```bash
# Edit state/current.json — update agents.scaffolder
```

---

## Sprint Definition of Done

- [ ] All 3 features implemented
- [ ] validate-system.sh passes (0 errors)
- [ ] health-monitor.sh status shows all agents idle
- [ ] Git commit with message "v3.1.1-P0: Fix critical state issues"
- [ ] GitHub pushed

---

*Requirements by @product*  
*Sprint P0 — Critical Fixes*
