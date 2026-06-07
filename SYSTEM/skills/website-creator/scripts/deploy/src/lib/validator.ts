import { existsSync, statSync } from 'fs';
import { join } from 'path';
import type { DeployInputs } from '../types/index.js';
import { getErrorMessage, type ErrorCode } from '../config/defaults.js';

/**
 * Validation error
 */
export class ValidationError extends Error {
  constructor(
    public code: ErrorCode,
    message?: string
  ) {
    super(message || getErrorMessage(code));
    this.name = 'ValidationError';
  }
}

/**
 * Validate deploy inputs
 */
export function validateInputs(inputs: Partial<DeployInputs>): asserts inputs is DeployInputs {
  const errors: string[] = [];

  // Required: sourceDir
  if (!inputs.sourceDir) {
    errors.push('sourceDir is required');
  }

  // Required: repoName
  if (!inputs.repoName) {
    errors.push('repoName is required');
  }

  if (errors.length > 0) {
    throw new ValidationError('E009', errors.join('; '));
  }

  // Validate sourceDir exists
  if (!existsSync(inputs.sourceDir!)) {
    throw new ValidationError('E001', `Source directory not found: ${inputs.sourceDir}`);
  }

  const stats = statSync(inputs.sourceDir!);
  if (!stats.isDirectory()) {
    throw new ValidationError('E001', `Source path is not a directory: ${inputs.sourceDir}`);
  }

  // Validate index.html exists
  const indexPath = join(inputs.sourceDir!, 'index.html');
  if (!existsSync(indexPath)) {
    throw new ValidationError('E002', `index.html not found in ${inputs.sourceDir}`);
  }

  // Validate repoName format
  const repoNameRegex = /^[a-zA-Z0-9._-]+$/;
  if (!repoNameRegex.test(inputs.repoName!)) {
    throw new ValidationError('E004', `Invalid repository name: ${inputs.repoName}. Use alphanumeric characters, hyphens, underscores, or dots.`);
  }

  // Validate custom domain if provided
  if (inputs.customDomain) {
    const domainRegex = /^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?:\.[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])*$/;
    if (!domainRegex.test(inputs.customDomain)) {
      throw new ValidationError('E006', `Invalid custom domain format: ${inputs.customDomain}`);
    }
  }
}

/**
 * Check for large files (>100MB)
 */
export function checkLargeFiles(dir: string): string[] {
  const largeFiles: string[] = [];
  const MAX_SIZE = 100 * 1024 * 1024; // 100MB

  function scanDirectory(currentDir: string) {
    const entries = require('fs').readdirSync(currentDir, { withFileTypes: true });
    
    for (const entry of entries) {
      const fullPath = join(currentDir, entry.name);
      
      if (entry.isDirectory()) {
        scanDirectory(fullPath);
      } else if (entry.isFile()) {
        const stats = statSync(fullPath);
        if (stats.size > MAX_SIZE) {
          largeFiles.push(fullPath);
        }
      }
    }
  }

  scanDirectory(dir);
  return largeFiles;
}

/**
 * Sanitize commit message
 */
export function sanitizeCommitMessage(message: string): string {
  // Remove newlines and limit length
  return message
    .replace(/[\r\n]/g, ' ')
    .trim()
    .slice(0, 72);
}