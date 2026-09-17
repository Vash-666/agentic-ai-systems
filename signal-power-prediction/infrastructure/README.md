# Level-Game Infrastructure

**Signal Power Prediction System** - CODE RED Activation

Complete infrastructure scaffolding for gamified development sprints with agent coordination, XP progression, and automated level unlocking.

## 🎮 Quick Start

```bash
# Navigate to sprint scripts
cd scripts/sprint

# Show all available commands
make help

# Setup infrastructure
make setup

# Initialize database (requires PostgreSQL)
make db-init

# OR use Docker
make dev-up
```

## 📁 Infrastructure Components

### Database Schema (`sprint-schema.sql`)
- **Sprints** - Track level-based sprints with XP rewards
- **Levels** - 10 progression levels with unlock conditions
- **Agents** - Agent registry with skills and specializations
- **Tasks** - Individual sprint tasks with assignments
- **XP History** - Complete audit trail of XP awards
- **Events** - Sprint lifecycle event log

### Agent Coordination (`agent-coordinator.yaml`)
- Agent registry with roles and capabilities
- Task assignment rules and load balancing
- Escalation policies
- Sprint phase definitions
- Notification templates
- XP progression formulas

### CI/CD Pipeline (`ci-cd-pipeline.yml`)
- GitHub Actions workflow
- Sprint discovery and validation
- Task completion tracking
- Automated level progression
- Artifact generation
- Deployment gates (Level 5+)

### Docker Compose (`docker-compose.yml`)
- PostgreSQL database
- Redis for caching/events
- API server
- Web dashboard
- Agent coordinator service
- Prometheus/Grafana monitoring
- Loki log aggregation

## 🚀 Sprint Commands

### Initialize a Sprint
```bash
make init LEVEL=1 NAME="Foundation Setup" AGENTS="@architect,@builder"
```

### Start a Sprint
```bash
make start                    # Start active sprint
make start DIR=<path>         # Start specific sprint
```

### Check Status
```bash
make status                   # Show current sprint status
make watch                    # Watch mode (auto-refresh)
make status --all             # Show all sprints
```

### Complete a Sprint
```bash
make complete                 # Complete active sprint
make complete RATING=5        # Complete with 5-star rating
```

## 🎯 Level Progression

### Unlock a Level
```bash
make level-up LEVEL=2
```

### View Level Status
```bash
make levels
```

### Level Overview

| Level | Name | Required XP | Perks |
|-------|------|-------------|-------|
| 1 | Initiate | 0 | Basic access |
| 2 | Apprentice | 100 | Task creation |
| 3 | Journeyman | 300 | Code review |
| 4 | Specialist | 600 | Architecture input |
| 5 | Expert | 1000 | Sprint leadership |
| 6 | Master | 1500 | Full leadership |
| 7 | Grandmaster | 2100 | Cross-team coordination |
| 8 | Legend | 2800 | Strategic planning |
| 9 | Mythic | 3600 | System ownership |
| 10 | Transcendent | 4500 | Legend status |

## 👥 Agent Commands

### Notify an Agent
```bash
make agent-notify AGENT=@builder MSG="Task assigned!"
```

### Assign a Task
```bash
make agent-assign AGENT=@builder TASK=./tasks/01-task.md
```

### Complete a Task
```bash
make agent-complete AGENT=@builder TASK=./tasks/01-task.md
```

### Award XP
```bash
make agent-xp AGENT=@builder XP=25 REASON="Excellent work!"
```

## 📊 Monitoring

### Start Dashboard
```bash
make dashboard
```

Access:
- Grafana: http://localhost:3001 (admin/admin)
- Prometheus: http://localhost:9090
- API: http://localhost:3000

### Sprint Status Display
```
╔═══════════════════════════════════════════════════════════╗
║  🎮 LEVEL 3 SPRINT                                        ║
║  API Development                                          ║
║  Status: 🟢 ACTIVE                                        ║
╚═══════════════════════════════════════════════════════════╝

📋 TASK SUMMARY
  Total:     7
  Pending:   2
  Active:    1
  Completed: 4
  Progress:  ████████████████░░░░ 57%

👥 AGENT STATUS
  @architect      2/2 tasks  [100%]
  @builder        2/3 tasks  [ 67%]
  @tester         0/2 tasks  [  0%]
```

## 🏗️ Directory Structure

```
signal-power-prediction/
├── infrastructure/
│   ├── sprint-schema.sql      # Database schema
│   ├── agent-coordinator.yaml # Agent coordination config
│   ├── ci-cd-pipeline.yml     # GitHub Actions workflow
│   ├── docker-compose.yml     # Docker services
│   └── README.md              # This file
├── scripts/sprint/
│   ├── init-sprint.sh         # Sprint initialization
│   ├── start-sprint.sh        # Sprint activation
│   ├── complete-sprint.sh     # Sprint completion
│   ├── sprint-status.sh       # Status monitor
│   ├── level-up.sh            # Level progression
│   ├── agent-hook.sh          # Agent coordination
│   └── Makefile               # Command shortcuts
├── sprints/                   # Sprint directories
│   └── level-N-name/
│       ├── sprint.json        # Sprint manifest
│       ├── README.md          # Sprint documentation
│       ├── tasks/             # Task files
│       ├── docs/              # Documentation
│       └── agent-assignments/ # Agent task lists
├── levels/                    # Level directories
│   └── level-N/
│       ├── level-info.json    # Level configuration
│       └── sprints/           # Level sprints
├── events/                    # Event log
├── notifications/             # Agent notifications
└── xp-awards/                 # XP award records
```

## 🔧 Configuration

### Environment Variables
```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=signal_power
DB_USER=spp_user
DB_PASS=your_password

# Monitoring
GRAFANA_USER=admin
GRAFANA_PASS=admin

# Notifications (optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/...
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
```

### Agent Configuration
Edit `infrastructure/agent-coordinator.yaml` to:
- Add/modify agents
- Change coordination rules
- Update XP formulas
- Configure notifications

## 🎉 XP System

### Task Completion XP
```
Base: 10 XP
Priority Multiplier:
  - Critical: 2.0x
  - High: 1.5x
  - Medium: 1.0x
  - Low: 0.5x

Type Bonus:
  - Code: +5 XP
  - Design: +5 XP
  - Review: +3 XP
  - Test: +4 XP
```

### Sprint Bonus
```
Base: level * 25 XP
Completion Bonus: total_tasks * 5 XP
Rating Multiplier: 0.5x - 1.5x
```

### Level Formula
```
Level = sqrt(total_xp / 100) + 1
```

## 🚀 CI/CD Integration

The pipeline automatically:
1. Discovers active sprints
2. Validates sprint structure
3. Checks task completion
4. Tracks progress
5. Triggers level unlocks at 100%
6. Generates completion reports

## 📝 Sprint Templates

- `default` - Standard development sprint
- `architecture` - System design sprint
- `feature` - Feature implementation sprint
- `bugfix` - Bug fix sprint
- `performance` - Optimization sprint

## 🤝 Agent Roles

| Role | Responsibilities |
|------|-----------------|
| @architect | System design, API design, reviews |
| @builder | Implementation, coding, debugging |
| @reviewer | Code review, security audit, QA |
| @tester | Test design, validation, regression |
| @coordinator | Sprint planning, task assignment |
| @scaffolder | Infrastructure, CI/CD, automation |

## 📈 Metrics Tracked

- Sprint velocity (tasks/hour)
- Agent utilization
- Task completion rate
- Blocker count
- XP distribution
- Level progression

## 🔐 Security

- Agent authentication via handles
- Task assignment validation
- XP award audit trail
- Event logging
- Access control by level

---

**CODE RED Status**: Infrastructure operational. Ready for Level-Game sprints.
