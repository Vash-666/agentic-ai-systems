# Agent Architecture Improvements - Product Backlog

**Created:** 2026-05-04  
**Quality Score Target:** 9.0+/10 (Current: 8.79/10)  
**Owner:** @switch  
**Status:** Draft - Ready for Review

---

## Executive Summary

This backlog captures three strategic improvements to the agent architecture identified by @switch. These enhancements aim to improve agent collaboration efficiency, memory accessibility, and inter-agent communication patterns.

**Recommended Execution Order:**
1. Structured Handoff Protocol (Quick win - Low effort, immediate impact)
2. Shared Vector Memory for Agents (Foundation for future capabilities)
3. Agent-to-Agent Messaging (Long-term architectural evolution)

---

## Backlog Items

### ARCH-001 : Structured Handoff Protocol

| Field | Details |
|-------|---------|
| **ID** | ARCH-001 |
| **Title** | Structured Handoff Protocol |
| **Impact** | Medium |
| **Effort** | Low |

#### User Story / Problem Statement

**As a** system architect,  
**I want** agents to return structured JSON results instead of free-form text,  
**So that** downstream agents can reliably parse and act on outputs without ambiguity or parsing errors.

**Current Pain Point:**
- Agents currently return free-form text responses
- Downstream processing requires brittle text parsing
- No standardized schema for common result types (success, error, partial, needs-clarification)
- Inconsistent handling of metadata (timestamps, confidence scores, source references)

#### Acceptance Criteria

- [ ] Define JSON schema for standard agent result types:
  - `success` - Operation completed successfully
  - `error` - Operation failed with structured error info
  - `partial` - Partial success with completion percentage
  - `needs_clarification` - Requires additional input
  - `delegated` - Task passed to another agent
- [ ] Schema includes standard fields:
  - `status` (enum)
  - `result` (payload object)
  - `metadata` (timestamp, agent_id, version)
  - `confidence` (0.0-1.0)
  - `next_actions` (suggested follow-ups)
- [ ] Backward compatibility layer for agents not yet migrated
- [ ] Validation middleware that rejects/flags non-compliant responses
- [ ] Documentation with examples for each result type
- [ ] Migration guide for existing agents

#### Priority

**Should Have** (MoSCoW)

Rationale: Significant quality-of-life improvement with low implementation cost. Enables future features but not blocking current operations.

#### Estimated Effort

| Component | Story Points | Notes |
|-----------|--------------|-------|
| Schema design | 2 | RFC + review cycle |
| Core implementation | 3 | Schema validation, base classes |
| Backward compatibility | 2 | Adapter pattern for legacy agents |
| Documentation | 1 | Schema docs + migration guide |
| Testing | 2 | Unit + integration tests |
| **Total** | **10 SP** | ~1 developer-week |

#### Dependencies

- None (self-contained)
- **Blocks:** ARCH-003 (Agent-to-Agent Messaging benefits from structured payloads)

#### Success Metrics

| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| Agent response parse errors | Unknown | <1% | Error logs over 30 days |
| Time to integrate new agent | Unknown | -50% | Developer survey |
| Schema adoption rate | 0% | 100% of new agents | Code review audit |
| Developer satisfaction | N/A | >4/5 | Post-implementation survey |

---

### ARCH-002 : Shared Vector Memory for Agents

| Field | Details |
|-------|---------|
| **ID** | ARCH-002 |
| **Title** | Shared Vector Memory for Agents |
| **Impact** | High |
| **Effort** | Medium |

#### User Story / Problem Statement

**As an** agent developer,  
**I want** agents to have access to a shared vector-based memory retriever,  
**So that** agents can perform semantic searches across the entire memory corpus and retrieve contextually relevant information without manual query crafting.

**Current Pain Point:**
- Agents rely on keyword-based or manual memory lookups
- No semantic understanding of memory content
- Each agent maintains isolated memory access patterns
- Inefficient retrieval of relevant historical context
- Duplicated effort in memory search implementations

#### Acceptance Criteria

- [ ] Vector store integration (existing or new):
  - Support for embeddings generation
  - Efficient similarity search
  - Configurable top-k retrieval
- [ ] Memory indexing pipeline:
  - Automatic embedding of new memory entries
  - Batch processing for historical memory
  - Update/delete handling
- [ ] Agent-facing API:
  - `memory.query(text, limit=5, min_score=0.7)` - Semantic search
  - `memory.remember(text, metadata={})` - Store with auto-embedding
  - `memory.related_to(memory_id, limit=5)` - Find similar memories
- [ ] Access control layer:
  - Agent-scoped memory namespaces
  - Permission levels (read-only, read-write, admin)
  - Audit logging for sensitive queries
- [ ] Performance requirements:
  - Query latency <100ms (p95)
  - Support for 100k+ memory entries
  - Index updates within 5 seconds of new memory
- [ ] Observability:
  - Query metrics (latency, hit rate)
  - Embedding quality monitoring
  - Memory coverage dashboards

#### Priority

**Must Have** (MoSCoW)

Rationale: Foundation capability that unlocks significant agent intelligence improvements. High impact justifies medium effort investment.

#### Estimated Effort

| Component | Story Points | Notes |
|-----------|--------------|-------|
| Vector store selection/setup | 3 | Evaluate vs. implement |
| Embedding pipeline | 5 | Model selection, batch processing |
| Agent API design | 3 | Interface + permissions |
| Indexing infrastructure | 5 | Backfill, incremental updates |
| Access control | 3 | AuthZ layer |
| Observability | 2 | Metrics, dashboards |
| Documentation | 2 | API docs, best practices |
| Testing | 3 | Load tests, accuracy validation |
| **Total** | **26 SP** | ~2.5 developer-weeks |

#### Dependencies

- Requires: Vector store infrastructure (decision: use existing vs. new)
- Requires: Embedding model selection and integration
- **Blocks:** None directly, but enhances value of ARCH-003

#### Success Metrics

| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| Memory query relevance score | N/A (keyword) | >0.8 semantic similarity | Human evaluation sample |
| Context retrieval accuracy | Unknown | >85% | Benchmark dataset |
| Query latency (p95) | N/A | <100ms | APM metrics |
| Agent adoption rate | 0% | >75% | Usage analytics |
| Memory coverage | 0% | 100% of new memories | Pipeline monitoring |
| Developer NPS | N/A | >50 | Quarterly survey |

---

### ARCH-003 : Agent-to-Agent Messaging

| Field | Details |
|-------|---------|
| **ID** | ARCH-003 |
| **Title** | Agent-to-Agent Messaging |
| **Impact** | High |
| **Effort** | High |

#### User Story / Problem Statement

**As a** system architect,  
**I want** agents to communicate directly with each other without routing through @switch,  
**So that** we reduce bottlenecks, enable more complex multi-agent workflows, and improve system scalability.

**Current Pain Point:**
- All agent communication routes through @switch (centralized bottleneck)
- Limits scalability as agent count grows
- @switch becomes single point of failure
- No support for agent-initiated collaboration
- Complex workflows require excessive @switch coordination

#### Acceptance Criteria

- [ ] Messaging infrastructure:
  - Message bus or direct connection support
  - At-least-once delivery guarantee
  - Message persistence for offline agents
  - TTL and dead-letter handling
- [ ] Protocol specification:
  - Message envelope format (sender, recipient, type, payload, correlation_id)
  - Message types: `request`, `response`, `event`, `broadcast`
  - Schema validation (leverages ARCH-001)
  - Compression for large payloads
- [ ] Agent capabilities:
  - Discovery: `agent.discover(capability_filter)`
  - Direct messaging: `agent.send(target_agent_id, message)`
  - Pub/sub: `agent.subscribe(topic)`, `agent.publish(topic, event)`
  - Request/response pattern with timeouts
- [ ] Security model:
  - Mutual authentication between agents
  - Message encryption in transit
  - Capability-based access control
  - Audit logging for compliance
- [ ] @switch integration:
  - Optional oversight mode (monitor but don't route)
  - Circuit breaker for agent failures
  - System-wide broadcast capability
  - Gradual migration path from centralized routing
- [ ] Observability:
  - Message flow tracing
  - Latency histograms by agent pair
  - Error rate monitoring
  - Topology visualization

#### Priority

**Could Have** (MoSCoW)

Rationale: High impact but also high effort. Current centralized routing works for present scale. Defer until ARCH-001 and ARCH-002 provide foundation, then evaluate urgency based on scaling needs.

#### Estimated Effort

| Component | Story Points | Notes |
|-----------|--------------|-------|
| Messaging infrastructure | 8 | Bus selection/setup or custom |
| Protocol design | 5 | RFC + review cycle |
| Agent SDK updates | 8 | Discovery, send, subscribe APIs |
| Security layer | 8 | AuthN, AuthZ, encryption |
| @switch integration | 5 | Oversight mode, circuit breaker |
| Observability | 5 | Tracing, metrics, topology |
| Documentation | 3 | Protocol spec, migration guide |
| Testing | 8 | Chaos testing, load testing |
| **Total** | **50 SP** | ~5 developer-weeks |

#### Dependencies

- **Requires:** ARCH-001 (Structured Handoff Protocol) - for message payload standardization
- **Requires:** ARCH-002 (Shared Vector Memory) - for agent discovery and context sharing
- Requires: Security infrastructure review (encryption, auth)
- Requires: Scalability analysis to justify investment

#### Success Metrics

| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| @switch routing load | 100% | <30% | Message routing telemetry |
| Agent-to-agent latency | Via @switch | -50% | APM comparison |
| System throughput | Baseline | +200% | Load test results |
| Agent collaboration complexity | Limited | Complex workflows enabled | Use case validation |
| Developer adoption | 0% | >60% direct messaging | Usage analytics |
| Message delivery reliability | N/A | 99.9% | Delivery confirmation logs |

---

## Roadmap & Recommendations

### Phase 1: Foundation (Weeks 1-2)
**Focus:** ARCH-001 - Structured Handoff Protocol

**Why first:**
- Lowest effort, fastest time-to-value
- Unblocks ARCH-003 (structured payloads needed)
- Immediate quality improvement for all agent interactions
- Establishes schema discipline for future work

**Deliverables:**
- RFC approved and schema defined
- Core implementation with backward compatibility
- Documentation and migration guide
- 100% adoption for new agents

### Phase 2: Intelligence (Weeks 3-5)
**Focus:** ARCH-002 - Shared Vector Memory

**Why second:**
- High impact justifies medium effort
- Foundation for intelligent agent behavior
- Can leverage structured outputs from Phase 1
- Enables semantic context for Phase 3

**Deliverables:**
- Vector store operational
- Memory indexing pipeline
- Agent API with access control
- Performance benchmarks met
- Developer documentation

### Phase 3: Scale (Weeks 6-10)
**Focus:** ARCH-003 - Agent-to-Agent Messaging

**Why third:**
- Highest effort, requires foundation from Phases 1-2
- Only needed when scaling demands justify investment
- Benefits from structured payloads and shared memory context
- Can be deferred if current architecture meets needs

**Deliverables:**
- Messaging infrastructure deployed
- Protocol specification finalized
- Security model implemented
- @switch oversight mode operational
- Migration of high-traffic agent pairs

### Contingency: Phase 3 Evaluation Gate

Before committing to Phase 3, evaluate:
1. Is @switch currently a bottleneck? (Measure routing latency/queue depth)
2. Do we have >10 agents with frequent collaboration needs?
3. Are there specific workflows blocked by centralized routing?
4. Can we achieve goals with horizontal scaling of @switch instead?

If answers are "no," defer Phase 3 and invest in horizontal scaling or other priorities.

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Schema changes break existing agents | Medium | High | Backward compatibility layer, deprecation cycle |
| Vector search quality poor | Low | High | Evaluate embedding models, human feedback loop |
| Agent-to-agent security vulnerabilities | Medium | High | Security review, penetration testing, audit logging |
| Performance doesn't meet targets | Low | Medium | Load testing early, caching strategies |
| Developer adoption slow | Medium | Medium | Clear documentation, migration tooling, champions program |

---

## Appendix

### A. MoSCoW Definitions

- **Must Have:** Critical to success. Non-negotiable.
- **Should Have:** Important but not critical. Can work around if missing.
- **Could Have:** Desirable but can be deferred. Nice-to-have.
- **Won't Have (this time):** Acknowledged but explicitly excluded from scope.

### B. Story Point Reference

| Points | Approximate Duration |
|--------|---------------------|
| 1 | Half day |
| 2 | 1 day |
| 3 | 1-2 days |
| 5 | 3-4 days |
| 8 | 1 week |

### C. Change Log

| Date | Version | Changes |
|------|---------|---------|
| 2026-05-04 | 1.0 | Initial backlog creation |

---

*This backlog is a living document. Update priorities and estimates as work progresses and new information emerges.*
