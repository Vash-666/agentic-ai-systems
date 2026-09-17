import { Container } from "@/components/layout/Container";
import { Carousel, CarouselItem } from "@/components/ui/Carousel";
import { TestimonialCard } from "@/components/features/TestimonialCard";
import testimonialsData from "@/content/data/testimonials.json";

function TestimonialsSlider() {
  const { testimonials } = testimonialsData;

  return (
    <section className="py-20 bg-navy-50">
      <Container>
        <div className="text-center max-w-2xl mx-auto mb-12">
          <p className="text-gold-600 font-medium mb-2 uppercase tracking-wide text-sm">
            Client Testimonials
          </p>
          <h2 className="font-heading text-3xl md:text-4xl font-bold text-navy-900 mb-4">
            What Our Clients Say
          </h2>
          <p className="text-charcoal-600">
            We take pride in the lasting relationships we build with our clients 
            and the results we achieve on their behalf.
          </p>
        </div>

        <Carousel autoPlay interval={6000}>
          {testimonials.map((testimonial) => (
            <CarouselItem key={testimonial.id}>
              <div className="max-w-3xl mx-auto">
                <TestimonialCard testimonial={testimonial} variant="featured" />
              </div>
            </CarouselItem>
          ))}
        </Carousel>
      </Container>
    </section>
  );
}

export { TestimonialsSlider };
