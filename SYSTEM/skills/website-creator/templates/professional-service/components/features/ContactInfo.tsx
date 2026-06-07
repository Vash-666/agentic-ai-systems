import { Phone, Mail, MapPin, Clock } from "lucide-react";
import business from "@/content/data/business.json";

function ContactInfo() {
  return (
    <div className="space-y-6">
      <div className="flex items-start gap-4">
        <div className="p-3 bg-navy-50 rounded-lg">
          <MapPin className="h-5 w-5 text-navy-700" />
        </div>
        <div>
          <h3 className="font-heading font-semibold text-navy-900">Address</h3>
          <p className="text-charcoal-600">
            {business.address.street}
            <br />
            {business.address.city}, {business.address.state} {business.address.zip}
          </p>
        </div>
      </div>

      <div className="flex items-start gap-4">
        <div className="p-3 bg-navy-50 rounded-lg">
          <Phone className="h-5 w-5 text-navy-700" />
        </div>
        <div>
          <h3 className="font-heading font-semibold text-navy-900">Phone</h3>
          <a
            href={`tel:${business.phone}`}
            className="text-charcoal-600 hover:text-navy-900"
          >
            {business.phone}
          </a>
        </div>
      </div>

      <div className="flex items-start gap-4">
        <div className="p-3 bg-navy-50 rounded-lg">
          <Mail className="h-5 w-5 text-navy-700" />
        </div>
        <div>
          <h3 className="font-heading font-semibold text-navy-900">Email</h3>
          <a
            href={`mailto:${business.email}`}
            className="text-charcoal-600 hover:text-navy-900"
          >
            {business.email}
          </a>
        </div>
      </div>

      <div className="flex items-start gap-4">
        <div className="p-3 bg-navy-50 rounded-lg">
          <Clock className="h-5 w-5 text-navy-700" />
        </div>
        <div>
          <h3 className="font-heading font-semibold text-navy-900">Office Hours</h3>
          <ul className="text-sm text-charcoal-600 space-y-1">
            {Object.entries(business.hours).map(([day, hours]) => (
              <li key={day} className="flex justify-between gap-8">
                <span>{day}:</span>
                <span>{hours}</span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}

export { ContactInfo };
