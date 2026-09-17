import Link from "next/link";
import { Container } from "@/components/layout/Container";
import { Button } from "@/components/ui/Button";

interface ContactCTAProps {
  title?: string;
  subtitle?: string;
}

export function ContactCTA({
  title = "Let's Create Something Beautiful",
  subtitle = "Ready to bring your vision to life? Get in touch to discuss your project.",
}: ContactCTAProps) {
  return (
    <section className="py-24 bg-accent/5 border-y border-accent/10">
      <Container size="small">
        <div className="text-center">
          <h2 className="font-display text-3xl sm:text-4xl font-bold mb-4">
            {title}
          </h2>
          <p className="text-foreground/60 max-w-xl mx-auto mb-8">
            {subtitle}
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link href="/contact">
              <Button size="lg" className="rounded-full px-8">
                Start a Project
              </Button>
            </Link>
            <Link href="/portfolio">
              <Button variant="outline" size="lg" className="rounded-full px-8">
                View Portfolio
              </Button>
            </Link>
          </div>
        </div>
      </Container>
    </section>
  );
}