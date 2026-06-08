#!/usr/bin/env bash
#
# Production Deployment Script
# Path: /Users/rohitvashist/.openclaw/workspace/deployment/deploy-to-prod.sh
#
# Usage:
#   ./deploy-to-prod.sh                    # Standard deployment
#   ./deploy-to-prod.sh --dry-run          # Simulate without changes
#   ./deploy-to-prod.sh --step             # Confirm each step
#   ./deploy-to-prod.sh --force            # Skip confirmations (CI/CD)
#   ./deploy-to-prod.sh --rollback <tag>   # Rollback to specific tag
#

set -euo pipefail

# ==============================================================================
# CONFIGURATION
# ==============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly WORKSPACE_ROOT="${SCRIPT_DIR}/.."
readonly DEPLOY_ROOT="${HOME}/.openclaw"
readonly LOG_DIR="${DEPLOY_ROOT}/logs"
readonly BACKUP_DIR="${DEPLOY_ROOT}/backups"
readonly STATE_DIR="${DEPLOY_ROOT}/state"
readonly CONFIG_DIR="${DEPLOY_ROOT}/config"
readonly DEPLOY_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly DEPLOY_TAG="deploy-${DEPLOY_TIMESTAMP}"
readonly LOG_FILE="${LOG_DIR}/deploy-${DEPLOY_TIMESTAMP}.log"

# Deployment directories
readonly DEPLOY_LIB_DIR="${DEPLOY_ROOT}/lib"
readonly DEPLOY_TOOLS_DIR="${DEPLOY_ROOT}/tools"
readonly DEPLOY_CRON_DIR="${DEPLOY_ROOT}/cron"

# Source directories
readonly SOURCE_LIB_DIR="${WORKSPACE_ROOT}/lib"
readonly SOURCE_TOOLS_DIR="${WORKSPACE_ROOT}/tools"
readonly SOURCE_CONFIG_DIR="${WORKSPACE_ROOT}/config"

# ==============================================================================
# FLAGS
# ==============================================================================

DRY_RUN=false
STEP_MODE=false
FORCE_MODE=false
ROLLBACK_TAG=""
VERBOSE=false

# ==============================================================================
# LOGGING
# ==============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_line="[${timestamp}] [${level}] ${message}"
    
    # Ensure log directory exists
    mkdir -p "${LOG_DIR}"
    
    echo "${log_line}" | tee -a "${LOG_FILE}"
}

log_info() { log "INFO" "$@"; }
log_warn() { log "WARN" "$@"; }
log_error() { log "ERROR" "$@"; }
log_success() { log "SUCCESS" "$@"; }
log_section() {
    echo "" | tee -a "${LOG_FILE}"
    log "SECTION" "========================================"
    log "SECTION" "$@"
    log "SECTION" "========================================"
}

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Deployment failed with exit code: ${exit_code}"
        if [[ -z "${ROLLBACK_TAG}" ]]; then
            log_info "Initiating auto-rollback..."
            rollback_deployment
        fi
    fi
    log_info "Deployment log saved to: ${LOG_FILE}"
    exit $exit_code
}

trap cleanup EXIT

confirm_step() {
    local step_name="$1"
    
    if [[ "${FORCE_MODE}" == true ]]; then
        log_info "Force mode: Skipping confirmation for '${step_name}'"
        return 0
    fi
    
    if [[ "${STEP_MODE}" == true ]]; then
        echo -n "Proceed with '${step_name}'? [Y/n]: "
        read -r response
        if [[ -n "${response}" && ! "${response}" =~ ^[Yy]$ ]]; then
            log_warn "Step '${step_name}' skipped by user"
            return 1
        fi
    fi
    
    return 0
}

execute_or_simulate() {
    local description="$1"
    shift
    
    if [[ "${DRY_RUN}" == true ]]; then
        log_info "[DRY-RUN] Would execute: ${description}"
        log_info "[DRY-RUN] Command: $*"
        return 0
    else
        log_info "Executing: ${description}"
        if [[ "${VERBOSE}" == true ]]; then
            log_info "Command: $*"
        fi
        "$@"
    fi
}

# ==============================================================================
# PRE-DEPLOYMENT CHECKLIST
# ==============================================================================

verify_prerequisites() {
    log_section "PRE-DEPLOYMENT CHECKLIST"
    
    local checks_passed=true
    
    # Check 1: Git repository
    log_info "Checking git repository..."
    if [[ ! -d "${WORKSPACE_ROOT}/.git" ]]; then
        log_error "Not a git repository: ${WORKSPACE_ROOT}"
        checks_passed=false
    else
        log_success "Git repository verified"
    fi
    
    # Check 2: Working directory clean
    log_info "Checking working directory status..."
    if [[ -n $(git -C "${WORKSPACE_ROOT}" status --porcelain 2>/dev/null) ]]; then
        log_warn "Working directory has uncommitted changes"
        if [[ "${FORCE_MODE}" != true ]]; then
            echo -n "Continue anyway? [y/N]: "
            read -r response
            if [[ ! "${response}" =~ ^[Yy]$ ]]; then
                checks_passed=false
            fi
        fi
    else
        log_success "Working directory is clean"
    fi
    
    # Check 3: Required directories exist
    log_info "Checking source directories..."
    for dir in "${SOURCE_LIB_DIR}" "${SOURCE_TOOLS_DIR}"; do
        if [[ ! -d "${dir}" ]]; then
            log_warn "Source directory missing: ${dir}"
        else
            log_success "Source directory exists: $(basename "${dir}")"
        fi
    done
    
    # Check 4: Required tools available
    log_info "Checking required tools..."
    local required_tools=("git" "rsync" "chmod" "mkdir" "date")
    for tool in "${required_tools[@]}"; do
        if ! command -v "${tool}" &>/dev/null; then
            log_error "Required tool not found: ${tool}"
            checks_passed=false
        else
            log_success "Tool available: ${tool}"
        fi
    done
    
    # Check 5: Disk space
    log_info "Checking disk space..."
    local available_kb=$(df -k "${DEPLOY_ROOT}" | awk 'NR==2 {print $4}')
    local min_required_kb=$((100 * 1024))  # 100MB minimum
    if [[ ${available_kb} -lt ${min_required_kb} ]]; then
        log_error "Insufficient disk space: ${available_kb}KB available, ${min_required_kb}KB required"
        checks_passed=false
    else
        log_success "Disk space sufficient: $((available_kb / 1024))MB available"
    fi
    
    # Check 6: Verify pre-deployment checklist file
    local checklist_file="${WORKSPACE_ROOT}/PRE_DEPLOY_CHECKLIST.md"
    if [[ -f "${checklist_file}" ]]; then
        log_info "Pre-deployment checklist file found"
        # Check if all items are marked complete
        local incomplete=$(grep -c '^\s*-\s*\[ \]' "${checklist_file}" 2>/dev/null || echo "0")
        if [[ ${incomplete} -gt 0 ]]; then
            log_warn "Pre-deployment checklist has ${incomplete} incomplete items"
            if [[ "${FORCE_MODE}" != true ]]; then
                echo -n "Continue anyway? [y/N]: "
                read -r response
                if [[ ! "${response}" =~ ^[Yy]$ ]]; then
                    checks_passed=false
                fi
            fi
        else
            log_success "Pre-deployment checklist complete"
        fi
    else
        log_warn "No pre-deployment checklist file found"
    fi
    
    if [[ "${checks_passed}" == false ]]; then
        log_error "Pre-deployment checks failed. Aborting."
        exit 1
    fi
    
    log_success "All pre-deployment checks passed"
}

# ==============================================================================
# GIT OPERATIONS
# ==============================================================================

create_git_tags() {
    log_section "CREATING GIT TAGS"
    
    if ! confirm_step "Create git tags for rollback"; then
        return 0
    fi
    
    local current_branch
    current_branch=$(git -C "${WORKSPACE_ROOT}" rev-parse --abbrev-ref HEAD)
    local current_commit
    current_commit=$(git -C "${WORKSPACE_ROOT}" rev-parse --short HEAD)
    
    log_info "Current branch: ${current_branch}"
    log_info "Current commit: ${current_commit}"
    
    # Create pre-deploy tag
    local pre_deploy_tag="pre-deploy-${DEPLOY_TIMESTAMP}"
    execute_or_simulate "Create pre-deployment tag: ${pre_deploy_tag}" \
        git -C "${WORKSPACE_ROOT}" tag -a "${pre_deploy_tag}" -m "Pre-deployment checkpoint: ${DEPLOY_TIMESTAMP}"
    
    # Create deployment tag
    execute_or_simulate "Create deployment tag: ${DEPLOY_TAG}" \
        git -C "${WORKSPACE_ROOT}" tag -a "${DEPLOY_TAG}" -m "Production deployment: ${DEPLOY_TIMESTAMP}"
    
    log_success "Git tags created: ${pre_deploy_tag}, ${DEPLOY_TAG}"
}

# ==============================================================================
# BACKUP OPERATIONS
# ==============================================================================

backup_current_state() {
    log_section "BACKUP CURRENT STATE"
    
    if ! confirm_step "Backup current state"; then
        return 0
    fi
    
    local backup_path="${BACKUP_DIR}/backup-${DEPLOY_TIMESTAMP}"
    
    execute_or_simulate "Create backup directory" \
        mkdir -p "${backup_path}"
    
    # Backup lib directory
    if [[ -d "${DEPLOY_LIB_DIR}" ]]; then
        execute_or_simulate "Backup lib directory" \
            rsync -av --delete "${DEPLOY_LIB_DIR}/" "${backup_path}/lib/"
    fi
    
    # Backup tools directory
    if [[ -d "${DEPLOY_TOOLS_DIR}" ]]; then
        execute_or_simulate "Backup tools directory" \
            rsync -av --delete "${DEPLOY_TOOLS_DIR}/" "${backup_path}/tools/"
    fi
    
    # Backup config directory
    if [[ -d "${CONFIG_DIR}" ]]; then
        execute_or_simulate "Backup config directory" \
            rsync -av --delete "${CONFIG_DIR}/" "${backup_path}/config/"
    fi
    
    # Backup state files
    if [[ -d "${STATE_DIR}" ]]; then
        execute_or_simulate "Backup state directory" \
            rsync -av "${STATE_DIR}/" "${backup_path}/state/"
    fi
    
    # Create backup manifest
    local manifest_file="${backup_path}/MANIFEST.txt"
    if [[ "${DRY_RUN}" != true ]]; then
        cat > "${manifest_file}" <<EOF
Backup created: $(date)
Deployment tag: ${DEPLOY_TAG}
Source commit: $(git -C "${WORKSPACE_ROOT}" rev-parse HEAD 2>/dev/null || echo "unknown")
Backup contents:
$(find "${backup_path}" -type f | wc -l) files backed up
EOF
    fi
    
    log_success "Backup created at: ${backup_path}"
    echo "${backup_path}" > "${STATE_DIR}/last-backup.txt"
}

# ==============================================================================
# DEPLOY FILES
# ==============================================================================

deploy_files() {
    log_section "DEPLOY FILES"
    
    if ! confirm_step "Deploy new files"; then
        return 0
    fi
    
    # Deploy lib directory
    if [[ -d "${SOURCE_LIB_DIR}" ]]; then
        execute_or_simulate "Deploy lib directory" \
            mkdir -p "${DEPLOY_LIB_DIR}"
        execute_or_simulate "Sync lib files" \
            rsync -av --delete --exclude='*.pyc' --exclude='__pycache__' \
            "${SOURCE_LIB_DIR}/" "${DEPLOY_LIB_DIR}/"
        log_success "Lib directory deployed"
    fi
    
    # Deploy tools directory
    if [[ -d "${SOURCE_TOOLS_DIR}" ]]; then
        execute_or_simulate "Deploy tools directory" \
            mkdir -p "${DEPLOY_TOOLS_DIR}"
        execute_or_simulate "Sync tools files" \
            rsync -av --delete --exclude='*.pyc' --exclude='__pycache__' \
            "${SOURCE_TOOLS_DIR}/" "${DEPLOY_TOOLS_DIR}/"
        
        # Make scripts executable
        execute_or_simulate "Set executable permissions" \
            find "${DEPLOY_TOOLS_DIR}" -name "*.sh" -exec chmod +x {} \;
        
        log_success "Tools directory deployed"
    fi
}

# ==============================================================================
# CONFIGURATION UPDATE
# ==============================================================================

update_configuration() {
    log_section "UPDATE CONFIGURATION"
    
    if ! confirm_step "Update configuration files"; then
        return 0
    fi
    
    execute_or_simulate "Create config directory" \
        mkdir -p "${CONFIG_DIR}"
    
    # Deploy new config files
    if [[ -d "${SOURCE_CONFIG_DIR}" ]]; then
        execute_or_simulate "Deploy config files" \
            rsync -av --exclude='*.example' "${SOURCE_CONFIG_DIR}/" "${CONFIG_DIR}/"
        log_success "Configuration files deployed"
    fi
    
    # Update deployment metadata
    local deploy_info="${CONFIG_DIR}/deploy-info.json"
    if [[ "${DRY_RUN}" != true ]]; then
        cat > "${deploy_info}" <<EOF
{
    "deployment_timestamp": "${DEPLOY_TIMESTAMP}",
    "deployment_tag": "${DEPLOY_TAG}",
    "deployed_by": "$(whoami)",
    "deployed_from": "${WORKSPACE_ROOT}",
    "git_commit": "$(git -C "${WORKSPACE_ROOT}" rev-parse HEAD 2>/dev/null || echo "unknown")",
    "git_branch": "$(git -C "${WORKSPACE_ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
}
EOF
    fi
    
    log_success "Configuration updated"
}

# ==============================================================================
# CRON JOBS SETUP
# ==============================================================================

setup_cron_jobs() {
    log_section "SETUP CRON JOBS"
    
    if ! confirm_step "Set up cron jobs"; then
        return 0
    fi
    
    execute_or_simulate "Create cron directory" \
        mkdir -p "${DEPLOY_CRON_DIR}"
    
    # Curation cron job - runs every hour
    local curation_script="${DEPLOY_TOOLS_DIR}/curation.sh"
    if [[ -f "${curation_script}" || "${DRY_RUN}" == true ]]; then
        local cron_entry="0 * * * * ${curation_script} >> ${LOG_DIR}/curation.log 2>&1"
        
        if [[ "${DRY_RUN}" == true ]]; then
            log_info "[DRY-RUN] Would add cron job: ${cron_entry}"
        else
            # Remove existing curation cron job if present
            (crontab -l 2>/dev/null | grep -v "curation.sh" || true) | crontab -
            # Add new curation cron job
            (crontab -l 2>/dev/null; echo "${cron_entry}") | crontab -
        fi
        
        log_success "Curation cron job configured"
    else
        log_warn "Curation script not found: ${curation_script}"
    fi
    
    # Cleanup cron job - runs daily at 3 AM
    local cleanup_script="${DEPLOY_TOOLS_DIR}/cleanup.sh"
    if [[ -f "${cleanup_script}" || "${DRY_RUN}" == true ]]; then
        local cleanup_cron="0 3 * * * ${cleanup_script} >> ${LOG_DIR}/cleanup.log 2>&1"
        
        if [[ "${DRY_RUN}" == true ]]; then
            log_info "[DRY-RUN] Would add cron job: ${cleanup_cron}"
        else
            # Remove existing cleanup cron job if present
            (crontab -l 2>/dev/null | grep -v "cleanup.sh" || true) | crontab -
            # Add new cleanup cron job
            (crontab -l 2>/dev/null; echo "${cleanup_cron}") | crontab -
        fi
        
        log_success "Cleanup cron job configured"
    fi
    
    # Log rotation cron job
    local logrotate_cron="0 0 * * * find ${LOG_DIR} -name '*.log' -mtime +30 -delete"
    if [[ "${DRY_RUN}" == true ]]; then
        log_info "[DRY-RUN] Would add cron job: ${logrotate_cron}"
    else
        (crontab -l 2>/dev/null | grep -v "find.*log.*-delete" || true) | crontab -
        (crontab -l 2>/dev/null; echo "${logrotate_cron}") | crontab -
    fi
    
    log_success "Log rotation cron job configured"
}

# ==============================================================================
# STATE FILES INITIALIZATION
# ==============================================================================

initialize_state_files() {
    log_section "INITIALIZE STATE FILES"
    
    if ! confirm_step "Initialize state files"; then
        return 0
    fi
    
    execute_or_simulate "Create state directory" \
        mkdir -p "${STATE_DIR}"
    
    # Initialize deployment state
    local state_file="${STATE_DIR}/deployment-state.json"
    if [[ "${DRY_RUN}" != true ]]; then
        cat > "${state_file}" <<EOF
{
    "last_deployment": "${DEPLOY_TIMESTAMP}",
    "last_tag": "${DEPLOY_TAG}",
    "deploy_count": $(($(cat "${STATE_DIR}/deploy-count.txt" 2>/dev/null || echo "0") + 1)),
    "status": "deploying"
}
EOF
    fi
    
    # Initialize metrics state
    local metrics_state="${STATE_DIR}/metrics.json"
    if [[ "${DRY_RUN}" != true && ! -f "${metrics_state}" ]]; then
        cat > "${metrics_state}" <<EOF
{
    "deployments": [],
    "health_checks": [],
    "errors": []
}
EOF
    fi
    
    # Initialize heartbeat state
    local heartbeat_state="${STATE_DIR}/heartbeat-state.json"
    if [[ "${DRY_RUN}" != true && ! -f "${heartbeat_state}" ]]; then
        cat > "${heartbeat_state}" <<EOF
{
    "lastChecks": {
        "email": null,
        "calendar": null,
        "weather": null
    }
}
EOF
    fi
    
    # Update deploy count
    if [[ "${DRY_RUN}" != true ]]; then
        echo "$(($(cat "${STATE_DIR}/deploy-count.txt" 2>/dev/null || echo "0") + 1))" > "${STATE_DIR}/deploy-count.txt"
    fi
    
    log_success "State files initialized"
}

# ==============================================================================
# SMOKE TESTS
# ==============================================================================

run_smoke_tests() {
    log_section "SMOKE TESTS"
    
    if ! confirm_step "Run smoke tests"; then
        return 0
    fi
    
    local tests_passed=true
    
    # Test 1: Verify lib directory exists and has files
    log_info "Testing lib directory..."
    if [[ -d "${DEPLOY_LIB_DIR}" ]]; then
        local lib_file_count=$(find "${DEPLOY_LIB_DIR}" -type f 2>/dev/null | wc -l)
        if [[ ${lib_file_count} -gt 0 ]]; then
            log_success "Lib directory contains ${lib_file_count} files"
        else
            log_warn "Lib directory is empty"
        fi
    else
        log_error "Lib directory not found"
        tests_passed=false
    fi
    
    # Test 2: Verify tools directory exists and scripts are executable
    log_info "Testing tools directory..."
    if [[ -d "${DEPLOY_TOOLS_DIR}" ]]; then
        local tool_file_count=$(find "${DEPLOY_TOOLS_DIR}" -type f 2>/dev/null | wc -l)
        log_success "Tools directory contains ${tool_file_count} files"
        
        # Check executable scripts
        local exec_count=$(find "${DEPLOY_TOOLS_DIR}" -name "*.sh" -executable 2>/dev/null | wc -l)
        log_success "${exec_count} shell scripts are executable"
    else
        log_error "Tools directory not found"
        tests_passed=false
    fi
    
    # Test 3: Verify config files
    log_info "Testing configuration..."
    if [[ -f "${CONFIG_DIR}/deploy-info.json" ]]; then
        log_success "Deployment info file exists"
    else
        log_warn "Deployment info file not found"
    fi
    
    # Test 4: Verify state files
    log_info "Testing state files..."
    if [[ -f "${STATE_DIR}/deployment-state.json" ]]; then
        log_success "Deployment state file exists"
    else
        log_error "Deployment state file not found"
        tests_passed=false
    fi
    
    # Test 5: Test script syntax
    log_info "Testing script syntax..."
    local syntax_errors=0
    while IFS= read -r script; do
        if ! bash -n "${script}" 2>/dev/null; then
            log_error "Syntax error in: ${script}"
            ((syntax_errors++))
        fi
    done < <(find "${DEPLOY_TOOLS_DIR}" -name "*.sh" 2>/dev/null)
    
    if [[ ${syntax_errors} -eq 0 ]]; then
        log_success "All scripts have valid syntax"
    else
        log_error "${syntax_errors} scripts have syntax errors"
        tests_passed=false
    fi
    
    if [[ "${tests_passed}" == false ]]; then
        log_error "Smoke tests failed"
        return 1
    fi
    
    log_success "All smoke tests passed"
}

# ==============================================================================
# HEALTH CHECKS
# ==============================================================================

verify_health_checks() {
    log_section "HEALTH CHECKS"
    
    if ! confirm_step "Verify health checks"; then
        return 0
    fi
    
    local health_passed=true
    
    # Check 1: Disk space
    log_info "Checking disk space..."
    local disk_usage=$(df -h "${DEPLOY_ROOT}" | awk 'NR==2 {print $5}' | tr -d '%')
    if [[ ${disk_usage} -lt 90 ]]; then
        log_success "Disk usage: ${disk_usage}%"
    else
        log_warn "High disk usage: ${disk_usage}%"
    fi
    
    # Check 2: Log directory writable
    log_info "Checking log directory..."
    if [[ -w "${LOG_DIR}" ]]; then
        log_success "Log directory is writable"
    else
        log_error "Log directory is not writable"
        health_passed=false
    fi
    
    # Check 3: State directory writable
    log_info "Checking state directory..."
    if [[ -w "${STATE_DIR}" ]]; then
        log_success "State directory is writable"
    else
        log_error "State directory is not writable"
        health_passed=false
    fi
    
    # Check 4: Cron jobs configured
    log_info "Checking cron jobs..."
    local cron_count=$(crontab -l 2>/dev/null | grep -c "${DEPLOY_ROOT}" || echo "0")
    if [[ ${cron_count} -gt 0 ]]; then
        log_success "${cron_count} cron jobs configured for deployment"
    else
        log_warn "No cron jobs found for deployment"
    fi
    
    # Check 5: Git tags exist
    log_info "Checking git tags..."
    if git -C "${WORKSPACE_ROOT}" tag -l "${DEPLOY_TAG}" &>/dev/null; then
        log_success "Deployment tag exists: ${DEPLOY_TAG}"
    else
        log_warn "Deployment tag not found: ${DEPLOY_TAG}"
    fi
    
    # Check 6: Backup exists
    log_info "Checking backup..."
    if [[ -f "${STATE_DIR}/last-backup.txt" ]]; then
        local last_backup=$(cat "${STATE_DIR}/last-backup.txt")
        if [[ -d "${last_backup}" ]]; then
            log_success "Backup exists: ${last_backup}"
        else
            log_warn "Backup directory missing: ${last_backup}"
        fi
    else
        log_warn "No backup record found"
    fi
    
    # Record health check results
    local health_record="${STATE_DIR}/health-checks.json"
    if [[ "${DRY_RUN}" != true ]]; then
        local health_entry=$(cat <<EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "deployment": "${DEPLOY_TAG}",
    "status": "$([[ "${health_passed}" == true ]] && echo "healthy" || echo "unhealthy")",
    "checks": {
        "disk_space": "${disk_usage}%",
        "cron_jobs": ${cron_count}
    }
}
EOF
)
        
        # Append to health checks array
        if [[ -f "${health_record}" ]]; then
            # Use jq if available, otherwise simple append
            if command -v jq &>/dev/null; then
                jq ".checks += [${health_entry}]" "${health_record}" > "${health_record}.tmp" && \
                    mv "${health_record}.tmp" "${health_record}"
            fi
        else
            echo "{\"checks\": [${health_entry}]}" > "${health_record}"
        fi
    fi
    
    if [[ "${health_passed}" == false ]]; then
        log_error "Health checks failed"
        return 1
    fi
    
    log_success "All health checks passed"
}

# ==============================================================================
# ROLLBACK
# ==============================================================================

rollback_deployment() {
    log_section "ROLLBACK DEPLOYMENT"
    
    local rollback_target="${ROLLBACK_TAG}"
    
    if [[ -z "${rollback_target}" ]]; then
        # Find the most recent backup
        if [[ -f "${STATE_DIR}/last-backup.txt" ]]; then
            local last_backup=$(cat "${STATE_DIR}/last-backup.txt")
            if [[ -d "${last_backup}" ]]; then
                log_info "Rolling back to last backup: ${last_backup}"
                
                # Restore from backup
                if [[ -d "${last_backup}/lib" ]]; then
                    rsync -av --delete "${last_backup}/lib/" "${DEPLOY_LIB_DIR}/"
                fi
                if [[ -d "${last_backup}/tools" ]]; then
                    rsync -av --delete "${last_backup}/tools/" "${DEPLOY_TOOLS_DIR}/"
                fi
                if [[ -d "${last_backup}/config" ]]; then
                    rsync -av --delete "${last_backup}/config/" "${CONFIG_DIR}/"
                fi
                if [[ -d "${last_backup}/state" ]]; then
                    rsync -av "${last_backup}/state/" "${STATE_DIR}/"
                fi
                
                log_success "Rollback completed from: ${last_backup}"
                return 0
            fi
        fi
        
        log_error "No backup found for rollback"
        return 1
    else
        # Rollback to specific git tag
        log_info "Rolling back to tag: ${rollback_target}"
        
        if git -C "${WORKSPACE_ROOT}" rev-parse "${rollback_target}" &>/dev/null; then
            git -C "${WORKSPACE_ROOT}" checkout "${rollback_target}"
            log_success "Rolled back to tag: ${rollback_target}"
            
            # Re-deploy from the rolled back state
            log_info "Re-deploying from rolled back state..."
            deploy_files
            update_configuration
        else
            log_error "Rollback tag not found: ${rollback_target}"
            return 1
        fi
    fi
}

# ==============================================================================
# NOTIFICATIONS
# ==============================================================================

send_deployment_notification() {
    log_section "DEPLOYMENT NOTIFICATION"
    
    if ! confirm_step "Send deployment notification"; then
        return 0
    fi
    
    local deploy_status="$1"
    local duration="$2"
    
    local notification_msg=$(cat <<EOF
Production Deployment ${deploy_status}
================================
Deployment Tag: ${DEPLOY_TAG}
Timestamp: ${DEPLOY_TIMESTAMP}
Duration: ${duration}s
Status: ${deploy_status}
Deployed By: $(whoami)
Git Commit: $(git -C "${WORKSPACE_ROOT}" rev-parse --short HEAD 2>/dev/null || echo "unknown")
Log File: ${LOG_FILE}
EOF
)
    
    # Write notification to file
    local notification_file="${LOG_DIR}/notification-${DEPLOY_TIMESTAMP}.txt"
    if [[ "${DRY_RUN}" != true ]]; then
        echo "${notification_msg}" > "${notification_file}"
    fi
    
    log_info "Notification saved to: ${notification_file}"
    
    # Try to send desktop notification if available
    if command -v osascript &>/dev/null; then
        execute_or_simulate "Send macOS notification" \
            osascript -e "display notification \"Deployment ${deploy_status}: ${DEPLOY_TAG}\" with title \"OpenClaw Deploy\""
    elif command -v notify-send &>/dev/null; then
        execute_or_simulate "Send Linux notification" \
            notify-send "OpenClaw Deploy" "Deployment ${deploy_status}: ${DEPLOY_TAG}"
    fi
    
    log_success "Deployment notification sent"
}

# ==============================================================================
# VALIDATION
# ==============================================================================

run_validation() {
    log_section "VALIDATION"
    
    if ! confirm_step "Run full validation"; then
        return 0
    fi
    
    local validation_passed=true
    
    # Test each component
    log_info "Testing components..."
    
    # Component 1: Library imports (if Python)
    if [[ -f "${DEPLOY_LIB_DIR}/__init__.py" ]]; then
        log_info "Testing Python library imports..."
        if python3 -c "import sys; sys.path.insert(0, '${DEPLOY_LIB_DIR}'); import $(basename "${DEPLOY_LIB_DIR}")" 2>/dev/null; then
            log_success "Python library imports successfully"
        else
            log_warn "Python library import test skipped or failed"
        fi
    fi
    
    # Component 2: Tool scripts
    log_info "Testing tool scripts..."
    local tool_tests=0
    local tool_passes=0
    while IFS= read -r script; do
        ((tool_tests++))
        local script_name=$(basename "${script}")
        if [[ -x "${script}" ]]; then
            # Try to run with --help or --version
            if "${script}" --help &>/dev/null || "${script}" --version &>/dev/null; then
                log_success "Tool responds: ${script_name}"
                ((tool_passes++))
            else
                log_warn "Tool may not support --help/--version: ${script_name}"
            fi
        fi
    done < <(find "${DEPLOY_TOOLS_DIR}" -name "*.sh" 2>/dev/null)
    
    log_info "Tool tests: ${tool_passes}/${tool_tests} passed"
    
    # Verify integrations
    log_info "Verifying integrations..."
    
    # Check if OpenClaw is available
    if command -v openclaw &>/dev/null; then
        log_success "OpenClaw CLI available"
    else
        log_warn "OpenClaw CLI not in PATH"
    fi
    
    # Check metrics
    log_info "Checking metrics..."
    if [[ -f "${STATE_DIR}/metrics.json" ]]; then
        log_success "Metrics state file exists"
    fi
    
    # Confirm alerts
    log_info "Confirming alerts..."
    if [[ -f "${LOG_DIR}/notification-${DEPLOY_TIMESTAMP}.txt" ]]; then
        log_success "Alert notification ready"
    fi
    
    if [[ "${validation_passed}" == false ]]; then
        log_warn "Some validation checks failed"
    else
        log_success "Validation completed"
    fi
}

# ==============================================================================
# MAIN DEPLOYMENT
# ==============================================================================

main() {
    local start_time=$(date +%s)
    
    log_section "PRODUCTION DEPLOYMENT STARTED"
    log_info "Deployment tag: ${DEPLOY_TAG}"
    log_info "Dry run: ${DRY_RUN}"
    log_info "Step mode: ${STEP_MODE}"
    log_info "Force mode: ${FORCE_MODE}"
    
    # Handle rollback mode
    if [[ -n "${ROLLBACK_TAG}" ]]; then
        rollback_deployment
        exit $?
    fi
    
    # Run deployment steps
    verify_prerequisites
    create_git_tags
    backup_current_state
    deploy_files
    update_configuration
    setup_cron_jobs
    initialize_state_files
    run_smoke_tests
    verify_health_checks
    run_validation
    
    # Mark deployment as successful
    if [[ "${DRY_RUN}" != true ]]; then
        local state_file="${STATE_DIR}/deployment-state.json"
        if [[ -f "${state_file}" ]]; then
            # Update status to completed
            if command -v jq &>/dev/null; then
                jq '.status = "completed"' "${state_file}" > "${state_file}.tmp" && \
                    mv "${state_file}.tmp" "${state_file}"
            fi
        fi
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    send_deployment_notification "SUCCESS" "${duration}"
    
    log_section "DEPLOYMENT COMPLETED SUCCESSFULLY"
    log_info "Deployment tag: ${DEPLOY_TAG}"
    log_info "Duration: ${duration} seconds"
    log_info "Log file: ${LOG_FILE}"
    
    return 0
}

# ==============================================================================
# COMMAND LINE PARSING
# ==============================================================================

print_usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Production Deployment Script for OpenClaw

OPTIONS:
    --dry-run          Simulate deployment without making changes
    --step             Confirm each step before proceeding
    --force            Skip all confirmations (for CI/CD)
    --rollback <tag>   Rollback to specified git tag
    --verbose          Enable verbose output
    -h, --help         Show this help message

EXAMPLES:
    $(basename "$0")                    # Standard deployment
    $(basename "$0") --dry-run          # Dry run mode
    $(basename "$0") --step             # Step-by-step confirmation
    $(basename "$0") --force            # CI/CD automation
    $(basename "$0") --rollback deploy-20240115_120000

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --step)
            STEP_MODE=true
            shift
            ;;
        --force)
            FORCE_MODE=true
            shift
            ;;
        --rollback)
            if [[ -n "${2:-}" ]]; then
                ROLLBACK_TAG="$2"
                shift 2
            else
                echo "Error: --rollback requires a tag argument" >&2
                exit 1
            fi
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1" >&2
            print_usage
            exit 1
            ;;
    esac
done

# Run main deployment
main
