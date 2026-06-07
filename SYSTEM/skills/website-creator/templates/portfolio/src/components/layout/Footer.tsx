import Link from "next/link";
import { Mail, MapPin, Phone, Globe } from "lucide-react";

const footerLinks = {
  navigation: [
    { href: "/", label: "Home" },
    { href: "/portfolio", label: "Portfolio" },
    { href: "/about", label: "About" },
    { href: "/services", label: "Services" },
    { href: "/journal", label: "Journal" },
    { href: "/contact", label: "Contact" },
  ],
  services: [
    { href: "/services", label: "Portrait Photography" },
    { href: "/services", label: "Commercial & Brand" },
    { href: "/services", label: "Editorial & Fashion" },
    { href: "/services", label: "Event Coverage" },
    { href: "/services", label: "Fine Art Prints" },
  ],
};

export function Footer() {
  return (
    <footer className="border-t border-border bg-card">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="space-y-4">
            <h3 className="font-display text-xl font-bold">Marcus Chen</h3>
            <p className="text-sm text-foreground/60">
              Award-winning photographer capturing moments that transcend time. Based in San Francisco, available worldwide.
            </p>
            <div className="flex gap-4">
              <a
                href="https://instagram.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-foreground/60 hover:text-accent transition-colors"
                aria-label="Instagram"
              >
                <Globe className="h-5 w-5" />
              </a>
              <a
                href="https://twitter.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-foreground/60 hover:text-accent transition-colors"
                aria-label="Twitter"
              >
                <Globe className="h-5 w-5" />
              </a>
              <a
                href="https://linkedin.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-foreground/60 hover:text-accent transition-colors"
                aria-label="LinkedIn"
              >
                <Globe className="h-5 w-5" />
              </a>
            </div>
          </div>

          {/* Navigation */}
          <div>
            <h4 className="font-display text-sm font-semibold uppercase tracking-wider mb-4">
              Navigation
            </h4>
            <ul className="space-y-2">
              {footerLinks.navigation.map((link) => (
                <li key={link.href + link.label}>
                  <Link
                    href={link.href}
                    className="text-sm text-foreground/60 hover:text-accent transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Services */}
          <div>
            <h4 className="font-display text-sm font-semibold uppercase tracking-wider mb-4">
              Services
            </h4>
            <ul className="space-y-2">
              {footerLinks.services.map((link, index) => (
                <li key={index}>
                  <Link
                    href={link.href}
                    className="text-sm text-foreground/60 hover:text-accent transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h4 className="font-display text-sm font-semibold uppercase tracking-wider mb-4">
              Get in Touch
            </h4>
            <ul className="space-y-3">
              <li className="flex items-start gap-3 text-sm text-foreground/60">
                <MapPin className="h-4 w-4 mt-0.5 flex-shrink-0" />
                <span>San Francisco, CA</span>
              </li>
              <li className="flex items-center gap-3 text-sm text-foreground/60">
                <Mail className="h-4 w-4 flex-shrink-0" />
                <a href="mailto:hello@marcuschen.photo" className="hover:text-accent transition-colors">
                  hello@marcuschen.photo
                </a>
              </li>
              <li className="flex items-center gap-3 text-sm text-foreground/60">
                <Phone className="h-4 w-4 flex-shrink-0" />
                <a href="tel:+14155550187" className="hover:text-accent transition-colors">
                  +1 (415) 555-0187
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-12 pt-8 border-t border-border flex flex-col sm:flex-row justify-between items-center gap-4">
          <p className="text-sm text-foreground/40">
            © {new Date().getFullYear()} Marcus Chen Photography. All rights reserved.
          </p>
          <div className="flex gap-6">
            <Link href="/" className="text-sm text-foreground/40 hover:text-foreground/60 transition-colors">
              Privacy Policy
            </Link>
            <Link href="/" className="text-sm text-foreground/40 hover:text-foreground/60 transition-colors">
              Terms of Service
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
}