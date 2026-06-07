"use client";

import { Mail } from "lucide-react";
import { Card, CardContent } from "@/components/ui/Card";

interface TeamMemberData {
  id: string;
  name: string;
  title: string;
  specialty: string;
  bio: string;
  education: string[];
  recognitions: string[];
  email: string;
}

interface TeamMemberProps {
  member: TeamMemberData;
}

function TeamMember({ member }: TeamMemberProps) {
  return (
    <Card className="group h-full overflow-hidden">
      <div className="aspect-[3/4] bg-navy-100 relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-t from-navy-900/80 to-transparent" />
        <div className="absolute bottom-0 left-0 right-0 p-6 text-white">
          <h3 className="font-heading text-xl font-bold">{member.name}</h3>
          <p className="text-gold-400 font-medium">{member.title}</p>
          <p className="text-sm text-cream-200 mt-1">{member.specialty}</p>
        </div>
      </div>
      <CardContent className="p-6">
        <p className="text-charcoal-600 text-sm leading-relaxed mb-4">
          {member.bio}
        </p>
        
        <div className="space-y-3">
          <div>
            <h4 className="text-xs font-semibold uppercase tracking-wider text-navy-500 mb-1">
              Education
            </h4>
            <ul className="text-sm text-charcoal-600">
              {member.education.map((edu, index) => (
                <li key={index}>{edu}</li>
              ))}
            </ul>
          </div>
          
          <div>
            <h4 className="text-xs font-semibold uppercase tracking-wider text-navy-500 mb-1">
              Recognitions
            </h4>
            <ul className="text-sm text-charcoal-600">
              {member.recognitions.slice(0, 2).map((rec, index) => (
                <li key={index}>{rec}</li>
              ))}
            </ul>
          </div>
        </div>

        <div className="flex gap-3 mt-4 pt-4 border-t border-navy-100">
          <a
            href={`mailto:${member.email}`}
            className="p-2 text-navy-600 hover:text-gold-600 hover:bg-gold-50 rounded-full transition-colors"
          >
            <Mail className="h-4 w-4" />
          </a>
          <a
            href="#"
            className="p-2 text-navy-600 hover:text-gold-600 hover:bg-gold-50 rounded-full transition-colors"
          >
            <svg className="h-4 w-4" fill="currentColor" viewBox="0 0 24 24">
              <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
            </svg>
          </a>
        </div>
      </CardContent>
    </Card>
  );
}

export { TeamMember };
export type { TeamMemberData };
