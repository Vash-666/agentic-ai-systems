"use client";

import { CountUp } from "@/components/ui/CountUp";

function StatsBar() {
  const stats = [
    { value: 50000, suffix: "+", label: "Teams Using TaskFlow" },
    { value: 10, suffix: "M+", label: "Tasks Completed" },
    { value: 99.9, suffix: "%", label: "Uptime Guaranteed", decimals: 1 },
    { value: 4.9, suffix: "/5", label: "Average Rating", decimals: 1 },
  ];

  return (
    <section className="py-16 bg-primary">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-8">
          {stats.map((stat, index) => (
            <div key={index} className="text-center">
              <div className="text-4xl sm:text-5xl font-bold text-white mb-2">
                <CountUp
                  end={stat.value}
                  suffix={stat.suffix}
                  decimals={stat.decimals || 0}
                  duration={2000}
                />
              </div>
              <p className="text-primary-100 text-sm sm:text-base">
                {stat.label}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export { StatsBar };
