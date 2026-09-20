# Sprint P1-001 — Requirements Document

**Sprint Goal:** Fix quality-score.sh array bugs  
**Duration:** 30 minutes  
**Effort:** 30 min  
**Feature:** 1

---

## Feature: P1-001 — Fix quality-score.sh Array Bugs

### Current State
Script runs but emits errors at end of execution:
```
./scripts/quality-score.sh: line 115: scores[-1]: unbound variable
./scripts/quality-score.sh: line 115: scores: bad array subscript
```

Lines 73, 75, 77 also show integer expression errors.

### Root Cause
- Bash array `scores[-1]` syntax unsupported in older bash versions
- Integer comparison on empty/null variables

### Requirement
Fix script to run cleanly with 0 errors while preserving correct score calculation.

### Acceptance Criteria
- [ ] `./scripts/quality-score.sh` exits with code 0
- [ ] No stderr output (no "unbound variable" or "bad array subscript")
- [ ] Score calculation remains correct (currently 9/10)
- [ ] All existing checks still run (agents, features, docs, git)

### Implementation Notes
- Replace `scores[-1]` with `scores[${#scores[@]}-1]` or track last index
- Add null checks before integer comparisons on lines 73/75/77
- Test on bash 3.2+ (macOS default)

---

## Definition of Done

- [ ] Script runs clean (0 stderr)
- [ ] Score still calculates correctly
- [ ] validate-system.sh still passes
- [ ] Git commit: "P1-001: Fix quality-score.sh array bugs"
- [ ] @quality verifies (or sign-off file on disk)

---

*Requirements by @product*  
*Sprint P1-001 — Quality Script Fix*
