/**
 * OpenClaw Integration Hooks
 * P003-L3-Self-Improve Week 1
 * 
 * Hooks into sessions_spawn to auto-collect metrics
 */

import { metricsCollector } from '../skills/self-improvement-agent/src/collectors/agent-metrics';

interface SpawnOptions {
  agentId: string;
  task: string;
  model?: string;
  timeoutSeconds?: number;
  startTime?: number;
}

interface SpawnResult {
  success: boolean;
  output?: string;
  error?: string;
  duration: number;
  tokensUsed?: number;
}

/**
 * Wrap a spawn call with metrics collection
 * Use this instead of raw sessions_spawn for L3 monitoring
 */
export async function spawnWithMetrics(
  options: SpawnOptions,
  spawnFn: (opts: SpawnOptions) => Promise<SpawnResult>
): Promise<SpawnResult> {
  const startTime = Date.now();
  const startMemory = process.memoryUsage().heapUsed;
  
  console.log(`[L3] Spawning @${options.agentId} with metrics...`);
  
  try {
    // Execute the actual spawn
    const result = await spawnFn(options);
    
    const duration = Date.now() - startTime;
    const memoryUsed = process.memoryUsage().heapUsed - startMemory;
    
    // Record metrics
    metricsCollector.recordTask(
      options.agentId,
      result.success,
      duration,
      result.tokensUsed || estimateTokens(result.output),
      calculateQualityScore(result)
    );
    
    console.log(`[L3] @${options.agentId} completed in ${duration}ms`);
    
    return result;
  } catch (error) {
    const duration = Date.now() - startTime;
    
    // Record failure
    metricsCollector.recordTask(
      options.agentId,
      false,
      duration,
      0,
      0
    );
    
    console.error(`[L3] @${options.agentId} failed after ${duration}ms`);
    throw error;
  }
}

/**
 * Estimate token usage from output
 */
function estimateTokens(output?: string): number {
  if (!output) return 0;
  // Rough estimate: 1 token ≈ 4 characters
  return Math.ceil(output.length / 4);
}

/**
 * Calculate quality score from result
 */
function calculateQualityScore(result: SpawnResult): number {
  if (!result.success) return 0;
  
  // Base score
  let score = 8.0;
  
  // Bonus for complete output
  if (result.output && result.output.length > 100) {
    score += 0.5;
  }
  
  // Penalty for errors in output
  if (result.output?.includes('error') || result.output?.includes('Error')) {
    score -= 1.0;
  }
  
  return Math.min(score, 10.0);
}

/**
 * Middleware to wrap existing spawn calls
 */
export function createMetricsMiddleware(
  originalSpawn: Function
) {
  return async function wrappedSpawn(options: SpawnOptions) {
    return spawnWithMetrics(options, originalSpawn);
  };
}

/**
 * Patch sessions_spawn to auto-collect metrics
 * Call this once at system startup
 */
export function enableL3Monitoring(): void {
  console.log('[L3] Enabling OpenClaw monitoring hooks...');
  
  // Store reference to original if needed
  const originalSpawn = (global as any).sessionsSpawn;
  
  if (!originalSpawn) {
    console.warn('[L3] sessions_spawn not found in global scope');
    return;
  }
  
  // Wrap with metrics
  (global as any).sessionsSpawn = createMetricsMiddleware(originalSpawn);
  
  console.log('[L3] Monitoring enabled — all spawns will be tracked');
}

/**
 * Check if L3 monitoring is active
 */
export function isL3MonitoringEnabled(): boolean {
  return !!(global as any).l3MonitoringEnabled;
}

// Auto-enable if this module is loaded
if (process.env.ENABLE_L3_MONITORING === 'true') {
  enableL3Monitoring();
}
