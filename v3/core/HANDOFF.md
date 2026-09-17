# HANDOFF.md — Agent Context Transfer Protocol

**Version:** 3.0
**Purpose:** Structured context transfer between agents
**Inspired by:** dabit3/agent-handoff, Google A2A Protocol

---

## Handoff Structure

Every agent-to-agent transfer MUST include:

```yaml
handoff:
  id: "uuid"                    # Unique transfer ID
  timestamp: "ISO-8601"         # When transfer occurred
  from: "agent_name"            # Source agent
  to: "agent_name"              # Target agent
  
  context:
    task: "string"              # What needs to be done
    goal: "string"              # Success criteria
    priority: "low|medium|high|critical"
    
  artifacts:
    files: []                   # Paths to created/modified files
    data: {}                    # Key data structures
    evidence: []                # Supporting evidence/logs
    
  acceptance_criteria:
    - "Specific checkable condition"
    - "Another condition"
    
  return_path:
    to: "agent_name"            # Where to return results
    format: "string"            # Expected return format
    
  chain:
    - {agent: "name", action: "what they did", timestamp: "ISO"}
    - {agent: "name", action: "what they did", timestamp: "ISO"}
```

## Handoff Types

### 1. Task Delegation
```yaml
from: "@switch"
to: "@quality"
context:
  task: "Audit the code in src/auth.js"
  goal: "Find security vulnerabilities"
  priority: high
artifacts:
  files: ["src/auth.js", "tests/auth.test.js"]
acceptance_criteria:
  - "No SQL injection vulnerabilities"
  - "Input validation reviewed"
  - "Rate limiting assessed"
return_path:
  to: "@switch"
  format: "Markdown report with severity ratings"
```

### 2. Escalation
```yaml
from: "@content"
to: "@switch"
context:
  task: "Escalate: content requires technical review"
  goal: "Get technical accuracy verification"
  priority: medium
artifacts:
  files: ["docs/api-reference.md"]
  data: {technical_terms: 15, accuracy_confidence: 0.6}
acceptance_criteria:
  - "Technical terms verified"
  - "Code examples tested"
return_path:
  to: "@content"
  format: "Approved or rejected with notes"
```

### 3. Completion
```yaml
from: "@scaffolder"
to: "@switch"
context:
  task: "Project scaffolding complete"
  goal: "Deliver working project structure"
  priority: medium
artifacts:
  files: ["package.json", "src/", "tests/", "README.md"]
  data: {dependencies: 12, test_coverage: "80%"}
acceptance_criteria:
  - "All files created"
  - "Tests pass"
  - "README is accurate"
return_path:
  to: "@switch"
  format: "Completion summary with verification steps"
```

## Validation Rules

Before transferring:
- [ ] Task is clearly defined
- [ ] Artifacts are listed and accessible
- [ ] Acceptance criteria are checkable
- [ ] Return path is specified
- [ ] Chain history is maintained

## Error Handling

If handoff fails:
1. Log failure reason
2. Return to sender with error details
3. Do NOT silently drop tasks

---

*Every agent transfer is a contract. Honor it.*
