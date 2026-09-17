import { siteConfig } from "@/config/site";
import { getLocalBusinessSchema, getFAQSchema } from "@/lib/structured-data";
import { getPageMetadata } from "@/lib/metadata";
import { Header } from "@/components/sections/header";
import { Footer } from "@/components/sections/footer";
import { HeroSection } from "@/components/sections/hero-section";
import { ServicesPreview } from "@/components/sections/services-preview";
import { TrustSection } from "@/components/sections/trust-section";
import { TestimonialsSection } from "@/components/sections/testimonials-section";
import { ServiceAreaSection } from "@/components/sections/service-area-section";
import { CTASection } from "@/components/sections/cta-section";
import { FAQSection } from "@/components/sections/faq-section";

const pageMeta = getPageMetadata("home");

export const metadata = {
  title: pageMeta.title,
  description: pageMeta.description,
  openGraph: {
    title: pageMeta.title,
    description: pageMeta.description,
    url: siteConfig.siteUrl,
    siteName: siteConfig.businessName,
    locale: "en_US",
    type: "website",
  },
};

// Home Page FAQs — Edit questions/answers below
// Tip: Keep template literals on one line to avoid truncation issues
const homeFAQ = [
  {
    question: `How fast can you get a plumber to my home in ${siteConfig.serviceArea}?`,
    answer: `For emergencies, we guarantee arrival within 60 minutes. For standard service calls, we offer same-day appointments throughout ${siteConfig.serviceArea}. Just call (703) 555-0123 and we'll have a truck on the way.`,
  },
  {
    question: `Is ${siteConfig.businessName} licensed and insured?`,
    answer: `Absolutely. QuickFlow Plumbing is fully licensed in both Virginia and DC (License #QLCK01), carries $2M in liability insurance, and holds an A+ rating with the Better Business Bureau.`,
  },
  {
    question: `Do you offer free estimates for plumbing work in ${siteConfig.serviceArea}?`,
    answer: `Yes! We provide free, no-obligation estimates for most plumbing services. We believe in transparent, upfront pricing with no hidden fees. Contact us today to schedule yours.`,
  },
  {
    question: `Do you really do same-day service in ${siteConfig.serviceArea}?`,
    answer: `Yes — it's our guarantee. When you call QuickFlow before noon, we'll have a plumber at your door the same day. Our Same-Day Service Guarantee means you never have to wait days for plumbing help.`,
  },
  {
    question: `What types of payment do you accept?`,
    answer: `We accept cash, credit cards, and debit cards. Payment is due upon completion of service. We also work with homeowners insurance for eligible claims.`,
  },
  {
    question: `Do you service homes and businesses?`,
    answer: `Yes. QuickFlow Plumbing provides expert plumbing services for both residential and commercial properties throughout Northern Virginia. From single-family homes to office buildings, we've got you covered.`,
  },
];

export default function HomePage() {
  const localBusinessSchema = getLocalBusinessSchema();
  const faqSchema = getFAQSchema(homeFAQ);

  return (
    <>
      {/* JSON-LD Structured Data */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(localBusinessSchema),
        }}
      />
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(faqSchema),
        }}
      />

      <Header />
      <main>
        <article>
          {/* H1 is in HeroSection for answer-first SEO */}
          <HeroSection />

          <ServicesPreview />

          <TrustSection />

          <TestimonialsSection />

          <ServiceAreaSection />

          {/* FAQ Section - Critical for LLM SEO */}
          <FAQSection
            faqs={homeFAQ}
            subtitle={`Common questions about our ${siteConfig.serviceType.toLowerCase()} services in ${siteConfig.serviceArea}`}
          />

          <CTASection />
        </article>
      </main>
      <Footer />
    </>
  );
}
