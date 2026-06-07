import Link from "next/link";
import { siteConfig } from "@/config/site";
import { Phone, Mail, MapPin, Clock } from "lucide-react";

export function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t bg-muted/40">
      <div className="container mx-auto px-4 py-12">
        <div className="grid grid-cols-1 gap-8 md:grid-cols-2 lg:grid-cols-4">
          {/* Business Info */}
          <div>
            <h3 className="mb-3 text-lg font-bold">{siteConfig.businessName}</h3>
            <p className="mb-4 text-sm text-muted-foreground">
              {siteConfig.tagline}
            </p>
            <div className="space-y-2 text-sm">
              <a
                href={`tel:${siteConfig.phone}`}
                className="flex items-center gap-2 text-muted-foreground hover:text-foreground"
              >
                <Phone className="h-4 w-4 shrink-0" />
                {siteConfig.phone}
              </a>
              <a
                href={`mailto:${siteConfig.email}`}
                className="flex items-center gap-2 text-muted-foreground hover:text-foreground"
              >
                <Mail className="h-4 w-4 shrink-0" />
                {siteConfig.email}
              </a>
              <span className="flex items-center gap-2 text-muted-foreground">
                <MapPin className="h-4 w-4 shrink-0" />
                {siteConfig.address.city}, {siteConfig.address.state}
              </span>
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="mb-3 text-sm font-semibold uppercase tracking-wider text-muted-foreground">
              Quick Links
            </h3>
            <nav className="space-y-2 text-sm">
              <Link
                href="/"
                className="block text-muted-foreground hover:text-foreground"
              >
                Home
              </Link>
              <Link
                href="/services"
                className="block text-muted-foreground hover:text-foreground"
              >
                Services
              </Link>
              <Link
                href="/about"
                className="block text-muted-foreground hover:text-foreground"
              >
                About Us
              </Link>
              <Link
                href="/contact"
                className="block text-muted-foreground hover:text-foreground"
              >
                Contact
              </Link>
            </nav>
          </div>

          {/* Services */}
          <div>
            <h3 className="mb-3 text-sm font-semibold uppercase tracking-wider text-muted-foreground">
              Services
            </h3>
            <nav className="space-y-2 text-sm">
              {siteConfig.services.slice(0, 4).map((service) => (
                <Link
                  key={service.name}
                  href="/services"
                  className="block text-muted-foreground hover:text-foreground"
                >
                  {service.name}
                </Link>
              ))}
              <Link
                href="/services"
                className="block font-medium text-primary hover:underline"
              >
                View All Services
              </Link>
            </nav>
          </div>

          {/* Service Area */}
          <div>
            <h3 className="mb-3 text-sm font-semibold uppercase tracking-wider text-muted-foreground">
              Service Area
            </h3>
            <p className="mb-2 text-sm text-muted-foreground">
              Serving {siteConfig.serviceArea}
            </p>
            <div className="flex flex-wrap gap-x-2 gap-y-1 text-sm text-muted-foreground">
              {siteConfig.serviceAreaList.slice(0, 5).map((city) => (
                <span key={city}>{city}</span>
              ))}
              {siteConfig.serviceAreaList.length > 5 && (
                <a
                  href="/contact"
                  className="font-medium text-primary hover:underline"
                >
                  +{siteConfig.serviceAreaList.length - 5} more
                </a>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Bottom bar */}
      <div className="border-t">
        <div className="container mx-auto flex flex-col items-center justify-between gap-2 px-4 py-4 text-center text-xs text-muted-foreground sm:flex-row sm:text-left">
          <p>
            &copy; {currentYear} {siteConfig.businessName}. All rights reserved.
          </p>
          <p>
            Licensed &amp; Insured | {siteConfig.licenseNumber}
          </p>
        </div>
      </div>
    </footer>
  );
}
