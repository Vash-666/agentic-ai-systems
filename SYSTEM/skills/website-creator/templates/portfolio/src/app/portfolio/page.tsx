import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { PortfolioGrid } from "@/components/sections/PortfolioGrid";
import { ContactCTA } from "@/components/sections/ContactCTA";
import projectsData from "@/content/data/projects.json";

export const metadata = {
  title: "Portfolio",
  description: "A curated collection of portrait, landscape, commercial, and editorial photography by Marcus Chen.",
};

export default function PortfolioPage() {
  return (
    <>
      <Header />
      <main>
        <section className="pt-32 pb-16 bg-background">
          <Container>
            <div className="text-center max-w-2xl mx-auto">
              <h1 className="font-display text-4xl sm:text-5xl font-bold mb-4">
                Portfolio
              </h1>
              <p className="text-foreground/60 text-lg">
                A curated collection of work spanning portraits, landscapes, commercial projects, and editorial features.
              </p>
            </div>
          </Container>
        </section>
        <PortfolioGrid projects={projectsData.projects} />
        <ContactCTA />
      </main>
      <Footer />
    </>
  );
}