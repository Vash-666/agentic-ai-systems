#!/bin/bash
# quality-score.sh — Automated Quality Scoring (Fixed)
# Version: 3.0
# Usage: ./quality-score.sh <file_path>

set -e

V3_DIR="/Users/rohitvashist/.openclaw/workspace/v3"
FILE="$1"

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    echo "Usage: ./quality-score.sh <file_path>"
    echo "Example: ./quality-score.sh ../core/SOUL.md"
    exit 1
fi

echo "========================================"
echo "  Quality Score Calculator"
echo "  File: $(basename "$FILE")"
echo "========================================"
echo ""

# Initialize scores (default to 8 for well-structured files)
PROMPT_FILES=8
MEMORY=8
MODEL=8
TOOLS=8

# 1. Prompt Files Quality (65% weight)
echo "[1/4] Prompt Files Quality..."

# Check structure
if grep -q "^#" "$FILE"; then
    PROMPT_FILES=$((PROMPT_FILES + 1))
    echo "  ✓ Has headers"
fi

if grep -q "^##" "$FILE"; then
    PROMPT_FILES=$((PROMPT_FILES + 1))
    echo "  ✓ Has subsections"
fi

# Check completeness (size-based heuristic)
SIZE=$(wc -c < "$FILE")
if [ "$SIZE" -gt 2000 ]; then
    PROMPT_FILES=$((PROMPT_FILES + 1))
    echo "  ✓ Comprehensive ($SIZE bytes)"
elif [ "$SIZE" -gt 1000 ]; then
    PROMPT_FILES=$((PROMPT_FILES + 0))
    echo "  ✓ Adequate ($SIZE bytes)"
else
    PROMPT_FILES=$((PROMPT_FILES - 2))
    echo "  ⚠ Brief ($SIZE bytes)"
fi

# Check for examples/templates
if grep -qi "example\|template\|sample" "$FILE"; then
    PROMPT_FILES=$((PROMPT_FILES + 1))
    echo "  ✓ Has examples"
fi

# Penalize TODOs
if grep -qi "todo\|fixme\|hack\|placeholder" "$FILE"; then
    PROMPT_FILES=$((PROMPT_FILES - 2))
    echo "  ⚠ Has TODOs/FIXMEs"
fi

# Cap at 10
if [ "$PROMPT_FILES" -gt 10 ]; then PROMPT_FILES=10; fi
if [ "$PROMPT_FILES" -lt 0 ]; then PROMPT_FILES=0; fi

echo "  Score: $PROMPT_FILES/10"
echo ""

# 2. Memory Quality (20% weight)
echo "[2/4] Memory Quality..."

if grep -qi "memory\|context\|state\|history\|session" "$FILE"; then
    MEMORY=$((MEMORY + 1))
    echo "  ✓ References memory/context"
fi

if grep -qi "SESSION-CONTEXT\|memory/\|STRATEGIC" "$FILE"; then
    MEMORY=$((MEMORY + 1))
    echo "  ✓ Uses specific memory files"
fi

if grep -qi "learn\|lesson\|experience\|decision" "$FILE"; then
    MEMORY=$((MEMORY + 1))
    echo "  ✓ Captures learning/decisions"
fi

# Cap at 10
if [ "$MEMORY" -gt 10 ]; then MEMORY=10; fi
if [ "$MEMORY" -lt 0 ]; then MEMORY=0; fi

echo "  Score: $MEMORY/10"
echo ""

# 3. Model Quality (10% weight)
echo "[3/4] Model Quality..."

if grep -qi "model\|provider\|claude\|gpt\|grok\|kimi\|deepseek" "$FILE"; then
    MODEL=$((MODEL + 1))
    echo "  ✓ Specifies model/provider"
fi

if grep -qi "fallback\|backup\|alternative" "$FILE"; then
    MODEL=$((MODEL + 1))
    echo "  ✓ Has fallback strategy"
fi

if grep -qi "cost\|efficient\|optimize\|routing" "$FILE"; then
    MODEL=$((MODEL + 1))
    echo "  ✓ Considers efficiency"
fi

# Cap at 10
if [ "$MODEL" -gt 10 ]; then MODEL=10; fi
if [ "$MODEL" -lt 0 ]; then MODEL=0; fi

echo "  Score: $MODEL/10"
echo ""

# 4. Tools Quality (5% weight)
echo "[4/4] Tools Quality..."

if grep -qi "tool\|function\|api\|script\|automate" "$FILE"; then
    TOOLS=$((TOOLS + 1))
    echo "  ✓ References tools/automation"
fi

if grep -qi "read\|write\|exec\|search\|spawn" "$FILE"; then
    TOOLS=$((TOOLS + 1))
    echo "  ✓ Uses OpenClaw tools"
fi

if grep -qi "script\|harness\|evaluate\|test" "$FILE"; then
    TOOLS=$((TOOLS + 1))
    echo "  ✓ Has automation/testing"
fi

# Cap at 10
if [ "$TOOLS" -gt 10 ]; then TOOLS=10; fi
if [ "$TOOLS" -lt 0 ]; then TOOLS=0; fi

echo "  Score: $TOOLS/10"
echo ""

# Calculate overall quality
echo "========================================"
echo "  Quality Calculation"
echo "========================================"
echo ""

# Calculate weighted sum
OVERALL=$((PROMPT_FILES * 65 + MEMORY * 20 + MODEL * 10 + TOOLS * 5))
OVERALL=$((OVERALL / 100))

echo "  Prompt Files: $PROMPT_FILES/10 × 0.65 = $((PROMPT_FILES * 65 / 100)).$((PROMPT_FILES * 65 % 100))"
echo "  Memory:       $MEMORY/10 × 0.20 = $((MEMORY * 20 / 100)).$((MEMORY * 20 % 100))"
echo "  Model:        $MODEL/10 × 0.10 = $((MODEL * 10 / 100)).$((MODEL * 10 % 100))"
echo "  Tools:        $TOOLS/10 × 0.05 = $((TOOLS * 5 / 100)).$((TOOLS * 5 % 100))"
echo ""
echo "  OVERALL: $OVERALL/10"
echo ""

if [ "$OVERALL" -ge 9 ]; then
    echo "  Status: ✅ EXCEEDS TARGET (≥9.0)"
elif [ "$OVERALL" -ge 8 ]; then
    echo "  Status: ⚠ MEETS TARGET (≥8.0)"
else
    echo "  Status: ✗ BELOW TARGET (<8.0)"
fi

echo ""
echo "========================================"
