"use client";

import React, { useEffect, useState } from "react";
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
  const [activeSection, setActiveSection] = useState("analytics");
  const [permissions, setPermissions] = useState<Record<string, boolean>>({});

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
    }
  }, []);

  // ❌ fallback UI
  function NoAccess() {
    return (
      <div className="p-6 text-center text-muted-foreground">
        You don’t have permission to access this section
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

      <SidebarInset>
        <SiteHeader />

        <div className="flex flex-1 flex-col">
          <div className="flex flex-col gap-4 py-4 md:py-6">
            {renderSection()}
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>
  );
}