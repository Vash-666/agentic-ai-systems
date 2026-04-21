# PI-005: Task Templates with Mandatory Sections

**Status:** Backlog  
**Theme:** Efficiency + Security/Trust  
**Priority:** High  
**Created:** April 20, 2026  
**Estimated Effort:** 2-3 hours  
**Related Feedback:** @product

---

## Objective
Create comprehensive task templates with mandatory sections to ensure consistent quality, completeness, and verifiability across all work.

## Background
**Current State:**
- Task definitions vary in quality and completeness
- Missing critical information (artifacts, verification, dependencies)
- Inconsistent structure makes review difficult
- No enforcement of best practices

**Desired State:**
- Every task follows proven template
- All critical sections present
- Easy to review, verify, and execute
- Built-in quality gates

## Scope

### 1. Core Task Template Design
**Effort:** 1 hour

**Mandatory Sections:**
```markdown
# [Task ID]: [Title]

**Status:** [Backlog/In Progress/Blocked/Complete]
**Priority:** [High/Medium/Low]
**Owner:** [@agent]
**Estimated Effort:** [hours]
**Created:** [date]

---

## Objective
[Clear, measurable goal - one sentence]

## Context
[Why this task exists, background, related decisions]

## Scope
[What's included, what's explicitly excluded]
[Numbered list of specific deliverables]

## Required Artifacts
- [ ] `path/to/artifact1.ext` - Description
- [ ] `path/to/artifact2.ext` - Description
[Git commit hash: ______ ]

## Dependencies
**Blocks:** [Tasks that can't start until this completes]
**Blocked By:** [Tasks that must complete first]
**Related:** [Tasks with soft dependencies or context]

## Success Criteria
- [ ] Criterion 1 (verifiable)
- [ ] Criterion 2 (verifiable)
[Include verification method for each]

## Definition of Done
- [ ] All required artifacts created and committed
- [ ] All success criteria met
- [ ] Verification passed (automated + peer review if required)
- [ ] Documentation updated
- [ ] State updated (PI-004)
- [ ] Handoff complete (if applicable)

## Verification
**Automated Checks:**
- [ ] Check 1 (script/command)
- [ ] Check 2 (script/command)

**Manual Verification:**
- [ ] Review item 1
- [ ] Review item 2

**Reviewer:** [@agent] - Sign-off required: [YES/NO]

## Risks & Mitigations
**Risk:** [Potential issue]
**Impact:** [High/Medium/Low]
**Probability:** [High/Medium/Low]
**Mitigation:** [How to address]

## Notes
[Additional context, learnings, decisions made during execution]
```

### 2. Template Variants by Task Type
**Effort:** 2 hours

**Create specialized templates for:**

**A. Development Task Template**
- Code quality requirements
- Testing requirements
- Performance benchmarks
- Documentation requirements

**B. Documentation Task Template**
- Content review checklist
- Audience definition
- Example/screenshot requirements
- Link validation

**C. Review/Validation Task Template**
- Independence requirements
- Validation methodology
- Sign-off criteria
- Artifact tracking

**D. Research Task Template**
- Research questions
- Sources to consult
- Synthesis requirements
- Decision recommendation format

**E. Process Improvement Task Template**
- Problem statement
- Stakeholder input required
- Adoption plan
- Success metrics

### 3. Template Enforcement Mechanism
**Effort:** 1 hour

**Deliverable:**
- Template validation script
- Pre-task checklist (all sections filled?)
- Integration with task creation workflow
- How to request template exceptions

**Validation Script:**
```bash
# validate-task.sh
# Checks that task file has all mandatory sections
# Returns pass/fail + missing sections
```

### 4. Template Repository & Documentation
**Effort:** 30 min

**Deliverable:**
- `templates/` directory with all task templates
- `templates/README.md` - When to use which template
- Template selection guide
- Template customization guidelines

## Success Criteria
- [ ] Core task template designed and approved
- [ ] 5 specialized templates created
- [ ] Validation script working
- [ ] Templates documented in `templates/` directory
- [ ] All new tasks use appropriate template
- [ ] Template compliance: >95% in next sprint
- [ ] Reduction in incomplete/ambiguous tasks

## Priority Rationale
**High** - Foundation for multiple other improvements (PI-001, PI-003, PI-007). Low effort, high impact. Immediately improves quality and reduces rework.

## Dependencies
- None - can implement immediately
- Integrates with: PI-001 (verification), PI-003 (artifacts), PI-004 (state), PI-007 (handoffs)

## Implementation Notes
- Start with core template, add variants incrementally
- Enforce for all new tasks immediately
- Retrofit existing critical tasks
- Review templates after 1 sprint and iterate

## Adoption Strategy
1. **Week 1:** Introduce core template, optional use
2. **Week 2:** Mandatory for all new tasks
3. **Week 3:** Add specialized variants
4. **Week 4:** Full compliance, validation enforced

## Metrics to Track
- Template compliance rate
- Task completion quality (before/after templates)
- Time to review/approve tasks
- Reduction in missing artifacts
- Reduction in ambiguous requirements

## Related Items
- PI-001: Verification Framework (DoD integration)
- PI-003: Artifact-First Workflow (artifact requirements)
- PI-004: State Synchronization (state update in DoD)
- PI-007: Handoff Protocols (handoff in DoD)

---

**Created by:** @product (subagent)  
**Review Status:** Pending team review
