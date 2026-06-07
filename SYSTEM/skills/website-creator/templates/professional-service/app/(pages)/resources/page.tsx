import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { ResourceCard } from "@/components/features/ResourceCard";
import { CTABanner } from "@/components/sections/CTABanner";
import resourcesData from "@/content/data/resources.json";

export const metadata = {
  title: "Resources & Insights",
  description: "Legal insights, articles, and resources from Sterling & Associates.",
};

interface Resource {
  id: number;
  title: string;
  description: string;
  type: string;
  category: string;
  date: string;
  readTime: string;
}

export default function ResourcesPage() {
  const resources: Resource[] = resourcesData.resources;

  return (
    <>
      <Header />
      <main className="flex-1">
        {/* Hero Section */}
        <section className="bg-navy-900 py-20">
          <Container>
            <div className="max-w-3xl mx-auto text-center">
              <h1 className="font-heading text-4xl md:text-5xl font-bold text-white mb-6">
                Resources & Insights
              </h1>
              <p className="text-lg text-cream-200">
                Stay informed with the latest legal insights, articles, and resources 
                from our experienced attorneys.
              </p>
            </div>
          </Container>
        </section>

        {/* Resources Grid */}
        <section className="py-20 bg-white">
          <Container>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {resources.map((resource: Resource, index: number) => (
                <ResourceCard key={index} resource={resource} />
              ))}
            </div>
          </Container>
        </section>

        {/* Newsletter Section */}
        <section className="py-20 bg-cream-50">
          <Container>
            <div className="max-w-2xl mx-auto text-center">
              <h2 className="font-heading text-3xl font-bold text-navy-900 mb-4">
                Stay Updated
              </h2>
              <p className="text-charcoal-600 mb-8">
                Subscribe to our newsletter for the latest legal insights and firm news.
              </p>
              <form className="flex flex-col sm:flex-row gap-4 max-w-md mx-auto">
                <input
                  type="email"
                  placeholder="Enter your email"
                  className="flex-1 px-4 py-3 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-navy-900"
                />
                <button
                  type="submit"
                  className="px-6 py-3 bg-navy-900 text-white rounded-lg font-semibold hover:bg-navy-800 transition-colors"
                >
                  Subscribe
                </button>
              </form>
            </div>
          </Container>
        </section>

        <CTABanner />
      </main>
      <Footer />
    </>
  );
}
