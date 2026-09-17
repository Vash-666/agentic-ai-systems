"use client";

import { Accordion } from "@/components/ui/Accordion";

function FAQAccordion() {
  const faqs = [
    {
      question: "How does the 14-day free trial work?",
      answer:
        "Start your trial instantly—no credit card required. You get full access to all Professional features for 14 days. At the end of your trial, choose a plan that works for you or continue with our free tier.",
    },
    {
      question: "Can I switch plans later?",
      answer:
        "Absolutely. You can upgrade, downgrade, or cancel your plan at any time. If you upgrade, you'll be charged the prorated difference. If you downgrade, you'll receive account credit for the difference.",
    },
    {
      question: "Is my data secure?",
      answer:
        "Security is our top priority. We use bank-level 256-bit encryption, SOC 2 Type II certified data centers, and regular third-party security audits. Your data is backed up in real-time across multiple geographic regions.",
    },
    {
      question: "Do you offer refunds?",
      answer:
        "Yes. We offer a 14-day money-back guarantee on all paid plans. If TaskFlow isn't the right fit, contact our support team within 14 days of your purchase for a full refund—no questions asked.",
    },
    {
      question: "Can I import data from other tools?",
      answer:
        "Yes! We offer one-click imports from Asana, Trello, Monday.com, Jira, and ClickUp. Our import wizard preserves your task history, attachments, and team assignments.",
    },
    {
      question: "What happens if I exceed my plan limits?",
      answer:
        "We'll notify you when you're approaching your limits. You can upgrade instantly or archive old projects to free up space. We never delete your data—you'll always have access to export it.",
    },
    {
      question: "Do you offer discounts for nonprofits or education?",
      answer:
        "Yes! We offer 50% off for registered nonprofits and free Professional plans for educational institutions. Contact our sales team with your organization details to apply.",
    },
  ];

  return (
    <section id="faq" className="py-20 bg-gray-50">
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-16">
          <h2 className="text-3xl sm:text-4xl font-bold text-foreground mb-6">
            Frequently Asked Questions
          </h2>
          <p className="text-lg text-gray-600">
            Everything you need to know about TaskFlow. Can't find what you're
            looking for? Contact our support team.
          </p>
        </div>

        <div className="bg-white rounded-2xl shadow-lg shadow-gray-200/50 p-6 sm:p-8">
          <Accordion items={faqs} />
        </div>

        {/* Contact CTA */}
        <div className="mt-12 text-center">
          <p className="text-gray-600 mb-4">Still have questions?</p>
          <a
            href="#"
            className="inline-flex items-center gap-2 text-primary font-semibold hover:underline"
          >
            Contact our support team
          </a>
        </div>
      </div>
    </section>
  );
}

export { FAQAccordion };
