# GitHub Pages Deploy Script

Automated deployment script for publishing static websites to GitHub Pages.

## Installation

```bash
npm install
npm run build
```

## Usage

### CLI

```bash
# Basic deployment
npx deploy-gh-pages deploy -s ./dist -r my-website

# With custom domain
npx deploy-gh-pages deploy -s ./out -r my-website -d www.example.com

# Full options
npx deploy-gh-pages deploy \
  --source ./dist \
  --repo my-website \
  --owner myusername \
  --branch gh-pages \
  --message "Deploy version 1.2.3" \
  --domain www.example.com \
  --private

# Dry run (validate without deploying)
npx deploy-gh-pages deploy -s ./dist -r my-website --dry-run

# Check build output
npx deploy-gh-pages check ./dist
```

### Programmatic

```typescript
import { deploy } from './deploy-gh-pages';

const result = await deploy({
  sourceDir: './dist',
  repoName: 'my-website',
  repoOwner: 'myusername',
  customDomain: 'www.example.com',
  commitMessage: 'Automated deployment',
  onProgress: (progress) => {
    console.log(`${progress.percent}%: ${progress.message}`);
  }
});

if (result.success) {
  console.log(`Deployed to: ${result.url}`);
} else {
  console.error('Deployment failed:', result.errors);
}
```

## Configuration

### Environment Variables

- `GITHUB_TOKEN` - GitHub personal access token (required)

### GitHub Token Scopes

- `repo` - Full control of private repositories
- `public_repo` - Access public repositories

### Creating a Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select required scopes
4. Copy and set as `GITHUB_TOKEN` environment variable

## Error Codes

| Code | Description | Resolution |
|------|-------------|------------|
| E001 | Build output not found | Run build command first |
| E002 | Missing index.html | Ensure build generates entry point |
| E003 | GitHub auth failed | Check GITHUB_TOKEN |
| E004 | Repo creation failed | Check permissions, repo name |
| E005 | Push failed | Check branch permissions |
| E006 | Domain DNS not configured | Add CNAME record to DNS |
| E007 | File too large (>100MB) | Use Git LFS or reduce file size |
| E008 | Deployment timeout | Retry deployment |
| E009 | Invalid input parameters | Check required parameters |
| E010 | Git operation failed | Check git configuration |

## API

### `deploy(options)`

Deploy a static site to GitHub Pages.

**Options:**

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `sourceDir` | string | Yes | - | Path to built static files |
| `repoName` | string | Yes | - | GitHub repository name |
| `repoOwner` | string | No | Authed user | GitHub username/org |
| `branch` | string | No | `gh-pages` | Deployment branch |
| `commitMessage` | string | No | `Deploy to GitHub Pages` | Commit message |
| `customDomain` | string | No | - | Custom domain CNAME |
| `isPrivate` | boolean | No | `false` | Private repository |
| `token` | string | No | `GITHUB_TOKEN` | GitHub token |
| `onProgress` | function | No | - | Progress callback |
| `verbose` | boolean | No | `false` | Verbose logging |

**Returns:** `Promise<DeployOutputs>`

```typescript
interface DeployOutputs {
  success: boolean;
  url: string;
  repoUrl: string;
  commitSha: string;
  deploymentId?: number;
  timestamp: string;
  duration: number;
  errors?: string[];
  warnings?: string[];
}
```

## License

MIT