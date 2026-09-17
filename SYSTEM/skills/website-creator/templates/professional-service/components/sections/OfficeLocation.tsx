"use client";

import { Container } from "@/components/layout/Container";
import { ContactInfo } from "@/components/features/ContactInfo";
import business from "@/content/data/business.json";

function OfficeLocation() {
  return (
    <section className="py-20 bg-white">
      <Container>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
          <div>
            <p className="text-gold-600 font-medium mb-2 uppercase tracking-wide text-sm">
              Visit Our Office
            </p>
            <h2 className="font-heading text-3xl md:text-4xl font-bold text-navy-900 mb-6">
              Our Location
            </h2>
            <p className="text-charcoal-600 mb-8 leading-relaxed">
              Our offices are conveniently located in the heart of Manhattan. 
              We welcome you to visit us for a consultation or to discuss your 
              legal needs in person.
            </p>
            <ContactInfo />
          </div>

          <div className="bg-navy-100 rounded-lg overflow-hidden h-[400px] flex items-center justify-center">
            {/* Placeholder for map - in production, integrate Google Maps or similar */}
            <div className="text-center p-8">
              <div className="w-16 h-16 bg-navy-200 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg
                  className="w-8 h-8 text-navy-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                  />
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                  />
                </svg>
              </div>
              <h3 className="font-heading text-xl font-semibold text-navy-900 mb-2">
                {business.name}
              </h3>
              <p className="text-charcoal-600">
                {business.address.street}
                <br />
                {business.address.city}, {business.address.state} {business.address.zip}
              </p>
            </div>
          </div>
        </div>
      </Container>
    </section>
  );
}

export { OfficeLocation };
