"use client";

import { Badge } from "@/components/ui/Badge";
import {
  BarChart3,
  Clock,
  LayoutGrid,
  LucideIcon,
  Plug,
  Users,
  Zap,
} from "lucide-react";

interface Feature {
  id: string;
  title: string;
  description: string;
  icon: string;
  highlight: string | null;
}

const iconMap: Record<string, LucideIcon> = {
  LayoutGrid,
  Clock,
  Zap,
  Users,
  BarChart3,
  Plug,
};

function FeaturesGrid() {
  const features: Feature[] = [
    {
      id: "kanban",
      title: "Visual Kanban Boards",
      description:
        "Drag, drop, and organize tasks with intuitive boards that keep everyone on the same page.",
      icon: "LayoutGrid",
      highlight: "Most Popular",
    },
    {
      id: "timeline",
      title: "Smart Timeline View",
      description:
        "See the big picture with Gantt-style timelines that auto-update as your team progresses.",
      icon: "Clock",
      highlight: null,
    },
    {
      id: "automation",
      title: "Workflow Automation",
      description:
        "Automate repetitive tasks. Set triggers and let TaskFlow handle the busywork.",
      icon: "Zap",
      highlight: "New",
    },
    {
      id: "collaboration",
      title: "Real-Time Collaboration",
      description:
        "Comment, tag, and collaborate in real-time. No more endless email threads.",
      icon: "Users",
      highlight: null,
    },
    {
      id: "analytics",
      title: "Powerful Analytics",
      description:
        "Track velocity, burndown, and team performance with beautiful dashboards.",
      icon: "BarChart3",
      highlight: null,
    },
    {
      id: "integrations",
      title: "200+ Integrations",
      description:
        "Connect Slack, GitHub, Figma, and all your favorite tools in one place.",
      icon: "Plug",
      highlight: null,
    },
  ];

  return (
    <section id="features" className="py-20 bg-gray-50">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-foreground mb-6">
            Everything You Need to Ship Great Work
          </h2>
          <p className="text-lg text-gray-600">
            Powerful features that adapt to how your team works. No bloat, no
            complexity—just the tools you need to get things done.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {features.map((feature) => {
            const Icon = iconMap[feature.icon];
            return (
              <div
                key={feature.id}
                className="group bg-white rounded-2xl p-8 shadow-lg shadow-gray-200/50 border border-gray-100 hover:shadow-xl hover:shadow-gray-200/50 transition-all duration-300 hover:-translate-y-1"
              >
                <div className="flex items-start justify-between mb-6">
                  <div className="h-12 w-12 rounded-xl bg-primary/10 flex items-center justify-center group-hover:bg-primary group-hover:scale-110 transition-all duration-300">
                    <Icon className="h-6 w-6 text-primary group-hover:text-white transition-colors" />
                  </div>
                  {feature.highlight && (
                    <Badge variant="success" size="sm">
                      {feature.highlight}
                    </Badge>
                  )}
                </div>
                <h3 className="text-xl font-bold text-foreground mb-3">
                  {feature.title}
                </h3>
                <p className="text-gray-600 leading-relaxed">
                  {feature.description}
                </p>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}

export { FeaturesGrid };
