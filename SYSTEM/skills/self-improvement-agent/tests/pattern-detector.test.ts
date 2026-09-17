/**
 * Pattern Detector Tests
 * P003-L3-Self-Improve Week 1
 * 
 * Target: 80%+ coverage
 */

import { patternDetector, Pattern } from '../src/analyzers/pattern-detector';
import { AgentMetrics } from '../src/collectors/agent-metrics';

describe('PatternDetector', () => {
  const createMetrics = (overrides: Partial<AgentMetrics> = {}): AgentMetrics => ({
    agentId: 'test-agent',
    timestamp: new Date(),
    taskCount: 100,
    successCount: 95,
    failureCount: 5,
    averageResponseTime: 1000,
    tokenUsage: 5000,
    qualityScore: 8.5,
    errorRate: 0.05,
    ...overrides
  });

  describe('detectDegradation', () => {
    it('should detect performance degradation > 15%', () => {
      const metrics: AgentMetrics[] = [
        // Previous window: 90% success
        ...Array(10).fill(null).map(() => createMetrics({ successCount: 90 })),
        // Recent window: 70% success (22% degradation)
        ...Array(10).fill(null).map(() => createMetrics({ successCount: 70 }))
      ];

      const pattern = patternDetector.detectDegradation(metrics);

      expect(pattern).not.toBeNull();
      expect(pattern?.type).toBe('degradation');
      expect(pattern?.severity).toBe('high');
      expect(pattern?.confidence).toBeGreaterThan(0.5);
    });

    it('should not detect degradation < 15%', () => {
      const metrics: AgentMetrics[] = [
        ...Array(10).fill(null).map(() => createMetrics({ successCount: 90 })),
        ...Array(10).fill(null).map(() => createMetrics({ successCount: 85 })) // Only 5.5% degradation
      ];

      const pattern = patternDetector.detectDegradation(metrics);

      expect(pattern).toBeNull();
    });

    it('should return null for insufficient data', () => {
      const metrics = [createMetrics()];
      const pattern = patternDetector.detectDegradation(metrics);
      expect(pattern).toBeNull();
    });
  });

  describe('detectErrorAnomaly', () => {
    it('should detect error rate spike (z-score > 2)', () => {
      const metrics: AgentMetrics[] = [
        // Historical: 5% error rate
        ...Array(10).fill(null).map(() => createMetrics({ errorRate: 0.05 })),
        // Current: 25% error rate
        createMetrics({ errorRate: 0.25 })
      ];

      const pattern = patternDetector.detectErrorAnomaly(metrics);

      expect(pattern).not.toBeNull();
      expect(pattern?.type).toBe('anomaly');
      expect(pattern?.metric).toBe('errorRate');
    });

    it('should not detect normal error rates', () => {
      const metrics: AgentMetrics[] = [
        ...Array(10).fill(null).map(() => createMetrics({ errorRate: 0.05 })),
        createMetrics({ errorRate: 0.06 }) // Normal variation
      ];

      const pattern = patternDetector.detectErrorAnomaly(metrics);

      expect(pattern).toBeNull();
    });
  });

  describe('detectLatencyTrend', () => {
    it('should detect latency increase > 20%', () => {
      const metrics: AgentMetrics[] = [
        // Older: 1000ms average
        ...Array(10).fill(null).map(() => createMetrics({ averageResponseTime: 1000 })),
        // Recent: 1500ms average (50% increase)
        ...Array(10).fill(null).map(() => createMetrics({ averageResponseTime: 1500 }))
      ];

      const pattern = patternDetector.detectLatencyTrend(metrics);

      expect(pattern).not.toBeNull();
      expect(pattern?.type).toBe('trend');
      expect(pattern?.metric).toBe('responseTime');
    });

    it('should require at least 20 data points', () => {
      const metrics = Array(15).fill(null).map(() => createMetrics());
      const pattern = patternDetector.detectLatencyTrend(metrics);
      expect(pattern).toBeNull();
    });
  });

  describe('analyzeAgent', () => {
    it('should return all detected patterns', () => {
      const metrics: AgentMetrics[] = [
        ...Array(20).fill(null).map((_, i) => createMetrics({
          successCount: i < 10 ? 90 : 70, // Degradation
          errorRate: i === 19 ? 0.3 : 0.05, // Anomaly
          averageResponseTime: i < 10 ? 1000 : 1500 // Trend
        }))
      ];

      const patterns = patternDetector.analyzeAgent(metrics);

      expect(patterns.length).toBeGreaterThanOrEqual(1);
      expect(patterns.some(p => p.type === 'degradation')).toBe(true);
    });

    it('should return empty array for healthy agent', () => {
      const metrics = Array(20).fill(null).map(() => createMetrics());
      const patterns = patternDetector.analyzeAgent(metrics);
      expect(patterns).toEqual([]);
    });
  });
});
