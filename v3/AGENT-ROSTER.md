# Agent Roster — Canonical Source of Truth

**Version:** 3.1.1  
**Last Verified:** 2026-09-20  
**Validator:** `scripts/validate-system.sh`

---

## Active Agents

| Agent | Role | Model | Fallback | Status |
|-------|------|-------|----------|--------|
| **@switch** | Orchestrator & Router | moonshot/kimi-k2.5 | ollama/llama3.2 | ✅ Active |
| **@quality** | Quality Auditor | anthropic/claude-sonnet-4-5 | ollama/phi4 | ✅ Active |
| **@content** | Content Creator | google/gemini-2.5-flash | ollama/llama3.2 | ✅ Active |
| **@grok** | Advanced Reasoning | xai/grok-4.20-reasoning | ollama/phi4 | ✅ Active |
| **@product** | Product Analyst | deepseek/deepseek-chat | ollama/llama3.2 | ✅ Active |
| **@scaffolder** | Project Builder | moonshot/kimi-k2.5 | ollama/llama3.2 | ✅ Active |
| **@ux** | Experience Designer | anthropic/claude-sonnet-4-5 | ollama/mistral | ✅ Active |

## Verification

Run to verify this roster matches disk:
```bash
./scripts/validate-system.sh
```

## Adding New Agents

1. Create `agents/<name>/AGENT.md`
2. Update this roster
3. Update `state/current.json`
4. Run validator
5. Commit only after validation passes

## Changelog

- **v3.1.1** (2026-09-20): Added validator, fixed documentation drift
- **v3.1** (2026-09-20): Infrastructure features (checkpointer, reducers, etc.)
- **v3.0** (2026-09-16): Initial 7-agent system
