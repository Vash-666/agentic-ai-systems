# STRATEGIC.md — Long-Term Memory

**Version:** 3.0
**Purpose:** Curated strategic knowledge
**Update Frequency:** Weekly

---

## System Evolution

### v1.0 → v2.0 (April 2026)
- Basic multi-agent setup
- Model switching experiments
- Quality Equation defined

### v2.0 → v3.0 (September 2026)
- Complete system reset
- Incorporated best practices from:
  - CrewAI (role-based agents)
  - Mem0 (structured memory)
  - dabit3/agent-handoff (context transfer)
  - DeepEval (quality metrics)
- Standardized protocols
- Clean architecture

## Core Principles

### Quality Equation
```
Quality = (Prompt_Files × 0.65) + (Memory × 0.20) + (Model × 0.10) + (Tools × 0.05)
```
Target: ≥9.0/10

### Agent Architecture
- **Core:** @switch, @quality, @content (always active)
- **Specialists:** @grok, @product, @scaffolder, @ux (on demand)

### Key Protocols
1. Session startup with full context
2. Structured handoffs between agents
3. Quality audits before delivery
4. Memory extraction at session end

## Lessons Learned

### What Works
- Three-tier model switching (SESSION-CONTEXT + memory flush + smart routing)
- Manual WordPress updates > browser automation
- Telegram > Signal for reliability
- Batch operations > individual calls

### What Doesn't
- Over-automation for simple tasks
- Signal integration (unstable)
- Unstructured agent handoffs
- Context loss during model switches

## Current Focus

### Immediate
- v3.0 system stabilization
- GitHub showcase content
- Agentic AI Mastery Lab videos

### Short-Term
- Federal systems + Web3 bridge
- Practical AI integration workflows
- Content creation pipeline

### Long-Term
- Build impactful projects at legacy/emerging tech intersection
- Create value through technology with integrity
- Document and teach agentic systems

## Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Quality Score | 8.79/10 | ≥9.0/10 |
| Context Preservation | 100% | 100% |
| Cost Savings | 88% | ≥85% |
| Active Agents | 7 | 7 |

---

*Strategy is a commodity, execution is an art.*
