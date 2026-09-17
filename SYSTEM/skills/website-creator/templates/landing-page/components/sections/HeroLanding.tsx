"use client";

import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { TrustBadge } from "@/components/ui/TrustBadge";
import { ArrowRight, Play, Star, Users } from "lucide-react";
import { useState } from "react";

function HeroLanding() {
  const [email, setEmail] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle email capture
    console.log("Email captured:", email);
  };

  return (
    <section className="relative overflow-hidden bg-white pt-32 pb-20 lg:pt-40 lg:pb-32">
      {/* Background decoration */}
      <div className="absolute inset-0 -z-10">
        <div className="absolute top-0 right-0 -translate-y-1/4 translate-x-1/4 w-[800px] h-[800px] bg-primary/5 rounded-full blur-3xl" />
        <div className="absolute bottom-0 left-0 translate-y-1/4 -translate-x-1/4 w-[600px] h-[600px] bg-success/5 rounded-full blur-3xl" />
      </div>

      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid lg:grid-cols-2 gap-12 lg:gap-16 items-center">
          {/* Content */}
          <div className="text-center lg:text-left">
            {/* Social proof badge */}
            <div className="inline-flex items-center gap-2 rounded-full bg-primary/10 px-4 py-2 mb-8">
              <Star className="h-4 w-4 text-primary fill-primary" />
              <span className="text-sm font-medium text-primary">
                Rated 4.9/5 by 10,000+ teams
              </span>
            </div>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-foreground mb-6">
              Project Management{" "}
              <span className="text-primary">That Actually Works</span>
            </h1>

            <p className="text-lg sm:text-xl text-gray-600 mb-8 max-w-2xl mx-auto lg:mx-0 leading-relaxed">
              Stop drowning in spreadsheets. The project management tool that
              helps teams ship faster, collaborate better, and hit every
              deadline.
            </p>

            {/* Email capture form */}
            <form
              onSubmit={handleSubmit}
              className="flex flex-col sm:flex-row gap-3 max-w-md mx-auto lg:mx-0 mb-6"
            >
              <Input
                type="email"
                placeholder="Enter your work email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="flex-1"
                required
              />
              <Button type="submit" size="lg" className="whitespace-nowrap">
                Start Free Trial
                <ArrowRight className="h-4 w-4" />
              </Button>
            </form>

            {/* Trust badges */}
            <div className="flex flex-wrap justify-center lg:justify-start gap-4">
              <TrustBadge variant="secure" text="No credit card required" />
              <TrustBadge variant="users" text="14-day free trial" />
            </div>
          </div>

          {/* Visual / Demo area */}
          <div className="relative">
            <div className="relative rounded-2xl bg-gradient-to-br from-gray-50 to-gray-100 p-2 shadow-2xl shadow-gray-200/50">
              {/* Mock UI */}
              <div className="bg-white rounded-xl overflow-hidden">
                {/* Header */}
                <div className="bg-gray-50 px-4 py-3 border-b border-gray-100 flex items-center gap-2">
                  <div className="flex gap-1.5">
                    <div className="w-3 h-3 rounded-full bg-red-400" />
                    <div className="w-3 h-3 rounded-full bg-yellow-400" />
                    <div className="w-3 h-3 rounded-full bg-green-400" />
                  </div>
                  <div className="flex-1 text-center text-sm text-gray-400">
                    TaskFlow Dashboard
                  </div>
                </div>

                {/* Content */}
                <div className="p-6">
                  <div className="flex items-center justify-between mb-6">
                    <div>
                      <div className="h-4 w-32 bg-gray-200 rounded mb-2" />
                      <div className="h-3 w-20 bg-gray-100 rounded" />
                    </div>
                    <div className="flex gap-2">
                      <div className="h-8 w-20 bg-primary/10 rounded-lg" />
                      <div className="h-8 w-8 bg-primary rounded-lg" />
                    </div>
                  </div>

                  {/* Kanban columns */}
                  <div className="grid grid-cols-3 gap-3">
                    {["To Do", "In Progress", "Done"].map((col, i) => (
                      <div key={col} className="bg-gray-50 rounded-lg p-3">
                        <div className="flex items-center justify-between mb-3">
                          <span className="text-xs font-medium text-gray-600">
                            {col}
                          </span>
                          <span className="text-xs text-gray-400">
                            {i === 0 ? "4" : i === 1 ? "2" : "8"}
                          </span>
                        </div>
                        <div className="space-y-2">
                          {Array.from({ length: i === 2 ? 3 : 2 }).map((_, j) => (
                            <div
                              key={j}
                              className="bg-white p-3 rounded-lg shadow-sm border border-gray-100"
                            >
                              <div className="h-2 w-full bg-gray-100 rounded mb-2" />
                              <div className="h-2 w-2/3 bg-gray-100 rounded" />
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Floating stats card */}
              <div className="absolute -bottom-4 -left-4 bg-white rounded-xl shadow-xl p-4 border border-gray-100">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-full bg-success/10 flex items-center justify-center">
                    <Users className="h-5 w-5 text-success" />
                  </div>
                  <div>
                    <div className="text-2xl font-bold text-foreground">98%</div>
                    <div className="text-xs text-gray-500">On-time delivery</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export { HeroLanding };
