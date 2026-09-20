#!/bin/bash
# backup-state.sh — Automated backup for v3/state/state.db
# Usage: ./scripts/backup-state.sh

set -euo pipefail

V3_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKUP_DIR="$V3_DIR/backups"
DB_FILE="$V3_DIR/state/state.db"
LOG_FILE="$V3_DIR/logs/backup-state.log"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/state-$TIMESTAMP.db"
KEEP_COUNT=30

# Ensure directories exist
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Verify source exists
if [ ! -f "$DB_FILE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): ERROR: $DB_FILE not found" | tee -a "$LOG_FILE"
    exit 1
fi

# Create backup
cp "$DB_FILE" "$BACKUP_FILE"

# Verify backup integrity
if ! sqlite3 "$BACKUP_FILE" "PRAGMA integrity_check;" | grep -q "ok"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): ERROR: Backup integrity check failed for $BACKUP_FILE" | tee -a "$LOG_FILE"
    rm -f "$BACKUP_FILE"
    exit 1
fi

# Log success
SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "$(date '+%Y-%m-%d %H:%M:%S'): Backup created: $BACKUP_FILE ($SIZE)" | tee -a "$LOG_FILE"

# Rotate: keep last 30 backups
if [ "$(ls -1 "$BACKUP_DIR"/state-*.db 2>/dev/null | wc -l)" -gt "$KEEP_COUNT" ]; then
    ls -t "$BACKUP_DIR"/state-*.db | tail -n +$((KEEP_COUNT + 1)) | while read -r old; do
        echo "$(date '+%Y-%m-%d %H:%M:%S'): Rotating: removing $old" | tee -a "$LOG_FILE"
        rm -f "$old"
    done
fi

echo "$(date '+%Y-%m-%d %H:%M:%S'): Backup complete. Total backups: $(ls -1 "$BACKUP_DIR"/state-*.db 2>/dev/null | wc -l)" | tee -a "$LOG_FILE"
exit 0
