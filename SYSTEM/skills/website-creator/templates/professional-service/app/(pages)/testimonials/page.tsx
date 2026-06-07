import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { TestimonialCard } from "@/components/features/TestimonialCard";
import { CTABanner } from "@/components/sections/CTABanner";
import testimonialsData from "@/content/data/testimonials.json";

export const metadata = {
  title: "Client Testimonials",
  description: "Read what our clients say about working with Sterling & Associates.",
};

interface Testimonial {
  id: number;
  quote: string;
  author: string;
  title: string;
  company: string;
  service: string;
}

export default function TestimonialsPage() {
  const testimonials: Testimonial[] = testimonialsData.testimonials;

  return (
    <>
      <Header />
      <main className="flex-1">
        {/* Hero Section */}
        <section className="bg-navy-900 py-20">
          <Container>
            <div className="max-w-3xl mx-auto text-center">
              <h1 className="font-heading text-4xl md:text-5xl font-bold text-white mb-6">
                Client Testimonials
              </h1>
              <p className="text-lg text-cream-200">
                Hear what our clients have to say about their experience working with our firm.
              </p>
            </div>
          </Container>
        </section>

        {/* Stats Section */}
        <section className="py-16 bg-gold-500">
          <Container>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
              <div>
                <div className="font-heading text-4xl font-bold text-navy-900">500+</div>
                <div className="text-navy-800">Clients Served</div>
              </div>
              <div>
                <div className="font-heading text-4xl font-bold text-navy-900">95%</div>
                <div className="text-navy-800">Client Retention</div>
              </div>
              <div>
                <div className="font-heading text-4xl font-bold text-navy-900">27+</div>
                <div className="text-navy-800">Years of Service</div>
              </div>
              <div>
                <div className="font-heading text-4xl font-bold text-navy-900">4.9/5</div>
                <div className="text-navy-800">Average Rating</div>
              </div>
            </div>
          </Container>
        </section>

        {/* Testimonials Grid */}
        <section className="py-20 bg-cream-50">
          <Container>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              {testimonials.map((testimonial: Testimonial, index: number) => (
                <TestimonialCard key={index} testimonial={testimonial} />
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
