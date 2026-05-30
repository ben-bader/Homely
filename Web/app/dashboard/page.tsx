"use client";

import React, { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import { SidebarProvider, SidebarInset } from "@/components/ui/sidebar";
import { AppSidebar } from "@/components/dashboardComponents/app-sidebar";
import { SiteHeader } from "@/components/dashboardComponents/site-header";

import Analytics from "@/app/analytics/Analytics";
import Users from "@/app/users/Users";
import Properties from "@/app/properties/Properties";
import Reports from "@/app/reports/Reports";
import Boosts from "@/app/boosts/Boosts";
import ActivityMonitoring from "@/app/activityMonitoring/ActivityMonitoring";
import VisitRequests from "@/app/visitRequests/VisitRequests";
import Profile from "@/app/profile/profile";
import Chat from "@/app/chats/Chat";
import ManageParameters from "@/app/ManageParametres/ManageParametres";
import AdminManager from "../AdminManager/AdminManager";

import { getUserFromToken, isAdmin } from "@/lib/auth";

export default function Page() {
  const t = useTranslations("common");
  const tSections = useTranslations("sections");
  const [activeSection, setActiveSection] = useState("analytics");
  const [permissions, setPermissions] = useState<Record<string, boolean>>({});
  const [isInitialized, setIsInitialized] = useState(false);

  const defaultAdminPermissions: Record<string, boolean> = {
    dashboard: true,
    users: true,
    properties: true,
    reports: true,
    boosts: true,
    visit_requests: true,
    activity_monitoring: true,
    chats: true,
    manage_parameters: true,
    manage_admins: true,
  };

  // ✅ Load permissions per user
  useEffect(() => {
    const user = getUserFromToken();
    if (!user) return;

    const stored = localStorage.getItem(`permissions_${user.id}`);

    if (stored) {
      try {
        setPermissions(JSON.parse(stored));
      } catch {
        setPermissions(isAdmin() ? defaultAdminPermissions : {});
      }
    } else if (isAdmin()) {
      localStorage.setItem(`permissions_${user.id}`, JSON.stringify(defaultAdminPermissions));
      setPermissions(defaultAdminPermissions);
    } else {
      setPermissions({});
    }
  }, []);

  // ✅ Parse section query param from URL on load for deep linking
  useEffect(() => {
    if (typeof window !== "undefined") {
      const params = new URLSearchParams(window.location.search);
      const sec = params.get("section");
      if (sec) {
        setActiveSection(sec);
      }
      setIsInitialized(true);
    }
  }, []);

  // ✅ Update URL search param whenever activeSection changes to prevent reset on page reload/refresh
  useEffect(() => {
    if (!isInitialized) return;
    if (typeof window !== "undefined") {
      const url = new URL(window.location.href);
      if (url.searchParams.get("section") !== activeSection) {
        url.searchParams.set("section", activeSection);
        window.history.replaceState(null, "", url.pathname + url.search);
      }
    }
  }, [activeSection, isInitialized]);

  // ✅ Dynamically update Chrome browser tab title based on active section
  useEffect(() => {
    if (typeof window !== "undefined") {
      const keyMap: Record<string, string> = {
        dashboard: "analytics",
        analytics: "analytics",
        users: "users",
        properties: "properties",
        reports: "reports",
        boosts: "boosts",
        "visit requests": "visitRequests",
        "activity monitoring": "activityMonitoring",
        "manage admins": "manageAdmins",
        chats: "chats",
        "manage parameters": "manageParameters",
        profile: "profile",
      };
      const key = keyMap[activeSection.toLowerCase()] || activeSection;
      let secTitle = "";
      try {
        secTitle = tSections(key);
      } catch {
        secTitle = activeSection.charAt(0).toUpperCase() + activeSection.slice(1);
      }
      document.title = `Homely | ${secTitle}`;
    }
  }, [activeSection, tSections]);

  // ❌ fallback UI
  function NoAccess() {
    return (
      <div className="p-6 text-center text-muted-foreground">
        {t("noAccess")}
      </div>
    );
  }

  // ✅ IMPORTANT FIX: only ONE component renders
  function renderSection() {
    switch (activeSection) {
      case "dashboard":
      case "analytics":
        return permissions.dashboard ? <Analytics /> : <NoAccess />;

      case "users":
        return permissions.users ? <Users /> : <NoAccess />;

      case "properties":
        return permissions.properties ? <Properties /> : <NoAccess />;

      case "reports":
        return permissions.reports ? <Reports /> : <NoAccess />;

      case "boosts":
        return permissions.boosts ? <Boosts /> : <NoAccess />;

      case "visit requests":
        return permissions.visit_requests ? <VisitRequests /> : <NoAccess />;

      case "activity monitoring":
        return permissions.activity_monitoring ? <ActivityMonitoring /> : <NoAccess />;

      case "manage admins":
        return permissions.manage_admins ? <AdminManager /> : <NoAccess />;

      case "chats":
        return permissions.chats ? <Chat /> : <NoAccess />;

      case "manage parameters":
        return permissions.manage_parameters ? <ManageParameters /> : <NoAccess />;

      case "profile":
        return <Profile />;

      default:
        return <NoAccess />;
    }
  }

  return (
    <SidebarProvider>
      <AppSidebar
        setActiveSection={setActiveSection}
        activeSection={activeSection}
      />

      <SidebarInset className="relative overflow-hidden bg-background">
        {/* Ambient Neon Volt Green Glowing Circles */}
        <div className="absolute top-[-10%] right-[-10%] w-[500px] h-[500px] rounded-full bg-primary/12 blur-[130px] pointer-events-none z-0" />
        <div className="absolute bottom-[-15%] left-[-10%] w-[600px] h-[600px] rounded-full bg-primary/8 blur-[160px] pointer-events-none z-0" />
        <div className="absolute top-[35%] left-[50%] -translate-x-1/2 w-[350px] h-[350px] rounded-full bg-primary/5 blur-[110px] pointer-events-none z-0" />

        <div className="relative z-10 flex flex-1 flex-col">
          <SiteHeader activeSection={activeSection} />

          <div className="flex flex-1 flex-col">
            <div 
              key={activeSection}
              className="flex flex-1 flex-col gap-4 py-4 md:py-6 animate-in fade-in slide-in-from-bottom-3 duration-500 ease-out fill-mode-forward"
            >
              {renderSection()}
            </div>
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  );
}