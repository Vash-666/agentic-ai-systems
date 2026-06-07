import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Hero } from "@/components/sections/Hero";
import { TrustBadges } from "@/components/sections/TrustBadges";
import { ServicesGrid } from "@/components/sections/ServicesGrid";
import { AboutPreview } from "@/components/sections/AboutPreview";
import { TestimonialsSlider } from "@/components/sections/TestimonialsSlider";
import { CTABanner } from "@/components/sections/CTABanner";
import { ResourcesPreview } from "@/components/sections/ResourcesPreview";

export const metadata = {
  title: "Sterling & Associates | Premier Legal Services",
  description: "Trusted legal counsel for businesses and individuals. Over 25 years of excellence in corporate law, litigation, and estate planning.",
};

export default function HomePage() {
  return (
    <>
      <Header />
      <main className="flex-1">
        <Hero />
        <TrustBadges />
        <ServicesGrid />
        <AboutPreview />
        <TestimonialsSlider />
        <ResourcesPreview />
        <CTABanner variant="dark" />
      </main>
      <Footer />
    </>
  );
}
