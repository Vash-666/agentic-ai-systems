# STATE.md — Shared State Machine

**Version:** 3.0
**Purpose:** Central state schema for all agents
**Inspired by:** LangGraph state management

---

## State Architecture

```
┌─────────────────────────────────────────┐
│           GLOBAL STATE                  │
├─────────────────────────────────────────┤
│  session: SessionState                  │
│  agents: AgentState[]                   │
│  tasks: TaskState[]                     │
│  memory: MemoryState                    │
│  quality: QualityState                  │
└─────────────────────────────────────────┘
```

## State Schemas

### SessionState
```typescript
interface SessionState {
  id: string;                    // UUID
  started: string;               // ISO-8601
  lastActive: string;            // ISO-8601
  type: "main" | "subagent" | "background";
  status: "active" | "paused" | "completed" | "error";
  currentAgent: string;          // Active agent
  parentSession?: string;        // For subagents
  
  context: {
    loaded: string[];            // Files read
    handoffs: Handoff[];         // Transfer history
    decisions: Decision[];       // Key decisions
  };
}
```

### AgentState
```typescript
interface AgentState {
  id: string;
  name: string;
  status: "idle" | "working" | "waiting" | "error";
  currentTask?: string;
  model: string;
  fallbackModel: string;
  
  metrics: {
    tasksCompleted: number;
    tasksFailed: number;
    avgQuality: number;
    totalRuntime: number;
  };
}
```

### TaskState
```typescript
interface TaskState {
  id: string;
  description: string;
  status: "pending" | "in_progress" | "completed" | "failed" | "blocked";
  priority: "low" | "medium" | "high" | "critical";
  assignee: string;
  created: string;
  started?: string;
  completed?: string;
  
  artifacts: string[];
  quality?: number;
  blockers?: string[];
}
```

### MemoryState
```typescript
interface MemoryState {
  working: Memory[];             // Current session
  shortTerm: Memory[];           // Daily
  longTerm: Memory[];            // Strategic
  vector: VectorMemory[];        // Semantic search
}

interface Memory {
  id: string;
  timestamp: string;
  content: string;
  category: string;
  importance: number;
  embedding?: number[];
}
```

### QualityState
```typescript
interface QualityState {
  overall: number;
  components: {
    promptFiles: number;
    memory: number;
    model: number;
    tools: number;
  };
  audits: Audit[];
  trends: Trend[];
}
```

## State Transitions

### Session Lifecycle
```
[created] → [active] → [paused] → [active] → [completed]
                ↓
              [error] → [recovery] → [active]
```

### Task Lifecycle
```
[pending] → [in_progress] → [completed]
                ↓
              [blocked] → [in_progress]
                ↓
              [failed] → [pending] (retry)
```

### Agent Lifecycle
```
[idle] → [working] → [waiting] → [working] → [idle]
            ↓
          [error] → [idle] (after recovery)
```

## State Persistence

### What to Save
- Session state: Every handoff
- Task state: Every status change
- Agent state: Every spawn/return
- Quality state: Every audit

### Where to Save
- Working: In-memory (session)
- Short-term: `memory/daily/YYYY-MM-DD.jsonl`
- Long-term: `memory/STRATEGIC.md`
- Vector: Embedded in vector store

## State Recovery

### On Crash
1. Read last saved state
2. Identify incomplete tasks
3. Restore agent contexts
4. Resume or retry

### On Model Switch
1. Serialize current state
2. Pass to new model
3. Deserialize and continue

## State Inspection

### Current Status
```bash
# Get full system state
cat v3/state/current.json

# Get agent status
cat v3/state/agents.json

# Get active tasks
cat v3/state/tasks.json
```

### State History
```bash
# View state changes
tail -f v3/state/history.jsonl

# Filter by agent
grep "@quality" v3/state/history.jsonl
```

---

*State is the single source of truth. Keep it accurate.*
