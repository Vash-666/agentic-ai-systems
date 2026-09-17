import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-inter",
});

export const metadata: Metadata = {
  title: "TaskFlow Pro - Project Management That Actually Works",
  description: "Stop drowning in spreadsheets. The project management tool that helps teams ship faster, collaborate better, and hit every deadline.",
  keywords: ["project management", "team collaboration", "SaaS", "productivity", "task management"],
  openGraph: {
    title: "TaskFlow Pro - Project Management That Actually Works",
    description: "Stop drowning in spreadsheets. The project management tool that helps teams ship faster.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={inter.variable}>
      <body className="min-h-screen bg-white text-foreground">
        {children}
      </body>
    </html>
  );
}