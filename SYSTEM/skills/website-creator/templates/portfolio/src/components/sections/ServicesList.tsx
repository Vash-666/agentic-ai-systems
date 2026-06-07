import Link from "next/link";
import { Camera, Briefcase, Sparkles, Calendar, Mountain, GraduationCap, ArrowRight } from "lucide-react";
import { Container } from "@/components/layout/Container";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/Card";

const iconMap: Record<string, React.ComponentType<{ className?: string }>> = {
  Camera,
  Briefcase,
  Sparkles,
  Calendar,
  Mountain,
  GraduationCap,
};

interface Service {
  id: string;
  title: string;
  description: string;
  features: string[];
  price: string;
  icon: string;
}

interface ServicesListProps {
  services: Service[];
}

export function ServicesList({ services }: ServicesListProps) {
  return (
    <section className="py-24 bg-background">
      <Container>
        <div className="text-center mb-16">
          <h2 className="font-display text-3xl sm:text-4xl font-bold mb-4">
            Services
          </h2>
          <p className="text-foreground/60 max-w-2xl mx-auto">
            Professional photography services tailored to your unique needs and vision.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {services.map((service) => {
            const IconComponent = iconMap[service.icon] || Camera;
            return (
              <Card key={service.id} className="group hover:border-accent/50 transition-colors">
                <CardHeader>
                  <div className="w-12 h-12 rounded-lg bg-accent/10 flex items-center justify-center mb-4">
                    <IconComponent className="h-6 w-6 text-accent" />
                  </div>
                  <CardTitle>{service.title}</CardTitle>
                  <CardDescription>{service.description}</CardDescription>
                </CardHeader>
                <CardContent>
                  <ul className="space-y-2 mb-6">
                    {service.features.slice(0, 3).map((feature, index) => (
                      <li key={index} className="text-sm text-foreground/60 flex items-start gap-2">
                        <span className="text-accent mt-1">•</span>
                        {feature}
                      </li>
                    ))}
                  </ul>
                  <div className="flex items-center justify-between">
                    <span className="font-display text-lg font-semibold text-accent">
                      {service.price}
                    </span>
                    <Link
                      href="/contact"
                      className="inline-flex items-center gap-1 text-sm font-medium text-foreground/70 hover:text-accent transition-colors"
                    >
                      Inquire
                      <ArrowRight className="h-4 w-4" />
                    </Link>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      </Container>
    </section>
  );
}