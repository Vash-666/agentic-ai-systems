import * as React from "react";
import { cn } from "@/lib/utils";

interface ContainerProps extends React.HTMLAttributes<HTMLDivElement> {
  size?: "default" | "small" | "large";
}

function Container({
  children,
  className,
  size = "default",
  ...props
}: ContainerProps) {
  return (
    <div
      className={cn(
        "mx-auto px-4 sm:px-6 lg:px-8",
        size === "small" && "max-w-4xl",
        size === "default" && "max-w-7xl",
        size === "large" && "max-w-[1400px]",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}

export { Container };
