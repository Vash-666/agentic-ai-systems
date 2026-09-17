import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { HeroFullBleed } from "@/components/sections/HeroFullBleed";
import { FeaturedWorks } from "@/components/sections/FeaturedWorks";
import { AboutSnippet } from "@/components/sections/AboutSnippet";
import { ServicesList } from "@/components/sections/ServicesList";
import { JournalPreview } from "@/components/sections/JournalPreview";
import { ContactCTA } from "@/components/sections/ContactCTA";
import artistData from "@/content/data/artist.json";
import projectsData from "@/content/data/projects.json";
import servicesData from "@/content/data/services.json";
import journalData from "@/content/data/journal.json";

export default function HomePage() {
  const featuredProjects = projectsData.projects
    .filter((p) => p.featured)
    .slice(0, 3);

  const stats = [
    { label: "Projects", value: artistData.stats.projectsCompleted.toString() },
    { label: "Clients", value: artistData.stats.happyClients.toString() },
    { label: "Awards", value: artistData.stats.awardsWon.toString() },
    { label: "Experience", value: `${artistData.stats.yearsExperience}+` },
  ];

  const featuredPosts = journalData.posts
    .filter((p) => p.featured)
    .slice(0, 3);

  return (
    <>
      <Header />
      <main>
        <HeroFullBleed
          title="Capturing Moments That Transcend Time"
          subtitle="Award-winning photography for those who seek the extraordinary"
        />
        <FeaturedWorks
          projects={featuredProjects}
        />
        <AboutSnippet
          name={artistData.name}
          title={artistData.title}
          bio={artistData.bio}
          image="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80"
          stats={stats}
        />
        <ServicesList services={servicesData.services.slice(0, 3)} />
        <JournalPreview posts={featuredPosts} />
        <ContactCTA />
      </main>
      <Footer />
    </>
  );
}