# PHASE 5 — HYGIENE TABLE

**Date:** 2026-09-17  
**Status:** NO DELETIONS MADE  
**Produced by:** @switch (@product unavailable)

---

## Cut/Keep Table

| Path | Action | Why | Risk |
|------|--------|-----|------|
| `archive/old-blockchain/**/node_modules` | **gitignore** | node_modules in archived blockchain project. Already archived, but should not be committed to git. | Low — already in archive/ |
| `archive/old-blockchain/TENNIS-TROPHY-TOKENIZATION/frontend/node_modules/**` | **gitignore** | Deeply nested node_modules (10+ levels). Not used. | Low — archived |
| `v3/scripts/implementations/04-fact-extractor.py` | **delete** | Superseded by `04-fact-extractor-v2.py`. Duplicate functionality. | Low — v2 is the improved version |
| `v3/scripts/implementations/fact_extractor.py` | **delete** | Superseded by `04-fact-extractor-v2.py`. Naming inconsistency. | Low — v2 is the improved version |
| `v3/scripts/implementations/fact_extractor_v2.py` | **delete** | Superseded by `04-fact-extractor-v2.py`. Naming inconsistency. | Low — v2 is the improved version |
| `v3/blog-post-v3-launch.md` | **keep** | Marketing copy, but metrics are unverified. Add disclaimer or update with real numbers. | Medium — claims 9.15/10, 21x, 92% without evidence |
| `v3/README.md` | **keep** | Core documentation. Update to remove "100%" claims or add test suite reference. | Low — README is accurate about structure |
| `v3/scripts/implementations/02-reducers.py` | **keep** | Standalone but tested. Wire to startup in future. | Low — functional, just not wired |
| `v3/scripts/implementations/03-scoped-memory.py` | **keep** | Standalone but tested. Wire to startup in future. | Low — functional, just not wired |
| `v3/scripts/implementations/05-composite-recall.py` | **keep** | Standalone but tested. Wire to startup in future. | Low — functional, just not wired |
| `v3/scripts/implementations/06-arc-compaction.py` | **keep** | Standalone but tested. Wire to startup in future. | Low — functional, just not wired |
| `v3/verticals/oak-and-iron/site/` | **keep** | Phase 4 vertical output. QA score 8.7/10. | Low — demo project, not deployed |
| `v3/verticals/oak-and-iron/qa-report.md` | **keep** | Historical QA (7.7/10). Shows progression. | Low — v2 report is the current one |
| `v3/verticals/oak-and-iron/qa-report-v2.md` | **keep** | Current QA (8.7/10). Evidence of fixes. | Low — needed for audit trail |
| `v3/docs/maturity/PHASE-1-AUDIT.md` | **keep** | Audit trail. Shows honest assessment. | Low — documentation |
| `v3/docs/maturity/PHASE-2-WIRING.md` | **keep** | Audit trail. Shows what was wired. | Low — documentation |
| `v3/docs/maturity/PHASE-3-EVAL.md` | **keep** | Audit trail. Shows test results. | Low — documentation |
| `v3/docs/maturity/PHASE-4-VERTICAL.md` | **keep** | Audit trail. Shows vertical run. | Low — documentation |
| `v3/docs/maturity/PHASE-5-HYGIENE.md` | **keep** | This file. | Low — documentation |
| `tools/automated-health-monitor.sh~Stashed changes` | **NOT FOUND** | Searched workspace. File does not exist. | N/A |
| `SYSTEM/**/node_modules` | **NOT FOUND** | Searched SYSTEM/. No node_modules found. | N/A — already cleaned or never existed |
| `v2 docs contradicting v3.1` | **keep** | All v2 docs are in `archive/`. No contradictions in active files. | Low — already archived |

---

## Junk from Tonight (Session Artifacts)

| Path | Action | Why |
|------|--------|-----|
| `v3/state/state.db` | **keep** | SQLite database with test checkpoints. Real data now. | Low |
| `v3/tests/test-suite.sh` | **keep** | Phase 3 test suite. 16/16 pass. Evidence of quality. | Low |
| `v3/memory/handoffs/sess-verify-001-quality.yaml` | **delete** | Test artifact from Phase 2 smoke test. Not a real handoff. | Low — test data |
| `v3/verticals/oak-and-iron/research-*.md` | **keep** | Phase 4 research outputs. Useful for demo. | Low |
| `v3/verticals/oak-and-iron/sow.md` | **keep** | Phase 4 SOW. Useful for demo. | Low |
| `v3/verticals/oak-and-iron/design-brief.md` | **keep** | Phase 4 design brief. Useful for demo. | Low |

---

## Recommended Actions (No Deletions Yet)

1. **Delete 3 duplicate fact_extractor files** after user approval
2. **gitignore node_modules** in archive/ (already archived, just prevent future commits)
3. **Add disclaimer to blog-post-v3-launch.md** or update with real metrics
4. **Delete test handoff YAML** (sess-verify-001-quality.yaml)

---

*No files deleted. Awaiting user approval for any deletions.*
