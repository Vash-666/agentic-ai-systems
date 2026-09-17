#!/usr/bin/env python3
"""
Scoped Memory Hierarchy for v3.0
CrewAI-style /project/agent/task memory paths
"""

import json
import os
from pathlib import Path
from datetime import datetime

MEMORY_ROOT = Path("/Users/rohitvashist/.openclaw/workspace/v3/memory/scoped")

def ensure_dirs():
    """Create scoped memory directories"""
    for scope in ["project", "agent", "task", "global"]:
        (MEMORY_ROOT / scope).mkdir(parents=True, exist_ok=True)
    print(f"✓ Scoped memory directories created at {MEMORY_ROOT}")

def memory_path(scope, scope_id, key):
    """Get file path for a scoped memory entry"""
    return MEMORY_ROOT / scope / scope_id / f"{key}.json"

def save(scope, scope_id, key, data):
    """Save data to scoped memory"""
    path = memory_path(scope, scope_id, key)
    path.parent.mkdir(parents=True, exist_ok=True)
    
    entry = {
        "timestamp": datetime.utcnow().isoformat(),
        "scope": f"{scope}/{scope_id}",
        "key": key,
        "data": data
    }
    
    with open(path, 'w') as f:
        json.dump(entry, f, indent=2)
    
    return path

def load(scope, scope_id, key):
    """Load data from scoped memory"""
    path = memory_path(scope, scope_id, key)
    if not path.exists():
        return None
    
    with open(path) as f:
        return json.load(f)

def list_scope(scope, scope_id=None):
    """List all entries in a scope"""
    base = MEMORY_ROOT / scope
    if scope_id:
        base = base / scope_id
    
    if not base.exists():
        return []
    
    entries = []
    for path in base.rglob("*.json"):
        with open(path) as f:
            entries.append(json.load(f))
    return entries

def search(query, scope=None):
    """Simple keyword search across scoped memory"""
    results = []
    search_root = MEMORY_ROOT / scope if scope else MEMORY_ROOT
    
    if not search_root.exists():
        return results
    
    for path in search_root.rglob("*.json"):
        with open(path) as f:
            entry = json.load(f)
            if query.lower() in json.dumps(entry).lower():
                results.append(entry)
    
    return results

if __name__ == "__main__":
    ensure_dirs()
    
    # Test: Save agent memory
    save("agent", "switch", "preferences", {"model": "kimi-k2.5", "fallback": "llama3.2"})
    print("✓ Saved agent preference")
    
    # Test: Save task memory
    save("task", "login-page", "requirements", {"fields": ["email", "password"]})
    print("✓ Saved task requirements")
    
    # Test: Load
    loaded = load("agent", "switch", "preferences")
    print(f"✓ Loaded: {loaded['data']}")
    
    # Test: Search
    results = search("password")
    print(f"✓ Search found {len(results)} results")
