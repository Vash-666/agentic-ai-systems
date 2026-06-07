import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { ContactCTA } from "@/components/sections/ContactCTA";
import { AvailabilityBadge } from "@/components/features/AvailabilityBadge";
import { SocialLinks } from "@/components/features/SocialLinks";
import { Camera, Award, Globe, Users } from "lucide-react";
import artistData from "@/content/data/artist.json";

export const metadata = {
  title: "About",
  description: "Learn about Marcus Chen, award-winning photographer based in San Francisco.",
};

export default function AboutPage() {
  const expertiseIcons = [
    { icon: Camera, label: "Photography" },
    { icon: Award, label: "Awards" },
    { icon: Globe, label: "Worldwide" },
    { icon: Users, label: "Clients" },
  ];

  const socialLinks = [
    { platform: "Instagram", url: artistData.social.instagram, icon: "Instagram" },
    { platform: "Twitter", url: artistData.social.twitter, icon: "Twitter" },
    { platform: "LinkedIn", url: artistData.social.linkedin, icon: "Linkedin" },
  ];

  return (
    <>
      <Header />
      <main>
        <section className="pt-32 pb-16 bg-background">
          <Container>
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
              <div className="relative">
                <div className="aspect-[4/5] rounded-lg overflow-hidden">
                  <img
                    src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80"
                    alt={artistData.name}
                    className="h-full w-full object-cover"
                  />
                </div>
              </div>

              <div className="space-y-6">
                <AvailabilityBadge
                  status={artistData.availability.status as "available" | "limited" | "booked"}
                  nextAvailable={artistData.availability.nextAvailable}
                />

                <div>
                  <h1 className="font-display text-4xl sm:text-5xl font-bold mb-2">
                    {artistData.name}
                  </h1>
                  <p className="text-xl text-accent">{artistData.title}</p>
                </div>

                <p className="text-foreground/70 leading-relaxed text-lg">
                  {artistData.bio}
                </p>

                <div className="grid grid-cols-2 sm:grid-cols-4 gap-6 py-6">
                  <div className="text-center">
                    <p className="font-display text-3xl font-bold text-accent">
                      {artistData.stats.yearsExperience}+
                    </p>
                    <p className="text-sm text-foreground/60">Years Experience</p>
                  </div>
                  <div className="text-center">
                    <p className="font-display text-3xl font-bold text-accent">
                      {artistData.stats.projectsCompleted}+
                    </p>
                    <p className="text-sm text-foreground/60">Projects</p>
                  </div>
                  <div className="text-center">
                    <p className="font-display text-3xl font-bold text-accent">
                      {artistData.stats.awardsWon}
                    </p>
                    <p className="text-sm text-foreground/60">Awards</p>
                  </div>
                  <div className="text-center">
                    <p className="font-display text-3xl font-bold text-accent">
                      {artistData.stats.happyClients}+
                    </p>
                    <p className="text-sm text-foreground/60">Happy Clients</p>
                  </div>
                </div>

                <div>
                  <h3 className="font-display text-lg font-semibold mb-3">
                    Areas of Expertise
                  </h3>
                  <div className="flex flex-wrap gap-2">
                    {artistData.expertise.map((skill) => (
                      <span
                        key={skill}
                        className="px-3 py-1 rounded-full bg-muted text-sm text-foreground/80"
                      >
                        {skill}
                      </span>
                    ))}
                  </div>
                </div>

                <div className="pt-4">
                  <h3 className="font-display text-lg font-semibold mb-3">
                    Connect
                  </h3>
                  <SocialLinks links={socialLinks} iconSize="lg" />
                </div>
              </div>
            </div>
          </Container>
        </section>

        <section className="py-24 bg-card">
          <Container size="small">
            <div className="text-center">
              <h2 className="font-display text-3xl font-bold mb-6">
                My Philosophy
              </h2>
              <blockquote className="text-xl sm:text-2xl text-foreground/80 italic leading-relaxed">
                "Photography is not about capturing what you see—it's about capturing what you feel. Every image should tell a story, evoke an emotion, and transport the viewer to that exact moment in time."
              </blockquote>
              <p className="mt-4 text-accent font-medium">— Marcus Chen</p>
            </div>
          </Container>
        </section>

        <ContactCTA />
      </main>
      <Footer />
    </>
  );
}