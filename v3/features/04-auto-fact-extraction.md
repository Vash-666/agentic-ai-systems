# Feature Spec: Automatic Post-Task Fact Extraction

**Feature ID:** FEAT-004
**Title:** Automatic Post-Task Fact Extraction
**Status:** Implemented (v2)
**Priority:** Medium
**Estimated Effort:** 2-3 days

---

## Problem Statement

The current v3 system (`MEMORY.md`) requires manual fact extraction at the end of every session:

> "At end of every session: 1. Extract Facts... 2. Score Importance... 3. Store with Context... 4. Link Related..."

This manual process has several problems:

1. **Inconsistent Execution:** Agents forget to extract facts, especially under time pressure or when sessions end abruptly.
2. **Variable Quality:** Importance scoring is subjective and inconsistent across agents. One agent's "0.9" is another's "0.6".
3. **Missed Context:** Facts are extracted without structured analysis of what was actually learned vs. what was already known.
4. **No Task-Level Granularity:** Facts are extracted per session, but a session may contain multiple tasks with unrelated learnings.
5. **Delayed Storage:** Facts are only extracted at session end, meaning a crash mid-session loses all learnings.

The system needs automatic, structured, task-level fact extraction that runs without agent intervention.

---

## Solution Approach

Implement an **Automatic Fact Extraction Pipeline** that:

1. **Runs After Every Task:** Automatically triggers when a task transitions to `completed` or `failed`.
2. **Analyzes Task Artifacts:** Reads the task's output files, logs, and conversation history.
3. **Extracts Structured Facts:** Uses a dedicated extraction engine with precise regex patterns and heuristics.
4. **Scores Confidence Automatically:** Multi-factor confidence scoring (pattern reliability, context quality, specificity, structural integrity).
5. **Filters False Positives:** Blocklists, minimum lengths, and heuristics eliminate trivial or incorrect matches.
6. **Deduplicates Against Existing:** Content hashing prevents duplicate facts within a single extraction run.
7. **Stores Immediately:** Persists facts to the appropriate memory scope (see FEAT-003) without waiting for session end.

### Key Design Decisions

1. **Task-Level, Not Session-Level:** Facts are extracted per task, not per session. A session with 5 tasks produces 5 extraction runs.
2. **Pattern-Based Extraction:** Uses compiled regex with negative lookbehinds/lookaheads for precision.
3. **Structured Output:** Facts are extracted as JSON with typed fields, confidence scores, and source attribution.
4. **Confidence Scoring:** Every fact gets a 0.0-1.0 confidence score with a breakdown of contributing factors.
5. **False-Positive Filtering:** Blocklists for pronouns/trivial words, minimum length checks, and alpha-ratio heuristics.
6. **Novelty Detection:** Content hashing deduplicates within a run; vector similarity for cross-run deduplication (future).

---

## Data Structures / Schemas

### Extracted Fact Schema (v2)

```typescript
interface StructuredFact {
    id: string;                      // Deterministic hash (16-char hex)
    timestamp: string;               // ISO-8601
    factType: 'metric' | 'decision' | 'preference' | 'definition' | 'discovery' | 'correction' | 'pattern' | 'error';
    content: string;                 // Human-readable fact summary

    confidence: number;              // Overall confidence (0.0-1.0)
    confidenceFactors: {
        patternReliability: number;  // How reliable is the regex pattern
        contextQuality: number;      // Quality of surrounding context
        specificity: number;         // How specific/detailed is the fact
        structuralIntegrity: number; // Are all required fields present
    };

    importance: number;              // Estimated importance (0.0-1.0)

    source: {
        source: string;              // Source identifier (agent name, file path)
        sourceType: string;          // text, file, api, conversation
        lineNumber?: number;         // Line number in source text
        charOffset?: number;         // Character offset in source text
        contextBefore: string;       // Text before match (up to 50 chars)
        contextAfter: string;        // Text after match (up to 50 chars)
        extractedAt: string;         // ISO-8601 extraction timestamp
    };

    metadata: {
        factType: string;            // Redundant for quick filtering
        // Type-specific fields:
        // metric: { value, unit }
        // definition: { subject, predicate }
        // decision: { decision }
        // preference: { preference }
    };

    tags: string[];                  // e.g., ["metric", "quantitative"]
}
```

### Confidence Scoring Algorithm

```
confidence = (
    patternReliability * 0.30 +
    contextQuality * 0.20 +
    specificity * 0.30 +
    structuralIntegrity * 0.20
)
```

**Pattern Reliability** (fixed per fact type):
| Type | Reliability |
|------|-------------|
| metric | 0.95 |
| definition | 0.90 |
| decision | 0.85 |
| preference | 0.80 |
| error | 0.80 |
| correction | 0.75 |
| discovery | 0.70 |
| pattern | 0.65 |

**Context Quality**: Based on available surrounding text (0.3-0.9).

**Specificity**: Based on word count, named entities, and numeric precision (0.5-1.0).

**Structural Integrity**: Based on presence and quality of regex capture groups (0.5-1.0).

### Importance Scoring Algorithm

```
importance = baseScore[type] + (confidence * 0.1) + criticalTermBoost
```

Base scores:
| Type | Base |
|------|------|
| decision | 0.85 |
| error | 0.80 |
| correction | 0.75 |
| discovery | 0.70 |
| metric | 0.65 |
| definition | 0.55 |
| preference | 0.50 |
| pattern | 0.45 |

Critical terms (security, performance, cost, quality, user, error, failure, bug) add +0.05.

---

## Supported Fact Types

### 1. Metrics (`metric`)
- **Patterns**: Percentages (`88%`), scores (`9.0/10`), durations (`45 minutes`), counts (`5 agents`), sizes (`2.5 MB`)
- **False-Positive Filters**: Rejects standalone years, version numbers without context
- **Metadata**: `{ value, unit }`

### 2. Decisions (`decision`)
- **Patterns**: "decided to X", "chose to X", "we will use X", "recommend X"
- **False-Positive Filters**: Rejects fragments < 3 words, sentences starting with conjunctions
- **Metadata**: `{ decision }`

### 3. Preferences (`preference`)
- **Patterns**: "prefer X", "would rather X", "want X", "X is preferred"
- **False-Positive Filters**: Rejects matches < 2 words
- **Metadata**: `{ preference }`

### 4. Definitions (`definition`)
- **Patterns**: "X is a Y", "X refers to Y", "X is defined as Y"
- **False-Positive Filters**: Rejects pronoun subjects, trivial predicates, "It is" constructions
- **Metadata**: `{ subject, predicate }`

### 5. Discoveries (`discovery`)
- **Patterns**: "found that X", "discovered X", "it turns out X"
- **Metadata**: `{ discovery }`

### 6. Corrections (`correction`)
- **Patterns**: "was wrong about X", "corrected X", "actually, X"
- **Metadata**: `{ correction }`

### 7. Patterns (`pattern`)
- **Patterns**: "always X", "usually X", "X tends to Y"
- **Metadata**: `{ pattern }`

### 8. Errors (`error`)
- **Patterns**: "error: X", "failed to X", "exception X"
- **Metadata**: `{ error }`

---

## False-Positive Filtering

### Subject Blocklist
Pronouns and trivial words are rejected as definition subjects: `it`, `this`, `that`, `there`, `here`, `what`, `which`, `who`, `when`, `where`, `why`, `how`, `i`, `you`, `he`, `she`, `we`, `they`, `the`, `a`, `an`, `one`, `some`, `any`, `all`, etc.

### Predicate Blocklist
Trivial words are rejected as definition predicates: `a`, `an`, `the`, `this`, `that`, `it`, `they`, `here`, `there`, etc.

### Minimum Lengths
- Subject: 3 characters
- Predicate: 3 characters
- Content: 5 characters

### Alpha Ratio Check
Matches that are > 50% punctuation are rejected.

---

## API / Interface Design

### Python Interface

```python
from fact_extractor import FactExtractor, StructuredFact

# Initialize extractor
extractor = FactExtractor(min_confidence=0.5, min_importance=0.3)

# Extract facts from text
facts: List[StructuredFact] = extractor.extract_facts(text, source="@switch")

# Get JSON output
json_output: str = extractor.extract_to_json(text, source="@switch")

# Get Python objects
objects: List[Dict] = extractor.extract_to_objects(text, source="@switch")

# Process agent output (extract + store)
result: Dict = process_agent_output(output_text, agent_name="@switch")
# Returns: { agent, facts_extracted, facts[], summary { by_type, avg_confidence, avg_importance } }
```

### Configuration

```yaml
fact_extraction:
    enabled: true
    trigger: "task_completed"        # or "session_end", "manual"
    maxFactsPerTask: 5
    minConfidenceThreshold: 0.5      # Facts below this are discarded
    minImportanceThreshold: 0.3      # Facts below this are discarded
    deduplication:
        similarityThreshold: 0.85    # Cosine similarity for duplicate detection
        updateExisting: true         # Update vs. skip duplicates
    scopes:
        preference: "/global"
        decision: "/{project}"
        discovery: "/{project}/{agent}"
        error: "/{project}/{agent}"
    output:
        markdownFile: "memory/STRATEGIC.md"
        jsonlFile: "memory/facts.jsonl"
```

### CLI Commands

```bash
# Trigger extraction for a task manually
openclaw facts extract --task <task-id>

# View extracted facts for a task
openclaw facts show --task <task-id>

# Review pending extractions
openclaw facts pending

# Re-run extraction with different thresholds
openclaw facts extract --task <task-id> --min-confidence 0.7

# Export facts as JSON
openclaw facts export --format json --output facts.json
```

---

## Storage Format

### Markdown Output (`memory/STRATEGIC.md`)

```markdown
## Auto-Extracted Facts — 2026-09-17T02:15:59

**Source:** @switch | **Facts:** 9

- **[DEFINITION]** A state machine is mathematical model of computation used to design algorithms
  - Confidence: 0.89 (pattern=0.90, context=0.90, specificity=0.80, integrity=1.00)
  - Importance: 0.64
  - Source: @switch (line 5)
  - Tags: definition

- **[METRIC]** 88%
  - Confidence: 0.95 (pattern=0.95, context=0.90, specificity=0.90, integrity=1.00)
  - Importance: 0.70
  - Source: @switch (line 7)
  - Tags: metric, quantitative
```

### JSONL Output (`memory/facts.jsonl`)

Each line is a self-contained JSON object (StructuredFact schema), suitable for streaming and log aggregation.

---

## Acceptance Criteria

- [x] **AC1:** When a task transitions to `completed`, fact extraction triggers automatically within 5 seconds.
- [x] **AC2:** Extracted facts include type, confidence score with factor breakdown, and source context.
- [x] **AC3:** Facts with confidence < `minConfidenceThreshold` are discarded and not stored.
- [x] **AC4:** Facts with importance < `minImportanceThreshold` are discarded and not stored.
- [x] **AC5:** False positives are filtered via blocklists, minimum lengths, and alpha-ratio checks.
- [x] **AC6:** Facts are stored at the correct scope based on their type (e.g., preferences → `/global`, discoveries → `/{project}/{agent}`).
- [x] **AC7:** Extraction runs asynchronously and does not block the agent's next task.
- [x] **AC8:** Failed extractions are retried once and then logged; they do not crash the system.
- [x] **AC9:** A task with no learnings (e.g., routine cleanup) produces zero facts without error.
- [x] **AC10:** Extracted facts support structured JSON output with full metadata.
- [x] **AC11:** Source attribution includes line numbers, character offsets, and surrounding context.
- [ ] **AC12:** Extracted facts are queryable via `openclaw memory recall` within 10 seconds of storage. (Depends on FEAT-005)

---

## Implementation Files

| File | Description |
|------|-------------|
| `scripts/implementations/04-fact-extractor-v2.py` | Main implementation with FactExtractor class |
| `memory/STRATEGIC.md` | Markdown fact storage (auto-generated) |
| `memory/facts.jsonl` | JSONL fact log (auto-generated) |

---

## Changelog

### v2 (2026-09-17)
- **Improved regex patterns** with word boundaries and negative lookbehinds
- **Multi-factor confidence scoring** (pattern reliability, context quality, specificity, structural integrity)
- **False-positive filtering** via blocklists, minimum lengths, and alpha-ratio checks
- **Structured JSON output** with full metadata and source attribution
- **Source attribution** with line numbers, character offsets, and surrounding context
- **Content hashing deduplication** within extraction runs
- **8 fact types** supported: metric, decision, preference, definition, discovery, correction, pattern, error
- **Dual storage**: Markdown for human review, JSONL for programmatic access

### v1 (Original)
- Basic regex patterns for "is_a", decision, metric, preference
- Simple importance scoring (fixed per type)
- Markdown-only storage
- No confidence scoring or false-positive filtering

---

## Dependencies

- **FEAT-001 (SQLite Checkpointer):** Task status triggers stored in DB.
- **FEAT-003 (Scoped Memory Hierarchy):** Facts stored at correct scope paths.
- **FEAT-005 (Composite Recall Scoring):** Deduplication uses vector similarity.
- Existing `MEMORY.md` fact extraction protocol (replaced by automation).

## Risks

| Risk | Mitigation |
|------|------------|
| Model hallucinates false facts | Pattern-based extraction (no LLM); structured output schema; human review queue for high-importance facts |
| Extraction is slow/costly | Regex-based (no API calls); async execution; max 5 facts per task |
| Over-extraction creates noise | Minimum confidence/importance thresholds; aggressive deduplication |
| Duplicate detection misses near-duplicates | Content hashing within runs; tunable similarity threshold for cross-run; manual review queue |

---

*Every task teaches something. Never waste a lesson.*
