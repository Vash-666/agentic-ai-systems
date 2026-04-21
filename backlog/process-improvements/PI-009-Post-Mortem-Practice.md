# PI-009: Post-Mortem as Standard Practice

**Status:** Backlog  
**Theme:** Efficiency + Security/Trust  
**Priority:** Medium  
**Created:** April 20, 2026  
**Estimated Effort:** 2 hours  
**Related Feedback:** @product

---

## Objective
Establish post-mortem retrospectives as standard practice after major milestones or incidents to capture learnings and improve processes.

## Background
**Current State:**
- No systematic learning from successes or failures
- Same mistakes repeated
- Good practices not documented or shared
- Valuable context lost over time

**Desired State:**
- After every major milestone or incident: formal retrospective
- Learnings captured and actionable
- Process improvements identified and tracked
- Continuous improvement culture

## Scope

### 1. Post-Mortem Triggers
**Effort:** 30 min

**When to conduct post-mortems:**

**Mandatory:**
- After project completion (success or failure)
- After major milestone (v1, v2 launch, etc.)
- After significant incident (quality failure, missed deadline, coordination breakdown)
- After sprint/phase completion

**Optional:**
- After learning a hard lesson (judgment call)
- After trying new process/tool
- Quarterly team retrospective

### 2. Post-Mortem Template
**Effort:** 1 hour

**Create standard template:**
```markdown
# Post-Mortem: [Project/Incident Name]

**Date:** [date]  
**Facilitator:** [@product or designated lead]  
**Participants:** [@agent1, @agent2, ...]  
**Type:** [Project Completion / Incident / Sprint Retro]

---

## Summary
[One paragraph: what happened, outcome, key takeaway]

## Timeline
[For incidents: sequence of events]
[For projects: major phases and dates]

**Start:** [date/time]  
**Key Events:**
- [timestamp] - [event]
- [timestamp] - [event]
**Resolution/Completion:** [date/time]

---

## What Went Well ✅
[Celebrate successes, identify practices to keep]

1. [Success 1]
   - Why it worked
   - How to repeat

2. [Success 2]
   - Why it worked
   - How to repeat

---

## What Went Wrong ❌
[Identify problems without blame, focus on systems and processes]

1. [Issue 1]
   - What happened
   - Impact
   - Root cause (the "why behind the why")
   - Contributing factors

2. [Issue 2]
   - What happened
   - Impact
   - Root cause
   - Contributing factors

---

## Lessons Learned 💡
[Distilled insights that apply beyond this specific situation]

1. [Lesson 1]
2. [Lesson 2]
3. [Lesson 3]

---

## Action Items 🎯
[Specific, actionable improvements - must have owner and deadline]

| Action | Owner | Deadline | Status | Related PI Item |
|--------|-------|----------|--------|-----------------|
| [Action 1] | [@agent] | [date] | [ ] | PI-XXX |
| [Action 2] | [@agent] | [date] | [ ] | PI-YYY |

---

## Metrics & Evidence
[Quantitative data supporting analysis]

**Quality Metrics:**
- [Metric 1]: [value]
- [Metric 2]: [value]

**Performance Metrics:**
- [Metric 1]: [value]
- [Metric 2]: [value]

**Process Metrics:**
- [Metric 1]: [value]
- [Metric 2]: [value]

---

## References
- [Link to project plan]
- [Link to artifacts]
- [Link to related post-mortems]

---

**Post-Mortem Status:** [DRAFT / REVIEW / APPROVED]  
**Follow-up Date:** [When to review action items]  
**Approver:** [@product] [date]
```

### 3. Post-Mortem Workflow
**Effort:** 30 min

**Deliverable:**
- Who initiates post-mortem (anyone can propose, @product facilitates)
- When to schedule (within 1 week of trigger event)
- How to conduct (async or sync)
- Participant selection
- Documentation requirements
- Action item tracking

**Post-Mortem Process:**
1. **Trigger Event** → Identified
2. **Scheduling** → Within 1 week, @product facilitates
3. **Preparation** → Participants gather data, notes
4. **Retrospective Session** → 1 hour, blameless, structured
5. **Documentation** → Post-mortem written using template
6. **Action Items** → Converted to backlog items (PI-XXX format)
7. **Follow-up** → Review action items at next weekly sync

### 4. Post-Mortem Repository & Index
**Effort:** 30 min

**Deliverable:**
- `post-mortems/` directory
- Naming: `post-mortems/YYYYMMDD-topic.md`
- Post-mortem index with categories
- Integration with process improvement backlog

**Post-Mortem Index Example:**
```markdown
# Post-Mortem Index

## 2026 Q2

### Project Completions
- [2026-04-20: P001 Day 3 Quality Failure](post-mortems/20260420-p001-day3-quality-failure.md)
  - Action Items: PI-001, PI-002, PI-004
  - Status: Actions in progress

### Incidents
- [TBD: Example incident](post-mortems/...)

### Sprint Retrospectives
- [TBD: Sprint 1 Retro](post-mortems/...)
```

## Success Criteria
- [ ] Post-mortem template created
- [ ] Post-mortem workflow documented
- [ ] Post-mortem repository established
- [ ] First post-mortem completed (Day 3 Quality Failure)
- [ ] Post-mortem conducted after all major milestones: 100%
- [ ] Action items from post-mortems tracked to completion: >80%
- [ ] Same mistake not repeated: measurable improvement

## Priority Rationale
**Medium** - Important for long-term learning and improvement, but not immediately blocking. Should start with Day 3 retrospective, then make it standard practice.

## Dependencies
- None - can implement immediately
- Feeds into: All process improvement items (PI-001 through PI-011)

## Implementation Notes
- Start with Day 3 quality failure as first post-mortem
- Make it blameless and learning-focused
- Keep it time-boxed (1 hour max)
- Focus on actionable improvements
- Track action items to completion

## Quick Start: Day 3 Post-Mortem
**Immediate Action:**
- Schedule post-mortem for Day 3 quality failure
- Participants: @product, @quality, @switch, @content
- Topic: Why quality validation failed, how to prevent
- Expected output: This entire PI backlog is partly derived from that retrospective

## Risks & Mitigations
**Risk:** Post-mortems become blame sessions  
**Mitigation:** Blameless culture, focus on systems not people, facilitator enforcement

**Risk:** Action items not completed  
**Mitigation:** Track in backlog with owners/deadlines, review at weekly sync

**Risk:** Post-mortems seen as overhead  
**Mitigation:** Keep time-boxed, show value through improvements, celebrate learnings

## Metrics to Track
- Post-mortem completion rate (after trigger events)
- Action item completion rate
- Time to post-mortem (from trigger event)
- Quality of learnings (surveyed value)
- Repeat issues (should decrease over time)

## Related Items
- All PI items (001-011) - Post-mortems generate improvement backlog
- PI-007: Weekly Priority Sync (action item review)

---

**Created by:** @product (subagent)  
**Review Status:** Pending team review

**Note:** A post-mortem for Day 3 quality failure should be scheduled immediately to demonstrate this practice and generate additional insights.
