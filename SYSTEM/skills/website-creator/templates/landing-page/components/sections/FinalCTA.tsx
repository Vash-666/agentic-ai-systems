"use client";

import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { ArrowRight, CheckCircle, Sparkles } from "lucide-react";
import { useState } from "react";

function FinalCTA() {
  const [email, setEmail] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log("Email captured:", email);
  };

  const benefits = [
    "14-day free trial",
    "No credit card required",
    "Cancel anytime",
  ];

  return (
    <section className="py-20 bg-primary relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute inset-0 -z-10">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-white/5 rounded-full blur-3xl" />
        <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-white/5 rounded-full blur-3xl" />
      </div>

      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8 text-center">
        <div className="inline-flex items-center gap-2 rounded-full bg-white/10 px-4 py-2 mb-8">
          <Sparkles className="h-4 w-4 text-white" />
          <span className="text-sm font-medium text-white">
            Join 50,000+ teams already using TaskFlow
          </span>
        </div>

        <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold text-white mb-6">
          Ready to Ship Faster?
        </h2>

        <p className="text-lg sm:text-xl text-primary-100 mb-8 max-w-2xl mx-auto">
          Start your free trial today. No credit card required. Experience the
          project management tool that actually works.
        </p>

        {/* Email capture form */}
        <form
          onSubmit={handleSubmit}
          className="flex flex-col sm:flex-row gap-3 max-w-lg mx-auto mb-8"
        >
          <Input
            type="email"
            placeholder="Enter your work email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            className="flex-1 bg-white/10 border-white/20 text-white placeholder:text-white/60 focus:bg-white/20"
            required
          />
          <Button
            type="submit"
            variant="white"
            size="lg"
            className="whitespace-nowrap"
          >
            Start Free Trial
            <ArrowRight className="h-4 w-4" />
          </Button>
        </form>

        {/* Trust badges */}
        <div className="flex flex-wrap justify-center gap-6">
          {benefits.map((benefit, index) => (
            <div key={index} className="flex items-center gap-2 text-white/80">
              <CheckCircle className="h-5 w-5" />
              <span className="text-sm">{benefit}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

export { FinalCTA };
