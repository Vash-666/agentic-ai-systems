import { siteConfig } from "@/config/site";
import { Phone, ArrowRight } from "lucide-react";
import Link from "next/link";

export function HeroSection() {
  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-primary/5 via-background to-primary/10 py-20 md:py-28">
      <div className="container mx-auto px-4">
        <div className="mx-auto max-w-3xl text-center">
          {/* Answer-first headline */}
          <h1 className="mb-4 text-4xl font-bold leading-tight tracking-tight md:text-5xl lg:text-6xl">
            {siteConfig.heroHeadline}
          </h1>

          <p className="mb-8 text-lg text-muted-foreground md:text-xl">
            {siteConfig.heroSubheadline}
          </p>

          {/* Primary CTA */}
          <div className="flex flex-col items-center gap-4 sm:flex-row sm:justify-center">
            <a
              href={`tel:${siteConfig.phone}`}
              className="inline-flex items-center justify-center gap-2 rounded-lg bg-primary px-6 py-3 text-base font-semibold text-primary-foreground shadow-sm transition-all hover:bg-primary/80 w-full sm:w-auto"
            >
              <Phone className="h-5 w-5" />
              Call Now: {siteConfig.phone}
            </a>
            <Link
              href="/contact"
              className="inline-flex items-center justify-center gap-2 rounded-lg border border-border bg-background px-6 py-3 text-base font-semibold shadow-sm transition-all hover:bg-muted w-full sm:w-auto"
            >
              Get Free Quote
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>

          {/* Trust badges */}
          <div className="mt-10 flex flex-wrap items-center justify-center gap-x-6 gap-y-2 text-sm text-muted-foreground">
            <span className="flex items-center gap-1">
              <span className="text-primary">✓</span> Licensed &amp; Insured
            </span>
            <span className="flex items-center gap-1">
              <span className="text-primary">✓</span> {siteConfig.yearsInBusiness}+ Years
            </span>
            <span className="flex items-center gap-1">
              <span className="text-primary">✓</span> 24/7 Emergency Service
            </span>
            <span className="flex items-center gap-1">
              <span className="text-primary">✓</span> Satisfaction Guaranteed
            </span>
          </div>
        </div>
      </div>
    </section>
  );
}
