# Feature Spec: Reducers for State Merging

**Feature ID:** FEAT-002
**Title:** Reducers for State Merging — Prevent Concurrent Subagent Conflicts
**Status:** Draft
**Priority:** High
**Estimated Effort:** 2-3 days

---

## Problem Statement

The current v3 architecture allows a main agent to spawn multiple subagents that may execute concurrently (e.g., `@research` and `@scaffolder` working in parallel). Each subagent receives a snapshot of the global state, modifies it during execution, and returns an updated state. However, there is no mechanism to safely merge these concurrent state updates back into the global state.

This leads to:

1. **Last-Write-Wins Data Loss:** If two subagents both update the `tasks` array, the second one to return overwrites the first's changes entirely.
2. **Inconsistent Agent Status:** Subagent A sets `@quality` to `working`; Subagent B sets it to `waiting`. The final state depends on return order, not logic.
3. **Broken Task Lifecycles:** A task marked `completed` by one subagent might be reverted to `in_progress` by another subagent's stale state snapshot.
4. **No Conflict Detection:** The system silently accepts conflicting updates, making bugs extremely hard to trace.

A naive JSON deep-merge is insufficient because different state fields require different merge semantics (e.g., arrays should append, counters should sum, objects should deep-merge, enums should follow priority rules).

---

## Solution Approach

Implement a **Reducer System** inspired by LangGraph's reducer pattern and Redux reducers. Each field in the state schema declares its merge strategy. When concurrent subagents return, their state patches are applied through typed reducers rather than blind overwriting.

### Key Design Decisions

1. **Per-Field Reducer Registration:** Each key in `SessionState`, `AgentState`, `TaskState`, etc., has an associated reducer function.
2. **Patch-Based Updates:** Subagents return state *patches* (deltas) rather than full state snapshots. This minimizes merge surface area.
3. **Three-Way Merge:** When merging, compare base state (at spawn time), left branch (subagent A), and right branch (subagent B). Apply reducers to resolve conflicts.
4. **Merge Conflict Log:** Unresolvable conflicts are logged for human review rather than silently dropped.
5. **Opt-In Concurrency:** Not all tasks are parallelizable. The task definition declares whether it supports concurrent execution and which state keys it may touch.

---

## Data Structures / Schemas

### Reducer Registry

```typescript
type ReducerFunction<T> = (
    base: T,
    left: T,      // Subagent A's value
    right: T,     // Subagent B's value
    context: MergeContext
) => T;

interface MergeContext {
    fieldPath: string;
    agentA: string;
    agentB: string;
    timestamp: string;
    logConflicts: boolean;
}

interface ReducerEntry<T> {
    path: string;                    // Dot-notation path, e.g., "agents.*.status"
    reducer: ReducerFunction<T>;
    description: string;
}
```

### Built-In Reducers

```typescript
// 1. LAST_WRITE_WINS — Simple overwrite (for timestamps, single values)
const lastWriteWins = <T>(base: T, left: T, right: T, ctx: MergeContext): T => {
    // Prefer the most recent based on subagent completion time
    // If timestamps equal, deterministic tie-breaker (agent name hash)
    return right; // Simplified; actual implementation uses metadata
};

// 2. APPEND_UNIQUE — Append arrays, deduplicate by key (for artifacts, handoffs)
const appendUnique = <T>(base: T[], left: T[], right: T[], ctx: MergeContext): T[] => {
    const merged = [...base, ...left, ...right];
    // Deduplicate by 'id' field if present
    const seen = new Set();
    return merged.filter(item => {
        const key = (item as any).id ?? JSON.stringify(item);
        if (seen.has(key)) return false;
        seen.add(key);
        return true;
    });
};

// 3. DEEP_MERGE — Recursive object merge (for metrics, context)
const deepMerge = (base: object, left: object, right: object, ctx: MergeContext): object => {
    return mergeWith({}, base, left, right, (objValue, srcValue) => {
        if (Array.isArray(objValue)) return appendUnique(objValue, srcValue, [], ctx);
    });
};

// 4. MAX_PRIORITY — For enums with priority ordering
const maxPriority = (base: string, left: string, right: string, ctx: MergeContext): string => {
    const priority = { error: 4, working: 3, waiting: 2, idle: 1 };
    const pLeft = priority[left as keyof typeof priority] ?? 0;
    const pRight = priority[right as keyof typeof priority] ?? 0;
    return pLeft >= pRight ? left : right;
};

// 5. SUM — For numeric counters
const sum = (base: number, left: number, right: number, ctx: MergeContext): number => {
    // If both changed from base, sum the deltas to avoid double-counting
    const deltaLeft = (left as number) - (base as number);
    const deltaRight = (right as number) - (base as number);
    return (base as number) + deltaLeft + deltaRight;
};

// 6. CONFLICT_LOG — Log and require resolution
const conflictLog = <T>(base: T, left: T, right: T, ctx: MergeContext): T => {
    if (JSON.stringify(left) !== JSON.stringify(right) && JSON.stringify(left) !== JSON.stringify(base)) {
        console.warn(`[MERGE CONFLICT] ${ctx.fieldPath}: ${ctx.agentA}=${JSON.stringify(left)} vs ${ctx.agentB}=${JSON.stringify(right)}`);
    }
    return right; // Default fallback
};
```

### State Patch Format

Subagents return patches instead of full state:

```typescript
interface StatePatch {
    agentId: string;                 // Who produced this patch
    baseCheckpointId: number;        // State version at spawn time
    timestamp: string;
    changes: Array<{
        path: string;                // Dot-notation path
        op: 'add' | 'replace' | 'remove';
        value: any;
        oldValue?: any;              // For conflict detection
    }>;
}
```

### Task Concurrency Declaration

```typescript
interface TaskState {
    // ... existing fields ...
    concurrency: {
        allowed: boolean;
        isolatedKeys: string[];      // Keys this task is allowed to modify
        mergeStrategy: 'auto' | 'manual'; // Auto=use reducers, Manual=human resolves
    };
}
```

---

## API / Interface Design

### TypeScript Interface

```typescript
interface StateReducer {
    registerReducer<T>(path: string, reducer: ReducerFunction<T>): void;
    getReducer<T>(path: string): ReducerFunction<T> | undefined;

    // Merge patches from multiple subagents
    mergePatches(
        baseState: GlobalState,
        patches: StatePatch[],
        options?: MergeOptions
    ): MergeResult;

    // Apply a single patch (for sequential execution)
    applyPatch(state: GlobalState, patch: StatePatch): GlobalState;
}

interface MergeResult {
    state: GlobalState;
    conflicts: MergeConflict[];
    appliedPatches: number;
    rejectedPatches: number;
}

interface MergeConflict {
    path: string;
    baseValue: any;
    values: Array<{ agentId: string; value: any }>;
    resolution: 'auto' | 'manual' | 'rejected';
    resolvedValue: any;
}

interface MergeOptions {
    logConflicts: boolean;
    rejectOnConflict: boolean;
    maxConflicts: number;
}
```

### Usage Example

```typescript
// Register reducers at system startup
reducer.registerReducer('session.lastActive', lastWriteWins);
reducer.registerReducer('agents.*.status', maxPriority);
reducer.registerReducer('agents.*.metrics.tasksCompleted', sum);
reducer.registerReducer('tasks', appendUnique);
reducer.registerReducer('session.context.handoffs', appendUnique);
reducer.registerReducer('session.context.decisions', appendUnique);

// Main agent spawns parallel subagents
const baseCheckpoint = await checkpointer.getLatestCheckpoint('global');
const patchA = await spawnSubagent('@research', task, baseCheckpoint.id);
const patchB = await spawnSubagent('@scaffolder', task, baseCheckpoint.id);

// Merge their results
const result = reducer.mergePatches(baseCheckpoint.state, [patchA, patchB], {
    logConflicts: true,
    rejectOnConflict: false
});

if (result.conflicts.length > 0) {
    console.warn(`${result.conflicts.length} merge conflicts detected`);
    // Log for review, but continue with auto-resolved state
}

await checkpointer.saveCheckpoint('global', result.state, { reason: 'merge', conflicts: result.conflicts });
```

---

## Acceptance Criteria

- [ ] **AC1:** Two subagents updating different tasks do not overwrite each other's changes.
- [ ] **AC2:** Two subagents updating the same agent's status use the priority reducer (e.g., `error` beats `working`).
- [ ] **AC3:** Task arrays from concurrent subagents are merged with deduplication, not replacement.
- [ ] **AC4:** Numeric counters (e.g., `tasksCompleted`) sum correctly even when both subagents increment.
- [ ] **AC5:** A merge conflict on a critical field (e.g., API key change) is logged and flagged for review.
- [ ] **AC6:** The system can replay a merge: given base state + patches, it produces the same result deterministically.
- [ ] **AC7:** Subagents that do not declare `concurrency.allowed=true` are executed sequentially by default.
- [ ] **AC8:** Merge performance: merging 5 concurrent subagent patches completes in <100ms.

---

## Estimated Effort

| Phase | Duration | Description |
|-------|----------|-------------|
| Reducer Core & Built-Ins | 1 day | Implement reducer registry, 6 built-in reducers |
| Patch Format & Apply Logic | 0.5 day | Define patch schema, applyPatch function |
| Three-Way Merge Engine | 0.5 day | Base + left + right resolution logic |
| Integration with Spawner | 0.5 day | Wire into subagent spawn/return lifecycle |
| Conflict Logging & CLI | 0.5 day | Conflict report, `openclaw state conflicts` command |
| Testing | 0.5 day | Concurrent subagent simulation, edge cases |
| **Total** | **2-3 days** | |

---

## Dependencies

- **FEAT-001 (SQLite Checkpointer):** Uses checkpoint IDs for base state references.
- Existing `STATE.md` schemas (extended with `concurrency` field).

## Risks

| Risk | Mitigation |
|------|------------|
| Custom reducers are error-prone | Comprehensive unit tests for each built-in reducer; fuzz testing |
| Merge complexity grows with state size | Benchmark at 1000 tasks; optimize hot paths |
| Subagents return full state instead of patches | Enforce patch format at type level; runtime validation |

---

*Concurrent agents should collaborate, not clobber.*
