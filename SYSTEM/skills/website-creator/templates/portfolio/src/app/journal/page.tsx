import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { ContactCTA } from "@/components/sections/ContactCTA";
import { Calendar, Clock, ArrowRight } from "lucide-react";
import Link from "next/link";
import journalData from "@/content/data/journal.json";

export const metadata = {
  title: "Journal",
  description: "Thoughts on photography, behind-the-scenes stories, and insights from the field by Marcus Chen.",
};

export default function JournalPage() {
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", {
      month: "long",
      day: "numeric",
      year: "numeric",
    });
  };

  const featuredPost = journalData.posts.find((p) => p.featured);
  const otherPosts = journalData.posts.filter((p) => p.id !== featuredPost?.id);

  return (
    <>
      <Header />
      <main>
        <section className="pt-32 pb-16 bg-background">
          <Container>
            <div className="text-center max-w-2xl mx-auto">
              <h1 className="font-display text-4xl sm:text-5xl font-bold mb-4">
                Journal
              </h1>
              <p className="text-foreground/60 text-lg">
                Thoughts on photography, behind-the-scenes stories, and insights from the field.
              </p>
            </div>
          </Container>
        </section>

        {featuredPost && (
          <section className="pb-16">
            <Container>
              <Link href={`/journal#${featuredPost.id}`} className="group block">
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
                  <div className="aspect-[16/10] rounded-lg overflow-hidden">
                    <img
                      src={featuredPost.image}
                      alt={featuredPost.title}
                      className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
                    />
                  </div>
                  <div className="space-y-4">
                    <div className="flex items-center gap-3 text-sm">
                      <span className="px-3 py-1 rounded-full bg-accent/10 text-accent font-medium">
                        Featured
                      </span>
                      <span className="text-foreground/50">{featuredPost.category}</span>
                    </div>
                    <h2 className="font-display text-3xl sm:text-4xl font-bold group-hover:text-accent transition-colors">
                      {featuredPost.title}
                    </h2>
                    <p className="text-foreground/70 text-lg">
                      {featuredPost.excerpt}
                    </p>
                    <div className="flex items-center gap-4 text-sm text-foreground/50">
                      <span className="flex items-center gap-1">
                        <Calendar className="h-4 w-4" />
                        {formatDate(featuredPost.date)}
                      </span>
                      <span className="flex items-center gap-1">
                        <Clock className="h-4 w-4" />
                        5 min read
                      </span>
                    </div>
                  </div>
                </div>
              </Link>
            </Container>
          </section>
        )}

        <section className="py-16 bg-card">
          <Container>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {otherPosts.map((post) => (
                <article key={post.id} className="group">
                  <Link href={`/journal#${post.id}`}>
                    <div className="aspect-[16/10] rounded-lg overflow-hidden mb-4">
                      <img
                        src={post.image}
                        alt={post.title}
                        className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
                      />
                    </div>
                  </Link>
                  <div className="flex items-center gap-3 text-sm text-foreground/50 mb-2">
                    <span className="text-accent font-medium">{post.category}</span>
                    <span>•</span>
                    <span>{formatDate(post.date)}</span>
                  </div>
                  <Link href={`/journal#${post.id}`}>
                    <h3 className="font-display text-xl font-semibold mb-2 group-hover:text-accent transition-colors">
                      {post.title}
                    </h3>
                  </Link>
                  <p className="text-foreground/60 text-sm line-clamp-2 mb-4">
                    {post.excerpt}
                  </p>
                  <Link
                    href={`/journal#${post.id}`}
                    className="inline-flex items-center gap-1 text-sm font-medium text-accent hover:underline"
                  >
                    Read More
                    <ArrowRight className="h-4 w-4" />
                  </Link>
                </article>
              ))}
            </div>
          </Container>
        </section>

        <ContactCTA />
      </main>
      <Footer />
    </>
  );
}