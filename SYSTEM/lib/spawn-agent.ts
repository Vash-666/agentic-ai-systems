#!/usr/bin/env ts-node
/**
 * spawn-agent.ts
 * CLI tool and library for spawning agents with automatic model lookup
 * 
 * Usage:
 *   CLI: ts-node spawn-agent.ts --agent=grok --task="Research..." --taskName="research_task"
 *   Lib: import { spawnAgent } from './spawn-agent';
 */

import { sessionsSpawn } from '@openclaw/core'; // Assuming this exists
import { buildSpawnParams, validateSpawnConfig, SpawnConfig } from './agent-spawn-utils';

/**
 * Spawn an agent with automatic model lookup from agent-directory.json
 * 
 * @param config Spawn configuration
 * @returns Promise with spawn result
 */
export async function spawnAgent(config: SpawnConfig): Promise<any> {
  // Validate first
  const errors = validateSpawnConfig(config);
  if (errors.length > 0) {
    console.error('❌ Spawn validation failed:');
    errors.forEach(e => console.error(`   - ${e}`));
    throw new Error(`Invalid spawn configuration: ${errors.join(', ')}`);
  }
  
  // Build params with correct model
  const params = buildSpawnParams(config);
  
  console.log(`🚀 Spawning @${params.agentId}...`);
  console.log(`   Model: ${params.model}`);
  console.log(`   Task: ${params.taskName || 'unnamed'}`);
  
  // Call actual spawn
  // Note: This is a wrapper around the actual sessions_spawn
  // In production, this would call the real OpenClaw API
  const result = await sessionsSpawn({
    agentId: params.agentId,
    task: params.task,
    model: params.model,
    taskName: params.taskName,
    timeoutSeconds: params.timeoutSeconds || 300,
    context: params.context || 'isolated'
  });
  
  console.log(`✅ Spawned @${params.agentId} successfully`);
  
  return result;
}

/**
 * Quick spawn helper with minimal config
 */
export function quickSpawn(agentId: string, task: string, taskName?: string): Promise<any> {
  return spawnAgent({ agentId, task, taskName });
}

/**
 * Spawn with explicit model override (use sparingly)
 */
export function spawnWithModel(
  agentId: string,
  model: string,
  task: string,
  taskName?: string
): Promise<any> {
  console.warn(`⚠️  Using explicit model override for @${agentId}: ${model}`);
  return spawnAgent({ agentId, task, model, taskName });
}

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  
  // Parse CLI args
  const getArg = (flag: string): string | undefined => {
    const idx = args.findIndex(a => a.startsWith(flag));
    return idx !== -1 ? args[idx].split('=')[1] || args[idx + 1] : undefined;
  };
  
  const agentId = getArg('--agent') || getArg('-a');
  const task = getArg('--task') || getArg('-t');
  const taskName = getArg('--taskName') || getArg('-n');
  const model = getArg('--model') || getArg('-m');
  const timeout = parseInt(getArg('--timeout') || '300', 10);
  
  if (!agentId || !task) {
    console.log('Usage: ts-node spawn-agent.ts --agent=<id> --task="<task>" [options]');
    console.log('');
    console.log('Options:');
    console.log('  --agent, -a       Agent ID (required)');
    console.log('  --task, -t        Task description (required)');
    console.log('  --taskName, -n    Task name for tracking');
    console.log('  --model, -m       Override model (not recommended)');
    console.log('  --timeout         Timeout in seconds (default: 300)');
    console.log('');
    console.log('Examples:');
    console.log('  ts-node spawn-agent.ts --agent=grok --task="Research..."');
    console.log('  ts-node spawn-agent.ts -a=quality -t="Audit code" -n="code_audit_001"');
    process.exit(1);
  }
  
  // Run spawn
  spawnAgent({
    agentId,
    task,
    taskName,
    model,
    timeoutSeconds: timeout
  }).then(result => {
    console.log('\n✅ Spawn completed');
    console.log(result);
  }).catch(error => {
    console.error('\n❌ Spawn failed:', error.message);
    process.exit(1);
  });
}
