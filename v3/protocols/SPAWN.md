# SPAWN.md — Agent Spawn Protocol

**Version:** 3.0
**Purpose:** Standardized agent spawning with full context injection
**Applies to:** All agent-to-agent spawns

---

## Spawn Rules

### When to Spawn
- Task requires different expertise
- Parallel processing needed
- Quality audit required
- Specialized tool needed

### When NOT to Spawn
- Simple task (do it yourself)
- Same expertise (redundant)
- User asked directly (don't delegate)

## Spawn Template

```yaml
spawn:
  agent: "agent_name"
  task: "Specific, measurable task"
  context:
    background: "What the agent needs to know"
    goal: "What success looks like"
    constraints: "What to avoid"
  artifacts:
    files: ["path/to/file1", "path/to/file2"]
    data: {key: "value"}
  handoff:
    from: "current_agent"
    to: "target_agent"
    return_to: "current_agent"
    format: "expected_return_format"
  model:
    primary: "provider/model"
    fallback: "provider/model"
  timeout: 300
  quality_gate: true
```

## Context Injection (CRITICAL)

Every spawn MUST include:

### 1. Task Definition
- What to do (specific)
- Why it matters (context)
- How to verify (acceptance criteria)

### 2. Background
- User's goal
- Previous actions
- Relevant decisions
- Known constraints

### 3. Artifacts
- Files to read/modify
- Data to process
- Examples to follow

### 4. Return Format
- Expected output format
- Where to save results
- How to report completion

## Spawn Types

### Sequential Spawn
```
@switch spawns @product
@product returns to @switch
@switch spawns @scaffolder
@scaffolder returns to @switch
```

### Parallel Spawn
```
@switch spawns @content (writing)
@switch spawns @scaffolder (coding)
Both return to @switch
@switch combines results
```

### Nested Spawn
```
@switch spawns @quality
@quality spawns @grok (for complex analysis)
@grok returns to @quality
@quality returns to @switch
```

## Anti-Patterns

### ❌ Bad Spawn
```yaml
spawn:
  agent: "@quality"
  task: "Check this"  # Too vague
  # No context
  # No artifacts
  # No return format
```

### ✅ Good Spawn
```yaml
spawn:
  agent: "@quality"
  task: "Audit src/auth.js for security vulnerabilities"
  context:
    background: "This is a login module handling sensitive data"
    goal: "Find all security issues before production"
    constraints: "Focus on injection and auth bypass"
  artifacts:
    files: ["src/auth.js", "tests/auth.test.js"]
    data: {framework: "express", auth_type: "JWT"}
  handoff:
    from: "@switch"
    to: "@quality"
    return_to: "@switch"
    format: "Markdown report with severity ratings"
  model:
    primary: "anthropic/claude-sonnet-4-5"
    fallback: "ollama/phi4"
  timeout: 300
  quality_gate: true
```

## Return Handling

### Successful Return
1. Verify output meets acceptance criteria
2. Log completion
3. Update session context
4. Deliver to user or next agent

### Failed Return
1. Capture error details
2. Decide: retry, fallback, or escalate
3. Log failure
4. Update quality metrics

---

*A good spawn is 80% context, 20% task.*
