import { siteConfig } from "@/config/site";
import { Card, CardContent } from "@/components/ui/card";
import {
  Wrench,
  Droplets,
  Thermometer,
  Bath,
  ArrowRight,
} from "lucide-react";
import Link from "next/link";
import type { LucideIcon } from "lucide-react";

const iconMap: Record<string, LucideIcon> = {
  "Emergency Repairs": Wrench,
  "Drain & Sewer Cleaning": Droplets,
  "Water Heater Service": Thermometer,
  "Fixture Installation": Bath,
  "Pipe Repair & Repiping": Wrench,
  "Commercial Plumbing": Wrench,
};

function getIcon(name: string): LucideIcon {
  return iconMap[name] || Wrench;
}

export function ServicesPreview() {
  const previewServices = siteConfig.services.slice(0, 4);

  return (
    <section className="py-16 md:py-20">
      <div className="container mx-auto px-4">
        <div className="mb-10 text-center">
          <h2 className="mb-3 text-3xl font-bold">Our Services</h2>
          <p className="text-lg text-muted-foreground">
            Professional {siteConfig.serviceType.toLowerCase()} Solutions for Your
            Home or Business
          </p>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {previewServices.map((service) => {
            const Icon = getIcon(service.name);
            return (
              <Card
                key={service.name}
                className="border-0 bg-muted/30 transition-all hover:shadow-md"
              >
                <CardContent className="flex flex-col items-center p-6 text-center">
                  <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
                    <Icon className="h-6 w-6 text-primary" />
                  </div>
                  <h3 className="mb-2 text-lg font-semibold">{service.name}</h3>
                  <p className="mb-4 text-sm text-muted-foreground">
                    {service.shortDescription}
                  </p>
                  <Link
                    href="/services"
                    className="inline-flex items-center gap-1 text-sm font-medium text-primary hover:underline"
                  >
                    Learn More <ArrowRight className="h-3 w-3" />
                  </Link>
                </CardContent>
              </Card>
            );
          })}
        </div>
      </div>
    </section>
  );
}
