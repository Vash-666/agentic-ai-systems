# Sprint P1-002 — Requirements Document

**Sprint Goal:** Add automated backup for state.db  
**Duration:** 1 hour  
**Effort:** 1 hour  
**Feature:** 1

---

## Feature: P1-002 — Automated Backup for state.db

### Current State
- `v3/state/state.db` is the single source of truth for SQLite checkpoints
- No automated backup exists
- Data loss risk if file corrupts or is accidentally deleted
- Manual `cp` only, no rotation

### Requirement
Create `scripts/backup-state.sh` that:
1. Backs up `state.db` to `backups/state-YYYY-MM-DD-HHMMSS.db`
2. Keeps last 30 backups (rotation)
3. Can run manually or via cron
4. Logs success/failure

### Acceptance Criteria
- [ ] `scripts/backup-state.sh` exists and is executable
- [ ] Creates timestamped backup in `backups/` directory
- [ ] Auto-creates `backups/` if missing
- [ ] Keeps max 30 backups, deletes oldest
- [ ] Logs to `logs/backup-state.log`
- [ ] Returns 0 on success, 1 on failure
- [ ] validate-system.sh still passes

### Implementation Notes
```bash
#!/bin/bash
# backup-state.sh
# Usage: ./backup-state.sh

BACKUP_DIR="$V3_DIR/backups"
DB_FILE="$V3_DIR/state/state.db"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="$BACKUP_DIR/state-$TIMESTAMP.db"

# Create backup dir if missing
mkdir -p "$BACKUP_DIR"

# Copy with verification
cp "$DB_FILE" "$BACKUP_FILE"
if [ $? -eq 0 ]; then
    echo "$(date): Backup created: $BACKUP_FILE"
    # Rotate: keep last 30
    ls -t "$BACKUP_DIR"/state-*.db | tail -n +31 | xargs rm -f
else
    echo "$(date): BACKUP FAILED"
    exit 1
fi
```

---

## Definition of Done

- [ ] Script created and tested
- [ ] Backup file verified (sqlite3 integrity check)
- [ ] Rotation works (old backups purged)
- [ ] validate-system.sh passes
- [ ] Git commit: "P1-002: Add automated backup for state.db"
- [ ] Stop — do not start P1-003

---

*Requirements by @product*  
*Sprint P1-002 — State Backup*
