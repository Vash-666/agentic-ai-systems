#!/usr/bin/env python3
"""
Composite Recall Scoring for v3.0
Weighted combination of semantic similarity + recency + importance
"""

import json
import math
from datetime import datetime, timedelta
from pathlib import Path

class CompositeRecall:
    """Memory retrieval with weighted scoring"""
    
    def __init__(self, weights=None):
        self.weights = weights or {
            "semantic": 0.5,
            "recency": 0.3,
            "importance": 0.2
        }
    
    def semantic_similarity(self, query, memory_text):
        """Simple keyword-based similarity (placeholder for embeddings)"""
        query_words = set(query.lower().split())
        memory_words = set(memory_text.lower().split())
        
        if not query_words or not memory_words:
            return 0.0
        
        intersection = query_words & memory_words
        union = query_words | memory_words
        
        return len(intersection) / len(union)
    
    def recency_score(self, timestamp_str):
        """Score based on how recent the memory is"""
        try:
            memory_time = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
            age = datetime.utcnow() - memory_time
            
            # Exponential decay: 1.0 (now) → 0.0 (30 days)
            half_life = timedelta(days=7)
            return math.exp(-age / half_life)
        except:
            return 0.5  # Unknown age = middle score
    
    def importance_score(self, importance_val):
        """Normalize importance to 0-1"""
        if isinstance(importance_val, (int, float)):
            return min(max(importance_val, 0.0), 1.0)
        return 0.5
    
    def score_memory(self, query, memory):
        """Calculate composite score for a memory"""
        memory_text = json.dumps(memory)
        
        semantic = self.semantic_similarity(query, memory_text)
        
        timestamp = memory.get("timestamp", "")
        recency = self.recency_score(timestamp)
        
        importance = self.importance_score(memory.get("importance", 0.5))
        
        composite = (
            semantic * self.weights["semantic"] +
            recency * self.weights["recency"] +
            importance * self.weights["importance"]
        )
        
        return {
            "score": round(composite, 3),
            "breakdown": {
                "semantic": round(semantic, 3),
                "recency": round(recency, 3),
                "importance": round(importance, 3)
            },
            "memory": memory
        }
    
    def search(self, query, memories, top_k=5):
        """Search and rank memories by composite score"""
        scored = [self.score_memory(query, m) for m in memories]
        scored.sort(key=lambda x: x["score"], reverse=True)
        return scored[:top_k]

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
    
    recall = CompositeRecall()
    results = recall.search("user preferences", memories)
    
    print("✓ Composite recall test")
    for r in results:
        print(f"  Score: {r['score']} — {r['memory']['content'][:50]}...")
        print(f"    Breakdown: {r['breakdown']}")
