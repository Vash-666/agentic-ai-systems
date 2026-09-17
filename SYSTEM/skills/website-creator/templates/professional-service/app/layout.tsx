import type { Metadata } from "next";
import { Playfair_Display, Inter } from "next/font/google";
import "./globals.css";

const playfair = Playfair_Display({
  variable: "--font-heading",
  subsets: ["latin"],
  display: "swap",
});

const inter = Inter({
  variable: "--font-body",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "Sterling & Associates | Premier Legal Services",
    template: "%s | Sterling & Associates",
  },
  description: "Trusted legal counsel for businesses and individuals. Over 25 years of excellence in corporate law, litigation, and estate planning.",
  keywords: ["law firm", "legal services", "corporate law", "litigation", "estate planning", "attorneys"],
  robots: {
    index: true,
    follow: true,
  },
  openGraph: {
    type: "website",
    locale: "en_US",
    siteName: "Sterling & Associates",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${playfair.variable} ${inter.variable} antialiased`}>
      <body className="min-h-screen flex flex-col bg-cream-50 text-charcoal-900">
        {children}
      </body>
    </html>
  );
}