# PI-003: Artifact-First Workflow

**Status:** Backlog  
**Theme:** Security/Trust + Coordination  
**Priority:** Medium  
**Created:** April 20, 2026  
**Estimated Effort:** 3-4 hours  
**Related Feedback:** @quality, @content

---

## Objective
Shift from conversation-based to artifact-based workflows, ensuring all work produces tangible, verifiable deliverables.

## Background
**Current Issue:**
- Work happens in chat/memory
- Hard to verify what was actually done
- Knowledge scattered across sessions
- Difficult to audit or review

**Desired State:**
- Every task produces artifacts
- Artifacts are the source of truth
- Easy to verify, review, and reference
- Clear audit trail

## Scope

### 1. Artifact-First Culture Guidelines
**Effort:** 1 hour  
**Source:** @quality, @content

**Deliverable:**
- Update AGENTS.md with artifact-first principles
- Define what counts as an artifact
- When artifacts are required vs optional
- How to name and organize artifacts

**Key Principle:**
> "If it wasn't written to a file, it didn't happen."

### 2. Artifact Linking Standards
**Effort:** 1 hour  
**Source:** @content

**Deliverable:**
- Standard format for linking artifacts
- Cross-reference conventions
- How to maintain artifact relationships
- Broken link detection/prevention

**Example:**
```markdown
**Related Artifacts:**
- Requirement: `products/project-scaffolding-engine-prd.md`
- Implementation: `verification/t3.3-quality-scores.json`
- Report: `verification/t3.3-validation-report.txt`
- Git: commit `abc123`
```

### 3. Task Templates with Artifact Requirements
**Effort:** 2 hours  
**Source:** @product

**Deliverable:**
- Update task template to include:
  - Required artifacts (by name/path)
  - Optional artifacts
  - Artifact validation criteria
  - Where to store artifacts
- Templates for common task types:
  - Development task
  - Documentation task
  - Review task
  - Research task

**Template Enhancement:**
```markdown
## Deliverables
**Required Artifacts:**
- [ ] `path/to/artifact.md` - Description
- [ ] `verification/task-validation.json` - Automated checks

**Optional Artifacts:**
- [ ] `notes/research-notes.md` - Background research

**Artifact Validation:**
- All files exist at specified paths
- All files committed to git with clear message
- Links between artifacts valid
- Automated checks pass (if applicable)
```

### 4. Documentation-First Culture
**Effort:** 1 hour  
**Source:** @content

**Deliverable:**
- Guidelines for when documentation is required
- Documentation templates for common scenarios
- Integration with artifact-first workflow
- Documentation review checklist

## Success Criteria
- [ ] AGENTS.md updated with artifact-first principles
- [ ] Task templates include artifact requirements
- [ ] Artifact linking standards documented
- [ ] All tasks in next sprint produce verifiable artifacts
- [ ] Artifact completion rate: >95%
- [ ] Zero "lost work" incidents

## Priority Rationale
**Medium** - Important for long-term sustainability but not immediately blocking. Builds on PI-001 and PI-002. Can be adopted incrementally.

## Dependencies
- PI-001: Verification Framework (artifact validation)
- PI-005: Task Templates (integration point)

## Implementation Notes
- Start by making artifact requirements explicit in task templates
- Gradually shift culture through consistent enforcement
- Lead by example - every process improvement produces artifacts
- Measure adoption and provide feedback

## Metrics to Track
- % of tasks with all required artifacts
- % of artifacts with valid cross-references
- Time saved in audits/reviews
- Reduction in "where is that?" questions

## Related Items
- PI-001: Verification Framework
- PI-005: Task Templates
- PI-008: Content Review Protocol
- PI-011: Collaborative Documentation

---

**Created by:** @product (subagent)  
**Review Status:** Pending team review
