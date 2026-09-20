# RECOVERY.md — Error Handling & Recovery

**Version:** 3.0
**Purpose:** Handle failures gracefully
**Applies to:** All agents, all sessions

---

## Error Types

| Type | Description | Example |
|------|-------------|---------|
| **API Error** | Model API failure | Timeout, rate limit |
| **Tool Error** | Tool execution failure | File not found |
| **Agent Error** | Agent malfunction | Wrong output format |
| **Context Error** | Context loss | Forgotten instructions |
| **System Error** | Infrastructure failure | Disk full, crash |

## Recovery Strategies

### 1. Retry with Backoff
```python
def retry_with_backoff(func, max_retries=3):
    for attempt in range(max_retries):
        try:
            return func()
        except TransientError as e:
            wait = 2 ** attempt  # Exponential backoff
            sleep(wait)
    raise MaxRetriesExceeded()
```

### 2. Fallback Model
```python
def call_with_fallback(primary, fallback, task):
    try:
        return call_model(primary, task)
    except APIError:
        log_error(f"Primary {primary} failed, using fallback {fallback}")
        return call_model(fallback, task)
```

### 3. State Recovery
```python
def recover_state(session_id):
    state = load_state(session_id)
    incomplete_tasks = [t for t in state.tasks if t.status != "completed"]
    
    for task in incomplete_tasks:
        if task.status == "in_progress":
            retry_task(task)
        elif task.status == "blocked":
            unblock_task(task)
        elif task.status == "failed":
            escalate_task(task)
```

### 4. Graceful Degradation
```python
def execute_with_degradation(task):
    try:
        return full_execution(task)
    except ResourceError:
        return reduced_execution(task)  # Simpler but works
    except CriticalError:
        return error_message(task)  # Inform user
```

## Error Handling Flow

```
Error Detected
      │
      ▼
Classify Error
      │
      ├── Transient ──► Retry ──► Success?
      │                      ├── Yes ──► Continue
      │                      └── No ──► Fallback
      │
      ├── Permanent ──► Fallback ──► Success?
      │                           ├── Yes ──► Continue
      │                           └── No ──► Escalate
      │
      └── Critical ──► Escalate to User
```

## Agent-Specific Recovery

### @switch (Router)
- **Error:** Routing failure
- **Recovery:** Default to @grok for analysis
- **Escalation:** Ask user for clarification

### @quality (Auditor)
- **Error:** Cannot score output
- **Recovery:** Use simpler heuristic scoring
- **Escalation:** Flag for manual review

### @content (Creator)
- **Error:** Content generation fails
- **Recovery:** Reduce scope, generate partial
- **Escalation:** Request more specific instructions

### @grok (Reasoning)
- **Error:** Analysis timeout
- **Recovery:** Reduce problem scope
- **Escalation:** Break into smaller sub-problems

### @product (Analyst)
- **Error:** Requirements unclear
- **Recovery:** Ask clarifying questions
- **Escalation:** Schedule user interview

### @scaffolder (Builder)
- **Error:** Build fails
- **Recovery:** Check dependencies, retry
- **Escalation:** Simplify scaffold

### @ux (Designer)
- **Error:** Design constraint conflict
- **Recovery:** Prioritize constraints
- **Escalation:** Present options to user

## Recovery Protocol

### Step 1: Detect
```python
try:
    result = execute_task()
except Exception as e:
    error = classify_error(e)
```

### Step 2: Classify
```python
def classify_error(error):
    if is_transient(error):
        return "transient"
    elif is_recoverable(error):
        return "recoverable"
    else:
        return "critical"
```

### Step 3: Recover
```python
def recover(error, task):
    if error.type == "transient":
        return retry(task)
    elif error.type == "recoverable":
        return fallback(task)
    else:
        return escalate(task)
```

### Step 4: Log
```python
def log_recovery(error, action, result):
    log_entry = {
        "timestamp": now(),
        "error": str(error),
        "action": action,
        "result": result,
        "task": task.id
    }
    append_to_log(log_entry)
```

## Escalation Criteria

Escalate to user when:
- All retries exhausted
- No fallback available
- Critical system error
- User input required
- Security concern

## Recovery Metrics

Track:
- Recovery success rate
- Average recovery time
- Escalation frequency
- Error patterns

Target:
- Recovery rate: >95%
- Escalation rate: <5%
- Recovery time: <30s

---

*Failure is not the opposite of success; it's part of it.*
