import { siteConfig } from "@/config/site";
import { Shield, Clock, ThumbsUp, DollarSign } from "lucide-react";
import type { LucideIcon } from "lucide-react";

const trustIcons: LucideIcon[] = [Shield, Clock, ThumbsUp, DollarSign];

export function TrustSection() {
  return (
    <section className="bg-muted/30 py-16 md:py-20">
      <div className="container mx-auto px-4">
        <h2 className="mb-10 text-center text-3xl font-bold">
          Why Choose {siteConfig.businessName}?
        </h2>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {siteConfig.trustPoints.map((point, i) => {
            const Icon = trustIcons[i] || Shield;
            return (
              <div
                key={point.headline}
                className="flex flex-col items-center rounded-lg bg-white p-6 text-center shadow-sm"
              >
                <div className="mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
                  <Icon className="h-6 w-6 text-primary" />
                </div>
                <h3 className="mb-1 text-lg font-semibold">
                  {point.headline}
                </h3>
                <p className="text-sm text-muted-foreground">
                  {point.description}
                </p>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
