import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { CTABanner } from "@/components/sections/CTABanner";
import { CheckCircle2 } from "lucide-react";
import business from "@/content/data/business.json";

export const metadata = {
  title: "About Us",
  description: "Learn about Sterling & Associates' legacy of legal excellence spanning over 25 years.",
};

const values = [
  {
    title: "Integrity",
    description: "We uphold the highest ethical standards in every aspect of our practice.",
  },
  {
    title: "Excellence",
    description: "We strive for exceptional results in every matter we handle.",
  },
  {
    title: "Client Focus",
    description: "Our clients' success is the measure of our own.",
  },
  {
    title: "Innovation",
    description: "We embrace creative solutions to complex legal challenges.",
  },
];

export default function AboutPage() {
  return (
    <>
      <Header />
      <main className="flex-1">
        {/* Hero Section */}
        <section className="bg-navy-900 py-20">
          <Container>
            <div className="max-w-3xl mx-auto text-center">
              <h1 className="font-heading text-4xl md:text-5xl font-bold text-white mb-6">
                About Our Firm
              </h1>
              <p className="text-lg text-cream-200">
                A legacy of excellence, integrity, and client-focused legal services 
                since {business.founded}.
              </p>
            </div>
          </Container>
        </section>

        {/* Our Story */}
        <section className="py-20 bg-white">
          <Container>
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
              <div>
                <p className="text-gold-600 font-medium mb-2 uppercase tracking-wide text-sm">
                  Our Story
                </p>
                <h2 className="font-heading text-3xl font-bold text-navy-900 mb-6">
                  Decades of Dedication to Our Clients
                </h2>
                <div className="space-y-4 text-charcoal-600 leading-relaxed">
                  <p>
                    Founded in {business.founded} by Richard Sterling, our firm began 
                    with a simple mission: to provide sophisticated legal counsel with 
                    a personal touch. What started as a small practice has grown into 
                    a respected firm serving clients nationwide.
                  </p>
                  <p>
                    Over the past {business.yearsInBusiness} years, we have built a 
                    reputation for excellence in corporate law, litigation, estate 
                    planning, and more. Our team of experienced attorneys brings 
                    diverse expertise and a shared commitment to achieving the best 
                    possible outcomes for our clients.
                  </p>
                  <p>
                    Today, {business.name} continues to uphold the values that have 
                    guided us from the beginning: integrity, excellence, and an 
                    unwavering dedication to our clients success.
                  </p>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-6">
                <div className="bg-navy-50 p-8 rounded-lg text-center">
                  <div className="font-heading text-4xl font-bold text-navy-900 mb-2">
                    {business.yearsInBusiness}+
                  </div>
                  <div className="text-charcoal-600">Years of Excellence</div>
                </div>
                <div className="bg-gold-50 p-8 rounded-lg text-center">
                  <div className="font-heading text-4xl font-bold text-navy-900 mb-2">
                    500+
                  </div>
                  <div className="text-charcoal-600">Clients Served</div>
                </div>
                <div className="bg-sage-50 p-8 rounded-lg text-center">
                  <div className="font-heading text-4xl font-bold text-navy-900 mb-2">
                    6
                  </div>
                  <div className="text-charcoal-600">Practice Areas</div>
                </div>
                <div className="bg-navy-100 p-8 rounded-lg text-center">
                  <div className="font-heading text-4xl font-bold text-navy-900 mb-2">
                    15+
                  </div>
                  <div className="text-charcoal-600">Attorneys</div>
                </div>
              </div>
            </div>
          </Container>
        </section>

        {/* Our Values */}
        <section className="py-20 bg-cream-50">
          <Container>
            <div className="text-center max-w-2xl mx-auto mb-12">
              <p className="text-gold-600 font-medium mb-2 uppercase tracking-wide text-sm">
                Our Values
              </p>
              <h2 className="font-heading text-3xl font-bold text-navy-900 mb-4">
                Principles That Guide Us
              </h2>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {values.map((value, index) => (
                <div key={index} className="bg-white p-6 rounded-lg shadow-sm">
                  <h3 className="font-heading text-xl font-semibold text-navy-900 mb-3">
                    {value.title}
                  </h3>
                  <p className="text-charcoal-600 text-sm">{value.description}</p>
                </div>
              ))}
            </div>
          </Container>
        </section>

        {/* Credentials */}
        <section className="py-20 bg-white">
          <Container>
            <div className="text-center max-w-2xl mx-auto mb-12">
              <p className="text-gold-600 font-medium mb-2 uppercase tracking-wide text-sm">
                Recognition
              </p>
              <h2 className="font-heading text-3xl font-bold text-navy-900 mb-4">
                Awards & Credentials
              </h2>
            </div>
            <div className="flex flex-wrap justify-center gap-4">
              {business.credentials.map((credential, index) => (
                <div
                  key={index}
                  className="flex items-center gap-2 bg-navy-50 px-6 py-3 rounded-full"
                >
                  <CheckCircle2 className="h-5 w-5 text-sage-500" />
                  <span className="text-navy-900 font-medium">{credential}</span>
                </div>
              ))}
            </div>
          </Container>
        </section>

        <CTABanner />
      </main>
      <Footer />
    </>
  );
}
