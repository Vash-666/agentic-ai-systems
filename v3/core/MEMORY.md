# MEMORY.md — Agent Memory System

**Version:** 3.0
**Purpose:** Structured memory with vector search, fact extraction, and linking
**Inspired by:** Mem0, A-MEM (Agentic Memory)

---

## Memory Architecture

```
┌─────────────────────────────────────────┐
│           MEMORY LAYERS                 │
├─────────────────────────────────────────┤
│  Layer 1: Working Memory (Session)      │
│  - Current conversation                 │
│  - Active context                       │
│  - Temporary state                      │
├─────────────────────────────────────────┤
│  Layer 2: Short-Term Memory (Daily)     │
│  - Daily logs: memory/YYYY-MM-DD.md     │
│  - Recent facts, decisions, actions     │
│  - Auto-generated                       │
├─────────────────────────────────────────┤
│  Layer 3: Long-Term Memory (Curated)    │
│  - MEMORY.md (strategic)                │
│  - User preferences                     │
│  - Project history                      │
│  - Manually curated                     │
├─────────────────────────────────────────┤
│  Layer 4: Vector Memory (Semantic)      │
│  - Embedded facts                       │
│  - Semantic search                      │
│  - Similarity matching                  │
└─────────────────────────────────────────┘
```

---

## Memory Operations

### Store a Memory

```yaml
memory:
  id: "uuid"
  timestamp: "ISO-8601"
  category: "preference|fact|decision|entity|other"
  importance: 0.0-1.0
  content: "The actual memory"
  tags: ["tag1", "tag2"]
  source: "agent_name|user|system"
  related: ["memory_id_1", "memory_id_2"]  # Linked memories
```

### Retrieve Memories

```yaml
query:
  text: "What does user prefer?"
  filters:
    category: "preference"
    importance: ">0.7"
    tags: ["communication"]
  limit: 5
  sort_by: "relevance|recency|importance"
```

### Memory Types

| Type | Example | Storage |
|------|---------|---------|
| Preference | "User prefers concise responses" | Long-term + Vector |
| Fact | "API key stored in env-secrets.sh" | Long-term |
| Decision | "Switched to manual WordPress updates" | Long-term + Daily |
| Entity | "Telegram bot: vash_ai_bot" | Long-term |
| Action | "Created health monitor cron" | Daily |

---

## Fact Extraction Protocol

At end of every session:

1. **Extract Facts:** What did we learn?
   - User preferences revealed
   - Technical decisions made
   - Errors encountered and fixes

2. **Score Importance:** 0.0-1.0
   - 0.9-1.0: Critical (passwords, API keys, major decisions)
   - 0.7-0.8: Important (preferences, project status)
   - 0.4-0.6: Useful (minor details, context)
   - 0.0-0.3: Trivial (can be forgotten)

3. **Store with Context:**
   - When did this happen?
   - Why is it important?
   - Related to what?

4. **Link Related:** Connect to existing memories
   - "This preference replaces previous preference X"
   - "This decision follows from decision Y"

---

## Memory Maintenance

### Weekly Review
- Review daily logs from the week
- Extract important facts to long-term memory
- Remove outdated information
- Verify accuracy

### Monthly Consolidation
- Merge duplicate memories
- Update stale information
- Archive old daily logs
- Review memory effectiveness

### Quarterly Audit
- Full memory system review
- Check for contradictions
- Update categories and tags
- Optimize retrieval performance

---

## Vector Memory Guidelines

### When to Use Vector Storage
- Facts that need semantic search
- User preferences (find by meaning, not exact match)
- Project context (related concepts)
- Error patterns (similar issues)

### When NOT to Use Vector Storage
- Temporary session state
- Exact values (API keys, paths)
- Time-sensitive data (use daily logs)
- Large documents (link instead)

### Embedding Strategy
- Use sentence-transformers or similar
- Chunk long memories into facts
- Include metadata with embeddings
- Update embeddings when facts change

---

## Memory Hygiene

### DO
- Store facts immediately when learned
- Tag memories for easy retrieval
- Link related memories
- Review and update regularly

### DON'T
- Store secrets (use env files)
- Store duplicate information
- Let memories grow unbounded
- Forget to extract facts from sessions

---

*Memory is the scaffold of intelligence. Build it carefully.*
