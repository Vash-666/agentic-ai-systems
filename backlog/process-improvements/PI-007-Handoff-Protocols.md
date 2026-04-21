# PI-007: Explicit Handoff Protocols

**Status:** Backlog  
**Theme:** Coordination  
**Priority:** High  
**Created:** April 20, 2026  
**Estimated Effort:** 2-3 hours  
**Related Feedback:** @product

---

## Objective
Establish clear, explicit handoff protocols to ensure smooth transitions between agents and prevent dropped context or work.

## Background
**Current Problem:**
- Handoffs are implicit and informal
- Context gets lost in transitions
- Receiving agent doesn't know what's expected
- No verification that handoff is complete
- Unclear accountability

**Desired State:**
- Explicit handoff trigger and acknowledgment
- Complete context transfer
- Clear expectations for receiving agent
- Verification before handoff accepted
- Traceable handoff history

## Scope

### 1. Handoff Protocol Design
**Effort:** 1 hour

**Core Handoff Elements:**
```markdown
## Handoff Template

**From:** [@sending_agent]  
**To:** [@receiving_agent]  
**Date:** [timestamp]  
**Task/Context:** [What's being handed off]

### Work Completed
- [Summary of what was done]
- [Key decisions made]
- [Artifacts created with paths]
- [Git commit: abc123]

### Current State
- [Where things stand now]
- [What's working]
- [What's not working / known issues]

### What's Needed Next
- [ ] Action item 1 (verifiable)
- [ ] Action item 2 (verifiable)
- [ ] Decision needed on X by [date]

### Context & Background
- [Why this work was done]
- [Related discussions/decisions]
- [Who to consult for questions]
- [Reference materials/links]

### Dependencies & Blockers
- [What this work depends on]
- [What might block next steps]
- [Coordination needed with other agents]

### Success Criteria for Next Phase
- [ ] Criterion 1
- [ ] Criterion 2

### Verification Checklist (Sending Agent)
- [ ] All artifacts committed to git
- [ ] State updated (PI-004)
- [ ] Documentation current
- [ ] No loose ends
- [ ] Receiving agent has access to all needed resources

### Acceptance Checklist (Receiving Agent)
- [ ] Context understood
- [ ] All artifacts accessible
- [ ] Questions answered
- [ ] Ready to proceed
- [ ] Acknowledged handoff (signature/timestamp)

**Handoff Status:** [OFFERED / ACCEPTED / REJECTED - CLARIFICATION NEEDED]
```

### 2. Handoff Workflow Integration
**Effort:** 1 hour

**Deliverable:**
- When handoffs are required (task completion, agent change, sprint boundary)
- How to initiate handoff (create handoff document, notify receiving agent)
- Handoff acceptance criteria
- Handoff rejection/clarification process
- Handoff tracking (where handoff documents live)

**Handoff Triggers:**
- Task completion → Next task owner
- Sprint end → Next sprint owner
- Specialist work needed → Specialist agent
- External dependency resolution → Original requester
- Escalation → Higher authority

### 3. Handoff Repository & Tracking
**Effort:** 30 min

**Deliverable:**
- `handoffs/` directory structure
- Naming convention: `handoffs/YYYYMMDD-from-to-topic.md`
- Handoff index/log
- Integration with project state (PI-004)

**Handoff Index Example:**
```markdown
# Handoff Log - P001

| Date | From | To | Topic | Status | File |
|------|------|----|----|--------|------|
| 2026-04-20 | @switch | @quality | Day 3 Validation | ACCEPTED | handoffs/20260420-switch-quality-day3-validation.md |
| 2026-04-21 | @quality | @product | Quality Report | ACCEPTED | handoffs/20260421-quality-product-quality-report.md |
```

### 4. Weekly Priority Sync Integration
**Effort:** 1 hour

**Deliverable:**
- Weekly sync meeting agenda template
- How handoffs inform priorities
- How roadmap (PI-006) informs handoffs
- Sync output: updated priorities + planned handoffs
- Integration with state sync (PI-004)

**Weekly Sync Agenda:**
```markdown
# Weekly Priority Sync - [Date]

**Attendees:** @product, @quality, @content, @switch

## 1. Review Last Week (15 min)
- Completed handoffs
- Blocked handoffs
- Surprises or deviations

## 2. Active Work Review (15 min)
- Current task status
- Upcoming handoffs this week
- Blockers or risks

## 3. Next Week Planning (20 min)
- Roadmap review (PI-006)
- Priority adjustments
- Planned handoffs
- Resource allocation

## 4. Process Check (10 min)
- What's working in handoffs?
- What needs improvement?
- Action items for process

## Outputs
- [ ] Updated priorities committed
- [ ] Planned handoffs documented
- [ ] Roadmap adjusted if needed
- [ ] State synchronized (PI-004)
```

## Success Criteria
- [ ] Handoff protocol documented
- [ ] Handoff template created and available
- [ ] Handoff repository established
- [ ] Weekly sync process defined
- [ ] All handoffs use standard protocol: >90%
- [ ] Handoff acceptance rate: >95% first attempt
- [ ] Zero dropped context incidents
- [ ] Handoff time: <30 min average

## Priority Rationale
**High** - Addresses major coordination pain points. Prevents work loss and context drops. Foundation for effective multi-agent collaboration. Relatively low effort, high impact.

## Dependencies
- PI-004: State Synchronization (state update in handoff)
- PI-006: Shared Roadmap (roadmap informs handoffs)

## Implementation Notes
- Start with template, use for all handoffs immediately
- Track handoff quality for 1 sprint
- Iterate based on feedback
- Keep it lightweight - don't create bureaucracy

## Risks & Mitigations
**Risk:** Handoffs become too heavyweight  
**Mitigation:** Template is maximum, use what's needed, <30 min target

**Risk:** Agents skip handoff protocol  
**Mitigation:** Make it a DoD requirement (PI-005), track compliance

**Risk:** Receiving agent doesn't accept handoff  
**Mitigation:** Clarification process, sending agent stays accountable until accepted

## Metrics to Track
- Handoff completion rate
- Handoff acceptance rate (first attempt)
- Time to handoff completion
- Context loss incidents (should go to zero)
- Agent satisfaction with handoffs

## Related Items
- PI-002: Peer Review Protocol (review can be part of handoff)
- PI-004: State Synchronization (handoff updates state)
- PI-005: Task Templates (handoff in DoD)
- PI-006: Shared Roadmap (informs handoffs)
- PI-009: Post-Mortem Practice (handoff issues in retrospective)

---

**Created by:** @product (subagent)  
**Review Status:** Pending team review
