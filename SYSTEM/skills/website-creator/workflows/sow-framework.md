# Step 5/9: SOW Framework

**Purpose:** Convert research into actionable scope of work  
**Agent:** @website-product  
**Input:** intake.md + research/ (client, user, competitor)  
**Output:** `SOW-[XXX].md`  
**Next Step:** UX Design

---

## Overview

Adapted from AI Website Studio SOW Framework. Streamlined for static website projects.

---

## SOW Structure

```markdown
# SOW-[XXX]: [Project Name]

## Metadata
- **Project ID:** P001
- **Client ID:** C001
- **Client:** [Business Name]
- **Agent:** @website-product
- **Date:** 2026-05-25
- **Package:** Essential | Professional | Premium

## Input Summary
- **Intake:** [Key points from questionnaire]
- **Client Research:** [Current presence findings]
- **User Research:** [Target audience insights]
- **Competitive Analysis:** [Positioning opportunities]

## Scope

### Pages to Build
- [ ] Home
- [ ] About
- [ ] Services
- [ ] Contact
- [ ] Blog (if Professional/Premium)

### Features
- [ ] Contact form
- [ ] Click-to-call
- [ ] Google Maps embed
- [ ] Testimonials section
- [ ] FAQ section
- [ ] Blog (if applicable)

### Technical Requirements
- **Template:** [local-service | professional-service | portfolio | landing-page]
- **Domain:** [client domain or subdomain]
- **Hosting:** GitHub Pages
- **Analytics:** Google Analytics (if requested)

## Deliverables

### D1: Customized Website
- Fully customized template
- Client copy and images
- Mobile responsive
- Contact form functional

### D2: SEO Setup
- Meta tags optimized
- JSON-LD structured data
- Sitemap.xml
- robots.txt

### D3: Launch Package
- GitHub repository
- Deployment live
- Basic documentation

## Acceptance Criteria

- [ ] All pages render correctly
- [ ] Mobile responsive (tested on iOS + Android)
- [ ] Contact form submits successfully
- [ ] Lighthouse score ≥ 90
- [ ] Client approves design
- [ ] 0 critical bugs

## Timeline

| Phase | Duration | Owner |
|-------|----------|-------|
| UX Design | 1 day | @website-ux |
| Scaffold | 2 days | @website-scaffold |
| Quality Check | 1 day | @website-quality |
| Deploy | 0.5 day | @switch |
| **Total** | **4.5 days** | |

## Pricing

| Item | Cost |
|------|------|
| Base Package | $[amount] |
| Add-ons | $[amount] |
| **Total** | **$[amount]** |

## Handoff

**To:** @website-ux  
**With:** design-brief template  
**When:** SOW approved

## Notes

[Special requirements, client preferences, risks]
```

---

## Agent Spawn Template

```
sessions_spawn(
    agentId="website-product",
    task="[SOW-005] Create Scope of Work
    
    Project: P001 - [Client Name]
    Package: [Essential | Professional | Premium]
    
    Inputs:
    - intake.md (questionnaire responses)
    - research/client.md (current presence analysis)
    - research/user.md (target audience)
    - research/competitors.md (competitive positioning)
    
    Deliver:
    1. SOW-[XXX].md with full scope
    2. Page list and features
    3. Timeline (4-5 days typical)
    4. Acceptance criteria
    5. Pricing breakdown
    
    Template to use: local-service | professional-service | portfolio
    
    Handoff to: @website-ux with design-brief template"
)
```

---

## Package Definitions

### Essential ($1,500)
- 1-page website (Home with sections)
- Contact form
- Mobile responsive
- Basic SEO
- 3-day delivery

### Professional ($3,000)
- 4-page website (Home, About, Services, Contact)
- Blog setup
- Advanced SEO (JSON-LD)
- Analytics integration
- 5-day delivery

### Premium ($5,000)
- Everything in Professional
- Custom features (booking, calculator, etc.)
- Priority support
- 7-day delivery

---

## Quality Gates

| Gate | Check | Pass Criteria |
|------|-------|---------------|
| Scope clarity | All requirements documented | No ambiguous items |
| Timeline realistic | Based on template + customization | 4-7 days typical |
| Pricing correct | Matches package + add-ons | Client budget aligned |
| Acceptance defined | Measurable criteria | All checkboxes testable |

---

**Source:** Migrated from ai-website-studio/SOW-FRAMEWORK.md  
**Adapted for:** 9-step website-creator skill  
**Next:** Step 6/9 — UX Design
