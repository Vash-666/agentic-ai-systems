# PI-004: State Synchronization System

**Status:** Backlog  
**Theme:** Coordination  
**Priority:** High  
**Created:** April 20, 2026  
**Estimated Effort:** 3-4 hours  
**Related Feedback:** @quality

---

## Objective
Implement systematic state synchronization to prevent agents from working with stale information and causing coordination failures.

## Background
**Current Problem:**
- Agents work with outdated information
- Changes not propagated across team
- Duplicate work or conflicting changes
- No single source of truth for project state

**Example Failures:**
- @quality didn't know about template changes
- Agents make decisions based on old PRD
- Sprint plans diverge from actual work
- Verification fails due to stale expectations

## Scope

### 1. State Synchronization Protocol
**Effort:** 2 hours

**Deliverable:**
- Define "project state" components:
  - Active tasks and status
  - Key artifacts and versions
  - Decisions and rationale
  - Blockers and dependencies
  - Quality metrics
- Standard state snapshot format
- When to update state (triggers)
- How to propagate updates

**Example State Snapshot:**
```json
{
  "project": "P001",
  "snapshot_time": "2026-04-20T20:00:00Z",
  "active_tasks": [
    {"id": "T3.3", "status": "in-progress", "owner": "@switch"},
    {"id": "T3.4", "status": "blocked", "blocker": "T3.3"}
  ],
  "key_artifacts": {
    "prd": {"path": "products/prd.md", "version": "v2.1", "hash": "abc123"},
    "sprint_plan": {"path": "backlog/P001-Day-4-Sprint-Plan.md", "updated": "2026-04-20"}
  },
  "decisions": [
    {"date": "2026-04-20", "decision": "Prioritize test framework over new template", "owner": "@product"}
  ],
  "metrics": {
    "quality_score": 8.0,
    "completion": "60%"
  }
}
```

### 2. Single Source of Truth (SSOT) for Project State
**Effort:** 1 hour

**Deliverable:**
- Designate authoritative state file(s)
- Define update ownership by state component
- Read-only vs read-write access patterns
- Conflict resolution protocol

**Proposed SSOT Structure:**
- `state/P001-current-state.json` - Authoritative snapshot
- Updated by @product after major milestones
- Read by all agents before starting work
- Agents report changes back to @product for state update

### 3. State Update Workflow
**Effort:** 1-2 hours

**Deliverable:**
- When to check state (task start, handoff, before decisions)
- How to report state changes
- Integration with handoff protocol (PI-007)
- Automated state update scripts where possible

**Workflow:**
1. Agent starts task → Check `state/current-state.json`
2. Agent completes task → Report changes to @product
3. @product validates → Updates SSOT
4. State change notification → All agents aware

### 4. State Synchronization Tools
**Effort:** 1 hour

**Deliverable:**
- Script to generate state snapshot
- State diff tool (compare snapshots)
- State validation checker
- Integration with existing tracking logs

## Success Criteria
- [ ] State synchronization protocol documented
- [ ] SSOT file structure established
- [ ] State update workflow integrated with handoffs
- [ ] All agents check state before starting work
- [ ] Zero coordination failures due to stale state
- [ ] State freshness: <2 hours for critical updates

## Priority Rationale
**High** - Directly addresses coordination failures identified in quality audit. Prevents duplicate work and conflicts. Enables better decision-making with current information.

## Dependencies
- PI-007: Handoff Protocols (integration point)
- PI-006: Shared Roadmap (state includes roadmap view)

## Implementation Notes
- Start simple - JSON state file is enough
- @product owns state updates initially
- Can automate more over time
- Balance freshness with update overhead

## Risks & Mitigations
**Risk:** State updates become bottleneck through @product  
**Mitigation:** Allow direct updates for low-impact changes, batch updates

**Risk:** State gets stale if agents forget to check  
**Mitigation:** Integrate into task templates, handoff checklists

**Risk:** Conflicting state updates  
**Mitigation:** Last-write-wins with git tracking, conflict resolution protocol

## Metrics to Track
- State freshness (time since last update)
- State check compliance (% of tasks that checked state first)
- Coordination failures due to stale state (should go to zero)
- Time spent on state synchronization (should be minimal)

## Related Items
- PI-006: Shared Roadmap Visibility
- PI-007: Handoff Protocols
- PI-010: Project Health Dashboard

---

**Created by:** @product (subagent)  
**Review Status:** Pending team review
