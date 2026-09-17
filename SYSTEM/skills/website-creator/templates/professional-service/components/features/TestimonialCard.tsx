import { Quote } from "lucide-react";
import { cn } from "@/lib/utils";
import { Card, CardContent } from "@/components/ui/Card";

interface Testimonial {
  id: number;
  quote: string;
  author: string;
  title: string;
  company: string;
  service: string;
}

interface TestimonialCardProps {
  testimonial: Testimonial;
  variant?: "default" | "featured";
}

function TestimonialCard({ testimonial, variant = "default" }: TestimonialCardProps) {
  const isFeatured = variant === "featured";

  return (
    <Card
      className={cn(
        "h-full",
        isFeatured && "bg-white border-navy-100 shadow-lg"
      )}
    >
      <CardContent className={cn("p-6", isFeatured && "p-8")}>
        <Quote
          className={cn(
            "text-gold-400 mb-4",
            isFeatured ? "h-10 w-10" : "h-8 w-8"
          )}
        />
        <blockquote
          className={cn(
            "text-charcoal-700 mb-6 leading-relaxed",
            isFeatured ? "text-lg" : "text-base"
          )}
        >
          "{testimonial.quote}"
        </blockquote>
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 bg-navy-100 rounded-full flex items-center justify-center">
            <span className="font-heading text-lg font-semibold text-navy-700">
              {testimonial.author.charAt(0)}
            </span>
          </div>
          <div>
            <div className="font-heading font-semibold text-navy-900">
              {testimonial.author}
            </div>
            <div className="text-sm text-charcoal-500">
              {testimonial.title}
              {testimonial.company && `, ${testimonial.company}`}
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

export { TestimonialCard };
export type { Testimonial };
