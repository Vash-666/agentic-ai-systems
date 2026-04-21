# PI-008: Content Review Protocol

**Status:** Backlog  
**Theme:** Coordination + Security/Trust  
**Priority:** Medium  
**Created:** April 20, 2026  
**Estimated Effort:** 2 hours  
**Related Feedback:** @content

---

## Objective
Establish systematic content review before external publishing to ensure quality, accuracy, and brand consistency.

## Background
**Current Issue:**
- Content published without review
- Risk of factual errors or tone mismatches
- Inconsistent quality in external materials
- No verification of claims or links

**Desired State:**
- All external content reviewed before publishing
- Factual accuracy verified
- Brand voice consistent
- Links and references validated

## Scope

### 1. Content Review Requirements
**Effort:** 30 min

**Define "External Content":**
- Blog posts, documentation, README files
- Social media posts
- Marketing materials
- User-facing communications
- Public presentations

**Review Threshold:**
- **Mandatory Review:** All external content
- **Optional Review:** Internal documentation (recommended)
- **Expedited Review:** Time-sensitive content (2-hour SLA)

### 2. Content Review Checklist
**Effort:** 1 hour

**Create comprehensive checklist:**
```markdown
# Content Review Checklist

**Content Title:** [title]  
**Author:** [@agent]  
**Reviewer:** [@agent]  
**Target Audience:** [who will read this]  
**Publication Channel:** [where it goes]  
**Review Date:** [date]

## Factual Accuracy
- [ ] All claims verified against source material
- [ ] Statistics and numbers double-checked
- [ ] Technical details reviewed by subject matter expert
- [ ] No hallucinated information
- [ ] Sources cited where appropriate

## Quality & Clarity
- [ ] Clear, understandable language for target audience
- [ ] Logical flow and structure
- [ ] No jargon without explanation
- [ ] Grammar and spelling correct
- [ ] Formatting consistent

## Links & References
- [ ] All links valid and working
- [ ] Links point to correct resources
- [ ] Internal links use correct paths
- [ ] External links to reputable sources
- [ ] Artifact links valid (PI-003)

## Brand & Tone
- [ ] Voice consistent with brand
- [ ] Tone appropriate for audience and channel
- [ ] Professional and respectful
- [ ] No confidential information disclosed
- [ ] Legal/compliance requirements met (if applicable)

## Completeness
- [ ] All promised content included
- [ ] Examples/screenshots present if needed
- [ ] Call-to-action clear (if applicable)
- [ ] Contact/support information correct

## Special Considerations
- [ ] Accessibility considerations (if applicable)
- [ ] SEO optimization (if applicable)
- [ ] Cross-platform compatibility (if multi-channel)
- [ ] Version/date information included

**Review Outcome:** [APPROVED / APPROVED WITH CHANGES / REJECTED]

**Reviewer Notes:**
[Feedback, suggestions, required changes]

**Reviewer Signature:** [@agent] [timestamp]
```

### 3. Content Review Workflow
**Effort:** 1 hour

**Deliverable:**
- How to request content review
- Review assignment (who reviews what)
- Review timeline expectations
- Revision process
- Approval and publishing workflow

**Workflow Steps:**
1. **Author completes draft** → Marks as "Ready for Review"
2. **Review request** → Notifies assigned reviewer (via handoff protocol)
3. **Review conducted** → Reviewer uses checklist, provides feedback
4. **Revisions** (if needed) → Author addresses feedback
5. **Final approval** → Reviewer signs off
6. **Publication** → Author publishes with review record

**Review SLA:**
- Standard: 24 hours
- Expedited: 2 hours (for time-sensitive content)
- Complex: 48 hours (for technical deep-dives)

### 4. Content Brief Format
**Effort:** 30 min

**Deliverable:**
- Standard content brief template
- When to create a brief (before writing)
- What to include in brief
- Brief approval before starting

**Content Brief Template:**
```markdown
# Content Brief: [Title]

**Author:** [@agent]  
**Reviewer (assigned):** [@agent]  
**Created:** [date]  
**Target Publish Date:** [date]

## Purpose
[Why this content is being created]

## Target Audience
[Who will read/use this]

## Key Messages
- [Point 1]
- [Point 2]
- [Point 3]

## Outline
1. [Section 1]
2. [Section 2]
3. [Section 3]

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Related Artifacts
- [Links to source material, related content]

## Constraints
- Word count: [if applicable]
- Tone: [formal/casual/technical]
- Format: [blog/doc/guide/post]

**Brief Approved:** [@product or relevant stakeholder] [date]
```

## Success Criteria
- [ ] Content review checklist created
- [ ] Review workflow documented
- [ ] Content brief template available
- [ ] All external content reviewed before publishing: 100%
- [ ] Review turnaround time: <24 hours average
- [ ] Content quality incidents: zero
- [ ] Author/reviewer satisfaction: high

## Priority Rationale
**Medium** - Important for external quality and brand protection, but current volume of external content is low. Can implement incrementally starting with high-visibility content.

## Dependencies
- PI-002: Peer Review Protocol (content review is a specialized peer review)
- PI-003: Artifact-First Workflow (artifact linking in content)
- PI-007: Handoff Protocols (review request workflow)

## Implementation Notes
- Start with mandatory review for all external content
- Assign @content as default reviewer
- Track review quality and turnaround time
- Iterate checklist based on issues found

## Risks & Mitigations
**Risk:** Review becomes bottleneck  
**Mitigation:** Clear SLA, expedited process, multiple reviewers if needed

**Risk:** Reviews become rubber-stamp  
**Mitigation:** Checklist enforcement, spot-check review quality

**Risk:** Conflict between author and reviewer  
**Mitigation:** Escalation path to @product, focus on improvement not blame

## Metrics to Track
- Content review coverage (% reviewed before publishing)
- Review turnaround time (by priority level)
- Revision cycles per piece
- Issues found in review (factual, quality, links)
- Published content quality incidents

## Related Items
- PI-002: Peer Review Protocol
- PI-003: Artifact-First Workflow
- PI-007: Handoff Protocols
- PI-011: Collaborative Documentation

---

**Created by:** @product (subagent)  
**Review Status:** Pending team review
