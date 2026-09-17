/**
 * Agent Spawn Utilities
 * Automatic model lookup from agent-directory.json
 * 
 * Usage:
 *   import { spawnAgent } from './agent-spawn-utils';
 *   await spawnAgent({ agentId: 'grok', task: '...' });
 */

import { readFileSync } from 'fs';
import { resolve } from 'path';

interface AgentConfig {
  id: string;
  name: string;
  handle: string;
  model: string;
  preferred_model?: string;
  quality: number;
  status: string;
}

interface AgentDirectory {
  version: string;
  updated: string;
  agents: Record<string, AgentConfig>;
}

let cachedDirectory: AgentDirectory | null = null;
let cacheTimestamp: number = 0;
const CACHE_TTL = 60000; // 1 minute

/**
 * Load and cache agent directory
 */
function loadAgentDirectory(): AgentDirectory {
  const now = Date.now();
  
  // Return cached if fresh
  if (cachedDirectory && (now - cacheTimestamp) < CACHE_TTL) {
    return cachedDirectory;
  }
  
  try {
    const workspaceRoot = process.env.WORKSPACE_ROOT || '/Users/rohitvashist/.openclaw/workspace';
    const configPath = resolve(workspaceRoot, 'agent-directory.json');
    const configData = readFileSync(configPath, 'utf-8');
    const directory: AgentDirectory = JSON.parse(configData);
    
    cachedDirectory = directory;
    cacheTimestamp = now;
    
    return directory;
  } catch (error) {
    console.error('Failed to load agent-directory.json:', error);
    throw new Error('Agent directory not found. Ensure agent-directory.json exists in workspace root.');
  }
}

/**
 * Get agent configuration by ID
 */
export function getAgentConfig(agentId: string): AgentConfig {
  const directory = loadAgentDirectory();
  const agent = directory.agents[agentId];
  
  if (!agent) {
    throw new Error(`Agent '${agentId}' not found in agent-directory.json`);
  }
  
  return agent;
}

/**
 * Get the appropriate model for an agent
 * Uses preferred_model if available, falls back to model
 */
export function getAgentModel(agentId: string): string {
  const agent = getAgentConfig(agentId);
  return agent.preferred_model || agent.model;
}

/**
 * Spawn configuration for an agent
 * Automatically includes correct model
 */
export interface SpawnConfig {
  agentId: string;
  task: string;
  taskName?: string;
  timeoutSeconds?: number;
  context?: 'isolated' | 'fork';
  // Allow override but warn
  model?: string;
}

/**
 * Build spawn parameters with automatic model lookup
 */
export function buildSpawnParams(config: SpawnConfig): {
  agentId: string;
  task: string;
  model: string;
  taskName?: string;
  timeoutSeconds?: number;
  context?: 'isolated' | 'fork';
} {
  const agent = getAgentConfig(config.agentId);
  const correctModel = agent.preferred_model || agent.model;
  
  // Warn if model override doesn't match
  if (config.model && config.model !== correctModel) {
    console.warn(`⚠️  Model override for ${config.agentId}:`);
    console.warn(`   Expected: ${correctModel}`);
    console.warn(`   Override: ${config.model}`);
    console.warn(`   Using override, but this may not be intended.`);
  }
  
  return {
    agentId: config.agentId,
    task: config.task,
    model: config.model || correctModel,
    taskName: config.taskName,
    timeoutSeconds: config.timeoutSeconds,
    context: config.context
  };
}

/**
 * Validate spawn configuration
 */
export function validateSpawnConfig(config: SpawnConfig): string[] {
  const errors: string[] = [];
  
  try {
    const agent = getAgentConfig(config.agentId);
    
    if (agent.status !== 'active') {
      errors.push(`Agent '${config.agentId}' is not active (status: ${agent.status})`);
    }
    
    const correctModel = agent.preferred_model || agent.model;
    if (config.model && config.model !== correctModel) {
      errors.push(`Model mismatch for '${config.agentId}': expected ${correctModel}, got ${config.model}`);
    }
  } catch (error) {
    errors.push(`Agent '${config.agentId}' not found in directory`);
  }
  
  return errors;
}

// Export for direct use
export { loadAgentDirectory };
export type { AgentConfig, AgentDirectory };
