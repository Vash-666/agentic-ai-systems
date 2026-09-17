import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { Container } from "@/components/layout/Container";
import { ServiceCard } from "@/components/features/ServiceCard";
import { Button } from "@/components/ui/Button";
import servicesData from "@/content/data/services.json";

function ServicesGrid() {
  const { services } = servicesData;

  return (
    <section className="py-20 bg-cream-50">
      <Container>
        <div className="text-center max-w-2xl mx-auto mb-12">
          <h2 className="font-heading text-3xl md:text-4xl font-bold text-navy-900 mb-4">
            Our Practice Areas
          </h2>
          <p className="text-charcoal-600">
            Comprehensive legal services tailored to meet the unique needs of 
            businesses and individuals.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {services.map((service) => (
            <ServiceCard key={service.id} service={service} />
          ))}
        </div>

        <div className="mt-12 text-center">
          <Button variant="outline" size="lg" asChild>
            <Link href="/services" className="gap-2">
              View All Services
              <ArrowRight className="h-4 w-4" />
            </Link>
          </Button>
        </div>
      </Container>
    </section>
  );
}

export { ServicesGrid };
