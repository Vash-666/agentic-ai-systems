/**
 * Agent Metrics Collector
 * P003-L3-Self-Improve MVP
 * 
 * Collects performance metrics from all 7 agents
 */

export interface AgentMetrics {
  agentId: string;
  timestamp: Date;
  taskCount: number;
  successCount: number;
  failureCount: number;
  averageResponseTime: number;
  tokenUsage: number;
  qualityScore: number;
  errorRate: number;
}

export class AgentMetricsCollector {
  private metrics: Map<string, AgentMetrics[]> = new Map();
  
  // All 7 agents in the system
  private readonly agents = [
    'switch',
    'content', 
    'quality',
    'grok',
    'product',
    'scaffolder',
    'ux'
  ];

  constructor() {
    this.initializeMetrics();
  }

  private initializeMetrics() {
    this.agents.forEach(agent => {
      this.metrics.set(agent, []);
    });
  }

  /**
   * Record a task execution for an agent
   */
  recordTask(
    agentId: string,
    success: boolean,
    responseTime: number,
    tokenUsage: number,
    qualityScore: number
  ): void {
    const agentMetrics = this.metrics.get(agentId) || [];
    
    const lastMetrics = agentMetrics[agentMetrics.length - 1] || {
      taskCount: 0,
      successCount: 0,
      failureCount: 0,
      averageResponseTime: 0,
      tokenUsage: 0,
      qualityScore: 0,
      errorRate: 0
    };

    const newMetrics: AgentMetrics = {
      agentId,
      timestamp: new Date(),
      taskCount: lastMetrics.taskCount + 1,
      successCount: lastMetrics.successCount + (success ? 1 : 0),
      failureCount: lastMetrics.failureCount + (success ? 0 : 1),
      averageResponseTime: this.calculateAverage(
        lastMetrics.averageResponseTime,
        responseTime,
        lastMetrics.taskCount
      ),
      tokenUsage: lastMetrics.tokenUsage + tokenUsage,
      qualityScore: this.calculateAverage(
        lastMetrics.qualityScore,
        qualityScore,
        lastMetrics.taskCount
      ),
      errorRate: (lastMetrics.failureCount + (success ? 0 : 1)) / (lastMetrics.taskCount + 1)
    };

    agentMetrics.push(newMetrics);
    this.metrics.set(agentId, agentMetrics);
    
    // Keep only last 1000 entries per agent
    if (agentMetrics.length > 1000) {
      agentMetrics.shift();
    }
  }

  /**
   * Get metrics for a specific agent
   */
  getMetrics(agentId: string): AgentMetrics[] {
    return this.metrics.get(agentId) || [];
  }

  /**
   * Get latest metrics for all agents
   */
  getAllLatestMetrics(): AgentMetrics[] {
    return this.agents.map(agent => {
      const metrics = this.metrics.get(agent) || [];
      return metrics[metrics.length - 1] || {
        agentId: agent,
        timestamp: new Date(),
        taskCount: 0,
        successCount: 0,
        failureCount: 0,
        averageResponseTime: 0,
        tokenUsage: 0,
        qualityScore: 0,
        errorRate: 0
      };
    });
  }

  /**
   * Get agents that need improvement (error rate > 10%)
   */
  getAgentsNeedingImprovement(): string[] {
    return this.agents.filter(agent => {
      const metrics = this.metrics.get(agent) || [];
      const latest = metrics[metrics.length - 1];
      return latest && latest.errorRate > 0.1;
    });
  }

  /**
   * Export metrics for analysis
   */
  exportMetrics(): Record<string, AgentMetrics[]> {
    const result: Record<string, AgentMetrics[]> = {};
    this.metrics.forEach((value, key) => {
      result[key] = value;
    });
    return result;
  }

  private calculateAverage(currentAvg: number, newValue: number, count: number): number {
    return (currentAvg * count + newValue) / (count + 1);
  }
}

// Singleton instance
export const metricsCollector = new AgentMetricsCollector();
