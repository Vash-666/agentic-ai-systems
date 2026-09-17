import { cn } from "@/lib/utils";

interface ContainerProps {
  children: React.ReactNode;
  className?: string;
  size?: "default" | "small" | "large" | "full";
}

export function Container({
  children,
  className,
  size = "default",
}: ContainerProps) {
  return (
    <div
      className={cn(
        "mx-auto px-4 sm:px-6 lg:px-8",
        size === "small" && "max-w-4xl",
        size === "default" && "max-w-7xl",
        size === "large" && "max-w-[1400px]",
        size === "full" && "max-w-none",
        className
      )}
    >
      {children}
    </div>
  );
}