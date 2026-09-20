# Feature Spec: Composite Recall Scoring

**Feature ID:** FEAT-005
**Title:** Composite Recall Scoring — Semantic + Recency + Importance
**Status:** Draft
**Priority:** Medium
**Estimated Effort:** 2-3 days

---

## Problem Statement

The current v3 memory system (`MEMORY.md`) supports recalling memories by `relevance`, `recency`, or `importance` individually:

> `sort_by: "relevance|recency|importance"`

This single-factor sorting is inadequate because:

1. **High Relevance, Low Importance:** A semantically similar but trivial memory ("user said 'ok'") can outrank a highly important but less semantically matching memory ("user's production API key changed").
2. **Stale but Relevant:** An old memory about a deprecated API version may score high on semantic similarity but should be penalized for age.
3. **Important but Forgotten:** A critical fact that hasn't been accessed recently drifts down in recency-based sorts, even though it should remain top-of-mind.
4. **No Personalization:** All agents use the same scoring weights, but `@research` might prioritize recency (API docs change) while `@content` prioritizes importance (brand voice guidelines).

The system needs a composite scoring function that balances multiple factors with configurable weights.

---

## Solution Approach

Implement a **Composite Recall Scoring** system that calculates a final score for each memory by combining:

1. **Semantic Similarity** (cosine similarity between query embedding and memory embedding)
2. **Recency Score** (time-decayed; newer memories score higher)
3. **Importance Score** (static or dynamically adjusted based on access patterns)
4. **Access Frequency** (memories accessed often are more relevant)
5. **Scope Relevance** (memories closer to the agent's current scope score higher — see FEAT-003)

### Key Design Decisions

1. **Weighted Linear Combination:** FinalScore = w₁×Semantic + w₂×Recency + w₃×Importance + w₄×Frequency + w₅×Scope
2. **Configurable Weights:** Per-agent or per-task weight profiles. Default weights work for most cases.
3. **Time Decay Function:** Exponential decay for recency. Half-life configurable (default: 7 days).
4. **Dynamic Importance Adjustment:** Memories accessed frequently get a small importance boost (feedback loop).
5. **Normalized Scores:** Each component is normalized to 0.0-1.0 before weighting.

---

## Data Structures / Schemas

### Composite Score Components

```typescript
interface ScoreComponents {
    semantic: number;        // 0.0-1.0, cosine similarity
    recency: number;         // 0.0-1.0, time-decayed
    importance: number;      // 0.0-1.0, stored importance + dynamic boost
    frequency: number;       // 0.0-1.0, access count normalized
    scope: number;           // 0.0-1.0, scope distance penalty/bonus
}

interface CompositeScore {
    total: number;           // 0.0-1.0, weighted sum
    components: ScoreComponents;
    weights: ScoreWeights;
    explanation: string;     // Human-readable breakdown
}

interface ScoreWeights {
    semantic: number;
    recency: number;
    importance: number;
    frequency: number;
    scope: number;
}

// Predefined weight profiles
const WEIGHT_PROFILES: Record<string, ScoreWeights> = {
    default:      { semantic: 0.35, recency: 0.25, importance: 0.25, frequency: 0.10, scope: 0.05 },
    research:     { semantic: 0.40, recency: 0.35, importance: 0.10, frequency: 0.10, scope: 0.05 },
    content:      { semantic: 0.30, recency: 0.15, importance: 0.40, frequency: 0.10, scope: 0.05 },
    quality:      { semantic: 0.25, recency: 0.20, importance: 0.35, frequency: 0.10, scope: 0.10 },
    recencyFirst: { semantic: 0.20, recency: 0.50, importance: 0.15, frequency: 0.10, scope: 0.05 },
    importanceFirst: { semantic: 0.20, recency: 0.15, importance: 0.50, frequency: 0.10, scope: 0.05 },
};
```

### Score Calculation Formulas

```typescript
// 1. Semantic Score (already 0-1 from cosine similarity)
function semanticScore(similarity: number): number {
    return Math.max(0, Math.min(1, similarity));
}

// 2. Recency Score — exponential decay
function recencyScore(timestamp: string, halfLifeDays: number = 7): number {
    const ageMs = Date.now() - new Date(timestamp).getTime();
    const ageDays = ageMs / (1000 * 60 * 60 * 24);
    return Math.exp(-ageDays / halfLifeDays);
}

// 3. Importance Score — stored value + dynamic boost
function importanceScore(
    storedImportance: number,
    accessCount: number,
    maxAccessCount: number
): number {
    const frequencyBoost = Math.min(accessCount / Math.max(maxAccessCount, 1), 0.2); // Max 0.2 boost
    return Math.min(1, storedImportance + frequencyBoost);
}

// 4. Frequency Score — normalized access count
function frequencyScore(accessCount: number, maxAccessCount: number): number {
    return Math.min(1, accessCount / Math.max(maxAccessCount, 1));
}

// 5. Scope Score — closer scope = higher score
function scopeScore(memoryScope: string, queryScope: string): number {
    const memoryParts = memoryScope.split('/').filter(Boolean);
    const queryParts = queryScope.split('/').filter(Boolean);
    let matchDepth = 0;
    for (let i = 0; i < Math.min(memoryParts.length, queryParts.length); i++) {
        if (memoryParts[i] === queryParts[i]) matchDepth++;
        else break;
    }
    return matchDepth / Math.max(memoryParts.length, queryParts.length, 1);
}

// Final composite score
function compositeScore(
    components: ScoreComponents,
    weights: ScoreWeights
): number {
    const total =
        components.semantic * weights.semantic +
        components.recency * weights.recency +
        components.importance * weights.importance +
        components.frequency * weights.frequency +
        components.scope * weights.scope;

    const weightSum = Object.values(weights).reduce((a, b) => a + b, 0);
    return total / weightSum;
}
```

### Memory Metadata for Scoring

```typescript
interface MemoryMetadata {
    // ... existing fields ...

    scoring: {
        accessCount: number;
        lastAccessed: string;
        firstStored: string;
        halfLifeDays: number;        // Per-memory override
        dynamicImportance: number;   // Adjusted over time
    };

    // For explanation generation
    scoreHistory: Array<{
        timestamp: string;
        query: string;
        total: number;
        components: ScoreComponents;
    }>;
}
```

---

## API / Interface Design

### TypeScript Interface

```typescript
interface RecallScorer {
    // Calculate composite score for a memory against a query
    score(
        memory: ScopedMemory,
        query: string,
        queryEmbedding: number[],
        queryScope: string,
        weights?: ScoreWeights
    ): CompositeScore;

    // Rank memories by composite score
    rank(
        memories: ScopedMemory[],
        query: string,
        queryEmbedding: number[],
        queryScope: string,
        options?: RankOptions
    ): Array<{ memory: ScopedMemory; score: CompositeScore }>;

    // Update access metadata when a memory is recalled
    recordAccess(memoryId: string): Promise<void>;

    // Get or set weight profile for an agent
    getProfile(agentId: string): ScoreWeights;
    setProfile(agentId: string, weights: ScoreWeights): void;

    // Explain why a memory scored the way it did
    explain(memoryId: string, query: string): Promise<string>;
}

interface RankOptions {
    weights?: ScoreWeights;
    profile?: string;            // Use named profile
    limit?: number;
    minScore?: number;           // Filter out below threshold
    halfLifeDays?: number;       // Override default recency decay
}
```

### Configuration

```yaml
recall_scoring:
    defaultProfile: "default"
    halfLifeDays: 7               # Default recency decay
    maxAccessBoost: 0.2           # Max importance boost from frequent access
    profiles:
        @research:
            semantic: 0.40
            recency: 0.35
            importance: 0.10
            frequency: 0.10
            scope: 0.05
        @content:
            semantic: 0.30
            recency: 0.15
            importance: 0.40
            frequency: 0.10
            scope: 0.05
        @quality:
            semantic: 0.25
            recency: 0.20
            importance: 0.35
            frequency: 0.10
            scope: 0.10
```

### CLI Commands

```bash
# Recall with composite scoring
openclaw memory recall "API authentication" --profile research --limit 5

# Explain why a memory was ranked highly
openclaw memory explain --memory <id> --query "API authentication"

# View scoring profiles
openclaw memory profiles

# Tune weights for an agent
openclaw memory profile set @research --semantic 0.5 --recency 0.3

# Benchmark recall quality
openclaw memory benchmark --query "deployment process" --expected <memory-id>
```

---

## Acceptance Criteria

- [ ] **AC1:** A memory with high semantic similarity but low importance scores lower than a memory with medium similarity and high importance (under default weights).
- [ ] **AC2:** A 30-day-old memory scores lower on recency than a 1-day-old memory (with same other factors).
- [ ] **AC3:** A memory accessed 10 times gets a higher importance score than an identical memory accessed once.
- [ ] **AC4:** `@research` agent uses a different weight profile than `@content` agent automatically.
- [ ] **AC5:** Scope distance affects score: a memory at `/product/research` scores higher for a `/product/research` query than one at `/global`.
- [ ] **AC6:** The `explain` command returns a human-readable breakdown of score components.
- [ ] **AC7:** All component scores are normalized to 0.0-1.0 before weighting.
- [ ] **AC8:** The final composite score is deterministic: same memory + same query + same weights = same score.
- [ ] **AC9:** Ranked results are returned in <200ms for 1000 candidate memories.

---

## Estimated Effort

| Phase | Duration | Description |
|-------|----------|-------------|
| Score Component Design | 0.5 day | Define formulas, normalization, decay curves |
| Scorer Implementation | 1 day | Core scoring engine, component calculators |
| Profile System | 0.5 day | Per-agent weight profiles, configuration |
| Access Tracking | 0.5 day | Record access counts, dynamic importance updates |
| Explainability | 0.5 day | Human-readable score breakdowns |
| CLI & Benchmarking | 0.5 day | Commands, quality benchmarking tool |
| Testing | 0.5 day | Component tests, integration with recall pipeline |
| **Total** | **2-3 days** | |

---

## Dependencies

- **FEAT-003 (Scoped Memory Hierarchy):** Scope score component requires scoped memories.
- **FEAT-001 (SQLite CheckPOINTER):** Access counts and score history stored in DB.
- Existing vector store for semantic similarity.

## Risks

| Risk | Mitigation |
|------|------------|
| Weight tuning is subjective | Provide presets; A/B benchmark tool; agent-specific defaults |
| Score calculation is slow | Cache embeddings; precompute recency scores; index access counts |
| Over-optimization for one component | Ensure all weights are non-zero; validate with benchmarks |

---

*The best memory is the one you need, when you need it.*
