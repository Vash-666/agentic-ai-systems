#!/bin/bash
# health-monitor.sh — Ollama Health Monitor Wrapper
# Version: 3.1
# Usage: ./health-monitor.sh [start|stop|status|check]
# Configured via cron to run every 5 minutes

set -euo pipefail

# Resolve V3_DIR from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V3_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="$V3_DIR/logs/health-monitor.log"
PID_FILE="$V3_DIR/logs/health-monitor.pid"
CONFIG_FILE="$V3_DIR/state/health-monitor.conf"

# Alert thresholds
ALERT_API_DOWN_MINUTES=2
ALERT_LATENCY_MS=5000
ALERT_MODEL_UNLOAD="INFO"

# Default Telegram settings (override in config)
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""

# Load config if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [$level] $msg" | tee -a "$LOG_FILE"
}

send_telegram() {
    local level="$1"
    local msg="$2"
    
    if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
        return 0
    fi
    
    local icon="🔵"
    case "$level" in
        CRITICAL) icon="🔴" ;;
        WARNING)  icon="🟡" ;;
        INFO)     icon="🟢" ;;
    esac
    
    local payload="${icon} *${level}* — Ollama Health Monitor\n\n${msg}\n\n_Time: $(date -u +"%Y-%m-%d %H:%M UTC")_"
    
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${payload}" \
        -d "parse_mode=Markdown" \
        -d "disable_notification=$([ "$level" = "INFO" ] && echo "true" || echo "false")" \
        > /dev/null 2>&1 || true
}

check_ollama_api() {
    local start_time end_time latency
    start_time=$(python3 -c "import time; print(int(time.time()*1000))")
    
    local response
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://localhost:11434/api/tags" 2>/dev/null || echo "000")
    
    end_time=$(python3 -c "import time; print(int(time.time()*1000))")
    latency=$((end_time - start_time))
    
    if [ "$response" != "200" ]; then
        echo "DOWN|$latency"
    else
        echo "UP|$latency"
    fi
}

check_model_status() {
    local models
    models=$(curl -s --max-time 10 "http://localhost:11434/api/tags" 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    models = data.get('models', [])
    if not models:
        print('NO_MODELS')
    else:
        for m in models:
            print(f\"{m.get('name','unknown')}|{m.get('size',0)}\")
except:
    print('ERROR')
" 2>/dev/null || echo "ERROR")
    echo "$models"
}

run_check() {
    log "INFO" "Starting health check..."
    
    local api_status latency
    local check_result
    check_result=$(check_ollama_api)
    api_status=$(echo "$check_result" | cut -d'|' -f1)
    latency=$(echo "$check_result" | cut -d'|' -f2)
    
    local state_file="$V3_DIR/state/health-state.json"
    local api_down_since="0"
    local last_alert=""
    
    if [ -f "$state_file" ]; then
        api_down_since=$(python3 -c "import json; d=json.load(open('$state_file')); print(d.get('api_down_since',0))" 2>/dev/null || echo "0")
        last_alert=$(python3 -c "import json; d=json.load(open('$state_file')); print(d.get('last_alert',''))" 2>/dev/null || echo "")
    fi
    
    local now
    now=$(date +%s)
    
    if [ "$api_status" = "DOWN" ]; then
        if [ "$api_down_since" = "0" ]; then
            api_down_since="$now"
            log "WARNING" "Ollama API is DOWN (latency: ${latency}ms)"
        fi
        
        local down_minutes=$(( (now - api_down_since) / 60 ))
        
        if [ "$down_minutes" -ge "$ALERT_API_DOWN_MINUTES" ]; then
            local alert_key="CRITICAL_${api_down_since}"
            if [ "$last_alert" != "$alert_key" ]; then
                log "CRITICAL" "Ollama API down for ${down_minutes} minutes!"
                send_telegram "CRITICAL" "Ollama API has been down for *${down_minutes} minutes*.\n\nPlease check the service immediately."
                last_alert="$alert_key"
            fi
        fi
    else
        if [ "$api_down_since" != "0" ]; then
            local down_minutes=$(( (now - api_down_since) / 60 ))
            log "INFO" "Ollama API recovered after ${down_minutes} minutes"
            send_telegram "INFO" "Ollama API is back UP.\n\nDowntime: ${down_minutes} minutes."
        fi
        api_down_since="0"
        
        # Check latency
        if [ "$latency" -gt "$ALERT_LATENCY_MS" ]; then
            local alert_key="WARNING_LATENCY_${now}"
            # Throttle: max 1 latency alert per hour
            if [ "$last_alert" != "$alert_key" ] && [ "$(( now % 3600 ))" -lt 300 ]; then
                log "WARNING" "High latency detected: ${latency}ms (threshold: ${ALERT_LATENCY_MS}ms)"
                send_telegram "WARNING" "High Ollama latency detected: *${latency}ms*\n\nThreshold: ${ALERT_LATENCY_MS}ms"
                last_alert="$alert_key"
            fi
        fi
        
        # Check model status
        local model_status
        model_status=$(check_model_status)
        if [ "$model_status" = "NO_MODELS" ]; then
            log "INFO" "No models currently loaded in Ollama"
        elif [ "$model_status" = "ERROR" ]; then
            log "WARNING" "Could not retrieve model status"
        else
            local model_count
            model_count=$(echo "$model_status" | grep -c "|" || echo "0")
            log "INFO" "Ollama API UP — ${model_count} model(s) loaded, latency: ${latency}ms"
        fi
    fi
    
    # Persist state
    python3 -c "
import json
state = {
    'api_down_since': $api_down_since,
    'last_alert': '$last_alert',
    'last_check': $now,
    'last_latency': $latency,
    'last_status': '$api_status'
}
with open('$state_file', 'w') as f:
    json.dump(state, f, indent=2)
" 2>/dev/null || true
    
    log "INFO" "Health check complete"
}

case "${1:-check}" in
    start)
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            log "INFO" "Health monitor already running (PID: $(cat "$PID_FILE"))"
            exit 0
        fi
        echo $$ > "$PID_FILE"
        log "INFO" "Health monitor started (PID: $$)"
        while true; do
            run_check
            sleep 300  # 5 minutes
        done
        ;;
    stop)
        if [ -f "$PID_FILE" ]; then
            pid=$(cat "$PID_FILE")
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid" 2>/dev/null || true
                rm -f "$PID_FILE"
                log "INFO" "Health monitor stopped (PID: $pid)"
            else
                rm -f "$PID_FILE"
                log "INFO" "Health monitor was not running"
            fi
        else
            log "INFO" "Health monitor not running"
        fi
        ;;
    status)
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            echo "Health monitor: RUNNING (PID: $(cat "$PID_FILE"))"
            echo "Log file: $LOG_FILE"
            if [ -f "$LOG_FILE" ]; then
                echo "--- Last 5 log entries ---"
                tail -n 5 "$LOG_FILE"
            fi
        else
            echo "Health monitor: STOPPED"
            rm -f "$PID_FILE" 2>/dev/null || true
        fi
        ;;
    check|*)
        run_check
        ;;
esac
