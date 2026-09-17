import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { Container } from "@/components/layout/Container";

interface Project {
  id: string;
  title: string;
  category: string;
  image: string;
}

interface FeaturedWorksProps {
  projects: Project[];
  title?: string;
  subtitle?: string;
}

export function FeaturedWorks({
  projects,
  title = "Featured Work",
  subtitle = "A selection of recent projects that showcase my approach to visual storytelling.",
}: FeaturedWorksProps) {
  return (
    <section className="py-24 bg-background">
      <Container>
        <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-12">
          <div>
            <h2 className="font-display text-3xl sm:text-4xl font-bold mb-4">
              {title}
            </h2>
            <p className="text-foreground/60 max-w-xl">{subtitle}</p>
          </div>
          <Link
            href="/portfolio"
            className="inline-flex items-center gap-2 text-accent hover:underline font-medium"
          >
            View All Projects
            <ArrowRight className="h-4 w-4" />
          </Link>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {projects.map((project, index) => (
            <Link
              key={project.id}
              href={`/portfolio#${project.id}`}
              className={`group relative overflow-hidden rounded-lg ${
                index === 0 ? "md:col-span-2 aspect-[21/9]" : "aspect-[4/3]"
              }`}
            >
              <img
                src={project.image}
                alt={project.title}
                className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent opacity-60 group-hover:opacity-80 transition-opacity" />
              <div className="absolute bottom-0 left-0 right-0 p-6">
                <p className="text-sm font-medium text-accent mb-1">
                  {project.category}
                </p>
                <h3 className="font-display text-xl sm:text-2xl font-semibold text-white">
                  {project.title}
                </h3>
              </div>
            </Link>
          ))}
        </div>
      </Container>
    </section>
  );
}