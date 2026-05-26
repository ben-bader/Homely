"use client";

import React, { useEffect, useState } from "react";
import { SidebarProvider, SidebarInset } from "@/components/ui/sidebar";
import { AppSidebar } from "@/components/dashboardComponents/app-sidebar";
import { SiteHeader } from "@/components/dashboardComponents/site-header";
import Analytics from "./Analytics";
import { useRouter } from "next/navigation";
import { getUserFromToken, isAdmin } from "@/lib/auth";

export default function AnalyticsPage() {
  const router = useRouter();
  const [authorized, setAuthorized] = useState(false);

  useEffect(() => {
    const user = getUserFromToken();
    if (!user || !isAdmin()) {
      router.replace("/");
    } else {
      setAuthorized(true);
    }
  }, [router]);

  if (!authorized) {
    return (
      <div className="flex h-screen items-center justify-center text-sm text-muted-foreground">
        Checking admin authentication status...
      </div>
    );
  }

  return (
    <SidebarProvider>
      <AppSidebar
        setActiveSection={(sec) => {
          // Seamlessly redirect to the main SPA dashboard with the chosen section
          router.push(`/dashboard?section=${encodeURIComponent(sec)}`);
        }}
        activeSection="analytics"
      />

      <SidebarInset>
        <SiteHeader />

        <div className="flex flex-1 flex-col">
          <div className="flex flex-col gap-4 py-4 md:py-6">
            <Analytics />
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  );
}
