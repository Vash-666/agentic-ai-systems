import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { HeroLanding } from "@/components/sections/HeroLanding";
import { ProblemAgitation } from "@/components/sections/ProblemAgitation";
import { SolutionReveal } from "@/components/sections/SolutionReveal";
import { FeaturesGrid } from "@/components/sections/FeaturesGrid";
import { SocialProof } from "@/components/sections/SocialProof";
import { StatsBar } from "@/components/sections/StatsBar";
import { HowItWorks } from "@/components/sections/HowItWorks";
import { PricingTable } from "@/components/sections/PricingTable";
import { TestimonialsCarousel } from "@/components/sections/TestimonialsCarousel";
import { FAQAccordion } from "@/components/sections/FAQAccordion";
import { FinalCTA } from "@/components/sections/FinalCTA";
import { StickyBanner } from "@/components/sections/StickyBanner";

export default function Home() {
  return (
    <>
      <Header />
      <main>
        <HeroLanding />
        <SocialProof />
        <ProblemAgitation />
        <SolutionReveal />
        <FeaturesGrid />
        <StatsBar />
        <HowItWorks />
        <TestimonialsCarousel />
        <PricingTable />
        <FAQAccordion />
        <FinalCTA />
      </main>
      <Footer />
      <StickyBanner />
    </>
  );
}
