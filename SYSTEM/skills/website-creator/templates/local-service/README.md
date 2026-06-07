# Local Service Business Template

A professional, SEO-optimized Next.js template for local service businesses (plumbers, electricians, HVAC, cleaners, landscapers, etc.).

## Features

- **4 Pages** — Home, Services, About, Contact
- **LLM SEO Optimized** — Answer-first content, clear hierarchy, entity signals
- **JSON-LD Structured Data** — LocalBusiness, Service, FAQPage schemas
- **Sticky Header** — Phone number always visible
- **Contact Form** — React Hook Form + Zod validation
- **Mobile Responsive** — Desktop, tablet, and mobile layouts
- **Easy Customization** — Single config file for all content
- **Semantic HTML** — Clean markup for AI parsing

## Quick Start

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

## Customization

Edit `src/config/site.ts` to customize all content:

```typescript
export const siteConfig = {
  businessName: "Your Business Name",
  tagline: "Your Tagline",
  phone: "(555) 123-4567",
  email: "info@yourbusiness.com",
  // ... and more
};
```

## Pages

| Page | Route | Key Features |
|------|-------|-------------|
| Home | `/` | Hero with answer-first headline, services preview, testimonials, FAQ, trust signals |
| Services | `/services` | Detailed service listings with features, FAQ, service area |
| About | `/about` | Business story, owner photo placeholder, credentials, values |
| Contact | `/contact` | Contact form, business hours, map placeholder, emergency info |

## Tech Stack

- **Framework:** Next.js 16 (App Router)
- **Styling:** Tailwind CSS 4 + shadcn/ui
- **Forms:** React Hook Form + Zod
- **Icons:** Lucide React
- **TypeScript** throughout

## Structured Data

All pages include JSON-LD schema markup:
- **LocalBusiness** — Business name, address, phone, hours, service area
- **FAQPage** — FAQ sections with Question/Answer schema
- **Service** — Per-service schema on Services page

## Build

```bash
npm run build
```

## Deploy

Deploy to Vercel, Netlify, or any Node.js hosting:
```bash
npm run build
npm start
```

## License

MIT
