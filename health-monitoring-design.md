# Health Monitoring Visibility & Alerting Design

> **Status:** Design Document  
> **Date:** 2026-05-11  
> **Quality Threshold:** 8.5/10 (Current: 9.26/10)  
> **Priority:** P0-SEC-001 (Critical)

---

## Executive Summary

This document designs a comprehensive health monitoring visibility and alerting system that integrates with our unified session infrastructure (Telegram/WebChat/TUI). The solution provides proactive alerts, cross-device visibility, dashboard integration, and historical trend tracking.

---

## 1. Current State Analysis

### What's Working
- Health monitoring code exists (`openclaw security audit`)
- Daily execution at 22:30 (planned)
- Markdown output files generated
- Quality score tracking (currently 9.26/10)
- Telegram bot configured
- Unified sessions active across devices

### Current Gaps
| Gap | Impact | Severity |
|-----|--------|----------|
| No alerting when issues detected | Silent failures | Critical |
| No cross-device visibility | Missed notifications on secondary devices | High |
| No dashboard view | Hard to track trends | Medium |
| No historical tracking | Can't identify degradation patterns | Medium |
| Manual review required | Delayed response to issues | High |

---

## 2. Design Goals

1. **Proactive Alerting:** Immediate notifications when health checks fail or warnings occur
2. **Cross-Device Visibility:** Notifications reach all active devices (Telegram, WebChat, TUI)
3. **Dashboard Integration:** Central view of system health status
4. **Historical Tracking:** Trend analysis and degradation detection
5. **Minimal Overhead:** Efficient, non-intrusive monitoring

---

## 3. Alerting Mechanism Design

### 3.1 Alert Levels

```
┌─────────────────────────────────────────────────────────┐
│                    ALERT HIERARCHY                      │
├─────────────────────────────────────────────────────────┤
│ 🔴 CRITICAL  → Immediate notification + escalation      │
│ 🟠 WARNING   → Notification within 5 minutes            │
│ 🟡 INFO      → Daily digest only                        │
│ 🟢 HEALTHY   → Silent (logged only)                     │
└─────────────────────────────────────────────────────────┘
```

### 3.2 Alert Triggers

| Severity | Condition | Example |
|----------|-----------|---------|
| CRITICAL | Security audit finds critical issues | New critical vulnerability detected |
| CRITICAL | Quality score drops below threshold | Score < 8.5/10 |
| CRITICAL | Health check fails to run | Cron job failure, missing output |
| WARNING | Security audit finds warnings | Trusted proxies not configured |
| WARNING | Quality score declining trend | 3-day downward trend |
| WARNING | Component health degradation | Response time > 2x baseline |
| INFO | New info-level findings | Attack surface changes |
| INFO | Successful health check completion | Daily confirmation |

### 3.3 Alert Payload Structure

```json
{
  "alertId": "health-2026-05-11-22-30-001",
  "timestamp": "2026-05-11T22:30:00Z",
  "severity": "warning",
  "category": "security",
  "title": "Reverse Proxy Headers Not Trusted",
  "message": "gateway.trustedProxies is empty. If exposing Control UI through reverse proxy, configure trusted proxies.",
  "source": "openclaw-security-audit",
  "checkId": "gateway.trusted_proxies_missing",
  "currentScore": 9.26,
  "threshold": 8.5,
  "affectedComponents": ["gateway"],
  "remediation": "Set gateway.trustedProxies to your proxy IPs",
  "autoResolve": false,
  "links": {
    "dashboard": "/health/dashboard",
    "details": "/health/alerts/health-2026-05-11-22-30-001",
    "docs": "https://docs.openclaw.dev/security/trusted-proxies"
  }
}
```

---

## 4. Notification Channels

### 4.1 Channel Priority Matrix

| Channel | Real-time | Best For | Priority |
|---------|-----------|----------|----------|
| Telegram | Yes | Urgent alerts, mobile visibility | P1 |
| WebChat | Yes | Desktop visibility, rich formatting | P1 |
| TUI | No | Technical details, logs | P2 |
| Email | No | Digest, escalations | P3 |
| Push | Yes | Critical only | P1 |

### 4.2 Telegram Integration

```yaml
# Telegram Notification Config
telegram:
  enabled: true
  botToken: ${TELEGRAM_BOT_TOKEN}
  chatId: ${TELEGRAM_CHAT_ID}
  
  # Alert routing rules
  routing:
    critical:
      - immediate: true
      - format: "rich"  # Markdown with emojis
      - sound: true
    warning:
      - immediate: true
      - format: "rich"
      - sound: false
    info:
      - immediate: false
      - digest: "daily"  # 08:00 daily summary
  
  # Message templates
  templates:
    critical: |
      🔴 *CRITICAL: {{title}}*
      
      {{message}}
      
      *Score:* {{currentScore}}/10 (threshold: {{threshold}})
      *Component:* {{affectedComponents}}
      
      [View Dashboard]({{links.dashboard}})
      
    warning: |
      🟠 *Warning: {{title}}*
      
      {{message}}
      
      *Remediation:* {{remediation}}
```

### 4.3 WebChat Integration

```yaml
# WebChat Notification Config
webchat:
  enabled: true
  
  # UI Components
  components:
    - health-badge: "Top navigation indicator"
    - alert-toast: "Sliding notification panel"
    - health-panel: "Collapsible side panel"
  
  # Real-time updates via WebSocket
  websocket:
    channel: "health-alerts"
    reconnect: true
  
  # Visual indicators
  indicators:
    healthy: "🟢 All systems operational"
    warning: "🟠 {{count}} warnings"
    critical: "🔴 {{count}} critical issues"
```

### 4.4 Unified Session Routing

```javascript
// Unified notification router
class HealthAlertRouter {
  async route(alert) {
    const sessions = await this.getActiveSessions();
    
    for (const session of sessions) {
      const channel = this.determineChannel(session);
      
      if (this.shouldNotify(session, alert)) {
        await this.send(session, channel, alert);
      }
    }
  }
  
  determineChannel(session) {
    // Route based on session type and alert severity
    if (session.type === 'telegram') return 'telegram';
    if (session.type === 'webchat') return 'webchat';
    if (session.type === 'tui') return 'tui';
    return 'default';
  }
  
  shouldNotify(session, alert) {
    // Don't spam: respect quiet hours, deduplicate
    if (alert.severity === 'critical') return true;
    if (session.preferences.muteWarnings) return false;
    return true;
  }
}
```

---

## 5. Dashboard Design

### 5.1 Dashboard Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  🏥 System Health Dashboard                          [Refresh]  │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────┐ │
│  │   SCORE     │  │   STATUS    │  │  LAST RUN   │  │ ALERTS │ │
│  │   9.26/10   │  │   🟢 Healthy│  │  2 min ago  │  │   0    │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  📊 Quality Score Trend (30 days)                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  10 ┤                                          ╭─╮      │   │
│  │   9 ┤                              ╭──────────╯  ╰──╮  │   │
│  │   8 ┤                  ╭──────────╯                  │  │   │
│  │   7 ┤      ╭──────────╯                              │  │   │
│  │     └──────┴──────┴──────┴──────┴──────┴──────┴──────┘  │   │
│  │        11    12    13    14    15    16    17            │   │
│  └─────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│  🔍 Component Health                                            │
│  ┌─────────────────┬──────────┬─────────────┬─────────────┐    │
│  │ Component       │ Status   │ Last Check  │ Issues      │    │
│  ├─────────────────┼──────────┼─────────────┼─────────────┤    │
│  │ Security Audit  │ 🟢 Pass  │ 22:30:05    │ 0 critical  │    │
│  │ Gateway         │ 🟢 Pass  │ 22:30:05    │ 1 warning   │    │
│  │ API Keys        │ 🟢 Pass  │ 22:30:05    │ 0 expired   │    │
│  │ Updates         │ 🟢 Pass  │ 22:30:05    │ Current     │    │
│  └─────────────────┴──────────┴─────────────┴─────────────┘    │
├─────────────────────────────────────────────────────────────────┤
│  📋 Recent Alerts (Last 7 Days)                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ 🟠 2026-05-10  Reverse proxy headers not trusted        │   │
│  │ 🟡 2026-05-09  Attack surface summary updated           │   │
│  │ 🟢 2026-05-08  All checks passed                        │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Dashboard Features

| Feature | Description | Priority |
|---------|-------------|----------|
| Real-time Score | Current quality score with threshold indicator | P0 |
| Trend Chart | 30-day quality score history | P1 |
| Component Status | Individual health check status | P0 |
| Alert History | Filterable alert log | P1 |
| Drill-down | Click for detailed check results | P2 |
| Export | JSON/CSV export of historical data | P2 |

---

## 6. Historical Tracking

### 6.1 Data Model

```typescript
interface HealthSnapshot {
  id: string;                    // UUID
  timestamp: Date;
  score: number;                 // 0-10 quality score
  status: 'healthy' | 'warning' | 'critical';
  
  // Component results
  components: {
    security: SecurityResult;
    gateway: GatewayResult;
    updates: UpdateResult;
    // ...
  };
  
  // Aggregated metrics
  metrics: {
    criticalCount: number;
    warningCount: number;
    infoCount: number;
    checkDuration: number;       // ms
  };
  
  // Raw audit output (compressed)
  rawOutput: CompressedJSON;
}

interface TrendAnalysis {
  period: '7d' | '30d' | '90d';
  averageScore: number;
  trendDirection: 'improving' | 'stable' | 'degrading';
  trendMagnitude: number;        // Score change over period
  volatility: number;            // Standard deviation
  alertsPerDay: number;
  topIssues: Issue[];
}
```

### 6.2 Storage Strategy

```yaml
# Storage tiers
storage:
  # Hot: Recent data, fast access
  hot:
    retention: 7 days
    storage: memory + local json
    useCase: dashboard, real-time alerts
    
  # Warm: Medium-term analysis
  warm:
    retention: 90 days
    storage: sqlite database
    useCase: trend analysis, reports
    
  # Cold: Long-term archival
  cold:
    retention: 2 years
    storage: compressed jsonl files
    useCase: compliance, historical research
```

### 6.3 Trend Detection

```python
# Trend detection algorithm
def detect_trend(snapshots: List[HealthSnapshot]) -> TrendResult:
    scores = [s.score for s in snapshots]
    
    # Calculate moving average
    window_size = 7
    ma = moving_average(scores, window_size)
    
    # Detect trend direction
    slope = calculate_slope(ma[-7:])
    
    # Volatility check
    volatility = std_dev(scores[-7:])
    
    # Alert if degrading
    if slope < -0.1:  # Dropping more than 0.1 per day
        return TrendResult(
            direction='degrading',
            severity='warning' if slope > -0.3 else 'critical',
            message=f"Quality score declining: {slope:.2f} per day"
        )
    
    return TrendResult(direction='stable')
```

---

## 7. Implementation Plan

### Phase 1: Core Alerting (Week 1)

| Task | Owner | Effort | Status |
|------|-------|--------|--------|
| Create alert manager service | @scaffolder | 4h | 🔴 Not Started |
| Telegram notification handler | @scaffolder | 3h | 🔴 Not Started |
| WebChat notification integration | @switch | 4h | 🔴 Not Started |
| Alert payload formatter | @scaffolder | 2h | 🔴 Not Started |
| Cron job wrapper with alerting | @scaffolder | 3h | 🔴 Not Started |

### Phase 2: Dashboard (Week 2)

| Task | Owner | Effort | Status |
|------|-------|--------|--------|
| Dashboard UI component | @switch | 6h | 🔴 Not Started |
| Score trend chart | @switch | 4h | 🔴 Not Started |
| Component status grid | @switch | 3h | 🔴 Not Started |
| Alert history view | @switch | 4h | 🔴 Not Started |

### Phase 3: Historical Tracking (Week 3)

| Task | Owner | Effort | Status |
|------|-------|--------|--------|
| SQLite schema for snapshots | @scaffolder | 3h | 🔴 Not Started |
| Data collection service | @scaffolder | 4h | 🔴 Not Started |
| Trend analysis engine | @scaffolder | 5h | 🔴 Not Started |
| Data retention policies | @scaffolder | 2h | 🔴 Not Started |

### Phase 4: Integration & Polish (Week 4)

| Task | Owner | Effort | Status |
|------|-------|--------|--------|
| Unified session routing | @switch | 4h | 🔴 Not Started |
| Quiet hours configuration | @scaffolder | 2h | 🔴 Not Started |
| Alert deduplication | @scaffolder | 3h | 🔴 Not Started |
| Documentation | @product | 4h | 🔴 Not Started |

---

## 8. Configuration

### 8.1 Health Monitoring Config

```yaml
# health-monitoring.yaml
monitoring:
  enabled: true
  
  schedule:
    cron: "30 22 * * *"  # Daily at 22:30
    timezone: "America/New_York"
  
  thresholds:
    qualityScore:
      critical: 8.5
      warning: 9.0
    
    trend:
      warningDays: 3
      criticalDays: 5
  
  alerting:
    enabled: true
    channels:
      telegram:
        enabled: true
        chatId: ${TELEGRAM_CHAT_ID}
        muteHours: [23, 0, 1, 2, 3, 4, 5, 6, 7]  # Quiet 23:00-08:00
      
      webchat:
        enabled: true
        showBadge: true
        toastDuration: 5000  # ms
      
      tui:
        enabled: true
        showInStatusBar: true
  
  dashboard:
    enabled: true
    defaultView: "overview"
    refreshInterval: 300  # seconds
    historyRange: 30  # days
  
  storage:
    hotRetention: 7  # days
    warmRetention: 90  # days
    coldRetention: 730  # days (2 years)
```

---

## 9. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Alert Latency | < 30 seconds | Time from issue detection to notification |
| False Positive Rate | < 5% | Alerts that don't require action |
| Dashboard Load Time | < 1 second | Time to render dashboard |
| Data Retention | 100% | No gaps in historical data |
| Cross-device Delivery | 99% | Successful notification delivery |

---

## 10. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Alert fatigue | Users ignore alerts | Smart deduplication, severity filtering |
| Notification overload | System spam | Rate limiting, batching, quiet hours |
| Storage growth | Disk space issues | Compression, tiered retention |
| False positives | Loss of trust | Tuning thresholds, confirmation delays |
| Integration complexity | Delayed delivery | Modular design, fallback channels |

---

## 11. Open Questions

1. Should we support custom alert webhooks (Slack, Discord, PagerDuty)?
2. Do we need SMS/phone call escalation for critical issues?
3. Should alerts be acknowledged/resolved manually?
4. Do we need role-based alerting (different people get different alerts)?
5. Should we integrate with external monitoring (Datadog, Grafana)?

---

## 12. Acceptance Criteria

- [x] Design alerting mechanism with severity levels
- [x] Propose notification channels (Telegram, WebChat, TUI)
- [x] Suggest dashboard improvements with mockup
- [x] Recommend historical tracking approach
- [ ] Implement alerting service (Phase 1)
- [ ] Build dashboard UI (Phase 2)
- [ ] Deploy historical tracking (Phase 3)
- [ ] Complete integration testing (Phase 4)

---

## Appendix: Current Health Check Output

```json
{
  "ts": 1778515688418,
  "summary": {
    "critical": 0,
    "warn": 1,
    "info": 1
  },
  "findings": [
    {
      "checkId": "summary.attack_surface",
      "severity": "info",
      "title": "Attack surface summary",
      "detail": "groups: open=0, allowlist=2..."
    },
    {
      "checkId": "gateway.trusted_proxies_missing",
      "severity": "warn",
      "title": "Reverse proxy headers are not trusted",
      "detail": "gateway.bind is loopback and gateway.trustedProxies is empty...",
      "remediation": "Set gateway.trustedProxies to your proxy IPs or keep the Control UI local-only."
    }
  ]
}
```

---

*Document Version: 1.0*  
*Next Review: Upon implementation start*  
*Owner: @product*