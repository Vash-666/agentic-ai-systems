import Link from "next/link";
import { ArrowRight, CheckCircle2 } from "lucide-react";
import { Container } from "@/components/layout/Container";
import { Button } from "@/components/ui/Button";
import business from "@/content/data/business.json";

const highlights = [
  "Over ${business.yearsInBusiness} years of legal excellence",
  "Award-winning attorneys recognized nationally",
  "Client-centered approach to every matter",
  "Sophisticated solutions for complex challenges",
];

function AboutPreview() {
  return (
    <section className="py-20 bg-white">
      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          <div>
            <p className="text-gold-600 font-medium mb-2 uppercase tracking-wide text-sm">
              About Our Firm
            </p>
            <h2 className="font-heading text-3xl md:text-4xl font-bold text-navy-900 mb-6">
              A Legacy of Excellence in Legal Services
            </h2>
            <p className="text-charcoal-600 mb-6 leading-relaxed">
              Founded in {business.founded}, {business.name} has built a reputation 
              for delivering exceptional legal counsel to businesses and individuals 
              alike. Our team of experienced attorneys combines deep legal expertise 
              with a practical understanding of our clients needs.
            </p>
            <p className="text-charcoal-600 mb-8 leading-relaxed">
              We believe that effective legal representation requires more than just 
              technical knowledge. It demands strategic thinking, clear communication, 
              and an unwavering commitment to our clients success.
            </p>

            <ul className="space-y-3 mb-8">
              {highlights.map((highlight, index) => (
                <li key={index} className="flex items-center gap-3">
                  <CheckCircle2 className="h-5 w-5 text-sage-500 flex-shrink-0" />
                  <span className="text-charcoal-700">{highlight}</span>
                </li>
              ))}
            </ul>

            <Button asChild>
              <Link href="/about" className="gap-2">
                Learn More About Us
                <ArrowRight className="h-4 w-4" />
              </Link>
            </Button>
          </div>

          <div className="relative">
            <div className="aspect-[4/3] bg-navy-100 rounded-lg overflow-hidden">
              <div className="w-full h-full bg-gradient-to-br from-navy-200 to-navy-300 flex items-center justify-center">
                <div className="text-center p-8">
                  <div className="font-heading text-6xl font-bold text-navy-800 mb-2">
                    {business.yearsInBusiness}+
                  </div>
                  <div className="text-navy-700 font-medium">Years of Excellence</div>
                </div>
              </div>
            </div>
            <div className="absolute -bottom-6 -left-6 bg-gold-500 text-navy-900 p-6 rounded-lg shadow-lg">
              <div className="font-heading text-3xl font-bold">500+</div>
              <div className="text-sm font-medium">Clients Served</div>
            </div>
          </div>
        </div>
      </Container>
    </section>
  );
}

export { AboutPreview };
