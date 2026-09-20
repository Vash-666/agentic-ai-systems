#!/usr/bin/env python3
"""
ARC (Addressable Recall Compaction) for v3.1
Triggered when context grows > 50KB
Compresses old context to pointers
Restores on demand
"""

import json
import hashlib
import os
import sys
import sqlite3
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional, List

# Resolve paths relative to script location
SCRIPT_DIR = Path(__file__).resolve().parent
MEMORY_DIR = (SCRIPT_DIR / ".." / ".." / "memory").resolve()
COMPACTION_DIR = MEMORY_DIR / "compacted"
STATE_DIR = (SCRIPT_DIR / ".." / ".." / "state").resolve()
STATE_FILE = STATE_DIR / "current.json"
DB_PATH = STATE_DIR / "state.db"

# Default configuration
DEFAULT_THRESHOLD_BYTES = 51200  # 50KB
DEFAULT_BATCH_SIZE = 0.1  # Compact 10% at a time
DEFAULT_MAX_CONTEXT_BYTES = 102400  # 100KB max before emergency compaction

class ARCCompaction:
    """Adaptive Replacement Cache compaction for context management"""
    
    def __init__(self, threshold_bytes: int = None, batch_size: float = None):
        self.threshold_bytes = threshold_bytes or int(os.environ.get("ARC_THRESHOLD_BYTES", DEFAULT_THRESHOLD_BYTES))
        self.batch_size = batch_size or float(os.environ.get("ARC_BATCH_SIZE", DEFAULT_BATCH_SIZE))
        self.compaction_dir = COMPACTION_DIR
        self.compaction_dir.mkdir(parents=True, exist_ok=True)
    
    def ensure_dir(self):
        self.compaction_dir.mkdir(parents=True, exist_ok=True)
    
    def generate_pointer(self, content: str) -> str:
        """Generate unique pointer for content"""
        return hashlib.sha256(content.encode()).hexdigest()[:16]
    
    def save_pointer_to_sqlite(self, pointer: str, summary: str, original_length: int, compacted_length: int, session_id: str = None) -> bool:
        """Save compaction pointer to SQLite for durability"""
        try:
            conn = sqlite3.connect(str(DB_PATH))
            cursor = conn.cursor()
            
            # Ensure compaction table exists
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS arc_pointers (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    pointer TEXT UNIQUE NOT NULL,
                    summary TEXT,
                    original_length INTEGER,
                    compacted_length INTEGER,
                    session_id TEXT,
                    created_at TEXT NOT NULL,
                    restored_at TEXT,
                    restore_count INTEGER DEFAULT 0
                )
            ''')
            
            cursor.execute('''
                INSERT OR REPLACE INTO arc_pointers 
                (pointer, summary, original_length, compacted_length, session_id, created_at, restore_count)
                VALUES (?, ?, ?, ?, ?, ?, COALESCE((SELECT restore_count FROM arc_pointers WHERE pointer = ?), 0))
            ''', (
                pointer,
                summary,
                original_length,
                compacted_length,
                session_id or "unknown",
                datetime.utcnow().isoformat(),
                pointer
            ))
            
            conn.commit()
            conn.close()
            return True
        except Exception as e:
            print(f"  ✗ SQLite save failed: {e}", file=sys.stderr)
            return False
    
    def get_pointer_from_sqlite(self, pointer: str) -> Optional[Dict]:
        """Retrieve pointer metadata from SQLite"""
        try:
            conn = sqlite3.connect(str(DB_PATH))
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT pointer, summary, original_length, compacted_length, session_id, created_at, restored_at, restore_count
                FROM arc_pointers WHERE pointer = ?
            ''', (pointer,))
            
            row = cursor.fetchone()
            conn.close()
            
            if row:
                return {
                    "pointer": row[0],
                    "summary": row[1],
                    "original_length": row[2],
                    "compacted_length": row[3],
                    "session_id": row[4],
                    "created_at": row[5],
                    "restored_at": row[6],
                    "restore_count": row[7]
                }
            return None
        except Exception:
            return None
    
    def update_restore_count(self, pointer: str) -> bool:
        """Update restore count when pointer is dereferenced"""
        try:
            conn = sqlite3.connect(str(DB_PATH))
            cursor = conn.cursor()
            
            cursor.execute('''
                UPDATE arc_pointers 
                SET restore_count = restore_count + 1, restored_at = ?
                WHERE pointer = ?
            ''', (datetime.utcnow().isoformat(), pointer))
            
            conn.commit()
            conn.close()
            return True
        except Exception:
            return False
    
    def compact_context(self, context_data: Dict, max_summary_length: int = 500, session_id: str = None) -> Dict:
        """
        Compact context into summary + pointers.
        Returns: {summary, pointers, original_length, compacted_length}
        """
        self.ensure_dir()
        
        original = json.dumps(context_data)
        original_length = len(original)
        
        # Extract key facts for summary
        facts = []
        if isinstance(context_data, dict):
            for key, value in context_data.items():
                if key.startswith("_") or key in ["agents", "tasks", "decisions"]:
                    continue
                if isinstance(value, str) and len(value) < 200:
                    facts.append(f"{key}: {value}")
                elif isinstance(value, (list, dict)):
                    facts.append(f"{key}: [{len(value)} items]")
        
        # Create summary
        summary = " | ".join(facts[:10])
        if len(summary) > max_summary_length:
            summary = summary[:max_summary_length] + "..."
        
        # Store full content with pointer
        pointer = self.generate_pointer(original)
        archive_path = self.compaction_dir / f"{pointer}.json"
        
        archive_entry = {
            "pointer": pointer,
            "timestamp": datetime.utcnow().isoformat(),
            "summary": summary,
            "original_length": original_length,
            "full_content": context_data
        }
        
        with open(archive_path, 'w') as f:
            json.dump(archive_entry, f, indent=2)
        
        # Save to SQLite for durability
        self.save_pointer_to_sqlite(pointer, summary, original_length, len(summary), session_id)
        
        compacted = {
            "_arc": True,
            "pointer": pointer,
            "summary": summary,
            "original_length": original_length,
            "compacted_length": len(summary),
            "compression_ratio": round(original_length / max(len(summary), 1), 2)
        }
        
        return compacted
    
    def dereference(self, pointer: str) -> Optional[Dict]:
        """Retrieve full content from pointer"""
        archive_path = self.compaction_dir / f"{pointer}.json"
        
        if not archive_path.exists():
            return None
        
        with open(archive_path) as f:
            entry = json.load(f)
        
        # Update restore count in SQLite
        self.update_restore_count(pointer)
        
        return entry["full_content"]
    
    def should_compact(self, context_data: Any) -> bool:
        """Check if context should be compacted"""
        return len(json.dumps(context_data)) > self.threshold_bytes
    
    def get_context_size(self, context_data: Any) -> int:
        """Get size of context in bytes"""
        return len(json.dumps(context_data))
    
    def select_items_to_compact(self, context_data: Dict, batch_size: float = None) -> List[str]:
        """
        Select which context items to compact using LRU + LFU hybrid.
        Returns list of keys to compact.
        """
        if not isinstance(context_data, dict):
            return []
        
        batch = batch_size or self.batch_size
        items = []
        
        for key, value in context_data.items():
            if key.startswith("_"):
                continue
            
            # Calculate score: lower = more likely to compact
            # Combine recency and frequency signals
            metadata = context_data.get(f"_{key}_meta", {})
            last_access = metadata.get("last_access", "1970-01-01T00:00:00")
            access_count = metadata.get("access_count", 0)
            
            try:
                age = datetime.utcnow() - datetime.fromisoformat(last_access.replace('Z', '+00:00').replace('+00:00', ''))
                age_hours = age.total_seconds() / 3600
            except:
                age_hours = 9999
            
            # LRU score (older = higher score = compact first)
            lru_score = age_hours
            
            # LFU score (less frequent = higher score = compact first)
            lfu_score = 1.0 / max(access_count, 1)
            
            # Combined score
            combined_score = lru_score * 0.7 + lfu_score * 0.3
            
            items.append((key, combined_score, len(json.dumps(value))))
        
        # Sort by score descending (compact highest score first)
        items.sort(key=lambda x: x[1], reverse=True)
        
        # Select batch
        total_size = sum(item[2] for item in items)
        target_size = total_size * batch
        
        selected = []
        current_size = 0
        for key, score, size in items:
            if current_size >= target_size:
                break
            selected.append(key)
            current_size += size
        
        return selected
    
    def compact_state_file(self, state_file: Path = STATE_FILE) -> Dict:
        """
        Compact the state file if it exceeds threshold.
        Returns compaction report.
        """
        if not state_file.exists():
            return {"compacted": False, "reason": "state_file_not_found"}
        
        try:
            with open(state_file) as f:
                state = json.load(f)
        except (json.JSONDecodeError, IOError) as e:
            return {"compacted": False, "reason": f"read_error: {e}"}
        
        state_size = self.get_context_size(state)
        
        if state_size <= self.threshold_bytes:
            return {
                "compacted": False,
                "reason": "below_threshold",
                "size_bytes": state_size,
                "threshold_bytes": self.threshold_bytes
            }
        
        # Select items to compact
        keys_to_compact = self.select_items_to_compact(state)
        
        if not keys_to_compact:
            return {"compacted": False, "reason": "no_items_selected"}
        
        compacted_count = 0
        total_savings = 0
        
        for key in keys_to_compact:
            if key not in state:
                continue
            
            value = state[key]
            original_size = len(json.dumps(value))
            
            # Compact the value with session context
            session_id = state.get("session", {}).get("id", "unknown")
            compacted = self.compact_context(value, session_id=session_id)
            state[key] = compacted
            
            compacted_count += 1
            total_savings += original_size - compacted["compacted_length"]
        
        # Save compacted state
        state["_arc_meta"] = {
            "compacted_at": datetime.utcnow().isoformat(),
            "compacted_keys": keys_to_compact,
            "original_size": state_size,
            "compaction_version": "3.1"
        }
        
        try:
            with open(state_file, 'w') as f:
                json.dump(state, f, indent=2)
        except IOError as e:
            return {"compacted": False, "reason": f"write_error: {e}"}
        
        new_size = self.get_context_size(state)
        
        return {
            "compacted": True,
            "keys_compacted": keys_to_compact,
            "compacted_count": compacted_count,
            "original_size": state_size,
            "new_size": new_size,
            "savings_bytes": total_savings,
            "compression_ratio": round(state_size / max(new_size, 1), 2)
        }
    
    def restore_from_pointer(self, pointer: str, state_file: Path = STATE_FILE) -> bool:
        """
        Restore compacted content back into state file.
        Finds the key with this pointer and replaces with full content.
        """
        full_content = self.dereference(pointer)
        if not full_content:
            return False
        
        if not state_file.exists():
            return False
        
        try:
            with open(state_file) as f:
                state = json.load(f)
        except (json.JSONDecodeError, IOError):
            return False
        
        # Find key with this pointer
        restored = False
        for key, value in state.items():
            if isinstance(value, dict) and value.get("_arc") and value.get("pointer") == pointer:
                state[key] = full_content
                restored = True
                
                # Update metadata
                meta_key = f"_{key}_meta"
                if meta_key not in state:
                    state[meta_key] = {}
                state[meta_key]["last_access"] = datetime.utcnow().isoformat()
                state[meta_key]["access_count"] = state[meta_key].get("access_count", 0) + 1
        
        if restored:
            with open(state_file, 'w') as f:
                json.dump(state, f, indent=2)
        
        return restored
    
    def restore_all_compacted(self, state_file: Path = STATE_FILE) -> Dict:
        """
        Restore all compacted pointers in a state file.
        Returns report of what was restored.
        """
        if not state_file.exists():
            return {"restored": False, "reason": "state_file_not_found"}
        
        try:
            with open(state_file) as f:
                state = json.load(f)
        except (json.JSONDecodeError, IOError) as e:
            return {"restored": False, "reason": f"read_error: {e}"}
        
        restored_keys = []
        failed_pointers = []
        
        for key, value in list(state.items()):
            if isinstance(value, dict) and value.get("_arc") and value.get("pointer"):
                pointer = value["pointer"]
                full_content = self.dereference(pointer)
                
                if full_content:
                    state[key] = full_content
                    restored_keys.append(key)
                else:
                    failed_pointers.append(pointer)
        
        # Remove arc meta if all restored
        if restored_keys and not any(isinstance(v, dict) and v.get("_arc") for v in state.values()):
            state.pop("_arc_meta", None)
        
        try:
            with open(state_file, 'w') as f:
                json.dump(state, f, indent=2)
        except IOError as e:
            return {"restored": False, "reason": f"write_error: {e}"}
        
        return {
            "restored": len(restored_keys) > 0,
            "restored_keys": restored_keys,
            "restored_count": len(restored_keys),
            "failed_pointers": failed_pointers,
            "failed_count": len(failed_pointers)
        }
    
    def monitor_and_compact(self, state_file: Path = STATE_FILE) -> Dict:
        """
        Monitor context size and compact if needed.
        Safe to call periodically — only compacts when threshold exceeded.
        """
        if not state_file.exists():
            return {"action": "none", "reason": "no_state_file"}
        
        try:
            with open(state_file) as f:
                state = json.load(f)
        except (json.JSONDecodeError, IOError) as e:
            return {"action": "none", "reason": f"read_error: {e}"}
        
        state_size = self.get_context_size(state)
        
        # Emergency compaction if way over limit
        max_size = int(os.environ.get("ARC_MAX_CONTEXT_BYTES", DEFAULT_MAX_CONTEXT_BYTES))
        if state_size > max_size:
            # Compact more aggressively
            old_batch = self.batch_size
            self.batch_size = 0.3  # Compact 30%
            result = self.compact_state_file(state_file)
            self.batch_size = old_batch
            result["emergency"] = True
            return result
        
        # Normal compaction
        if state_size > self.threshold_bytes:
            return self.compact_state_file(state_file)
        
        return {
            "action": "none",
            "size_bytes": state_size,
            "threshold_bytes": self.threshold_bytes,
            "status": "healthy"
        }


def compact_if_needed(state_file: Path = None, threshold_bytes: int = None) -> Dict:
    """Simple wrapper to check and compact if needed"""
    state_file = state_file or STATE_FILE
    arc = ARCCompaction(threshold_bytes=threshold_bytes)
    return arc.monitor_and_compact(state_file)


def restore_pointer(pointer: str, state_file: Path = None) -> bool:
    """Restore a compacted pointer back to full content"""
    state_file = state_file or STATE_FILE
    arc = ARCCompaction()
    return arc.restore_from_pointer(pointer, state_file)


def restore_all(state_file: Path = None) -> Dict:
    """Restore all compacted pointers in state file"""
    state_file = state_file or STATE_FILE
    arc = ARCCompaction()
    return arc.restore_all_compacted(state_file)


def get_context_size(state_file: Path = None) -> int:
    """Get current context size in bytes"""
    state_file = state_file or STATE_FILE
    if not state_file.exists():
        return 0
    
    try:
        with open(state_file) as f:
            state = json.load(f)
        return len(json.dumps(state))
    except:
        return 0


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
    
    arc = ARCCompaction(threshold_bytes=1000)  # Low threshold for testing
    
    # Test compact_context
    compacted = arc.compact_context(large_context)
    print(f"✓ Compacted: {compacted['compacted_length']} bytes")
    print(f"✓ Compression: {compacted['compression_ratio']}x")
    print(f"✓ Pointer: {compacted['pointer']}")
    
    # Test dereference
    restored = arc.dereference(compacted['pointer'])
    print(f"✓ Restored: {len(json.dumps(restored))} bytes")
    print(f"✓ Match: {restored == large_context}")
    
    # Test monitor_and_compact with state file
    test_state_file = STATE_DIR / "test_arc_state.json"
    with open(test_state_file, 'w') as f:
        json.dump(large_context, f)
    
    result = arc.monitor_and_compact(test_state_file)
    print(f"\n✓ Monitor and compact:")
    print(f"  Compacted: {result.get('compacted', False)}")
    if result.get('compacted'):
        print(f"  Keys: {result.get('keys_compacted')}")
        print(f"  Savings: {result.get('savings_bytes')} bytes")
    
    # Cleanup
    test_state_file.unlink(missing_ok=True)
