import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { ServicesList } from "@/components/sections/ServicesList";
import { ProcessShowcase } from "@/components/sections/ProcessShowcase";
import { ContactCTA } from "@/components/sections/ContactCTA";
import servicesData from "@/content/data/services.json";

export const metadata = {
  title: "Services",
  description: "Professional photography services including portraits, commercial work, editorial, events, and fine art prints.",
};

export default function ServicesPage() {
  return (
    <>
      <Header />
      <main>
        <section className="pt-32 pb-16 bg-background">
          <Container>
            <div className="text-center max-w-2xl mx-auto">
              <h1 className="font-display text-4xl sm:text-5xl font-bold mb-4">
                Services
              </h1>
              <p className="text-foreground/60 text-lg">
                Professional photography services tailored to your unique needs and vision. From intimate portraits to large-scale commercial campaigns.
              </p>
            </div>
          </Container>
        </section>

        <ServicesList services={servicesData.services} />
        <ProcessShowcase steps={servicesData.process} />

        <section className="py-24 bg-card">
          <Container size="small">
            <div className="text-center">
              <h2 className="font-display text-3xl font-bold mb-4">
                Ready to Start?
              </h2>
              <p className="text-foreground/60 mb-8">
                Every project begins with a conversation. Let's discuss how we can bring your vision to life.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <a
                  href="mailto:hello@marcuschen.photo"
                  className="inline-flex items-center justify-center rounded-full bg-accent px-8 py-3 text-sm font-medium text-background transition-all hover:bg-accent/90"
                >
                  Email Me Directly
                </a>
                <span className="text-foreground/50 self-center">or</span>
                <a
                  href="tel:+14155550187"
                  className="inline-flex items-center justify-center rounded-full border border-border px-8 py-3 text-sm font-medium transition-all hover:bg-muted"
                >
                  Call +1 (415) 555-0187
                </a>
              </div>
            </div>
          </Container>
        </section>

        <ContactCTA />
      </main>
      <Footer />
    </>
  );
}