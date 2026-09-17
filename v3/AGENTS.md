# AGENTS.md — System Architecture v3.0

**Version:** 3.0
**Date:** 2026-09-16
**Status:** Active

---

## System Overview

Multi-agent system built on OpenClaw with structured protocols, quality enforcement, and best practices from CrewAI, Mem0, DeepEval, and agent-handoff protocols.

```
┌─────────────────────────────────────────┐
│              @switch                    │
│           (Orchestrator)                │
└───────────────┬─────────────────────────┘
                │
    ┌───────────┼───────────┐
    │           │           │
    ▼           ▼           ▼
┌───────┐  ┌───────┐  ┌───────┐
│@quality│  │@content│  │@grok  │
│(Audit) │  │(Create)│  │(Reason)│
└───┬───┘  └───┬───┘  └───┬───┘
    │           │           │
    └───────────┼───────────┘
                │
    ┌───────────┼───────────┐
    │           │           │
    ▼           ▼           ▼
┌───────┐  ┌───────┐  ┌───────┐
│@product│  │@scaffolder│  │@ux  │
│(Analyze)│  │(Build)   │  │(Design)│
└───────┘  └───────┘  └───────┘
```

## Agents

### Core (Always Active)

| Agent | Role | Model | Status |
|-------|------|-------|--------|
| @switch | Router & Coordinator | kimi-k2.5 | Active |
| @quality | Auditor & Scorer | claude-sonnet-4-5 | On Demand |
| @content | Writer & Creator | gemini-2.5-flash | On Demand |

### Specialists (On Demand)

| Agent | Role | Model | Status |
|-------|------|-------|--------|
| @grok | Advanced Reasoning | grok-4.20-reasoning | On Demand |
| @product | Requirements Analyst | deepseek-chat | On Demand |
| @scaffolder | Code Builder | kimi-k2.5 | On Demand |
| @ux | Experience Designer | claude-sonnet-4-5 | On Demand |

## File Structure

```
v3/
├── core/                    # Universal consciousness
│   ├── SOUL.md             # Shared identity
│   ├── HANDOFF.md          # Context transfer protocol
│   ├── QUALITY.md          # Quality equation & metrics
│   ├── MEMORY.md           # Memory system architecture
│   ├── STATE.md            # Shared state machine
│   ├── EVALUATION.md       # Test harness
│   └── CAPABILITIES.md     # Tool registry
│
├── agents/                  # Agent definitions
│   ├── switch/AGENT.md
│   ├── quality/AGENT.md
│   ├── content/AGENT.md
│   ├── grok/AGENT.md
│   ├── product/AGENT.md
│   ├── scaffolder/AGENT.md
│   └── ux/AGENT.md
│
├── protocols/               # Operational procedures
│   ├── SESSION-STARTUP.md  # Session initialization
│   ├── SPAWN.md            # Agent spawning
│   └── RECOVERY.md         # Error handling
│
├── memory/                  # Persistent knowledge
│   ├── USER.md             # Human context
│   ├── STRATEGIC.md        # Long-term memory
│   └── SESSION-CONTEXT.md  # Session bridge
│
├── examples/                # Documentation
│   └── WORKFLOW.md         # End-to-end example
│
└── docs/
    └── MIGRATION.md        # v2.0 → v3.0 guide
```

## Quality Target

**≥9.0/10** using:
```
Quality = (Prompt_Files × 0.65) + (Memory × 0.20) + (Model × 0.10) + (Tools × 0.05)
```

## Key Protocols

1. **Session Startup** — Load context in order
2. **Agent Spawn** — Include full context
3. **Handoff** — Structured transfer
4. **Quality Audit** — Score before delivery
5. **Error Recovery** — Graceful degradation

## Quick Start

### New Session
```bash
# 1. Read core files
read v3/core/SOUL.md
read v3/core/HANDOFF.md

# 2. Read agent definition
read v3/agents/switch/AGENT.md

# 3. Read user context
read v3/memory/USER.md

# 4. Read session context
read v3/memory/SESSION-CONTEXT.md
```

### Spawn Agent
```yaml
handoff:
  from: "@switch"
  to: "@agent_name"
  context:
    task: "Specific task"
    goal: "Success criteria"
  artifacts:
    files: []
  acceptance_criteria:
    - "Checkable condition"
  return_path:
    to: "@switch"
    format: "expected_format"
```

## Changes from v2.0

- ✅ Structured handoff protocol
- ✅ Explicit agent definitions
- ✅ Standardized quality metrics
- ✅ Layered memory system
- ✅ State machine
- ✅ Evaluation harness
- ✅ Tool registry
- ✅ Error recovery
- ✅ Example workflows

---

*v3.0 — Built with best practices from the agent community.*
