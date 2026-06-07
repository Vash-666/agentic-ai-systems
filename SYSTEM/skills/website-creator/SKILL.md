# 🌐 Website Creator Skill

**Skill ID:** website-creator  
**Version:** 1.0  
**Created:** 2026-05-25  
**Status:** Migration in Progress

---

## Overview

End-to-end website creation skill for custom static sites. From questionnaire to deployed website in 9 steps.

**Key Features:**
- Step-by-step interactive questionnaire
- Automated client/user/competitor research
- 9-step workflow with @switch status updates
- Internal project numbering per client
- Quality-gated deployment

---

## 9-Step Workflow

| Step | Name | Agent | Output | Switch Status |
|------|------|-------|--------|---------------|
| 1 | Questionnaire | @switch (interactive) | `intake-[client]-[date].md` | "Step 1/9: Running questionnaire..." |
| 2 | Client Research | @grok | `research-client.md` | "Step 2/9: Researching client presence..." |
| 3 | User Research | @grok | `research-user.md` | "Step 3/9: Defining target audience..." |
| 4 | Competitive Analysis | @grok | `research-competitors.md` | "Step 4/9: Analyzing competitors..." |
| 5 | SOW Creation | @website-product | `SOW-[XXX].md` | "Step 5/9: Writing scope of work..." |
| 6 | UX Design | @website-ux | `design-brief.md` | "Step 6/9: Creating design brief..." |
| 7 | Scaffold | @website-scaffold | Built website | "Step 7/9: Building website..." |
| 8 | Quality Check | @website-quality | `QA-report.md` | "Step 8/9: Running quality checks..." |
| 9 | Deploy | @switch | Live site | "Step 9/9: Deploying to GitHub..." |

---

## Project Numbering System

### Registry Files

**`registry/clients.json`**
```json
{
  "clients": [
    {
      "id": "C001",
      "name": "Acme Corp",
      "contact": "john@acme.com",
      "created": "2026-05-25"
    }
  ]
}
```

**`registry/projects.json`**
```json
{
  "projects": [
    {
      "id": "P001",
      "clientId": "C001",
      "name": "Corporate Website",
      "status": "complete",
      "score": 9.2,
      "url": "https://github.com/..."
    }
  ],
  "counters": {
    "client": 1,
    "project": 1
  }
}
```

### Directory Structure
```
projects/
├── C001-acme-corp/
│   ├── client-info.md
│   ├── P001-website/
│   │   ├── intake.md
│   │   ├── research/
│   │   ├── SOW-001.md
│   │   ├── design-brief.md
│   │   ├── build/
│   │   ├── QA-report.md
│   │   └── status.md
│   └── P002-redesign/     # Future project
└── C002-rohit-vashist/
    └── P003-website/
```

---

## Commands

### Start New Project
```
@switch: "Start website project for [Client Name]"
```

### Check Status
```
@switch: "Status of project P001"
```

### List Projects
```
@switch: "List all website projects"
```

---

## Templates Available

| Template | Best For | Features |
|----------|----------|----------|
| `local-service` | HVAC, plumbing, trades | Emergency CTA, service areas, reviews |
| `professional-service` | Consultants, lawyers | Credentials, case studies, booking |
| `portfolio` | Creatives, artists | Gallery, projects, testimonials |
| `landing-page` | Product launches | Single-page, high conversion |

---

## Quality Gates

- Lighthouse score ≥ 90
- Mobile responsive
- Contact form functional
- 0 critical bugs
- Build passes

---

## Status

🚧 **Migration in progress from:**
- ai-website-studio/SOW-FRAMEWORK.md
- projects/website-business/ (4 sprints)
- project-scaffolding-engine/agents/scaffolder/

---

**Next:** Create questionnaire system and migrate existing work.
