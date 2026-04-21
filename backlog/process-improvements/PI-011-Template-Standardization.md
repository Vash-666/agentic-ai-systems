# PI-011: Template Standardization & Collaborative Documentation

**Status:** Backlog  
**Theme:** Efficiency + Coordination  
**Priority:** Medium  
**Created:** April 20, 2026  
**Estimated Effort:** 2-3 hours  
**Related Feedback:** @content

---

## Objective
Standardize documentation templates and establish collaborative documentation practices to improve consistency, reduce overhead, and enable better knowledge sharing.

## Background
**Current State:**
- Inconsistent documentation formats
- Each agent invents their own structure
- Hard to find information across documents
- Duplication and contradictions
- No collaborative editing workflow

**Desired State:**
- Standard templates for common document types
- Consistent structure and formatting
- Easy to navigate and search
- Collaborative editing with version control
- Single source of truth per topic

## Scope

### 1. Core Documentation Templates
**Effort:** 1.5 hours

**Create standard templates for:**

**A. Project Documentation**
- Project PRD (already exists, but standardize)
- Project Plan / Sprint Plan
- Architecture Documentation
- API Documentation
- User Guide / README

**B. Process Documentation**
- Process Description (how we do X)
- Workflow Guide (step-by-step)
- Checklist Template
- Meeting Notes Template
- Decision Log Template

**C. Artifact Documentation**
- Code Documentation (inline + external)
- Test Documentation
- Verification Report Template
- Post-Mortem Template (PI-009)
- Handoff Template (PI-007)

**Template Structure (Meta-template):**
```markdown
# [Template Name]

**Purpose:** [One sentence: why this template exists]  
**When to Use:** [Situations where you should use this template]  
**Owner/Maintainer:** [Who keeps this template updated]

---

## Template Sections

### Section 1: [Name]
**Purpose:** [Why this section matters]  
**Required/Optional:** [Is this section mandatory?]

[Guidance on what to include]

### Section 2: [Name]
[...]

---

## Example

[Filled-in example of this template]

---

## Customization Notes

[How to adapt this template for specific situations]
[What can be omitted, what must stay]
```

### 2. Template Repository & Discovery
**Effort:** 30 min

**Deliverable:**
- `templates/` directory with all templates
- `templates/README.md` - Template catalog and index
- Template selection guide ("Which template should I use?")
- Template version tracking

**Template Catalog Example:**
```markdown
# Template Catalog

## Project Templates
- [PRD Template](prd-template.md) - Product requirements
- [Sprint Plan Template](sprint-plan-template.md) - Sprint planning
- [Architecture Doc Template](architecture-template.md) - System design

## Process Templates
- [Process Description Template](process-template.md) - How we do X
- [Workflow Template](workflow-template.md) - Step-by-step guide
- [Decision Log Template](decision-log-template.md) - Record key decisions

## Artifact Templates
- [Verification Report Template](verification-report-template.md) - Test results
- [Post-Mortem Template](post-mortem-template.md) - Retrospectives
- [Handoff Template](handoff-template.md) - Work transitions

## How to Choose a Template
[Decision tree or guidelines]
```

### 3. Collaborative Documentation Workflow
**Effort:** 1 hour

**Deliverable:**
- Collaborative editing guidelines
- Version control practices
- Conflict resolution process
- Multi-author attribution
- Documentation ownership model

**Collaborative Documentation Principles:**

**Single Source of Truth:**
- One canonical document per topic
- All references link to SSOT
- Updates happen at SSOT, propagate via links
- Avoid duplication

**Version Control:**
- All documents in git
- Meaningful commit messages
- Branch for major revisions (optional)
- Git history is audit trail

**Multi-Author Workflow:**
```markdown
# Collaborative Editing Workflow

## For Minor Updates (typos, clarifications)
1. Edit directly
2. Commit with clear message: "Fix: corrected X in Y.md"
3. Tag original author if significant change

## For Major Revisions
1. Create `[doc-name]-draft-v2.md` or use git branch
2. Notify stakeholders of proposed changes
3. Gather feedback
4. Merge when approved
5. Archive old version if needed

## For Collaborative Authoring (multiple agents, new doc)
1. Create outline first, agree on structure
2. Assign sections to agents
3. Each agent writes their section
4. Primary author integrates and harmonizes
5. All co-authors review
6. Final approval and commit
```

**Attribution Standards:**
```markdown
# Document Title

**Primary Author:** [@agent] [date]  
**Contributors:** [@agent1], [@agent2]  
**Last Updated:** [date] by [@agent]  
**Version:** 2.1

[... content ...]

---

## Revision History
- v2.1 (2026-04-20) [@agent] - Added section on X
- v2.0 (2026-04-15) [@agent] - Major restructure
- v1.0 (2026-04-10) [@agent] - Initial version
```

### 4. Documentation Maintenance
**Effort:** 30 min

**Deliverable:**
- Documentation freshness tracking
- Periodic review schedule
- Deprecation and archival process
- Link validation and maintenance

**Documentation Maintenance Plan:**
- **Monthly:** Review high-traffic documents for freshness
- **Quarterly:** Full template review and updates
- **On-demand:** Update when process changes
- **Automated:** Link checking, broken reference detection

## Success Criteria
- [ ] Core documentation templates created (10+ templates)
- [ ] Template catalog published and accessible
- [ ] Collaborative documentation workflow documented
- [ ] All new documents use appropriate template: >90%
- [ ] Template compliance reduces documentation time by 30%
- [ ] Knowledge findability improved (survey)
- [ ] Documentation consistency: high (peer assessment)

## Priority Rationale
**Medium** - Important for long-term efficiency and knowledge management, but not immediately blocking. Can be implemented incrementally alongside other PI items. Many templates already implicit in PI-001 through PI-010.

## Dependencies
- PI-003: Artifact-First Workflow (documentation is artifacts)
- PI-005: Task Templates (task template is one type)
- PI-007: Handoff Protocols (handoff template)
- PI-008: Content Review Protocol (content brief template)
- PI-009: Post-Mortem Practice (post-mortem template)

## Implementation Notes
- Many templates already created in other PI items
- Focus here is on consolidation, standardization, and discovery
- Start by collecting existing templates, standardizing format
- Add missing templates incrementally
- Socialize template catalog to encourage adoption

## Quick Win Strategy
1. **Week 1:** Create template catalog from existing templates in PI items
2. **Week 2:** Standardize format across all templates
3. **Week 3:** Add 3-5 missing templates
4. **Week 4:** Full adoption, measure compliance

## Risks & Mitigations
**Risk:** Template proliferation (too many templates)  
**Mitigation:** Keep template catalog curated, retire unused templates

**Risk:** Templates become rigid, stifle creativity  
**Mitigation:** Emphasize "adapt as needed", templates are starting point not straitjacket

**Risk:** Templates not adopted  
**Mitigation:** Lead by example, make them easy to find and use, show value

## Metrics to Track
- Template adoption rate (% of docs using templates)
- Time to create documentation (before/after templates)
- Documentation consistency score
- Template usage by type (which are most valuable?)
- Documentation findability (search effectiveness)

## Related Items
- PI-003: Artifact-First Workflow
- PI-005: Task Templates
- PI-007: Handoff Protocols
- PI-008: Content Review Protocol
- PI-009: Post-Mortem Practice

---

**Created by:** @product (subagent)  
**Review Status:** Pending team review

**Note:** This PI item serves as a consolidation and standardization layer over templates created in other PI items. Focus on discoverability and consistency rather than creating net-new templates.
