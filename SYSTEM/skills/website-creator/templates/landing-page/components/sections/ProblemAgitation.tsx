"use client";

import { AlertTriangle, Clock, Frown, XCircle } from "lucide-react";

function ProblemAgitation() {
  const problems = [
    {
      icon: Clock,
      title: "Deadlines Keep Slipping",
      description:
        "Projects that should take weeks stretch into months. Your team is busy, but nothing seems to get finished.",
    },
    {
      icon: XCircle,
      title: "Information Everywhere",
      description:
        "Critical updates buried in email threads, Slack messages, and sticky notes. Nobody knows what's actually happening.",
    },
    {
      icon: Frown,
      title: "Tools That Fight You",
      description:
        "Complex software that requires a PhD to use. Your team spends more time managing the tool than doing the work.",
    },
  ];

  return (
    <section className="py-20 bg-gray-50">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <div className="inline-flex items-center gap-2 rounded-full bg-red-100 px-4 py-2 mb-6">
            <AlertTriangle className="h-4 w-4 text-red-600" />
            <span className="text-sm font-medium text-red-700">
              Sound Familiar?
            </span>
          </div>
          <h2 className="text-3xl sm:text-4xl font-bold text-foreground mb-6">
            Project Management Shouldn't Be This Hard
          </h2>
          <p className="text-lg text-gray-600">
            You've tried the "industry standard" tools. They're either too
            simple to be useful or too complex to actually use. Your team is
            frustrated, deadlines are missed, and you're left wondering if
            there's a better way.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {problems.map((problem, index) => (
            <div
              key={index}
              className="bg-white rounded-2xl p-8 shadow-lg shadow-gray-200/50 border border-gray-100"
            >
              <div className="h-12 w-12 rounded-xl bg-red-50 flex items-center justify-center mb-6">
                <problem.icon className="h-6 w-6 text-red-500" />
              </div>
              <h3 className="text-xl font-bold text-foreground mb-3">
                {problem.title}
              </h3>
              <p className="text-gray-600 leading-relaxed">
                {problem.description}
              </p>
            </div>
          ))}
        </div>

        {/* The cost */}
        <div className="mt-16 text-center">
          <p className="text-lg text-gray-600 mb-4">
            The real cost isn't just missed deadlines—it's{" "}
            <span className="font-semibold text-foreground">
              lost revenue, burned-out employees, and opportunities that slip
              away
            </span>
            .
          </p>
          <p className="text-xl font-bold text-primary">
            There is a better way.
          </p>
        </div>
      </div>
    </section>
  );
}

export { ProblemAgitation };
