#!/bin/bash
# quality-score.sh — Automated Quality Scoring with Daily Logging
# Version: 3.1
# Usage: ./quality-score.sh <file_path>
# Logs results to memory/daily/YYYY-MM-DD-quality.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V3_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FILE="${1:-$V3_DIR/core/SOUL.md}"

# Ensure directories exist
mkdir -p "$V3_DIR/memory/daily"
mkdir -p "$V3_DIR/logs"

# Telegram alert config (override in state/health-monitor.conf)
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""
CONFIG_FILE="$V3_DIR/state/health-monitor.conf"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    echo "Usage: ./quality-score.sh <file_path>"
    echo "Example: ./quality-score.sh ../core/SOUL.md"
    exit 1
fi

# Gather system metrics for daily log
TODAY=$(date +%Y-%m-%d)
QUALITY_LOG="$V3_DIR/memory/daily/${TODAY}-quality.json"

# Count active agents from state file
ACTIVE_AGENTS=0
if [ -f "$V3_DIR/state/current.json" ]; then
    ACTIVE_AGENTS=$(python3 -c "
import json, sys
try:
    with open('$V3_DIR/state/current.json') as f:
        state = json.load(f)
    agents = state.get('agents', {})
    active = [a for a in agents.values() if a.get('status') == 'active' or a.get('status') == 'working']
    print(len(active))
except:
    print(0)
" 2>/dev/null || echo "0")
fi

# Calculate context utilization (placeholder: based on checkpoint count)
CONTEXT_UTIL=100
if [ -f "$V3_DIR/state/state.db" ]; then
    CHECKPOINT_COUNT=$(sqlite3 "$V3_DIR/state/state.db" "SELECT COUNT(*) FROM checkpoints;" 2>/dev/null || echo "0")
    if [ "$CHECKPOINT_COUNT" -gt 100 ]; then
        CONTEXT_UTIL=95
    elif [ "$CHECKPOINT_COUNT" -gt 50 ]; then
        CONTEXT_UTIL=90
    elif [ "$CHECKPOINT_COUNT" -gt 10 ]; then
        CONTEXT_UTIL=85
    else
        CONTEXT_UTIL=80
    fi
fi

# Calculate cost savings (placeholder heuristic)
COST_SAVINGS=88

# Error rate (placeholder: based on log presence)
ERROR_RATE=0
if [ -f "$V3_DIR/logs/health-monitor.log" ]; then
    RECENT_ERRORS=$(grep -c "CRITICAL\|ERROR" "$V3_DIR/logs/health-monitor.log" 2>/dev/null || echo "0")
    if [ "$RECENT_ERRORS" -gt 10 ]; then
        ERROR_RATE=5
    elif [ "$RECENT_ERRORS" -gt 5 ]; then
        ERROR_RATE=2
    elif [ "$RECENT_ERRORS" -gt 0 ]; then
        ERROR_RATE=1
    fi
fi

# Send Telegram alert if quality drops below 9.0
send_quality_alert() {
    local score="$1"
    local trend="$2"
    if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
        local payload="🔴 *QUALITY ALERT* — Score dropped below 9.0\n\nCurrent Score: *${score}/10*\n7-Day Trend: ${trend}\n\nPlease review system health."
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d "chat_id=${TELEGRAM_CHAT_ID}" \
            -d "text=${payload}" \
            -d "parse_mode=Markdown" \
            > /dev/null 2>&1 || true
    fi
}

# Calculate 7-day trend
calculate_trend() {
    local scores=()
    for i in $(seq 0 6); do
        local d
        d=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "-${i} days" +%Y-%m-%d)
        local f="$V3_DIR/memory/daily/${d}-quality.json"
        if [ -f "$f" ]; then
            local s
            s=$(python3 -c "import json; d=json.load(open('$f')); print(d.get('qualityScore',0))" 2>/dev/null || echo "0")
            scores+=("$s")
        fi
    done
    
    if [ ${#scores[@]} -lt 2 ]; then
        echo "insufficient_data"
        return
    fi
    
    local first="${scores[-1]}"
    local last="${scores[0]}"
    local diff
    diff=$(python3 -c "print(f'{float('$last') - float('$first'):.2f}')" 2>/dev/null || echo "0")
    
    if (( $(echo "$diff > 0.5" | bc -l 2>/dev/null || echo "0") )); then
        echo "improving (+$diff)"
    elif (( $(echo "$diff < -0.5" | bc -l 2>/dev/null || echo "0") )); then
        echo "declining ($diff)"
    else
        echo "stable ($diff)"
    fi
}

echo "========================================"
echo "  Quality Score Calculator"
echo "  File: $(basename "$FILE")"
echo "========================================"
echo ""

# Initialize scores (default to 8 for well-structured files)
PROMPT_FILES=8
MEMORY=8
MODEL=8
TOOLS=8

# 1. Prompt Files Quality (65% weight)
echo "[1/4] Prompt Files Quality..."

# Check structure
if grep -q "^#" "$FILE"; then
    PROMPT_FILES=$((PROMPT_FILES + 1))
    echo "  ✓ Has headers"
fi

if grep -q "^##" "$FILE"; then
    PROMPT_FILES=$((PROMPT_FILES + 1))
    echo "  ✓ Has subsections"
fi

# Check completeness (size-based heuristic)
SIZE=$(wc -c < "$FILE")
if [ "$SIZE" -gt 2000 ]; then
    PROMPT_FILES=$((PROMPT_FILES + 1))
    echo "  ✓ Comprehensive ($SIZE bytes)"
elif [ "$SIZE" -gt 1000 ]; then
    PROMPT_FILES=$((PROMPT_FILES + 0))
    echo "  ✓ Adequate ($SIZE bytes)"
else
    PROMPT_FILES=$((PROMPT_FILES - 2))
    echo "  ⚠ Brief ($SIZE bytes)"
fi

# Check for examples/templates
if grep -qi "example\|template\|sample" "$FILE"; then
    PROMPT_FILES=$((PROMPT_FILES + 1))
    echo "  ✓ Has examples"
fi

# Penalize TODOs
if grep -qi "todo\|fixme\|hack\|placeholder" "$FILE"; then
    PROMPT_FILES=$((PROMPT_FILES - 2))
    echo "  ⚠ Has TODOs/FIXMEs"
fi

# Cap at 10
if [ "$PROMPT_FILES" -gt 10 ]; then PROMPT_FILES=10; fi
if [ "$PROMPT_FILES" -lt 0 ]; then PROMPT_FILES=0; fi

echo "  Score: $PROMPT_FILES/10"
echo ""

# 2. Memory Quality (20% weight)
echo "[2/4] Memory Quality..."

if grep -qi "memory\|context\|state\|history\|session" "$FILE"; then
    MEMORY=$((MEMORY + 1))
    echo "  ✓ References memory/context"
fi

if grep -qi "SESSION-CONTEXT\|memory/\|STRATEGIC" "$FILE"; then
    MEMORY=$((MEMORY + 1))
    echo "  ✓ Uses specific memory files"
fi

if grep -qi "learn\|lesson\|experience\|decision" "$FILE"; then
    MEMORY=$((MEMORY + 1))
    echo "  ✓ Captures learning/decisions"
fi

# Cap at 10
if [ "$MEMORY" -gt 10 ]; then MEMORY=10; fi
if [ "$MEMORY" -lt 0 ]; then MEMORY=0; fi

echo "  Score: $MEMORY/10"
echo ""

# 3. Model Quality (10% weight)
echo "[3/4] Model Quality..."

if grep -qi "model\|provider\|claude\|gpt\|grok\|kimi\|deepseek" "$FILE"; then
    MODEL=$((MODEL + 1))
    echo "  ✓ Specifies model/provider"
fi

if grep -qi "fallback\|backup\|alternative" "$FILE"; then
    MODEL=$((MODEL + 1))
    echo "  ✓ Has fallback strategy"
fi

if grep -qi "cost\|efficient\|optimize\|routing" "$FILE"; then
    MODEL=$((MODEL + 1))
    echo "  ✓ Considers efficiency"
fi

# Cap at 10
if [ "$MODEL" -gt 10 ]; then MODEL=10; fi
if [ "$MODEL" -lt 0 ]; then MODEL=0; fi

echo "  Score: $MODEL/10"
echo ""

# 4. Tools Quality (5% weight)
echo "[4/4] Tools Quality..."

if grep -qi "tool\|function\|api\|script\|automate" "$FILE"; then
    TOOLS=$((TOOLS + 1))
    echo "  ✓ References tools/automation"
fi

if grep -qi "read\|write\|exec\|search\|spawn" "$FILE"; then
    TOOLS=$((TOOLS + 1))
    echo "  ✓ Uses OpenClaw tools"
fi

if grep -qi "script\|harness\|evaluate\|test" "$FILE"; then
    TOOLS=$((TOOLS + 1))
    echo "  ✓ Has automation/testing"
fi

# Cap at 10
if [ "$TOOLS" -gt 10 ]; then TOOLS=10; fi
if [ "$TOOLS" -lt 0 ]; then TOOLS=0; fi

echo "  Score: $TOOLS/10"
echo ""

# Calculate overall quality
echo "========================================"
echo "  Quality Calculation"
echo "========================================"
echo ""

# Calculate weighted sum
OVERALL=$((PROMPT_FILES * 65 + MEMORY * 20 + MODEL * 10 + TOOLS * 5))
OVERALL=$((OVERALL / 100))

echo "  Prompt Files: $PROMPT_FILES/10 × 0.65 = $((PROMPT_FILES * 65 / 100)).$((PROMPT_FILES * 65 % 100))"
echo "  Memory:       $MEMORY/10 × 0.20 = $((MEMORY * 20 / 100)).$((MEMORY * 20 % 100))"
echo "  Model:        $MODEL/10 × 0.10 = $((MODEL * 10 / 100)).$((MODEL * 10 % 100))"
echo "  Tools:        $TOOLS/10 × 0.05 = $((TOOLS * 5 / 100)).$((TOOLS * 5 % 100))"
echo ""
echo "  OVERALL: $OVERALL/10"
echo ""

if [ "$OVERALL" -ge 9 ]; then
    echo "  Status: ✅ EXCEEDS TARGET (≥9.0)"
elif [ "$OVERALL" -ge 8 ]; then
    echo "  Status: ⚠ MEETS TARGET (≥8.0)"
else
    echo "  Status: ✗ BELOW TARGET (<8.0)"
fi

# Write daily quality log
TREND=$(calculate_trend)
python3 -c "
import json
from datetime import datetime

entry = {
    'timestamp': datetime.utcnow().isoformat(),
    'date': '$TODAY',
    'qualityScore': $OVERALL,
    'contextUtilization': $CONTEXT_UTIL,
    'costSavings': $COST_SAVINGS,
    'activeAgents': $ACTIVE_AGENTS,
    'errorRate': $ERROR_RATE,
    'trend': '$TREND',
    'details': {
        'promptFiles': $PROMPT_FILES,
        'memory': $MEMORY,
        'model': $MODEL,
        'tools': $TOOLS
    }
}

with open('$QUALITY_LOG', 'w') as f:
    json.dump(entry, f, indent=2)
print(f'  ✓ Quality log saved: memory/daily/{datetime.utcnow().strftime(\"%Y-%m-%d\")}-quality.json')
" 2>/dev/null || echo "  ⚠ Could not save quality log"

# Alert if below 9.0
if [ "$OVERALL" -lt 9 ]; then
    echo "  🚨 ALERT: Quality score below 9.0 — triggering notification"
    send_quality_alert "$OVERALL" "$TREND"
fi

echo ""
echo "========================================"
