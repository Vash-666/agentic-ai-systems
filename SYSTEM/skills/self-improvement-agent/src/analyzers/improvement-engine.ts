/**
 * Improvement Engine
 * P003-L3-Self-Improve MVP
 * 
 * Generates improvement recommendations based on patterns
 */

import { Pattern } from './pattern-detector';

export interface ImprovementRecommendation {
  id: string;
  agentId: string;
  type: 'prompt' | 'model' | 'workflow' | 'configuration';
  priority: 'low' | 'medium' | 'high' | 'critical';
  description: string;
  currentState: string;
  proposedChange: string;
  expectedImpact: string;
  riskLevel: 'low' | 'medium' | 'high';
  autoApply: boolean;
  humanApprovalRequired: boolean;
}

export class ImprovementEngine {
  private recommendationCounter = 0;

  /**
   * Generate recommendations from detected patterns
   */
  generateRecommendations(patterns: Pattern[]): ImprovementRecommendation[] {
    const recommendations: ImprovementRecommendation[] = [];

    for (const pattern of patterns) {
      const rec = this.patternToRecommendation(pattern);
      if (rec) recommendations.push(rec);
    }

    return recommendations.sort((a, b) => 
      this.priorityWeight(b.priority) - this.priorityWeight(a.priority)
    );
  }

  private patternToRecommendation(pattern: Pattern): ImprovementRecommendation | null {
    this.recommendationCounter++;
    const id = `REC-${Date.now()}-${this.recommendationCounter}`;

    switch (pattern.type) {
      case 'degradation':
        return {
          id,
          agentId: pattern.agentId,
          type: 'prompt',
          priority: pattern.severity === 'high' ? 'critical' : 'high',
          description: `Address performance degradation in ${pattern.agentId}`,
          currentState: pattern.description,
          proposedChange: 'Review and optimize agent prompts based on recent failure patterns',
          expectedImpact: 'Restore previous performance levels (+15-30% success rate)',
          riskLevel: 'medium',
          autoApply: false,
          humanApprovalRequired: true
        };

      case 'anomaly':
        return {
          id,
          agentId: pattern.agentId,
          type: 'model',
          priority: pattern.severity === 'high' ? 'high' : 'medium',
          description: `Investigate error rate spike in ${pattern.agentId}`,
          currentState: pattern.description,
          proposedChange: 'Switch to fallback model or add retry logic',
          expectedImpact: 'Reduce error rate to baseline (<5%)',
          riskLevel: 'low',
          autoApply: pattern.severity === 'high',
          humanApprovalRequired: pattern.severity !== 'high'
        };

      case 'trend':
        return {
          id,
          agentId: pattern.agentId,
          type: 'workflow',
          priority: pattern.severity === 'high' ? 'high' : 'medium',
          description: `Optimize response time for ${pattern.agentId}`,
          currentState: pattern.description,
          proposedChange: 'Implement task chunking or parallel processing',
          expectedImpact: 'Reduce response time by 20-40%',
          riskLevel: 'medium',
          autoApply: false,
          humanApprovalRequired: true
        };

      default:
        return null;
    }
  }

  private priorityWeight(priority: string): number {
    const weights: Record<string, number> = {
      'critical': 4,
      'high': 3,
      'medium': 2,
      'low': 1
    };
    return weights[priority] || 0;
  }

  /**
   * Format recommendation for display
   */
  formatRecommendation(rec: ImprovementRecommendation): string {
    return `
[${rec.priority.toUpperCase()}] ${rec.id}
Agent: ${rec.agentId} | Type: ${rec.type}
${rec.description}

Current: ${rec.currentState}
Proposed: ${rec.proposedChange}
Expected: ${rec.expectedImpact}
Risk: ${rec.riskLevel} | Auto-apply: ${rec.autoApply ? 'YES' : 'NO'}
${rec.humanApprovalRequired ? '⚠️  REQUIRES HUMAN APPROVAL' : ''}
    `.trim();
  }
}

export const improvementEngine = new ImprovementEngine();
