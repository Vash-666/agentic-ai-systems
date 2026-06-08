#!/bin/bash
#
# @grok Monitor — Autonomous External Validation
# Triggered by cron or manual invocation
# Usage: bash grok-monitor.sh [trigger-type]
#

set -e

WORKSPACE="/Users/rohitvashist/.openclaw/workspace"
BRIDGE="$WORKSPACE/content/tools/grok-bridge.sh"
LOG="$WORKSPACE/grok-validation-log.md"
TRIGGER="${1:-manual}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S %Z")

# Guard rail: Check daily call limit
DAILY_CALLS=$(grep -c "## 2026-$(date +%m-%d)" "$LOG" 2>/dev/null || echo 0)
DAILY_CALLS=$(echo "$DAILY_CALLS" | tr -d '\n')
if [ "$DAILY_CALLS" -ge 10 ]; then
    echo "[@grok] Daily call limit reached (10). Skipping."
    exit 0
fi

# Guard rail: Check cost ceiling
DAILY_COST=$(grep "2026-$(date +%m-%d)" "$WORKSPACE/grok-cost-tracker.jsonl" 2>/dev/null | \
    jq -s 'map(.estimated_cost) | add' 2>/dev/null || echo "0")
if (( $(echo "$DAILY_COST > 0.50" | bc -l) )); then
    echo "[@grok] Daily cost ceiling reached ($$0.50). Skipping."
    exit 0
fi

# Build validation prompt based on trigger
case "$TRIGGER" in
    heartbeat)
        # Read latest health report
        HEALTH_REPORT=$(ls -t "$WORKSPACE"/health-report-*.md 2>/dev/null | head -1)
        if [ -f "$HEALTH_REPORT" ]; then
            SYSTEM_STATE=$(head -50 "$HEALTH_REPORT")
            PROMPT="External validation request:

SYSTEM HEALTH REPORT (OpenClaw):
$SYSTEM_STATE

As an external validator, review this health report:
1. Are the quality scores realistic?
2. Any blind spots or missing checks?
3. Would you flag anything as concerning?
4. Keep response under 200 words."
        else
            PROMPT="External validation: No health report found. Is this concerning?"
        fi
        ;;
    
    quality-check)
        # Spot-check recent quality scores
        RECENT_SCORES=$(grep -A5 "Quality Score:" "$WORKSPACE"/memory/*.md 2>/dev/null | tail -20 || echo "No recent scores")
        PROMPT="External validation of recent quality scores:
$RECENT_SCORES

Spot-check: Are these scores realistic or potentially inflated?"
        ;;
    
    manual|*)
        PROMPT="External system validation requested. Current system state unknown — request specific context from user."
        ;;
esac

# Sanitize: Remove any potential secrets
SANITIZED_PROMPT=$(echo "$PROMPT" | sed 's/xai-[a-zA-Z0-9]*/[REDACTED]/g' | sed 's/sk-[a-zA-Z0-9]*/[REDACTED]/g')

# Call Grok via bridge
echo "[@grok] Running $TRIGGER validation..."
"$BRIDGE" "$SANITIZED_PROMPT" || {
    echo "[@grok] Bridge call failed. Check grok-bridge-log.md"
    exit 1
}

# Log the trigger
echo "[@grok] $TRIGGER validation complete at $TIMESTAMP" >> "$LOG"
