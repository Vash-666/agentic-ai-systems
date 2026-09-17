#!/usr/bin/env python3
"""
State Reducers for v3.0
Prevents conflicts when multiple subagents modify state concurrently
"""

from typing import List, Dict, Any

def merge_decisions(existing: List[Dict], new: List[Dict]) -> List[Dict]:
    """Merge decision lists without duplicates"""
    seen = {d.get("id") for d in existing}
    return existing + [d for d in new if d.get("id") not in seen]

def merge_tasks(existing: List[Dict], new: List[Dict]) -> List[Dict]:
    """Merge tasks, updating existing by ID"""
    task_map = {t["id"]: t for t in existing}
    for task in new:
        task_id = task["id"]
        if task_id in task_map:
            # Update existing task
            task_map[task_id].update(task)
        else:
            task_map[task_id] = task
    return list(task_map.values())

def merge_agents(existing: Dict[str, Dict], new: Dict[str, Dict]) -> Dict[str, Dict]:
    """Merge agent states, preferring newer status"""
    result = existing.copy()
    for agent_id, state in new.items():
        if agent_id in result:
            # Keep newer timestamp
            if state.get("last_update", "") > result[agent_id].get("last_update", ""):
                result[agent_id] = state
        else:
            result[agent_id] = state
    return result

def merge_context(existing: Dict, new: Dict) -> Dict:
    """Merge context, appending to lists and updating scalars"""
    result = existing.copy()
    for key, value in new.items():
        if key not in result:
            result[key] = value
        elif isinstance(value, list) and isinstance(result[key], list):
            result[key] = result[key] + [v for v in value if v not in result[key]]
        elif isinstance(value, dict) and isinstance(result[key], dict):
            result[key].update(value)
        else:
            result[key] = value  # Newer value wins
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
        if key in REDUCERS and key in result:
            result[key] = REDUCERS[key](result[key], value)
        else:
            result[key] = value
    return result

if __name__ == "__main__":
    # Test reducers
    state = {
        "agents": {"switch": {"status": "active", "last_update": "2024-01-01T00:00:00"}},
        "tasks": [{"id": "t1", "status": "pending"}],
        "decisions": [{"id": "d1", "choice": "go"}]
    }
    
    delta = {
        "agents": {"switch": {"status": "busy", "last_update": "2024-01-01T01:00:00"}},
        "tasks": [{"id": "t1", "status": "in_progress"}, {"id": "t2", "status": "pending"}],
        "decisions": [{"id": "d2", "choice": "stop"}]
    }
    
    merged = reduce_state(state, delta)
    print("✓ Reducers test passed")
    print(f"  Agents: {merged['agents']}")
    print(f"  Tasks: {len(merged['tasks'])} tasks")
    print(f"  Decisions: {len(merged['decisions'])} decisions")
