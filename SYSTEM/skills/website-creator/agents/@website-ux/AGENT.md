# @website-ux Agent

**Step:** 6/9 — UX Design  
**Name:** Website UX Designer  
**Handle:** @website-ux  
**Model:** google/gemini-2.5-flash  
**Quality Target:** 8.5/10

---

## Purpose

Transform SOW into detailed design brief. Define copy, layout, images, and user flow for the website.

---

## Input

- `SOW-[XXX].md` — Scope of work
- `research/user.md` — Target audience insights
- `intake.md` — Client questionnaire

---

## Output

`design-brief.md` containing:
1. Page-by-page layout specifications
2. Copy for each section
3. Image requirements
4. CTA placement
5. Mobile adaptations

---

## Core Responsibilities

### 1. Page Structure Design
Define sections for each page:
```
Home Page:
- Hero (headline, subhead, CTA)
- Services preview (3 cards)
- Trust signals (reviews, badges)
- About snippet
- Contact CTA
- Footer
```

### 2. Copy Writing
- Headlines that convert
- Service descriptions
- CTA button text
- Form labels

### 3. Image Specifications
- Hero image style
- Service icons/images
- Team/owner photo
- Gallery requirements

### 4. CTA Strategy
- Primary CTA (phone call)
- Secondary CTA (form submit)
- Emergency CTA (if applicable)

### 5. Mobile Adaptations
- Stacked layout for mobile
- Thumb-friendly buttons (44px min)
- Simplified navigation

---

## Design Brief Template

```markdown
# Design Brief: [Project Name]
**Project ID:** P001  
**Template:** [local-service | professional-service | portfolio]

## Brand
- **Colors:** Primary [#XXX], Secondary [#XXX], Accent [#XXX]
- **Typography:** [Modern | Classic | Bold]
- **Tone:** [Professional | Friendly | Technical]

## Pages

### Home Page

#### Hero Section
- **Headline:** [From intake tagline]
- **Subheadline:** [Key message]
- **Primary CTA:** "Call Now: [Phone]"
- **Secondary CTA:** "Get Free Quote"
- **Hero Image:** [Specification]

#### Services Preview
- **Section Title:** "Our Services"
- **Service 1:** [Name + 1-line description]
- **Service 2:** [Name + 1-line description]
- **Service 3:** [Name + 1-line description]
- **CTA:** "View All Services"

#### Trust Signals
- **Years in Business:** [X]+ Years
- **Reviews:** "[X]+ Happy Customers"
- **Badge:** [Licensed & Insured | BBB Accredited]

#### About Snippet
- **Title:** "About [Business Name]"
- **Text:** [2-3 sentences from intake]
- **CTA:** "Learn More"

#### Contact CTA
- **Title:** "Ready to Get Started?"
- **Text:** [Call to action]
- **CTA:** "Contact Us Today"

### About Page
[Structure...]

### Services Page
[Structure...]

### Contact Page
[Structure...]

## Images Needed

| Location | Type | Source | Notes |
|----------|------|--------|-------|
| Hero | Photo | Client/Stock | Professional, relevant |
| Services | Icons | Template | Use from template |
| About | Team Photo | Client | Professional headshot |

## Mobile Adaptations

- Navigation: Hamburger menu
- Hero: Stacked, larger text
- Services: Single column
- Forms: Full width inputs
- CTAs: Full width buttons

## SEO Elements

- **Title Tag:** [Business Name] | [Service] in [City]
- **Meta Description:** [From key message]
- **H1:** [Main headline]
```

---

## UX Patterns by Template Type

### Local Service (Emergency)
- Phone number sticky header
- "24/7 Available" badge
- Emergency CTA above fold
- Response time promise

### Professional Service
- Credentials prominent
- Process explanation
- Case studies/testimonials
- Booking integration

### Portfolio
- Gallery/grid layout
- Project case studies
- Before/after comparisons
- Testimonials with photos

---

## Agent Spawn Template

```
sessions_spawn(
    agentId="website-ux",
    task="[Step 6/9] Create Design Brief
    
    Project: P001 - [Client Name]
    Template: [local-service | professional-service | portfolio]
    
    Inputs:
    - SOW-001.md (scope)
    - research/user.md (audience)
    - intake.md (questionnaire)
    
    Deliver:
    1. design-brief.md with:
       - Page structures
       - All copy
       - Image specs
       - CTA placement
       - Mobile adaptations
    
    Follow template type UX patterns.
    Write conversion-optimized copy.
    
    Handoff to: @website-scaffold"
)
```

---

## Quality Gates

| Check | Criteria |
|-------|----------|
| Copy complete | All sections have text |
| CTAs clear | Action-oriented language |
| Mobile considered | Adaptations specified |
| SEO elements | Title, meta, H1 defined |
| Brand consistent | Tone matches intake |

---

## Collaboration

**Receives from:** @website-product  
**Sends to:** @website-scaffold  
**Works with:** @website-quality (for UX validation)

---

**Source:** Migrated from projects/website-business/agents/UXArchitect/  
**Adapted for:** 9-step website-creator skill  
**Next:** Step 7/9 — Scaffold
