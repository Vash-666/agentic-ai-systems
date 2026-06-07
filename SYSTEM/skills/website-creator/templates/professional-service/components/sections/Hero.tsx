import Link from "next/link";
import { ArrowRight, Phone } from "lucide-react";
import { Container } from "@/components/layout/Container";
import { Button } from "@/components/ui/Button";
import business from "@/content/data/business.json";

function Hero() {
  return (
    <section className="relative bg-navy-900 py-20 md:py-28 lg:py-32 overflow-hidden">
      {/* Background pattern */}
      <div className="absolute inset-0 opacity-10">
        <div className="absolute inset-0" style={{
          backgroundImage: `radial-gradient(circle at 2px 2px, rgba(255,255,255,0.15) 1px, transparent 0)`,
          backgroundSize: '40px 40px'
        }} />
      </div>
      
      <Container className="relative">
        <div className="max-w-3xl mx-auto text-center">
          <p className="text-gold-400 font-medium mb-4 tracking-wide uppercase text-sm">
            {business.tagline}
          </p>
          <h1 className="font-heading text-4xl md:text-5xl lg:text-6xl font-bold text-white mb-6 leading-tight">
            Trusted Legal Counsel for Your Most Important Matters
          </h1>
          <p className="text-lg md:text-xl text-cream-200 mb-8 leading-relaxed max-w-2xl mx-auto">
            For over {business.yearsInBusiness} years, {business.name} has provided 
            sophisticated legal solutions with integrity, dedication, and excellence.
          </p>
          
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Button size="lg" asChild>
              <Link href="/contact" className="gap-2">
                Schedule a Consultation
                <ArrowRight className="h-4 w-4" />
              </Link>
            </Button>
            <Button variant="outline" size="lg" asChild className="border-cream-200 text-cream-100 hover:bg-navy-800 hover:text-white">
              <a href={`tel:${business.phone}`} className="gap-2">
                <Phone className="h-4 w-4" />
                {business.phone}
              </a>
            </Button>
          </div>

          {/* Trust badges */}
          <div className="mt-12 flex flex-wrap items-center justify-center gap-6 text-sm text-cream-300">
            <span className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-gold-400" />
              AV Preeminent Rated
            </span>
            <span className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-gold-400" />
              {business.yearsInBusiness}+ Years Experience
            </span>
            <span className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-gold-400" />
              Award-Winning Attorneys
            </span>
          </div>
        </div>
      </Container>
    </section>
  );
}

export { Hero };
