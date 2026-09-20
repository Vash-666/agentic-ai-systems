#!/usr/bin/env python3
"""
SQLite Checkpointer for v3.1
Replaces file-based state with durable SQLite database
"""

import sqlite3
import json
import os
from datetime import datetime
from pathlib import Path

# Resolve DB_PATH relative to this file location
SCRIPT_DIR = Path(__file__).resolve().parent
DB_PATH = (SCRIPT_DIR / ".." / ".." / "state" / "state.db").resolve()

def init_db():
    """Initialize SQLite database with checkpoints table"""
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    
    conn = sqlite3.connect(str(DB_PATH))
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS checkpoints (
            checkpoint_id INTEGER PRIMARY KEY AUTOINCREMENT,
            scope TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            state_json TEXT NOT NULL,
            parent_id INTEGER,
            metadata TEXT
        )
    """)
    
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_scope_time 
        ON checkpoints(scope, timestamp DESC)
    """)
    
    conn.commit()
    conn.close()
    print(f"✓ Database initialized at {DB_PATH}")

def save_checkpoint(scope, state, parent_id=None):
    """Save a state checkpoint"""
    init_db()  # Ensure table exists
    conn = sqlite3.connect(str(DB_PATH))
    cursor = conn.cursor()
    
    cursor.execute("""
        INSERT INTO checkpoints (scope, timestamp, state_json, parent_id, metadata)
        VALUES (?, ?, ?, ?, ?)
    """, (
        scope,
        datetime.utcnow().isoformat(),
        json.dumps(state),
        parent_id,
        json.dumps({"version": "3.1"})
    ))
    
    checkpoint_id = cursor.lastrowid
    conn.commit()
    conn.close()
    
    return checkpoint_id

def load_checkpoint(scope, checkpoint_id=None):
    """Load latest or specific checkpoint"""
    if not DB_PATH.exists():
        return None
    
    init_db()  # Ensure table exists
    conn = sqlite3.connect(str(DB_PATH))
    cursor = conn.cursor()
    
    if checkpoint_id:
        cursor.execute("""
            SELECT state_json FROM checkpoints 
            WHERE checkpoint_id = ?
        """, (checkpoint_id,))
    else:
        cursor.execute("""
            SELECT state_json FROM checkpoints 
            WHERE scope = ? 
            ORDER BY timestamp DESC LIMIT 1
        """, (scope,))
    
    row = cursor.fetchone()
    conn.close()
    
    if row:
        return json.loads(row[0])
    return None

def list_checkpoints(scope, limit=10):
    """List recent checkpoints for a scope"""
    if not DB_PATH.exists():
        return []
    
    init_db()
    conn = sqlite3.connect(str(DB_PATH))
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT checkpoint_id, timestamp, metadata 
        FROM checkpoints 
        WHERE scope = ? 
        ORDER BY timestamp DESC LIMIT ?
    """, (scope, limit))
    
    rows = cursor.fetchall()
    conn.close()
    
    return [{"id": r[0], "timestamp": r[1], "meta": json.loads(r[2] or "{}")} for r in rows]

if __name__ == "__main__":
    init_db()
    
    # Test: Save and load
    test_state = {"agents": {"switch": "active"}, "tasks": []}
    cp_id = save_checkpoint("global", test_state)
    print(f"✓ Saved checkpoint {cp_id}")
    
    loaded = load_checkpoint("global")
    print(f"✓ Loaded state: {loaded}")
    
    checkpoints = list_checkpoints("global")
    print(f"✓ Found {len(checkpoints)} checkpoints")
