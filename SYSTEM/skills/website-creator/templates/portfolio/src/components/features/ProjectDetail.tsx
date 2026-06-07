import { Container } from "@/components/layout/Container";
import { Button } from "@/components/ui/Button";
import { ArrowLeft, Calendar, User } from "lucide-react";
import Link from "next/link";

interface ProjectDetailProps {
  project: {
    id: string;
    title: string;
    category: string;
    description: string;
    image: string;
    year: number;
    client: string;
  };
}

export function ProjectDetail({ project }: ProjectDetailProps) {
  return (
    <article className="py-24 bg-background">
      <Container>
        <Link href="/portfolio">
          <Button variant="ghost" className="mb-8 -ml-4">
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Portfolio
          </Button>
        </Link>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
          <div className="lg:col-span-2">
            <div className="aspect-[16/10] rounded-lg overflow-hidden mb-8">
              <img
                src={project.image}
                alt={project.title}
                className="h-full w-full object-cover"
              />
            </div>
          </div>

          <div className="space-y-6">
            <div>
              <p className="text-accent font-medium mb-2">{project.category}</p>
              <h1 className="font-display text-3xl sm:text-4xl font-bold">
                {project.title}
              </h1>
            </div>

            <p className="text-foreground/70 leading-relaxed">
              {project.description}
            </p>

            <div className="space-y-4 pt-6 border-t border-border">
              <div className="flex items-center gap-3">
                <Calendar className="h-5 w-5 text-accent" />
                <div>
                  <p className="text-sm text-foreground/50">Year</p>
                  <p className="font-medium">{project.year}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <User className="h-5 w-5 text-accent" />
                <div>
                  <p className="text-sm text-foreground/50">Client</p>
                  <p className="font-medium">{project.client}</p>
                </div>
              </div>
            </div>

            <Link href="/contact">
              <Button className="w-full mt-6">Inquire About Similar Project</Button>
            </Link>
          </div>
        </div>
      </Container>
    </article>
  );
}