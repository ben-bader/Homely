import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { NextIntlClientProvider } from "next-intl"; // ✅ added
import { getMessages, setRequestLocale } from "next-intl/server";     // ✅ added
import { AppInitializer } from "@/components/AppInitializer"; // ✅ Auth init
import { AuthProvider } from "@/lib/auth-context"; // ✅ Auth context
import { cookies } from "next/headers"; // ✅ read cookie for locale
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Homely Admin Portal",
  description: "Homely admin dashboard and property moderation portal",
};

// ✅ made async (required to load messages)
export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const cookieStore = await cookies();
  const locale = cookieStore.get("locale")?.value === "fr" ? "fr" : "en";
  setRequestLocale(locale); // ✅ added
  const messages = await getMessages(); // ✅ added

  return (
    <html lang={locale}>
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {/* ✅ Initialize auth on app startup */}
        <AppInitializer />
        
        {/* ✅ Provide auth context */}
        <AuthProvider>
          {/* ✅ wrapped children ONLY */}
          <NextIntlClientProvider locale={locale} messages={messages}>
            {children}
          </NextIntlClientProvider>
        </AuthProvider>
      </body>
    </html>
  );
}