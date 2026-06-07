import { siteConfig } from "@/config/site";
import { getLocalBusinessSchema } from "@/lib/structured-data";
import { getPageMetadata } from "@/lib/metadata";
import { Header } from "@/components/sections/header";
import { Footer } from "@/components/sections/footer";
import { CTASection } from "@/components/sections/cta-section";
import { Badge } from "@/components/ui/badge";
import {
  Award,
  Shield,
  Clock,
  Heart,
  Briefcase,
  Star,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

const pageMeta = getPageMetadata("about");

export const metadata = {
  title: pageMeta.title,
  description: pageMeta.description,
  openGraph: {
    title: pageMeta.title,
    description: pageMeta.description,
    url: `${siteConfig.siteUrl}/about`,
    siteName: siteConfig.businessName,
    locale: "en_US",
    type: "website",
  },
};

const credentialIcons: LucideIcon[] = [
  Award,
  Shield,
  Clock,
  Star,
  Briefcase,
  Heart,
];

export default function AboutPage() {
  const localBusinessSchema = getLocalBusinessSchema();

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(localBusinessSchema),
        }}
      />

      <Header />
      <main>
        {/* Page Header — H1 */}
        <section className="bg-muted/40 py-16 md:py-20">
          <div className="container mx-auto px-4 text-center">
            <h1 className="mb-4 text-4xl font-bold md:text-5xl">
              About {siteConfig.businessName}
            </h1>
            <p className="mx-auto max-w-2xl text-lg text-muted-foreground">
              Your Trusted {siteConfig.serviceType} Experts in{" "}
              {siteConfig.serviceArea} — Serving with Integrity Since{" "}
              {siteConfig.yearEstablished}
            </p>
          </div>
        </section>

        {/* Business Story */}
        <section className="py-16 md:py-20">
          <div className="container mx-auto px-4">
            <div className="mx-auto max-w-4xl">
              <div className="grid gap-10 md:grid-cols-2 md:items-center">
                {/* Photo placeholder */}
                <div className="flex items-center justify-center">
                  <div className="flex h-80 w-full items-center justify-center rounded-xl bg-muted">
                    <div className="text-center">
                      <Briefcase className="mx-auto mb-2 h-12 w-12 text-muted-foreground/50" />
                      <p className="text-sm text-muted-foreground">
                        {siteConfig.ownerName}, Owner
                      </p>
                      <p className="text-xs text-muted-foreground/60">
                        (Replace this with your photo)
                      </p>
                    </div>
                  </div>
                </div>

                {/* Story */}
                <div>
                  <h2 className="mb-4 text-3xl font-bold">Our Story</h2>
                  <div className="space-y-4 text-muted-foreground leading-relaxed">
                    {siteConfig.businessStory
                      .split("\n\n")
                      .map((paragraph, i) => (
                        <p key={i}>{paragraph}</p>
                      ))}
                  </div>

                  {/* Authority badges */}
                  <div className="mt-6 flex flex-wrap gap-3">
                    <Badge variant="secondary" className="text-sm">
                      {siteConfig.yearsInBusiness}+ Years Experience
                    </Badge>
                    <Badge variant="secondary" className="text-sm">
                      Licensed &amp; Insured
                    </Badge>
                    <Badge variant="secondary" className="text-sm">
                      24/7 Emergency Service
                    </Badge>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Credentials & Certifications */}
        <section className="bg-muted/30 py-16 md:py-20">
          <div className="container mx-auto px-4 text-center">
            <h2 className="mb-4 text-3xl font-bold">
              Licensed, Insured, &amp; Certified
            </h2>
            <p className="mb-10 text-lg text-muted-foreground">
              We meet the highest standards in the industry
            </p>

            <div className="mx-auto grid max-w-4xl grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {siteConfig.credentials.map((credential, i) => {
                const Icon = credentialIcons[i] || Award;
                return (
                  <div
                    key={credential.name}
                    className="flex flex-col items-center rounded-lg border bg-white p-6 shadow-sm"
                  >
                    <div className="mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
                      <Icon className="h-6 w-6 text-primary" />
                    </div>
                    <h3 className="mb-1 text-lg font-semibold">
                      {credential.name}
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      {credential.details}
                    </p>
                  </div>
                );
              })}
            </div>
          </div>
        </section>

        {/* Values */}
        <section className="py-16 md:py-20">
          <div className="container mx-auto px-4 text-center">
            <h2 className="mb-4 text-3xl font-bold">
              Our Commitment to You
            </h2>
            <p className="mb-10 text-lg text-muted-foreground">
              The values that guide every service we provide
            </p>

            <div className="mx-auto grid max-w-3xl grid-cols-1 gap-6 sm:grid-cols-2">
              {[
                {
                  title: "Quality Workmanship",
                  desc: "We never cut corners. Every job is done right the first time with premium materials and proven techniques.",
                },
                {
                  title: "Honest Communication",
                  desc: "We explain the problem, show you the options, and give you clear pricing before any work begins.",
                },
                {
                  title: "Respect for Your Home",
                  desc: "We treat your property with care, using protective covers, cleaning up thoroughly, and minimizing disruption.",
                },
                {
                  title: "Stand Behind Our Work",
                  desc: "If something isn't right, we make it right. Your satisfaction isn't just our goal — it's our guarantee.",
                },
              ].map((value) => (
                <div
                  key={value.title}
                  className="rounded-lg border bg-white p-6 text-left shadow-sm"
                >
                  <h3 className="mb-2 text-lg font-semibold">
                    {value.title}
                  </h3>
                  <p className="text-sm text-muted-foreground">
                    {value.desc}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <CTASection variant="about" />
      </main>
      <Footer />
    </>
  );
}
