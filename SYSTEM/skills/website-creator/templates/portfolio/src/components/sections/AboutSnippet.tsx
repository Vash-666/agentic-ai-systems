import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { Container } from "@/components/layout/Container";

interface AboutSnippetProps {
  name: string;
  title: string;
  bio: string;
  image: string;
  stats: { label: string; value: string }[];
}

export function AboutSnippet({
  name,
  title,
  bio,
  image,
  stats,
}: AboutSnippetProps) {
  return (
    <section className="py-24 bg-card">
      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          <div className="relative">
            <div className="aspect-[4/5] rounded-lg overflow-hidden">
              <img
                src={image}
                alt={name}
                className="h-full w-full object-cover"
              />
            </div>
            <div className="absolute -bottom-6 -right-6 bg-accent text-background p-6 rounded-lg hidden sm:block">
              <p className="font-display text-4xl font-bold">12+</p>
              <p className="text-sm font-medium">Years Experience</p>
            </div>
          </div>

          <div className="space-y-6">
            <div>
              <p className="text-accent font-medium mb-2">About Me</p>
              <h2 className="font-display text-3xl sm:text-4xl font-bold mb-4">
                {name}
              </h2>
              <p className="text-xl text-foreground/70">{title}</p>
            </div>

            <p className="text-foreground/60 leading-relaxed">{bio}</p>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-6 pt-6">
              {stats.map((stat) => (
                <div key={stat.label}>
                  <p className="font-display text-2xl sm:text-3xl font-bold text-accent">
                    {stat.value}
                  </p>
                  <p className="text-sm text-foreground/60">{stat.label}</p>
                </div>
              ))}
            </div>

            <Link
              href="/about"
              className="inline-flex items-center gap-2 text-accent hover:underline font-medium pt-4"
            >
              Learn More About Me
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
        </div>
      </Container>
    </section>
  );
}