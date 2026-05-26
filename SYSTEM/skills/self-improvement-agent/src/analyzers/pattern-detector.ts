/**
 * Pattern Detector
 * P003-L3-Self-Improve MVP
 * 
 * Detects patterns and anomalies in agent performance
 */

import { AgentMetrics } from '../collectors/agent-metrics';

export interface Pattern {
  type: 'degradation' | 'improvement' | 'anomaly' | 'trend';
  agentId: string;
  metric: string;
  severity: 'low' | 'medium' | 'high';
  description: string;
  confidence: number;
  suggestedAction?: string;
}

export class PatternDetector {
  /**
   * Detect performance degradation
   */
  detectDegradation(
    metrics: AgentMetrics[],
    windowSize: number = 10
  ): Pattern | null {
    if (metrics.length < windowSize * 2) return null;

    const recent = metrics.slice(-windowSize);
    const previous = metrics.slice(-windowSize * 2, -windowSize);

    const recentSuccess = recent.reduce((sum, m) => sum + m.successCount, 0) / recent.length;
    const previousSuccess = previous.reduce((sum, m) => sum + m.successCount, 0) / previous.length;

    const degradation = (previousSuccess - recentSuccess) / previousSuccess;

    if (degradation > 0.15) {
      return {
        type: 'degradation',
        agentId: metrics[0].agentId,
        metric: 'successRate',
        severity: degradation > 0.3 ? 'high' : 'medium',
        description: `Success rate dropped by ${(degradation * 100).toFixed(1)}%`,
        confidence: Math.min(degradation * 2, 0.95),
        suggestedAction: 'Review recent prompt changes or model switches'
      };
    }

    return null;
  }

  /**
   * Detect error rate anomalies
   */
  detectErrorAnomaly(metrics: AgentMetrics[]): Pattern | null {
    if (metrics.length < 5) return null;

    const latest = metrics[metrics.length - 1];
    const historical = metrics.slice(0, -1);
    
    const avgError = historical.reduce((sum, m) => sum + m.errorRate, 0) / historical.length;
    const stdDev = Math.sqrt(
      historical.reduce((sum, m) => sum + Math.pow(m.errorRate - avgError, 2), 0) / historical.length
    );

    const zScore = (latest.errorRate - avgError) / (stdDev || 1);

    if (zScore > 2) {
      return {
        type: 'anomaly',
        agentId: latest.agentId,
        metric: 'errorRate',
        severity: zScore > 3 ? 'high' : 'medium',
        description: `Error rate spike: ${(latest.errorRate * 100).toFixed(1)}% (z-score: ${zScore.toFixed(2)})`,
        confidence: Math.min(zScore / 3, 0.95),
        suggestedAction: 'Check for system issues or task complexity increase'
      };
    }

    return null;
  }

  /**
   * Detect latency trends
   */
  detectLatencyTrend(metrics: AgentMetrics[]): Pattern | null {
    if (metrics.length < 20) return null;

    const recent = metrics.slice(-10);
    const older = metrics.slice(-20, -10);

    const recentAvg = recent.reduce((sum, m) => sum + m.averageResponseTime, 0) / recent.length;
    const olderAvg = older.reduce((sum, m) => sum + m.averageResponseTime, 0) / older.length;

    const increase = (recentAvg - olderAvg) / olderAvg;

    if (increase > 0.2) {
      return {
        type: 'trend',
        agentId: metrics[0].agentId,
        metric: 'responseTime',
        severity: increase > 0.5 ? 'high' : 'medium',
        description: `Response time increased by ${(increase * 100).toFixed(1)}%`,
        confidence: Math.min(increase, 0.9),
        suggestedAction: 'Consider model optimization or task decomposition'
      };
    }

    return null;
  }

  /**
   * Analyze all patterns for an agent
   */
  analyzeAgent(metrics: AgentMetrics[]): Pattern[] {
    const patterns: Pattern[] = [];

    const degradation = this.detectDegradation(metrics);
    if (degradation) patterns.push(degradation);

    const anomaly = this.detectErrorAnomaly(metrics);
    if (anomaly) patterns.push(anomaly);

    const trend = this.detectLatencyTrend(metrics);
    if (trend) patterns.push(trend);

    return patterns;
  }
}

export const patternDetector = new PatternDetector();
