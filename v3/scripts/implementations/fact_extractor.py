#!/usr/bin/env python3
"""
Automatic Fact Extraction for v3.0
Extracts key facts from agent outputs and stores them in memory
"""

import json
import re
from pathlib import Path
from datetime import datetime

MEMORY_FILE = Path("/Users/rohitvashist/.openclaw/workspace/v3/memory/STRATEGIC.md")

def extract_facts(text, source="unknown", min_importance=0.5):
    """Extract facts from text using simple heuristics"""
    facts = []
    
    # Pattern 1: "X is Y" statements
    is_pattern = re.findall(r'([A-Z][^.]+) is ([^.]+)', text)
    for subject, predicate in is_pattern:
        facts.append({
            "type": "is_a",
            "subject": subject.strip(),
            "predicate": predicate.strip(),
            "importance": 0.7,
            "source": source
        })
    
    # Pattern 2: Decisions ("decided to", "chose", "opted for")
    decision_pattern = re.findall(r'(?:decided|chose|opted) to ([^.]+)', text, re.IGNORECASE)
    for decision in decision_pattern:
        facts.append({
            "type": "decision",
            "content": decision.strip(),
            "importance": 0.9,
            "source": source
        })
    
    # Pattern 3: Numbers/metrics
    metric_pattern = re.findall(r'(\d+(?:\.\d+)?)\s*(%|/10|minutes?|hours?|days?)', text)
    for value, unit in metric_pattern:
        facts.append({
            "type": "metric",
            "value": value,
            "unit": unit,
            "importance": 0.8,
            "source": source
        })
    
    # Pattern 4: Preferences ("prefer", "like", "want")
    pref_pattern = re.findall(r'(?:prefer|likes?|wants?)\s+([^.]+)', text, re.IGNORECASE)
    for preference in pref_pattern:
        facts.append({
            "type": "preference",
            "content": preference.strip(),
            "importance": 0.6,
            "source": source
        })
    
    # Filter by importance
    return [f for f in facts if f["importance"] >= min_importance]

def store_facts(facts, agent_name="system"):
    """Store extracted facts to memory"""
    timestamp = datetime.utcnow().isoformat()
    
    entry = f"\n## Auto-Extracted Facts — {timestamp}\n\n"
    entry += f"**Source:** {agent_name}\n\n"
    
    for fact in facts:
        entry += f"- [{fact['type'].upper()}] "
        if "subject" in fact:
            entry += f"{fact['subject']} is {fact['predicate']}"
        elif "content" in fact:
            entry += fact["content"]
        elif "value" in fact:
            entry += f"{fact['value']}{fact['unit']}"
        entry += f" (importance: {fact['importance']})\n"
    
    # Append to memory file
    with open(MEMORY_FILE, 'a') as f:
        f.write(entry)
    
    return len(facts)

def process_agent_output(output_text, agent_name):
    """Main entry: process agent output and extract facts"""
    facts = extract_facts(output_text, source=agent_name)
    if facts:
        count = store_facts(facts, agent_name)
        print(f"✓ Extracted and stored {count} facts from {agent_name}")
        return count
    print(f"✓ No facts extracted from {agent_name}")
    return 0

if __name__ == "__main__":
    # Test with sample output
    sample = """
    We decided to use SQLite for state persistence. 
    The system quality is 9.0/10. 
    User prefers concise responses.
    The model routing achieved 88% cost savings.
    """
    
    count = process_agent_output(sample, "@switch")
    print(f"✓ Fact extraction test complete: {count} facts")
