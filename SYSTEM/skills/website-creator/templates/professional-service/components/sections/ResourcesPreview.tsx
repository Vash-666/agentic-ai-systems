import Link from "next/link";
import { ArrowRight, FileText } from "lucide-react";
import { Container } from "@/components/layout/Container";
import { ResourceCard } from "@/components/features/ResourceCard";
import { Button } from "@/components/ui/Button";
import resourcesData from "@/content/data/resources.json";

function ResourcesPreview() {
  const { resources } = resourcesData;
  const featuredResources = resources.slice(0, 3);

  return (
    <section className="py-20 bg-white">
      <Container>
        <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-12">
          <div className="max-w-2xl">
            <p className="text-gold-600 font-medium mb-2 uppercase tracking-wide text-sm">
              Knowledge Center
            </p>
            <h2 className="font-heading text-3xl md:text-4xl font-bold text-navy-900 mb-4">
              Insights & Resources
            </h2>
            <p className="text-charcoal-600">
              Stay informed with our latest articles, whitepapers, and legal updates 
              from our team of experienced attorneys.
            </p>
          </div>
          <Button variant="outline" asChild className="hidden md:inline-flex">
            <Link href="/resources" className="gap-2">
              View All Resources
              <ArrowRight className="h-4 w-4" />
            </Link>
          </Button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {featuredResources.map((resource) => (
            <ResourceCard key={resource.id} resource={resource} />
          ))}
        </div>

        <div className="mt-8 text-center md:hidden">
          <Button variant="outline" asChild>
            <Link href="/resources" className="gap-2">
              View All Resources
              <ArrowRight className="h-4 w-4" />
            </Link>
          </Button>
        </div>
      </Container>
    </section>
  );
}

export { ResourcesPreview };
