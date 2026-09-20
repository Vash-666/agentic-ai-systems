# Feature Spec: Scoped Memory Hierarchy

**Feature ID:** FEAT-003
**Title:** Scoped Memory Hierarchy — CrewAI-Style /project/agent/task Paths
**Status:** Draft
**Priority:** Medium
**Estimated Effort:** 3-4 days

---

## Problem Statement

The current v3 memory system (`MEMORY.md`) organizes memories into flat layers: Working, Short-Term, Long-Term, and Vector. While this works for a single agent, it breaks down in a multi-agent system where:

1. **No Project Isolation:** Memories from Project A leak into Project B. A fact about "user prefers dark mode for dashboard" in one project is irrelevant or wrong in another.
2. **No Agent Specialization:** `@research` memories (e.g., "API rate limit is 100/min") mix with `@content` memories (e.g., "user prefers casual tone"), reducing relevance for both.
3. **No Task Context:** A memory about a specific bug fix in Task #42 is not relevant to Task #43, but the current system has no way to scope it.
4. **Ambiguous Recall:** When an agent recalls memories, it gets a blend of global, project, agent, and task memories with no clear precedence or filtering.
5. **Memory Pollution:** Over time, the vector store accumulates irrelevant embeddings, degrading search quality.

The system needs a hierarchical namespace for memories, similar to CrewAI's context scoping or filesystem paths.

---

## Solution Approach

Implement a **scoped memory hierarchy** where every memory is stored at a specific path: `/project/agent/task`. Agents recall memories by querying a scope, and the system returns memories from that scope plus all parent scopes (inheritance), with relevance filtering.

### Key Design Decisions

1. **Path-Based Scoping:** Memories are stored under paths like `/product/research/api-limits` or `/global/content/tone-preferences`.
2. **Hierarchical Inheritance:** An agent working on `/product/research` sees memories from:
   - `/product/research` (most specific)
   - `/product` (project-level)
   - `/global` (universal)
3. **Explicit Agent Scope:** Each agent declares its default scope at initialization. Memories it creates are automatically tagged with that scope.
4. **Scoped Vector Search:** Vector embeddings include scope metadata. Similarity search is filtered by scope prefix before ranking.
5. **Memory Promotion/Demotion:** Important memories can be promoted up the hierarchy (e.g., a task-level preference becomes project-level). Stale memories are demoted or archived.

---

## Data Structures / Schemas

### Scoped Memory Schema

```typescript
interface ScopedMemory {
    id: string;                      // UUID
    timestamp: string;               // ISO-8601
    content: string;
    category: 'preference' | 'fact' | 'decision' | 'entity' | 'other';
    importance: number;              // 0.0-1.0

    scope: {
        path: string;                // e.g., "/product/research"
        level: 'global' | 'project' | 'agent' | 'task';
        project?: string;
        agent?: string;
        task?: string;
    };

    tags: string[];
    source: string;                  // agent name or 'user' or 'system'
    related: string[];               // Linked memory IDs

    embedding?: number[];
    metadata?: {
        promotedFrom?: string;       // Original scope if promoted
        expiresAt?: string;          // TTL for temporary memories
        accessCount: number;         // For recency scoring
        lastAccessed: string;
    };
}
```

### Scope Path Format

```
/global                    # Universal memories (user preferences, system facts)
/global/content            # Agent-class memories at global level
/global/research

/product                   # Project-level memories
/product/api-migration     # Sub-project
/product/website-redesign

/product/research          # Agent-level within project
/product/content
/product/quality

/product/research/task-42  # Task-level memories
/product/research/task-43
```

### Scope Inheritance Rules

```typescript
function getScopeHierarchy(scopePath: string): string[] {
    const parts = scopePath.split('/').filter(Boolean);
    const hierarchy: string[] = ['/global'];
    let current = '';
    for (const part of parts) {
        current += `/${part}`;
        hierarchy.push(current);
    }
    return hierarchy; // e.g., ["/global", "/product", "/product/research"]
}

// An agent at /product/research sees memories from:
// 1. /product/research (highest priority)
// 2. /product
// 3. /global
// But NOT from /product/content or /other-project
```

### Scoped Query Format

```typescript
interface ScopedMemoryQuery {
    text: string;                    // Semantic search text
    scope: string;                   // Current agent scope path
    includeParents: boolean;         // Include parent scopes (default: true)
    includeSiblings: boolean;        // Include same-level scopes (default: false)
    filters?: {
        category?: string;
        importance?: string;         // ">0.7", "0.4-0.8"
        tags?: string[];
        source?: string;
        createdAfter?: string;
        createdBefore?: string;
    };
    limit: number;
    sortBy: 'relevance' | 'recency' | 'importance' | 'composite';
}
```

---

## API / Interface Design

### TypeScript Interface

```typescript
interface ScopedMemoryStore {
    // Store a memory at a specific scope
    store(memory: Omit<ScopedMemory, 'id'>): Promise<ScopedMemory>;

    // Recall memories for a given scope
    recall(query: ScopedMemoryQuery): Promise<ScopedMemory[]>;

    // Scoped vector search (pre-filtered by scope)
    searchSimilar(
        embedding: number[],
        scope: string,
        limit?: number,
        threshold?: number
    ): Promise<ScopedMemory[]>;

    // Promote a memory up the hierarchy
    promote(memoryId: string, toScope: string): Promise<ScopedMemory>;

    // Demote or archive a memory
    demote(memoryId: string, toScope?: string): Promise<ScopedMemory>;

    // Get all memories in a scope (for inspection)
    listScope(scope: string, recursive?: boolean): Promise<ScopedMemory[]>;

    // Clean up stale memories in a scope
    cleanup(scope: string, maxAge?: string): Promise<number>; // Returns deleted count
}
```

### Configuration

```yaml
# In agent config or task definition
memory:
  defaultScope: "/product/research"
  inheritance:
    includeParents: true
    includeSiblings: false
    maxParentDepth: 3          # How far up the tree to climb
  autoPromote:
    enabled: true
    threshold: 0.8             # Importance > 0.8 gets promoted to parent scope
    minAccessCount: 3          # Must be accessed 3+ times
```

### CLI Commands

```bash
# Store a memory at a scope
openclaw memory store "API rate limit is 100/min" --scope /product/research --category fact --importance 0.7

# Recall memories for current scope
openclaw memory recall "What are the API limits?" --scope /product/research --limit 5

# List all memories in a scope
openclaw memory list --scope /product --recursive

# Promote a memory
openclaw memory promote <memory-id> --to /product

# Clean up old memories
openclaw memory cleanup --scope /product/research --older-than 30d
```

---

## Acceptance Criteria

- [ ] **AC1:** A memory stored at `/product/research` is returned when an agent at `/product/research` queries for it.
- [ ] **AC2:** A memory stored at `/product` is returned when an agent at `/product/research` queries (parent inheritance).
- [ ] **AC3:** A memory stored at `/product/content` is NOT returned when an agent at `/product/research` queries (sibling isolation).
- [ ] **AC4:** A memory stored at `/global` is returned to all agents (universal scope).
- [ ] **AC5:** Vector similarity search is pre-filtered by scope prefix before ranking.
- [ ] **AC6:** Promoting a memory from `/product/research/task-42` to `/product/research` preserves its ID and updates its scope path.
- [ ] **AC7:** Auto-promotion triggers when a memory's importance > threshold AND accessCount > minAccessCount.
- [ ] **AC8:** Cleanup removes memories older than the specified age within a scope (and optionally its children).
- [ ] **AC9:** Scope paths are validated: must start with `/global` or `/project-name`, max depth 4.

---

## Estimated Effort

| Phase | Duration | Description |
|-------|----------|-------------|
| Schema & Path Design | 0.5 day | ScopedMemory type, path validation, inheritance rules |
| Store & Recall Implementation | 1 day | Core store/recall with scope filtering |
| Vector Search Integration | 0.5 day | Pre-filter embeddings by scope prefix |
| Promote/Demote Logic | 0.5 day | Hierarchy movement, metadata updates |
| Auto-Promote & Cleanup | 0.5 day | Background jobs for promotion and TTL cleanup |
| CLI Commands | 0.5 day | `openclaw memory *` scoped variants |
| Testing | 0.5 day | Multi-scope recall, inheritance edge cases |
| **Total** | **3-4 days** | |

---

## Dependencies

- **FEAT-001 (SQLite Checkpointer):** Memories stored in SQLite for queryability.
- **FEAT-005 (Composite Recall Scoring):** Scoped recall benefits from composite ranking.
- Existing `MEMORY.md` layer system (scoped memory replaces flat layers).

## Risks

| Risk | Mitigation |
|------|------------|
| Overly restrictive scoping misses relevant memories | Sibling inclusion toggle; importance-based fallback to parent scope |
| Scope path typos create orphaned memories | Strict path validation at store time; regex enforcement |
| Deep hierarchies hurt query performance | Index on scope path; benchmark at 10k memories per scope |

---

*The right memory at the right scope.*
