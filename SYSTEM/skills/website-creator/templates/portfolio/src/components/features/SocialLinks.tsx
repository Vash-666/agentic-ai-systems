import { Globe } from "lucide-react";
import { cn } from "@/lib/utils";

interface SocialLink {
  platform: string;
  url: string;
  icon?: string;
}

interface SocialLinksProps {
  links: SocialLink[];
  className?: string;
  iconSize?: "sm" | "md" | "lg";
}

export function SocialLinks({
  links,
  className,
  iconSize = "md",
}: SocialLinksProps) {
  const sizeClasses = {
    sm: "h-4 w-4",
    md: "h-5 w-5",
    lg: "h-6 w-6",
  };

  return (
    <div className={cn("flex items-center gap-4", className)}>
      {links.map((link) => (
        <a
          key={link.platform}
          href={link.url}
          target="_blank"
          rel="noopener noreferrer"
          className="text-foreground/60 hover:text-accent transition-colors"
          aria-label={link.platform}
        >
          <Globe className={sizeClasses[iconSize]} />
        </a>
      ))}
    </div>
  );
}