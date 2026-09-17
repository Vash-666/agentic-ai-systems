"use client";

import { Button } from "@/components/ui/Button";
import { CheckCircle, Sparkles } from "lucide-react";

function SolutionReveal() {
  const benefits = [
    "Set up in under 5 minutes—no training required",
    "See every project's status at a glance",
    "Automate repetitive tasks and save 10+ hours/week",
    "Keep everyone aligned with real-time updates",
    "Integrate with the tools you already use",
  ];

  return (
    <section className="py-20 bg-white">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Visual side */}
          <div className="order-2 lg:order-1">
            <div className="relative">
              <div className="bg-gradient-to-br from-primary/5 to-success/5 rounded-3xl p-8 lg:p-12">
                {/* Before/After visualization */}
                <div className="space-y-6">
                  {/* Before */}
                  <div className="bg-white rounded-xl p-6 shadow-lg opacity-60">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="h-8 w-8 rounded-full bg-red-100 flex items-center justify-center text-red-600 text-sm font-bold">
                        B
                      </div>
                      <span className="font-semibold text-gray-500">
                        Before TaskFlow
                      </span>
                    </div>
                    <div className="space-y-2">
                      <div className="h-2 bg-gray-200 rounded w-full" />
                      <div className="h-2 bg-gray-200 rounded w-4/5" />
                      <div className="h-2 bg-gray-200 rounded w-3/5" />
                    </div>
                    <div className="mt-4 flex gap-2">
                      <span className="text-xs bg-red-100 text-red-700 px-2 py-1 rounded">
                        Overdue
                      </span>
                      <span className="text-xs bg-red-100 text-red-700 px-2 py-1 rounded">
                        Blocked
                      </span>
                    </div>
                  </div>

                  {/* Arrow */}
                  <div className="flex justify-center">
                    <div className="h-8 w-8 rounded-full bg-success/20 flex items-center justify-center">
                      <Sparkles className="h-4 w-4 text-success" />
                    </div>
                  </div>

                  {/* After */}
                  <div className="bg-white rounded-xl p-6 shadow-xl border-2 border-success/20">
                    <div className="flex items-center gap-3 mb-4">
                      <div className="h-8 w-8 rounded-full bg-success/20 flex items-center justify-center text-success text-sm font-bold">
                        A
                      </div>
                      <span className="font-semibold text-foreground">
                        With TaskFlow
                      </span>
                    </div>
                    <div className="space-y-2">
                      <div className="h-2 bg-success rounded w-full" />
                      <div className="h-2 bg-success rounded w-full" />
                      <div className="h-2 bg-success rounded w-full" />
                    </div>
                    <div className="mt-4 flex gap-2">
                      <span className="text-xs bg-success/10 text-success px-2 py-1 rounded">
                        On Track
                      </span>
                      <span className="text-xs bg-primary/10 text-primary px-2 py-1 rounded">
                        2 Days Ahead
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Content side */}
          <div className="order-1 lg:order-2">
            <div className="inline-flex items-center gap-2 rounded-full bg-success/10 px-4 py-2 mb-6">
              <Sparkles className="h-4 w-4 text-success" />
              <span className="text-sm font-medium text-success">
                The Solution Is Here
              </span>
            </div>

            <h2 className="text-3xl sm:text-4xl font-bold text-foreground mb-6">
              Meet TaskFlow: Project Management That Just Works
            </h2>

            <p className="text-lg text-gray-600 mb-8 leading-relaxed">
              We built TaskFlow because we were tired of project management tools
              that got in the way. It's powerful enough for enterprise teams,
              simple enough for startups, and flexible enough for everyone in
              between.
            </p>

            <ul className="space-y-4 mb-8">
              {benefits.map((benefit, index) => (
                <li key={index} className="flex items-start gap-3">
                  <CheckCircle className="h-6 w-6 text-success shrink-0 mt-0.5" />
                  <span className="text-gray-700">{benefit}</span>
                </li>
              ))}
            </ul>

            <Button size="lg" onClick={() => {
              document.querySelector('#pricing')?.scrollIntoView({ behavior: 'smooth' });
            }}>
              Start Your Free Trial
            </Button>
          </div>
        </div>
      </div>
    </section>
  );
}

export { SolutionReveal };
