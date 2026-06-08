# Production Deployment Rollback Plan

**Document Version:** 1.0  
**Date:** June 8, 2026  
**Status:** Active  
**Owner:** @product / DevOps Team  
**Review Cycle:** Per-sprint and pre-deployment

---

## Executive Summary

This document provides a comprehensive rollback strategy for the L3 Self-Improving Agentic System production deployment. It covers backup procedures, automated and manual rollback triggers, step-by-step recovery procedures, and communication protocols.

**Rollback Time Objectives:**
- **Automated Rollback:** < 5 minutes
- **Manual Rollback:** < 15 minutes
- **Full System Recovery:** < 30 minutes

---

## Table of Contents

1. [Backup Strategy](#1-backup-strategy)
2. [Rollback Triggers](#2-rollback-triggers)
3. [Rollback Procedures](#3-rollback-procedures)
4. [Communication Plan](#4-communication-plan)
5. [Post-Rollback Validation](#5-post-rollback-validation)
6. [Appendices](#6-appendices)

---

## 1. Backup Strategy

### 1.1 Git Tagging Strategy

Each sprint deployment is tagged for easy rollback:

```bash
# Sprint tagging convention
git tag -a sprint-1 -m "Sprint 1: OpenClaw Integration + Test Suite"
git tag -a sprint-2 -m "Sprint 2: Execution Layer + Auth/Rate Limiting"
git tag -a sprint-3 -m "Sprint 3: Quality Drift Detection + Rule Engine"

# Push tags to remote
git push origin sprint-1 sprint-2 sprint-3
```

**Tag Registry:**

| Tag | Sprint | Deploy Date | Key Features | Rollback Priority |
|-----|--------|-------------|--------------|-------------------|
| `sprint-1` | Week 1-2 | TBD | OpenClaw Integration, 80%+ Test Coverage | P1 - Stable baseline |
| `sprint-2` | Week 3-4 | TBD | Execution Layer, Auth, Rate Limiting | P1 - Security critical |
| `sprint-3` | Week 5-6 | TBD | Quality Drift, Rule Engine | P2 - Feature release |

### 1.2 Pre-Deployment Archive

**Automated Archive Script:** `scripts/archive-pre-deploy.sh`

```bash
#!/bin/bash
# Pre-deployment archive script
set -e

DEPLOY_VERSION=$1
ARCHIVE_DIR="/var/backups/l3-system/$(date +%Y%m%d-%H%M%S)-${DEPLOY_VERSION}"

echo "Creating pre-deployment archive..."
mkdir -p "${ARCHIVE_DIR}"

# Archive source code
git archive --format=tar.gz HEAD > "${ARCHIVE_DIR}/source-code.tar.gz"

# Archive state files
find /var/lib/l3-system -name "*.json" -o -name "*.jsonl" | \
  tar -czf "${ARCHIVE_DIR}/state-files.tar.gz" -T -

# Archive database dump
pg_dump l3_system > "${ARCHIVE_DIR}/database.sql"

# Archive configuration
cp -r /etc/l3-system "${ARCHIVE_DIR}/config"

# Archive environment variables (encrypted)
env | grep L3_ | gpg --encrypt --recipient ops@l3.system > "${ARCHIVE_DIR}/env.gpg"

# Create manifest
cat > "${ARCHIVE_DIR}/MANIFEST.json" <<EOF
{
  "version": "${DEPLOY_VERSION}",
  "timestamp": "$(date -Iseconds)",
  "archiveId": "$(basename ${ARCHIVE_DIR})",
  "contents": {
    "sourceCode": "source-code.tar.gz",
    "stateFiles": "state-files.tar.gz",
    "database": "database.sql",
    "config": "config/",
    "environment": "env.gpg"
  },
  "gitCommit": "$(git rev-parse HEAD)",
  "gitBranch": "$(git branch --show-current)"
}
EOF

echo "Archive created: ${ARCHIVE_DIR}"
echo "Archive ID: $(basename ${ARCHIVE_DIR})"
```

### 1.3 State File Backup

**Critical State Files:**

| File Pattern | Location | Backup Frequency | Retention |
|--------------|----------|------------------|-----------|
| `*.json` | `/var/lib/l3-system/state/` | Real-time replication | 90 days |
| `*.jsonl` | `/var/lib/l3-system/logs/` | Hourly snapshot | 30 days |
| `workflow-*.json` | `/var/lib/l3-system/workflows/` | On change | 90 days |
| `prompt-*.json` | `/var/lib/l3-system/prompts/` | On change | 90 days |
| `config-*.json` | `/etc/l3-system/` | Daily + pre-deploy | 180 days |

**State Backup Script:** `scripts/backup-state.sh`

```bash
#!/bin/bash
# Continuous state backup script

STATE_DIR="/var/lib/l3-system"
BACKUP_DIR="/var/backups/l3-system/state"
S3_BUCKET="s3://l3-system-backups"

# Create timestamped backup
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_PATH="${BACKUP_DIR}/${TIMESTAMP}"

mkdir -p "${BACKUP_PATH}"

# Backup JSON state files
rsync -av --include="*.json" --include="*.jsonl" \
  "${STATE_DIR}/" "${BACKUP_PATH}/"

# Sync to S3
aws s3 sync "${BACKUP_PATH}" "${S3_BUCKET}/state/${TIMESTAMP}/"

# Cleanup old backups (keep last 30)
ls -1t "${BACKUP_DIR}" | tail -n +31 | xargs -I {} rm -rf "${BACKUP_DIR}/{}"

# Verify backup integrity
if aws s3 ls "${S3_BUCKET}/state/${TIMESTAMP}/" > /dev/null; then
  echo "Backup verified: ${TIMESTAMP}"
  echo "${TIMESTAMP}" > "${BACKUP_DIR}/LATEST"
else
  echo "BACKUP FAILED: ${TIMESTAMP}" >&2
  exit 1
fi
```

### 1.4 Working Version Documentation

**Current Working Versions:**

```yaml
# /etc/l3-system/versions.yaml
components:
  api:
    current: "2.1.4"
    stable: "2.1.3"
    rollback_target: "2.1.3"
  
  worker:
    current: "2.1.4"
    stable: "2.1.3"
    rollback_target: "2.1.3"
  
  web:
    current: "2.1.4"
    stable: "2.1.3"
    rollback_target: "2.1.3"
  
  database:
    schema: "v2.1.4"
    compatible_with: ["2.1.3", "2.1.4"]
    rollback_script: "scripts/db-rollback-2.1.4-to-2.1.3.sql"
  
  openclaw_integration:
    version: "1.0.0"
    api_version: "v1"
    
  model:
    default: "moonshot/kimi-k2.5"
    fallback: "moonshot/kimi-k2"

last_updated: "2026-06-08T16:57:00Z"
verified_by: "@product"
```

---

## 2. Rollback Triggers

### 2.1 Automatic Rollback Triggers

| Trigger | Threshold | Evaluation Window | Action |
|---------|-----------|-------------------|--------|
| **Health Check Failures** | > 3 failures | 10 minutes | Immediate rollback |
| **Cost Overrun** | > 200% baseline | 1 hour | Alert + 5min grace, then rollback |
| **Circuit Breaker** | Open > 50% of time | 15 minutes | Immediate rollback |
| **Memory Quality Score** | < 6.0 | 24 hours | Alert + investigation, conditional rollback |
| **Error Rate** | > 5% | 5 minutes | Immediate rollback |
| **Latency P99** | > 2x baseline | 10 minutes | Alert + conditional rollback |
| **Memory Usage** | > 90% | 5 minutes | Alert + conditional rollback |

### 2.2 Manual Rollback Triggers

| Trigger | Source | Response Time | Escalation |
|---------|--------|---------------|------------|
| **User Escalation** | Critical issue reported | Immediate | Page on-call |
| **Security Incident** | Breach or vulnerability | Immediate | Page security team |
| **Data Integrity Issue** | Corruption detected | Immediate | Page DBA + on-call |
| **Compliance Violation** | Policy breach | < 30 minutes | Page compliance officer |
| **Feature Flag Failure** | New feature causing issues | < 15 minutes | Page feature owner |

### 2.3 Trigger Implementation

**Monitoring Query (Prometheus):**

```yaml
# rollback-alerts.yml
groups:
  - name: rollback_triggers
    rules:
      - alert: HighHealthCheckFailureRate
        expr: |
          (
            sum(rate(health_check_failures_total[10m])) 
            / 
            sum(rate(health_check_total[10m]))
          ) > 0.03
        for: 0m
        labels:
          severity: critical
          action: auto_rollback
        annotations:
          summary: "Health check failure rate > 3% in 10m"
          
      - alert: CostOverrun
        expr: |
          (
            sum(rate(cost_usd_total[1h])) 
            / 
            avg_over_time(cost_baseline_usd[1h])
          ) > 2.0
        for: 5m
        labels:
          severity: critical
          action: auto_rollback_with_grace
        annotations:
          summary: "Cost > 200% of baseline"
          
      - alert: CircuitBreakerOpen
        expr: |
          (
            sum_over_time(circuit_breaker_open[15m])
            / 
            15
          ) > 0.5
        for: 0m
        labels:
          severity: critical
          action: auto_rollback
        annotations:
          summary: "Circuit breaker open > 50% of time"
          
      - alert: LowMemoryQualityScore
        expr: |
          avg_over_time(memory_quality_score[24h]) < 6.0
        for: 0m
        labels:
          severity: warning
          action: manual_review
        annotations:
          summary: "Memory quality score < 6.0 for 24h"
```

---

## 3. Rollback Procedures

### 3.1 Quick Rollback Decision Matrix

```
┌─────────────────────────────────────────────────────────────────┐
│                    ROLLBACK DECISION FLOW                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │ Issue        │───▶│ Auto-Trigger?│───▶│ Auto-Rollback│      │
│  │ Detected     │    │              │Yes │ Executed     │      │
│  └──────────────┘    └──────────────┘    └──────────────┘      │
│                             │                                   │
│                             │ No                                │
│                             ▼                                   │
│                      ┌──────────────┐                          │
│                      │ Assess       │                          │
│                      │ Severity     │                          │
│                      └──────────────┘                          │
│                             │                                   │
│            ┌────────────────┼────────────────┐                 │
│            ▼                ▼                ▼                 │
│      ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│      │ Critical │    │ High     │    │ Medium/  │             │
│      │          │    │          │    │ Low      │             │
│      └────┬─────┘    └────┬─────┘    └────┬─────┘             │
│           │               │               │                    │
│           ▼               ▼               ▼                    │\n│      ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│      │ Immediate│    │ 15min    │    │ Patch in │             │
│      │ Rollback │    │ Rollback │    │ Place    │             │
│      │          │    │ or Fix   │    │          │             │
│      └──────────┘    └──────────┘    └──────────┘             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Automated Rollback Script

**Script:** `scripts/rollback-auto.sh`

```bash
#!/bin/bash
# Automated rollback script
# Usage: ./rollback-auto.sh --version sprint-2 --reason "health_check_failure"

set -e

VERSION=""
REASON=""
FORCE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --version) VERSION="$2"; shift 2 ;;
    --reason) REASON="$2"; shift 2 ;;
    --force) FORCE=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$VERSION" || -z "$REASON" ]]; then
  echo "Usage: $0 --version <tag> --reason <reason> [--force]"
  exit 1
fi

ROLLBACK_ID="rollback-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/var/log/l3-system/rollback-${ROLLBACK_ID}.log"

exec > >(tee -a "${LOG_FILE}")
exec 2>&1

echo "========================================"
echo "ROLLBACK INITIATED: ${ROLLBACK_ID}"
echo "Version: ${VERSION}"
echo "Reason: ${REASON}"
echo "Timestamp: $(date -Iseconds)"
echo "========================================"

# 1. Verify version exists
if ! git tag | grep -q "^${VERSION}$"; then
  echo "ERROR: Version tag ${VERSION} not found"
  exit 1
fi

# 2. Create rollback checkpoint
echo "[1/7] Creating rollback checkpoint..."
curl -X POST "https://monitoring.l3.system/api/checkpoints" \
  -H "Authorization: Bearer ${MONITORING_TOKEN}" \
  -d "{\"rollbackId\":\"${ROLLBACK_ID}\",\"fromVersion\":\"$(git describe --tags)\",\"toVersion\":\"${VERSION}\",\"reason\":\"${REASON}\"}"

# 3. Drain connections
echo "[2/7] Draining active connections..."
kubectl patch service l3-api -p '{"spec":{"selector":{"version":"draining"}}}'
sleep 10

# 4. Stop services
echo "[3/7] Stopping services..."
systemctl stop l3-api l3-worker l3-web || true
kubectl scale deployment l3-api --replicas=0
kubectl scale deployment l3-worker --replicas=0

# 5. Restore database (if needed)
echo "[4/7] Checking database rollback..."
CURRENT_DB=$(psql -U l3_system -c "SELECT version FROM schema_migrations ORDER BY id DESC LIMIT 1;" -t)
TARGET_DB=$(git show ${VERSION}:database/schema.version)

if [[ "$CURRENT_DB" != "$TARGET_DB" ]]; then
  echo "Rolling back database from ${CURRENT_DB} to ${TARGET_DB}..."
  psql -U l3_system -f "scripts/db-rollback-${CURRENT_DB}-to-${TARGET_DB}.sql"
fi

# 6. Restore state files
echo "[5/7] Restoring state files..."
if [[ -d "/var/backups/l3-system/latest-state" ]]; then
  rsync -av --delete /var/backups/l3-system/latest-state/ /var/lib/l3-system/
fi

# 7. Deploy previous version
echo "[6/7] Deploying version ${VERSION}..."
git checkout "${VERSION}"
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# 8. Start services
echo "[7/7] Starting services..."
systemctl start l3-api l3-worker l3-web
kubectl scale deployment l3-api --replicas=3
kubectl scale deployment l3-worker --replicas=5

# 9. Verify rollback
echo "Verifying rollback..."
sleep 5

HEALTH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://api.l3.system/health)
if [[ "$HEALTH_STATUS" == "200" ]]; then
  echo "✓ Rollback successful: Health check passed"
  
  # Notify success
  curl -X POST "https://alerts.l3.system/api/rollback-complete" \
    -H "Authorization: Bearer ${ALERTS_TOKEN}" \
    -d "{\"rollbackId\":\"${ROLLBACK_ID}\",\"status\":\"success\",\"version\":\"${VERSION}\"}"
else
  echo "✗ Rollback verification failed: HTTP ${HEALTH_STATUS}"
  
  # Escalate
  curl -X POST "https://pagerduty.l3.system/integration" \
    -H "Authorization: Bearer ${PAGERDUTY_TOKEN}" \
    -d "{\"incident\":{\"title\":\"Rollback Failed\",\"service\":\"l3-system\",\"urgency\":\"high\"}}"
  
  exit 1
fi

echo "========================================"
echo "ROLLBACK COMPLETE: ${ROLLBACK_ID}"
echo "========================================"
```

### 3.3 Manual Rollback Procedure

**Step-by-Step Manual Rollback:**

#### Step 1: Assess and Decide (0-2 minutes)

```bash
# Check current status
curl https://api.l3.system/health | jq .
curl https://api.l3.system/metrics | jq '.summary'

# View recent errors
kubectl logs -l app=l3-api --tail=100 | grep ERROR

# Check if auto-rollback already triggered
curl https://monitoring.l3.system/api/rollbacks/active
```

#### Step 2: Notify Team (2-3 minutes)

```bash
# Send rollback notification
./scripts/notify-rollback.sh \
  --version sprint-2 \
  --reason "Manual: User-reported critical issue" \
  --initiator "$(whoami)"
```

#### Step 3: Create Checkpoint (3-5 minutes)

```bash
# Create rollback checkpoint
ROLLBACK_ID="manual-$(date +%Y%m%d-%H%M%S)"

# Archive current state
./scripts/archive-pre-deploy.sh "pre-${ROLLBACK_ID}"

# Tag current state for potential forward recovery
git tag "pre-rollback-${ROLLBACK_ID}"
git push origin "pre-rollback-${ROLLBACK_ID}"
```

#### Step 4: Execute Rollback (5-10 minutes)

```bash
# Option A: Use automated script
./scripts/rollback-auto.sh --version sprint-2 --reason "manual_rollback" --force

# Option B: Manual steps
git checkout sprint-2
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d

# Restore database if needed
psql -U l3_system -f scripts/db-rollback-current-to-sprint-2.sql

# Restore state files
rsync -av /var/backups/l3-system/sprint-2-state/ /var/lib/l3-system/
```

#### Step 5: Validate Rollback (10-15 minutes)

```bash
# Health checks
./scripts/validate-deployment.sh --version sprint-2

# Smoke tests
./scripts/smoke-tests.sh --environment production

# Verify critical paths
curl -X POST https://api.l3.system/agents/spawn \
  -H "Authorization: Bearer ${TEST_TOKEN}" \
  -d '{"task":"ping","timeout":30}'
```

### 3.4 Service Restart Sequence

**Restart Order:**

```
Phase 1: Stop Services (Reverse dependency order)
  1. Web UI (l3-web)
  2. API Gateway (l3-api)
  3. Background Workers (l3-worker)
  4. Message Queue (redis/rabbitmq) - if needed
  
Phase 2: Data Layer
  1. Verify database rollback (if applicable)
  2. Restore state files
  3. Clear caches
  
Phase 3: Start Services (Dependency order)
  1. Message Queue
  2. Database connections
  3. Background Workers (l3-worker)
  4. API Gateway (l3-api)
  5. Web UI (l3-web)
  
Phase 4: Verification
  1. Health checks on all services
  2. Smoke tests
  3. Circuit breaker reset
```

**Restart Script:** `scripts/restart-sequence.sh`

```bash
#!/bin/bash
# Service restart sequence

ACTION=$1  # "stop" or "start"

if [[ "$ACTION" == "stop" ]]; then
  echo "Stopping services..."
  systemctl stop l3-web
  sleep 2
  systemctl stop l3-api
  sleep 2
  systemctl stop l3-worker
  
elif [[ "$ACTION" == "start" ]]; then
  echo "Starting services..."
  systemctl start l3-worker
  sleep 5
  
  # Verify worker health
  until curl -s http://localhost:8081/health > /dev/null; do
    echo "Waiting for worker..."
    sleep 2
  done
  
  systemctl start l3-api
  sleep 5
  
  # Verify API health
  until curl -s http://localhost:8080/health > /dev/null; do
    echo "Waiting for API..."
    sleep 2
  done
  
  systemctl start l3-web
  sleep 2
  
  echo "All services started"
  
else
  echo "Usage: $0 [stop|start]"
  exit 1
fi
```

---

## 4. Communication Plan

### 4.1 Notification Matrix

| Role | Channel | Trigger | Response Time |
|------|---------|---------|---------------|
| **On-Call Engineer** | PagerDuty + SMS | Any automatic rollback | 5 minutes |
| **Engineering Lead** | Slack #incidents + Email | Any rollback | 15 minutes |
| **Product Manager** | Slack #incidents | Manual or failed rollback | 30 minutes |
| **Engineering Team** | Slack #general | Post-rollback summary | N/A |
| **Users/Customers** | Status Page | Service degradation > 5min | Immediate |
| **Stakeholders** | Email | Post-incident report | Within 4 hours |

### 4.2 Status Page Updates

**Status Page Integration:**

```bash
# Update status page
./scripts/update-status-page.sh \
  --status "degraded" \
  --component "l3-api" \
  --message "We are investigating reports of elevated error rates."

# After rollback
./scripts/update-status-page.sh \
  --status "operational" \
  --component "l3-api" \
  --message "Service has been restored. We are monitoring the situation."
```

**Status Page Templates:**

**Investigating:**
```
🔍 Investigating

We are currently investigating reports of [issue description]. 
We will provide updates as more information becomes available.

Impact: [Service/Feature] may be experiencing [degraded performance/errors].
Started: [Timestamp]
```

**Identified:**
```
⚠️ Issue Identified

We have identified the cause of [issue] and are implementing a fix.
Root cause: [Brief description]
Expected resolution: [ETA]
```

**Monitoring:**
```
✅ Service Restored

We have rolled back to a stable version and service is now operational.
We are monitoring the system closely to ensure stability.

Rollback completed: [Timestamp]
Rollback version: [Version]
```

**Resolved:**
```
✓ Resolved

The issue has been fully resolved. All systems are operational.

Incident duration: [Duration]
Root cause: [Detailed description]
Preventive measures: [Actions taken]
```

### 4.3 User Communication Templates

**In-App Notification (Critical):**
```json
{
  "type": "critical",
  "title": "Service Temporarily Unavailable",
  "message": "We are experiencing technical difficulties. Our team is working to restore service. Estimated resolution: 15 minutes.",
  "dismissible": false,
  "actions": [
    {"label": "View Status", "url": "https://status.l3.system"}
  ]
}
```

**Email to Active Users:**
```
Subject: Service Update - Issue Resolved

Hi [User Name],

We experienced a brief service interruption today from [Start Time] to [End Time]. 
The issue has been resolved and all services are now operational.

What happened:
[Non-technical explanation]

What we did:
[Steps taken to resolve]

What we're doing to prevent this:
[Preventive measures]

We apologize for any inconvenience this may have caused.

The L3 System Team
```

**Slack #incidents Template:**
```
🚨 ROLLBACK INITIATED 🚨

**Time:** [Timestamp]
**Initiated by:** [Name/Auto-trigger]
**Reason:** [Trigger reason]
**From version:** [Current version]
**To version:** [Rollback target]

**Current Status:** [In progress/Complete/Failed]

**Impact:** [Services affected]
**ETA:** [Estimated completion]

Thread for updates ↓
```

### 4.4 Post-Rollback Report Template

```markdown
# Post-Rollback Report

**Rollback ID:** rollback-20260608-165700  
**Date:** June 8, 2026  
**Initiated by:** @on-call-engineer  
**Duration:** 12 minutes

## Summary
Brief description of what happened and why rollback was necessary.

## Timeline
| Time | Event |
|------|-------|
| 16:45 | Issue detected via health check |
| 16:47 | Alert fired to on-call engineer |
| 16:50 | Rollback decision made |
| 16:52 | Rollback initiated |
| 16:57 | Rollback completed |
| 17:00 | Validation passed |

## Root Cause
Detailed explanation of the root cause.

## Impact Assessment
- Users affected: [Number]
- Requests failed: [Number]
- Data loss: [Yes/No, details if yes]

## Rollback Effectiveness
- Rollback successful: [Yes/No]
- Issues during rollback: [Any]
- Time to recovery: [Duration]

## Follow-up Actions
- [ ] Fix root cause
- [ ] Add regression test
- [ ] Update monitoring
- [ ] Review rollback procedures

## Lessons Learned
Key insights and process improvements.
```

---

## 5. Post-Rollback Validation

### 5.1 Validation Checklist

**Immediate (0-5 minutes):**
- [ ] All services report healthy status
- [ ] Health check endpoint returns 200
- [ ] Database connectivity confirmed
- [ ] No critical errors in logs

**Short-term (5-15 minutes):**
- [ ] Smoke tests pass
- [ ] Can spawn test agents
- [ ] Can retrieve execution results
- [ ] API response times normal
- [ ] Error rate < 0.1%

**Medium-term (15-60 minutes):**
- [ ] User traffic flowing normally
- [ ] No spike in error rates
- [ ] Memory usage stable
- [ ] Circuit breakers closed
- [ ] Background jobs processing

**Long-term (1-24 hours):**
- [ ] No regression in metrics
- [ ] User complaints resolved
- [ ] Cost within normal range
- [ ] All integrations functional

### 5.2 Validation Script

**Script:** `scripts/validate-rollback.sh`

```bash
#!/bin/bash
# Post-rollback validation

VERSION=$1
FAILED=0

echo "=== Post-Rollback Validation ==="
echo "Target version: ${VERSION}"
echo ""

# 1. Version check
echo "[1/10] Checking deployed version..."
DEPLOYED_VERSION=$(curl -s https://api.l3.system/version | jq -r '.version')
if [[ "$DEPLOYED_VERSION" == "$VERSION" ]]; then
  echo "✓ Version correct: ${DEPLOYED_VERSION}"
else
  echo "✗ Version mismatch: expected ${VERSION}, got ${DEPLOYED_VERSION}"
  FAILED=1
fi

# 2. Health check
echo "[2/10] Health check..."
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" https://api.l3.system/health)
if [[ "$HEALTH" == "200" ]]; then
  echo "✓ Health check passed"
else
  echo "✗ Health check failed: HTTP ${HEALTH}"
  FAILED=1
fi

# 3. Database connectivity
echo "[3/10] Database connectivity..."
DB_STATUS=$(curl -s https://api.l3.system/health | jq -r '.components.database')
if [[ "$DB_STATUS" == "ok" ]]; then
  echo "✓ Database connected"
else
  echo "✗ Database issue: ${DB_STATUS}"
  FAILED=1
fi

# 4. Agent spawn test
echo "[4/10] Agent spawn test..."
SPAWN_RESULT=$(curl -s -X POST https://api.l3.system/agents/spawn \
  -H "Authorization: Bearer ${TEST_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"task":"validate-rollback","timeout":30}' \
  -w "\n%{http_code}")
SPAWN_HTTP=$(echo "$SPAWN_RESULT" | tail -1)
if [[ "$SPAWN_HTTP" == "200" ]]; then
  echo "✓ Agent spawn successful"
else
  echo "✗ Agent spawn failed: HTTP ${SPAWN_HTTP}"
  FAILED=1
fi

# 5. Response time check
echo "[5/10] Response time check..."
RESPONSE_TIME=$(curl -s -o /dev/null -w "%{time_total}" https://api.l3.system/health)
if (( $(echo "$RESPONSE_TIME < 1.0" | bc -l) )); then
  echo "✓ Response time OK: ${RESPONSE_TIME}s"
else
  echo "✗ Response time high: ${RESPONSE_TIME}s"
  FAILED=1
fi

# 6. Error rate check
echo "[6/10] Error rate check..."
ERROR_RATE=$(curl -s https://api.l3.system/metrics | jq -r '.error_rate_5m')
if (( $(echo "$ERROR_RATE < 0.001" | bc -l) )); then
  echo "✓ Error rate OK: ${ERROR_RATE}"
else
  echo "✗ Error rate high: ${ERROR_RATE}"
  FAILED=1
fi

# 7. Circuit breaker status
echo "[7/10] Circuit breaker status..."
CB_STATUS=$(curl -s https://api.l3.system/metrics | jq -r '.circuit_breaker.open')
if [[ "$CB_STATUS" == "false" ]]; then
  echo "✓ Circuit breakers closed"
else
  echo "✗ Circuit breaker open"
  FAILED=1
fi

# 8. Worker status
echo "[8/10] Worker status..."
WORKERS=$(curl -s https://api.l3.system/metrics | jq -r '.workers.active')
if [[ "$WORKERS" -gt 0 ]]; then
  echo "✓ Workers active: ${WORKERS}"
else
  echo "✗ No active workers"
  FAILED=1
fi

# 9. Memory usage
echo "[9/10] Memory usage..."
MEMORY=$(curl -s https://api.l3.system/metrics | jq -r '.memory.usage_percent')
if (( $(echo "$MEMORY < 80" | bc -l) )); then
  echo "✓ Memory usage OK: ${MEMORY}%"
else
  echo "✗ Memory usage high: ${MEMORY}%"
  FAILED=1
fi

# 10. Integration tests
echo "[10/10] Integration tests..."
if ./scripts/integration-tests.sh --quick; then
  echo "✓ Integration tests passed"
else
  echo "✗ Integration tests failed"
  FAILED=1
fi

echo ""
if [[ $FAILED -eq 0 ]]; then
  echo "=== ✓ ALL VALIDATIONS PASSED ==="
  exit 0
else
  echo "=== ✗ SOME VALIDATIONS FAILED ==="
  exit 1
fi
```

---

## 6. Appendices

### Appendix A: Rollback Runbook Quick Reference

```
┌─────────────────────────────────────────────────────────────────┐
│              EMERGENCY ROLLBACK QUICK REFERENCE                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. ASSESS    → Check /health and /metrics endpoints            │
│                                                                 │
│  2. DECIDE    → Use decision matrix (Section 3.1)              │
│                                                                 │
│  3. NOTIFY    → Post in #incidents channel                      │
│                                                                 │
│  4. EXECUTE   → Run: ./scripts/rollback-auto.sh                │
│                 --version sprint-X --reason "[reason]"          │
│                                                                 │
│  5. VALIDATE  → Run: ./scripts/validate-rollback.sh            │
│                                                                 │
│  6. COMMUNICATE → Update status page, notify users              │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  ESCALATION: If rollback fails, page Engineering Lead           │
│  PagerDuty: https://pagerduty.l3.system                         │
│  Emergency: +1-XXX-XXX-XXXX                                     │
└─────────────────────────────────────────────────────────────────┘
```

### Appendix B: Version Compatibility Matrix

| Version | Database Schema | API Version | Compatible With | Rollback Path |
|---------|-----------------|-------------|-----------------|---------------|
| sprint-3 | v2.1.4 | v1 | sprint-2 | Direct |
| sprint-2 | v2.1.3 | v1 | sprint-1 | Direct |
| sprint-1 | v2.1.2 | v1 | - | Baseline |

### Appendix C: Contact Information

| Role | Primary | Secondary | PagerDuty |
|------|---------|-----------|-----------|
| On-Call Engineer | oncall@l3.system | - | P1 |
| Engineering Lead | lead@l3.system | +1-XXX-XXX-XXXX1 | P2 |
| Product Manager | pm@l3.system | +1-XXX-XXX-XXXX2 | P3 |
| Database Admin | dba@l3.system | +1-XXX-XXX-XXXX3 | P2 |
| Security Team | security@l3.system | +1-XXX-XXX-XXXX4 | P1 |

### Appendix D: Related Documents

- [Health Monitoring Design](/product/health-monitoring-design.md)
- [Action Plan L3](/product/ACTION-PLAN-L3.md)
- [Deployment Runbook](./deployment-runbook.md)
- [Incident Response Plan](./incident-response.md)
- [Database Migration Guide](./database-migrations.md)

---

## Document History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | June 8, 2026 | Initial rollback plan | @product |

---

**Next Review:** Pre-deployment for each sprint  
**Document Owner:** Product Team (@product)  
**Approved By:** Engineering Lead, DevOps Lead
