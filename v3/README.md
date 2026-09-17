# Agentic System v3.0

**Version:** 3.0
**Date:** 2026-09-16
**Status:** Complete, Ready for Activation

---

## What This Is

A multi-agent system built on OpenClaw, incorporating best practices from:
- **CrewAI** — Role-based agent definitions
- **Mem0** — Structured memory with vector search
- **dabit3/agent-handoff** — Context transfer protocols
- **DeepEval** — Standardized quality metrics

## Architecture

```
v3/
├── core/                    # Universal consciousness
│   ├── SOUL.md             # Shared identity
│   ├── HANDOFF.md          # Context transfer protocol
│   ├── QUALITY.md          # Quality equation & metrics
│   └── MEMORY.md           # Memory system architecture
│
├── agents/                  # Agent definitions (7 agents)
│   ├── switch/             # Router & coordinator
│   ├── quality/            # Auditor & scorer
│   ├── content/            # Writer & creator
│   ├── grok/               # Advanced reasoning
│   ├── product/            # Requirements analyst
│   ├── scaffolder/         # Code builder
│   └── ux/                 # Experience designer
│
├── protocols/               # Operational procedures
│   ├── SESSION-STARTUP.md  # Session initialization
│   └── SPAWN.md            # Agent spawning rules
│
├── memory/                  # Persistent knowledge
│   ├── USER.md             # Human context
│   ├── STRATEGIC.md        # Long-term memory
│   └── SESSION-CONTEXT.md  # Session bridge
│
└── docs/
    └── MIGRATION.md        # v2.0 → v3.0 guide
```

## Quick Start

### For @switch (Router)
1. Read `core/SOUL.md`
2. Read `core/HANDOFF.md`
3. Read `agents/switch/AGENT.md`
4. Read `memory/USER.md`
5. Read `memory/SESSION-CONTEXT.md`

### For Specialists
1. Read `core/SOUL.md`
2. Read `core/HANDOFF.md`
3. Read `agents/[YOUR_ROLE]/AGENT.md`
4. Receive handoff from parent agent

## Quality Target

**≥9.0/10** using the Quality Equation:
```
Quality = (Prompt_Files × 0.65) + (Memory × 0.20) + (Model × 0.10) + (Tools × 0.05)
```

## Agents

| Agent | Role | Model | Status |
|-------|------|-------|--------|
| @switch | Router | kimi-k2.5 | Always Active |
| @quality | Auditor | claude-sonnet-4-5 | On Demand |
| @content | Creator | gemini-2.5-flash | On Demand |
| @grok | Reasoning | grok-4.20-reasoning | On Demand |
| @product | Analyst | deepseek-chat | On Demand |
| @scaffolder | Builder | kimi-k2.5 | On Demand |
| @ux | Designer | claude-sonnet-4-5 | On Demand |

## Key Protocols

1. **Session Startup** — Load context in order (SOUL → HANDOFF → Agent → User → Session)
2. **Agent Spawn** — Include task, context, artifacts, acceptance criteria, return path
3. **Handoff** — Structured YAML with full context transfer
4. **Quality Audit** — Score before delivery, reject if <7.0

## What's New in v3.0

- ✅ Structured handoff protocol (prevents context loss)
- ✅ Explicit agent definitions with roles/goals
- ✅ Standardized quality metrics (DeepEval-inspired)
- ✅ Layered memory system (working → short-term → long-term → vector)
- ✅ Session startup protocol (ensures continuity)
- ✅ Spawn protocol (standardized delegation)

## Migration

See `docs/MIGRATION.md` for v2.0 → v3.0 transition guide.

---

*Built with best practices from the open-source agent community.*
