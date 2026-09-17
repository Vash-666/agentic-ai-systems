"use client";

import * as React from "react";
import { Container } from "@/components/layout/Container";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Textarea } from "@/components/ui/Textarea";
import { Card, CardContent } from "@/components/ui/Card";

function ContactForm() {
  const [formState, setFormState] = React.useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
    subject: "",
    message: "",
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle form submission
    console.log("Form submitted:", formState);
  };

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    setFormState((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
  };

  return (
    <Card>
      <CardContent className="p-6">
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <label htmlFor="firstName" className="text-sm font-medium text-navy-900">
                First Name *
              </label>
              <Input
                id="firstName"
                name="firstName"
                value={formState.firstName}
                onChange={handleChange}
                required
                placeholder="John"
              />
            </div>
            <div className="space-y-2">
              <label htmlFor="lastName" className="text-sm font-medium text-navy-900">
                Last Name *
              </label>
              <Input
                id="lastName"
                name="lastName"
                value={formState.lastName}
                onChange={handleChange}
                required
                placeholder="Doe"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <label htmlFor="email" className="text-sm font-medium text-navy-900">
                Email Address *
              </label>
              <Input
                id="email"
                name="email"
                type="email"
                value={formState.email}
                onChange={handleChange}
                required
                placeholder="john@example.com"
              />
            </div>
            <div className="space-y-2">
              <label htmlFor="phone" className="text-sm font-medium text-navy-900">
                Phone Number
              </label>
              <Input
                id="phone"
                name="phone"
                type="tel"
                value={formState.phone}
                onChange={handleChange}
                placeholder="(555) 123-4567"
              />
            </div>
          </div>

          <div className="space-y-2">
            <label htmlFor="subject" className="text-sm font-medium text-navy-900">
              Subject *
            </label>
            <Input
              id="subject"
              name="subject"
              value={formState.subject}
              onChange={handleChange}
              required
              placeholder="How can we help you?"
            />
          </div>

          <div className="space-y-2">
            <label htmlFor="message" className="text-sm font-medium text-navy-900">
              Message *
            </label>
            <Textarea
              id="message"
              name="message"
              value={formState.message}
              onChange={handleChange}
              required
              rows={5}
              placeholder="Please describe your legal matter..."
            />
          </div>

          <Button type="submit" className="w-full">
            Send Message
          </Button>

          <p className="text-xs text-charcoal-500 text-center">
            By submitting this form, you acknowledge that you have read and agree to our{" "}
            <a href="#" className="underline hover:text-navy-900">
              Privacy Policy
            </a>
            . This form does not create an attorney-client relationship.
          </p>
        </form>
      </CardContent>
    </Card>
  );
}

export { ContactForm };
