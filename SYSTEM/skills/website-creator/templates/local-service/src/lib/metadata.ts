import { siteConfig, type SiteConfig } from "@/config/site";

export type PageMetadata = {
  title: string;
  description: string;
  path: string;
};

export function getPageMetadata(
  page: string,
  custom?: Partial<PageMetadata>,
  config: SiteConfig = siteConfig
): PageMetadata {
  const defaults: Record<string, PageMetadata> = {
    home: {
      title: `${config.businessName} | ${config.tagline} — Serving ${config.serviceArea}`,
      description: `Professional ${config.serviceType.toLowerCase()} services in ${config.serviceArea}. ${config.tagline}. Licensed & insured. Call ${config.phone} for same-day service.`,
      path: "/",
    },
    services: {
      title: `${config.serviceType} Services | ${config.businessName} — ${config.serviceArea}`,
      description: `Professional ${config.serviceType.toLowerCase()} services in ${config.serviceArea}. Emergency repairs, drain cleaning, water heaters, and more. Licensed & insured. Call ${config.phone}.`,
      path: "/services",
    },
    about: {
      title: `About ${config.businessName} | ${config.yearsInBusiness} Years Serving ${config.serviceArea}`,
      description: `Learn about ${config.businessName} — a trusted ${config.serviceType.toLowerCase()} company serving ${config.serviceArea} since ${config.yearEstablished}. Licensed, insured, and committed to quality.`,
      path: "/about",
    },
    contact: {
      title: `Contact ${config.businessName} | ${config.serviceArea} ${config.serviceType} Services`,
      description: `Contact ${config.businessName} for professional ${config.serviceType.toLowerCase()} services in ${config.serviceArea}. Call ${config.phone} or fill out our online form. 24/7 emergency service available.`,
      path: "/contact",
    },
  };

  return { ...defaults[page], ...custom };
}
