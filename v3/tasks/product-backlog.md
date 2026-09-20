# Product Backlog — Agentic AI System v3.1.1+

**Owner:** @product  
**Last Updated:** 2026-09-20  
**Source:** @grok System Validation Report

---

## Legend

| Priority | Meaning | SLA |
|----------|---------|-----|
| **P0 — Critical** | System broken / data loss risk | Fix today |
| **P1 — High** | Major feature gap / user blocker | Fix this week |
| **P2 — Medium** | Enhancement / nice to have | Fix this month |
| **P3 — Long-term** | Strategic / architectural | Next quarter |

---

## P0 — Critical (Fix Today)

| ID | Task | Description | Effort | Status | Dependencies | Owner |
|----|------|-------------|--------|--------|--------------|-------|
| **P0-001** | Fix stale task in state.json | `task-ho-1789739006` shows "in_progress" since Sept 18. Mark as completed or cancelled. | 10 min | ⏳ backlog | None | @scaffolder |
| **P0-002** | Sync v3.1.1 work to state.json | Validator creation, AGENT-ROSTER.md, RELEASE fix not tracked in state. | 15 min | ⏳ backlog | P0-001 | @switch |
| **P0-003** | Fix scaffolder orphaned status | Agent shows "working" but no active task. Set to "idle". | 5 min | ⏳ backlog | P0-001 | @switch |

---

## P1 — High (Fix This Week)

| ID | Task | Description | Effort | Status | Dependencies | Owner |
|----|------|-------------|--------|--------|--------------|-------|
| **P1-001** | Create SQLite task queue | Replace direct spawning with queued tasks. Table: `tasks(id, agent, description, status, priority, created_at, started_at, completed_at)`. | 2 hrs | ⏳ backlog | P0-002 | @scaffolder |
| **P1-002** | Fix quality-score.sh array bugs | Line 115: `scores: bad array subscript`. Fix bash array handling. | 30 min | ⏳ backlog | None | @quality |
| **P1-003** | Add automated backup for state.db | Cron job to copy state.db to `backups/state-YYYY-MM-DD-HHMMSS.db`. Keep last 30. | 1 hr | ⏳ backlog | None | @scaffolder |
| **P1-004** | Add alerting to health monitor | Send Telegram/Slack alert when health check fails. Configurable webhook. | 1 hr | ⏳ backlog | None | @scaffolder |
| **P1-005** | Add circuit breaker for model routing | If Ollama fails 3x, switch to cloud API. If cloud fails, queue tasks. | 2 hrs | ⏳ backlog | P1-001 | @switch |

---

## P2 — Medium (Fix This Month)

| ID | Task | Description | Effort | Status | Dependencies | Owner |
|----|------|-------------|--------|--------|--------------|-------|
| **P2-001** | Build web dashboard (read-only) | Simple HTML page showing: agents status, active tasks, health metrics, quality score. Serve via Python HTTP. | 4 hrs | ⏳ backlog | P1-001 | @ux |
| **P2-002** | Add Prometheus metrics endpoint | Expose `/metrics` with: agent_count, task_count, quality_score, health_status. | 2 hrs | ⏳ backlog | None | @scaffolder |
| **P2-003** | Add cost tracking per agent | Log API calls and estimate cost. Table: `costs(agent, model, tokens, cost_usd, timestamp)`. | 2 hrs | ⏳ backlog | P1-001 | @product |
| **P2-004** | Create audit log | Track all agent actions. Table: `audit(id, agent, action, target, timestamp, result)`. | 1 hr | ⏳ backlog | P1-001 | @quality |
| **P2-005** | Add natural language interface | Allow "@switch do X" instead of CLI commands. Parse intent, route to agent. | 4 hrs | ⏳ backlog | None | @switch |

---

## P3 — Long-term (Next Quarter)

| ID | Task | Description | Effort | Status | Dependencies | Owner |
|----|------|-------------|--------|--------|--------------|-------|
| **P3-001** | Plugin system for agents | `agents/` as plugins. New agent = new directory + manifest.json. Auto-discover. | 8 hrs | ⏳ backlog | P2-005 | @product |
| **P3-002** | Rewrite core in Python | Replace bash scripts with Python. Better error handling, testing, maintainability. | 16 hrs | ⏳ backlog | P3-001 | @scaffolder |
| **P3-003** | Multi-user support | User isolation, permissions, shared workspaces. | 12 hrs | ⏳ backlog | P3-002 | @product |
| **P3-004** | Agent marketplace | Share/download agents. GitHub integration. Ratings. | 20 hrs | ⏳ backlog | P3-003 | @content |
| **P3-005** | Mobile app / PWA | Access agents from phone. Push notifications. | 24 hrs | ⏳ backlog | P2-001 | @ux |

---

## Completed (Recently)

| ID | Task | Completed | By |
|----|------|-----------|-----|
| ~~v3.1~~ | Multi-Agent Platform release | 2026-09-20 | @switch |
| ~~v3.1.1~~ | Documentation drift fix + validator | 2026-09-20 | @scaffolder |
| ~~API-001~~ | Update xAI API key | 2026-09-20 | @switch |

---

## Metrics

| Metric | Value |
|--------|-------|
| Total backlog items | 17 |
| P0 (Critical) | 3 |
| P1 (High) | 5 |
| P2 (Medium) | 5 |
| P3 (Long-term) | 5 |
| Completed (recent) | 3 |

---

## Next Sprint Proposal

**Sprint Goal:** Stabilize system (fix P0 + P1)

**Sprint Backlog:**
1. P0-001: Fix stale task
2. P0-002: Sync v3.1.1 work
3. P0-003: Fix scaffolder status
4. P1-002: Fix quality-score.sh bugs
5. P1-003: Add state.db backup
6. P1-004: Add alerting

**Estimated Velocity:** 6.5 hours

---

*Backlog maintained by @product*  
*Last validated by @grok: 2026-09-20*
