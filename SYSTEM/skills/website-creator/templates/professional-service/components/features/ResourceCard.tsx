import Link from "next/link";
import { ArrowRight, FileText } from "lucide-react";
import { Card, CardContent, CardHeader } from "@/components/ui/Card";
import { Badge } from "@/components/ui/Badge";

interface Resource {
  id: number;
  title: string;
  description: string;
  type: string;
  category: string;
  date: string;
  readTime: string;
}

interface ResourceCardProps {
  resource: Resource;
}

function ResourceCard({ resource }: ResourceCardProps) {
  return (
    <Card className="group h-full flex flex-col">
      <CardHeader className="pb-3">
        <div className="flex items-center gap-2 mb-3">
          <Badge variant="accent">{resource.type}</Badge>
          <span className="text-xs text-charcoal-500">{resource.category}</span>
        </div>
        <h3 className="font-heading text-lg font-semibold text-navy-900 group-hover:text-gold-600 transition-colors">
          {resource.title}
        </h3>
      </CardHeader>
      <CardContent className="flex-1 flex flex-col">
        <p className="text-sm text-charcoal-600 mb-4 flex-1">
          {resource.description}
        </p>
        <div className="flex items-center justify-between pt-4 border-t border-navy-100">
          <span className="text-xs text-charcoal-500">{resource.readTime}</span>
          <Link
            href={`/resources#${resource.id}`}
            className="inline-flex items-center gap-1 text-sm font-medium text-navy-700 hover:text-gold-600 transition-colors"
          >
            Read More
            <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      </CardContent>
    </Card>
  );
}

export { ResourceCard };
export type { Resource };
