import Link from "next/link";
import { ArrowRight, Calendar } from "lucide-react";
import { Container } from "@/components/layout/Container";

interface Post {
  id: string;
  title: string;
  excerpt: string;
  category: string;
  date: string;
  image: string;
}

interface JournalPreviewProps {
  posts: Post[];
}

export function JournalPreview({ posts }: JournalPreviewProps) {
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", {
      month: "long",
      day: "numeric",
      year: "numeric",
    });
  };

  return (
    <section className="py-24 bg-card">
      <Container>
        <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-12">
          <div>
            <h2 className="font-display text-3xl sm:text-4xl font-bold mb-4">
              From the Journal
            </h2>
            <p className="text-foreground/60 max-w-xl">
              Thoughts on photography, behind-the-scenes stories, and insights from the field.
            </p>
          </div>
          <Link
            href="/journal"
            className="inline-flex items-center gap-2 text-accent hover:underline font-medium"
          >
            View All Posts
            <ArrowRight className="h-4 w-4" />
          </Link>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {posts.map((post) => (
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
                <span className="flex items-center gap-1">
                  <Calendar className="h-3 w-3" />
                  {formatDate(post.date)}
                </span>
              </div>
              <Link href={`/journal#${post.id}`}>
                <h3 className="font-display text-xl font-semibold mb-2 group-hover:text-accent transition-colors">
                  {post.title}
                </h3>
              </Link>
              <p className="text-foreground/60 text-sm line-clamp-2">
                {post.excerpt}
              </p>
            </article>
          ))}
        </div>
      </Container>
    </section>
  );
}