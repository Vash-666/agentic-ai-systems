import { siteConfig } from "@/config/site";
import { Star } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";

export function TestimonialsSection() {
  return (
    <section className="py-16 md:py-20">
      <div className="container mx-auto px-4">
        <h2 className="mb-10 text-center text-3xl font-bold">
          What Our Customers Say
        </h2>

        <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
          {siteConfig.testimonials.map((testimonial, i) => (
            <Card key={i} className="border-0 bg-muted/30">
              <CardContent className="p-6">
                {/* Stars */}
                <div className="mb-4 flex gap-1">
                  {Array.from({ length: 5 }).map((_, j) => (
                    <Star
                      key={j}
                      className="h-4 w-4 fill-yellow-400 text-yellow-400"
                    />
                  ))}
                </div>

                {/* Quote */}
                <blockquote className="mb-4 text-sm italic leading-relaxed text-muted-foreground">
                  &ldquo;{testimonial.quote}&rdquo;
                </blockquote>

                {/* Attribution */}
                <div className="text-sm">
                  <span className="font-semibold text-foreground">
                    {testimonial.name}
                  </span>
                  <span className="text-muted-foreground">
                    , {testimonial.location}
                  </span>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
}
