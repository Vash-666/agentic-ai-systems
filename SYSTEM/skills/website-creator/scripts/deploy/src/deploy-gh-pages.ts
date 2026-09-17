import { GitHubClient, getGitHubToken } from './lib/github.js';
import { GitHelper } from './lib/git.js';
import { validateInputs, checkLargeFiles } from './lib/validator.js';
import { verifyBuildOutput } from './lib/build-check.js';
import { defaults, getErrorMessage, type ErrorCode } from './config/defaults.js';
import type { DeployInputs, DeployOutputs, DeploymentProgress } from './types/index.js';
import { ValidationError } from './lib/validator.js';

/**
 * Deployment options with callbacks
 */
export interface DeployOptions extends DeployInputs {
  /** Progress callback */
  onProgress?: (progress: DeploymentProgress) => void;
  /** Verbose logging */
  verbose?: boolean;
}

/**
 * Main deploy function
 */
export async function deploy(options: DeployOptions): Promise<DeployOutputs> {
  const startTime = Date.now();
  const warnings: string[] = [];

  const reportProgress = (status: DeploymentProgress['status'], message: string, percent: number) => {
    options.onProgress?.({ status, message, percent });
    if (options.verbose) {
      console.log(`[${percent}%] ${message}`);
    }
  };

  try {
    // Step 1: Validate inputs
    reportProgress('pending', 'Validating inputs...', 5);
    validateInputs(options);

    // Step 2: Check for large files
    reportProgress('pending', 'Checking for large files...', 10);
    const largeFiles = checkLargeFiles(options.sourceDir);
    if (largeFiles.length > 0) {
      const fileList = largeFiles.map(f => `  - ${f}`).join('\n');
      throw new ValidationError('E007', `Files exceed 100MB limit:\n${fileList}`);
    }

    // Step 3: Verify build output
    reportProgress('pending', 'Verifying build output...', 15);
    const buildCheck = verifyBuildOutput(options.sourceDir);
    if (!buildCheck.valid) {
      throw new ValidationError('E001', buildCheck.errors.join('; '));
    }
    warnings.push(...buildCheck.warnings);

    // Step 4: Initialize GitHub client
    reportProgress('pending', 'Connecting to GitHub...', 20);
    const token = getGitHubToken(options);
    const github = new GitHubClient(token);

    // Step 5: Get or create repository
    reportProgress('building', 'Setting up repository...', 30);
    const user = await github.getAuthenticatedUser();
    const owner = options.repoOwner || user.login;
    
    let repo = await github.getRepo(owner, options.repoName);
    
    if (!repo) {
      reportProgress('building', `Creating repository ${owner}/${options.repoName}...`, 35);
      repo = await github.createRepo(
        options.repoName,
        options.isPrivate ?? defaults.isPrivate,
        options.repoOwner
      );
    }

    // Step 6: Initialize git and copy files
    reportProgress('building', 'Preparing deployment...', 40);
    const git = new GitHelper();
    
    try {
      await git.init(options.gitConfig);
      git.copySource(options.sourceDir);
      
      // Create .nojekyll to disable Jekyll processing
      git.createNoJekyll();
      
      // Create CNAME if custom domain provided
      if (options.customDomain) {
        reportProgress('building', `Setting up custom domain ${options.customDomain}...`, 45);
        git.createCNAME(options.customDomain);
      }

      // Step 7: Commit
      reportProgress('building', 'Creating commit...', 50);
      const commitSha = await git.commit(options.commitMessage || defaults.commitMessage);

      // Step 8: Push
      reportProgress('deploying', 'Pushing to GitHub...', 70);
      const remoteUrl = git.getRemoteUrl(owner, options.repoName, token);
      const branch = options.branch || defaults.branch;
      await git.push(remoteUrl, branch, true);

      // Step 9: Enable Pages
      reportProgress('deploying', 'Enabling GitHub Pages...', 80);
      await github.enablePages(owner, options.repoName, branch);

      // Step 10: Get deployment URL
      reportProgress('deploying', 'Getting deployment URL...', 90);
      const pagesSite = await github.getPagesSite(owner, options.repoName);
      
      // Construct URL
      let url: string;
      if (options.customDomain) {
        url = `https://${options.customDomain}`;
      } else if (pagesSite?.html_url) {
        url = pagesSite.html_url;
      } else {
        url = `https://${owner}.github.io/${options.repoName}`;
      }

      // Create deployment record (optional)
      const deployment = await github.createDeployment(owner, options.repoName, branch);

      const duration = (Date.now() - startTime) / 1000;

      reportProgress('success', 'Deployment complete!', 100);

      return {
        success: true,
        url,
        repoUrl: repo.html_url,
        commitSha,
        deploymentId: deployment?.id,
        timestamp: new Date().toISOString(),
        duration,
        warnings: warnings.length > 0 ? warnings : undefined,
      };

    } finally {
      // Cleanup
      await git.cleanup();
    }

  } catch (error) {
    const duration = (Date.now() - startTime) / 1000;
    
    if (error instanceof ValidationError) {
      return {
        success: false,
        url: '',
        repoUrl: '',
        commitSha: '',
        timestamp: new Date().toISOString(),
        duration,
        errors: [error.message],
      };
    }

    return {
      success: false,
      url: '',
      repoUrl: '',
      commitSha: '',
      timestamp: new Date().toISOString(),
      duration,
      errors: [error instanceof Error ? error.message : 'Unknown error occurred'],
    };
  }
}

/**
 * Deploy with full error handling
 */
export async function deploySafe(options: DeployOptions): Promise<DeployOutputs> {
  try {
    return await deploy(options);
  } catch (error) {
    return {
      success: false,
      url: '',
      repoUrl: '',
      commitSha: '',
      timestamp: new Date().toISOString(),
      duration: 0,
      errors: [error instanceof Error ? error.message : 'Unknown error occurred'],
    };
  }
}

// Export types
export type { DeployInputs, DeployOutputs } from './types/index.js';
export { ValidationError } from './lib/validator.js';
export { defaults, errorCodes, getErrorMessage } from './config/defaults.js';