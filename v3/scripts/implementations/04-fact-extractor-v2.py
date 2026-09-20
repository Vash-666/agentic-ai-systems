#!/usr/bin/env python3
"""
Automatic Fact Extraction v2.1 for v3.1
Wired to trigger after agent tasks complete
Extracts facts from agent output
Saves to memory/daily/ and memory/STRATEGIC.md
"""

import json
import re
import os
import sys
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any, Optional

# Resolve paths relative to script location
SCRIPT_DIR = Path(__file__).resolve().parent
MEMORY_DIR = (SCRIPT_DIR / ".." / ".." / "memory").resolve()
STRATEGIC_FILE = MEMORY_DIR / "STRATEGIC.md"
FACTS_JSONL = MEMORY_DIR / "facts.jsonl"
DAILY_DIR = MEMORY_DIR / "daily"

# Rate limiting: max 1 extraction per 30 seconds per agent
RATE_LIMIT_SECONDS = 30
_rate_limit_cache: Dict[str, datetime] = {}

class FactExtractor:
    """Extracts structured facts from agent outputs with confidence scoring"""
    
    def __init__(self, min_confidence=0.6, auto_trigger=True):
        self.min_confidence = min_confidence
        self.auto_trigger = auto_trigger
        self.facts: List[Dict[str, Any]] = []
        
        # Compiled regex patterns for performance
        self.patterns = {
            'decision': re.compile(
                r'(?:we\s+)?(?:decided|chose|opted|agreed|resolved)\s+(?:to|on|for)\s+([^.]{10,200})',
                re.IGNORECASE
            ),
            'metric': re.compile(
                r'(\d+(?:\.\d+)?)\s*(%|percent|/10|minutes?|hours?|days?|weeks?|months?|years?|KB|MB|GB|seconds?|ms|fps|x|times?)\b',
                re.IGNORECASE
            ),
            'preference': re.compile(
                r'(?:user|agent|system|we)\s+(?:prefers?|likes?|wants?|needs?|requires?|favors?)\s+([^.]{5,150})',
                re.IGNORECASE
            ),
            'definition': re.compile(
                r'([A-Z][a-zA-Z\s]{2,30})\s+(?:is|are|refers? to|means?|defines?)\s+([^.]{10,300})',
                re.IGNORECASE
            ),
            'achievement': re.compile(
                r'(?:achieved|reached|completed|finished|delivered|shipped|deployed)\s+([^.]{10,200})',
                re.IGNORECASE
            ),
            'constraint': re.compile(
                r'(?:must|should|needs? to|required to|has to)\s+([^.]{10,200})',
                re.IGNORECASE
            ),
        }
    
    def _calculate_confidence(self, fact_type: str, match_text: str, context: str) -> float:
        """Calculate confidence score based on multiple signals"""
        confidence = 0.6
        
        # Signal 1: Length appropriateness
        text_len = len(match_text)
        if 20 <= text_len <= 150:
            confidence += 0.15
        elif 10 <= text_len < 20:
            confidence += 0.1
        elif 3 <= text_len < 10:
            confidence += 0.05
        
        # Signal 2: Contains specific entities
        if re.search(r'\d+\.\d+|v\d+|\b[A-Z][a-z]+\s+[A-Z][a-z]+\b', match_text):
            confidence += 0.1
        
        # Signal 3: Clear sentence boundaries
        if text_len >= 10 and match_text[0].isupper() and not match_text.endswith(('and', 'or', 'but')):
            confidence += 0.05
        
        # Signal 4: Fact type specific boosts
        if fact_type == 'metric':
            if re.match(r'^\d+(\.\d+)?\s*\w+$', match_text):
                confidence += 0.2
            elif re.match(r'^\d+(\.\d+)?$', match_text.split()[0]):
                confidence += 0.15
        elif fact_type == 'decision' and any(w in match_text.lower() for w in ['use', 'implement', 'adopt', 'choose']):
            confidence += 0.1
        
        # Signal 5: Context quality
        if len(context) > 50:
            confidence += 0.05
        
        return min(confidence, 1.0)
    
    def _filter_false_positives(self, facts: List[Dict]) -> List[Dict]:
        """Remove likely false positives"""
        filtered = []
        
        for fact in facts:
            if 'content' in fact:
                text = fact['content']
            elif 'subject' in fact and 'predicate' in fact:
                text = f"{fact['subject']} {fact['predicate']}"
            elif 'value' in fact and 'unit' in fact:
                text = f"{fact['value']}{fact['unit']}"
            else:
                text = str(fact)
            
            if fact.get('type') == 'metric':
                if len(text) < 2 or len(text) > 50:
                    continue
            elif len(text) < 10 or len(text) > 300:
                continue
            
            if sum(c.isalpha() or c.isspace() for c in text) < len(text) * 0.5:
                continue
            
            false_patterns = [
                r'^\d+$',
                r'^(this|that|these|those|it|they)\s',
                r'^(is|are|was|were|be|been)\s',
            ]
            
            if any(re.match(p, text, re.IGNORECASE) for p in false_patterns):
                continue
            
            filtered.append(fact)
        
        return filtered
    
    def extract(self, text: str, source: str = "unknown", task_id: str = None) -> List[Dict[str, Any]]:
        """Extract facts from text"""
        self.facts = []
        
        # Extract decisions
        for match in self.patterns['decision'].finditer(text):
            content = match.group(1).strip()
            confidence = self._calculate_confidence('decision', content, text)
            if confidence >= self.min_confidence:
                self.facts.append({
                    "type": "decision",
                    "content": content,
                    "confidence": round(confidence, 2),
                    "importance": 0.9,
                    "source": source,
                    "task_id": task_id,
                    "timestamp": datetime.utcnow().isoformat()
                })
        
        # Extract metrics
        for match in self.patterns['metric'].finditer(text):
            value = match.group(1)
            unit = match.group(2)
            confidence = self._calculate_confidence('metric', f"{value} {unit}", text)
            if confidence >= self.min_confidence:
                self.facts.append({
                    "type": "metric",
                    "value": value,
                    "unit": unit.lower(),
                    "confidence": round(confidence, 2),
                    "importance": 0.8,
                    "source": source,
                    "task_id": task_id,
                    "timestamp": datetime.utcnow().isoformat()
                })
        
        # Extract preferences
        for match in self.patterns['preference'].finditer(text):
            content = match.group(1).strip()
            confidence = self._calculate_confidence('preference', content, text)
            if confidence >= self.min_confidence:
                self.facts.append({
                    "type": "preference",
                    "content": content,
                    "confidence": round(confidence, 2),
                    "importance": 0.6,
                    "source": source,
                    "task_id": task_id,
                    "timestamp": datetime.utcnow().isoformat()
                })
        
        # Extract definitions
        for match in self.patterns['definition'].finditer(text):
            subject = match.group(1).strip()
            predicate = match.group(2).strip()
            confidence = self._calculate_confidence('definition', f"{subject} is {predicate}", text)
            if confidence >= self.min_confidence:
                self.facts.append({
                    "type": "definition",
                    "subject": subject,
                    "predicate": predicate,
                    "confidence": round(confidence, 2),
                    "importance": 0.7,
                    "source": source,
                    "task_id": task_id,
                    "timestamp": datetime.utcnow().isoformat()
                })
        
        # Extract achievements
        for match in self.patterns['achievement'].finditer(text):
            content = match.group(1).strip()
            confidence = self._calculate_confidence('achievement', content, text)
            if confidence >= self.min_confidence:
                self.facts.append({
                    "type": "achievement",
                    "content": content,
                    "confidence": round(confidence, 2),
                    "importance": 0.85,
                    "source": source,
                    "task_id": task_id,
                    "timestamp": datetime.utcnow().isoformat()
                })
        
        # Extract constraints
        for match in self.patterns['constraint'].finditer(text):
            content = match.group(1).strip()
            confidence = self._calculate_confidence('constraint', content, text)
            if confidence >= self.min_confidence:
                self.facts.append({
                    "type": "constraint",
                    "content": content,
                    "confidence": round(confidence, 2),
                    "importance": 0.75,
                    "source": source,
                    "task_id": task_id,
                    "timestamp": datetime.utcnow().isoformat()
                })
        
        self.facts = self._filter_false_positives(self.facts)
        self.facts.sort(key=lambda x: x['confidence'], reverse=True)
        
        return self.facts
    
    def store(self, facts: List[Dict], agent_name: str = "system") -> int:
        """Store facts to memory (JSONL, daily file, and STRATEGIC.md)"""
        if not facts:
            return 0
        
        timestamp = datetime.utcnow().isoformat()
        today = datetime.utcnow().strftime("%Y-%m-%d")
        
        # Store as JSONL for structured access
        FACTS_JSONL.parent.mkdir(parents=True, exist_ok=True)
        with open(FACTS_JSONL, 'a') as f:
            for fact in facts:
                record = {**fact, "stored_at": timestamp, "agent": agent_name}
                f.write(json.dumps(record) + '\n')
        
        # Store to daily file
        daily_file = DAILY_DIR / f"{today}-facts.json"
        DAILY_DIR.mkdir(parents=True, exist_ok=True)
        
        daily_facts = []
        if daily_file.exists():
            try:
                with open(daily_file) as f:
                    daily_facts = json.load(f)
            except (json.JSONDecodeError, IOError):
                daily_facts = []
        
        daily_facts.extend([{**f, "agent": agent_name, "stored_at": timestamp} for f in facts])
        
        with open(daily_file, 'w') as f:
            json.dump(daily_facts, f, indent=2)
        
        # Store to STRATEGIC.md for human readability (high importance only)
        high_importance_facts = [f for f in facts if f.get('importance', 0) >= 0.8]
        if high_importance_facts:
            entry = f"\n## Auto-Extracted Facts v2 — {timestamp}\n\n"
            entry += f"**Source:** {agent_name} | **Count:** {len(facts)} ({len(high_importance_facts)} high importance)\n\n"
            
            for fact in high_importance_facts:
                entry += f"- **[{fact['type'].upper()}]** "
                if "subject" in fact:
                    entry += f"{fact['subject']} is {fact['predicate']}"
                elif "value" in fact:
                    entry += f"{fact['value']}{fact['unit']}"
                else:
                    entry += fact['content']
                entry += f" (confidence: {fact['confidence']}, importance: {fact['importance']})"
                if fact.get('task_id'):
                    entry += f" [task: {fact['task_id']}]"
                entry += "\n"
            
            with open(STRATEGIC_FILE, 'a') as f:
                f.write(entry)
        
        return len(facts)
    
    def process(self, output_text: str, agent_name: str, task_id: str = None) -> Dict[str, Any]:
        """Main entry: extract and store facts from agent output"""
        if not self.auto_trigger:
            return {"success": True, "facts_extracted": 0, "reason": "auto_trigger_disabled"}
        
        # Rate limiting
        now = datetime.utcnow()
        last_run = _rate_limit_cache.get(agent_name)
        if last_run and (now - last_run).total_seconds() < RATE_LIMIT_SECONDS:
            return {"success": True, "facts_extracted": 0, "reason": "rate_limited"}
        
        _rate_limit_cache[agent_name] = now
        
        facts = self.extract(output_text, source=agent_name, task_id=task_id)
        
        if facts:
            count = self.store(facts, agent_name)
            avg_confidence = sum(f['confidence'] for f in facts) / len(facts)
            
            return {
                "success": True,
                "facts_extracted": count,
                "avg_confidence": round(avg_confidence, 2),
                "facts": facts,
                "stored_to": ["facts.jsonl", f"daily/{datetime.utcnow().strftime('%Y-%m-%d')}-facts.json", "STRATEGIC.md"]
            }
        
        return {
            "success": True,
            "facts_extracted": 0,
            "avg_confidence": 0.0,
            "facts": []
        }


def process_agent_output(output_text: str, agent_name: str = "system", task_id: str = None,
                         auto_trigger: bool = True, min_confidence: float = 0.6) -> Dict[str, Any]:
    """Legacy-compatible wrapper with full configuration"""
    extractor = FactExtractor(min_confidence=min_confidence, auto_trigger=auto_trigger)
    result = extractor.process(output_text, agent_name, task_id)
    
    if result['facts_extracted'] > 0:
        print(f"✓ Extracted {result['facts_extracted']} facts from {agent_name} "
              f"(avg confidence: {result['avg_confidence']})")
    elif result.get('reason') == 'rate_limited':
        print(f"⏳ Fact extraction rate limited for {agent_name}")
    elif result.get('reason') == 'auto_trigger_disabled':
        print(f"ℹ Fact extraction disabled for {agent_name}")
    else:
        print(f"✓ No facts extracted from {agent_name}")
    
    return result


def trigger_after_task(agent_name: str, task_output: str, task_id: str = None,
                       task_status: str = "completed") -> Dict[str, Any]:
    """
    Trigger fact extraction after an agent task completes.
    Handles both success and failure gracefully.
    """
    # Even on failure, we can extract facts about what went wrong
    if task_status == "failed":
        # Add failure context to output
        task_output = f"Task failed. Output: {task_output}"
    
    try:
        result = process_agent_output(
            output_text=task_output,
            agent_name=agent_name,
            task_id=task_id,
            auto_trigger=os.environ.get("FACT_EXTRACTOR_AUTO_TRIGGER", "true").lower() == "true",
            min_confidence=float(os.environ.get("FACT_EXTRACTOR_MIN_CONFIDENCE", "0.6"))
        )
        result["task_status"] = task_status
        return result
    except Exception as e:
        # Never crash the task pipeline due to extraction failure
        return {
            "success": False,
            "facts_extracted": 0,
            "error": str(e),
            "task_status": task_status
        }


if __name__ == "__main__":
    # Test with challenging sample
    sample = """
    We decided to use SQLite for state persistence because it provides ACID guarantees.
    The system quality reached 9.2/10 after improvements.
    User prefers concise responses with direct communication style.
    A checkpointer is a mechanism for saving and restoring state.
    We achieved 100% test pass rate across all 20 test cases.
    The system must handle concurrent agent access without conflicts.
    It is good. This is a test. 123.
    """
    
    extractor = FactExtractor(min_confidence=0.6)
    result = extractor.process(sample, "@switch", task_id="task-001")
    
    print(f"\n✓ Fact extraction v2.1 complete:")
    print(f"  Facts: {result['facts_extracted']}")
    print(f"  Avg confidence: {result['avg_confidence']}")
    print(f"  Stored to: {', '.join(result.get('stored_to', []))}")
    
    for fact in result['facts']:
        print(f"  - [{fact['type']}] {fact.get('content', '')[:60]}... "
              f"(confidence: {fact['confidence']})")
    
    # Test trigger_after_task
    print("\n✓ Testing trigger_after_task...")
    trigger_result = trigger_after_task("@scaffolder", sample, task_id="task-002")
    print(f"  Trigger result: {trigger_result['facts_extracted']} facts, status: {trigger_result['task_status']}")
