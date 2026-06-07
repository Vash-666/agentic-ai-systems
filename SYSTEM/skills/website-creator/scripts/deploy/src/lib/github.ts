import fetch from 'node-fetch';
import type { GitHubRepo, GitHubError, DeployInputs } from '../types/index.js';
import { ValidationError } from './validator.js';

/**
 * GitHub API client
 */
export class GitHubClient {
  private token: string;
  private baseUrl = 'https://api.github.com';

  constructor(token: string) {
    this.token = token;
  }

  /**
   * Get authenticated user
   */
  async getAuthenticatedUser(): Promise<{ login: string }> {
    const response = await this.fetch('/user');
    
    if (!response.ok) {
      throw new ValidationError('E003', `Failed to authenticate: ${response.statusText}`);
    }

    return response.json() as Promise<{ login: string }>;
  }

  /**
   * Get repository
   */
  async getRepo(owner: string, repo: string): Promise<GitHubRepo | null> {
    const response = await this.fetch(`/repos/${owner}/${repo}`);
    
    if (response.status === 404) {
      return null;
    }
    
    if (!response.ok) {
      const error = await response.json() as GitHubError;
      throw new ValidationError('E004', `Failed to get repository: ${error.message}`);
    }

    return response.json() as Promise<GitHubRepo>;
  }

  /**
   * Create repository
   */
  async createRepo(
    name: string, 
    isPrivate: boolean = false,
    org?: string
  ): Promise<GitHubRepo> {
    const endpoint = org 
      ? `/orgs/${org}/repos`
      : '/user/repos';

    const response = await this.fetch(endpoint, {
      method: 'POST',
      body: JSON.stringify({
        name,
        private: isPrivate,
        auto_init: false,
        description: `Website deployed via Website Creator`,
      }),
    });

    if (!response.ok) {
      const error = await response.json() as GitHubError;
      throw new ValidationError('E004', `Failed to create repository: ${error.message}`);
    }

    return response.json() as Promise<GitHubRepo>;
  }

  /**
   * Enable GitHub Pages
   */
  async enablePages(owner: string, repo: string, branch: string = 'gh-pages'): Promise<void> {
    const response = await this.fetch(`/repos/${owner}/${repo}/pages`, {
      method: 'POST',
      body: JSON.stringify({
        source: {
          branch,
          path: '/',
        },
      }),
    });

    // 201 = created, 204 = already enabled, 409 = already enabled with different config
    if (![201, 204, 409].includes(response.status)) {
      const error = await response.json().catch(() => ({ message: response.statusText })) as GitHubError;
      console.warn(`Warning: Could not enable Pages via API: ${error.message}`);
    }
  }

  /**
   * Get Pages site info
   */
  async getPagesSite(owner: string, repo: string): Promise<{ html_url: string; status: string } | null> {
    const response = await this.fetch(`/repos/${owner}/${repo}/pages`);
    
    if (response.status === 404) {
      return null;
    }
    
    if (!response.ok) {
      return null;
    }

    return response.json() as Promise<{ html_url: string; status: string }>;
  }

  /**
   * Create a deployment
   */
  async createDeployment(
    owner: string, 
    repo: string, 
    ref: string
  ): Promise<{ id: number; url: string } | null> {
    try {
      const response = await this.fetch(`/repos/${owner}/${repo}/deployments`, {
        method: 'POST',
        body: JSON.stringify({
          ref,
          environment: 'github-pages',
          auto_merge: false,
          required_contexts: [],
        }),
      });

      if (!response.ok) {
        return null;
      }

      return response.json() as Promise<{ id: number; url: string }>;
    } catch {
      return null;
    }
  }

  /**
   * Make authenticated API request
   */
  private async fetch(
    endpoint: string, 
    options: { method?: string; body?: string } = {}
  ): Promise<ReturnType<typeof fetch>> {
    const url = `${this.baseUrl}${endpoint}`;
    
    return fetch(url, {
      ...options,
      headers: {
        'Authorization': `Bearer ${this.token}`,
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'Content-Type': 'application/json',
        ...((options as Record<string, string>).headers || {}),
      },
    });
  }
}

/**
 * Get GitHub token from inputs or environment
 */
export function getGitHubToken(inputs: Partial<DeployInputs>): string {
  const token = inputs.token || process.env.GITHUB_TOKEN;
  
  if (!token) {
    throw new ValidationError('E003', 'GitHub token not found. Set GITHUB_TOKEN environment variable or use --token option.');
  }

  return token;
}