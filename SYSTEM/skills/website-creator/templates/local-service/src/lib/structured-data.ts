import { siteConfig, type SiteConfig } from "@/config/site";

function getBaseUrl(config: SiteConfig): string {
  return config.siteUrl || `https://${config.businessName.toLowerCase().replace(/\s+/g, "")}.com`;
}

export function getLocalBusinessSchema(config: SiteConfig = siteConfig) {
  const hours: Record<string, string> = {};
  for (const [day, time] of Object.entries(config.businessHours)) {
    if (time !== "Closed" && !time.toLowerCase().includes("emergency")) {
      hours[day] = time;
    }
  }

  const openingHours = Object.entries(hours).map(
    ([day, time]) => `${day} ${time}`
  );

  return {
    "@context": "https://schema.org",
    "@type": "LocalBusiness",
    name: config.businessName,
    description: `${config.businessName} provides professional ${config.serviceType.toLowerCase()} services in ${config.serviceArea}. ${config.tagline}`,
    image: `${getBaseUrl(config)}/images/hero.jpg`,
    url: getBaseUrl(config),
    telephone: config.phone,
    email: config.email,
    priceRange: "$$",
    address: {
      "@type": "PostalAddress",
      streetAddress: config.address.street,
      addressLocality: config.address.city,
      addressRegion: config.address.state,
      postalCode: config.address.zip,
      addressCountry: "US",
    },
    geo: {
      "@type": "GeoCoordinates",
      latitude: 38.8793, // Default: Arlington, VA — users should update
      longitude: -77.1082,
    },
    openingHoursSpecification: Object.entries(hours).map(([day, time]) => {
      const [open, close] = time.replace(/\s+/g, "").split("–");
      return {
        "@type": "OpeningHoursSpecification",
        dayOfWeek: `https://schema.org/${day}`,
        opens: open,
        closes: close,
      };
    }),
    areaServed: {
      "@type": "City",
      name: config.serviceArea,
    },
    hasOfferCatalog: {
      "@type": "OfferCatalog",
      name: `${config.serviceType} Services`,
      itemListElement: config.services.map((s, i) => ({
        "@type": "Offer",
        itemOffered: {
          "@type": "Service",
          name: s.name,
          description: s.shortDescription,
        },
      })),
    },
    founder: {
      "@type": "Person",
      name: config.ownerName,
    },
    foundingDate: `${config.yearEstablished}`,
    foundingLocation: {
      "@type": "Place",
      address: {
        "@type": "PostalAddress",
        addressLocality: config.address.city,
        addressRegion: config.address.state,
        addressCountry: "US",
      },
    },
    aggregateRating: {
      "@type": "AggregateRating",
      ratingValue: "4.9",
      reviewCount: "125",
      bestRating: "5",
    },
  };
}

export function getFAQSchema(
  faqs: { question: string; answer: string }[]
) {
  return {
    "@context": "https://schema.org",
    "@type": "FAQPage",
    mainEntity: faqs.map((faq) => ({
      "@type": "Question",
      name: faq.question,
      acceptedAnswer: {
        "@type": "Answer",
        text: faq.answer,
      },
    })),
  };
}

export function getServiceSchema(
  serviceName: string,
  description: string,
  serviceArea: string,
  businessName: string
) {
  return {
    "@context": "https://schema.org",
    "@type": "Service",
    name: serviceName,
    description,
    provider: {
      "@type": "LocalBusiness",
      name: businessName,
    },
    areaServed: {
      "@type": "City",
      name: serviceArea,
    },
  };
}
