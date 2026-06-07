import { Award, Shield, Clock, Users } from "lucide-react";
import { Container } from "@/components/layout/Container";
import business from "@/content/data/business.json";

const badges = [
  {
    icon: Award,
    title: "Award-Winning",
    description: "Recognized by Best Lawyers and Super Lawyers",
  },
  {
    icon: Shield,
    title: "Trusted Counsel",
    description: "AV Preeminent Martindale-Hubbell Rating",
  },
  {
    icon: Clock,
    title: `${business.yearsInBusiness}+ Years`,
    description: "Serving clients with excellence since ${business.founded}",
  },
  {
    icon: Users,
    title: "Client-Focused",
    description: "Personalized attention for every matter",
  },
];

function TrustBadges() {
  return (
    <section className="py-12 bg-white border-b border-navy-100">
      <Container>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
          {badges.map((badge, index) => (
            <div key={index} className="flex items-start gap-3">
              <div className="p-2 bg-navy-50 rounded-lg">
                <badge.icon className="h-5 w-5 text-navy-700" />
              </div>
              <div>
                <h3 className="font-heading font-semibold text-navy-900 text-sm">
                  {badge.title}
                </h3>
                <p className="text-xs text-charcoal-500 mt-0.5">
                  {badge.description}
                </p>
              </div>
            </div>
          ))}
        </div>
      </Container>
    </section>
  );
}

export { TrustBadges };
