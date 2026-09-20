# EVALUATION.md — Quality Test Harness

**Version:** 3.0
**Purpose:** Automated evaluation framework for agent outputs
**Inspired by:** DeepEval, agentevals (LangChain)

---

## Evaluation Architecture

```
┌─────────────────────────────────────────┐
│         EVALUATION PIPELINE             │
├─────────────────────────────────────────┤
│  1. Test Cases (Golden Dataset)         │
│  2. Agent Execution                     │
│  3. Metric Calculation                  │
│  4. Score Aggregation                   │
│  5. Report Generation                   │
└─────────────────────────────────────────┘
```

## Test Cases

### Structure
```yaml
test_case:
  id: "TC-001"
  name: "Handoff Protocol Validation"
  category: "protocol"
  difficulty: "medium"
  
  input:
    task: "Spawn @quality to audit src/auth.js"
    context: {file: "src/auth.js", focus: "security"}
  
  expected:
    output_format: "yaml"
    required_fields: ["handoff", "context", "artifacts"]
    quality_threshold: 8.0
  
  evaluation:
    metrics: ["completeness", "format_accuracy", "context_preservation"]
    weights: {completeness: 0.4, format_accuracy: 0.3, context_preservation: 0.3}
```

### Categories
| Category | Description | Example |
|----------|-------------|---------|
| protocol | Handoff, spawn, startup | Verify handoff structure |
| quality | Output scoring | Verify audit accuracy |
| memory | Context preservation | Verify memory storage |
| routing | Agent selection | Verify correct agent chosen |
| recovery | Error handling | Verify retry logic |

## Metrics

### 1. G-Eval (LLM-as-Judge)
```python
def g_eval(output, criteria):
    """
    Use LLM to evaluate output against criteria
    Returns: score (0-10), reasoning
    """
    prompt = f"""
    Evaluate the following output against the criteria.
    
    Output: {output}
    Criteria: {criteria}
    
    Score 0-10 and explain why.
    """
    return llm.evaluate(prompt)
```

### 2. Answer Relevancy
```python
def answer_relevancy(output, input_question):
    """
    Does output address the input question?
    Uses embedding similarity + keyword overlap
    """
    embedding_sim = cosine_sim(embed(output), embed(input_question))
    keyword_overlap = jaccard_similarity(output, input_question)
    return 0.7 * embedding_sim + 0.3 * keyword_overlap
```

### 3. Factual Accuracy
```python
def factual_accuracy(output, ground_truth):
    """
    Compare claims in output to ground truth
    Uses NLI (Natural Language Inference)
    """
    claims = extract_claims(output)
    correct = sum(check_claim(c, ground_truth) for c in claims)
    return correct / len(claims)
```

### 4. Completeness
```python
def completeness(output, requirements):
    """
    Check if all requirements are met
    """
    met = sum(req in output for req in requirements)
    return met / len(requirements)
```

### 5. Context Preservation
```python
def context_preservation(output, input_context):
    """
    Verify context is maintained through processing
    """
    key_facts = extract_facts(input_context)
    preserved = sum(fact in output for fact in key_facts)
    return preserved / len(key_facts)
```

## Golden Dataset

### Test Cases
```yaml
golden_dataset:
  version: "3.0"
  tests:
    - id: "TC-001"
      name: "Session Startup"
      input: "Start new session"
      expected: ["SOUL.md loaded", "HANDOFF.md loaded", "Agent loaded"]
      
    - id: "TC-002"
      name: "Agent Spawn"
      input: "Spawn @quality to audit code"
      expected: ["Handoff structure valid", "Context included", "Return path specified"]
      
    - id: "TC-003"
      name: "Quality Audit"
      input: "Audit this output"
      expected: ["Score calculated", "Issues identified", "Recommendation given"]
      
    - id: "TC-004"
      name: "Memory Store"
      input: "Store important fact"
      expected: ["Fact stored", "Tagged correctly", "Retrievable"]
      
    - id: "TC-005"
      name: "Error Recovery"
      input: "Simulate agent failure"
      expected: ["Error detected", "Fallback triggered", "State preserved"]
```

## Running Tests

### Manual
```bash
# Run specific test
./v3/tools/evaluate.sh --test TC-001

# Run category
./v3/tools/evaluate.sh --category protocol

# Run all
./v3/tools/evaluate.sh --all
```

### Automated
```bash
# Run on every commit
./v3/tools/evaluate.sh --ci

# Run nightly
./v3/tools/evaluate.sh --nightly
```

## Report Format

```markdown
# Evaluation Report — 2026-09-16

## Summary
- Tests Run: 50
- Passed: 48
- Failed: 2
- Score: 9.6/10

## By Category
| Category | Tests | Passed | Score |
|----------|-------|--------|-------|
| Protocol | 10 | 10 | 10.0 |
| Quality | 15 | 14 | 9.3 |
| Memory | 10 | 10 | 10.0 |
| Routing | 10 | 9 | 9.0 |
| Recovery | 5 | 5 | 10.0 |

## Failed Tests
- TC-042: Quality audit missed minor issue
- TC-038: Routing chose suboptimal agent

## Recommendations
1. Update @quality prompt to catch minor issues
2. Add routing confidence threshold

## Trend
- Last week: 9.4/10
- This week: 9.6/10
- Trend: ↑ +0.2
```

## Continuous Improvement

### Weekly
- Review failed tests
- Update golden dataset
- Adjust thresholds

### Monthly
- Add new test cases
- Retire obsolete tests
- Calibrate metrics

### Quarterly
- Full harness review
- Benchmark against baselines
- Update evaluation models

---

*What gets measured gets improved.*
