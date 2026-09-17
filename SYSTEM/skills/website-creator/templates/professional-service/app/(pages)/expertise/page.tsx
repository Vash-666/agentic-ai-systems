import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { Container } from "@/components/layout/Container";
import { CTABanner } from "@/components/sections/CTABanner";
import { TeamMember } from "@/components/features/TeamMember";
import { Award, BookOpen, Briefcase } from "lucide-react";
import teamData from "@/content/data/team.json";

export const metadata = {
  title: "Our Attorneys",
  description: "Meet our team of experienced attorneys dedicated to providing exceptional legal counsel.",
};

export default function ExpertisePage() {
  const { members } = teamData;

  return (
    <>
      <Header />
      <main className="flex-1">
        {/* Hero Section */}
        <section className="bg-navy-900 py-20">
          <Container>
            <div className="max-w-3xl mx-auto text-center">
              <h1 className="font-heading text-4xl md:text-5xl font-bold text-white mb-6">
                Our Attorneys
              </h1>
              <p className="text-lg text-cream-200">
                A team of distinguished legal professionals committed to excellence 
                in every matter we handle.
              </p>
            </div>
          </Container>
        </section>

        {/* Team Grid */}
        <section className="py-20 bg-cream-50">
          <Container>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {members.map((member) => (
                <TeamMember key={member.id} member={member} />
              ))}
            </div>
          </Container>
        </section>

        {/* Expertise Highlights */}
        <section className="py-20 bg-white">
          <Container>
            <div className="text-center max-w-2xl mx-auto mb-12">
              <p className="text-gold-600 font-medium mb-2 uppercase tracking-wide text-sm">
                Why Choose Us
              </p>
              <h2 className="font-heading text-3xl font-bold text-navy-900 mb-4">
                The Sterling Difference
              </h2>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              <div className="text-center p-6">
                <div className="w-16 h-16 bg-navy-50 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Award className="h-8 w-8 text-navy-700" />
                </div>
                <h3 className="font-heading text-xl font-semibold text-navy-900 mb-3">
                  Recognized Excellence
                </h3>
                <p className="text-charcoal-600">
                  Our attorneys are consistently recognized by Best Lawyers, Super Lawyers, 
                  and Chambers USA for their exceptional legal skills.
                </p>
              </div>
              <div className="text-center p-6">
                <div className="w-16 h-16 bg-gold-50 rounded-full flex items-center justify-center mx-auto mb-4">
                  <BookOpen className="h-8 w-8 text-gold-700" />
                </div>
                <h3 className="font-heading text-xl font-semibold text-navy-900 mb-3">
                  Academic Excellence
                </h3>
                <p className="text-charcoal-600">
                  Our team includes graduates from the nation's top law schools, 
                  bringing rigorous analytical skills to every matter.
                </p>
              </div>
              <div className="text-center p-6">
                <div className="w-16 h-16 bg-sage-50 rounded-full flex items-center justify-center mx-auto mb-4">
                  <Briefcase className="h-8 w-8 text-sage-700" />
                </div>
                <h3 className="font-heading text-xl font-semibold text-navy-900 mb-3">
                  Industry Experience
                </h3>
                <p className="text-charcoal-600">
                  Decades of combined experience across diverse industries 
                  enable us to understand your unique business challenges.
                </p>
              </div>
            </div>
          </Container>
        </section>

        <CTABanner />
      </main>
      <Footer />
    </>
  );
}
