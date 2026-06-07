import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { CTABanner } from "@/components/sections/CTABanner";
import { Accordion } from "@/components/ui/Accordion";
import { HelpCircle, MessageCircle, Phone } from "lucide-react";
import faqData from "@/content/data/faq.json";
import business from "@/content/data/business.json";

export const metadata = {
  title: "Frequently Asked Questions",
  description: "Find answers to common questions about Sterling & Associates and our legal services.",
};

export default function FAQPage() {
  const { faqs } = faqData;

  return (
    <>
      <Header />
      <main className="flex-1">
        {/* Hero Section */}
        <section className="bg-navy-900 py-20">
          <Container>
            <div className="max-w-3xl mx-auto text-center">
              <h1 className="font-heading text-4xl md:text-5xl font-bold text-white mb-6">
                Frequently Asked Questions
              </h1>
              <p className="text-lg text-cream-200">
                Find answers to common questions about our firm and legal services. 
                Don't see what you're looking for? Contact us directly.
              </p>
            </div>
          </Container>
        </section>

        {/* FAQ Section */}
        <section className="py-20 bg-cream-50">
          <Container size="small">
            <Accordion items={faqs} />
          </Container>
        </section>

        {/* Still Have Questions */}
        <section className="py-16 bg-white">
          <Container>
            <div className="text-center max-w-2xl mx-auto">
              <HelpCircle className="h-12 w-12 text-gold-500 mx-auto mb-4" />
              <h2 className="font-heading text-2xl font-bold text-navy-900 mb-4">
                Still Have Questions?
              </h2>
              <p className="text-charcoal-600 mb-8">
                Our team is here to help. Reach out to us and we'll get back to you 
                as soon as possible.
              </p>
              <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
                <a
                  href="/contact"
                  className="inline-flex items-center gap-2 px-6 py-3 bg-navy-900 text-white font-semibold rounded-lg hover:bg-navy-800 transition-colors"
                >
                  <MessageCircle className="h-5 w-5" />
                  Contact Us
                </a>
                <a
                  href={`tel:${business.phone}`}
                  className="inline-flex items-center gap-2 px-6 py-3 border-2 border-navy-900 text-navy-900 font-semibold rounded-lg hover:bg-navy-50 transition-colors"
                >
                  <Phone className="h-5 w-5" />
                  {business.phone}
                </a>
              </div>
            </div>
          </Container>
        </section>

        {/* Quick Links */}
        <section className="py-16 bg-navy-50">
          <Container>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              <div className="bg-white p-6 rounded-lg">
                <h3 className="font-heading text-lg font-semibold text-navy-900 mb-3">
                  Schedule a Consultation
                </h3>
                <p className="text-charcoal-600 text-sm mb-4">
                  Ready to discuss your legal needs? Schedule a consultation with 
                  one of our experienced attorneys.
                </p>
                <a
                  href="/contact"
                  className="text-navy-700 font-medium hover:text-gold-600 transition-colors"
                >
                  Get Started →
                </a>
              </div>
              <div className="bg-white p-6 rounded-lg">
                <h3 className="font-heading text-lg font-semibold text-navy-900 mb-3">
                  Explore Our Services
                </h3>
                <p className="text-charcoal-600 text-sm mb-4">
                  Learn more about our practice areas and how we can help with 
                  your specific legal needs.
                </p>
                <a
                  href="/services"
                  className="text-navy-700 font-medium hover:text-gold-600 transition-colors"
                >
                  View Services →
                </a>
              </div>
              <div className="bg-white p-6 rounded-lg">
                <h3 className="font-heading text-lg font-semibold text-navy-900 mb-3">
                  Meet Our Team
                </h3>
                <p className="text-charcoal-600 text-sm mb-4">
                  Get to know our team of experienced attorneys and their areas 
                  of expertise.
                </p>
                <a
                  href="/expertise"
                  className="text-navy-700 font-medium hover:text-gold-600 transition-colors"
                >
                  Our Attorneys →
                </a>
              </div>
            </div>
          </Container>
        </section>

        <CTABanner />
      </main>
      <Footer />
    </>
  );
}
