"use client";

import React, { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
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
import { useIsMobile } from "@/hooks/use-mobile";

export default function Page() {
  const t = useTranslations("common");
  const tSections = useTranslations("sections");
  const isMobile = useIsMobile();
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

  // Load permissions per user
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

  // Parse section from URL on load
  useEffect(() => {
    if (typeof window !== "undefined") {
      const params = new URLSearchParams(window.location.search);
      const sec = params.get("section");
      if (sec) setActiveSection(sec);
      setIsInitialized(true);
    }
  }, []);

  // Sync URL param on section change
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

  // Update browser tab title
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

  function NoAccess() {
    return (
      <div className="flex items-center justify-center h-64 text-sm text-muted-foreground">
        {t("noAccess")}
      </div>
    );
  }

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
    <div className="flex h-screen overflow-hidden bg-background">
      {/* Navigation Rail */}
      <AppSidebar
        setActiveSection={setActiveSection}
        activeSection={activeSection}
      />

      {/* Main content area — offset by rail width (56px) on desktop */}
      <div className={`flex-1 flex flex-col overflow-hidden ${isMobile ? "" : "ml-64"}`}>
        <SiteHeader activeSection={activeSection} />
        <main className="flex-1 overflow-y-auto">
          <div
            key={activeSection}
            className="min-h-full"
          >
            {renderSection()}
          </div>
        </main>
      </div>
    </div>
  );
}
