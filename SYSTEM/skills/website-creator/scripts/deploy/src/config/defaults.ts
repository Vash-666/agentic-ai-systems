import type { DeployInputs } from '../types/index.js';

/**
 * Default configuration values
 */
export const defaults = {
  branch: 'gh-pages',
  isPrivate: false,
  commitMessage: 'Deploy to GitHub Pages',
  gitConfig: {
    userName: 'Website Creator',
    userEmail: 'deploy@website-creator.local',
  },
} as const;

/**
 * Error codes and messages
 */
export const errorCodes = {
  E001: {
    code: 'E001',
    message: 'Build output not found',
    resolution: 'Run build command first (e.g., npm run build)',
  },
  E002: {
    code: 'E002',
    message: 'Missing index.html',
    resolution: 'Ensure build generates an index.html entry point',
  },
  E003: {
    code: 'E003',
    message: 'GitHub authentication failed',
    resolution: 'Check GITHUB_TOKEN environment variable or --token option',
  },
  E004: {
    code: 'E004',
    message: 'Repository creation failed',
    resolution: 'Check permissions and repository name format',
  },
  E005: {
    code: 'E005',
    message: 'Push to GitHub failed',
    resolution: 'Check branch permissions and network connectivity',
  },
  E006: {
    code: 'E006',
    message: 'Domain DNS not configured',
    resolution: 'Add CNAME record to your DNS provider',
  },
  E007: {
    code: 'E007',
    message: 'File too large (>100MB)',
    resolution: 'Use Git LFS or reduce file size before deploying',
  },
  E008: {
    code: 'E008',
    message: 'Deployment timeout',
    resolution: 'Retry deployment or check GitHub status',
  },
  E009: {
    code: 'E009',
    message: 'Invalid input parameters',
    resolution: 'Check required parameters: sourceDir, repoName',
  },
  E010: {
    code: 'E010',
    message: 'Git operation failed',
    resolution: 'Check git configuration and repository state',
  },
} as const;

export type ErrorCode = keyof typeof errorCodes;

/**
 * Get full error message
 */
export function getErrorMessage(code: ErrorCode): string {
  const error = errorCodes[code];
  return `[${error.code}] ${error.message}. ${error.resolution}`;
}