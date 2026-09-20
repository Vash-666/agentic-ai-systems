#!/usr/bin/env python3
"""
Automatic Fact Extraction v2.0 for v3.0
Improved with precise patterns, confidence scoring, and structured output
"""

import json
import re
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any, Optional

MEMORY_FILE = Path("../../memory/STRATEGIC.md")
FACTS_JSON = Path("../../memory/facts.jsonl")

class FactExtractor:
    """Extracts structured facts from agent outputs with confidence scoring"""
    
    def __init__(self, min_confidence=0.6):
        self.min_confidence = min_confidence
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
        confidence = 0.5  # Base confidence
        
        # Signal 1: Length appropriateness (not too short, not too long)
        text_len = len(match_text)
        if 20 <= text_len <= 150:
            confidence += 0.2
        elif 10 <= text_len < 20:
            confidence += 0.1
        
        # Signal 2: Contains specific entities (names, versions, numbers)
        if re.search(r'\d+\.\d+|v\d+|\b[A-Z][a-z]+\s+[A-Z][a-z]+\b', match_text):
            confidence += 0.15
        
        # Signal 3: Clear sentence boundaries
        if match_text[0].isupper() and not match_text.endswith(('and', 'or', 'but')):
            confidence += 0.1
        
        # Signal 4: Fact type specific boosts
        if fact_type == 'metric' and re.match(r'^\d+(\.\d+)?$', match_text.split()[0]):
            confidence += 0.15
        elif fact_type == 'decision' and any(w in match_text.lower() for w in ['use', 'implement', 'adopt', 'choose']):
            confidence += 0.1
        
        # Signal 5: Context quality (surrounding text)
        if len(context) > 50:
            confidence += 0.05
        
        return min(confidence, 1.0)
    
    def _filter_false_positives(self, facts: List[Dict]) -> List[Dict]:
        """Remove likely false positives"""
        filtered = []
        
        for fact in facts:
            text = fact.get('content', '') or f"{fact.get('subject', '')} {fact.get('predicate', '')}"
            
            # Skip if too short or too long
            if len(text) < 10 or len(text) > 300:
                continue
            
            # Skip if mostly numbers/symbols
            if sum(c.isalpha() or c.isspace() for c in text) < len(text) * 0.5:
                continue
            
            # Skip common false positives
            false_patterns = [
                r'^\d+$',  # Just a number
                r'^(this|that|these|those|it|they)\s',  # Vague references
                r'^(is|are|was|were|be|been)\s',  # Incomplete
            ]
            
            if any(re.match(p, text, re.IGNORECASE) for p in false_patterns):
                continue
            
            filtered.append(fact)
        
        return filtered
    
    def extract(self, text: str, source: str = "unknown") -> List[Dict[str, Any]]:
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
                    "timestamp": datetime.utcnow().isoformat()
                })
        
        # Filter false positives
        self.facts = self._filter_false_positives(self.facts)
        
        # Sort by confidence
        self.facts.sort(key=lambda x: x['confidence'], reverse=True)
        
        return self.facts
    
    def store(self, facts: List[Dict], agent_name: str = "system") -> int:
        """Store facts to memory (both markdown and JSONL)"""
        if not facts:
            return 0
        
        timestamp = datetime.utcnow().isoformat()
        
        # Store as JSONL for structured access
        FACTS_JSON.parent.mkdir(parents=True, exist_ok=True)
        with open(FACTS_JSON, 'a') as f:
            for fact in facts:
                record = {
                    **fact,
                    "stored_at": timestamp,
                    "agent": agent_name
                }
                f.write(json.dumps(record) + '\n')
        
        # Store as markdown for human readability
        entry = f"\n## Auto-Extracted Facts v2 — {timestamp}\n\n"
        entry += f"**Source:** {agent_name} | **Count:** {len(facts)}\n\n"
        
        for fact in facts:
            entry += f"- **[{fact['type'].upper()}]** "
            if "subject" in fact:
                entry += f"{fact['subject']} is {fact['predicate']}"
            elif "value" in fact:
                entry += f"{fact['value']}{fact['unit']}"
            else:
                entry += fact['content']
            entry += f" (confidence: {fact['confidence']}, importance: {fact['importance']})\n"
        
        with open(MEMORY_FILE, 'a') as f:
            f.write(entry)
        
        return len(facts)
    
    def process(self, output_text: str, agent_name: str) -> Dict[str, Any]:
        """Main entry: extract and store facts from agent output"""
        facts = self.extract(output_text, source=agent_name)
        
        if facts:
            count = self.store(facts, agent_name)
            avg_confidence = sum(f['confidence'] for f in facts) / len(facts)
            
            return {
                "success": True,
                "facts_extracted": count,
                "avg_confidence": round(avg_confidence, 2),
                "facts": facts
            }
        
        return {
            "success": True,
            "facts_extracted": 0,
            "avg_confidence": 0.0,
            "facts": []
        }


def process_agent_output(output_text: str, agent_name: str = "system") -> int:
    """Legacy-compatible wrapper"""
    extractor = FactExtractor(min_confidence=0.6)
    result = extractor.process(output_text, agent_name)
    
    if result['facts_extracted'] > 0:
        print(f"✓ Extracted {result['facts_extracted']} facts from {agent_name} "
              f"(avg confidence: {result['avg_confidence']})")
    else:
        print(f"✓ No facts extracted from {agent_name}")
    
    return result['facts_extracted']


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
    result = extractor.process(sample, "@switch")
    
    print(f"\n✓ Fact extraction v2 complete:")
    print(f"  Facts: {result['facts_extracted']}")
    print(f"  Avg confidence: {result['avg_confidence']}")
    
    for fact in result['facts']:
        print(f"  - [{fact['type']}] {fact.get('content', '')[:60]}... "
              f"(confidence: {fact['confidence']})")
