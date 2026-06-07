"use client";

import { cn } from "@/lib/utils";

interface FilterTabsProps {
  categories: string[];
  activeCategory: string;
  onSelect: (category: string) => void;
}

export function FilterTabs({
  categories,
  activeCategory,
  onSelect,
}: FilterTabsProps) {
  return (
    <div className="flex flex-wrap justify-center gap-2">
      {categories.map((category) => (
        <button
          key={category}
          onClick={() => onSelect(category)}
          className={cn(
            "rounded-full px-4 py-2 text-sm font-medium transition-all duration-200",
            activeCategory === category
              ? "bg-accent text-background"
              : "bg-muted text-foreground/70 hover:bg-muted/80 hover:text-foreground"
          )}
        >
          {category}
        </button>
      ))}
    </div>
  );
}