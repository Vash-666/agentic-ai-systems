import Link from "next/link";
import { ArrowRight, Building2, Scale, Shield, Home, Users, Lightbulb } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/Card";

const iconMap: Record<string, React.ComponentType<{ className?: string }>> = {
  Building2,
  Scale,
  Shield,
  Home,
  Users,
  Lightbulb,
};

interface Service {
  id: string;
  title: string;
  shortDescription: string;
  icon: string;
}

interface ServiceCardProps {
  service: Service;
}

function ServiceCard({ service }: ServiceCardProps) {
  const Icon = iconMap[service.icon] || Building2;

  return (
    <Card className="group h-full transition-all hover:shadow-lg hover:border-gold-200">
      <CardHeader>
        <div className="w-12 h-12 bg-navy-50 rounded-lg flex items-center justify-center mb-4 group-hover:bg-gold-100 transition-colors">
          <Icon className="h-6 w-6 text-navy-700 group-hover:text-gold-700" />
        </div>
        <CardTitle>{service.title}</CardTitle>
        <CardDescription>{service.shortDescription}</CardDescription>
      </CardHeader>
      <CardContent>
        <Link
          href={`/services#${service.id}`}
          className="inline-flex items-center gap-1 text-sm font-medium text-navy-700 hover:text-gold-600 transition-colors"
        >
          Learn More
          <ArrowRight className="h-4 w-4" />
        </Link>
      </CardContent>
    </Card>
  );
}

export { ServiceCard };
export type { Service };
