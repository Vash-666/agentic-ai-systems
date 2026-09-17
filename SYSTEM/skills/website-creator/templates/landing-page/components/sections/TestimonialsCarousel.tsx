"use client";

import { Card } from "@/components/ui/Card";
import { Star, ChevronLeft, ChevronRight, Quote } from "lucide-react";
import { useState } from "react";

interface Testimonial {
  id: number;
  name: string;
  role: string;
  company: string;
  image: string;
  quote: string;
  rating: number;
}

function TestimonialsCarousel() {
  const testimonials: Testimonial[] = [
    {
      id: 1,
      name: "Sarah Chen",
      role: "VP of Engineering",
      company: "TechCorp",
      image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop&crop=face",
      quote: "We shipped 3x faster after switching to TaskFlow. The automation features alone saved us 20 hours per week.",
      rating: 5,
    },
    {
      id: 2,
      name: "Marcus Johnson",
      role: "Product Manager",
      company: "StartupXYZ",
      image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
      quote: "Finally, a project tool that doesn't require a PhD to use. My team adopted it in one day.",
      rating: 5,
    },
    {
      id: 3,
      name: "Emily Rodriguez",
      role: "CEO",
      company: "DesignStudio",
      image: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
      quote: "TaskFlow paid for itself in the first month. Our project delivery rate went from 60% to 95%.",
      rating: 5,
    },
    {
      id: 4,
      name: "David Kim",
      role: "Engineering Lead",
      company: "CloudScale",
      image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face",
      quote: "The timeline view is a game-changer. I can spot bottlenecks before they become problems.",
      rating: 5,
    },
    {
      id: 5,
      name: "Lisa Thompson",
      role: "Operations Director",
      company: "GrowthLabs",
      image: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face",
      quote: "We tried Asana, Monday, and Jira. TaskFlow is the only one our entire team actually enjoys using.",
      rating: 5,
    },
  ];

  const [currentIndex, setCurrentIndex] = useState(0);

  const nextSlide = () => {
    setCurrentIndex((prev) => (prev + 1) % testimonials.length);
  };

  const prevSlide = () => {
    setCurrentIndex((prev) => (prev - 1 + testimonials.length) % testimonials.length);
  };

  const visibleTestimonials = [
    testimonials[currentIndex],
    testimonials[(currentIndex + 1) % testimonials.length],
    testimonials[(currentIndex + 2) % testimonials.length],
  ];

  return (
    <section id="testimonials" className="py-20 bg-white">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-foreground mb-6">
            Loved by Teams Everywhere
          </h2>
          <p className="text-lg text-gray-600">
            Don't just take our word for it. Here's what our customers have to say.
          </p>
        </div>

        <div className="relative">
          {/* Desktop: Show 3 cards */}
          <div className="hidden md:grid md:grid-cols-3 gap-8">
            {visibleTestimonials.map((testimonial, index) => (
              <Card key={`${testimonial.id}-${index}`} padding="lg" className="h-full">
                <div className="flex flex-col h-full">
                  <Quote className="h-8 w-8 text-primary/20 mb-4" />
                  
                  {/* Stars */}
                  <div className="flex gap-1 mb-4">
                    {Array.from({ length: testimonial.rating }).map((_, i) => (
                      <Star key={i} className="h-5 w-5 text-yellow-400 fill-yellow-400" />
                    ))}
                  </div>

                  <p className="text-gray-700 leading-relaxed mb-6 flex-grow">
                    "{testimonial.quote}"
                  </p>

                  <div className="flex items-center gap-4 pt-4 border-t border-gray-100">
                    <img
                      src={testimonial.image}
                      alt={testimonial.name}
                      className="h-12 w-12 rounded-full object-cover"
                    />
                    <div>
                      <p className="font-semibold text-foreground">
                        {testimonial.name}
                      </p>
                      <p className="text-sm text-gray-500">
                        {testimonial.role}, {testimonial.company}
                      </p>
                    </div>
                  </div>
                </div>
              </Card>
            ))}
          </div>

          {/* Mobile: Show 1 card */}
          <div className="md:hidden">
            <Card padding="lg">
              <div className="flex flex-col">
                <Quote className="h-8 w-8 text-primary/20 mb-4" />
                
                <div className="flex gap-1 mb-4">
                  {Array.from({ length: testimonials[currentIndex].rating }).map((_, i) => (
                    <Star key={i} className="h-5 w-5 text-yellow-400 fill-yellow-400" />
                  ))}
                </div>

                <p className="text-gray-700 leading-relaxed mb-6">
                  "{testimonials[currentIndex].quote}"
                </p>

                <div className="flex items-center gap-4 pt-4 border-t border-gray-100">
                  <img
                    src={testimonials[currentIndex].image}
                    alt={testimonials[currentIndex].name}
                    className="h-12 w-12 rounded-full object-cover"
                  />
                  <div>
                    <p className="font-semibold text-foreground">
                      {testimonials[currentIndex].name}
                    </p>
                    <p className="text-sm text-gray-500">
                      {testimonials[currentIndex].role},{" "}
                      {testimonials[currentIndex].company}
                    </p>
                  </div>
                </div>
              </div>
            </Card>
          </div>

          {/* Navigation */}
          <div className="flex justify-center gap-4 mt-8">
            <button
              onClick={prevSlide}
              className="p-2 rounded-full border border-gray-200 hover:bg-gray-50 transition-colors"
            >
              <ChevronLeft className="h-5 w-5 text-gray-600" />
            </button>
            <div className="flex items-center gap-2">
              {testimonials.map((_, index) => (
                <button
                  key={index}
                  onClick={() => setCurrentIndex(index)}
                  className={`h-2 rounded-full transition-all ${
                    index === currentIndex
                      ? "w-8 bg-primary"
                      : "w-2 bg-gray-300 hover:bg-gray-400"
                  }`}
                />
              ))}
            </div>
            <button
              onClick={nextSlide}
              className="p-2 rounded-full border border-gray-200 hover:bg-gray-50 transition-colors"
            >
              <ChevronRight className="h-5 w-5 text-gray-600" />
            </button>
          </div>
        </div>
      </div>
    </section>
  );
}

export { TestimonialsCarousel };
