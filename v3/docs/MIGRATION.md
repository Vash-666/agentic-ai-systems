# MIGRATION.md — v2.0 → v3.0 Migration Guide

**Version:** 3.0
**Date:** 2026-09-16

---

## What Changed

### Architecture
| v2.0 | v3.0 |
|------|------|
| Flat file structure | Organized hierarchy |
| Ad-hoc handoffs | Structured HANDOFF.md protocol |
| Implicit agent roles | Explicit AGENT.md definitions |
| Custom quality scoring | Standardized QUALITY.md metrics |
| File-based memory only | Layered memory system |

### File Structure
```
v2.0                          v3.0
├── AGENTS.md                 ├── core/
├── SOUL.md                   │   ├── SOUL.md
├── IDENTITY.md               │   ├── HANDOFF.md
├── USER.md                   │   ├── QUALITY.md
├── MEMORY.md                 │   └── MEMORY.md
├── agents/                   ├── agents/
│   ├── switch/               │   ├── switch/AGENT.md
│   ├── quality/              │   ├── quality/AGENT.md
│   ├── content/              │   ├── content/AGENT.md
│   └── ...                   │   ├── grok/AGENT.md
├── tools/                    │   ├── product/AGENT.md
└── memory/                   │   ├── scaffolder/AGENT.md
                              │   └── ux/AGENT.md
                              ├── protocols/
                              │   ├── SESSION-STARTUP.md
                              │   └── SPAWN.md
                              ├── memory/
                              │   ├── USER.md
                              │   ├── STRATEGIC.md
                              │   └── SESSION-CONTEXT.md
                              └── docs/
                                  └── MIGRATION.md
```

### Key Improvements

1. **Structured Handoffs**
   - v2.0: "Spawn @quality to audit this"
   - v3.0: YAML-structured handoff with context, artifacts, acceptance criteria

2. **Explicit Agent Definitions**
   - v2.0: Roles in AGENTS.md table
   - v3.0: Individual AGENT.md files with responsibilities, models, protocols

3. **Standardized Quality**
   - v2.0: Custom Quality Equation only
   - v3.0: Quality Equation + DeepEval-style metrics + audit templates

4. **Layered Memory**
   - v2.0: MEMORY.md + daily logs
   - v3.0: Working + Short-term + Long-term + Vector memory layers

5. **Session Protocols**
   - v2.0: Startup sequence in AGENTS.md
   - v3.0: Dedicated SESSION-STARTUP.md + SPAWN.md protocols

## Migration Steps

### Step 1: Backup v2.0
```bash
# Already done via git history
# v2.0 files remain in place
```

### Step 2: Deploy v3.0
```bash
# v3/ directory created
# All files written
```

### Step 3: Update Agent References
- Change agent file paths from root to v3/agents/
- Update memory references to v3/memory/
- Use new protocol files

### Step 4: Test
- Spawn each agent with new structure
- Verify handoff protocol works
- Check quality scoring

### Step 5: Switch Over
- Update active system reference
- Begin using v3.0 exclusively
- Archive v2.0

## Backward Compatibility

### What Still Works
- Agent spawn mechanism (unchanged)
- Model routing (unchanged)
- Tool usage (unchanged)
- Git history (preserved)

### What Changed
- File paths (now in v3/)
- Startup sequence (now protocol-based)
- Handoff format (now structured)
- Quality audit (now standardized)

## Rollback Plan

If v3.0 has issues:
1. Continue using v2.0 files (still in place)
2. Fix v3.0 issues
3. Retry migration

---

*Migration is complete when v3.0 is the active system.*
