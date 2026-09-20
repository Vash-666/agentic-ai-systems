#!/usr/bin/env python3
"""
Scoped Memory Hierarchy for v3.1
Wired to agent context loading in session-startup.sh
Creates project/agent/task/global scope paths
Loads scoped context during startup
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime
from typing import Optional, List, Dict, Any

# Resolve paths relative to script location
SCRIPT_DIR = Path(__file__).resolve().parent
MEMORY_ROOT = (SCRIPT_DIR / ".." / ".." / "memory" / "scoped").resolve()
PROJECT_MEMORY_ROOT = (SCRIPT_DIR / ".." / ".." / "memory" / "project").resolve()

# Scope resolution order: task → agent → session → global
SCOPE_RESOLUTION_ORDER = ["task", "agent", "session", "global"]

def ensure_dirs():
    """Create scoped memory directories"""
    for scope in SCOPE_RESOLUTION_ORDER:
        (MEMORY_ROOT / scope).mkdir(parents=True, exist_ok=True)
        (PROJECT_MEMORY_ROOT / "default" / scope).mkdir(parents=True, exist_ok=True)
    return True

def memory_path(scope: str, scope_id: str, key: str) -> Path:
    """Get file path for a scoped memory entry"""
    return MEMORY_ROOT / scope / scope_id / f"{key}.json"

def save(scope: str, scope_id: str, key: str, data: Any, metadata: Dict = None) -> Path:
    """Save data to scoped memory with metadata"""
    ensure_dirs()
    path = memory_path(scope, scope_id, key)
    path.parent.mkdir(parents=True, exist_ok=True)
    
    entry = {
        "timestamp": datetime.utcnow().isoformat(),
        "scope": scope,
        "scope_id": scope_id,
        "key": key,
        "data": data,
        "metadata": metadata or {}
    }
    
    with open(path, 'w') as f:
        json.dump(entry, f, indent=2)
    
    return path

def load(scope: str, scope_id: str, key: str) -> Optional[Dict]:
    """Load data from scoped memory"""
    path = memory_path(scope, scope_id, key)
    if not path.exists():
        return None
    
    with open(path) as f:
        return json.load(f)

def get(scope: str, scope_id: str, key: str, default=None) -> Any:
    """Get data value from scoped memory, with fallback to default"""
    entry = load(scope, scope_id, key)
    if entry:
        return entry.get("data", default)
    return default

def resolve(scope: str, scope_id: str, key: str) -> Optional[Dict]:
    """
    Resolve a key following scope hierarchy.
    Tries: task → agent → session → global
    Returns the first match found.
    """
    # Start from the requested scope and walk up the hierarchy
    try:
        start_idx = SCOPE_RESOLUTION_ORDER.index(scope)
    except ValueError:
        start_idx = 0
    
    for i in range(start_idx, len(SCOPE_RESOLUTION_ORDER)):
        current_scope = SCOPE_RESOLUTION_ORDER[i]
        entry = load(current_scope, scope_id, key)
        if entry is not None:
            return entry
    
    return None

def resolve_value(scope: str, scope_id: str, key: str, default=None) -> Any:
    """Resolve a key following scope hierarchy, return just the data value"""
    entry = resolve(scope, scope_id, key)
    if entry:
        return entry.get("data", default)
    return default

def list_scope(scope: str, scope_id: Optional[str] = None) -> List[Dict]:
    """List all entries in a scope"""
    base = MEMORY_ROOT / scope
    if scope_id:
        base = base / scope_id
    
    if not base.exists():
        return []
    
    entries = []
    for path in base.rglob("*.json"):
        try:
            with open(path) as f:
                entries.append(json.load(f))
        except (json.JSONDecodeError, IOError):
            continue
    return entries

def search(query: str, scope: Optional[str] = None, scope_id: Optional[str] = None) -> List[Dict]:
    """Simple keyword search across scoped memory"""
    results = []
    
    if scope and scope_id:
        search_root = MEMORY_ROOT / scope / scope_id
    elif scope:
        search_root = MEMORY_ROOT / scope
    else:
        search_root = MEMORY_ROOT
    
    if not search_root.exists():
        return results
    
    query_lower = query.lower()
    for path in search_root.rglob("*.json"):
        try:
            with open(path) as f:
                entry = json.load(f)
                if query_lower in json.dumps(entry).lower():
                    results.append(entry)
        except (json.JSONDecodeError, IOError):
            continue
    
    return results

def project_memory_path(scope: str, scope_id: str, key: str) -> Path:
    """Get file path for a project-scoped memory entry"""
    return PROJECT_MEMORY_ROOT / "default" / scope / scope_id / f"{key}.json"


def save_project(scope: str, scope_id: str, key: str, data: Any, metadata: Dict = None) -> Path:
    """Save data to project-scoped memory with metadata"""
    ensure_dirs()
    path = project_memory_path(scope, scope_id, key)
    path.parent.mkdir(parents=True, exist_ok=True)

    entry = {
        "timestamp": datetime.utcnow().isoformat(),
        "scope": scope,
        "scope_id": scope_id,
        "key": key,
        "data": data,
        "metadata": metadata or {}
    }

    with open(path, 'w') as f:
        json.dump(entry, f, indent=2)

    return path


def load_project(scope: str, scope_id: str, key: str) -> Optional[Dict]:
    """Load data from project-scoped memory"""
    path = project_memory_path(scope, scope_id, key)
    if not path.exists():
        return None

    with open(path) as f:
        return json.load(f)


def list_project_scope(scope: str, scope_id: Optional[str] = None) -> List[Dict]:
    """List all entries in a project scope"""
    base = PROJECT_MEMORY_ROOT / "default" / scope
    if scope_id:
        base = base / scope_id

    if not base.exists():
        return []

    entries = []
    for path in base.rglob("*.json"):
        try:
            with open(path) as f:
                entries.append(json.load(f))
        except (json.JSONDecodeError, IOError):
            continue
    return entries


def load_project_context_for_startup(agent_name: str, session_id: str, task_id: Optional[str] = None) -> Dict[str, Any]:
    """
    Load project-scoped context for agent startup.
    Looks in: project/default/agent/{agent_name}/, project/default/global/, project/default/task/{task_id}/
    Returns a dictionary of all relevant project-scoped memories.
    """
    context = {
        "global": {},
        "agent": {},
        "task": {}
    }

    # Load global scope
    for entry in list_project_scope("global", "default"):
        context["global"][entry.get("key")] = entry.get("data")

    # Load agent scope
    for entry in list_project_scope("agent", agent_name):
        context["agent"][entry.get("key")] = entry.get("data")

    # Load task scope if task_id provided
    if task_id:
        for entry in list_project_scope("task", task_id):
            context["task"][entry.get("key")] = entry.get("data")

    return context


def load_context_for_startup(agent_name: str, session_id: str, task_id: Optional[str] = None) -> Dict[str, Any]:
    """
    Load scoped context for agent startup.
    Returns a dictionary of all relevant scoped memories.
    """
    context = {
        "global": {},
        "session": {},
        "agent": {},
        "task": {}
    }

    # Load global scope
    for entry in list_scope("global", "default"):
        context["global"][entry.get("key")] = entry.get("data")

    # Load session scope
    for entry in list_scope("session", session_id):
        context["session"][entry.get("key")] = entry.get("data")

    # Load agent scope
    for entry in list_scope("agent", agent_name):
        context["agent"][entry.get("key")] = entry.get("data")

    # Load task scope if task_id provided
    if task_id:
        for entry in list_scope("task", task_id):
            context["task"][entry.get("key")] = entry.get("data")

    return context

def promote(scope: str, scope_id: str, key: str, target_scope: str, target_scope_id: str) -> bool:
    """
    Promote a memory entry to a higher scope (e.g., task → session → global).
    Used by fact extractor to promote important facts.
    """
    entry = load(scope, scope_id, key)
    if not entry:
        return False
    
    # Save to target scope
    save(target_scope, target_scope_id, key, entry.get("data"), {
        **entry.get("metadata", {}),
        "promoted_from": f"{scope}/{scope_id}",
        "promoted_at": datetime.utcnow().isoformat()
    })
    
    return True

def garbage_collect_task(task_id: str, archive: bool = True) -> int:
    """
    Clean up task-scoped memories after task completion.
    Optionally archive to session scope before deletion.
    """
    task_dir = MEMORY_ROOT / "task" / task_id
    if not task_dir.exists():
        return 0
    
    archived_count = 0
    
    if archive:
        # Archive important entries to session scope
        for entry in list_scope("task", task_id):
            key = entry.get("key")
            importance = entry.get("metadata", {}).get("importance", 0.5)
            if importance >= 0.7:
                # Promote to session scope
                save("session", "default", f"{task_id}_{key}", entry.get("data"), {
                    "archived_from_task": task_id,
                    "original_key": key,
                    "archived_at": datetime.utcnow().isoformat()
                })
                archived_count += 1
    
    # Remove task directory
    import shutil
    shutil.rmtree(task_dir)
    
    return archived_count

if __name__ == "__main__":
    ensure_dirs()
    
    # Test: Save agent memory
    save("agent", "switch", "preferences", {"model": "kimi-k2.5", "fallback": "llama3.2"})
    print("✓ Saved agent preference")
    
    # Test: Save task memory
    save("task", "login-page", "requirements", {"fields": ["email", "password"]})
    print("✓ Saved task requirements")
    
    # Test: Save global memory
    save("global", "default", "system_config", {"version": "3.1", "debug": False})
    print("✓ Saved global config")
    
    # Test: Load
    loaded = load("agent", "switch", "preferences")
    print(f"✓ Loaded: {loaded['data']}")
    
    # Test: Resolve (task → agent → session → global)
    resolved = resolve_value("task", "login-page", "preferences", default={})
    print(f"✓ Resolved (task→agent→global): {resolved}")
    
    # Test: Search
    results = search("password")
    print(f"✓ Search found {len(results)} results")
    
    # Test: Load context for startup
    context = load_context_for_startup("switch", "sess-001", "login-page")
    print(f"✓ Startup context loaded: {sum(len(v) for v in context.values())} entries")
    
    # Test: Promote
    promote("task", "login-page", "requirements", "session", "sess-001")
    print("✓ Promoted task requirements to session scope")
    
    # Test: Garbage collect
    archived = garbage_collect_task("login-page", archive=True)
    print(f"✓ Garbage collected task (archived {archived} entries)")
