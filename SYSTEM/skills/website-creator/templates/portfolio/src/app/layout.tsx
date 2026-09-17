import type { Metadata } from "next";
import { Inter, Playfair_Display } from "next/font/google";
import "./globals.css";

const inter = Inter({
  variable: "--font-sans",
  subsets: ["latin"],
  display: "swap",
});

const playfair = Playfair_Display({
  variable: "--font-display",
  subsets: ["latin"],
  display: "swap",
  weight: ["400", "500", "600", "700", "800", "900"],
});

export const metadata: Metadata = {
  title: {
    default: "Marcus Chen Photography | Visual Storyteller",
    template: "%s | Marcus Chen Photography",
  },
  description: "Award-winning photographer specializing in portraits, landscapes, and commercial photography. Based in San Francisco, available worldwide.",
  keywords: ["photography", "photographer", "portraits", "landscapes", "commercial photography", "San Francisco"],
  authors: [{ name: "Marcus Chen" }],
  openGraph: {
    type: "website",
    locale: "en_US",
    siteName: "Marcus Chen Photography",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${inter.variable} ${playfair.variable}`}>
      <body className="min-h-screen bg-background text-foreground font-sans">
        {children}
      </body>
    </html>
  );
}