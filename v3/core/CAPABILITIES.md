# CAPABILITIES.md — Agent Tool Registry

**Version:** 3.0
**Purpose:** Define available tools per agent
**Inspired by:** CrewAI tool system, OpenAI function calling

---

## Tool Architecture

```
┌─────────────────────────────────────────┐
│           TOOL REGISTRY                 │
├─────────────────────────────────────────┤
│  Global Tools (All Agents)              │
│  Agent-Specific Tools                   │
│  Conditional Tools (Context-dependent)  │
└─────────────────────────────────────────┘
```

## Global Tools

Available to all agents:

| Tool | Description | Example |
|------|-------------|---------|
| `read` | Read file contents | `read(path)` |
| `write` | Write file contents | `write(path, content)` |
| `edit` | Edit file in place | `edit(path, old, new)` |
| `exec` | Execute shell command | `exec(command)` |
| `web_search` | Search the web | `web_search(query)` |
| `web_fetch` | Fetch URL content | `web_fetch(url)` |
| `memory_store` | Store memory | `memory_store(text, category)` |
| `memory_recall` | Recall memory | `memory_recall(query)` |
| `sessions_spawn` | Spawn sub-agent | `sessions_spawn(agentId, task)` |
| `sessions_send` | Send message | `sessions_send(sessionKey, message)` |

## Agent-Specific Tools

### @switch (Router)
| Tool | Description | When to Use |
|------|-------------|-------------|
| `classify_intent` | Classify user request | Route to correct agent |
| `select_model` | Choose model for task | Optimize cost/quality |
| `delegate` | Spawn agent with context | Task distribution |
| `aggregate` | Combine agent outputs | Final delivery |

### @quality (Auditor)
| Tool | Description | When to Use |
|------|-------------|-------------|
| `score_output` | Score agent output | Quality audit |
| `check_completeness` | Verify all requirements met | Pre-delivery check |
| `check_accuracy` | Verify factual claims | Content audit |
| `generate_report` | Create audit report | Documentation |

### @content (Creator)
| Tool | Description | When to Use |
|------|-------------|-------------|
| `generate_draft` | Create content draft | Initial creation |
| `refine_tone` | Adjust writing style | Voice matching |
| `format_markdown` | Format for readability | Final polish |
| `check_grammar` | Grammar/spelling check | Quality assurance |

### @grok (Reasoning)
| Tool | Description | When to Use |
|------|-------------|-------------|
| `deep_analysis` | Multi-factor analysis | Complex problems |
| `synthesize` | Combine information | Research summary |
| `hypothesize` | Generate hypotheses | Exploration |
| `evaluate_risks` | Risk assessment | Decision support |

### @product (Analyst)
| Tool | Description | When to Use |
|------|-------------|-------------|
| `gather_requirements` | Extract user needs | Project start |
| `prioritize` | Score and rank features | Roadmap planning |
| `estimate_effort` | Estimate task size | Sprint planning |
| `define_metrics` | Set success metrics | Goal setting |

### @scaffolder (Builder)
| Tool | Description | When to Use |
|------|-------------|-------------|
| `scaffold_project` | Create project structure | New project |
| `generate_boilerplate` | Write boilerplate code | Quick start |
| `setup_tooling` | Configure dev tools | Environment setup |
| `run_tests` | Execute test suite | Verification |

### @ux (Designer)
| Tool | Description | When to Use |
|------|-------------|-------------|
| `create_wireframe` | Design layout | Visual planning |
| `define_flow` | Map user journey | Experience design |
| `specify_interactions` | Define behaviors | Interaction design |
| `check_accessibility` | WCAG compliance | Accessibility audit |

## Conditional Tools

Available based on context:

| Condition | Tool | Description |
|-----------|------|-------------|
| `has_file(path)` | `analyze_code` | Code analysis |
| `has_url(url)` | `screenshot` | Visual capture |
| `has_image(path)` | `analyze_image` | Image analysis |
| `is_deployable` | `deploy` | Deployment |
| `has_tests` | `coverage_report` | Test coverage |

## Tool Selection

### How Agents Choose Tools
1. **Task Analysis:** What needs to be done?
2. **Capability Check:** What tools are available?
3. **Selection:** Choose best tool for task
4. **Execution:** Use tool correctly
5. **Verification:** Confirm result

### Tool Usage Rules
- Use simplest tool that works
- Combine tools for complex tasks
- Verify tool output before proceeding
- Log tool usage for audit

## Tool Registry Format

```yaml
tool:
  name: "tool_name"
  description: "What this tool does"
  agents: ["agent1", "agent2"]  # Which agents can use
  parameters:
    - name: "param1"
      type: "string"
      required: true
      description: "What this parameter does"
  returns:
    type: "string"
    description: "What the tool returns"
  examples:
    - input: "example input"
      output: "example output"
```

## Adding New Tools

1. Define tool in `CAPABILITIES.md`
2. Add to agent definitions
3. Create test cases
4. Update documentation

## Tool Audit

### Weekly
- Review tool usage patterns
- Identify unused tools
- Check for abuse

### Monthly
- Evaluate tool effectiveness
- Consider new tools
- Remove obsolete tools

---

*The right tool for the right job.*
