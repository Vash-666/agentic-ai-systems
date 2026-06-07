import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { Container } from "@/components/layout/Container";
import { Button } from "@/components/ui/Button";
import business from "@/content/data/business.json";

interface CTABannerProps {
  variant?: "default" | "dark";
  title?: string;
  description?: string;
}

function CTABanner({
  variant = "default",
  title = "Ready to Discuss Your Legal Needs?",
  description = `Contact ${business.name} today to schedule a consultation with one of our experienced attorneys.`,
}: CTABannerProps) {
  const isDark = variant === "dark";

  return (
    <section className={isDark ? "bg-navy-900 py-16" : "bg-gold-500 py-16"}>
      <Container>
        <div className="flex flex-col md:flex-row items-center justify-between gap-8">
          <div className="text-center md:text-left">
            <h2
              className={`font-heading text-2xl md:text-3xl font-bold mb-2 ${
                isDark ? "text-white" : "text-navy-900"
              }`}
            >
              {title}
            </h2>
            <p
              className={`max-w-xl ${
                isDark ? "text-cream-200" : "text-navy-800"
              }`}
            >
              {description}
            </p>
          </div>
          <div className="flex flex-col sm:flex-row gap-4">
            <Button
              variant={isDark ? "secondary" : "default"}
              size="lg"
              asChild
            >
              <Link href="/contact" className="gap-2">
                Schedule Consultation
                <ArrowRight className="h-4 w-4" />
              </Link>
            </Button>
            <Button
              variant={isDark ? "outline" : "outline"}
              size="lg"
              asChild
              className={
                isDark
                  ? "border-cream-200 text-cream-100 hover:bg-navy-800"
                  : "border-navy-800 text-navy-900 hover:bg-gold-400"
              }
            >
              <Link href="/services">Explore Services</Link>
            </Button>
          </div>
        </div>
      </Container>
    </section>
  );
}

export { CTABanner };
