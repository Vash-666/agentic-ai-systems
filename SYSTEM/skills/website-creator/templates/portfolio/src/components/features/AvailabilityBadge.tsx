import { cn } from "@/lib/utils";
import { Clock } from "lucide-react";

interface AvailabilityBadgeProps {
  status: "available" | "limited" | "booked";
  nextAvailable?: string;
  className?: string;
}

export function AvailabilityBadge({
  status,
  nextAvailable,
  className,
}: AvailabilityBadgeProps) {
  const statusConfig = {
    available: {
      label: "Available for Projects",
      color: "bg-green-500/20 text-green-400 border-green-500/30",
      dotColor: "bg-green-400",
    },
    limited: {
      label: "Limited Availability",
      color: "bg-yellow-500/20 text-yellow-400 border-yellow-500/30",
      dotColor: "bg-yellow-400",
    },
    booked: {
      label: "Fully Booked",
      color: "bg-red-500/20 text-red-400 border-red-500/30",
      dotColor: "bg-red-400",
    },
  };

  const config = statusConfig[status];

  return (
    <div
      className={cn(
        "inline-flex items-center gap-2 px-4 py-2 rounded-full border text-sm font-medium",
        config.color,
        className
      )}
    >
      <span className={cn("w-2 h-2 rounded-full animate-pulse", config.dotColor)} />
      <span>{config.label}</span>
      {nextAvailable && status !== "available" && (
        <span className="text-foreground/50 flex items-center gap-1">
          <Clock className="h-3 w-3" />
          Next: {nextAvailable}
        </span>
      )}
    </div>
  );
}