import { simpleGit, SimpleGit, CleanOptions } from 'simple-git';
import { mkdtempSync, writeFileSync, existsSync, copyFileSync, mkdirSync, readdirSync, statSync } from 'fs';
import { tmpdir } from 'os';
import { join, resolve } from 'path';
import type { DeployInputs } from '../types/index.js';
import { ValidationError } from './validator.js';
import { sanitizeCommitMessage } from './validator.js';

/**
 * Git operations helper
 */
export class GitHelper {
  private git: SimpleGit;
  private tempDir: string;

  constructor() {
    this.tempDir = mkdtempSync(join(tmpdir(), 'deploy-gh-pages-'));
    this.git = simpleGit(this.tempDir);
  }

  /**
   * Get temp directory path
   */
  getTempDir(): string {
    return this.tempDir;
  }

  /**
   * Initialize git repo
   */
  async init(gitConfig?: DeployInputs['gitConfig']): Promise<void> {
    await this.git.init();
    await this.git.addConfig('user.name', gitConfig?.userName || 'Website Creator');
    await this.git.addConfig('user.email', gitConfig?.userEmail || 'deploy@website-creator.local');
  }

  /**
   * Copy source files to temp directory
   */
  copySource(sourceDir: string): void {
    const copyRecursive = (src: string, dest: string) => {
      const entries = readdirSync(src, { withFileTypes: true });
      
      for (const entry of entries) {
        const srcPath = join(src, entry.name);
        const destPath = join(dest, entry.name);
        
        if (entry.isDirectory()) {
          if (!existsSync(destPath)) {
            mkdirSync(destPath, { recursive: true });
          }
          copyRecursive(srcPath, destPath);
        } else {
          copyFileSync(srcPath, destPath);
        }
      }
    };

    copyRecursive(resolve(sourceDir), this.tempDir);
  }

  /**
   * Create CNAME file for custom domain
   */
  createCNAME(domain: string): void {
    const cnamePath = join(this.tempDir, 'CNAME');
    writeFileSync(cnamePath, domain, 'utf-8');
  }

  /**
   * Create .nojekyll file to disable Jekyll processing
   */
  createNoJekyll(): void {
    const nojekyllPath = join(this.tempDir, '.nojekyll');
    writeFileSync(nojekyllPath, '', 'utf-8');
  }

  /**
   * Add and commit all files
   */
  async commit(message: string): Promise<string> {
    await this.git.add('.');
    const result = await this.git.commit(sanitizeCommitMessage(message));
    return result.commit || 'unknown';
  }

  /**
   * Push to remote
   */
  async push(remoteUrl: string, branch: string, force: boolean = true): Promise<void> {
    try {
      // Add remote
      await this.git.addRemote('origin', remoteUrl);
      
      // Push
      const pushArgs = ['origin', `HEAD:${branch}`];
      if (force) {
        pushArgs.unshift('--force');
      }
      
      await this.git.push(pushArgs);
    } catch (error) {
      throw new ValidationError('E005', `Push failed: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Get remote URL with token
   */
  getRemoteUrl(owner: string, repo: string, token: string): string {
    return `https://${token}@github.com/${owner}/${repo}.git`;
  }

  /**
   * Clean up temp directory
   */
  async cleanup(): Promise<void> {
    try {
      await this.git.clean(CleanOptions.FORCE + CleanOptions.RECURSIVE + CleanOptions.IGNORED_INCLUDED);
    } catch {
      // Ignore cleanup errors
    }
  }
}

/**
 * Execute pre-deploy commands
 */
export async function runPreDeploy(commands: string[], cwd: string): Promise<void> {
  const { execa } = await import('execa');
  
  for (const command of commands) {
    try {
      const [cmd, ...args] = command.split(' ');
      await execa(cmd, args, { cwd });
    } catch (error) {
      throw new ValidationError('E010', `Pre-deploy command failed: ${command}. ${error instanceof Error ? error.message : ''}`);
    }
  }
}

/**
 * Execute post-deploy commands
 */
export async function runPostDeploy(commands: string[], cwd: string): Promise<void> {
  const { execa } = await import('execa');
  
  for (const command of commands) {
    try {
      const [cmd, ...args] = command.split(' ');
      await execa(cmd, args, { cwd });
    } catch (error) {
      console.warn(`Warning: Post-deploy command failed: ${command}. ${error instanceof Error ? error.message : ''}`);
    }
  }
}