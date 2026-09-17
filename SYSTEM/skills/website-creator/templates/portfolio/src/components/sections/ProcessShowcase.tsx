import { Container } from "@/components/layout/Container";

interface ProcessStep {
  step: number;
  title: string;
  description: string;
}

interface ProcessShowcaseProps {
  steps: ProcessStep[];
  title?: string;
  subtitle?: string;
}

export function ProcessShowcase({
  steps,
  title = "My Process",
  subtitle = "A collaborative approach to creating images that tell your story.",
}: ProcessShowcaseProps) {
  return (
    <section className="py-24 bg-background">
      <Container>
        <div className="text-center mb-16">
          <h2 className="font-display text-3xl sm:text-4xl font-bold mb-4">
            {title}
          </h2>
          <p className="text-foreground/60 max-w-2xl mx-auto">{subtitle}</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-5 gap-8">
          {steps.map((step, index) => (
            <div key={step.step} className="relative">
              {index < steps.length - 1 && (
                <div className="hidden md:block absolute top-8 left-[60%] w-[80%] h-px bg-gradient-to-r from-accent/50 to-transparent" />
              )}
              <div className="flex flex-col items-center text-center">
                <div className="w-16 h-16 rounded-full bg-accent/10 border border-accent/30 flex items-center justify-center mb-4">
                  <span className="font-display text-2xl font-bold text-accent">
                    {step.step}
                  </span>
                </div>
                <h3 className="font-display text-lg font-semibold mb-2">
                  {step.title}
                </h3>
                <p className="text-sm text-foreground/60">{step.description}</p>
              </div>
            </div>
          ))}
        </div>
      </Container>
    </section>
  );
}