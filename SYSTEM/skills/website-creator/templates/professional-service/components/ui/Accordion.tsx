"use client";

import * as React from "react";
import { ChevronDown } from "lucide-react";
import { cn } from "@/lib/utils";

interface AccordionItem {
  question: string;
  answer: string;
}

interface AccordionProps {
  items: AccordionItem[];
  className?: string;
}

function Accordion({ items, className }: AccordionProps) {
  const [openIndex, setOpenIndex] = React.useState<number | null>(null);

  const toggleItem = (index: number) => {
    setOpenIndex(openIndex === index ? null : index);
  };

  return (
    <div className={cn("space-y-4", className)}>
      {items.map((item, index) => (
        <div
          key={index}
          className="border border-navy-100 rounded-lg bg-white overflow-hidden"
        >
          <button
            onClick={() => toggleItem(index)}
            className="flex w-full items-center justify-between p-4 text-left font-heading font-semibold text-navy-900 hover:bg-navy-50 transition-colors"
          >
            <span>{item.question}</span>
            <ChevronDown
              className={cn(
                "h-5 w-5 text-gold-500 transition-transform duration-200",
                openIndex === index && "rotate-180"
              )}
            />
          </button>
          <div
            className={cn(
              "overflow-hidden transition-all duration-200",
              openIndex === index ? "max-h-96" : "max-h-0"
            )}
          >
            <div className="p-4 pt-0 text-charcoal-600 leading-relaxed">
              {item.answer}
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

export { Accordion };
export type { AccordionItem };
