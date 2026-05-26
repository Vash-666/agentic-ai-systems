/**
 * Config Executor
 * P003-L3-Self-Improve Week 1
 * 
 * Actually modifies agent configurations safely
 */

import { readFileSync, writeFileSync, existsSync, copyFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { mkdirSync } from 'fs';

export interface ConfigChange {
  id: string;
  agentId: string;
  changeType: 'model' | 'prompt' | 'timeout' | 'enabled';
  previousValue: any;
  newValue: any;
  reason: string;
  timestamp: Date;
  approvedBy?: string;
}

export interface RollbackPoint {
  id: string;
  timestamp: Date;
  changes: ConfigChange[];
  configSnapshot: Record<string, any>;
}

export class ConfigExecutor {
  private readonly backupDir: string;
  private readonly configPath: string;
  private changes: ConfigChange[] = [];
  private rollbackPoints: Map<string, RollbackPoint> = new Map();

  constructor(
    configPath: string = '/Users/rohitvashist/.openclaw/workspace/agent-directory.json',
    backupDir: string = '/Users/rohitvashist/.openclaw/workspace/.l3-backups'
  ) {
    this.configPath = configPath;
    this.backupDir = backupDir;
    this.ensureBackupDir();
  }

  private ensureBackupDir(): void {
    if (!existsSync(this.backupDir)) {
      mkdirSync(this.backupDir, { recursive: true });
    }
  }

  /**
   * Create a rollback point before making changes
   */
  createRollbackPoint(changeId: string): RollbackPoint {
    const config = this.readConfig();
    const snapshot = JSON.parse(JSON.stringify(config)); // Deep copy
    
    const rollbackPoint: RollbackPoint = {
      id: changeId,
      timestamp: new Date(),
      changes: [],
      configSnapshot: snapshot
    };

    this.rollbackPoints.set(changeId, rollbackPoint);
    
    // Also save to disk
    const backupPath = resolve(this.backupDir, `backup-${changeId}-${Date.now()}.json`);
    writeFileSync(backupPath, JSON.stringify(snapshot, null, 2));
    
    console.log(`[L3] Rollback point created: ${changeId}`);
    
    return rollbackPoint;
  }

  /**
   * Execute a config change
   */
  executeChange(change: ConfigChange, skipApproval: boolean = false): boolean {
    // Check if approval required
    if (!skipApproval && !change.approvedBy) {
      console.error(`[L3] Change ${change.id} requires human approval`);
      return false;
    }

    // Create rollback point if not exists
    if (!this.rollbackPoints.has(change.id)) {
      this.createRollbackPoint(change.id);
    }

    try {
      const config = this.readConfig();
      const agent = config.agents[change.agentId];
      
      if (!agent) {
        console.error(`[L3] Agent ${change.agentId} not found`);
        return false;
      }

      // Store previous value
      change.previousValue = agent[change.changeType];
      
      // Apply change
      agent[change.changeType] = change.newValue;
      
      // Save config
      writeFileSync(this.configPath, JSON.stringify(config, null, 2));
      
      // Record change
      this.changes.push(change);
      
      console.log(`[L3] Change applied: ${change.agentId}.${change.changeType} = ${change.newValue}`);
      
      return true;
    } catch (error) {
      console.error(`[L3] Failed to apply change ${change.id}:`, error);
      return false;
    }
  }

  /**
   * Rollback to a specific point
   */
  rollback(changeId: string): boolean {
    const rollbackPoint = this.rollbackPoints.get(changeId);
    
    if (!rollbackPoint) {
      console.error(`[L3] Rollback point ${changeId} not found`);
      return false;
    }

    try {
      writeFileSync(
        this.configPath,
        JSON.stringify(rollbackPoint.configSnapshot, null, 2)
      );
      
      console.log(`[L3] Rolled back to: ${changeId}`);
      
      return true;
    } catch (error) {
      console.error(`[L3] Rollback failed:`, error);
      return false;
    }
  }

  /**
   * Get change history
   */
  getChangeHistory(agentId?: string): ConfigChange[] {
    if (agentId) {
      return this.changes.filter(c => c.agentId === agentId);
    }
    return this.changes;
  }

  /**
   * Check if change is safe (basic validation)
   */
  isSafeChange(change: ConfigChange): boolean {
    // Don't allow model changes to invalid models
    if (change.changeType === 'model') {
      const validModels = [
        'moonshot/kimi-k2.5',
        'google/gemini-2.5-flash',
        'anthropic/claude-sonnet-4-5',
        'xai/grok-4.20-reasoning',
        'deepseek/deepseek-chat'
      ];
      
      if (!validModels.includes(change.newValue)) {
        console.warn(`[L3] Invalid model: ${change.newValue}`);
        return false;
      }
    }

    // Don't disable core agents
    if (change.changeType === 'enabled' && change.agentId === 'switch') {
      console.warn('[L3] Cannot disable @switch');
      return false;
    }

    return true;
  }

  private readConfig(): any {
    const content = readFileSync(this.configPath, 'utf-8');
    return JSON.parse(content);
  }
}

// Singleton instance
export const configExecutor = new ConfigExecutor();
