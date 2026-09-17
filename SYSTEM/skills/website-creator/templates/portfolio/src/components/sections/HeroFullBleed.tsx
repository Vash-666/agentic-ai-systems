import Link from "next/link";
import { ArrowDown } from "lucide-react";
import { Button } from "@/components/ui/Button";

interface HeroFullBleedProps {
  title: string;
  subtitle: string;
  backgroundImage?: string;
  ctaPrimary?: { label: string; href: string };
  ctaSecondary?: { label: string; href: string };
}

export function HeroFullBleed({
  title,
  subtitle,
  backgroundImage = "https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=1920&q=80",
  ctaPrimary = { label: "View Portfolio", href: "/portfolio" },
  ctaSecondary = { label: "Get in Touch", href: "/contact" },
}: HeroFullBleedProps) {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Background Image */}
      <div className="absolute inset-0 z-0">
        <img
          src={backgroundImage}
          alt=""
          className="h-full w-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-b from-background/60 via-background/40 to-background" />
      </div>

      {/* Content */}
      <div className="relative z-10 container mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h1 className="font-display text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-bold tracking-tight mb-6">
          {title}
        </h1>
        <p className="text-lg sm:text-xl md:text-2xl text-foreground/80 max-w-2xl mx-auto mb-8">
          {subtitle}
        </p>
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Link href={ctaPrimary.href}>
            <Button size="lg" className="rounded-full px-8">
              {ctaPrimary.label}
            </Button>
          </Link>
          <Link href={ctaSecondary.href}>
            <Button variant="outline" size="lg" className="rounded-full px-8 border-foreground/20">
              {ctaSecondary.label}
            </Button>
          </Link>
        </div>
      </div>

      {/* Scroll indicator */}
      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 z-10 animate-bounce">
        <ArrowDown className="h-6 w-6 text-foreground/50" />
      </div>
    </section>
  );
}