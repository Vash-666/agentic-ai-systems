#!/usr/bin/env python3
"""
ARC (Addressable Recall Compaction) for v3.0
Pointer-based summaries to reduce context bloat
"""

import json
import hashlib
from datetime import datetime
from pathlib import Path

COMPACTION_DIR = Path("/Users/rohitvashist/.openclaw/workspace/v3/memory/compacted")

def ensure_dir():
    COMPACTION_DIR.mkdir(parents=True, exist_ok=True)

def generate_pointer(content):
    """Generate unique pointer for content"""
    return hashlib.sha256(content.encode()).hexdigest()[:16]

def compact_context(context_data, max_summary_length=500):
    """
    Compact context into summary + pointers
    Returns: {summary, pointers, original_length, compacted_length}
    """
    ensure_dir()
    
    original = json.dumps(context_data)
    original_length = len(original)
    
    # Extract key facts for summary
    facts = []
    if isinstance(context_data, dict):
        for key, value in context_data.items():
            if isinstance(value, str) and len(value) < 200:
                facts.append(f"{key}: {value}")
            elif isinstance(value, (list, dict)):
                facts.append(f"{key}: [{len(value)} items]")
    
    # Create summary
    summary = " | ".join(facts[:10])  # Top 10 facts
    if len(summary) > max_summary_length:
        summary = summary[:max_summary_length] + "..."
    
    # Store full content with pointer
    pointer = generate_pointer(original)
    archive_path = COMPACTION_DIR / f"{pointer}.json"
    
    archive_entry = {
        "pointer": pointer,
        "timestamp": datetime.utcnow().isoformat(),
        "summary": summary,
        "original_length": original_length,
        "full_content": context_data
    }
    
    with open(archive_path, 'w') as f:
        json.dump(archive_entry, f, indent=2)
    
    compacted = {
        "_arc": True,
        "pointer": pointer,
        "summary": summary,
        "original_length": original_length,
        "compacted_length": len(summary),
        "compression_ratio": round(original_length / max(len(summary), 1), 2)
    }
    
    return compacted

def dereference(pointer):
    """Retrieve full content from pointer"""
    archive_path = COMPACTION_DIR / f"{pointer}.json"
    
    if not archive_path.exists():
        return None
    
    with open(archive_path) as f:
        entry = json.load(f)
    
    return entry["full_content"]

def should_compact(context_data, threshold_bytes=2000):
    """Check if context should be compacted"""
    return len(json.dumps(context_data)) > threshold_bytes

if __name__ == "__main__":
    # Test with large context
    large_context = {
        "session_id": "sess-001",
        "agents": {
            "switch": {"status": "active", "model": "kimi", "tasks": 5},
            "quality": {"status": "idle", "model": "claude", "tasks": 0},
            "content": {"status": "working", "model": "gemini", "tasks": 2}
        },
        "tasks": [
            {"id": "t1", "desc": "Implement feature A", "status": "done"},
            {"id": "t2", "desc": "Implement feature B", "status": "in_progress"},
            {"id": "t3", "desc": "Test everything", "status": "pending"}
        ],
        "decisions": [
            {"id": "d1", "choice": "Use SQLite", "reason": "ACID guarantees"},
            {"id": "d2", "choice": "Add reducers", "reason": "Prevent conflicts"}
        ],
        "history": [f"Event {i}: something happened" for i in range(50)]
    }
    
    print(f"Original size: {len(json.dumps(large_context))} bytes")
    
    compacted = compact_context(large_context)
    print(f"✓ Compacted: {compacted['compacted_length']} bytes")
    print(f"✓ Compression: {compacted['compression_ratio']}x")
    print(f"✓ Pointer: {compacted['pointer']}")
    
    # Test dereference
    restored = dereference(compacted['pointer'])
    print(f"✓ Restored: {len(json.dumps(restored))} bytes")
    print(f"✓ Match: {restored == large_context}")
