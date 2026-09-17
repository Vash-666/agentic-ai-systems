import { siteConfig } from "@/config/site";
import Link from "next/link";
import { ArrowRight } from "lucide-react";

export function CTASection({ variant = "default" }: { variant?: "default" | "services" | "about" }) {
  const config = {
    default: {
      headline: "Ready to Get Started?",
      subheadline: "Call us today for fast, professional service",
      buttonText: "Request Free Quote",
      buttonLink: "/contact",
    },
    services: {
      headline: `Need ${siteConfig.services[0]?.name || "Service"} Today?`,
      subheadline: "Call us for prompt, reliable service",
      buttonText: "Get Free Quote",
      buttonLink: "/contact",
    },
    about: {
      headline: `Experience the ${siteConfig.businessName} Difference`,
      subheadline: "Contact us today for quality service you can trust",
      buttonText: "Contact Us Today",
      buttonLink: "/contact",
    },
  };

  const cta = config[variant];

  return (
    <section className="bg-primary py-16 text-primary-foreground md:py-20">
      <div className="container mx-auto px-4 text-center">
        <h2 className="mb-4 text-3xl font-bold md:text-4xl">
          {cta.headline}
        </h2>
        <p className="mb-6 text-lg text-primary-foreground/80">
          {cta.subheadline}
        </p>

        <div className="flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
          <a
            href={`tel:${siteConfig.phone}`}
            className="inline-flex items-center gap-2 rounded-md bg-white px-6 py-3 text-base font-semibold text-primary shadow-lg transition-all hover:bg-white/90"
          >
            {siteConfig.phone}
          </a>
          <Link
            href={cta.buttonLink}
            className="inline-flex items-center gap-2 rounded-md border border-primary-foreground/30 bg-primary-foreground/10 px-6 py-3 text-base font-semibold text-primary-foreground shadow-lg transition-all hover:bg-primary-foreground/20"
          >
            {cta.buttonText}
            <ArrowRight className="h-4 w-4" />
          </Link>
        </div>

        <p className="mt-4 text-sm text-primary-foreground/70">
          Available Monday – Saturday | 24/7 Emergency Service
        </p>
      </div>
    </section>
  );
}
