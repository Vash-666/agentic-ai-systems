# Step 1/9: Interactive Questionnaire

**Purpose:** Gather all client information through step-by-step Q&A  
**Output:** `intake-[client]-[date].md`  
**Next Step:** Client Research

---

## Questionnaire Format

Interactive step-by-step. @switch asks one question at a time.

---

## Section A: Business Basics

### Q1: Business Name
**@switch:** "What is the business name?"

### Q2: Business Type
**@switch:** "What type of business?"
- [ ] Local Service (plumbing, HVAC, electrical)
- [ ] Professional Service (consultant, lawyer, accountant)
- [ ] Creative (photographer, designer, artist)
- [ ] Trade/Construction (landscaping, roofing, remodeling)
- [ ] Other: _____

### Q3: Years in Business
**@switch:** "How many years in business?"
- [ ] Just starting (0-1 years)
- [ ] Growing (2-5 years)
- [ ] Established (5-10 years)
- [ ] Veteran (10+ years)

### Q4: Service Area
**@switch:** "What areas do you serve?"
- City/State: _____
- Radius: _____ miles
- Specific neighborhoods: _____

---

## Section B: Current Presence

### Q5: Current Website
**@switch:** "Do you have a current website?"
- [ ] No website
- [ ] Yes: URL _____ (needs redesign)
- [ ] DIY builder (Wix, Squarespace, etc.)
- [ ] Outdated/needs refresh

### Q6: Social Media
**@switch:** "Active social media accounts?"
- [ ] Facebook: _____
- [ ] Instagram: _____
- [ ] LinkedIn: _____
- [ ] None

### Q7: Google Business Profile
**@switch:** "Do you have a Google Business Profile?"
- [ ] Yes, claimed and active
- [ ] Yes, but not optimized
- [ ] No

---

## Section C: Services & Customers

### Q8: Main Services
**@switch:** "List your main services (top 3-5):"
1. _____
2. _____
3. _____
4. _____
5. _____

### Q9: Target Customer
**@switch:** "Who is your ideal customer?"
- [ ] Homeowners
- [ ] Businesses/commercial
- [ ] Property managers
- [ ] Real estate agents
- [ ] Other: _____

### Q10: Emergency vs Planned
**@switch:** "Are your services typically:"
- [ ] Emergency (need help NOW)
- [ ] Planned (can schedule)
- [ ] Both

---

## Section D: Brand & Messaging

### Q11: Tagline/Headline
**@switch:** "What should the main headline say? (What makes you different)"
Example: "24/7 Emergency Plumbing — We'll Fix It Tonight"

### Q12: Key Message
**@switch:** "In one sentence, why should customers choose you?"

### Q13: Tone
**@switch:** "What tone fits your business?"
- [ ] Professional and formal
- [ ] Friendly and approachable
- [ ] Bold and confident
- [ ] Technical/expert

---

## Section E: Content & Assets

### Q14: Logo
**@switch:** "Do you have a logo?"
- [ ] Yes, high quality files
- [ ] Yes, but needs update
- [ ] No, need one created

### Q15: Photos
**@switch:** "Do you have professional photos?"
- [ ] Yes, many
- [ ] Some
- [ ] No, need stock photos

### Q16: Testimonials/Reviews
**@switch:** "Do you have customer testimonials?"
- [ ] Yes, 5+ written testimonials
- [ ] Yes, but need to collect more
- [ ] No, need to gather

### Q17: Certifications/Licenses
**@switch:** "Professional certifications or licenses to display?"
- [ ] Licensed & insured
- [ ] BBB accredited
- [ ] Industry certifications
- [ ] Awards

---

## Section F: Technical Needs

### Q18: Domain
**@switch:** "Domain name situation:"
- [ ] Already own: _____
- [ ] Need to purchase
- [ ] Use subdomain for now

### Q19: Email
**@switch:** "Business email:"
- [ ] Professional domain email (john@business.com)
- [ ] Gmail/Yahoo (need upgrade)

### Q20: Contact Preferences
**@switch:** "How should customers contact you?"
- [ ] Phone (primary)
- [ ] Contact form
- [ ] Online booking
- [ ] Email

---

## Section G: Competition & Goals

### Q21: Main Competitors
**@switch:** "Who are your 2-3 main competitors?"
1. _____
2. _____
3. _____

### Q22: What They Do Better
**@switch:** "What do competitors do better than you?"

### Q23: Your Advantage
**@switch:** "What do you do better than competitors?"

### Q24: Website Goals
**@switch:** "Primary goal for this website:"
- [ ] Get more phone calls
- [ ] Get more form submissions
- [ ] Build credibility/trust
- [ ] Showcase work/portfolio
- [ ] Rank higher on Google

---

## Section H: Timeline & Budget

### Q25: Launch Date
**@switch:** "When do you need this live?"
- [ ] ASAP (1-2 weeks)
- [ ] Normal (3-4 weeks)
- [ ] Flexible (1-2 months)
- [ ] Specific date: _____

### Q26: Package
**@switch:** "Which package fits your needs?"
- [ ] Essential ($1,500) — 1 page, contact form, mobile
- [ ] Professional ($3,000) — 4 pages, blog, SEO
- [ ] Premium ($5,000) — Custom features, priority support

---

## Output Format

After all questions answered, @switch generates:

```markdown
# Intake: [Business Name]
**Date:** 2026-05-25  
**Client ID:** C001  
**Project ID:** P001

## Business Profile
- **Name:** 
- **Type:** 
- **Years:** 
- **Service Area:** 

## Current Presence
- **Website:** 
- **Social:** 
- **Google Business:** 

## Services
1. 
2. 
3. 

## Target Customer
- 

## Brand
- **Tagline:** 
- **Key Message:** 
- **Tone:** 

## Assets
- **Logo:** 
- **Photos:** 
- **Testimonials:** 
- **Certifications:** 

## Technical
- **Domain:** 
- **Email:** 
- **Contact Method:** 

## Competition
- **Competitors:** 
- **Their Advantage:** 
- **Your Advantage:** 

## Goals
- 

## Timeline & Budget
- **Launch:** 
- **Package:** 
- **Price:** 
```

---

**Next:** Step 2/9 — Client Research
