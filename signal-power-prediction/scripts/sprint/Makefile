# Level-Game Sprint Management Makefile
# Signal Power Prediction System

.PHONY: help init start complete status watch level-up agent

# Default target
help:
	@echo "╔═══════════════════════════════════════════════════════════╗"
	@echo "║     🎮 SIGNAL POWER PREDICTION - SPRINT COMMANDS          ║"
	@echo "╠═══════════════════════════════════════════════════════════╣"
	@echo "║                                                           ║"
	@echo "║  SPRINT MANAGEMENT:                                       ║"
	@echo "║    make init LEVEL=<N> NAME=<name> [AGENTS=<list>]       ║"
	@echo "║    make start [DIR=<path>]                               ║"
	@echo "║    make complete [DIR=<path>] [RATING=<1-5>]             ║"
	@echo "║    make status [DIR=<path>]                              ║"
	@echo "║    make watch [DIR=<path>]                               ║"
	@echo "║                                                           ║"
	@echo "║  LEVEL PROGRESSION:                                       ║"
	@echo "║    make level-up LEVEL=<N>                               ║"
	@echo "║    make levels                                           ║"
	@echo "║                                                           ║"
	@echo "║  AGENT COMMANDS:                                          ║"
	@echo "║    make agent-notify AGENT=<@handle> MSG=<message>       ║"
	@echo "║    make agent-assign AGENT=<@handle> TASK=<path>         ║"
	@echo "║    make agent-complete AGENT=<@handle> TASK=<path>       ║"
	@echo "║    make agent-xp AGENT=<@handle> XP=<amount>             ║"
	@echo "║                                                           ║"
	@echo "║  UTILITY:                                                 ║"
	@echo "║    make setup        - Initialize infrastructure          ║"
	@echo "║    make db-init      - Initialize database               ║"
	@echo "║    make clean        - Clean temporary files             ║"
	@echo "║    make dashboard    - Start monitoring dashboard        ║"
	@echo "║                                                           ║"
	@echo "╚═══════════════════════════════════════════════════════════╝"

# ============================================
# SPRINT COMMANDS
# ============================================

init:
	@if [ -z "$(LEVEL)" ] || [ -z "$(NAME)" ]; then \
		echo "❌ LEVEL and NAME are required"; \
		echo "Usage: make init LEVEL=1 NAME='Foundation Setup'"; \
		exit 1; \
	fi
	@./init-sprint.sh \
		--level $(LEVEL) \
		--name "$(NAME)" \
		$(if $(AGENTS),--agents "$(AGENTS)",) \
		$(if $(TEMPLATE),--template $(TEMPLATE),)

start:
	@if [ -n "$(DIR)" ]; then \
		./start-sprint.sh --sprint-dir $(DIR) --notify; \
	else \
		ACTIVE=$$(cat ../../.active-sprint 2>/dev/null || echo ""); \
		if [ -n "$$ACTIVE" ]; then \
			./start-sprint.sh --sprint-dir $$ACTIVE --notify; \
		else \
			echo "❌ No active sprint found. Use DIR=<path> or run from sprint directory"; \
			exit 1; \
		fi \
	fi

complete:
	@if [ -n "$(DIR)" ]; then \
		./complete-sprint.sh --sprint-dir $(DIR) $(if $(RATING),--rating $(RATING),); \
	else \
		ACTIVE=$$(cat ../../.active-sprint 2>/dev/null || echo ""); \
		if [ -n "$$ACTIVE" ]; then \
			./complete-sprint.sh --sprint-dir $$ACTIVE $(if $(RATING),--rating $(RATING),); \
		else \
			echo "❌ No active sprint found. Use DIR=<path>"; \
			exit 1; \
		fi \
	fi

status:
	@if [ -n "$(DIR)" ]; then \
		./sprint-status.sh --sprint-dir $(DIR); \
	else \
		./sprint-status.sh; \
	fi

watch:
	@if [ -n "$(DIR)" ]; then \
		./sprint-status.sh --sprint-dir $(DIR) --watch; \
	else \
		./sprint-status.sh --watch; \
	fi

# ============================================
# LEVEL COMMANDS
# ============================================

level-up:
	@if [ -z "$(LEVEL)" ]; then \
		echo "❌ LEVEL is required"; \
		echo "Usage: make level-up LEVEL=2"; \
		exit 1; \
	fi
	@./level-up.sh --level $(LEVEL)

levels:
	@echo "📊 LEVEL STATUS"
	@echo "═══════════════════════════════════════════════════════════"
	@if [ -d "../../levels" ]; then \
		for level in ../../levels/level-*/; do \
			if [ -f "$$level/level-info.json" ]; then \
				NUM=$$(jq -r '.number' "$$level/level-info.json"); \
				NAME=$$(jq -r '.name' "$$level/level-info.json"); \
				STATUS=$$(jq -r '.status' "$$level/level-info.json"); \
				if [ "$$STATUS" = "unlocked" ]; then \
					echo "  🔓 Level $$NUM: $$NAME"; \
				else \
					echo "  🔒 Level $$NUM: $$NAME (locked)"; \
				fi \
			fi \
		done \
	else \
		echo "  No levels directory found"; \
	fi
	@echo "═══════════════════════════════════════════════════════════"

# ============================================
# AGENT COMMANDS
# ============================================

agent-notify:
	@if [ -z "$(AGENT)" ] || [ -z "$(MSG)" ]; then \
		echo "❌ AGENT and MSG are required"; \
		echo "Usage: make agent-notify AGENT=@builder MSG='Hello!'"; \
		exit 1; \
	fi
	@./agent-hook.sh --action notify --agent $(AGENT) --message "$(MSG)"

agent-assign:
	@if [ -z "$(AGENT)" ] || [ -z "$(TASK)" ]; then \
		echo "❌ AGENT and TASK are required"; \
		echo "Usage: make agent-assign AGENT=@builder TASK=./tasks/01-task.md"; \
		exit 1; \
	fi
	@./agent-hook.sh --action assign --agent $(AGENT) --task $(TASK)

agent-complete:
	@if [ -z "$(AGENT)" ] || [ -z "$(TASK)" ]; then \
		echo "❌ AGENT and TASK are required"; \
		echo "Usage: make agent-complete AGENT=@builder TASK=./tasks/01-task.md"; \
		exit 1; \
	fi
	@./agent-hook.sh --action complete --agent $(AGENT) --task $(TASK)

agent-xp:
	@if [ -z "$(AGENT)" ] || [ -z "$(XP)" ]; then \
		echo "❌ AGENT and XP are required"; \
		echo "Usage: make agent-xp AGENT=@builder XP=25"; \
		exit 1; \
	fi
	@./agent-hook.sh --action xp-award --agent $(AGENT) --xp $(XP) --reason "$(if $(REASON),$(REASON),Manual XP award)"

agent-status:
	@./agent-hook.sh --action status

# ============================================
# UTILITY COMMANDS
# ============================================

setup:
	@echo "🔧 Setting up Level-Game Infrastructure..."
	@mkdir -p ../../{sprints,levels,events,notifications,xp-awards}
	@echo "✅ Directory structure created"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Initialize database: make db-init"
	@echo "  2. Unlock Level 1: make level-up LEVEL=1"
	@echo "  3. Create first sprint: make init LEVEL=1 NAME='Foundation'"

db-init:
	@echo "🗄️  Initializing database..."
	@if command -v psql >/dev/null 2>&1; then \
		psql -h localhost -U spp_user -d signal_power -f ../../infrastructure/sprint-schema.sql || \
		echo "⚠️  Could not connect to database. Make sure PostgreSQL is running."; \
	else \
		echo "⚠️  psql not found. Install PostgreSQL client or use Docker:"
		echo "    docker-compose -f ../../infrastructure/docker-compose.yml up -d postgres"; \
	fi

dashboard:
	@echo "📊 Starting monitoring dashboard..."
	@docker-compose -f ../../infrastructure/docker-compose.yml up -d grafana prometheus
	@echo "✅ Dashboard started at http://localhost:3001"
	@echo "   Default credentials: admin/admin"

clean:
	@echo "🧹 Cleaning temporary files..."
	@find . -name "*.bak" -delete
	@find . -name ".DS_Store" -delete
	@find . -name "tmp*" -delete
	@echo "✅ Cleanup complete"

# ============================================
# DEVELOPMENT COMMANDS
# ============================================

dev-up:
	@echo "🚀 Starting development environment..."
	@docker-compose -f ../../infrastructure/docker-compose.yml up -d
	@echo "✅ Development environment started"
	@echo "   API: http://localhost:3000"
	@echo "   Dashboard: http://localhost:8080"
	@echo "   Grafana: http://localhost:3001"

dev-down:
	@echo "🛑 Stopping development environment..."
	@docker-compose -f ../../infrastructure/docker-compose.yml down
	@echo "✅ Development environment stopped"

dev-logs:
	@docker-compose -f ../../infrastructure/docker-compose.yml logs -f

test:
	@echo "🧪 Running tests..."
	@for script in *.sh; do \
		bash -n "$$script" && echo "✓ $$script"; \
	done
	@echo "✅ All scripts validated"

# ============================================
# SHORTCUTS
# ============================================

# Quick sprint creation shortcuts
sprint-1: ; $(MAKE) init LEVEL=1 NAME="Foundation Setup" AGENTS="@architect,@builder"
sprint-2: ; $(MAKE) init LEVEL=2 NAME="Core Architecture" AGENTS="@architect,@builder,@reviewer"
sprint-3: ; $(MAKE) init LEVEL=3 NAME="API Development" AGENTS="@builder,@tester,@reviewer"
sprint-4: ; $(MAKE) init LEVEL=4 NAME="Integration" AGENTS="@architect,@builder,@tester,@reviewer"
sprint-5: ; $(MAKE) init LEVEL=5 NAME="Performance" AGENTS="@architect,@builder,@scaffolder"

# Quick level unlocks
unlock-1: ; $(MAKE) level-up LEVEL=1
unlock-2: ; $(MAKE) level-up LEVEL=2
unlock-3: ; $(MAKE) level-up LEVEL=3
unlock-4: ; $(MAKE) level-up LEVEL=4
unlock-5: ; $(MAKE) level-up LEVEL=5
