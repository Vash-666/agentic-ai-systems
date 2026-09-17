"use client";

import { CreditCard, FileText, Github, MessageSquare, Palette, Triangle } from "lucide-react";

function SocialProof() {
  const logos = [
    { name: "Stripe", icon: CreditCard },
    { name: "Notion", icon: FileText },
    { name: "Figma", icon: Palette },
    { name: "Slack", icon: MessageSquare },
    { name: "GitHub", icon: Github },
    { name: "Vercel", icon: Triangle },
  ];

  return (
    <section className="py-16 bg-white border-y border-gray-100">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <p className="text-center text-sm font-medium text-gray-500 uppercase tracking-wider mb-8">
          Trusted by innovative teams at
        </p>
        <div className="flex flex-wrap justify-center items-center gap-8 md:gap-16">
          {logos.map((logo) => {
            const Icon = logo.icon;
            return (
              <div
                key={logo.name}
                className="flex items-center gap-2 text-gray-400 hover:text-gray-600 transition-colors"
              >
                <Icon className="h-6 w-6" />
                <span className="text-lg font-semibold hidden sm:inline">
                  {logo.name}
                </span>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}

export { SocialProof };
