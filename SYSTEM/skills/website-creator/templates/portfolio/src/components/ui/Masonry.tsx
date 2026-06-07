"use client";

import { cn } from "@/lib/utils";

interface MasonryProps {
  children: React.ReactNode;
  className?: string;
  columns?: number;
}

export function Masonry({ children, className, columns = 3 }: MasonryProps) {
  return (
    <div
      className={cn(
        "columns-1 gap-4 space-y-4",
        columns >= 2 && "sm:columns-2",
        columns >= 3 && "lg:columns-3",
        className
      )}
    >
      {children}
    </div>
  );
}

interface MasonryItemProps {
  children: React.ReactNode;
  className?: string;
}

export function MasonryItem({ children, className }: MasonryItemProps) {
  return (
    <div className={cn("break-inside-avoid", className)}>
      {children}
    </div>
  );
}