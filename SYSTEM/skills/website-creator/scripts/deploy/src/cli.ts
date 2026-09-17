#!/usr/bin/env node

import { Command } from 'commander';
import chalk from 'chalk';
import ora from 'ora';
import { deploy } from './deploy-gh-pages.js';
import type { DeployInputs } from './types/index.js';
import { verifyBuildOutput, getBuildSummary } from './lib/build-check.js';

const program = new Command();

program
  .name('deploy-gh-pages')
  .description('Deploy static websites to GitHub Pages')
  .version('1.0.0');

program
  .command('deploy')
  .description('Deploy a static site to GitHub Pages')
  .requiredOption('-s, --source <path>', 'Source directory containing built files')
  .requiredOption('-r, --repo <name>', 'GitHub repository name')
  .option('-o, --owner <name>', 'GitHub username or organization')
  .option('-b, --branch <name>', 'Deployment branch', 'gh-pages')
  .option('-m, --message <text>', 'Custom commit message', 'Deploy to GitHub Pages')
  .option('-d, --domain <domain>', 'Custom domain (CNAME)')
  .option('-p, --private', 'Create as private repository', false)
  .option('-t, --token <token>', 'GitHub token (or set GITHUB_TOKEN env var)')
  .option('--dry-run', 'Validate without deploying')
  .option('--verbose', 'Verbose output')
  .action(async (options) => {
    const inputs: DeployInputs = {
      sourceDir: options.source,
      repoName: options.repo,
      repoOwner: options.owner,
      branch: options.branch,
      commitMessage: options.message,
      customDomain: options.domain,
      isPrivate: options.private,
      token: options.token,
    };

    // Dry run - just validate
    if (options.dryRun) {
      console.log(chalk.blue('🔍 Dry run mode - validating only\n'));
      
      try {
        const { validateInputs } = await import('./lib/validator.js');
        validateInputs(inputs);
        console.log(chalk.green('✓ Inputs valid'));
        
        const summary = getBuildSummary(inputs.sourceDir);
        console.log('\n' + summary);
        return;
      } catch (error) {
        console.error(chalk.red('✗ Validation failed:'));
        console.error(error instanceof Error ? error.message : 'Unknown error');
        process.exit(1);
      }
    }

    // Full deployment
    const spinner = ora('Starting deployment...').start();
    
    try {
      const result = await deploy({
        ...inputs,
        onProgress: (progress) => {
          spinner.text = progress.message;
        },
        verbose: options.verbose,
      });

      spinner.stop();

      if (result.success) {
        console.log(chalk.green('\n✓ Deployment successful!\n'));
        console.log(`  ${chalk.bold('URL:')}      ${chalk.cyan(result.url)}`);
        console.log(`  ${chalk.bold('Repo:')}     ${chalk.cyan(result.repoUrl)}`);
        console.log(`  ${chalk.bold('Commit:')}   ${result.commitSha.slice(0, 7)}`);
        console.log(`  ${chalk.bold('Duration:')} ${result.duration.toFixed(1)}s`);
        
        if (result.warnings && result.warnings.length > 0) {
          console.log(chalk.yellow('\nWarnings:'));
          result.warnings.forEach(w => console.log(`  ⚠ ${w}`));
        }
        
        console.log('');
      } else {
        console.log(chalk.red('\n✗ Deployment failed\n'));
        
        if (result.errors) {
          result.errors.forEach(e => console.log(`  ${chalk.red('•')} ${e}`));
        }
        
        console.log('');
        process.exit(1);
      }
    } catch (error) {
      spinner.stop();
      console.error(chalk.red('\n✗ Unexpected error:'));
      console.error(error instanceof Error ? error.message : 'Unknown error');
      process.exit(1);
    }
  });

program
  .command('check')
  .description('Check build output without deploying')
  .argument('<path>', 'Path to build output directory')
  .action(async (path) => {
    console.log(chalk.blue('🔍 Checking build output...\n'));
    
    const summary = getBuildSummary(path);
    console.log(summary);
    console.log('');
    
    const result = verifyBuildOutput(path);
    process.exit(result.valid ? 0 : 1);
  });

program
  .command('config')
  .description('Show configuration help')
  .action(() => {
    console.log(chalk.blue('Configuration\n'));
    console.log('Environment Variables:');
    console.log('  GITHUB_TOKEN    GitHub personal access token (required)\n');
    console.log('GitHub Token Scopes Required:');
    console.log('  • repo          Full control of private repositories');
    console.log('  • public_repo   Access public repositories');
    console.log('  • workflow      Update GitHub Action workflows (optional)\n');
    console.log('Creating a Token:');
    console.log('  1. Go to https://github.com/settings/tokens');
    console.log('  2. Click "Generate new token (classic)"');
    console.log('  3. Select required scopes');
    console.log('  4. Copy and set as GITHUB_TOKEN env var\n');
  });

// Handle unknown commands
program.on('command:*', () => {
  console.error(chalk.red(`Unknown command: ${program.args.join(' ')}`));
  console.log('Run `deploy-gh-pages --help` for available commands');
  process.exit(1);
});

// Parse arguments
program.parse();

// Show help if no command provided
if (!process.argv.slice(2).length) {
  program.outputHelp();
}