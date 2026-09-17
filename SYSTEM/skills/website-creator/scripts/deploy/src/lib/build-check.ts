import { existsSync, statSync, readdirSync } from 'fs';
import { join } from 'path';
import { ValidationError } from './validator.js';

/**
 * Build output verification
 */
export interface BuildCheckResult {
  valid: boolean;
  errors: string[];
  warnings: string[];
  stats: {
    totalFiles: number;
    totalSize: number;
    htmlFiles: number;
    assetFiles: number;
  };
}

/**
 * Verify build output
 */
export function verifyBuildOutput(sourceDir: string): BuildCheckResult {
  const errors: string[] = [];
  const warnings: string[] = [];
  
  // Check index.html exists
  const indexPath = join(sourceDir, 'index.html');
  if (!existsSync(indexPath)) {
    errors.push('Missing index.html - build output must include an entry point');
  }

  // Calculate stats
  let totalFiles = 0;
  let totalSize = 0;
  let htmlFiles = 0;
  let assetFiles = 0;

  function scanDir(dir: string) {
    const entries = readdirSync(dir, { withFileTypes: true });
    
    for (const entry of entries) {
      const fullPath = join(dir, entry.name);
      
      if (entry.isDirectory()) {
        scanDir(fullPath);
      } else {
        totalFiles++;
        const stats = statSync(fullPath);
        totalSize += stats.size;
        
        if (entry.name.endsWith('.html')) {
          htmlFiles++;
        } else if (/\.(js|css|png|jpg|jpeg|gif|svg|woff|woff2|ttf|eot)$/.test(entry.name)) {
          assetFiles++;
        }

        // Warn about large files
        if (stats.size > 5 * 1024 * 1024) {
          warnings.push(`Large file detected: ${fullPath} (${(stats.size / 1024 / 1024).toFixed(2)}MB)`);
        }
      }
    }
  }

  try {
    scanDir(sourceDir);
  } catch (error) {
    errors.push(`Failed to scan build output: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }

  // Warnings
  if (totalFiles === 0) {
    errors.push('Build output directory is empty');
  }

  if (htmlFiles === 0) {
    errors.push('No HTML files found in build output');
  }

  if (totalSize > 100 * 1024 * 1024) {
    warnings.push(`Total build size is large: ${(totalSize / 1024 / 1024).toFixed(2)}MB. Consider optimizing assets.`);
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
    stats: {
      totalFiles,
      totalSize,
      htmlFiles,
      assetFiles,
    },
  };
}

/**
 * Check if file is binary
 */
export function isBinaryFile(filePath: string): boolean {
  const binaryExtensions = [
    '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico',
    '.woff', '.woff2', '.ttf', '.eot', '.otf',
    '.pdf', '.zip', '.gz', '.tar', '.rar',
    '.mp3', '.mp4', '.webm', '.ogg', '.wav',
    '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
  ];
  
  const ext = filePath.slice(filePath.lastIndexOf('.')).toLowerCase();
  return binaryExtensions.includes(ext);
}

/**
 * Get build summary
 */
export function getBuildSummary(sourceDir: string): string {
  const result = verifyBuildOutput(sourceDir);
  
  if (!result.valid) {
    return `Build check failed:\n${result.errors.map(e => `  ✗ ${e}`).join('\n')}`;
  }

  const lines = [
    'Build check passed:',
    `  ✓ ${result.stats.totalFiles} files`,
    `  ✓ ${(result.stats.totalSize / 1024).toFixed(1)} KB total`,
    `  ✓ ${result.stats.htmlFiles} HTML files`,
    `  ✓ ${result.stats.assetFiles} asset files`,
  ];

  if (result.warnings.length > 0) {
    lines.push('', 'Warnings:');
    lines.push(...result.warnings.map(w => `  ⚠ ${w}`));
  }

  return lines.join('\n');
}