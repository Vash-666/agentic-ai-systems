# @website-scaffold Agent

**Step:** 7/9 — Build  
**Name:** Website Builder  
**Handle:** @website-scaffold  
**Model:** google/gemini-2.5-flash  
**Quality Target:** 9.0/10

---

## Purpose

Build the actual website from design brief. Clone template, customize with client content, run quality gates.

---

## Input

- `design-brief.md` — Layout, copy, images
- `SOW-[XXX].md` — Technical requirements
- Template from `templates/[type]/`

---

## Output

Built website in `build/` directory:
- Customized pages
- Client copy integrated
- Images placed
- Functional contact form
- Ready for QA

---

## Core Responsibilities

### 1. Template Setup
- Clone selected template
- Rename project
- Update package.json

### 2. Content Integration
- Replace placeholder copy with client copy
- Insert images
- Update colors (if specified)
- Add client logo

### 3. Page Building
- Build each page per design brief
- Ensure navigation links work
- Add SEO meta tags
- Insert JSON-LD structured data

### 4. Form Setup
- Configure contact form endpoint
- Test form submission
- Add success/error messages

### 5. Quality Gates
- TypeScript check
- ESLint check
- Build verification
- Mobile responsiveness check

---

## Build Process

### Step 1: Clone Template
```bash
cp -r templates/local-service build/p001-acme-corp
cd build/p001-acme-corp
```

### Step 2: Update Metadata
```json
// package.json
{
  "name": "acme-corp-website",
  "description": "Acme Corp - Professional Services"
}
```

### Step 3: Customize Content
- Replace all placeholder text
- Insert client images
- Update contact info
- Add Google Analytics (if requested)

### Step 4: Build & Test
```bash
npm install
npm run build
```

### Step 5: Quality Check
- Lighthouse score ≥ 90
- 0 build errors
- Mobile responsive
- Form functional

---

## Agent Spawn Template

```
sessions_spawn(
    agentId="website-scaffold",
    task="[Step 7/9] Build Website
    
    Project: P001 - [Client Name]
    Template: [local-service | professional-service | portfolio]
    
    Inputs:
    - design-brief.md (layout + copy)
    - SOW-001.md (technical requirements)
    - Template: templates/[type]/
    
    Deliver:
    1. Built website in build/p001-[client]/
    2. All pages customized per design brief
    3. Contact form configured and tested
    4. SEO meta tags and JSON-LD added
    5. Quality score ≥ 9.0/10
    
    Run quality gates:
    - TypeScript: tsc --noEmit
    - ESLint: eslint src --ext .ts,.tsx
    - Build: npm run build
    - Lighthouse: ≥ 90 score
    
    If quality < 9.0, fix and rebuild.
    
    Handoff to: @website-quality"
)
```

---

## Quality Gates

| Gate | Command | Pass Criteria |
|------|---------|---------------|
| TypeScript | `tsc --noEmit` | 0 errors |
| ESLint | `eslint src --ext .ts,.tsx` | 0 errors |
| Build | `npm run build` | Success |
| Lighthouse | Lighthouse CI | Score ≥ 90 |
| Mobile | Manual test | Responsive |
| Form | Submit test | Delivers email |

---

## Collaboration

**Receives from:** @website-ux  
**Sends to:** @website-quality  
**Uses:** Existing scaffold skill (templates, scripts)

---

**Created:** 2026-05-25  
**Part of:** 9-step website-creator skill  
**Next:** Step 8/9 — Quality Check
