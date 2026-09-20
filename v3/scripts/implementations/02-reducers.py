#!/usr/bin/env python3
"""
State Reducers for v3.1
Wired to concurrent agent operations in spawn-agent.sh
Merges task states when multiple agents complete
Handles conflicts without data loss
"""

import json
import os
import sys
import sqlite3
from typing import List, Dict, Any, Optional
from pathlib import Path
from datetime import datetime

# Resolve paths relative to script location
SCRIPT_DIR = Path(__file__).resolve().parent
STATE_DIR = (SCRIPT_DIR / ".." / ".." / "state").resolve()
STATE_FILE = STATE_DIR / "current.json"
DB_PATH = STATE_DIR / "state.db"

# Priority order for conflict resolution: higher index = higher priority
PRIORITY_ORDER = ["system_default", "agent_output", "user_override"]

def merge_decisions(existing: List[Dict], new: List[Dict]) -> List[Dict]:
    """Merge decision lists without duplicates, preferring newer timestamps"""
    seen = {}
    for d in existing + new:
        did = d.get("id")
        if did:
            if did not in seen or d.get("timestamp", "") > seen[did].get("timestamp", ""):
                seen[did] = d
        else:
            # Decisions without ID are appended
            seen[f"_anon_{len(seen)}"] = d
    return list(seen.values())

def merge_tasks(existing: List[Dict], new: List[Dict]) -> List[Dict]:
    """Merge tasks, updating existing by ID with conflict resolution"""
    task_map = {t["id"]: t for t in existing if "id" in t}
    for task in new:
        task_id = task.get("id")
        if not task_id:
            task_id = f"task-{datetime.utcnow().isoformat()}-{len(task_map)}"
            task["id"] = task_id
        
        if task_id in task_map:
            existing_task = task_map[task_id]
            # Priority-based merge for conflicting fields
            new_priority = task.get("_priority", "agent_output")
            old_priority = existing_task.get("_priority", "system_default")
            
            if PRIORITY_ORDER.index(new_priority) >= PRIORITY_ORDER.index(old_priority):
                # New wins, but preserve fields not in new
                merged = existing_task.copy()
                merged.update(task)
                task_map[task_id] = merged
            else:
                # Old wins for overlapping keys, but add new keys
                merged = task.copy()
                merged.update({k: v for k, v in existing_task.items() if k not in task})
                task_map[task_id] = merged
        else:
            task_map[task_id] = task
    
    return list(task_map.values())

def merge_agents(existing: Dict[str, Dict], new: Dict[str, Dict]) -> Dict[str, Dict]:
    """Merge agent states, preferring newer status with timestamp check"""
    result = existing.copy()
    for agent_id, state in new.items():
        if agent_id in result:
            old_state = result[agent_id]
            old_ts = old_state.get("last_update", "")
            new_ts = state.get("last_update", "")
            
            if new_ts >= old_ts:
                # Newer timestamp wins, but merge nested dicts
                merged = old_state.copy()
                merged.update(state)
                result[agent_id] = merged
            else:
                # Keep old but add any new keys
                merged = state.copy()
                merged.update({k: v for k, v in old_state.items() if k not in state})
                result[agent_id] = merged
        else:
            result[agent_id] = state
    return result

def merge_context(existing: Dict, new: Dict) -> Dict:
    """Merge context, appending to lists and updating scalars with priority"""
    result = existing.copy()
    for key, value in new.items():
        if key not in result:
            result[key] = value
        elif isinstance(value, list) and isinstance(result[key], list):
            # Merge lists without duplicates (for hashable items)
            existing_set = set(str(x) for x in result[key])
            result[key] = result[key] + [v for v in value if str(v) not in existing_set]
        elif isinstance(value, dict) and isinstance(result[key], dict):
            result[key] = merge_context(result[key], value)
        else:
            # Scalar conflict: newer wins unless marked otherwise
            new_priority = new.get(f"_{key}_priority", "agent_output")
            old_priority = result.get(f"_{key}_priority", "system_default")
            if PRIORITY_ORDER.index(new_priority) >= PRIORITY_ORDER.index(old_priority):
                result[key] = value
    return result

# Registry of reducers by state key
REDUCERS = {
    "decisions": merge_decisions,
    "tasks": merge_tasks,
    "agents": merge_agents,
    "context": merge_context,
}

def reduce_state(existing_state: Dict, delta: Dict) -> Dict:
    """Apply reducers to merge state delta into existing state"""
    result = existing_state.copy()
    for key, value in delta.items():
        if key.startswith("_"):
            # Metadata keys pass through
            result[key] = value
        elif key in REDUCERS and key in result:
            result[key] = REDUCERS[key](result[key], value)
        elif key in REDUCERS and key not in result:
            result[key] = value
        else:
            result[key] = value
    return result

def reduce_concurrent_states(states: List[Dict]) -> Dict:
    """Merge multiple concurrent agent states into canonical state"""
    if not states:
        return {}
    if len(states) == 1:
        return states[0]
    
    canonical = states[0].copy()
    for delta in states[1:]:
        canonical = reduce_state(canonical, delta)
    
    # Add merge metadata
    canonical["_merge_info"] = {
        "merged_count": len(states),
        "merged_at": datetime.utcnow().isoformat(),
        "reducer_version": "3.1"
    }
    
    return canonical

def load_and_reduce(state_file: Path = STATE_FILE, delta: Dict = None) -> Dict:
    """Load existing state, apply delta with reducers, return merged state"""
    existing = {}
    if state_file.exists():
        try:
            with open(state_file) as f:
                existing = json.load(f)
        except (json.JSONDecodeError, IOError):
            existing = {}
    
    if delta:
        return reduce_state(existing, delta)
    return existing

def save_reduced_state(state: Dict, state_file: Path = STATE_FILE) -> bool:
    """Save merged state back to file"""
    try:
        state_file.parent.mkdir(parents=True, exist_ok=True)
        with open(state_file, 'w') as f:
            json.dump(state, f, indent=2)
        return True
    except IOError as e:
        print(f"✗ Failed to save state: {e}", file=sys.stderr)
        return False

def load_state_from_sqlite(scope: str = "global") -> Optional[Dict]:
    """Load latest state from SQLite database"""
    if not DB_PATH.exists():
        return None
    try:
        conn = sqlite3.connect(str(DB_PATH))
        cursor = conn.cursor()
        cursor.execute("""
            SELECT state_json FROM checkpoints
            WHERE scope = ?
            ORDER BY timestamp DESC LIMIT 1
        """, (scope,))
        row = cursor.fetchone()
        conn.close()
        if row:
            return json.loads(row[0])
    except Exception as e:
        print(f"⚠ SQLite load warning: {e}", file=sys.stderr)
    return None

def save_state_to_sqlite(state: Dict, scope: str = "global", parent_id: int = None) -> Optional[int]:
    """Save merged state to SQLite as a new checkpoint"""
    try:
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
            INSERT INTO checkpoints (scope, timestamp, state_json, parent_id, metadata)
            VALUES (?, ?, ?, ?, ?)
        """, (
            scope,
            datetime.utcnow().isoformat(),
            json.dumps(state),
            parent_id,
            json.dumps({"version": "3.1", "source": "reducer_merge"})
        ))
        checkpoint_id = cursor.lastrowid
        conn.commit()
        conn.close()
        return checkpoint_id
    except Exception as e:
        print(f"✗ SQLite save failed: {e}", file=sys.stderr)
        return None

def merge_and_save_sqlite(delta: Dict, scope: str = "global") -> Dict:
    """
    Load current state from SQLite, merge with delta using reducers,
    save back to SQLite, and return merged state.
    """
    existing = load_state_from_sqlite(scope) or {}
    merged = reduce_state(existing, delta)
    merged["last_updated"] = datetime.utcnow().isoformat()
    cp_id = save_state_to_sqlite(merged, scope)
    if cp_id:
        merged["_checkpoint_id"] = cp_id
    return merged

def merge_agent_outputs(agent_outputs: List[Dict]) -> Dict:
    """
    Merge outputs from multiple concurrent agents.
    Each agent output should be: {"agent_id": str, "output": dict, "timestamp": str}
    """
    deltas = []
    for output in agent_outputs:
        agent_id = output.get("agent_id", "unknown")
        agent_output = output.get("output", {})
        timestamp = output.get("timestamp", datetime.utcnow().isoformat())
        
        delta = {
            "agents": {
                agent_id: {
                    "last_output": agent_output,
                    "last_update": timestamp,
                    "status": "completed"
                }
            }
        }
        
        # If agent output contains tasks, decisions, etc., merge those too
        for key in ["tasks", "decisions", "context"]:
            if key in agent_output:
                delta[key] = agent_output[key]
        
        deltas.append(delta)
    
    # Reduce all deltas into canonical state
    canonical = reduce_concurrent_states(deltas)
    return canonical

if __name__ == "__main__":
    # Test reducers
    state = {
        "agents": {"switch": {"status": "active", "last_update": "2024-01-01T00:00:00"}},
        "tasks": [{"id": "t1", "status": "pending", "_priority": "system_default"}],
        "decisions": [{"id": "d1", "choice": "go", "timestamp": "2024-01-01T00:00:00"}]
    }

    delta = {
        "agents": {"switch": {"status": "busy", "last_update": "2024-01-01T01:00:00"}},
        "tasks": [{"id": "t1", "status": "in_progress", "_priority": "agent_output"}, {"id": "t2", "status": "pending"}],
        "decisions": [{"id": "d2", "choice": "stop", "timestamp": "2024-01-01T01:00:00"}]
    }

    merged = reduce_state(state, delta)
    print("✓ Reducers test passed")
    print(f"  Agents: {merged['agents']}")
    print(f"  Tasks: {len(merged['tasks'])} tasks")
    print(f"  Decisions: {len(merged['decisions'])} decisions")

    # Test concurrent merge
    outputs = [
        {"agent_id": "agent_a", "output": {"tasks": [{"id": "t3", "status": "done"}]}, "timestamp": "2024-01-01T02:00:00"},
        {"agent_id": "agent_b", "output": {"tasks": [{"id": "t4", "status": "done"}]}, "timestamp": "2024-01-01T02:00:00"}
    ]
    canonical = merge_agent_outputs(outputs)
    print(f"\n✓ Concurrent merge test passed")
    print(f"  Merged {canonical['_merge_info']['merged_count']} agent outputs")
    print(f"  Tasks: {len(canonical.get('tasks', []))} tasks")

    # Test SQLite merge
    print("\n--- SQLite merge test ---")
    test_delta = {
        "agents": {"test_agent": {"status": "working", "currentTask": "test_task", "last_update": datetime.utcnow().isoformat(), "_priority": "agent_output"}},
        "tasks": [{"id": "task-test-001", "description": "Test SQLite merge", "status": "in_progress", "assignee": "@test_agent", "_priority": "agent_output"}]
    }
    merged_sqlite = merge_and_save_sqlite(test_delta, scope="test")
    print(f"✓ SQLite merge test passed")
    print(f"  Checkpoint ID: {merged_sqlite.get('_checkpoint_id')}")
    print(f"  Agents: {list(merged_sqlite.get('agents', {}).keys())}")
    print(f"  Tasks: {len(merged_sqlite.get('tasks', []))} tasks")
    print(f"  Last updated: {merged_sqlite.get('last_updated')}")
