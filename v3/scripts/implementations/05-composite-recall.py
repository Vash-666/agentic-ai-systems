#!/usr/bin/env python3
"""
Composite Recall Scoring for v3.1
Wired to memory retrieval in session-startup.sh
Ranks memories by semantic + recency + importance
Loads top N relevant memories on startup
"""

import json
import math
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Any, Optional

# Resolve paths relative to script location
SCRIPT_DIR = Path(__file__).resolve().parent
MEMORY_DIR = (SCRIPT_DIR / ".." / ".." / "memory").resolve()
FACTS_JSONL = MEMORY_DIR / "facts.jsonl"
STRATEGIC_FILE = MEMORY_DIR / "STRATEGIC.md"

class CompositeRecall:
    """Memory retrieval with weighted scoring across multiple modalities"""
    
    def __init__(self, weights=None):
        self.weights = weights or {
            "semantic": 0.5,
            "recency": 0.3,
            "importance": 0.2
        }
    
    def semantic_similarity(self, query: str, memory_text: str) -> float:
        """Keyword-based similarity (placeholder for embeddings)"""
        query_words = set(query.lower().split())
        memory_words = set(memory_text.lower().split())
        
        if not query_words or not memory_words:
            return 0.0
        
        intersection = query_words & memory_words
        union = query_words | memory_words
        
        return len(intersection) / len(union)
    
    def keyword_match(self, query: str, memory_text: str) -> float:
        """Exact and fuzzy keyword matching"""
        query_lower = query.lower()
        text_lower = memory_text.lower()
        
        # Exact phrase match
        if query_lower in text_lower:
            return 1.0
        
        # Word-level match
        query_words = query_lower.split()
        text_words = text_lower.split()
        
        matches = sum(1 for w in query_words if w in text_words)
        return matches / len(query_words) if query_words else 0.0
    
    def recency_score(self, timestamp_str: str) -> float:
        """Score based on how recent the memory is (exponential decay)"""
        try:
            # Handle various timestamp formats
            timestamp_str = timestamp_str.replace('Z', '+00:00')
            memory_time = datetime.fromisoformat(timestamp_str)
            # Ensure naive datetime for comparison
            if memory_time.tzinfo:
                memory_time = memory_time.replace(tzinfo=None)
            
            age = datetime.utcnow() - memory_time
            
            # Exponential decay: 1.0 (now) → 0.0 (30 days)
            half_life = timedelta(days=7)
            score = math.exp(-age / half_life)
            return max(0.0, min(1.0, score))
        except (ValueError, TypeError):
            return 0.5  # Unknown age = middle score
    
    def importance_score(self, importance_val) -> float:
        """Normalize importance to 0-1"""
        if isinstance(importance_val, (int, float)):
            return min(max(float(importance_val), 0.0), 1.0)
        return 0.5
    
    def score_memory(self, query: str, memory: Dict) -> Dict:
        """Calculate composite score for a memory"""
        memory_text = json.dumps(memory)
        
        semantic = self.semantic_similarity(query, memory_text)
        keyword = self.keyword_match(query, memory_text)
        
        # Combine semantic and keyword (keyword is more precise)
        combined_semantic = max(semantic, keyword * 0.8)
        
        timestamp = memory.get("timestamp", memory.get("stored_at", ""))
        recency = self.recency_score(timestamp)
        
        importance = self.importance_score(memory.get("importance", 0.5))
        
        composite = (
            combined_semantic * self.weights["semantic"] +
            recency * self.weights["recency"] +
            importance * self.weights["importance"]
        )
        
        return {
            "score": round(composite, 3),
            "breakdown": {
                "semantic": round(semantic, 3),
                "keyword": round(keyword, 3),
                "recency": round(recency, 3),
                "importance": round(importance, 3)
            },
            "memory": memory
        }
    
    def search(self, query: str, memories: List[Dict], top_k: int = 5) -> List[Dict]:
        """Search and rank memories by composite score"""
        if not memories:
            return []
        
        scored = [self.score_memory(query, m) for m in memories]
        scored.sort(key=lambda x: x["score"], reverse=True)
        return scored[:top_k]
    
    def recall(self, query: str, top_k: int = 5, 
               scope: Optional[str] = None, scope_id: Optional[str] = None) -> List[Dict]:
        """
        Main recall entry point. Loads memories from all sources and ranks them.
        Falls back to simple search if composite fails.
        """
        try:
            memories = self.load_all_memories(scope, scope_id)
            return self.search(query, memories, top_k)
        except Exception as e:
            # Fallback to simple search
            print(f"⚠ Composite recall failed: {e}. Falling back to simple search.", file=sys.stderr)
            return self._simple_search(query, scope, scope_id, top_k)
    
    def load_all_memories(self, scope: Optional[str] = None, 
                          scope_id: Optional[str] = None) -> List[Dict]:
        """Load memories from all available sources"""
        memories = []
        
        # Load from facts.jsonl
        if FACTS_JSONL.exists():
            try:
                with open(FACTS_JSONL) as f:
                    for line in f:
                        line = line.strip()
                        if line:
                            memories.append(json.loads(line))
            except (json.JSONDecodeError, IOError):
                pass
        
        # Load from daily fact files
        daily_dir = MEMORY_DIR / "daily"
        if daily_dir.exists():
            for fact_file in daily_dir.glob("*-facts.json"):
                try:
                    with open(fact_file) as f:
                        daily_facts = json.load(f)
                        if isinstance(daily_facts, list):
                            memories.extend(daily_facts)
                except (json.JSONDecodeError, IOError):
                    pass
        
        # Load from scoped memory if available
        scoped_dir = MEMORY_DIR / "scoped"
        if scoped_dir.exists():
            for scope_dir in scoped_dir.rglob("*.json"):
                try:
                    with open(scope_dir) as f:
                        entry = json.load(f)
                        if isinstance(entry, dict) and "data" in entry:
                            memories.append(entry)
                except (json.JSONDecodeError, IOError):
                    pass
        
        # Filter by scope if specified
        if scope:
            memories = [m for m in memories if m.get("scope") == scope or m.get("metadata", {}).get("scope") == scope]
        
        return memories
    
    def _simple_search(self, query: str, scope: Optional[str], 
                       scope_id: Optional[str], top_k: int) -> List[Dict]:
        """Fallback simple keyword search"""
        memories = self.load_all_memories(scope, scope_id)
        query_lower = query.lower()
        
        results = []
        for memory in memories:
            text = json.dumps(memory).lower()
            if query_lower in text:
                results.append({
                    "score": 0.5,
                    "breakdown": {"fallback": True},
                    "memory": memory
                })
        
        return results[:top_k]
    
    def get_startup_memories(self, agent_name: str = "switch", 
                             session_id: str = None,
                             top_k: int = 10) -> List[Dict]:
        """
        Load top N relevant memories for session startup.
        Uses agent identity and recent context as implicit query.
        """
        # Build implicit query from agent context
        query_parts = [agent_name, "preferences", "configuration"]
        if session_id:
            query_parts.append(session_id)
        
        implicit_query = " ".join(query_parts)
        
        return self.recall(implicit_query, top_k=top_k)


def recall_for_startup(agent_name: str = "switch", session_id: str = None,
                       top_k: int = 10, weights: Dict = None) -> List[Dict]:
    """
    Load top N relevant memories during session startup.
    Called by session-startup.sh to inject relevant context.
    """
    recall = CompositeRecall(weights=weights)
    memories = recall.get_startup_memories(agent_name, session_id, top_k)
    
    print(f"✓ Composite recall loaded {len(memories)} relevant memories for @{agent_name}")
    for m in memories[:3]:
        mem = m["memory"]
        content = mem.get("content", mem.get("subject", str(mem)[:50]))
        print(f"  [{m['score']}] {content[:60]}...")
    
    return memories


def score_relevance(memories: List[Dict], query: str = None, top_k: int = 3) -> List[Dict]:
    """
    Rank a list of memories by composite relevance score.
    Uses semantic + recency + importance weighting.
    If no query provided, uses a generic startup query based on memory content.
    """
    recall_engine = CompositeRecall()
    
    # Build implicit query from memory content if none provided
    if not query:
        # Extract common themes from memories for implicit query
        query = "preferences configuration system agent"
    
    scored = [recall_engine.score_memory(query, m) for m in memories]
    scored.sort(key=lambda x: x["score"], reverse=True)
    return scored[:top_k]


def rank_daily_memories(daily_facts_files: List[str], query: str = None, top_k: int = 3) -> List[Dict]:
    """
    Load daily fact files and rank memories by composite score.
    Called by session-startup.sh Step 7.
    """
    all_memories = []
    
    for facts_file in daily_facts_files:
        try:
            with open(facts_file) as f:
                facts = json.load(f)
                if isinstance(facts, list):
                    all_memories.extend(facts)
        except (json.JSONDecodeError, IOError) as e:
            print(f"  ⚠ Failed to load {facts_file}: {e}", file=sys.stderr)
            continue
    
    if not all_memories:
        return []
    
    ranked = score_relevance(all_memories, query=query, top_k=top_k)
    
    print(f"✓ Composite recall ranked {len(all_memories)} memories, top {len(ranked)}:")
    for i, m in enumerate(ranked, 1):
        mem = m["memory"]
        content = mem.get("content", mem.get("subject", str(mem)[:50]))
        print(f"  [{i}] Score: {m['score']} — {content[:70]}...")
        print(f"      semantic={m['breakdown']['semantic']}, recency={m['breakdown']['recency']}, importance={m['breakdown']['importance']}")
    
    return ranked


def recall(query: str, top_k: int = 5, weights: Dict = None) -> List[Dict]:
    """Simple recall wrapper for general use"""
    recall_engine = CompositeRecall(weights=weights)
    return recall_engine.recall(query, top_k)


if __name__ == "__main__":
    # Test with sample memories
    memories = [
        {
            "timestamp": datetime.utcnow().isoformat(),
            "importance": 0.9,
            "content": "User prefers concise responses and direct communication"
        },
        {
            "timestamp": (datetime.utcnow() - timedelta(days=10)).isoformat(),
            "importance": 0.7,
            "content": "System uses three-tier model switching protocol"
        },
        {
            "timestamp": (datetime.utcnow() - timedelta(days=1)).isoformat(),
            "importance": 0.5,
            "content": "GitHub repository updated with v3.0 features"
        }
    ]
    
    recall_engine = CompositeRecall()
    results = recall_engine.search("user preferences", memories)
    
    print("✓ Composite recall test")
    for r in results:
        print(f"  Score: {r['score']} — {r['memory']['content'][:50]}...")
        print(f"    Breakdown: {r['breakdown']}")
    
    # Test startup recall
    print("\n✓ Testing startup recall...")
    startup_memories = recall_for_startup("switch", "sess-001", top_k=3)
    print(f"  Loaded {len(startup_memories)} memories for startup")
