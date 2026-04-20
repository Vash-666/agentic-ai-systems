#!/bin/bash
# verify-day3.sh - Automated verification checker for Day 3 tasks
# Created: April 20, 2026
# Purpose: Prevent "execution theatre" by validating proof-of-work artifacts

set -e

echo "========================================"
echo "Day 3 Verification Checker"
echo "========================================"
echo ""

ERRORS=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
check_file() {
  if [ -f "$1" ]; then
    echo -e "${GREEN}✅ PASS${NC}: $1 exists"
  else
    echo -e "${RED}❌ FAIL${NC}: $1 missing"
    ((ERRORS++))
  fi
}

check_dir() {
  if [ -d "$1" ]; then
    echo -e "${GREEN}✅ PASS${NC}: $1 exists"
  else
    echo -e "${RED}❌ FAIL${NC}: $1 missing"
    ((ERRORS++))
  fi
}

check_file_min_lines() {
  if [ ! -f "$1" ]; then
    echo -e "${RED}❌ FAIL${NC}: $1 missing"
    ((ERRORS++))
    return
  fi
  
  lines=$(wc -l < "$1" | tr -d ' ')
  if [ "$lines" -ge "$2" ]; then
    echo -e "${GREEN}✅ PASS${NC}: $1 has $lines lines (≥$2 required)"
  else
    echo -e "${RED}❌ FAIL${NC}: $1 has only $lines lines (need ≥$2)"
    ((ERRORS++))
  fi
}

echo "=== Task 3.1: Agent Integration ==="
check_dir "agents/scaffolder"
check_file "agents/scaffolder/AGENT.md"
check_dir "skills/scaffold/templates"
check_file "verification/t3.1-structure.txt"
check_file "verification/t3.1-agent-list.txt"
echo ""

echo "=== Task 3.2: Generation Pipeline ==="
check_file "generate.ts"
check_file "verification/t3.2-nextjs-run.log"
check_file "verification/t3.2-express-run.log"
check_file "verification/t3.2-nextjs-files.txt"
check_file "verification/t3.2-express-files.txt"

# Check logs have meaningful content (not empty)
check_file_min_lines "verification/t3.2-nextjs-run.log" 10
check_file_min_lines "verification/t3.2-express-run.log" 10
echo ""

echo "=== Task 3.3: Performance Testing ==="
check_file "validate.ts"
check_file "benchmarks.json"
check_file "verification/t3.3-perf-nextjs.log"
check_file "verification/t3.3-perf-express.log"
check_file "verification/t3.3-results.json"
check_file "verification/t3.3-percentiles.txt"

# Check benchmarks.json has sufficient runs
if [ -f "benchmarks.json" ]; then
  if command -v jq &> /dev/null; then
    runs=$(jq 'length' benchmarks.json 2>/dev/null || echo 0)
    if [ "$runs" -ge 20 ]; then
      echo -e "${GREEN}✅ PASS${NC}: benchmarks.json has $runs runs (≥20 required)"
    else
      echo -e "${RED}❌ FAIL${NC}: benchmarks.json has only $runs runs (need ≥20)"
      ((ERRORS++))
    fi
  else
    echo -e "${YELLOW}⚠️  WARN${NC}: jq not installed, skipping benchmarks.json validation"
  fi
fi
echo ""

echo "=== Task 3.4: End-to-End Validation ==="
check_file "verification/t3.4-repos.txt"
check_file "verification/t3.4-github-actions.png"
check_file "verification/t3.4-nextjs-install.log"
check_file "verification/t3.4-nextjs-dev.log"
check_file "verification/t3.4-nextjs-build.log"
check_file "verification/t3.4-express-install.log"
check_file "verification/t3.4-express-dev.log"
check_file "verification/t3.4-express-build.log"

# Check repos.txt has actual URLs
if [ -f "verification/t3.4-repos.txt" ]; then
  if grep -q "github.com" "verification/t3.4-repos.txt"; then
    echo -e "${GREEN}✅ PASS${NC}: t3.4-repos.txt contains GitHub URLs"
  else
    echo -e "${RED}❌ FAIL${NC}: t3.4-repos.txt missing GitHub URLs"
    ((ERRORS++))
  fi
fi
echo ""

echo "========================================"
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ ALL VERIFICATION CHECKS PASSED${NC}"
  echo "Day 3 execution verified - all required artifacts present."
  exit 0
else
  echo -e "${RED}❌ VERIFICATION FAILED${NC}"
  echo "Found $ERRORS error(s) - Day 3 NOT complete."
  echo ""
  echo "Missing artifacts indicate work was not actually performed."
  echo "Do NOT claim task completion until all checks pass."
  exit 1
fi
