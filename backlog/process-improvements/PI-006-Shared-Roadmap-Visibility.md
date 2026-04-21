# PI-006: Shared Roadmap Visibility

**Status:** Backlog  
**Theme:** Coordination  
**Priority:** Medium  
**Created:** April 20, 2026  
**Estimated Effort:** 2-3 hours  
**Related Feedback:** @product

---

## Objective
Create a shared, always-current roadmap that gives all agents visibility into project direction, priorities, and upcoming work.

## Background
**Current Problem:**
- Agents don't know what's coming next
- Hard to plan or prepare
- Surprises lead to inefficiency
- No shared understanding of priorities

**Desired State:**
- Everyone sees the same roadmap
- Clear priorities and timelines
- Easy to understand what's next
- Enables proactive preparation

## Scope

### 1. Roadmap Structure & Format
**Effort:** 1 hour

**Deliverable:**
- Define roadmap timeframes:
  - **Now:** Current sprint (this week)
  - **Next:** Next sprint (next week)
  - **Soon:** Next 2-4 weeks
  - **Later:** Beyond 1 month
- Roadmap file format (Markdown table or JSON)
- What information to include per item
- How to indicate priority/status

**Example Roadmap Format:**
```markdown
# P001 Project Roadmap

**Last Updated:** 2026-04-20 by @product

## Now (Week of April 21)
| Priority | Item | Owner | Status | Target |
|----------|------|-------|--------|--------|
| 🔴 HIGH | v2 Launch - Quality Gates | @switch | In Progress | Apr 21 |
| 🔴 HIGH | v2 Launch - Test Framework | @switch | In Progress | Apr 21 |
| 🟡 MED | Documentation - Quick Start | @content | Planned | Apr 21 |

## Next (Week of April 28)
| Priority | Item | Owner | Status | Target |
|----------|------|-------|--------|--------|
| 🔴 HIGH | Beta Testing & Feedback | @product | Planned | Apr 28 |
| 🟡 MED | Process Improvements (PI-001-005) | TBD | Planned | Apr 30 |
| 🟢 LOW | Additional Template (Python) | TBD | Backlog | May 2 |

## Soon (May 2026)
- Template library expansion (3-5 new templates)
- Performance optimization phase
- User onboarding improvements
- Analytics integration

## Later (Beyond May)
- Multi-language support
- Cloud deployment templates
- Plugin system
- Community templates
```

### 2. Roadmap Update Process
**Effort:** 1 hour

**Deliverable:**
- Who can update roadmap (@product owns)
- When roadmap is updated (after major milestones, weekly sync)
- How changes are communicated (announcement + commit)
- Integration with weekly priority sync (PI-007)

**Update Triggers:**
- After sprint completion
- After major milestone
- Weekly sync meeting
- Significant priority shift
- New strategic decision

### 3. Roadmap Visibility & Access
**Effort:** 30 min

**Deliverable:**
- Roadmap file location: `roadmap/P001-roadmap.md`
- How agents access roadmap (startup context? link in AGENTS.md?)
- When to check roadmap (task planning, before proposing work)
- Roadmap change notifications

### 4. Integration with Project Health Dashboard
**Effort:** 1 hour

**Deliverable:**
- Link roadmap items to current state (PI-004)
- Show progress against roadmap in dashboard (PI-010)
- Roadmap burn-down or completion tracking
- Highlight roadmap risks or delays

## Success Criteria
- [ ] Roadmap structure and format defined
- [ ] Initial P001 roadmap created
- [ ] Roadmap update process documented
- [ ] All agents aware of roadmap location
- [ ] Roadmap checked before task planning: >80%
- [ ] Roadmap update frequency: weekly minimum
- [ ] Agents report improved clarity on direction

## Priority Rationale
**Medium** - Important for coordination and planning, but not immediately blocking current work. Complements PI-004 (state sync) and PI-007 (priority sync).

## Dependencies
- None - can implement independently
- Enhances: PI-004 (State Sync), PI-007 (Priority Sync), PI-010 (Dashboard)

## Implementation Notes
- Start simple - Markdown table in `roadmap/` directory
- @product maintains, updates weekly
- Include in AGENTS.md as standard reference
- Link from sprint plans

## Risks & Mitigations
**Risk:** Roadmap gets stale  
**Mitigation:** Weekly update commitment, integrate with sprint cycle

**Risk:** Roadmap too detailed (becomes micro-management)  
**Mitigation:** Keep to major milestones only, 2-week granularity max

**Risk:** Roadmap conflicts with reality  
**Mitigation:** Weekly review, adjust roadmap to reality (not the reverse)

## Metrics to Track
- Roadmap freshness (days since last update)
- Roadmap accuracy (% of items completed on target)
- Agent roadmap consultation rate
- Surprise work (unplanned items) percentage
- Agent confidence in direction (survey)

## Related Items
- PI-004: State Synchronization (current state)
- PI-007: Weekly Priority Sync (roadmap input)
- PI-010: Project Health Dashboard (roadmap visualization)

---

**Created by:** @product (subagent)  
**Review Status:** Pending team review
