import { siteConfig } from "@/config/site";
import {
  getServiceSchema,
  getFAQSchema,
} from "@/lib/structured-data";
import { getPageMetadata } from "@/lib/metadata";
import { Header } from "@/components/sections/header";
import { Footer } from "@/components/sections/footer";
import { CTASection } from "@/components/sections/cta-section";
import { FAQSection } from "@/components/sections/faq-section";
import { ServiceAreaSection } from "@/components/sections/service-area-section";
import { CheckCircle, ArrowRight } from "lucide-react";
import Link from "next/link";
import {
  Wrench,
  Droplets,
  Thermometer,
  Bath,
  Gauge,
  Building2,
  type LucideIcon,
} from "lucide-react";

const pageMeta = getPageMetadata("services");

export const metadata = {
  title: pageMeta.title,
  description: pageMeta.description,
  openGraph: {
    title: pageMeta.title,
    description: pageMeta.description,
    url: `${siteConfig.siteUrl}/services`,
    siteName: siteConfig.businessName,
    locale: "en_US",
    type: "website",
  },
};

// Map service names to icons — uses partial matching for flexibility
// Example: "Drain Cleaning" matches "Drain & Sewer Cleaning"
const getServiceIcon = (serviceName: string): LucideIcon => {
  const name = serviceName.toLowerCase();
  if (name.includes("emergency") || name.includes("repair")) return Wrench;
  if (name.includes("drain") || name.includes("sewer")) return Droplets;
  if (name.includes("water") || name.includes("heater")) return Thermometer;
  if (name.includes("fixture") || name.includes("faucet") || name.includes("toilet")) return Bath;
  // Default fallback
  return Wrench;
};

// Service Page FAQs — Edit questions/answers below
// Tip: Keep template literals on one line to avoid truncation issues
const serviceFAQs = [
  {
    question: `How much do ${siteConfig.serviceType.toLowerCase()} services cost in ${siteConfig.serviceArea}?`,
    answer: `Costs vary depending on the service and complexity. We provide free estimates for most jobs with transparent, upfront pricing — no hidden fees, ever. Contact QuickFlow for a personalized quote.`,
  },
  {
    question: `Does ${siteConfig.businessName} offer emergency ${siteConfig.serviceType.toLowerCase()} services?`,
    answer: `Absolutely. QuickFlow offers 24/7 emergency services for burst pipes, major leaks, sewer backups, and more. Our team is on standby 365 days a year and guarantees arrival within 60 minutes of your call.`,
  },
  {
    question: `What areas of ${siteConfig.serviceArea} do you serve?`,
    answer: `We proudly serve the entire ${siteConfig.serviceArea} area including ${siteConfig.serviceAreaList.slice(0, 6).join(", ")}, and more. Same-day service available across all locations.`,
  },
  {
    question: `Are your plumbers licensed and background-checked?`,
    answer: `Every QuickFlow plumber is fully licensed in VA & DC, insured with $2M liability coverage, and background-checked. We invest in ongoing training to ensure top-quality service on every job.`,
  },
  {
    question: `Do you offer warranties on your work?`,
    answer: `Yes. We stand behind all work with a 90-day guarantee on repairs and comprehensive warranties on installations. If you're not satisfied, we'll make it right. That's our Same-Day Service Guarantee in action.`,
  },
  {
    question: `Can you help with insurance claims for water damage?`,
    answer: `We work with homeowners insurance providers for eligible water damage claims. We can provide detailed invoices, photos, and documentation to support your claim process.`,
  },
];

export default function ServicesPage() {
  return (
    <>
      {/* Structured data for each service */}
      {siteConfig.services.map((service) => (
        <script
          key={service.name}
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify(
              getServiceSchema(
                service.name,
                service.description,
                siteConfig.serviceArea,
                siteConfig.businessName
              )
            ),
          }}
        />
      ))}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(getFAQSchema(serviceFAQs)),
        }}
      />

      <Header />
      <main>
        {/* Page Header — H1 */}
        <section className="bg-muted/40 py-16 md:py-20">
          <div className="container mx-auto px-4 text-center">
            <h1 className="mb-4 text-4xl font-bold md:text-5xl">
              Our {siteConfig.serviceType} Services
            </h1>
            <p className="mx-auto max-w-2xl text-lg text-muted-foreground">
              Professional {siteConfig.serviceType.toLowerCase()} solutions for
              every need. Serving {siteConfig.serviceArea} with quality and
              reliability.
            </p>
          </div>
        </section>

        {/* Service Listings */}
        <section className="py-16 md:py-20">
          <div className="container mx-auto px-4">
            <div className="space-y-16">
              {siteConfig.services.map((service) => {
                const Icon = getServiceIcon(service.name);
                return (
                  <article
                    key={service.name}
                    className="rounded-lg border bg-white p-6 shadow-sm md:p-8"
                  >
                    <div className="flex flex-col gap-6 md:flex-row md:items-start">
                      {/* Icon */}
                      <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-full bg-primary/10">
                        <Icon className="h-7 w-7 text-primary" />
                      </div>

                      {/* Content */}
                      <div className="flex-1">
                        <h2 className="mb-3 text-2xl font-bold">
                          {service.name}
                        </h2>
                        <p className="mb-4 text-muted-foreground">
                          {service.description}
                        </p>

                        {/* Features */}
                        <h3 className="mb-2 text-sm font-semibold uppercase tracking-wider text-muted-foreground">
                          What&apos;s Included
                        </h3>
                        <ul className="mb-6 grid gap-2 sm:grid-cols-2">
                          {service.features.map((feature) => (
                            <li
                              key={feature}
                              className="flex items-start gap-2 text-sm"
                            >
                              <CheckCircle className="mt-0.5 h-4 w-4 shrink-0 text-green-500" />
                              <span>{feature}</span>
                            </li>
                          ))}
                        </ul>

                        <Link
                          href={`/contact?service=${encodeURIComponent(service.name)}`}
                          className="inline-flex items-center justify-center gap-2 rounded-lg bg-primary px-3 py-1.5 text-sm font-medium text-primary-foreground transition-all hover:bg-primary/80"
                        >
                          Get Quote <ArrowRight className="h-3 w-3" />
                        </Link>
                      </div>
                    </div>
                  </article>
                );
              })}
            </div>
          </div>
        </section>

        {/* FAQ about services */}
        <FAQSection
          faqs={serviceFAQs}
          title="Questions About Our Services"
          subtitle={`Everything you need to know about ${siteConfig.businessName} ${siteConfig.serviceType.toLowerCase()} services`}
        />

        <ServiceAreaSection />

        <CTASection variant="services" />
      </main>
      <Footer />
    </>
  );
}
