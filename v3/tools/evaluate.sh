#!/bin/bash
# evaluate.sh — v3.0 Quality Evaluation Harness
# Version: 3.0
# Usage: ./evaluate.sh [--all|--file <path>|--category <name>]

set -e

V3_DIR="/Users/rohitvashist/.openclaw/workspace/v3"
MODE="${1:---all}"

echo "========================================"
echo "  v3.0 Quality Evaluation Harness"
echo "  Mode: $MODE"
echo "========================================"
echo ""

# Quality scoring function
score_file() {
    local file="$1"
    local name=$(basename "$file")
    
    # Check if file exists
    if [ ! -f "$file" ]; then
        echo "  ✗ $name — FILE NOT FOUND"
        return 1
    fi
    
    # Check if file is non-empty
    local size=$(wc -c < "$file")
    if [ "$size" -lt 100 ]; then
        echo "  ✗ $name — TOO SHORT ($size bytes)"
        return 1
    fi
    
    # Check for required sections
    local score=0
    local checks=0
    
    # Has headers
    if grep -q "^#" "$file"; then
        score=$((score + 2))
    fi
    checks=$((checks + 2))
    
    # Has structure (lists, tables, or code blocks)
    if grep -q "^\s*[-|*]\|^\s*|\|^\s*\`\`\`" "$file"; then
        score=$((score + 2))
    fi
    checks=$((checks + 2))
    
    # Has version marker
    if grep -qi "version.*3\.0" "$file"; then
        score=$((score + 1))
    fi
    checks=$((checks + 1))
    
    # Has purpose/goal
    if grep -qi "purpose\|goal\|objective" "$file"; then
        score=$((score + 1))
    fi
    checks=$((checks + 1))
    
    # File size quality (larger files tend to be more complete)
    if [ "$size" -gt 1000 ]; then
        score=$((score + 2))
    elif [ "$size" -gt 500 ]; then
        score=$((score + 1))
    fi
    checks=$((checks + 2))
    
    # Calculate percentage
    local pct=$((score * 100 / checks))
    
    # Convert to 0-10 scale
    local final=$((pct / 10))
    
    echo "  ✓ $name — $final/10 ($size bytes)"
    return 0
}

# Run evaluation
PASS=0
FAIL=0
TOTAL=0

if [ "$MODE" = "--all" ]; then
    echo "Evaluating all v3.0 files..."
    echo ""
    
    # Core files
    echo "Core Files:"
    for file in "$V3_DIR/core/"*.md; do
        if score_file "$file"; then
            PASS=$((PASS + 1))
        else
            FAIL=$((FAIL + 1))
        fi
        TOTAL=$((TOTAL + 1))
    done
    echo ""
    
    # Agent files
    echo "Agent Definitions:"
    for file in "$V3_DIR/agents/"*/AGENT.md; do
        if score_file "$file"; then
            PASS=$((PASS + 1))
        else
            FAIL=$((FAIL + 1))
        fi
        TOTAL=$((TOTAL + 1))
    done
    echo ""
    
    # Protocol files
    echo "Protocols:"
    for file in "$V3_DIR/protocols/"*.md; do
        if score_file "$file"; then
            PASS=$((PASS + 1))
        else
            FAIL=$((FAIL + 1))
        fi
        TOTAL=$((TOTAL + 1))
    done
    echo ""
    
    # Memory files
    echo "Memory:"
    for file in "$V3_DIR/memory/"*.md; do
        if score_file "$file"; then
            PASS=$((PASS + 1))
        else
            FAIL=$((FAIL + 1))
        fi
        TOTAL=$((TOTAL + 1))
    done
    echo ""
    
elif [ "$MODE" = "--file" ] && [ -n "$2" ]; then
    echo "Evaluating: $2"
    score_file "$2"
    
elif [ "$MODE" = "--category" ] && [ -n "$2" ]; then
    echo "Evaluating category: $2"
    for file in "$V3_DIR/$2/"*.md; do
        if score_file "$file"; then
            PASS=$((PASS + 1))
        else
            FAIL=$((FAIL + 1))
        fi
        TOTAL=$((TOTAL + 1))
    done
else
    echo "Usage: ./evaluate.sh [--all|--file <path>|--category <name>]"
    exit 1
fi

# Summary
echo "========================================"
echo "  Evaluation Complete"
echo "  Passed: $PASS/$TOTAL"
echo "  Failed: $FAIL/$TOTAL"
echo "  Success Rate: $((PASS * 100 / TOTAL))%"
echo "========================================"

if [ "$FAIL" -eq 0 ]; then
    echo "  Status: ✅ ALL TESTS PASSED"
    exit 0
else
    echo "  Status: ⚠ SOME TESTS FAILED"
    exit 1
fi
