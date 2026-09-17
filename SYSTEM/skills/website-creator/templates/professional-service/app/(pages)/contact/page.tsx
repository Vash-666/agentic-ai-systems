import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { ContactForm } from "@/components/sections/ContactForm";
import { ContactInfo } from "@/components/features/ContactInfo";
import { OfficeLocation } from "@/components/sections/OfficeLocation";
import { CTABanner } from "@/components/sections/CTABanner";

export const metadata = {
  title: "Contact Us",
  description: "Get in touch with Sterling & Associates. Schedule a consultation with our experienced legal team.",
};

export default function ContactPage() {
  return (
    <>
      <Header />
      <main className="flex-1">
        {/* Hero Section */}
        <section className="bg-navy-900 py-20">
          <Container>
            <div className="max-w-3xl mx-auto text-center">
              <h1 className="font-heading text-4xl md:text-5xl font-bold text-white mb-6">
                Contact Us
              </h1>
              <p className="text-lg text-cream-200">
                Schedule a consultation with our experienced legal team. 
                We are here to help with your legal needs.
              </p>
            </div>
          </Container>
        </section>

        {/* Contact Section */}
        <section className="py-20 bg-white">
          <Container>
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
              <div>
                <p className="text-gold-600 font-medium mb-2 uppercase tracking-wide text-sm">
                  Get In Touch
                </p>
                <h2 className="font-heading text-3xl font-bold text-navy-900 mb-6">
                  Schedule a Consultation
                </h2>
                <p className="text-charcoal-600 mb-8">
                  Fill out the form below and we will get back to you within 24 hours 
                  to schedule your initial consultation.
                </p>
                <ContactForm />
              </div>
              <div className="lg:pl-8">
                <ContactInfo />
              </div>
            </div>
          </Container>
        </section>

        <OfficeLocation />
        <CTABanner />
      </main>
      <Footer />
    </>
  );
}