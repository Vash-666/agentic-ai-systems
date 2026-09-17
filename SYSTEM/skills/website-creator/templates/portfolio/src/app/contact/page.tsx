import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Textarea } from "@/components/ui/Textarea";
import { Mail, Phone, MapPin, Globe } from "lucide-react";
import artistData from "@/content/data/artist.json";

export const metadata = {
  title: "Contact",
  description: "Get in touch with Marcus Chen Photography for bookings, inquiries, and collaborations.",
};

export default function ContactPage() {
  return (
    <>
      <Header />
      <main>
        <section className="pt-32 pb-16 bg-background">
          <Container>
            <div className="text-center max-w-2xl mx-auto mb-16">
              <h1 className="font-display text-4xl sm:text-5xl font-bold mb-4">
                Get in Touch
              </h1>
              <p className="text-foreground/60 text-lg">
                Ready to create something beautiful? Let's discuss your project and bring your vision to life.
              </p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
              {/* Contact Form */}
              <div className="bg-card rounded-lg p-8">
                <h2 className="font-display text-2xl font-bold mb-6">
                  Send a Message
                </h2>
                <form className="space-y-6">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <label htmlFor="firstName" className="text-sm font-medium">
                        First Name
                      </label>
                      <Input id="firstName" placeholder="John" />
                    </div>
                    <div className="space-y-2">
                      <label htmlFor="lastName" className="text-sm font-medium">
                        Last Name
                      </label>
                      <Input id="lastName" placeholder="Doe" />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <label htmlFor="email" className="text-sm font-medium">
                      Email
                    </label>
                    <Input id="email" type="email" placeholder="john@example.com" />
                  </div>

                  <div className="space-y-2">
                    <label htmlFor="service" className="text-sm font-medium">
                      Service Interested In
                    </label>
                    <select
                      id="service"
                      className="flex h-10 w-full rounded-md border border-border bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-accent/50"
                    >
                      <option value="">Select a service</option>
                      <option value="portrait">Portrait Photography</option>
                      <option value="commercial">Commercial & Brand</option>
                      <option value="editorial">Editorial & Fashion</option>
                      <option value="events">Event Coverage</option>
                      <option value="prints">Fine Art Prints</option>
                      <option value="workshop">Photography Workshop</option>
                      <option value="other">Other</option>
                    </select>
                  </div>

                  <div className="space-y-2">
                    <label htmlFor="message" className="text-sm font-medium">
                      Message
                    </label>
                    <Textarea
                      id="message"
                      placeholder="Tell me about your project..."
                      rows={5}
                    />
                  </div>

                  <Button type="submit" className="w-full">
                    Send Message
                  </Button>
                </form>
              </div>

              {/* Contact Info */}
              <div className="space-y-8">
                <div>
                  <h2 className="font-display text-2xl font-bold mb-6">
                    Contact Information
                  </h2>
                  <div className="space-y-4">
                    <div className="flex items-start gap-4">
                      <div className="w-10 h-10 rounded-lg bg-accent/10 flex items-center justify-center flex-shrink-0">
                        <Mail className="h-5 w-5 text-accent" />
                      </div>
                      <div>
                        <p className="font-medium">Email</p>
                        <a
                          href={`mailto:${artistData.email}`}
                          className="text-foreground/60 hover:text-accent transition-colors"
                        >
                          {artistData.email}
                        </a>
                      </div>
                    </div>

                    <div className="flex items-start gap-4">
                      <div className="w-10 h-10 rounded-lg bg-accent/10 flex items-center justify-center flex-shrink-0">
                        <Phone className="h-5 w-5 text-accent" />
                      </div>
                      <div>
                        <p className="font-medium">Phone</p>
                        <a
                          href={`tel:${artistData.phone.replace(/\s/g, "")}`}
                          className="text-foreground/60 hover:text-accent transition-colors"
                        >
                          {artistData.phone}
                        </a>
                      </div>
                    </div>

                    <div className="flex items-start gap-4">
                      <div className="w-10 h-10 rounded-lg bg-accent/10 flex items-center justify-center flex-shrink-0">
                        <MapPin className="h-5 w-5 text-accent" />
                      </div>
                      <div>
                        <p className="font-medium">Location</p>
                        <p className="text-foreground/60">{artistData.location}</p>
                        <p className="text-sm text-foreground/40 mt-1">
                          Available for travel worldwide
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                <div>
                  <h3 className="font-display text-lg font-semibold mb-4">
                    Follow Me
                  </h3>
                  <div className="flex gap-4">
                    <a
                      href={artistData.social.instagram}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="w-10 h-10 rounded-lg bg-muted flex items-center justify-center text-foreground/60 hover:text-accent hover:bg-muted/80 transition-colors"
                      aria-label="Instagram"
                    >
                      <Globe className="h-5 w-5" />
                    </a>
                    <a
                      href={artistData.social.twitter}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="w-10 h-10 rounded-lg bg-muted flex items-center justify-center text-foreground/60 hover:text-accent hover:bg-muted/80 transition-colors"
                      aria-label="Twitter"
                    >
                      <Globe className="h-5 w-5" />
                    </a>
                    <a
                      href={artistData.social.linkedin}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="w-10 h-10 rounded-lg bg-muted flex items-center justify-center text-foreground/60 hover:text-accent hover:bg-muted/80 transition-colors"
                      aria-label="LinkedIn"
                    >
                      <Globe className="h-5 w-5" />
                    </a>
                  </div>
                </div>

                <div className="bg-accent/5 rounded-lg p-6 border border-accent/10">
                  <h3 className="font-display text-lg font-semibold mb-2">
                    Response Time
                  </h3>
                  <p className="text-foreground/60 text-sm">
                    I typically respond to inquiries within 24-48 hours. For urgent requests, please call directly.
                  </p>
                </div>
              </div>
            </div>
          </Container>
        </section>
      </main>
      <Footer />
    </>
  );
}