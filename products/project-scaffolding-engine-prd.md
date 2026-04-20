# Project Scaffolding Engine - Product Requirements Document

**Version:** 1.0  
**Date:** April 20, 2026  
**Status:** Draft  
**Owner:** @product

---

## Executive Summary

The Project Scaffolding Engine is an intelligent code generation system that creates production-ready project structures in under 2 minutes with ≥95% success rate and ≥9.0/10 code quality. It integrates seamlessly with OpenClaw's agent system and automates the entire setup-to-deploy workflow.

**Core Value:** Transform project ideas into working codebases instantly, eliminating hours of boilerplate setup.

---

## Product Overview

### Problem Statement
Developers waste 2-6 hours setting up new projects:
- Manually creating folder structures
- Configuring build tools and dependencies
- Setting up linting, formatting, and quality gates
- Integrating CI/CD pipelines
- Writing boilerplate code

### Solution
An AI-powered scaffolding engine that:
1. Generates complete project structures from templates
2. Installs and configures all dependencies
3. Sets up quality gates and GitHub integration
4. Validates output against success metrics
5. Pushes working code to GitHub in < 2 minutes

### Success Metrics

**Core Performance:**
- **Scaffolding Time:** < 2 minutes (from command to GitHub push)
- **Success Rate:** ≥ 95% (successful builds without manual fixes)
- **Code Quality:** ≥ 9.0/10 (ESLint score, no critical issues)

**Security & Reliability:**
- **Vulnerability-Free Rate:** ≥ 98% (no high/critical CVEs in generated projects)
- **Uptime:** ≥ 99.5% (agent availability)

**User Experience:**
- **User Satisfaction:** ≥ 90% would use again
- **Time-to-First-Success:** < 5 minutes (including learning curve)
- **Documentation Quality:** ≥ 4.0/5.0 stars (user surveys)

---

## Core Project Types

### 1. Next.js Full-Stack Web App

**Use Case:** Modern web applications with SSR, API routes, and database integration.

**File Structure:**
```
<project-name>/
├── .github/
│   └── workflows/
│       └── ci.yml                 # GitHub Actions workflow
├── src/
│   ├── app/                       # App router (Next.js 14+)
│   │   ├── layout.tsx             # Root layout
│   │   ├── page.tsx               # Home page
│   │   ├── api/                   # API routes
│   │   │   └── health/route.ts   # Health check endpoint
│   │   └── globals.css            # Global styles
│   ├── components/                # React components
│   │   ├── ui/                    # Reusable UI components
│   │   └── README.md              # Component documentation
│   ├── lib/                       # Utility functions
│   │   ├── db.ts                  # Database client
│   │   └── utils.ts               # Helper functions
│   └── types/                     # TypeScript types
│       └── index.ts
├── public/                        # Static assets
│   └── favicon.ico
├── tests/
│   ├── unit/                      # Unit tests
│   └── e2e/                       # End-to-end tests
├── .env.example                   # Environment variables template
├── .eslintrc.json                 # ESLint config
├── .prettierrc                    # Prettier config
├── next.config.js                 # Next.js config
├── package.json                   # Dependencies
├── tsconfig.json                  # TypeScript config
├── tailwind.config.ts             # Tailwind CSS config
├── postcss.config.js              # PostCSS config
└── README.md                      # Project documentation
```

**Tech Stack:**
- Next.js 14+ (App Router)
- TypeScript
- Tailwind CSS
- ESLint + Prettier
- Vitest (unit tests) + Playwright (e2e)
- PostgreSQL/Prisma (optional, based on requirements)

**Key Files Generated:**
1. `package.json` - All dependencies pre-configured
2. `README.md` - Project overview, setup instructions, and scripts
3. `next.config.js` - Optimized for production
4. `.github/workflows/ci.yml` - Automated testing and deployment
5. `.env.example` - Required environment variables documented

---

### 2. Express.js + React (Client-Server Architecture)

**Use Case:** Traditional client-server applications with separate frontend and backend.

**File Structure:**
```
<project-name>/
├── .github/
│   └── workflows/
│       └── ci.yml                 # GitHub Actions workflow
├── server/                        # Backend (Express.js)
│   ├── src/
│   │   ├── index.ts               # Server entry point
│   │   ├── routes/                # API routes
│   │   │   ├── index.ts           # Route aggregator
│   │   │   └── health.ts          # Health check
│   │   ├── middleware/            # Express middleware
│   │   │   ├── auth.ts
│   │   │   ├── errorHandler.ts
│   │   │   └── logger.ts
│   │   ├── controllers/           # Request handlers
│   │   ├── models/                # Data models
│   │   ├── services/              # Business logic
│   │   └── utils/                 # Helper functions
│   ├── tests/                     # Backend tests
│   ├── .env.example
│   ├── package.json
│   └── tsconfig.json
├── client/                        # Frontend (React)
│   ├── src/
│   │   ├── App.tsx                # Main app component
│   │   ├── main.tsx               # Entry point
│   │   ├── components/            # React components
│   │   │   └── ui/                # Reusable UI components
│   │   ├── pages/                 # Page components
│   │   ├── hooks/                 # Custom React hooks
│   │   ├── services/              # API client
│   │   │   └── api.ts             # Axios/Fetch wrapper
│   │   ├── utils/                 # Helper functions
│   │   ├── styles/                # CSS modules/styles
│   │   └── types/                 # TypeScript types
│   ├── public/                    # Static assets
│   ├── tests/                     # Frontend tests
│   ├── .env.example
│   ├── package.json
│   ├── tsconfig.json
│   ├── vite.config.ts             # Vite config
│   └── index.html
├── .eslintrc.json                 # Shared ESLint config
├── .prettierrc                    # Shared Prettier config
├── package.json                   # Root package.json (workspaces)
└── README.md                      # Project documentation
```

**Tech Stack:**
- **Backend:** Express.js 4.x, TypeScript, Node.js 18+
- **Frontend:** React 18+, TypeScript, Vite
- **Styling:** CSS Modules or Tailwind CSS
- **Testing:** Vitest (both client/server)
- **Database:** PostgreSQL/MongoDB (optional, based on requirements)
- **Monorepo:** npm workspaces

**Key Files Generated:**
1. Root `package.json` with workspaces configured
2. Separate `package.json` for client and server
3. Pre-configured CORS, error handling, and logging middleware
4. API client with TypeScript types
5. Docker Compose file for local development (optional)

---

## OpenClaw Integration

### 1. Agent Folder Structure

```
agents/
├── scaffolder/                    # Main scaffolding agent
│   ├── AGENT.md                   # Agent documentation
│   ├── skills/
│   │   └── scaffold/
│   │       ├── SKILL.md           # Skill documentation
│   │       ├── templates/         # Project templates
│   │       │   ├── nextjs-fullstack/
│   │       │   └── express-react/
│   │       └── scripts/
│   │           ├── generate.ts    # Template generator
│   │           ├── validate.ts    # Quality validator
│   │           └── deploy.ts      # GitHub push
│   └── MEMORY.md                  # Agent memory/learning
```

### 2. Workflow Integration

**Command Flow:**
```
User Request → OpenClaw Main Agent → @scaffolder subagent
                                    ↓
                            Generate Project
                                    ↓
                            Install Dependencies
                                    ↓
                            Run Quality Gates
                                    ↓
                            Git Init + Push
                                    ↓
                            Return Result
```

**Example Usage:**
```
User: "Create a Next.js blog app with authentication"
OpenClaw: [spawns @scaffolder subagent]
@scaffolder: 
  1. Analyze requirements
  2. Select template: nextjs-fullstack
  3. Customize: add auth routes, blog schema
  4. Generate files
  5. npm install
  6. Run linter (quality gate)
  7. Push to GitHub: username/blog-app
  8. Return: "✅ Project created: github.com/username/blog-app"
```

### 3. Quality Gates

**Pre-Push Validation:**
1. **Syntax Check:** `tsc --noEmit` (TypeScript compilation)
2. **Linting:** `eslint . --max-warnings 0` (zero warnings allowed)
3. **Formatting:** `prettier --check .` (consistent code style)
4. **Tests:** `npm test` (all tests pass)
5. **Build:** `npm run build` (production build succeeds)

**Quality Score Calculation:**
```typescript
const qualityScore = {
  syntax: tsErrors === 0 ? 2.5 : 0,           // 2.5 points
  linting: eslintErrors === 0 ? 2.5 : 0,      // 2.5 points
  formatting: prettierErrors === 0 ? 1.0 : 0, // 1.0 point
  tests: testsPassed ? 2.0 : 0,               // 2.0 points
  build: buildSucceeded ? 2.0 : 0             // 2.0 points
};
const totalScore = Object.values(qualityScore).reduce((a, b) => a + b, 0);
// Total: 10.0 points possible
```

**Failure Handling:**
- Score < 9.0 → Agent attempts auto-fix (1 retry)
- Auto-fix fails → Return detailed error report to user
- User can override with `--skip-quality-gates` (not recommended)

### 4. GitHub Integration

**Automated Workflow:**
1. `git init` in project directory
2. Create `.gitignore` (node_modules, .env, dist/)
3. `git add .` and `git commit -m "Initial commit via OpenClaw"`
4. Create GitHub repo via `gh` CLI or GitHub API
5. `git remote add origin <repo-url>`
6. `git push -u origin main`

**GitHub Actions CI/CD:**
- Auto-generated `.github/workflows/ci.yml`
- Runs on every push to main
- Includes: lint, test, build, deploy (optional)

---

## Implementation Plan

### Phase 1: Core Engine (Week 1-2)
- [ ] Build template generator
- [ ] Implement Next.js template
- [ ] Implement Express+React template
- [ ] Add dependency installation
- [ ] Basic validation (syntax + build)

### Phase 2: Quality Gates (Week 3)
- [ ] Integrate ESLint validation
- [ ] Add Prettier checks
- [ ] Implement quality scoring
- [ ] Auto-fix logic

### Phase 3: GitHub Integration (Week 4)
- [ ] Git initialization
- [ ] GitHub repo creation
- [ ] CI/CD workflow generation
- [ ] Push automation

### Phase 4: OpenClaw Integration (Week 5)
- [ ] Create @scaffolder agent
- [ ] Subagent spawning logic
- [ ] Memory/learning system
- [ ] User feedback collection

---

## Technical Specifications

### Performance Requirements
- **Generation Time:** < 30 seconds (file creation)
- **Dependency Install:** < 60 seconds (npm install)
- **Quality Gates:** < 30 seconds (validation)
- **GitHub Push:** < 10 seconds
- **Total Time:** < 2 minutes ✅

### Error Handling
- Retry failed installations (up to 2 times)
- Validate network connectivity before GitHub push
- Log all errors to `agents/scaffolder/logs/`
- Surface actionable errors to user

### Extensibility
- Template system supports custom templates
- Plugin architecture for additional project types
- User-defined quality thresholds
- Custom post-generation hooks

---

## Security & Compliance

### Security Principles
- **No Secrets in Code:** All API keys, tokens, and credentials must use `.env` files
- **Template Scanning:** All generated code scanned for hardcoded secrets before push
- **Dependency Auditing:** Run `npm audit` automatically; fail on high/critical vulnerabilities
- **GitHub Token Security:** Use read-scoped tokens for repo creation; never commit tokens

### Generated Code Security
1. **Environment Variables:**
   - Always generate `.env.example` with placeholder values
   - Add `.env` to `.gitignore` by default
   - Include security warnings in README.md

2. **CORS Configuration:**
   - Express templates include strict CORS by default
   - Next.js API routes use secure headers
   - No `*` wildcards in production configs

3. **Authentication Templates:**
   - Use industry-standard libraries (NextAuth.js, Passport.js)
   - Include rate limiting on auth endpoints
   - Hash passwords with bcrypt (cost factor ≥ 12)

### Compliance
- **License:** All templates include MIT license by default (user-configurable)
- **Third-Party Code:** Only use dependencies with permissive licenses (MIT, Apache 2.0, BSD)
- **Data Privacy:** No telemetry or tracking in generated projects without explicit opt-in

---

## Input Validation & Error Handling

### Input Validation

**User Inputs to Validate:**
1. **Project Name:**
   - Pattern: `^[a-z0-9-]+$` (lowercase, alphanumeric, hyphens only)
   - Length: 3-50 characters
   - Reject: reserved names (e.g., `node_modules`, `test`, `src`)

2. **GitHub Repository:**
   - Format: `username/repo-name` or `org/repo-name`
   - Check: repo doesn't already exist (API call before creation)
   - Validate: user has push access

3. **Template Selection:**
   - Must be one of: `nextjs-fullstack`, `express-react`
   - Reject: unknown templates with helpful error

4. **Custom Options:**
   - Database type: `none`, `postgresql`, `mongodb`
   - Auth: `none`, `nextauth`, `passport`
   - Validate: combinations are compatible (e.g., NextAuth requires Next.js)

### Error Handling Strategy

**Error Categories:**

1. **Validation Errors (4xx-style):**
   - Invalid project name
   - GitHub repo already exists
   - Incompatible option combinations
   - **Action:** Return clear error message; do not retry

2. **Transient Errors (5xx-style):**
   - Network timeout during `npm install`
   - GitHub API rate limit
   - Temporary file system issues
   - **Action:** Retry up to 2 times with exponential backoff

3. **Quality Gate Failures:**
   - ESLint errors in generated code
   - TypeScript compilation errors
   - Failed tests
   - **Action:** Attempt auto-fix once; if fails, return detailed report

4. **Critical Failures:**
   - Disk full
   - Git/GitHub CLI not installed
   - Permission denied on file system
   - **Action:** Immediate abort; surface to user with setup instructions

**Error Logging:**
- All errors logged to `agents/scaffolder/logs/YYYY-MM-DD.log`
- Include: timestamp, error type, stack trace, user input
- Sensitive data (tokens, credentials) never logged

**User-Facing Error Messages:**
```typescript
// Good: Actionable error
"❌ Project name 'My-App' is invalid. Use lowercase letters, numbers, and hyphens only. Example: 'my-app'"

// Bad: Vague error
"Invalid input"
```

---

## Testing Strategy

### Test Pyramid

**Unit Tests (70% coverage):**
- **Scope:** Template generation logic, validation functions, utility helpers
- **Tools:** Vitest
- **Examples:**
  - `validateProjectName()` with valid/invalid inputs
  - `generatePackageJson()` produces correct dependencies
  - `calculateQualityScore()` math accuracy

**Integration Tests (20% coverage):**
- **Scope:** Full template generation, dependency installation, quality gates
- **Tools:** Vitest with mocked file system and GitHub API
- **Examples:**
  - Generate Next.js project → verify file structure
  - Run quality gates on generated code → expect 9.0+ score
  - Mock GitHub API → verify repo creation

**End-to-End Tests (10% coverage):**
- **Scope:** Complete workflow from user request to GitHub push
- **Tools:** Playwright or custom test harness
- **Examples:**
  - Full Next.js scaffolding (real npm install, real git operations)
  - Verify GitHub repo exists and has correct files
  - Clone generated repo and run `npm run build`

### Test Environments

1. **Local Development:**
   - Developers run unit tests on every save
   - Integration tests before commit

2. **CI Pipeline (GitHub Actions):**
   - All tests run on every PR
   - E2E tests run nightly (slower, more expensive)
   - Test matrix: Node 18.x, 20.x, 22.x

3. **Staging:**
   - Weekly full E2E test against production templates
   - Monitor quality score distribution

### Quality Metrics
- **Test Coverage:** ≥ 80% overall
- **Test Speed:** Unit tests < 5s, Integration tests < 30s
- **Flakiness:** < 1% (tests must be deterministic)
- **Failure Rate:** CI pipeline ≥ 98% pass rate

---

## Dependency Management

### Template Dependencies

**Pinning Strategy:**
- **Major versions:** Pin to latest stable (e.g., `next@^14.2.0`)
- **Security patches:** Update within 48 hours of vulnerability disclosure
- **Breaking changes:** Test thoroughly before updating templates

**Dependency Sources:**
- Primary: npm registry
- Avoid: GitHub URLs, unverified packages, abandoned projects

**Approved Libraries (as of April 2026):**

| Category | Next.js Template | Express+React Template |
|----------|------------------|------------------------|
| Framework | next@^14.2.0 | express@^4.19.0, react@^18.3.0 |
| TypeScript | typescript@^5.4.0 | typescript@^5.4.0 |
| Linting | eslint@^8.57.0 | eslint@^8.57.0 |
| Formatting | prettier@^3.2.0 | prettier@^3.2.0 |
| Testing | vitest@^1.5.0, playwright@^1.43.0 | vitest@^1.5.0 |
| Database | prisma@^5.12.0 (optional) | mongoose@^8.3.0 (optional) |
| Auth | next-auth@^5.0.0 (optional) | passport@^0.7.0 (optional) |

### Vulnerability Management

**Automated Scanning:**
1. **Pre-Generation:** Check template dependencies for vulnerabilities
2. **Post-Generation:** Run `npm audit --audit-level=high` on generated project
3. **Fail Condition:** Critical or high vulnerabilities block scaffolding

**Update Schedule:**
- **Weekly:** Check for updates to template dependencies
- **Monthly:** Review and update all templates to latest stable versions
- **On-Demand:** Immediate updates for CVEs affecting generated projects

**Dependency Lifecycle:**
```
New Dependency Request
  ↓
Review: License, maintenance, download count
  ↓
Approve → Add to template
  ↓
Monitor: npm audit, security advisories
  ↓
Security Issue? → Patch/Replace within 48h
  ↓
Deprecated? → Plan migration, notify users
```

### Generated Project Dependencies

**User Control:**
- Users can modify `package.json` after generation (we don't lock it)
- Include `npm update` instructions in README.md
- Generated projects include Dependabot config for auto-updates

---

## Operational Requirements

### System Requirements

**Host Machine:**
- Node.js ≥ 18.0.0
- npm ≥ 9.0.0
- Git ≥ 2.30.0
- GitHub CLI (`gh`) ≥ 2.0.0 OR GitHub Personal Access Token
- Disk space: ≥ 500MB per generated project
- Network: stable internet connection (for npm installs and GitHub API)

**OpenClaw Agent:**
- Memory: ≥ 2GB available RAM (for spawning subagent)
- CPU: ≥ 2 cores (parallel file generation)
- Permissions: write access to `agents/scaffolder/` directory

### Resource Limits

**Per-Project Limits:**
- Max file size: 10MB (any single generated file)
- Max total files: 500 (protects against template bugs)
- Max generation time: 5 minutes (includes retries)
- npm install timeout: 3 minutes

**Concurrency:**
- Max simultaneous scaffolding jobs: 3 (prevents resource exhaustion)
- Queue subsequent requests (FIFO)

### Monitoring & Observability

**Key Metrics to Track:**
1. **Success Rate:** % of scaffolding jobs that complete successfully
2. **Generation Time:** P50, P95, P99 latencies
3. **Quality Score Distribution:** Histogram of generated project scores
4. **Error Types:** Count by category (validation, network, quality, critical)
5. **Template Usage:** Which templates are most popular

**Logging:**
- **Location:** `agents/scaffolder/logs/`
- **Retention:** 30 days (rotate daily)
- **Format:** JSON for easy parsing
- **Example Log Entry:**
```json
{
  "timestamp": "2026-04-20T16:45:00Z",
  "level": "info",
  "event": "scaffolding_complete",
  "projectName": "my-blog-app",
  "template": "nextjs-fullstack",
  "durationMs": 87340,
  "qualityScore": 9.5,
  "githubRepo": "username/my-blog-app"
}
```

**Alerting:**
- Success rate drops below 90% → notify @product
- P95 latency exceeds 3 minutes → investigate performance
- Critical errors → immediate notification

### Maintenance

**Regular Tasks:**
- **Daily:** Review logs for errors
- **Weekly:** Update dependencies, run full test suite
- **Monthly:** Review template usage metrics, plan improvements
- **Quarterly:** Audit security practices, dependency licenses

**Backup & Recovery:**
- Templates versioned in Git (no backup needed)
- Logs backed up to cloud storage (S3 or similar)
- No user data stored (stateless system)

---

## Risk Register

### Risk #1: Dependency Vulnerabilities in Generated Projects
**Likelihood:** High | **Impact:** High | **Risk Score:** 9/10

**Description:** A critical vulnerability is discovered in a core dependency (e.g., Next.js, Express) after projects are generated and deployed.

**Mitigation:**
- **Proactive:** Include Dependabot in generated projects for auto-updates
- **Reactive:** Maintain list of generated projects; notify users via GitHub issue if critical CVE affects their stack
- **Monitoring:** Subscribe to security advisories for all template dependencies
- **Fallback:** Provide emergency patch templates for critical vulnerabilities

---

### Risk #2: GitHub API Rate Limiting
**Likelihood:** Medium | **Impact:** Medium | **Risk Score:** 6/10

**Description:** Heavy usage of scaffolding tool exceeds GitHub API rate limits (5,000 requests/hour for authenticated users), blocking repo creation.

**Mitigation:**
- **Prevention:** Implement request caching and intelligent retry with exponential backoff
- **Quota Management:** Display remaining rate limit to users; warn when approaching limit
- **Fallback:** Offer manual repo creation instructions if rate limit exceeded
- **Long-term:** Use GitHub App authentication (higher rate limits) instead of personal tokens

---

### Risk #3: Template Bit Rot
**Likelihood:** Medium | **Impact:** Medium | **Risk Score:** 5/10

**Description:** Templates become outdated as frameworks evolve (e.g., Next.js 14 → 15), leading to deprecated APIs or incompatibilities.

**Mitigation:**
- **Monitoring:** Weekly automated checks for dependency updates
- **Testing:** Integration tests catch breaking changes early
- **Versioning:** Maintain multiple template versions (e.g., nextjs-14, nextjs-15)
- **Deprecation Policy:** Mark old templates as deprecated after 6 months; provide migration guide
- **User Communication:** Notify users when using outdated template versions

---

### Risk #4: Quality Gate False Negatives
**Likelihood:** Low | **Impact:** High | **Risk Score:** 5/10

**Description:** Generated code passes quality gates (9.0+ score) but contains runtime bugs or logical errors not caught by static analysis.

**Mitigation:**
- **Defense in Depth:** Combine multiple validation layers (syntax, linting, tests, build)
- **Smoke Tests:** Add basic runtime tests to E2E suite (e.g., server starts, homepage loads)
- **User Feedback Loop:** Collect reports of bugs in generated code; add regression tests
- **Manual Audits:** Quarterly review of generated code quality by senior engineers
- **Transparency:** Clearly document that quality gates are structural, not functional guarantees

---

### Risk #5: Disk Space Exhaustion
**Likelihood:** Low | **Impact:** Medium | **Risk Score:** 3/10

**Description:** Multiple concurrent scaffolding jobs fill up disk space, causing failures or system instability.

**Mitigation:**
- **Pre-Flight Check:** Verify ≥ 1GB free disk space before starting scaffolding
- **Cleanup:** Auto-delete temporary files after successful completion
- **Concurrency Limit:** Max 3 simultaneous jobs (reduces resource contention)
- **Monitoring:** Alert if disk usage exceeds 80%
- **Graceful Degradation:** Fail fast with clear error message if disk full

---

## User Documentation Plan

### Documentation Deliverables

#### 1. Quick Start Guide (5 minutes)
**Target Audience:** New users, developers exploring the tool

**Content:**
- Single-command example: `openclaw "Create a Next.js blog app"`
- Expected output: GitHub repo link, time taken, quality score
- Visual: Screenshot of successful scaffolding
- Next steps: Clone repo, run dev server

#### 2. Template Reference (15 minutes)
**Target Audience:** Users choosing between templates

**Content:**
- Side-by-side comparison table (Next.js vs Express+React)
- Use case guidance ("Use Next.js for...")
- File structure diagrams
- Tech stack details
- Customization options (database, auth, styling)

#### 3. Advanced Usage Guide (30 minutes)
**Target Audience:** Power users, teams

**Content:**
- Custom template creation
- Overriding quality thresholds
- Integration with CI/CD pipelines
- Batch scaffolding (multiple projects)
- Troubleshooting common issues

#### 4. Generated Project README.md
**Target Audience:** Developers using the generated project

**Content (auto-generated in each project):**
- Project overview and purpose
- Installation and setup steps
- npm scripts explanation
- Environment variables required
- Development workflow
- Deployment instructions (Vercel, Railway, etc.)
- "Created by OpenClaw" footer with link to docs

### Documentation Formats

**Markdown Docs:**
- Hosted in `agents/scaffolder/docs/`
- Versioned with code (same Git repo)
- Rendered on GitHub (automatic table of contents)

**Interactive Examples:**
- Video walkthrough (2-minute demo on YouTube)
- Live demo environment (sandbox where users can try without setup)

**In-Agent Help:**
- `openclaw help scaffold` → show usage, templates, options
- Error messages link to relevant docs (e.g., "See: docs/troubleshooting.md#github-auth")

### Documentation Maintenance

**Update Triggers:**
- New template added → update Template Reference
- Breaking change → update migration guide
- Common support question → add to FAQ/troubleshooting
- Quarterly review → refresh all docs for accuracy

**Quality Standards:**
- Code examples must be tested (no copy-paste errors)
- Screenshots updated when UI changes
- Docs versioned alongside templates (e.g., `docs/v1.0/`, `docs/v1.1/`)
- Plain language, avoid jargon (write for junior developers)

**Success Metrics:**
- ≥ 80% of users complete scaffolding without needing support
- Average time-to-first-success: < 5 minutes
- Documentation feedback: ≥ 4.0/5.0 stars (user surveys)

---

## Future Enhancements (Post-MVP)

1. **Additional Templates:**
   - Python FastAPI + React
   - Vue.js + Express
   - Mobile: React Native, Flutter
   - Desktop: Electron, Tauri

2. **AI Customization:**
   - Auto-generate components from descriptions
   - Suggest optimal tech stack based on requirements
   - Learn from user preferences over time

3. **Team Features:**
   - Shared template library
   - Organization-wide quality standards
   - Collaboration tools (PR templates, issue templates)

4. **Marketplace:**
   - Community-contributed templates
   - Paid premium templates
   - Template versioning and updates

---

## Appendix

### Example: Generated Next.js Project

**package.json:**
```json
{
  "name": "my-nextjs-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint .",
    "format": "prettier --write .",
    "test": "vitest",
    "test:e2e": "playwright test"
  },
  "dependencies": {
    "next": "^14.2.0",
    "react": "^18.3.0",
    "react-dom": "^18.3.0"
  },
  "devDependencies": {
    "@types/node": "^20.12.0",
    "@types/react": "^18.3.0",
    "eslint": "^8.57.0",
    "eslint-config-next": "^14.2.0",
    "prettier": "^3.2.0",
    "typescript": "^5.4.0",
    "vitest": "^1.5.0"
  }
}
```

**README.md:**
```markdown
# My Next.js App

Generated by OpenClaw Project Scaffolding Engine

## Quick Start

1. Install dependencies: `npm install`
2. Run dev server: `npm run dev`
3. Open http://localhost:3000

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint
- `npm run format` - Format code with Prettier
- `npm test` - Run unit tests
- `npm run test:e2e` - Run E2E tests

## Project Structure

See `src/` for application code.
See `.github/workflows/` for CI/CD pipeline.

---

Created with ❤️ by OpenClaw
```

---

## Key Decisions

### 1. **Two Project Types First**
Focus on Next.js and Express+React as they cover 80% of use cases. Avoid scope creep.

### 2. **Strict Quality Gates**
9.0/10 minimum ensures generated code is production-ready, not just "works on my machine."

### 3. **OpenClaw Native**
Tight integration with agent system means seamless workflows and learning over time.

### 4. **Speed Over Perfection**
< 2 minute total time is the killer feature. Optimize for fast iteration, not exhaustive testing.

### 5. **Opinionated Defaults**
TypeScript, ESLint, Prettier are non-negotiable. Reduces decision fatigue and ensures consistency.

---

**End of Document**
