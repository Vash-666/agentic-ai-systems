/**
 * Meta Agent (@meta)
 * P003-L3-Self-Improve MVP
 * 
 * The self-improvement orchestrator that monitors and improves the system
 */

import { metricsCollector, AgentMetrics } from '../collectors/agent-metrics';
import { patternDetector, Pattern } from '../analyzers/pattern-detector';
import { improvementEngine, ImprovementRecommendation } from '../analyzers/improvement-engine';

export interface MetaAgentStatus {
  isRunning: boolean;
  lastAnalysis: Date;
  agentsMonitored: number;
  patternsDetected: number;
  recommendationsPending: number;
  autoFixesApplied: number;
}

export class MetaAgent {
  private isRunning = false;
  private analysisInterval: NodeJS.Timeout | null = null;
  private readonly agents = ['switch', 'content', 'quality', 'grok', 'product', 'scaffolder', 'ux'];
  private patterns: Map<string, Pattern[]> = new Map();
  private recommendations: ImprovementRecommendation[] = [];
  private autoFixesApplied = 0;

  /**
   * Start the meta-agent monitoring loop
   */
  start(analysisIntervalMs: number = 60000): void {
    if (this.isRunning) {
      console.log('Meta-agent already running');
      return;
    }

    this.isRunning = true;
    console.log('🔄 Meta-agent started');

    // Initial analysis
    this.runAnalysis();

    // Schedule periodic analysis
    this.analysisInterval = setInterval(() => {
      this.runAnalysis();
    }, analysisIntervalMs);
  }

  /**
   * Stop the meta-agent
   */
  stop(): void {
    if (!this.isRunning) return;

    this.isRunning = false;
    if (this.analysisInterval) {
      clearInterval(this.analysisInterval);
      this.analysisInterval = null;
    }
    console.log('⏹️  Meta-agent stopped');
  }

  /**
   * Run one analysis cycle
   */
  private runAnalysis(): void {
    console.log('\n🔍 Running meta-analysis...');

    for (const agentId of this.agents) {
      const metrics = metricsCollector.getMetrics(agentId);
      
      if (metrics.length === 0) continue;

      // Detect patterns
      const detectedPatterns = patternDetector.analyzeAgent(metrics);
      this.patterns.set(agentId, detectedPatterns);

      if (detectedPatterns.length > 0) {
        console.log(`\n📊 ${agentId}:`);
        detectedPatterns.forEach(p => {
          console.log(`  [${p.severity.toUpperCase()}] ${p.description}`);
        });
      }
    }

    // Generate recommendations
    const allPatterns = Array.from(this.patterns.values()).flat();
    this.recommendations = improvementEngine.generateRecommendations(allPatterns);

    // Apply auto-fixes
    this.applyAutoFixes();

    // Log summary
    this.logSummary();
  }

  /**
   * Apply automatic fixes for low-risk recommendations
   */
  private applyAutoFixes(): void {
    for (const rec of this.recommendations) {
      if (rec.autoApply && !rec.humanApprovalRequired) {
        console.log(`\n🔧 Auto-applying: ${rec.id}`);
        console.log(`   ${rec.description}`);
        this.autoFixesApplied++;
        
        // In MVP, just log. In full version, would actually apply changes
        // this.applyChange(rec);
      }
    }
  }

  /**
   * Log analysis summary
   */
  private logSummary(): void {
    const totalPatterns = Array.from(this.patterns.values()).flat().length;
    const criticalRecs = this.recommendations.filter(r => r.priority === 'critical').length;
    const highRecs = this.recommendations.filter(r => r.priority === 'high').length;

    console.log('\n📈 Meta-Analysis Summary:');
    console.log(`   Agents monitored: ${this.agents.length}`);
    console.log(`   Patterns detected: ${totalPatterns}`);
    console.log(`   Recommendations: ${this.recommendations.length}`);
    console.log(`   Critical: ${criticalRecs} | High: ${highRecs}`);
    console.log(`   Auto-fixes applied: ${this.autoFixesApplied}`);
    
    if (this.recommendations.length > 0) {
      console.log('\n💡 Top Recommendations:');
      this.recommendations.slice(0, 3).forEach(rec => {
        console.log(`   [${rec.priority}] ${rec.agentId}: ${rec.description}`);
      });
    }
  }

  /**
   * Get current status
   */
  getStatus(): MetaAgentStatus {
    return {
      isRunning: this.isRunning,
      lastAnalysis: new Date(),
      agentsMonitored: this.agents.length,
      patternsDetected: Array.from(this.patterns.values()).flat().length,
      recommendationsPending: this.recommendations.length,
      autoFixesApplied: this.autoFixesApplied
    };
  }

  /**
   * Get all pending recommendations
   */
  getRecommendations(): ImprovementRecommendation[] {
    return this.recommendations;
  }

  /**
   * Get patterns for a specific agent
   */
  getAgentPatterns(agentId: string): Pattern[] {
    return this.patterns.get(agentId) || [];
  }
}

// Singleton instance
export const metaAgent = new MetaAgent();
