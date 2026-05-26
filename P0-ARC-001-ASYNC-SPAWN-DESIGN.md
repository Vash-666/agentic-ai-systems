# P0-ARC-001: Async Spawn Architecture Design

## Overview

Design for a non-blocking async spawn system where parent agents can continue working after spawning subagents, with event-driven completion notifications and cross-boundary token tracking.

---

## Current Constraints (Inherited from P1-SPAWN-LIMITS)

| Limit | Value | Description |
|-------|-------|-------------|
| `maxConcurrent` | 8 | Maximum concurrent spawns system-wide |
| `maxSpawnDepth` | 3 | Maximum nesting depth of subagent tree |
| `maxChildrenPerAgent` | 5 | Maximum direct children per parent agent |

---

## 1. Async Spawn Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PARENT AGENT                                       │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐   │
│  │   Main      │───→│  Spawn      │───→│  Continue   │───→│  Receive    │   │
│  │   Thread    │    │  Request    │    │  Working    │    │  Results    │   │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘   │
│         │                 │                   │                  ▲          │
│         │                 │                   │                  │          │
│         │            ┌────┴────┐              │           ┌──────┘          │
│         │            │         │              │           │                 │
│         │       [Non-blocking] │              │      [Callback/Event]       │
│         │            │         │              │           │                 │
│         ▼            ▼         ▼              ▼           │                 │
│  ┌──────────────────────────────────────────────────┐    │                 │
│  │              SPAWN ORCHESTRATOR                   │    │                 │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────┐  │    │                 │
│  │  │  Limit      │  │  Queue      │  │  State   │  │    │                 │
│  │  │  Checker    │  │  Manager    │  │  Store   │  │    │                 │
│  │  └─────────────┘  └─────────────┘  └──────────┘  │    │                 │
│  └──────────────────────────────────────────────────┘    │                 │
│                           │                              │                 │
│                           ▼                              │                 │
│  ┌──────────────────────────────────────────────────┐    │                 │
│  │              SUBAGENT EXECUTION                   │    │                 │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────┐  │    │                 │
│  │  │  Worker     │  │  Token      │  │  Result  │──┼────┘                 │
│  │  │  Pool       │  │  Tracker    │  │  Emitter │  │                      │
│  │  └─────────────┘  └─────────────┘  └──────────┘  │                      │
│  └──────────────────────────────────────────────────┘                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Detailed Flow

```
1. SPAWN REQUEST
   ┌─────────┐     ┌─────────────┐     ┌─────────────┐
   │ Parent  │────→│  Validate   │────→│  Check      │
   │         │     │  Params     │     │  Limits     │
   └─────────┘     └─────────────┘     └──────┬──────┘
                                              │
                    ┌─────────────────────────┼─────────────────────────┐
                    │                         │                         │
                    ▼                         ▼                         ▼
              ┌─────────┐              ┌─────────┐              ┌─────────┐
              │  Pass   │              │  Queue  │              │  Reject │
              │  Limits │              │  Full   │              │  Depth  │
              └────┬────┘              └────┬────┘              └────┬────┘
                   │                        │                        │
                   ▼                        ▼                        ▼
              ┌─────────┐              ┌─────────┐              ┌─────────┐
              │ Create  │              │  Wait   │              │ Return  │
              │ Promise │              │  Queue  │              │  Error  │
              └────┬────┘              └─────────┘              └─────────┘
                   │
                   ▼
              ┌─────────┐
              │ Return  │
              │ Promise │
              │  (non-  │
              │ block)  │
              └─────────┘

2. ASYNC EXECUTION
   ┌─────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
   │ Worker  │────→│  Execute    │────→│  Track      │────→│  Emit       │
   │  Start  │     │  Subagent   │     │  Tokens     │     │  Result     │
   └─────────┘     └─────────────┘     └─────────────┘     └──────┬──────┘
                                                                  │
                    ┌─────────────────────────────────────────────┼─────────┐
                    │                                             │         │
                    ▼                                             ▼         ▼
              ┌─────────┐                                   ┌─────────┐ ┌─────────┐
              │ Success │                                   │ Failure │ │ Timeout │
              └────┬────┘                                   └────┬────┘ └────┬────┘
                   │                                             │           │
                   ▼                                             ▼           ▼
              ┌─────────┐                                   ┌─────────┐ ┌─────────┐
              │ Resolve │                                   │ Reject  │ │ Reject  │
              │ Promise │                                   │ Promise │ │ Promise │
              └─────────┘                                   └─────────┘ └─────────┘

3. RESULT DELIVERY
   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
   │  Result     │────→│  Callback   │────→│  Parent     │
   │  Event      │     │  Router     │     │  Handler    │
   └─────────────┘     └─────────────┘     └──────┬──────┘
                                                  │
                    ┌─────────────────────────────┼─────────────┐
                    │                             │             │
                    ▼                             ▼             ▼
              ┌─────────┐                   ┌─────────┐   ┌─────────┐
              │ Inline  │                   │ Channel │   │  Poll   │
              │ Handler │                   │  Push   │   │  (opt)  │
              └─────────┘                   └─────────┘   └─────────┘
```

---

## 2. Callback/Notification Mechanism

### 2.1 Event-Driven Architecture

```typescript
// Core Types
interface SpawnRequest {
  id: string;                    // Unique spawn ID
  parentId: string;              // Parent agent ID
  task: string;                  // Task description
  context?: SpawnContext;        // Optional context
  callback?: CallbackConfig;     // How to receive results
  timeoutMs?: number;            // Optional timeout
}

interface SpawnContext {
  depth: number;                 // Current spawn depth
  inheritedTokens: number;       // Tokens from parent
  metadata: Record<string, any>; // Arbitrary context
}

interface CallbackConfig {
  type: 'inline' | 'webhook' | 'channel' | 'poll';
  target?: string;               // URL, channel ID, etc.
  correlationId?: string;        // For matching responses
}

interface SpawnResult {
  spawnId: string;
  status: 'completed' | 'failed' | 'timeout' | 'cancelled';
  result?: any;
  error?: SpawnError;
  tokensUsed: number;
  durationMs: number;
  completedAt: Date;
}

interface SpawnError {
  code: string;
  message: string;
  retryable: boolean;
  details?: any;
}
```

### 2.2 Notification Patterns

#### Pattern A: Promise/Future (Default)
```typescript
// Parent spawns and receives a future
const future = await spawn.async({
  task: "Analyze data",
  context: { data: largeDataset }
});

// Continue working immediately
const preliminaryResults = await doPreliminaryWork();

// Await result when needed (non-blocking until this point)
const subagentResult = await future.result(); // Blocks here only
```

#### Pattern B: Callback Handler
```typescript
// Parent registers handler before spawning
spawn.onComplete(spawnId, (result: SpawnResult) => {
  console.log(`Subagent ${result.spawnId} finished:`, result.status);
  processResult(result);
});

// Fire and forget - no await needed
await spawn.async({
  task: "Background analysis",
  callback: { type: 'inline' }
});
```

#### Pattern C: Channel Push (for external integrations)
```typescript
// Results pushed to messaging channel
await spawn.async({
  task: "Generate report",
  callback: {
    type: 'channel',
    target: 'discord://channel-id',
    correlationId: 'report-job-123'
  }
});
```

#### Pattern D: Webhook
```typescript
// Results POSTed to external endpoint
await spawn.async({
  task: "Process payment",
  callback: {
    type: 'webhook',
    target: 'https://api.example.com/webhooks/spawn-complete',
    correlationId: 'payment-456'
  }
});
```

### 2.3 Event Bus Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     EVENT BUS                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  spawn.     │  │  spawn.     │  │  spawn.             │  │
│  │  requested  │  │  completed  │  │  failed             │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  spawn.     │  │  spawn.     │  │  spawn.             │  │
│  │  started    │  │  cancelled  │  │  timeout            │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
         │                │                │
         ▼                ▼                ▼
  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
  │  Limit      │  │  Parent     │  │  Metrics    │
  │  Enforcer   │  │  Notifier   │  │  Collector  │
  └─────────────┘  └─────────────┘  └─────────────┘
```

---

## 3. Token Tracking for Async Spawns

### 3.1 Token Budget Hierarchy

```
System Token Budget
        │
        ├──→ Session Budget (parent session)
        │         │
        │         ├──→ Agent Budget (main agent)
        │         │         │
        │         │         ├──→ Subagent 1 Budget ──→ Grandchild Budget
        │         │         │
        │         │         ├──→ Subagent 2 Budget
        │         │         │
        │         │         └──→ Subagent 3 Budget
        │         │
        │         └──→ Reserved for async results
        │
        └──→ System Reserve (10%)
```

### 3.2 Async Token Tracking Flow

```typescript
interface TokenBudget {
  total: number;           // Total tokens allocated
  consumed: number;        // Tokens already used
  reserved: number;        // Tokens reserved for pending async ops
  available: number;       // Tokens available for new work
}

interface AsyncTokenState {
  spawnId: string;
  parentId: string;
  reservedTokens: number;  // Estimated/allocated for this spawn
  actualTokens: number;    // Populated on completion
  status: 'pending' | 'running' | 'completed';
}

class AsyncTokenTracker {
  private pendingSpawns: Map<string, AsyncTokenState> = new Map();
  
  // Reserve tokens when spawn is requested
  async reserveTokens(spawnId: string, estimate: number): Promise<boolean> {
    const available = this.getAvailableTokens();
    if (available < estimate) {
      return false; // Insufficient budget
    }
    
    this.budget.reserved += estimate;
    this.pendingSpawns.set(spawnId, {
      spawnId,
      reservedTokens: estimate,
      actualTokens: 0,
      status: 'pending'
    });
    return true;
  }
  
  // Release reservation and record actual usage on completion
  async finalizeTokens(spawnId: string, actualTokens: number): Promise<void> {
    const state = this.pendingSpawns.get(spawnId);
    if (!state) return;
    
    // Release reservation
    this.budget.reserved -= state.reservedTokens;
    
    // Record actual consumption
    this.budget.consumed += actualTokens;
    state.actualTokens = actualTokens;
    state.status = 'completed';
    
    // Handle over/under estimation
    if (actualTokens > state.reservedTokens) {
      // Over-budget: deduct from available or mark deficit
      await this.handleOverBudget(spawnId, actualTokens - state.reservedTokens);
    }
    
    this.pendingSpawns.delete(spawnId);
  }
}
```

### 3.3 Cross-Boundary Token Aggregation

```typescript
interface TokenReport {
  spawnId: string;
  directTokens: number;      // Tokens used by this agent
  childTokens: number;       // Sum of all child agent tokens
  totalTokens: number;       // direct + child (recursive)
  breakdown: TokenBreakdown;
}

interface TokenBreakdown {
  inputTokens: number;
  outputTokens: number;
  reasoningTokens?: number;
  toolCallTokens?: number;
}

// Token aggregation bubbles up through async boundaries
async function aggregateTokens(spawnId: string): Promise<TokenReport> {
  const spawn = await getSpawnRecord(spawnId);
  const children = await getChildSpawns(spawnId);
  
  // Recursively get child token reports (parallel)
  const childReports = await Promise.all(
    children.map(child => aggregateTokens(child.id))
  );
  
  const childTokens = childReports.reduce(
    (sum, report) => sum + report.totalTokens, 0
  );
  
  return {
    spawnId,
    directTokens: spawn.tokensUsed,
    childTokens,
    totalTokens: spawn.tokensUsed + childTokens,
    breakdown: spawn.tokenBreakdown
  };
}
```

---

## 4. Implementation Approach

### 4.1 Core Components

```
┌────────────────────────────────────────────────────────────────┐
│                    ASYNC SPAWN SYSTEM                           │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  SpawnManager   │  │  PromiseRegistry│  │  TokenTracker   │ │
│  │                 │  │                 │  │                 │ │
│  │ - validate()    │  │ - register()    │  │ - reserve()     │ │
│  │ - enqueue()     │  │ - resolve()     │  │ - consume()     │ │
│  │ - execute()     │  │ - reject()      │  │ - release()     │ │
│  │ - notify()      │  │ - timeout()     │  │ - report()      │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  LimitEnforcer  │  │  WorkerPool     │  │  EventEmitter   │ │
│  │                 │  │                 │  │                 │ │
│  │ - checkDepth()  │  │ - acquire()     │  │ - emit()        │ │
│  │ - checkConcurrent│ │ - release()     │  │ - subscribe()   │ │
│  │ - checkChildren()│  │ - scale()       │  │ - broadcast()   │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### 4.2 API Design

```typescript
// Main spawn interface
interface AsyncSpawnAPI {
  // Core async spawn - returns immediately with a future
  spawn<T>(options: SpawnOptions): SpawnFuture<T>;
  
  // Batch spawn multiple subagents in parallel
  spawnAll<T>(options: SpawnOptions[]): SpawnFuture<T>[];
  
  // Spawn with automatic result collection
  spawnAndCollect<T>(options: SpawnOptions): Promise<T>;
  
  // Cancel a pending or running spawn
  cancel(spawnId: string): Promise<boolean>;
  
  // Get status of a spawn
  status(spawnId: string): Promise<SpawnStatus>;
  
  // Register event handlers
  on(event: SpawnEvent, handler: EventHandler): Unsubscribe;
}

// Future/Promise pattern for async results
interface SpawnFuture<T> {
  readonly spawnId: string;
  readonly status: SpawnStatus;
  
  // Await result (blocks only when called)
  result(): Promise<T>;
  
  // Check if completed without blocking
  isCompleted(): boolean;
  
  // Get result if completed, null otherwise
  peek(): T | null;
  
  // Cancel this spawn
  cancel(): Promise<boolean>;
}
```

### 4.3 Implementation Phases

#### Phase 1: Core Async Infrastructure
- [ ] Promise/Future registry
- [ ] Non-blocking spawn execution
- [ ] Basic event emission
- [ ] In-memory result storage

#### Phase 2: Token Tracking
- [ ] Token reservation system
- [ ] Cross-boundary aggregation
- [ ] Budget enforcement
- [ ] Token reporting API

#### Phase 3: Limit Integration
- [ ] Depth tracking in async context
- [ ] Concurrent spawn semaphore
- [ ] Queue management for limits
- [ ] Backpressure handling

#### Phase 4: Advanced Features
- [ ] Webhook callbacks
- [ ] Channel integration
- [ ] Result persistence
- [ ] Failure recovery

---

## 5. Risks and Mitigation Strategies

### 5.1 Risk Matrix

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Orphaned spawns (parent dies) | High | Medium | Parent heartbeat + timeout cleanup |
| Token budget overflow | High | Medium | Conservative reservation + reconciliation |
| Memory leaks (unresolved promises) | Medium | High | Promise registry with TTL + cleanup job |
| Deadlocks (circular waits) | Medium | Low | Cycle detection in spawn graph |
| Race conditions | Medium | Medium | Atomic state transitions + locking |
| Callback failures | Low | Medium | Retry queue + dead letter handling |

### 5.2 Detailed Mitigations

#### Risk: Orphaned Spawns
**Scenario:** Parent agent crashes or terminates while subagents are still running.

**Mitigation:**
```typescript
// Parent heartbeat mechanism
class ParentMonitor {
  private heartbeats: Map<string, Date> = new Map();
  
  startMonitoring(parentId: string): void {
    this.heartbeats.set(parentId, new Date());
    // Check every 30 seconds
    setInterval(() => this.checkHeartbeats(), 30000);
  }
  
  private checkHeartbeats(): void {
    const now = new Date();
    for (const [parentId, lastBeat] of this.heartbeats) {
      if (now.getTime() - lastBeat.getTime() > 60000) {
        // Parent hasn't checked in for 60s
        this.handleOrphanedParent(parentId);
      }
    }
  }
  
  private async handleOrphanedParent(parentId: string): Promise<void> {
    // Option 1: Cancel all children
    await spawnManager.cancelChildrenOf(parentId);
    
    // Option 2: Let children complete, buffer results
    await spawnManager.bufferResultsFor(parentId, { ttl: '1h' });
  }
}
```

#### Risk: Token Budget Overflow
**Scenario:** Actual token usage exceeds reserved budget across many async spawns.

**Mitigation:**
```typescript
// Conservative reservation with dynamic adjustment
class AdaptiveTokenReservation {
  // Reserve 120% of estimate to handle variance
  private safetyFactor = 1.2;
  
  // Track historical accuracy
  private accuracyHistory: number[] = [];
  
  calculateReservation(estimate: number): number {
    const avgAccuracy = this.getAverageAccuracy();
    // Adjust safety factor based on historical accuracy
    const adjustedFactor = this.safetyFactor * (2 - avgAccuracy);
    return Math.ceil(estimate * adjustedFactor);
  }
  
  // Reconcile and adjust after each spawn
  reconcile(reserved: number, actual: number): void {
    const accuracy = actual / reserved;
    this.accuracyHistory.push(accuracy);
    if (this.accuracyHistory.length > 100) {
      this.accuracyHistory.shift();
    }
  }
}
```

#### Risk: Memory Leaks from Unresolved Promises
**Scenario:** Parent never awaits results, promises accumulate in registry.

**Mitigation:**
```typescript
class PromiseRegistry {
  private promises: Map<string, RegisteredPromise> = new Map();
  private readonly DEFAULT_TTL = 3600000; // 1 hour
  
  register<T>(spawnId: string, ttl: number = this.DEFAULT_TTL): PromiseHandle<T> {
    const handle: PromiseHandle<T> = {
      promise: new Deferred<T>(),
      expiresAt: Date.now() + ttl
    };
    
    this.promises.set(spawnId, handle);
    return handle;
  }
  
  // Cleanup job runs every 5 minutes
  cleanup(): void {
    const now = Date.now();
    for (const [spawnId, handle] of this.promises) {
      if (handle.expiresAt < now) {
        // Reject expired promises
        handle.promise.reject(new Error('Spawn result expired'));
        this.promises.delete(spawnId);
      }
    }
  }
}
```

#### Risk: Deadlocks (Circular Dependencies)
**Scenario:** Agent A spawns B, B spawns C, C tries to spawn A.

**Mitigation:**
```typescript
class CycleDetector {
  private spawnGraph: Map<string, Set<string>> = new Map();
  
  canSpawn(parentId: string, wouldSpawnId: string): boolean {
    // Check if wouldSpawnId is already an ancestor of parentId
    return !this.isAncestor(wouldSpawnId, parentId);
  }
  
  private isAncestor(potentialAncestor: string, node: string): boolean {
    const parents = this.getParents(node);
    for (const parent of parents) {
      if (parent === potentialAncestor || this.isAncestor(potentialAncestor, parent)) {
        return true;
      }
    }
    return false;
  }
}
```

---

## 6. Integration with Existing Spawn Limits

### 6.1 Limit Enforcement in Async Model

```typescript
interface LimitState {
  currentDepth: number;
  activeCount: number;
  childrenCount: number;
}

class AsyncLimitEnforcer {
  private readonly limits = {
    maxConcurrent: 8,
    maxSpawnDepth: 3,
    maxChildrenPerAgent: 5
  };
  
  private state: Map<string, LimitState> = new Map();
  private globalActiveCount = 0;
  private queue: QueuedSpawn[] = [];
  
  async checkAndAcquire(parentId: string): Promise<boolean> {
    const parentState = this.state.get(parentId) || {
      currentDepth: 0,
      activeCount: 0,
      childrenCount: 0
    };
    
    // Check depth
    if (parentState.currentDepth >= this.limits.maxSpawnDepth) {
      return false;
    }
    
    // Check children per agent
    if (parentState.childrenCount >= this.limits.maxChildrenPerAgent) {
      return false;
    }
    
    // Check global concurrent
    if (this.globalActiveCount >= this.limits.maxConcurrent) {
      // Queue instead of reject
      return 'queued';
    }
    
    // Acquire slots
    this.globalActiveCount++;
    parentState.childrenCount++;
    this.state.set(parentId, parentState);
    
    return true;
  }
  
  release(parentId: string): void {
    this.globalActiveCount = Math.max(0, this.globalActiveCount - 1);
    
    const parentState = this.state.get(parentId);
    if (parentState) {
      parentState.childrenCount = Math.max(0, parentState.childrenCount - 1);
    }
    
    // Process queue
    this.processQueue();
  }
}
```

### 6.2 Queue Management

```typescript
interface QueuedSpawn {
  id: string;
  parentId: string;
  request: SpawnRequest;
  queuedAt: Date;
  priority: number;
}

class SpawnQueue {
  private queue: QueuedSpawn[] = [];
  
  enqueue(spawn: QueuedSpawn): void {
    // Insert by priority (higher first), then FIFO
    const index = this.queue.findIndex(s => s.priority < spawn.priority);
    if (index === -1) {
      this.queue.push(spawn);
    } else {
      this.queue.splice(index, 0, spawn);
    }
  }
  
  dequeue(parentId?: string): QueuedSpawn | undefined {
    if (parentId) {
      // Find next for specific parent
      const index = this.queue.findIndex(s => s.parentId === parentId);
      if (index !== -1) {
        return this.queue.splice(index, 1)[0];
      }
      return undefined;
    }
    // Global dequeue
    return this.queue.shift();
  }
  
  // Timeout old entries
  cleanup(maxAgeMs: number = 300000): void {
    const cutoff = Date.now() - maxAgeMs;
    this.queue = this.queue.filter(s => s.queuedAt.getTime() > cutoff);
  }
}
```

---

## 7. Monitoring and Observability

### 7.1 Key Metrics

```typescript
interface SpawnMetrics {
  // Performance
  spawnLatencyMs: Histogram;      // Time from request to execution
  executionTimeMs: Histogram;     // Time from execution to completion
  queueWaitMs: Histogram;         // Time spent in queue
  
  // Throughput
  spawnsPerSecond: Rate;
  completionsPerSecond: Rate;
  failuresPerSecond: Rate;
  
  // Resource usage
  activeSpawns: Gauge;
  queuedSpawns: Gauge;
  tokenConsumption: Counter;
  tokenReservations: Gauge;
  
  // Limits
  depthLimitHits: Counter;
  concurrentLimitHits: Counter;
  childrenLimitHits: Counter;
  
  // Reliability
  timeoutRate: Rate;
  cancellationRate: Rate;
  orphanCleanupCount: Counter;
}
```

### 7.2 Distributed Tracing

```
┌─────────────────────────────────────────────────────────────┐
│                    TRACE: Spawn Flow                         │
├─────────────────────────────────────────────────────────────┤
│  [Parent] ──spawn()──→ [Orchestrator] ──execute()──→ [Worker]│
│     │                      │                         │      │
│     │                      │                         │      │
│     │←─────future─────────│                         │      │
│     │                      │                         │      │
│     │                      │←──────result────────────│      │
│     │                      │                         │      │
│     │←─────resolve()──────│                         │      │
│     │                      │                         │      │
└─────────────────────────────────────────────────────────────┘

Trace Context Propagation:
- traceId: spans entire operation
- parentSpanId: links child to parent
- spawnDepth: current nesting level
- tokenBudget: remaining tokens
```

---

## 8. Summary

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Result Pattern | Promise/Future | Familiar async semantics, composable |
| Notification | Event-driven + callbacks | Flexible, supports multiple patterns |
| Token Tracking | Reserve-on-spawn, reconcile-on-complete | Prevents budget overruns |
| Limit Enforcement | Queue when at capacity | Better than rejection for throughput |
| Orphan Handling | Heartbeat + timeout | Balances reliability with cleanup |
| State Persistence | In-memory + optional external | Fast path with durability option |

### Acceptance Criteria Status

- [x] Design async spawn flow diagram
- [x] Propose callback/notification mechanism
- [x] Design token tracking for async spawns
- [x] Recommend implementation approach
- [x] Identify risks and mitigation strategies

### Next Steps

1. **Review** this design with stakeholders
2. **Prototype** Phase 1 (core async infrastructure)
3. **Benchmark** against synchronous spawn baseline
4. **Iterate** on token tracking accuracy
5. **Implement** full feature set incrementally

---

*Document Version: 1.0*
*Created: 2026-05-11*
*Reference: P1-SPAWN-LIMITS-DESIGN.md (constraints)*
