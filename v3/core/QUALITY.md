# QUALITY.md — Quality Equation & Evaluation Framework

**Version:** 3.0
**Purpose:** Standardized quality scoring for all agent outputs
**Inspired by:** DeepEval, agentevals (LangChain)

---

## Quality Equation

```
Quality = (Prompt_Files × 0.65) + (Memory × 0.20) + (Model × 0.10) + (Tools × 0.05)
```

### Component Breakdown

| Component | Weight | Measures | Target |
|-----------|--------|----------|--------|
| Prompt Files | 65% | Clarity, completeness, accuracy | ≥9.0/10 |
| Memory | 20% | Context preservation, fact accuracy | ≥9.0/10 |
| Model | 10% | Appropriate model selection | ≥8.5/10 |
| Tools | 5% | Correct tool usage, efficiency | ≥8.0/10 |

**Overall Target:** ≥9.0/10

---

## Evaluation Metrics

### 1. Answer Relevancy (0-10)
- Does the output address the user's actual question?
- Is there off-topic content?
- **Scoring:**
  - 10: Perfectly on-target
  - 7-9: Mostly relevant, minor tangents
  - 4-6: Partially relevant
  - 0-3: Off-topic or unhelpful

### 2. Factual Accuracy (0-10)
- Are claims verifiable?
- Are there hallucinations?
- **Scoring:**
  - 10: All facts verified
  - 7-9: Minor unverifiable claims
  - 4-6: Some incorrect statements
  - 0-3: Major factual errors

### 3. Completeness (0-10)
- Did the agent do everything requested?
- Are there missing steps or files?
- **Scoring:**
  - 10: Fully complete
  - 7-9: Minor omissions
  - 4-6: Significant gaps
  - 0-3: Incomplete or abandoned

### 4. Efficiency (0-10)
- Was the task done with minimal steps?
- Were tools used appropriately?
- **Scoring:**
  - 10: Optimal path taken
  - 7-9: Slightly inefficient
  - 4-6: Redundant steps
  - 0-3: Very inefficient

### 5. Context Preservation (0-10)
- Was context maintained throughout?
- Did the agent remember previous instructions?
- **Scoring:**
  - 10: Perfect continuity
  - 7-9: Minor context gaps
  - 4-6: Noticeable context loss
  - 0-3: Complete context loss

---

## Quality Audit Process

### When to Audit
- Every agent output before delivery
- Critical tasks (security, deployment)
- When quality drops below 8.0

### Audit Steps
1. **Self-Assessment:** Agent scores own output
2. **Peer Review:** Another agent verifies (for critical tasks)
3. **User Feedback:** Track real-world quality scores
4. **Trend Analysis:** Monitor quality over time

### Audit Template

```markdown
## Quality Audit — [Task ID]

**Agent:** @agent_name
**Task:** Brief description
**Timestamp:** ISO-8601

### Scores
- Relevancy: X/10
- Accuracy: X/10
- Completeness: X/10
- Efficiency: X/10
- Context: X/10

**Overall: X/10**

### Issues Found
- [ ] Issue 1
- [ ] Issue 2

### Recommendations
- Fix 1
- Fix 2

### Verified By:** @quality_agent
```

---

## Quality Thresholds

| Score | Action |
|-------|--------|
| ≥9.0 | Approve and deliver |
| 8.0-8.9 | Minor fixes, then deliver |
| 7.0-7.9 | Significant revision required |
| <7.0 | Reject, return to agent |

---

## Continuous Improvement

### Weekly Quality Review
- Review all audits from the week
- Identify patterns (common failures)
- Update prompt files to address issues
- Retrain agents on weak areas

### Monthly Calibration
- Compare agent self-scores vs actual quality
- Adjust scoring rubrics if needed
- Update quality targets based on trends

---

*Quality is not an act. It is a habit.*
