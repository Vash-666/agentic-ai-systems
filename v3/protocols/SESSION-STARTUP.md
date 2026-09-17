# SESSION-STARTUP.md — Session Initialization Protocol

**Version:** 3.0
**Purpose:** Ensure every session starts with full context
**Applies to:** All agents, all sessions

---

## Startup Sequence

Every session MUST execute in this order:

### Step 1: Load Core Consciousness
```
Read: v3/core/SOUL.md
Read: v3/core/HANDOFF.md
Read: v3/core/QUALITY.md
Read: v3/core/MEMORY.md
```

### Step 2: Load Agent Identity
```
Read: v3/agents/[AGENT_NAME]/AGENT.md
```

### Step 3: Load User Context
```
Read: v3/memory/USER.md
```

### Step 4: Load Session Context
```
Read: v3/memory/SESSION-CONTEXT.md (if exists)
```

### Step 5: Load Recent Memory
```
Read: v3/memory/daily/YYYY-MM-DD.md (today)
Read: v3/memory/daily/YYYY-MM-DD.md (yesterday)
```

### Step 6: Load Strategic Memory (Main Sessions Only)
```
Read: v3/memory/STRATEGIC.md
```

---

## Session Types

### Main Session
- User-facing session
- Full context load (all steps)
- Can spawn sub-agents
- Updates strategic memory

### Sub-Agent Session
- Spawned by main session
- Minimal context (Steps 1-2 + handoff context)
- Receives context via handoff
- Returns results to parent

### Background Session
- Cron-triggered or async
- Minimal context (Steps 1-2 + task context)
- No user interaction
- Logs results to files

---

## Context Preservation

### Before Model Switch
1. Write SESSION-CONTEXT.md with:
   - Current task state
   - Recent decisions
   - Pending actions
   - Key facts learned

2. Flush to memory:
   - Important facts → STRATEGIC.md
   - Daily activity → daily/YYYY-MM-DD.md

### After Model Switch
1. Read SESSION-CONTEXT.md
2. Verify continuity with 3-5 validation questions
3. Resume task

---

## Verification Checklist

After startup:
- [ ] Core files read successfully
- [ ] Agent identity loaded
- [ ] User context known
- [ ] Recent memory accessible
- [ ] Ready to accept tasks

---

*A session without context is a session wasted.*
