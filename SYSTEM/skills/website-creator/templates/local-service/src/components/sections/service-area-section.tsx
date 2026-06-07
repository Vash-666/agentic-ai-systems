import { siteConfig } from "@/config/site";

export function ServiceAreaSection() {
  return (
    <section className="bg-muted/30 py-16 md:py-20">
      <div className="container mx-auto px-4 text-center">
        <h2 className="mb-4 text-3xl font-bold">
          Proudly Serving {siteConfig.serviceArea}
        </h2>
        <p className="mb-8 text-lg text-muted-foreground">
          Our team provides reliable services throughout{" "}
          {siteConfig.serviceArea} and surrounding communities.
        </p>

        <div className="mx-auto flex max-w-2xl flex-wrap justify-center gap-x-4 gap-y-2">
          {siteConfig.serviceAreaList.map((city) => (
            <span
              key={city}
              className="inline-flex items-center rounded-full bg-white px-4 py-2 text-sm font-medium shadow-sm"
            >
              {city}
            </span>
          ))}
        </div>
      </div>
    </section>
  );
}
