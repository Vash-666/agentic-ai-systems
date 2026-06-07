"use client";

import { useState } from "react";
import Link from "next/link";
import { Menu, X, Phone } from "lucide-react";
import { Button } from "@/components/ui/button";
import { siteConfig } from "@/config/site";

export function MobileNav() {
  const [open, setOpen] = useState(false);

  return (
    <div className="md:hidden">
      <Button
        variant="ghost"
        size="icon"
        onClick={() => setOpen(!open)}
        aria-label={open ? "Close menu" : "Open menu"}
      >
        {open ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
      </Button>

      {open && (
        <>
          {/* Overlay */}
          <div
            className="fixed inset-0 z-40 bg-black/20"
            onClick={() => setOpen(false)}
          />

          {/* Menu */}
          <div className="fixed inset-x-0 top-16 z-50 border-b bg-white px-4 pb-6 pt-4 shadow-lg">
            <nav className="flex flex-col gap-3">
              <Link
                href="/"
                className="rounded-lg px-3 py-2 text-base font-medium text-foreground hover:bg-muted"
                onClick={() => setOpen(false)}
              >
                Home
              </Link>
              <Link
                href="/services"
                className="rounded-lg px-3 py-2 text-base font-medium text-foreground hover:bg-muted"
                onClick={() => setOpen(false)}
              >
                Services
              </Link>
              <Link
                href="/about"
                className="rounded-lg px-3 py-2 text-base font-medium text-foreground hover:bg-muted"
                onClick={() => setOpen(false)}
              >
                About
              </Link>
              <Link
                href="/contact"
                className="rounded-lg px-3 py-2 text-base font-medium text-foreground hover:bg-muted"
                onClick={() => setOpen(false)}
              >
                Contact
              </Link>
              <div className="mt-2 border-t pt-3">
                <a
                  href={`tel:${siteConfig.phone}`}
                  className="flex items-center gap-2 rounded-lg px-3 py-2 text-base font-semibold text-primary hover:bg-muted"
                  onClick={() => setOpen(false)}
                >
                  <Phone className="h-4 w-4" />
                  {siteConfig.phone}
                </a>
              </div>
            </nav>
          </div>
        </>
      )}
    </div>
  );
}
