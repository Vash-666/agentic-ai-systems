"use client";

import { useState } from "react";
import { Container } from "@/components/layout/Container";
import { FilterTabs } from "@/components/ui/FilterTabs";
import { Lightbox } from "@/components/ui/Lightbox";

interface Project {
  id: string;
  title: string;
  category: string;
  image: string;
  description?: string;
}

interface PortfolioGridProps {
  projects: Project[];
}

export function PortfolioGrid({ projects }: PortfolioGridProps) {
  const [activeCategory, setActiveCategory] = useState("All");
  const [lightboxOpen, setLightboxOpen] = useState(false);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  const categories = ["All", ...Array.from(new Set(projects.map((p) => p.category)))];

  const filteredProjects =
    activeCategory === "All"
      ? projects
      : projects.filter((p) => p.category === activeCategory);

  const lightboxImages = filteredProjects.map((p) => ({
    src: p.image,
    alt: p.title,
    title: p.title,
  }));

  const openLightbox = (index: number) => {
    setCurrentImageIndex(index);
    setLightboxOpen(true);
  };

  return (
    <section className="py-24 bg-background">
      <Container>
        <div className="text-center mb-12">
          <h2 className="font-display text-3xl sm:text-4xl font-bold mb-4">
            Portfolio
          </h2>
          <p className="text-foreground/60 max-w-2xl mx-auto mb-8">
            A curated collection of work spanning portraits, landscapes, commercial projects, and editorial features.
          </p>
          <FilterTabs
            categories={categories}
            activeCategory={activeCategory}
            onSelect={setActiveCategory}
          />
        </div>

        <div className="columns-1 sm:columns-2 lg:columns-3 gap-4 space-y-4">
          {filteredProjects.map((project, index) => (
            <div
              key={project.id}
              className="break-inside-avoid group relative overflow-hidden rounded-lg cursor-pointer"
              onClick={() => openLightbox(index)}
            >
              <div className="aspect-auto">
                <img
                  src={project.image}
                  alt={project.title}
                  className="w-full h-auto object-cover transition-transform duration-500 group-hover:scale-105"
                />
              </div>
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                <div className="absolute bottom-0 left-0 right-0 p-4">
                  <p className="text-sm font-medium text-accent mb-1">
                    {project.category}
                  </p>
                  <h3 className="font-display text-lg font-semibold text-white">
                    {project.title}
                  </h3>
                  {project.description && (
                    <p className="text-sm text-white/70 mt-1 line-clamp-2">
                      {project.description}
                    </p>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </Container>

      <Lightbox
        isOpen={lightboxOpen}
        onClose={() => setLightboxOpen(false)}
        images={lightboxImages}
        currentIndex={currentImageIndex}
        onNavigate={setCurrentImageIndex}
      />
    </section>
  );
}