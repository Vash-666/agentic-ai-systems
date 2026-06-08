#!/bin/bash
# context-cleanup.sh - Auto-cleanup expired session contexts
# Created: 2026-05-19
# Purpose: Enforce TTL on SESSION-CONTEXT.md and archive stale contexts

WORKSPACE="/Users/rohitvashist/.openclaw/workspace"
SESSION_CONTEXT="$WORKSPACE/SESSION-CONTEXT.md"
ARCHIVE_DIR="$WORKSPACE/archive/contexts"
LOG_FILE="$WORKSPACE/logs/context-cleanup.log"

# Ensure directories exist
mkdir -p "$ARCHIVE_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if SESSION-CONTEXT.md exists and has TTL
if [[ ! -f "$SESSION_CONTEXT" ]]; then
    log "INFO: No SESSION-CONTEXT.md found"
    exit 0
fi

# Extract expiration date from YAML frontmatter
EXPIRES=$(grep "^Expires:" "$SESSION_CONTEXT" | sed 's/Expires: //' || echo "")

if [[ -z "$EXPIRES" ]]; then
    log "WARN: SESSION-CONTEXT.md has no expiration date"
    exit 0
fi

# Convert to epoch seconds
EXPIRES_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${EXPIRES%EDT}" +%s 2>/dev/null || date -d "${EXPIRES%EDT}" +%s 2>/dev/null)
NOW_EPOCH=$(date +%s)

if [[ -z "$EXPIRES_EPOCH" ]]; then
    log "ERROR: Could not parse expiration date: $EXPIRES"
    exit 1
fi

# Check if expired
if [[ $NOW_EPOCH -gt $EXPIRES_EPOCH ]]; then
    # Archive the expired context
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    ARCHIVE_NAME="SESSION-CONTEXT-${TIMESTAMP}.md"
    
    cp "$SESSION_CONTEXT" "$ARCHIVE_DIR/$ARCHIVE_NAME"
    
    # Create fresh SESSION-CONTEXT.md template
    cat > "$SESSION_CONTEXT" << 'EOF'
# SESSION-CONTEXT.md - Model Switch Bridge

```yaml
Version: PLACEHOLDER
Created: PLACEHOLDER
Updated: PLACEHOLDER
Expires: PLACEHOLDER
TTL: 24h
Status: fresh
```

**Current Session:** PLACEHOLDER  
**Active Agent:** PLACEHOLDER  
**Current Model:** PLACEHOLDER  
**Session ID:** PLACEHOLDER  

---

## Recent Activity

*No recent activity recorded.*

---

## Key Decisions

*No key decisions recorded.*

---

## Active Work

| Task | Agent | Status | Started |
|------|-------|--------|---------|

---

## Files Being Modified

| File | Change | Status |
|------|--------|--------|

---

## Blockers

None.

---

## Quality Status

- **Overall System:** —
- **Context Freshness:** Fresh (just created)
- **Agent Coordination:** —

---

*Context expires in 24h — update or archive before then.*
EOF

    log "INFO: Expired context archived to $ARCHIVE_NAME"
    log "INFO: Fresh SESSION-CONTEXT.md template created"
else
    HOURS_LEFT=$(( ($EXPIRES_EPOCH - $NOW_EPOCH) / 3600 ))
    log "INFO: Context still valid ($HOURS_LEFT hours left)"
fi

exit 0
