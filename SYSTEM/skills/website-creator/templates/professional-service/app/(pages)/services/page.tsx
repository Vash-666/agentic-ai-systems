import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { CTABanner } from "@/components/sections/CTABanner";
import { ServiceCard } from "@/components/features/ServiceCard";
import { Building2, Scale, Shield, Home, Users, Lightbulb, CheckCircle2 } from "lucide-react";
import servicesData from "@/content/data/services.json";

export const metadata = {
  title: "Our Services",
  description: "Comprehensive legal services including corporate law, litigation, estate planning, real estate, employment law, and intellectual property.",
};

const iconMap: Record<string, React.ComponentType<{ className?: string }>> = {
  Building2,
  Scale,
  Shield,
  Home,
  Users,
  Lightbulb,
};

export default function ServicesPage() {
  const { services } = servicesData;

  return (
    <>
      <Header />
      <main className="flex-1">
        {/* Hero Section */}
        <section className="bg-navy-900 py-20">
          <Container>
            <div className="max-w-3xl mx-auto text-center">
              <h1 className="font-heading text-4xl md:text-5xl font-bold text-white mb-6">
                Our Practice Areas
              </h1>
              <p className="text-lg text-cream-200">
                Comprehensive legal services tailored to meet the unique needs of 
                businesses and individuals.
              </p>
            </div>
          </Container>
        </section>

        {/* Services Grid */}
        <section className="py-20 bg-cream-50">
          <Container>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {services.map((service) => (
                <ServiceCard key={service.id} service={service} />
              ))}
            </div>
          </Container>
        </section>

        {/* Detailed Services */}
        <section className="py-20 bg-white">
          <Container size="small">
            <div className="space-y-20">
              {services.map((service, index) => {
                const Icon = iconMap[service.icon] || Building2;
                return (
                  <div key={service.id} id={service.id} className="scroll-mt-24">
                    <div className="flex items-start gap-4 mb-6">
                      <div className="p-3 bg-navy-50 rounded-lg">
                        <Icon className="h-8 w-8 text-navy-700" />
                      </div>
                      <div>
                        <h2 className="font-heading text-2xl font-bold text-navy-900">
                          {service.title}
                        </h2>
                      </div>
                    </div>
                    <p className="text-charcoal-600 leading-relaxed mb-6">
                      {service.fullDescription}
                    </p>
                    <h3 className="font-heading text-lg font-semibold text-navy-900 mb-4">
                      Key Services
                    </h3>
                    <ul className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      {service.features.map((feature, featureIndex) => (
                        <li
                          key={featureIndex}
                          className="flex items-start gap-3"
                        >
                          <CheckCircle2 className="h-5 w-5 text-sage-500 flex-shrink-0 mt-0.5" />
                          <span className="text-charcoal-700">{feature}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                );
              })}
            </div>
          </Container>
        </section>

        <CTABanner />
      </main>
      <Footer />
    </>
  );
}
