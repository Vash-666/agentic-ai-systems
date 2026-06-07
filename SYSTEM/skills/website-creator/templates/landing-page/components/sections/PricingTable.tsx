"use client";

import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Check } from "lucide-react";
import { useState } from "react";

function PricingTable() {
  const [isYearly, setIsYearly] = useState(true);

  const plans = [
    {
      id: "starter",
      name: "Starter",
      description: "Perfect for small teams getting started",
      price: { monthly: 19, yearly: 15 },
      features: [
        "Up to 10 team members",
        "Unlimited projects",
        "Basic analytics",
        "Email support",
        "5GB storage",
        "Mobile app access",
      ],
      cta: "Start Free Trial",
      popular: false,
    },
    {
      id: "pro",
      name: "Professional",
      description: "For growing teams that need more power",
      price: { monthly: 49, yearly: 39 },
      features: [
        "Up to 50 team members",
        "Unlimited projects",
        "Advanced analytics & reports",
        "Priority support",
        "50GB storage",
        "Workflow automation",
        "Custom fields",
        "API access",
      ],
      cta: "Start Free Trial",
      popular: true,
    },
    {
      id: "enterprise",
      name: "Enterprise",
      description: "For large organizations with custom needs",
      price: { monthly: null, yearly: null },
      features: [
        "Unlimited team members",
        "Unlimited projects",
        "Custom analytics dashboards",
        "24/7 dedicated support",
        "Unlimited storage",
        "Advanced security & SSO",
        "Custom integrations",
        "Dedicated account manager",
        "SLA guarantee",
      ],
      cta: "Contact Sales",
      popular: false,
    },
  ];

  return (
    <section id="pricing" className="py-20 bg-gray-50">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-12">
          <h2 className="text-3xl sm:text-4xl font-bold text-foreground mb-6">
            Simple, Transparent Pricing
          </h2>
          <p className="text-lg text-gray-600 mb-8">
            Start free for 14 days. No credit card required. Cancel anytime.
          </p>

          {/* Billing toggle */}
          <div className="inline-flex items-center gap-4 bg-white rounded-full p-1.5 shadow-sm border border-gray-200">
            <button
              onClick={() => setIsYearly(false)}
              className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${
                !isYearly
                  ? "bg-primary text-white"
                  : "text-gray-600 hover:text-gray-900"
              }`}
            >
              Monthly
            </button>
            <button
              onClick={() => setIsYearly(true)}
              className={`px-4 py-2 rounded-full text-sm font-medium transition-all flex items-center gap-2 ${
                isYearly
                  ? "bg-primary text-white"
                  : "text-gray-600 hover:text-gray-900"
              }`}
            >
              Yearly
              <span
                className={`text-xs px-2 py-0.5 rounded-full ${
                  isYearly ? "bg-white/20" : "bg-success/10 text-success"
                }`}
              >
                Save 20%
              </span>
            </button>
          </div>
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {plans.map((plan) => (
            <Card
              key={plan.id}
              padding="none"
              className={`relative ${
                plan.popular
                  ? "ring-2 ring-primary shadow-xl shadow-primary/10"
                  : ""
              }`}
            >
              {plan.popular && (
                <div className="absolute -top-4 left-1/2 -translate-x-1/2">
                  <span className="bg-primary text-white text-sm font-semibold px-4 py-1.5 rounded-full">
                    Most Popular
                  </span>
                </div>
              )}

              <div className="p-8">
                <h3 className="text-xl font-bold text-foreground mb-2">
                  {plan.name}
                </h3>
                <p className="text-gray-600 text-sm mb-6">{plan.description}</p>

                <div className="mb-6">
                  {plan.price.monthly !== null ? (
                    <div className="flex items-baseline gap-1">
                      <span className="text-4xl font-bold text-foreground">
                        $
                        {isYearly
                          ? plan.price.yearly
                          : plan.price.monthly}
                      </span>
                      <span className="text-gray-500">/user/month</span>
                    </div>
                  ) : (
                    <div className="text-3xl font-bold text-foreground">
                      Custom
                    </div>
                  )}
                  {plan.price.monthly !== null && isYearly && (
                    <p className="text-sm text-gray-500 mt-1">
                      Billed annually (${
                        (plan.price.yearly || 0) * 12
                      }/user/year)
                    </p>
                  )}
                </div>

                <Button
                  variant={plan.popular ? "primary" : "outline"}
                  fullWidth
                  className="mb-8"
                >
                  {plan.cta}
                </Button>

                <ul className="space-y-3">
                  {plan.features.map((feature, index) => (
                    <li key={index} className="flex items-start gap-3">
                      <Check className="h-5 w-5 text-success shrink-0 mt-0.5" />
                      <span className="text-gray-700 text-sm">{feature}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </Card>
          ))}
        </div>

        {/* Guarantee */}
        <div className="mt-12 text-center">
          <p className="text-gray-600">
            <span className="font-semibold text-foreground">
              14-Day Money-Back Guarantee
            </span>{" "}
            — Not satisfied? Get a full refund, no questions asked.
          </p>
        </div>
      </div>
    </section>
  );
}

export { PricingTable };
