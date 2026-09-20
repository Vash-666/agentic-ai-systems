# Feature Spec: ARC Compaction — Pointer-Based Summaries

**Feature ID:** FEAT-006
**Title:** ARC Compaction — Automatic Context Compression via Pointer-Based Summaries
**Status:** Draft
**Priority:** Medium
**Estimated Effort:** 4-5 days

---

## Problem Statement

As agent sessions grow longer and more complex, the working context (conversation history, file contents, task outputs, handoff artifacts) grows without bound. This leads to:

1. **Token Bloat:** LLM context windows are consumed by irrelevant historical details, reducing available tokens for actual reasoning.
2. **Signal-to-Noise Degradation:** Early session details drown out recent critical information.
3. **Cost Inflation:** Every API call sends more tokens than necessary, increasing costs.
4. **Slow Context Loading:** Reading and parsing large context files on every agent switch adds latency.
5. **No Granular Recovery:** If context is truncated, specific details are lost with no way to retrieve them on demand.

Current approaches (simple truncation, sliding windows) are lossy and undifferentiated. The system needs an intelligent compaction mechanism that preserves semantic coverage while dramatically reducing token count.

---

## Solution Approach

Implement **ARC (Adaptive Recursive Compaction)**, a pointer-based summarization system inspired by hierarchical memory compression and log-structured merge trees:

1. **Hierarchical Summarization:** Conversation segments are summarized at multiple levels of detail (L0=raw, L1=paragraph, L2=bullet, L3=single sentence).
2. **Pointer References:** Higher-level summaries contain pointers to lower-level segments. When a detail is needed, the system can "dereference" the pointer to retrieve the original.
3. **Lazy Decompression:** The agent sees only the summary level appropriate for its current task. If it needs details, it requests a pointer dereference.
4. **Automatic Triggering:** Compaction triggers when context size exceeds a threshold (e.g., 50% of context window).
5. **Semantic Chunking:** Segments are chunked at semantic boundaries (task completions, handoffs, topic shifts) rather than fixed token counts.

### Key Design Decisions

1. **Multi-Level Summaries:** 4 levels (L0 raw, L1 detailed, L2 concise, L3 atomic). Each level is ~10x smaller than the previous.
2. **Pointer IDs:** Every segment and summary has a stable UUID. Pointers are lightweight references.
3. **Compaction Policy:** Configurable by agent type. `@research` keeps more L1 detail; `@switch` operates mostly on L2/L3.
4. **Lossless at L0:** Raw segments are archived, not deleted. They can always be retrieved.
5. **Incremental Compaction:** Only new segments since last compaction are processed, not the entire history.

---

## Data Structures / Schemas

### ARC Node Schema

```typescript
interface ARCNode {
    id: string;                      // UUID, stable across compactions
    level: 0 | 1 | 2 | 3;            // 0=raw, 1=detailed, 2=concise, 3=atomic

    content: string;                 // The summary or raw text
    tokenCount: number;              // Estimated tokens

    // Hierarchy
    parentId?: string;               // Higher-level summary that references this
    childIds: string[];              // Lower-level nodes this summarizes

    // Metadata
    scope: string;                   // Memory scope path (see FEAT-003)
    timestamp: string;               // ISO-8601
    sourceType: 'conversation' | 'handoff' | 'task_output' | 'file_read' | 'decision';
    sourceId: string;                // Original task/session ID

    // Semantic
    embedding?: number[];            // For similarity-based retrieval
    keywords: string[];              // Extracted key terms
    entities: string[];              // Named entities mentioned

    // Access tracking
    accessCount: number;
    lastAccessed: string;
    lastDereferenced: string;        // When child content was last fetched

    // Compaction status
    compacted: boolean;              // Has this node been summarized into a parent?
    archivePath?: string;            // Path to L0 raw data if offloaded
}
```

### ARC Tree Structure

```
L3 (Atomic)          "Migrated auth to OAuth2, fixed 3 bugs, deployed v2.1"
    ↓ points to
L2 (Concise)         "Auth migration: OAuth2 implementation... Bug fixes: #142, #143, #144..."
    ↓ points to
L1 (Detailed)        [Paragraph summaries of each task]
    ↓ points to
L0 (Raw)             [Full conversation logs, file contents, command outputs]
```

### Compaction Trigger

```typescript
interface CompactionConfig {
    enabled: boolean;
    triggerThreshold: number;        // % of context window (default: 50)
    targetLevel: 1 | 2 | 3;          // Compact to this level

    // Per-level token targets
    levelTargets: {
        0: number;                   // Keep raw if under this (default: 4000)
        1: number;                   // Target size for L1 (default: 400)
        2: number;                   // Target size for L2 (default: 100)
        3: number;                   // Target size for L3 (default: 20)
    };

    // Semantic chunking
    chunkBy: 'tokens' | 'turns' | 'tasks' | 'semantic';
    chunkSize: number;               // Tokens per chunk (if chunkBy=tokens)

    // What to compact
    includeConversations: boolean;
    includeHandoffs: boolean;
    includeFileReads: boolean;
    includeTaskOutputs: boolean;

    // Archive
    archiveL0: boolean;              // Move raw to disk after compaction
    archivePath: string;             // e.g., "memory/archive/"
}
```

### Context Assembly

```typescript
interface ContextAssembly {
    // Build the context window for an agent
    assemble(
        agentId: string,
        taskId: string,
        maxTokens: number,
        priorityQuery?: string         // Boost segments relevant to current task
    ): Promise<{
        segments: Array<{
            nodeId: string;
            level: number;
            content: string;
            dereferenceable: boolean;  // Can fetch more detail?
        }>;
        totalTokens: number;
        coverage: number;             // % of original context represented
        dereferenceCount: number;     // How many pointers included
    }>;

    // Dereference a pointer to get more detail
    dereference(nodeId: string, targetLevel?: number): Promise<ARCNode[]>;

    // Force compaction
    compact(scope: string, targetLevel?: number): Promise<{
        nodesCompacted: number;
        tokensBefore: number;
        tokensAfter: number;
        compressionRatio: number;
    }>;
}
```

---

## API / Interface Design

### TypeScript Interface

```typescript
interface ARCCompactor {
    // Initialize ARC for a session
    initialize(sessionId: string, config: CompactionConfig): Promise<void>;

    // Ingest a new segment into ARC
    ingest(
        sessionId: string,
        content: string,
        sourceType: ARCNode['sourceType'],
        sourceId: string
    ): Promise<ARCNode>;

    // Assemble context for an agent
    assembleContext(
        sessionId: string,
        agentId: string,
        options: AssemblyOptions
    ): Promise<AssembledContext>;

    // Dereference pointers for more detail
    dereference(nodeIds: string[], targetLevel?: number): Promise<ARCNode[]>;

    // Trigger compaction
    compact(sessionId: string, force?: boolean): Promise<CompactionResult>;

    // Get ARC tree statistics
    getStats(sessionId: string): Promise<{
        totalNodes: number;
        nodesByLevel: Record<number, number>;
        totalTokens: number;
        tokensByLevel: Record<number, number>;
        compressionRatio: number;
    }>;

    // Search within ARC (semantic)
    search(
        sessionId: string,
        query: string,
        queryEmbedding: number[]
    ): Promise<Array<{ node: ARCNode; similarity: number }>>;
}

interface AssemblyOptions {
    maxTokens: number;
    minLevel?: number;               // Don't go below this level
    priorityQuery?: string;          // Boost relevant segments
    includeDereferenceHints: boolean; // Add "[details: <nodeId>]" markers
}

interface AssembledContext {
    text: string;
    segments: Array<{ nodeId: string; level: number; content: string }>;
    totalTokens: number;
    dereferenceHints: string[];
}

interface CompactionResult {
    nodesCreated: number;
    nodesArchived: number;
    tokensBefore: number;
    tokensAfter: number;
    compressionRatio: number;
}
```

### Summarization Prompts

```yaml
# L1: Detailed summary (reduce ~10x)
system: |
  Summarize the following conversation segment into 2-3 paragraphs.
  Preserve: key decisions, technical details, error messages, file paths.
  Omit: greetings, filler, repeated information.

# L2: Concise summary (reduce ~40x)
system: |
  Summarize the following detailed summary into 3-5 bullet points.
  Each bullet: "Action: Result" format.
  Preserve: outcomes, blockers, next steps.

# L3: Atomic summary (reduce ~200x)
system: |
  Summarize the following into a single sentence of <25 words.
  Format: "[Topic]: [What happened] → [Outcome]"
```

### CLI Commands

```bash
# View ARC stats for current session
openclaw arc stats

# Force compaction
openclaw arc compact --level 2

# Dereference a pointer
openclaw arc dereference --node <node-id> --level 1

# Search within ARC
openclaw arc search "OAuth2 migration"

# Assemble context for debugging
openclaw arc assemble --agent @research --max-tokens 4000

# Configure compaction policy
openclaw arc config --threshold 60 --archive-l0 true
```

---

## Acceptance Criteria

- [ ] **AC1:** A 10,000-token conversation segment compacts to <1,000 tokens at L1, <250 tokens at L2, and <50 tokens at L3.
- [ ] **AC2:** Dereferencing an L3 node to L0 returns the original full content without loss.
- [ ] **AC3:** Context assembly stays within `maxTokens` budget while maximizing semantic coverage.
- [ ] **AC4:** Compaction triggers automatically when context exceeds 50% of the configured window.
- [ ] **AC5:** Incremental compaction only processes new segments since last compaction (not full history).
- [ ] **AC6:** Semantic chunking splits at task boundaries, handoffs, or topic shifts, not mid-sentence.
- [ ] **AC7:** Archived L0 segments are stored on disk and retrievable via dereference.
- [ ] **AC8:** Assembly includes dereference hints so the agent knows it can ask for more detail.
- [ ] **AC9:** ARC search returns relevant segments across all levels based on semantic similarity.
- [ ] **AC10:** Compression ratio is reported and logged for monitoring.

---

## Estimated Effort

| Phase | Duration | Description |
|-------|----------|-------------|
| ARC Node & Tree Design | 0.5 day | Schema, pointer structure, hierarchy |
| Ingestion & Chunking | 1 day | Semantic chunking, source type handling |
| Summarization Pipeline | 1 day | L1/L2/L3 prompts, model calls, quality validation |
| Context Assembly | 1 day | Token-budget assembly, priority boosting, dereference hints |
| Dereference & Archive | 0.5 day | Pointer resolution, L0 disk archive, retrieval |
| Auto-Compaction Trigger | 0.5 day | Threshold monitoring, incremental compaction |
| CLI & Stats | 0.5 day | Commands, stats reporting, configuration |
| Testing | 0.5-1 day | End-to-end compaction, dereference accuracy, token budgets |
| **Total** | **4-5 days** | |

---

## Dependencies

- **FEAT-001 (SQLite Checkpointer):** ARC nodes stored in SQLite for fast pointer lookups.
- **FEAT-003 (Scoped Memory Hierarchy):** ARC nodes tagged with scope paths.
- **FEAT-005 (Composite Recall Scoring):** Semantic search within ARC uses composite scoring.
- LLM access for summarization (uses existing model configuration).

## Risks

| Risk | Mitigation |
|------|------------|
| Summarization loses critical details | Multi-level review; dereference always available; human validation on L3 |
| Compaction is slow/costly | Incremental only; cheaper model for L2/L3; async execution |
| Pointer chasing adds latency | Cache hot nodes; prefetch likely dereferences |
| Over-compaction hurts reasoning | Agent-specific policies; `@research` keeps more L1 detail |

---

*Compress without losing the thread.*
