/**
 * P003-L3-Self-Improve
 * Level 3 Self-Improving Agentic System
 * 
 * Entry point for the meta-cognitive improvement system
 */

import { metaAgent } from './api/meta-agent';

export { metricsCollector, AgentMetrics } from './collectors/agent-metrics';
export { patternDetector, Pattern } from './analyzers/pattern-detector';
export { improvementEngine, ImprovementRecommendation } from './analyzers/improvement-engine';
export { metaAgent, MetaAgentStatus } from './api/meta-agent';

// Version info
export const VERSION = '3.0.0-MVP';
export const SYSTEM_NAME = 'P003-L3-Self-Improve';

/**
 * Initialize and start the self-improvement system
 */
export function initializeL3System(): void {
  console.log(`\n🚀 ${SYSTEM_NAME} v${VERSION}`);
  console.log('Level 3 Self-Improving Agentic System\n');
  
  // Start the meta-agent
  metaAgent.start(60000); // Analyze every 60 seconds
  
  console.log('✅ System initialized');
  console.log('   Monitoring 7 agents for self-improvement opportunities\n');
}

/**
 * Stop the self-improvement system
 */
export function stopL3System(): void {
  metaAgent.stop();
  console.log('✅ System stopped');
}

// Auto-initialize if running as main module
if (require.main === module) {
  initializeL3System();
}
