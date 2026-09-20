# Feature Spec: SQLite Checkpointer

**Feature ID:** FEAT-001
**Title:** SQLite Checkpointer — Replace File-Based State with Durable Database
**Status:** Draft
**Priority:** High
**Estimated Effort:** 3-4 days

---

## Problem Statement

The current v3 state system persists data through flat files (`v3/state/current.json`, `v3/state/agents.json`, `v3/state/tasks.json`, and `memory/daily/YYYY-MM-DD.jsonl`). This approach has several critical weaknesses:

1. **No Atomicity:** A crash during a write can corrupt the entire state file, leaving the system in an unrecoverable inconsistent state.
2. **No Concurrent Access:** Multiple agents or subagents reading/writing state simultaneously risk race conditions and data loss. File locking is primitive and error-prone.
3. **Poor Queryability:** Finding "all tasks assigned to @quality that failed in the last 24 hours" requires loading and filtering entire JSON files in memory.
4. **Scalability Ceiling:** As agent count, task volume, and session history grow, JSON files become unwieldy. Parsing multi-megabyte JSON on every state read is inefficient.
5. **No Transaction History:** There is no built-in audit trail of state changes. Debugging "what changed and when" requires external log parsing.

The system needs a durable, transactional, queryable state backend.

---

## Solution Approach

Replace the file-based state persistence layer with an **SQLite-based checkpointer** that provides ACID guarantees, concurrent read access, and structured querying.

### Key Design Decisions

1. **SQLite over PostgreSQL:** SQLite is serverless, requires zero setup, and is sufficient for single-node deployments. It keeps the system lightweight while providing full SQL capabilities. Migration to PostgreSQL can be a future enhancement.
2. **WAL Mode:** Enable SQLite's Write-Ahead Logging (WAL) mode for better concurrent read performance and crash safety.
3. **Schema-per-Concern:** Separate tables for sessions, agents, tasks, and state checkpoints rather than a single JSON blob.
4. **Checkpoint Pattern:** Every significant state change creates a new checkpoint row. The "current" state is the latest checkpoint. This provides implicit history and rollback capability.
5. **Migration Path:** The system must boot from existing JSON files on first run, migrate them into SQLite, and then operate exclusively from the database.

---

## Data Structures / Schemas

### Database: `v3/state/state.db`

#### Table: `checkpoints`
Stores every state snapshot. The latest `checkpoint_id` per `scope` represents current state.

```sql
CREATE TABLE checkpoints (
    checkpoint_id INTEGER PRIMARY KEY AUTOINCREMENT,
    scope         TEXT NOT NULL,        -- 'global', 'session:<id>', 'agent:<id>'
    timestamp     TEXT NOT NULL,        -- ISO-8601
    state_json    TEXT NOT NULL,        -- Full serialized state (JSON)
    parent_id     INTEGER,              -- Previous checkpoint for this scope
    metadata_json TEXT,                 -- Optional: agent_id, task_id, reason
    FOREIGN KEY (parent_id) REFERENCES checkpoints(checkpoint_id)
);

CREATE INDEX idx_checkpoints_scope_time ON checkpoints(scope, timestamp DESC);
```

#### Table: `sessions`
Queryable session registry.

```sql
CREATE TABLE sessions (
    id            TEXT PRIMARY KEY,
    started       TEXT NOT NULL,
    last_active   TEXT NOT NULL,
    type          TEXT NOT NULL CHECK(type IN ('main', 'subagent', 'background')),
    status        TEXT NOT NULL CHECK(status IN ('active', 'paused', 'completed', 'error')),
    current_agent TEXT,
    parent_session TEXT,
    context_json  TEXT                  -- Loaded files, handoffs, decisions
);

CREATE INDEX idx_sessions_status ON sessions(status);
CREATE INDEX idx_sessions_parent ON sessions(parent_session);
```

#### Table: `agents`
Queryable agent registry.

```sql
CREATE TABLE agents (
    id              TEXT PRIMARY KEY,
    name            TEXT NOT NULL,
    status          TEXT NOT NULL CHECK(status IN ('idle', 'working', 'waiting', 'error')),
    current_task    TEXT,
    model           TEXT NOT NULL,
    fallback_model  TEXT NOT NULL,
    metrics_json    TEXT NOT NULL,      -- tasksCompleted, tasksFailed, avgQuality, totalRuntime
    last_updated    TEXT NOT NULL
);

CREATE INDEX idx_agents_status ON agents(status);
```

#### Table: `tasks`
Queryable task registry.

```sql
CREATE TABLE tasks (
    id          TEXT PRIMARY KEY,
    description TEXT NOT NULL,
    status      TEXT NOT NULL CHECK(status IN ('pending', 'in_progress', 'completed', 'failed', 'blocked')),
    priority    TEXT NOT NULL CHECK(priority IN ('low', 'medium', 'high', 'critical')),
    assignee    TEXT NOT NULL,
    created     TEXT NOT NULL,
    started     TEXT,
    completed   TEXT,
    artifacts_json  TEXT,               -- Array of file paths
    quality     REAL,
    blockers_json   TEXT                -- Array of strings
);

CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_assignee ON tasks(assignee);
CREATE INDEX idx_tasks_priority ON tasks(priority);
```

#### Table: `state_history`
Audit log of all state transitions (append-only).

```sql
CREATE TABLE state_history (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp   TEXT NOT NULL,
    scope       TEXT NOT NULL,
    action      TEXT NOT NULL,          -- 'create', 'update', 'delete', 'handoff'
    actor       TEXT NOT NULL,          -- agent name or 'system'
    diff_json   TEXT,                   -- JSON diff of what changed
    checkpoint_id INTEGER,
    FOREIGN KEY (checkpoint_id) REFERENCES checkpoints(checkpoint_id)
);

CREATE INDEX idx_state_history_scope_time ON state_history(scope, timestamp DESC);
```

---

## API / Interface Design

### TypeScript Interface

```typescript
interface Checkpointer {
    // Lifecycle
    initialize(): Promise<void>;        // Create tables, migrate from JSON if needed
    close(): Promise<void>;

    // Checkpoints
    saveCheckpoint(scope: string, state: object, metadata?: object): Promise<number>;
    getLatestCheckpoint(scope: string): Promise<{ id: number; state: object; timestamp: string } | null>;
    getCheckpointHistory(scope: string, limit?: number): Promise<Array<{ id: number; state: object; timestamp: string }>>;
    rollback(scope: string, checkpointId: number): Promise<boolean>;

    // Sessions
    upsertSession(session: SessionState): Promise<void>;
    getSession(id: string): Promise<SessionState | null>;
    getActiveSessions(): Promise<SessionState[]>;

    // Agents
    upsertAgent(agent: AgentState): Promise<void>;
    getAgent(id: string): Promise<AgentState | null>;
    getAgentsByStatus(status: string): Promise<AgentState[]>;

    // Tasks
    upsertTask(task: TaskState): Promise<void>;
    getTask(id: string): Promise<TaskState | null>;
    getTasksByStatus(status: string): Promise<TaskState[]>;
    getTasksByAssignee(assignee: string): Promise<TaskState[]>;
    getBlockedTasks(): Promise<TaskState[]>;

    // Audit
    logTransition(scope: string, action: string, actor: string, diff?: object): Promise<void>;
    getHistory(scope: string, since?: string): Promise<Array<{ timestamp: string; action: string; actor: string; diff: object }>>;
}
```

### CLI Commands

```bash
# Initialize/migrate database
openclaw state init

# View current state
openclaw state show

# View agent status
openclaw state agents

# View active tasks
openclaw state tasks --status active

# View state history for a session
openclaw state history --scope session:abc-123 --limit 20

# Rollback to a checkpoint
openclaw state rollback --scope global --checkpoint 42
```

---

## Acceptance Criteria

- [ ] **AC1:** `state.db` is created automatically on first run if it does not exist.
- [ ] **AC2:** Existing JSON state files (`v3/state/*.json`, `memory/daily/*.jsonl`) are transparently migrated into SQLite on first boot, then archived.
- [ ] **AC3:** Every handoff creates a new checkpoint in the `checkpoints` table with correct `scope` and `parent_id` linkage.
- [ ] **AC4:** Concurrent reads from multiple agents do not block each other (WAL mode).
- [ ] **AC5:** A write operation (e.g., task status update) is atomic; a crash mid-write does not corrupt the database.
- [ ] **AC6:** Querying "all blocked tasks" or "all active subagents of session X" completes in <50ms for up to 10,000 records.
- [ ] **AC7:** State history is queryable via CLI and shows who changed what and when.
- [ ] **AC8:** Rollback to any previous checkpoint restores that state correctly.
- [ ] **AC9:** The system operates normally if SQLite is unavailable (graceful degradation to in-memory with warnings).

---

## Estimated Effort

| Phase | Duration | Description |
|-------|----------|-------------|
| Schema Design & Migration | 1 day | Define tables, write migration from JSON |
| Checkpointer Implementation | 1.5 days | Core class, WAL config, checkpoint logic |
| Integration with State Manager | 0.5 day | Wire into existing state read/write paths |
| CLI & Query Tools | 0.5 day | `openclaw state *` commands |
| Testing & Edge Cases | 0.5-1 day | Crash recovery, concurrent access, rollback |
| **Total** | **3-4 days** | |

---

## Dependencies

- `better-sqlite3` or `bun:sqlite` (depending on runtime)
- Existing `STATE.md` schemas (no breaking changes)

## Risks

| Risk | Mitigation |
|------|------------|
| Migration fails on large JSON files | Chunked migration with progress logging; abort with clear error |
| SQLite file corruption | WAL mode + periodic `VACUUM`; backup strategy |
| Performance at scale | Benchmark at 10k records; document PostgreSQL migration path |

---

*Replace fragile files with durable transactions.*
