#!/bin/bash
# P001-T3.3: Quality Gates & Performance Testing
# Validates generated projects against 5-point quality system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="/Users/rohitvashist/.openclaw/agents/scaffolder/agent/skills/scaffold/templates"
OUTPUT_DIR="/tmp/p001-t3.3-validation-$(date +%Y%m%d-%H%M%S)"
VERIFICATION_DIR="$SCRIPT_DIR/verification/T3.3"
ITERATIONS=5  # Run 5 iterations per template for validation

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging (to stderr so stdout can be used for JSON output)
log_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1" >&2; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Get current time in milliseconds
get_time_ms() {
    python3 -c "import time; print(int(time.time() * 1000))"
}

# Initialize
init() {
    log_info "P001-T3.3: Quality Gates & Performance Testing"
    log_info "================================================"
    log_info "Iterations per template: $ITERATIONS"
    log_info "Output directory: $OUTPUT_DIR"
    log_info ""
    
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$VERIFICATION_DIR"
    
    # Check prerequisites
    if ! command -v node &> /dev/null; then
        log_error "Node.js not found"
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        log_error "npm not found"
        exit 1
    fi
    
    log_info "Node version: $(node --version)"
    log_info "npm version: $(npm --version)"
    log_info ""
}

# Generate project from template
generate_project() {
    local project_name="$1"
    local template="$2"
    local output_path="$3"
    local timing_file="$4"
    
    local start_time=$(get_time_ms)
    
    # Copy template files (copy contents, not the directory itself)
    mkdir -p "$output_path"
    # Use find to copy all files including hidden ones, excluding . and ..
    find "$TEMPLATES_DIR/$template" -mindepth 1 -maxdepth 1 -exec cp -r {} "$output_path/" \;
    
    # Update project name in package.json
    if [ -f "$output_path/package.json" ]; then
        local tmp_file=$(mktemp)
        jq --arg name "$project_name" '.name = $name' "$output_path/package.json" > "$tmp_file"
        mv "$tmp_file" "$output_path/package.json"
    fi
    
    # For express-react, update workspace packages too
    if [ "$template" == "express-react" ]; then
        [ -f "$output_path/server/package.json" ] && \
            jq --arg name "${project_name}-server" '.name = $name' "$output_path/server/package.json" > "$output_path/server/package.json.tmp" && \
            mv "$output_path/server/package.json.tmp" "$output_path/server/package.json"
        
        [ -f "$output_path/client/package.json" ] && \
            jq --arg name "${project_name}-client" '.name = $name' "$output_path/client/package.json" > "$output_path/client/package.json.tmp" && \
            mv "$output_path/client/package.json.tmp" "$output_path/client/package.json"
    fi
    
    local end_time=$(get_time_ms)
    local duration_ms=$((end_time - start_time))
    
    echo "$duration_ms" > "$timing_file"
}

# Run npm install
run_npm_install() {
    local project_path="$1"
    local timing_file="$2"
    local error_file="$3"
    
    local start_time=$(get_time_ms)
    
    cd "$project_path"
    
    if ! npm install --silent > "$error_file" 2>&1; then
        echo "ERROR" > "$timing_file"
        return 1
    fi
    
    local end_time=$(get_time_ms)
    local duration_ms=$((end_time - start_time))
    
    echo "$duration_ms" > "$timing_file"
}

# Check 1: TypeScript Compilation (2 pts)
check_typescript() {
    local project_path="$1"
    local template="$2"
    local score_file="$3"
    
    cd "$project_path"
    
    local passed=true
    
    # For express-react, check both client and server from their directories
    if [ "$template" == "express-react" ]; then
        # Check server
        cd "$project_path/server"
        if ! npx tsc --noEmit > /tmp/tsc-server.log 2>&1; then
            passed=false
        fi
        # Check client (use its own tsconfig)
        cd "$project_path/client"
        if ! npx tsc --noEmit > /tmp/tsc-client.log 2>&1; then
            passed=false
        fi
    else
        # Single package
        if ! npx tsc --noEmit > /tmp/tsc.log 2>&1; then
            passed=false
        fi
    fi
    
    if $passed; then
        echo "2" > "$score_file"
    else
        echo "0" > "$score_file"
    fi
}

# Check 2: ESLint Clean (2 pts)
check_eslint() {
    local project_path="$1"
    local template="$2"
    local score_file="$3"
    
    cd "$project_path"
    
    local passed=true
    
    # For express-react, check both workspaces
    if [ "$template" == "express-react" ]; then
        cd "$project_path/server"
        if ! npx eslint src --ext .ts --max-warnings 0 > /dev/null 2>&1; then
            passed=false
        fi
        cd "$project_path/client"
        if ! npx eslint src --ext .ts,.tsx --max-warnings 0 > /dev/null 2>&1; then
            passed=false
        fi
    else
        if ! npx eslint src --ext .ts,.tsx --max-warnings 0 > /dev/null 2>&1; then
            passed=false
        fi
    fi
    
    if $passed; then
        echo "2" > "$score_file"
    else
        echo "0" > "$score_file"
    fi
}

# Check 3: Build Success (2 pts)
check_build() {
    local project_path="$1"
    local template="$2"
    local score_file="$3"
    
    cd "$project_path"
    
    local passed=true
    
    if [ "$template" == "express-react" ]; then
        # Build client (vite handles both type check and build)
        cd "$project_path/client"
        if ! npm run build > /tmp/build-client.log 2>&1; then
            passed=false
        fi
        # Compile server
        cd "$project_path/server"
        if ! npx tsc --build > /tmp/build-server.log 2>&1; then
            passed=false
        fi
    else
        # Next.js build
        if ! npm run build > /tmp/build.log 2>&1; then
            passed=false
        fi
    fi
    
    if $passed; then
        echo "2" > "$score_file"
    else
        echo "0" > "$score_file"
    fi
}

# Check 4: Structure Validation (2 pts)
check_structure() {
    local project_path="$1"
    local template="$2"
    local score_file="$3"
    
    local score=0
    
    # Essential files that must exist
    local essential_files=(
        "package.json"
        "README.md"
        ".gitignore"
    )
    
    for file in "${essential_files[@]}"; do
        if [ -f "$project_path/$file" ]; then
            ((score+=1))
        fi
    done
    
    # Template-specific checks
    if [ "$template" == "nextjs-fullstack" ]; then
        [ -d "$project_path/src/app" ] && ((score+=1))
        [ -f "$project_path/next.config.js" ] && ((score+=1))
    elif [ "$template" == "express-react" ]; then
        [ -d "$project_path/server" ] && ((score+=1))
        [ -d "$project_path/client" ] && ((score+=1))
    fi
    
    # Normalize to 0-2 scale
    if [ $score -ge 5 ]; then
        echo "2" > "$score_file"
    elif [ $score -ge 3 ]; then
        echo "1" > "$score_file"
    else
        echo "0" > "$score_file"
    fi
}

# Check 5: Dependencies Check (2 pts)
check_dependencies() {
    local project_path="$1"
    local template="$2"
    local score_file="$3"
    
    cd "$project_path"
    
    local all_installed=true
    
    # Check root node_modules exists and has content
    if [ ! -d "node_modules" ] || [ -z "$(ls -A node_modules 2>/dev/null)" ]; then
        all_installed=false
    fi
    
    # For express-react (npm workspaces), verify workspace deps are linked
    if [ "$template" == "express-react" ]; then
        # Check that client and server packages are linked in node_modules
        if [ ! -L "node_modules/$(jq -r '.name' client/package.json)" ] && \
           [ ! -d "node_modules/$(jq -r '.name' client/package.json)" ]; then
            # Check if the packages are installed at all (npm workspaces hoists them)
            if ! npm list --json > /dev/null 2>&1; then
                all_installed=false
            fi
        fi
    fi
    
    if $all_installed; then
        echo "2" > "$score_file"
    else
        echo "0" > "$score_file"
    fi
}

# Run full validation on a single iteration
validate_iteration() {
    local iteration="$1"
    local template="$2"
    local project_name="test-${template}-${iteration}"
    local project_path="$OUTPUT_DIR/$project_name"
    local result_dir="$project_path"
    
    mkdir -p "$result_dir"
    
    log_info "  Iteration $iteration: $project_name"
    
    # Generate
    local gen_time_file="$result_dir/gen_time.txt"
    generate_project "$project_name" "$template" "$project_path" "$gen_time_file"
    local gen_time=$(cat "$gen_time_file")
    log_info "    Generated in ${gen_time}ms"
    
    # Install dependencies
    local install_time_file="$result_dir/install_time.txt"
    local install_error_file="$result_dir/install_error.log"
    if run_npm_install "$project_path" "$install_time_file" "$install_error_file"; then
        local install_time=$(cat "$install_time_file")
        log_info "    npm install in ${install_time}ms"
    else
        log_error "    npm install failed"
        local install_time=0
    fi
    
    # Run quality checks
    log_info "    Running quality checks..."
    
    local ts_score_file="$result_dir/ts_score.txt"
    local eslint_score_file="$result_dir/eslint_score.txt"
    local build_score_file="$result_dir/build_score.txt"
    local structure_score_file="$result_dir/structure_score.txt"
    local deps_score_file="$result_dir/deps_score.txt"
    
    check_typescript "$project_path" "$template" "$ts_score_file"
    check_eslint "$project_path" "$template" "$eslint_score_file"
    check_build "$project_path" "$template" "$build_score_file"
    check_structure "$project_path" "$template" "$structure_score_file"
    check_dependencies "$project_path" "$template" "$deps_score_file"
    
    local ts_score=$(cat "$ts_score_file")
    local eslint_score=$(cat "$eslint_score_file")
    local build_score=$(cat "$build_score_file")
    local structure_score=$(cat "$structure_score_file")
    local deps_score=$(cat "$deps_score_file")
    
    local total_score=$((ts_score + eslint_score + build_score + structure_score + deps_score))
    
    log_info "    Quality Score: ${total_score}/10 (TS:${ts_score} ESLint:${eslint_score} Build:${build_score} Structure:${structure_score} Deps:${deps_score})"
    
    # Output JSON result
    cat > "$result_dir/result.json" <<EOF
{
  "iteration": $iteration,
  "project_name": "$project_name",
  "template": "$template",
  "timing": {
    "generation_ms": $gen_time,
    "install_ms": $install_time,
    "total_ms": $((gen_time + install_time))
  },
  "quality": {
    "typescript": $ts_score,
    "eslint": $eslint_score,
    "build": $build_score,
    "structure": $structure_score,
    "dependencies": $deps_score,
    "total": $total_score
  }
}
EOF
    
    # Output just the JSON to stdout for aggregation
    cat "$result_dir/result.json"
}

# Run all iterations for a template
run_template_tests() {
    local template="$1"
    local results_file="$VERIFICATION_DIR/${template}-results.json"
    
    log_info ""
    log_info "Testing Template: $template"
    log_info "================================"
    
    # Start JSON array
    echo "{\"template\": \"$template\", \"iterations\": [" > "$results_file"
    
    local first=true
    for i in $(seq 1 $ITERATIONS); do
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$results_file"
        fi
        
        validate_iteration "$i" "$template" >> "$results_file"
    done
    
    # Close JSON
    echo "" >> "$results_file"
    echo "]}" >> "$results_file"
    
    log_info ""
    log_success "Results saved to: $results_file"
}

# Calculate statistics from results
calculate_stats() {
    local template="$1"
    local results_file="$VERIFICATION_DIR/${template}-results.json"
    
    if [ ! -f "$results_file" ]; then
        log_error "Results file not found: $results_file"
        return
    fi
    
    log_info ""
    log_info "Statistics for $template:"
    
    # Use Python for statistics calculation
    python3 << EOF
import json

with open('$results_file') as f:
    data = json.load(f)

iterations = data['iterations']
times = [r['timing']['total_ms'] for r in iterations]
scores = [r['quality']['total'] for r in iterations]

avg_time = sum(times) / len(times)
min_time = min(times)
max_time = max(times)
avg_score = sum(scores) / len(scores)

print(f"  Average Time: {avg_time:.0f}ms ({avg_time/1000:.1f}s)")
print(f"  Min Time: {min_time}ms ({min_time/1000:.1f}s)")
print(f"  Max Time: {max_time}ms ({max_time/1000:.1f}s)")
print(f"  Average Quality Score: {avg_score:.1f}/10")

# Determine pass/fail
target_time = 120000 if '$template' == 'nextjs-fullstack' else 130000
target_score = 9.0

time_pass = avg_time <= target_time
score_pass = avg_score >= target_score

print(f"")
print(f"  Time Target (<{target_time/1000:.0f}s): {'PASS' if time_pass else 'FAIL'}")
print(f"  Quality Target (≥9.0): {'PASS' if score_pass else 'FAIL'}")

# Save stats
stats = {
    'template': '$template',
    'iterations': len(iterations),
    'timing_ms': {
        'average': avg_time,
        'min': min_time,
        'max': max_time,
        'target': target_time,
        'pass': time_pass
    },
    'quality': {
        'average_score': avg_score,
        'target': target_score,
        'pass': score_pass
    },
    'overall_pass': time_pass and score_pass
}

with open('$VERIFICATION_DIR/${template}-stats.json', 'w') as f:
    json.dump(stats, f, indent=2)

print(f"")
print(f"  Overall: {'PASS' if time_pass and score_pass else 'FAIL'}")
EOF
}

# Generate final report
generate_report() {
    local report_file="$VERIFICATION_DIR/P001-T3.3-RESULTS.md"
    
    log_info ""
    log_info "Generating Final Report..."
    
    # Get stats for both templates
    local nextjs_stats="{}"
    local express_stats="{}"
    
    [ -f "$VERIFICATION_DIR/nextjs-fullstack-stats.json" ] && \
        nextjs_stats=$(cat "$VERIFICATION_DIR/nextjs-fullstack-stats.json")
    
    [ -f "$VERIFICATION_DIR/express-react-stats.json" ] && \
        express_stats=$(cat "$VERIFICATION_DIR/express-react-stats.json")
    
    cat <<EOF > "$report_file"
# P001-T3.3: Quality Gates & Performance Testing Results

**Date:** $(date)
**Agent:** @switch (Kimi K2.5)
**Status:** COMPLETED
**Iterations per template:** $ITERATIONS

## Summary

This validation tested both project templates through $ITERATIONS iterations each,
measuring generation time and quality scores against production targets.

## Quality Scoring System

- TypeScript Compilation: 2 points
- ESLint Clean: 2 points  
- Build Success: 2 points
- Structure Validation: 2 points
- Dependencies Check: 2 points
- **Total: 10 points (score = total)**
- **Target: ≥9.0/10**

## Results

### Next.js Full-Stack Template

\`\`\`json
$nextjs_stats
\`\`\`

### Express + React Template

\`\`\`json
$express_stats
\`\`\`

## Artifacts

- Raw Results (Next.js): \`verification/T3.3/nextjs-fullstack-results.json\`
- Raw Results (Express): \`verification/T3.3/express-react-results.json\`
- Statistics: \`verification/T3.3/*-stats.json\`
- This Report: \`verification/T3.3/P001-T3.3-RESULTS.md\`

## Conclusion

Validation completed with full artifact generation.
All results include timing and quality metrics for each iteration.

EOF
    
    log_success "Report saved to: $report_file"
}

# Main execution
main() {
    init
    
    # Run tests for both templates
    run_template_tests "nextjs-fullstack"
    run_template_tests "express-react"
    
    # Calculate statistics
    calculate_stats "nextjs-fullstack"
    calculate_stats "express-react"
    
    # Generate final report
    generate_report
    
    log_info ""
    log_success "P001-T3.3 Validation Complete!"
    log_info "Artifacts location: $VERIFICATION_DIR"
    log_info ""
    
    # Summary
    log_info "Summary:"
    local nextjs_pass="UNKNOWN"
    local express_pass="UNKNOWN"
    
    [ -f "$VERIFICATION_DIR/nextjs-fullstack-stats.json" ] && \
        nextjs_pass=$(python3 -c "import json; d=json.load(open('$VERIFICATION_DIR/nextjs-fullstack-stats.json')); print('PASS' if d.get('overall_pass') else 'FAIL')")
    
    [ -f "$VERIFICATION_DIR/express-react-stats.json" ] && \
        express_pass=$(python3 -c "import json; d=json.load(open('$VERIFICATION_DIR/express-react-stats.json')); print('PASS' if d.get('overall_pass') else 'FAIL')")
    
    log_info "  Next.js Template: $nextjs_pass"
    log_info "  Express+React Template: $express_pass"
}

# Run main
main "$@"
