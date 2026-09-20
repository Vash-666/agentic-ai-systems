#!/bin/bash
# update-daily-memory.sh — Update Daily Memory Log with Current Activity
# Version: 3.1
# Usage: ./update-daily-memory.sh [category] [content]

set -e

# Resolve V3_DIR from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V3_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Date configuration
TODAY=$(date +%Y-%m-%d)
DAILY_DIR="$V3_DIR/memory/daily"
TODAY_FILE="$DAILY_DIR/$TODAY.md"

# Ensure daily log exists
if [ ! -f "$TODAY_FILE" ]; then
    echo "Creating daily log first..."
    "$V3_DIR/scripts/daily-memory-log.sh" "Auto-created" > /dev/null 2>&1
fi

# Parse arguments
CATEGORY="${1:-general}"
CONTENT="${2:-No content provided}"
TIMESTAMP=$(date -u +"%H:%M:%S")

# Append to appropriate section based on category
case "$CATEGORY" in
    decision|decisions)
        # Add to Decisions Made section
        sed -i '' "/## Decisions Made/a\\
- [$TIMESTAMP] $CONTENT" "$TODAY_FILE" 2>/dev/null || \
        sed -i "/## Decisions Made/a\\
- [$TIMESTAMP] $CONTENT" "$TODAY_FILE"
        echo "✓ Added decision to daily log"
        ;;
    
    fact|facts|learned)
        # Add to Facts Learned section
        sed -i '' "/## Facts Learned/a\\
- [$TIMESTAMP] $CONTENT" "$TODAY_FILE" 2>/dev/null || \
        sed -i "/## Facts Learned/a\\
- [$TIMESTAMP] $CONTENT" "$TODAY_FILE"
        echo "✓ Added fact to daily log"
        ;;
    
    task|tasks|completed)
        # Add to Tasks Completed section
        sed -i '' "/## Tasks Completed/a\\
- [$TIMESTAMP] $CONTENT" "$TODAY_FILE" 2>/dev/null || \
        sed -i "/## Tasks Completed/a\\
- [$TIMESTAMP] $CONTENT" "$TODAY_FILE"
        echo "✓ Added task to daily log"
        ;;
    
    issue|issues|problem|problems)
        # Add to Issues Encountered section
        sed -i '' "/## Issues Encountered/a\\
- [$TIMESTAMP] $CONTENT" "$TODAY_FILE" 2>/dev/null || \
        sed -i "/## Issues Encountered/a\\
- [$TIMESTAMP] $CONTENT" "$TODAY_FILE"
        echo "✓ Added issue to daily log"
        ;;
    
    status|metrics)
        # Update System Status table
        # This is more complex - just append for now
        sed -i '' "/## Session Summary/a\\
\n**Status Update [$TIMESTAMP]:** $CONTENT" "$TODAY_FILE" 2>/dev/null || \
        sed -i "/## Session Summary/a\\
\n**Status Update [$TIMESTAMP]:** $CONTENT" "$TODAY_FILE"
        echo "✓ Added status update to daily log"
        ;;
    
    *)
        # General append to session summary
        sed -i '' "/## Session Summary/a\\
\n- [$TIMESTAMP] $CONTENT" "$TODAY_FILE" 2>/dev/null || \
        sed -i "/## Session Summary/a\\
\n- [$TIMESTAMP] $CONTENT" "$TODAY_FILE"
        echo "✓ Added entry to daily log"
        ;;
esac

echo "File: $TODAY_FILE"
