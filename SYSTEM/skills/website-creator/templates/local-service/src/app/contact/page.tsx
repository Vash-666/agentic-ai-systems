import { siteConfig } from "@/config/site";
import { getLocalBusinessSchema } from "@/lib/structured-data";
import { getPageMetadata } from "@/lib/metadata";
import { Header } from "@/components/sections/header";
import { Footer } from "@/components/sections/footer";
import { ContactForm } from "@/components/sections/contact-form";
import {
  Phone,
  Mail,
  MapPin,
  Clock,
  AlertTriangle,
  ArrowRight,
} from "lucide-react";


const pageMeta = getPageMetadata("contact");

export const metadata = {
  title: pageMeta.title,
  description: pageMeta.description,
  openGraph: {
    title: pageMeta.title,
    description: pageMeta.description,
    url: `${siteConfig.siteUrl}/contact`,
    siteName: siteConfig.businessName,
    locale: "en_US",
    type: "website",
  },
};

type HoursKey = keyof typeof siteConfig.businessHours;

export default function ContactPage() {
  const localBusinessSchema = getLocalBusinessSchema();

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(localBusinessSchema),
        }}
      />

      <Header />
      <main>
        {/* Page Header — H1 */}
        <section className="bg-muted/40 py-16 md:py-20">
          <div className="container mx-auto px-4 text-center">
            <h1 className="mb-4 text-4xl font-bold md:text-5xl">
              Contact Us
            </h1>
            <p className="mx-auto max-w-2xl text-lg text-muted-foreground">
              Get in Touch for Fast, Professional{" "}
              {siteConfig.serviceType} Service in {siteConfig.serviceArea}
            </p>
          </div>
        </section>

        {/* Form + Contact Info */}
        <section className="py-16 md:py-20">
          <div className="container mx-auto px-4">
            <div className="grid gap-10 lg:grid-cols-5">
              {/* Contact Form */}
              <div className="lg:col-span-3">
                <h2 className="mb-6 text-2xl font-bold">
                  Request a Free Quote
                </h2>
                <ContactForm />
              </div>

              {/* Contact Information */}
              <div className="lg:col-span-2">
                <div className="space-y-6">
                  {/* Phone */}
                  <div className="rounded-lg border bg-white p-5 shadow-sm">
                    <div className="flex items-start gap-3">
                      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary/10">
                        <Phone className="h-5 w-5 text-primary" />
                      </div>
                      <div>
                        <h3 className="font-semibold">Call Us</h3>
                        <a
                          href={`tel:${siteConfig.phone}`}
                          className="text-lg font-bold text-primary hover:underline"
                        >
                          {siteConfig.phone}
                        </a>
                      </div>
                    </div>
                  </div>

                  {/* Email */}
                  <div className="rounded-lg border bg-white p-5 shadow-sm">
                    <div className="flex items-start gap-3">
                      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary/10">
                        <Mail className="h-5 w-5 text-primary" />
                      </div>
                      <div>
                        <h3 className="font-semibold">Email Us</h3>
                        <a
                          href={`mailto:${siteConfig.email}`}
                          className="text-primary hover:underline"
                        >
                          {siteConfig.email}
                        </a>
                      </div>
                    </div>
                  </div>

                  {/* Address */}
                  <div className="rounded-lg border bg-white p-5 shadow-sm">
                    <div className="flex items-start gap-3">
                      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary/10">
                        <MapPin className="h-5 w-5 text-primary" />
                      </div>
                      <div>
                        <h3 className="font-semibold">Visit Us</h3>
                        <p className="text-muted-foreground">
                          {siteConfig.address.street}
                          <br />
                          {siteConfig.address.city},{" "}
                          {siteConfig.address.state}{" "}
                          {siteConfig.address.zip}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Business Hours */}
                  <div className="rounded-lg border bg-white p-5 shadow-sm">
                    <div className="flex items-start gap-3">
                      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary/10">
                        <Clock className="h-5 w-5 text-primary" />
                      </div>
                      <div className="flex-1">
                        <h3 className="mb-2 font-semibold">
                          Business Hours
                        </h3>
                        <table className="w-full text-sm text-muted-foreground">
                          <tbody>
                            {(
                              Object.keys(
                                siteConfig.businessHours
                              ) as HoursKey[]
                            ).map((day) => (
                              <tr key={day}>
                                <td className="py-1 pr-4 font-medium text-foreground">
                                  {day}
                                </td>
                                <td className="py-1 text-right">
                                  {siteConfig.businessHours[day]}
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  </div>

                  {/* Emergency Service */}
                  <div className="rounded-lg border-2 border-destructive/20 bg-destructive/5 p-5">
                    <div className="flex items-start gap-3">
                      <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-destructive/10">
                        <AlertTriangle className="h-5 w-5 text-destructive" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-destructive">
                          24/7 Emergency Service
                        </h3>
                        <p className="mb-2 text-sm text-muted-foreground">
                          For urgent issues, call our emergency line:
                        </p>
                        <a
                          href={`tel:${siteConfig.emergencyPhone}`}
                          className="text-lg font-bold text-destructive hover:underline"
                        >
                          {siteConfig.emergencyPhone}
                        </a>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Map Section */}
        <section className="bg-muted/30 py-16">
          <div className="container mx-auto px-4">
            <h2 className="mb-6 text-center text-2xl font-bold">Find Us</h2>
            <div className="mx-auto max-w-4xl overflow-hidden rounded-lg shadow-sm">
              {/* Google Maps Embed Placeholder */}
              <div className="flex h-[400px] items-center justify-center bg-muted">
                <div className="text-center">
                  <MapPin className="mx-auto mb-2 h-10 w-10 text-muted-foreground/50" />
                  <p className="text-muted-foreground">
                    Google Maps Embed
                  </p>
                  <p className="text-xs text-muted-foreground/60">
                    Replace with your Google Maps iframe
                  </p>
                  <a
                    href={`https://maps.google.com/?q=${encodeURIComponent(`${siteConfig.address.street}, ${siteConfig.address.city}, ${siteConfig.address.state} ${siteConfig.address.zip}`)}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="mt-2 inline-flex items-center gap-1 text-sm font-medium text-primary hover:underline"
                  >
                    Get Directions <ArrowRight className="h-3 w-3" />
                  </a>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Service Area */}
        <section className="py-16 md:py-20">
          <div className="container mx-auto px-4 text-center">
            <h2 className="mb-4 text-3xl font-bold">
              We Serve {siteConfig.serviceArea}
            </h2>
            <p className="mb-8 text-lg text-muted-foreground">
              Our team provides reliable {siteConfig.serviceType.toLowerCase()}{" "}
              services throughout {siteConfig.serviceArea} and surrounding
              communities.
            </p>

            <div className="mx-auto flex max-w-3xl flex-wrap justify-center gap-x-4 gap-y-2">
              {siteConfig.serviceAreaList.map((city) => (
                <span
                  key={city}
                  className="inline-flex items-center rounded-full bg-muted px-4 py-2 text-sm font-medium"
                >
                  {city}
                </span>
              ))}
            </div>

            <p className="mt-6 text-sm text-muted-foreground">
              Not sure if we serve your area? Give us a call!
            </p>
            <a
              href={`tel:${siteConfig.phone}`}
              className="inline-flex mt-2 text-lg font-bold text-primary underline-offset-4 hover:underline"
            >
              {siteConfig.phone}
            </a>
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
