import { cn } from "@/lib/utils";

interface ProjectCardProps {
  title: string;
  category: string;
  image: string;
  description?: string;
  className?: string;
  onClick?: () => void;
}

export function ProjectCard({
  title,
  category,
  image,
  description,
  className,
  onClick,
}: ProjectCardProps) {
  return (
    <div
      className={cn(
        "group relative overflow-hidden rounded-lg cursor-pointer",
        className
      )}
      onClick={onClick}
    >
      <img
        src={image}
        alt={title}
        className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
      />
      <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent opacity-60 group-hover:opacity-90 transition-opacity duration-300" />
      <div className="absolute bottom-0 left-0 right-0 p-6">
        <p className="text-sm font-medium text-accent mb-1">{category}</p>
        <h3 className="font-display text-xl font-semibold text-white mb-1">
          {title}
        </h3>
        {description && (
          <p className="text-sm text-white/70 line-clamp-2 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
            {description}
          </p>
        )}
      </div>
    </div>
  );
}