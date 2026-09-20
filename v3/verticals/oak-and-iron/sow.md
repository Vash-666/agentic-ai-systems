# Statement of Work — Oak & Iron Coffee Website

**Project:** One-Page Marketing Website  
**Client:** Oak & Iron Coffee  
**Location:** Cincinnati, OH  
**Prepared:** 2026-09-17  
**Status:** Draft — Pending Client Approval

---

## 1. Project Scope

### Overview
Design and build a single-page marketing website for Oak & Iron Coffee, a veteran-owned coffee shop and roastery in Cincinnati, Ohio. The site will serve as the primary digital presence to attract local customers, showcase the brand story, drive foot traffic, and build an email list for promotions.

### In Scope
- One-page responsive website (HTML/CSS/JS)
- Brand storytelling and visual identity execution
- Menu highlights section (6–8 signature items)
- Location, hours, and contact information
- Email signup / newsletter capture
- SEO-ready structure and metadata
- Mobile-first responsive design
- Performance optimization (fast load, smooth scroll)

### Out of Scope
- E-commerce / online ordering (reserved for future phase)
- Full menu management system
- Blog or content management system
- Multi-page architecture
- Custom backend or database
- Third-party integrations beyond map embed and email capture

### Target Audience
- Remote workers seeking laptop-friendly workspace
- Coffee enthusiasts interested in craft roasting and sourcing
- Tourists exploring Cincinnati's local food and drink scene
- Local residents looking for a community-focused coffee shop

---

## 2. Deliverables

### 2.1 Design Deliverables
| Item | Description |
|------|-------------|
| Design Brief | Document summarizing brand direction, color palette, typography, and imagery style based on questionnaire and research |
| Wireframe | Low-fidelity layout of the one-page structure showing section flow and content hierarchy |
| High-Fidelity Mockup | Visual design of the full page in desktop and mobile breakpoints |
| Asset Specifications | List of required photography, icons, and copy with dimensions and format requirements |

### 2.2 Development Deliverables
| Item | Description |
|------|-------------|
| HTML/CSS/JS Source | Clean, semantic HTML5; modern CSS (Flexbox/Grid); vanilla JavaScript (no heavy frameworks) |
| Responsive Layout | Optimized for mobile (320px+), tablet (768px+), and desktop (1024px+) |
| SEO Foundation | Semantic headings, meta tags, Open Graph tags, structured data (LocalBusiness schema), alt text, fast-loading assets |
| Performance | Lighthouse score target: 90+ on Performance, Accessibility, Best Practices, and SEO |
| Cross-Browser | Compatible with latest Chrome, Safari, Firefox, and Edge |
| Hosting-Ready | Static files ready for deployment to any static host (Netlify, Vercel, GitHub Pages, etc.) |

### 2.3 Content Deliverables
| Item | Description |
|------|-------------|
| Copywriting | All on-page text including hero headline, brand story, menu descriptions, CTAs, and footer |
| SEO Copy | Page title, meta description, and keyword-optimized headings |
| Image Sourcing | Curated stock photography or client-provided photos edited for web use |
| Email Capture Form | Functional signup form with validation (integrates with Mailchimp, ConvertKit, or similar via client-provided API key) |

### 2.4 Section Breakdown (One-Page Structure)
1. **Navigation** — Sticky header with logo, nav links (anchor scroll), and optional "Order Online" placeholder
2. **Hero** — Full-width brand statement: "Veteran-Owned, Small-Batch Coffee Roasted in Cincinnati" with strong industrial/rustic imagery and two CTAs ("Visit Us" / "Our Story")
3. **Hours & Location** — Prominently displayed address, neighborhood context, hours, and embedded Google Map
4. **Workspace Signals** — Icon-based section highlighting free Wi-Fi, outlets, comfortable seating, and laptop-friendly atmosphere
5. **Brand Story** — 2–3 paragraphs on the veteran-owned origin, the meaning of "Oak & Iron," and commitment to craft
6. **Menu Highlights** — 6–8 signature drinks with descriptions and price ranges (styled text, not PDF/photo)
7. **Sourcing Teaser** — 2–3 origin regions with flavor notes (e.g., "Ethiopia Guji — floral, citrus, roasted in small batches")
8. **Events / Community** — "Coming Soon" block or 1–2 upcoming events to signal community intent
9. **Email Signup** — Inline, polite capture with incentive: "Join the crew — first drink on us"
10. **Footer** — Social links, contact info, copyright, and secondary nav

---

## 3. Timeline

| Step | Phase | Duration | Deliverable |
|------|-------|----------|-------------|
| 1 | **Questionnaire & Research Review** | 1 day | Confirm client goals, audience, and brand tone; review all research files |
| 2 | **Design Brief & Direction** | 2 days | Finalize color palette, typography, imagery style, and section priorities |
| 3 | **Wireframe** | 2 days | Low-fidelity layout approved by client |
| 4 | **Content Creation** | 3 days | Write all copy, source/curate images, finalize menu items and pricing |
| 5 | **High-Fidelity Design** | 3 days | Visual mockup of desktop and mobile; client review and approval |
| 6 | **Development — Core Build** | 4 days | Code all sections, responsive behavior, interactions, and form functionality |
| 7 | **Development — Polish & SEO** | 2 days | Performance optimization, accessibility audit, SEO metadata, cross-browser testing |
| 8 | **Client Review & Revisions** | 3 days | Client feedback round; up to 2 rounds of revisions included |
| 9 | **Deploy & Handoff** | 1 day | Deploy to client-preferred host; provide source files and brief documentation |

**Total Estimated Duration:** 21 business days (~4–5 weeks with client feedback cycles)

---

## 4. Acceptance Criteria

The website will be considered complete and accepted when all of the following are met:

### 4.1 Functional
- [ ] All 10 sections render correctly on desktop, tablet, and mobile
- [ ] Navigation smoothly scrolls to each section
- [ ] Email signup form validates input and submits successfully
- [ ] Embedded Google Map loads and is interactive
- [ ] No broken links, missing images, or console errors
- [ ] Page loads in under 3 seconds on a standard 4G connection

### 4.2 Design
- [ ] Visual design matches approved high-fidelity mockup within reasonable tolerance
- [ ] Color palette, typography, and imagery align with "warm but industrial" brand tone
- [ ] Hero section communicates brand identity within 3 seconds of landing
- [ ] Hours and location are visible in the first 20% of the page without scrolling

### 4.3 Performance & Quality
- [ ] Google Lighthouse scores: 90+ on Performance, Accessibility, Best Practices, and SEO
- [ ] Passes WCAG 2.1 AA accessibility standards (contrast, focus states, alt text, semantic HTML)
- [ ] Renders correctly on latest Chrome, Safari, Firefox, and Edge
- [ ] No intrusive popups, cookie banners, or mobile friction elements

### 4.4 SEO
- [ ] Unique, keyword-optimized `<title>` and `<meta name="description">` tags
- [ ] Semantic HTML structure with proper heading hierarchy (H1 → H2 → H3)
- [ ] LocalBusiness structured data (JSON-LD) including name, address, hours, and geo coordinates
- [ ] Alt text on all images
- [ ] Clean, readable URLs

### 4.5 Content
- [ ] All copy is grammatically correct, on-brand, and client-approved
- [ ] Menu highlights include 6–8 items with descriptions and price ranges
- [ ] Brand story section includes veteran-owned narrative and meaning of "Oak & Iron"
- [ ] Workspace section clearly signals Wi-Fi, outlets, and laptop-friendly atmosphere

---

## 5. Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **Client-provided content delays** (photos, menu pricing, founder story details) | Medium | High | Build with placeholder content and high-quality stock imagery; schedule a content deadline at Week 2; client owns final copy accuracy |
| **Unclear brand ownership** (existing "Oak & Iron Coffee" Instagram/Facebook presence may conflict) | Medium | High | Client must confirm trademark/name rights before launch; recommend legal review if brand is not yet registered |
| **No confirmed physical location** (research found no verified Cincinnati address) | High | High | Client must provide verified address, hours, and geo coordinates before development of Location section; site cannot launch without this |
| **Scope creep** (client requests e-commerce, blog, or multi-page expansion mid-project) | Medium | Medium | Clearly document out-of-scope items; offer Phase 2 proposal for additional features; require written change order for scope additions |
| **Competitive differentiation falls flat** (Cincinnati coffee market is mature and crowded) | Low | Medium | Lean heavily on uncontested differentiators: veteran-owned narrative, explicit workspace-friendliness, and industrial/rustic aesthetic; validate with soft launch feedback |
| **Email platform integration issues** (client may not have Mailchimp/ConvertKit account ready) | Low | Low | Build form with frontend validation only as fallback; provide integration instructions for client or offer setup as small add-on |
| **Mobile performance on slow networks** (tourists and remote workers often browse on mobile data) | Low | Medium | Optimize images (WebP/AVIF with fallbacks), lazy-load below-fold assets, minify CSS/JS, and test on throttled connections |
| **Design approval delays** (client unavailable or slow to respond during review phases) | Medium | Medium | Build in 3-day review windows; after 2 rounds of revisions, additional changes bill at hourly rate; set clear deadlines at kickoff |

---

## 6. Assumptions

1. Client will provide a verified business name, address, phone number, and hours before development begins.
2. Client will provide or approve all photography, or accept curated stock imagery.
3. Client has or will set up an email marketing platform (Mailchimp, ConvertKit, etc.) for form integration.
4. Client confirms the veteran-owned brand story is accurate and may be used publicly.
5. Website will be static HTML/CSS/JS; no CMS, database, or server-side logic is included.
6. Hosting and domain registration are client responsibilities; deployment assistance is included.

---

## 7. Next Steps

1. **Client reviews and approves this SOW**
2. **Schedule kickoff call** to confirm assumptions, gather missing info (exact address, hours, menu items, photos), and align on timeline
3. **Client provides brand assets** (logo files, existing photography, color preferences if any)
4. **Begin Step 1: Questionnaire & Research Review**

---

*This Statement of Work is based on the Oak & Iron Coffee Client Questionnaire, Client Research, User Persona Research, and Competitive Website Analysis conducted on 2026-09-17.*
