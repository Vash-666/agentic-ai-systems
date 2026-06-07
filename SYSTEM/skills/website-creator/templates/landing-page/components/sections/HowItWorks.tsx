"use client";

import { ArrowRight, CheckCircle, Settings, Sparkles, Users } from "lucide-react";

function HowItWorks() {
  const steps = [
    {
      number: "01",
      icon: Settings,
      title: "Set Up in Minutes",
      description:
        "Import your existing projects or start fresh. Our onboarding wizard gets you up and running in under 5 minutes—no IT department required.",
    },
    {
      number: "02",
      icon: Users,
      title: "Invite Your Team",
      description:
        "Add team members with a simple email invite. They'll be productive immediately—no training sessions, no confusing manuals.",
    },
    {
      number: "03",
      icon: Sparkles,
      title: "Watch the Magic Happen",
      description:
        "See productivity soar as tasks get organized, deadlines get met, and your team finally has clarity on what matters most.",
    },
  ];

  return (
    <section id="how-it-works" className="py-20 bg-white">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-foreground mb-6">
            Get Started in 3 Simple Steps
          </h2>
          <p className="text-lg text-gray-600">
            No complex setup, no lengthy onboarding. You'll be managing projects
            like a pro within minutes.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8 lg:gap-12">
          {steps.map((step, index) => (
            <div key={index} className="relative">
              {/* Connector line */}
              {index < steps.length - 1 && (
                <div className="hidden md:block absolute top-12 left-full w-full h-0.5 bg-gradient-to-r from-primary/30 to-transparent -translate-x-8" />
              )}

              <div className="bg-gray-50 rounded-2xl p-8 h-full">
                <div className="flex items-center justify-between mb-6">
                  <div className="h-12 w-12 rounded-xl bg-primary flex items-center justify-center">
                    <step.icon className="h-6 w-6 text-white" />
                  </div>
                  <span className="text-4xl font-bold text-gray-200">
                    {step.number}
                  </span>
                </div>
                <h3 className="text-xl font-bold text-foreground mb-3">
                  {step.title}
                </h3>
                <p className="text-gray-600 leading-relaxed">
                  {step.description}
                </p>
              </div>
            </div>
          ))}
        </div>

        {/* Bottom CTA */}
        <div className="mt-16 text-center">
          <div className="inline-flex items-center gap-4 bg-success/10 rounded-full px-6 py-3">
            <CheckCircle className="h-5 w-5 text-success" />
            <span className="font-medium text-success">
              Join 50,000+ teams already shipping faster
            </span>
            <ArrowRight className="h-4 w-4 text-success" />
          </div>
        </div>
      </div>
    </section>
  );
}

export { HowItWorks };
