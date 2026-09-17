/**
 * Deploy Input Configuration
 */
export interface DeployInputs {
  /** Path to built static files (./dist, ./out) */
  sourceDir: string;
  /** GitHub repo name (will be created if doesn't exist) */
  repoName: string;
  /** GitHub username/org (defaults to authenticated user) */
  repoOwner?: string;
  /** Deployment branch (default: 'gh-pages') */
  branch?: string;
  /** Custom commit message */
  commitMessage?: string;
  /** Custom domain CNAME */
  customDomain?: string;
  /** Private repo (default: false) */
  isPrivate?: boolean;
  /** Git configuration */
  gitConfig?: {
    userName: string;
    userEmail: string;
  };
  /** Commands to run before deploy */
  preDeploy?: string[];
  /** Commands to run after deploy */
  postDeploy?: string[];
  /** GitHub token (defaults to GITHUB_TOKEN env var) */
  token?: string;
}

/**
 * Deploy Output Result
 */
export interface DeployOutputs {
  /** Whether deployment was successful */
  success: boolean;
  /** Live website URL */
  url: string;
  /** GitHub repository URL */
  repoUrl: string;
  /** Deployed commit hash */
  commitSha: string;
  /** GitHub deployment ID */
  deploymentId?: string;
  /** ISO timestamp */
  timestamp: string;
  /** Deployment time in seconds */
  duration: number;
  /** Any errors encountered */
  errors?: string[];
  /** Warning messages */
  warnings?: string[];
}

/**
 * GitHub API Repository
 */
export interface GitHubRepo {
  id: number;
  name: string;
  full_name: string;
  html_url: string;
  clone_url: string;
  ssh_url: string;
  private: boolean;
  default_branch: string;
  created_at: string;
  updated_at: string;
}

/**
 * GitHub API Error
 */
export interface GitHubError {
  message: string;
  documentation_url?: string;
  errors?: Array<{
    resource: string;
    field: string;
    code: string;
    message?: string;
  }>;
}

/**
 * Deployment Status
 */
export type DeploymentStatus = 
  | 'pending'
  | 'building'
  | 'deploying'
  | 'success'
  | 'failure'
  | 'error';

/**
 * Deployment Progress
 */
export interface DeploymentProgress {
  status: DeploymentStatus;
  message: string;
  percent: number;
}