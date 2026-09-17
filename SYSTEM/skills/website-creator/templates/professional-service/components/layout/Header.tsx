"use client";

import * as React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, X, Phone } from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/Button";
import business from "@/content/data/business.json";

const navItems = [
  { label: "Home", href: "/" },
  { label: "About", href: "/about" },
  { label: "Services", href: "/services" },
  { label: "Expertise", href: "/expertise" },
  { label: "Testimonials", href: "/testimonials" },
  { label: "Resources", href: "/resources" },
  { label: "FAQ", href: "/faq" },
  { label: "Contact", href: "/contact" },
];

function Header() {
  const pathname = usePathname();
  const [mobileMenuOpen, setMobileMenuOpen] = React.useState(false);

  return (
    <header className="sticky top-0 z-50 w-full border-b border-navy-100 bg-cream-50/95 backdrop-blur supports-[backdrop-filter]:bg-cream-50/80">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-20 items-center justify-between">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2">
            <span className="font-heading text-2xl font-bold text-navy-900">
              {business.name}
            </span>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden lg:flex items-center gap-1">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "px-3 py-2 text-sm font-medium transition-colors rounded-md",
                  pathname === item.href
                    ? "text-navy-900 bg-navy-50"
                    : "text-charcoal-600 hover:text-navy-900 hover:bg-navy-50"
                )}
              >
                {item.label}
              </Link>
            ))}
          </nav>

          {/* CTA & Mobile Menu */}
          <div className="flex items-center gap-4">
            <a
              href={`tel:${business.phone}`}
              className="hidden md:flex items-center gap-2 text-sm font-semibold text-navy-900"
            >
              <Phone className="h-4 w-4" />
              {business.phone}
            </a>
            <Button asChild className="hidden sm:inline-flex">
              <Link href="/contact">Schedule Consultation</Link>
            </Button>

            {/* Mobile menu button */}
            <button
              className="lg:hidden p-2 text-navy-900"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            >
              {mobileMenuOpen ? (
                <X className="h-6 w-6" />
              ) : (
                <Menu className="h-6 w-6" />
              )}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Navigation */}
      {mobileMenuOpen && (
        <div className="lg:hidden border-t border-navy-100 bg-white">
          <div className="mx-auto max-w-7xl px-4 py-4">
            <nav className="flex flex-col gap-2">
              {navItems.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setMobileMenuOpen(false)}
                  className={cn(
                    "px-4 py-3 text-sm font-medium rounded-md transition-colors",
                    pathname === item.href
                      ? "text-navy-900 bg-navy-50"
                      : "text-charcoal-600 hover:text-navy-900 hover:bg-navy-50"
                  )}
                >
                  {item.label}
                </Link>
              ))}
              <div className="mt-4 pt-4 border-t border-navy-100">
                <a
                  href={`tel:${business.phone}`}
                  className="flex items-center gap-2 px-4 py-3 text-sm font-semibold text-navy-900"
                >
                  <Phone className="h-4 w-4" />
                  {business.phone}
                </a>
              </div>
            </nav>
          </div>
        </div>
      )}
    </header>
  );
}

export { Header };
