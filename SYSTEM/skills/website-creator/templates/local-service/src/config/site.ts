/**
 * Site Configuration
 * 
 * Edit this file to customize the template for your business.
 * All content across the site pulls from these variables.
 */

export type Service = {
  name: string;
  description: string;
  features: string[];
};

export type Testimonial = {
  quote: string;
  name: string;
  location: string;
};

export type TrustPoint = {
  headline: string;
  description: string;
};

export type Credential = {
  name: string;
  details: string;
};

export type BusinessHours = {
  [day: string]: string;
};

export const siteConfig = {
  // ── Business Info ──────────────────────────────────────────
  businessName: "QuickFlow Plumbing",
  tagline: "Same-Day Service, Guaranteed",
  serviceType: "Plumbing",
  phone: "(703) 555-0123",
  emergencyPhone: "(703) 555-0123",
  email: "service@quickflowplumbing.com",

  // ── Address ────────────────────────────────────────────────
  address: {
    street: "1234 Main St",
    city: "Fairfax",
    state: "VA",
    zip: "22030",
  },

  // ── Service Area ───────────────────────────────────────────
  serviceArea: "Northern Virginia",
  serviceAreaList: [
    "Fairfax",
    "Arlington",
    "Alexandria",
    "McLean",
    "Vienna",
    "Falls Church",
    "Annandale",
    "Springfield",
    "Burke",
    "Lorton",
  ],

  // ── Branding ───────────────────────────────────────────────
  primaryColor: "#0066cc",
  siteUrl: "https://quickflowplumbing.com",

  // ── Business Details ───────────────────────────────────────
  yearEstablished: "2009",
  yearsInBusiness: 15,
  licenseNumber: "VA Master Plumber License #QLCK01",
  responseTime: "1 hour",

  // ── Business Hours ─────────────────────────────────────────
  businessHours: {
    "Monday": "7:00 AM – 8:00 PM",
    "Tuesday": "7:00 AM – 8:00 PM",
    "Wednesday": "7:00 AM – 8:00 PM",
    "Thursday": "7:00 AM – 8:00 PM",
    "Friday": "7:00 AM – 8:00 PM",
    "Saturday": "8:00 AM – 6:00 PM",
    "Sunday": "24/7 Emergency Service",
  },

  // ── Services (used for service cards and detailed listings) ─
  services: [
    {
      name: "Emergency Repairs",
      shortDescription: "24/7 response for burst pipes, leaks, and urgent issues",
      description: "Available 24/7 for urgent plumbing issues including burst pipes, major leaks, and sewer backups. Our team is always ready to respond when you need us most — day or night.",
      features: [
        "24/7 emergency response, every day of the year",
        "Arrive within 60 minutes of your call",
        "Fully stocked vehicles for same-trip repairs",
        "Upfront pricing before any work begins",
        "90-day guarantee on all emergency repairs",
      ],
    },
    {
      name: "Drain Cleaning",
      shortDescription: "Professional drain cleaning to clear clogs and restore flow",
      description: "Professional drain cleaning using the latest equipment to clear tough clogs and restore your plumbing to full flow. From slow drains to complete blockages, we handle it all.",
      features: [
        "Video camera drain inspections",
        "Hydro-jetting for stubborn clogs",
        "Main line and lateral cleaning",
        "Preventative maintenance plans",
        "Root removal and prevention",
      ],
    },
    {
      name: "Water Heater Service",
      shortDescription: "Installation, repair, and maintenance for all water heaters",
      description: "Complete water heater installation, repair, and maintenance for traditional tank and modern tankless systems. We service all major brands and models.",
      features: [
        "Traditional and tankless water heaters",
        "Same-day installation available",
        "Energy-efficient upgrades to save money",
        "Factory warranty service on all brands",
        "Annual maintenance and flush services",
        "Emergency water heater repair",
      ],
    },
    {
      name: "Fixture Installation",
      shortDescription: "Faucets, toilets, sinks, and more — installed right",
      description: "Expert installation and replacement of faucets, toilets, sinks, garbage disposals, and other plumbing fixtures for kitchens and bathrooms throughout your home.",
      features: [
        "Kitchen and bathroom fixture installation",
        "Low-flow water-saving upgrades",
        "Modern design and style options",
        "Leak repair and fixture replacement",
        "Same-day fixture service available",
      ],
    },
  ] as (Service & { shortDescription: string })[],

  // ── Hero Section ───────────────────────────────────────────
  heroHeadline: "Same-Day Plumbing Service, Guaranteed",
  heroSubheadline: "24/7 Emergency Repairs | Licensed & Insured | Northern Virginia",

  // ── Trust Points ───────────────────────────────────────────
  trustPoints: [
    {
      headline: "Licensed & Insured",
      description: "VA & DC Licensed | $2M Liability Insurance",
    },
    {
      headline: "15 Years Experience",
      description: "Serving Northern Virginia since 2009",
    },
    {
      headline: "Satisfaction Guaranteed",
      description: "100% satisfaction or we make it right",
    },
    {
      headline: "Upfront Pricing",
      description: "No hidden fees — ever",
    },
    {
      headline: "BBB A+ Rated",
      description: "Accredited business with Better Business Bureau",
    },
    {
      headline: "24/7 Emergency Service",
      description: "Available any time, day or night",
    },
  ] as TrustPoint[],

  // ── Testimonials ───────────────────────────────────────────
  testimonials: [
    {
      quote: "Our basement flooded at 2 AM on a Sunday. QuickFlow had someone at our door by 3 AM. They had everything under control by 5 AM. Absolute lifesavers.",
      name: "Jennifer R.",
      location: "Fairfax, VA",
    },
    {
      quote: "Mike and his team replaced our old water heater same-day. Professional, fair price, and they cleaned up every drop. Won't call anyone else.",
      name: "Tom W.",
      location: "McLean, VA",
    },
    {
      quote: "Had a clogged kitchen drain that three other plumbers couldn't fix. QuickFlow diagnosed it in 10 minutes with their camera. Fixed it and it's been perfect ever since.",
      name: "Patricia L.",
      location: "Alexandria, VA",
    },
  ] as Testimonial[],

  // ── About Page ─────────────────────────────────────────────
  businessStory: `QuickFlow Plumbing was founded in 2009 with a simple mission: provide same-day, reliable plumbing services that homeowners and businesses in Northern Virginia can count on.

As a family-owned and operated business, we understand how stressful plumbing emergencies can be. A burst pipe at midnight or a clogged drain on Thanksgiving doesn't wait. That's why we answer the phone 24/7 and arrive within an hour, every time.

With 15 years of experience serving Fairfax, Arlington, Alexandria, McLean, and the entire Northern Virginia region, we've built our reputation on speed, honesty, and quality workmanship. Our team of licensed, insured plumbers brings expertise and professionalism to every service call.

We're proud to hold an A+ rating with the Better Business Bureau and are fully licensed in both Virginia and DC. When you call QuickFlow Plumbing, you get same-day service — guaranteed.`,

  ownerName: "Mike Johnson",

  // ── Credentials ────────────────────────────────────────────
  credentials: [
    { name: "State Licensed", details: "VA Master Plumber License #QLCK01 | DC Licensed" },
    { name: "Fully Insured", details: "$2M Liability Insurance | Workers Comp" },
    { name: "15 Years Experience", details: "Serving Northern Virginia since 2009" },
    { name: "BBB Accredited", details: "A+ Rating since 2012" },
    { name: "Emergency Services", details: "24/7 Availability — 60-minute response" },
    { name: "Satisfaction Guaranteed", details: "100% Customer Satisfaction — or we make it right" },
  ] as Credential[],
};

export type SiteConfig = typeof siteConfig;
