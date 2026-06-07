import Link from "next/link";
import { Phone, Mail, MapPin } from "lucide-react";
import { Container } from "./Container";
import { Separator } from "@/components/ui/Separator";
import business from "@/content/data/business.json";

function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="bg-navy-900 text-cream-100">
      <Container>
        <div className="py-12 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {/* Firm Info */}
          <div className="space-y-4">
            <h3 className="font-heading text-xl font-bold text-white">
              {business.name}
            </h3>
            <p className="text-sm text-cream-200 leading-relaxed">
              {business.description}
            </p>
            <div className="flex gap-4">
              <a
                href={business.social.linkedin}
                target="_blank"
                rel="noopener noreferrer"
                className="text-cream-300 hover:text-gold-400 transition-colors"
              >
                <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
                </svg>
              </a>
              <a
                href={business.social.twitter}
                target="_blank"
                rel="noopener noreferrer"
                className="text-cream-300 hover:text-gold-400 transition-colors"
              >
                <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                </svg>
              </a>
              <a
                href={business.social.facebook}
                target="_blank"
                rel="noopener noreferrer"
                className="text-cream-300 hover:text-gold-400 transition-colors"
              >
                <svg className="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                </svg>
              </a>
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="font-heading text-sm font-semibold uppercase tracking-wider text-gold-400 mb-4">
              Quick Links
            </h4>
            <ul className="space-y-2">
              {[
                { label: "Home", href: "/" },
                { label: "About Us", href: "/about" },
                { label: "Our Services", href: "/services" },
                { label: "Attorneys", href: "/expertise" },
                { label: "Resources", href: "/resources" },
                { label: "Contact", href: "/contact" },
              ].map((link) => (
                <li key={link.href}>
                  <Link
                    href={link.href}
                    className="text-sm text-cream-200 hover:text-white transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Practice Areas */}
          <div>
            <h4 className="font-heading text-sm font-semibold uppercase tracking-wider text-gold-400 mb-4">
              Practice Areas
            </h4>
            <ul className="space-y-2">
              {[
                "Corporate Law",
                "Commercial Litigation",
                "Estate Planning",
                "Real Estate",
                "Employment Law",
                "Intellectual Property",
              ].map((area) => (
                <li key={area}>
                  <Link
                    href="/services"
                    className="text-sm text-cream-200 hover:text-white transition-colors"
                  >
                    {area}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Contact Info */}
          <div>
            <h4 className="font-heading text-sm font-semibold uppercase tracking-wider text-gold-400 mb-4">
              Contact Us
            </h4>
            <ul className="space-y-3">
              <li>
                <a
                  href={`tel:${business.phone}`}
                  className="flex items-center gap-2 text-sm text-cream-200 hover:text-white transition-colors"
                >
                  <Phone className="h-4 w-4 text-gold-400" />
                  {business.phone}
                </a>
              </li>
              <li>
                <a
                  href={`mailto:${business.email}`}
                  className="flex items-center gap-2 text-sm text-cream-200 hover:text-white transition-colors"
                >
                  <Mail className="h-4 w-4 text-gold-400" />
                  {business.email}
                </a>
              </li>
              <li className="flex items-start gap-2 text-sm text-cream-200">
                <MapPin className="h-4 w-4 text-gold-400 mt-0.5" />
                <span>
                  {business.address.street}
                  <br />
                  {business.address.city}, {business.address.state} {business.address.zip}
                </span>
              </li>
            </ul>
          </div>
        </div>

        <Separator className="bg-navy-800" />

        <div className="py-6 flex flex-col md:flex-row items-center justify-between gap-4">
          <p className="text-sm text-cream-300">
            &copy; {currentYear} {business.name}. All rights reserved.
          </p>
          <p className="text-xs text-cream-400">
            Attorney Advertising. Prior results do not guarantee a similar outcome.
          </p>
        </div>
      </Container>
    </footer>
  );
}

export { Footer };
