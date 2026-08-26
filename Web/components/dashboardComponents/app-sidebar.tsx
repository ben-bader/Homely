"use client";

import React, { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import {
  Activity,
  BarChart3,
  Building2,
  CalendarCheck,
  ChevronRight,
  Flag,
  Menu,
  MessageCircle,
  Rocket,
  Settings,
  ShieldCheck,
  Users,
} from "lucide-react";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import Logo from "@/components/logo/Logo";
import { NavUser } from "./nav-user";
import { getUserFromToken, isAdmin } from "@/lib/auth";
import { cn } from "@/lib/utils";
import { useIsMobile } from "@/hooks/use-mobile";

type NavGroup = {
  label: string;
  items: NavItem[];
};

type NavItem = {
  id: string;
  section: string;
  icon: React.ElementType;
  permissionKey?: string;
};

const NAV_GROUPS: NavGroup[] = [
  {
    label: "Overview",
    items: [
      { id: "analytics", section: "analytics", icon: BarChart3, permissionKey: "dashboard" },
    ],
  },
  {
    label: "Marketplace",
    items: [
      { id: "properties", section: "properties", icon: Building2, permissionKey: "properties" },
      { id: "visit-requests", section: "visit requests", icon: CalendarCheck, permissionKey: "visit_requests" },
    ],
  },
  {
    label: "Users",
    items: [
      { id: "users", section: "users", icon: Users, permissionKey: "users" },
      { id: "manage-admins", section: "manage admins", icon: ShieldCheck, permissionKey: "manage_admins" },
    ],
  },
  {
    label: "Communications",
    items: [
      { id: "chats", section: "chats", icon: MessageCircle, permissionKey: "chats" },
      { id: "reports", section: "reports", icon: Flag, permissionKey: "reports" },
    ],
  },
  {
    label: "Revenue",
    items: [
      { id: "boosts", section: "boosts", icon: Rocket, permissionKey: "boosts" },
    ],
  },
  {
    label: "Operations",
    items: [
      { id: "activity-monitoring", section: "activity monitoring", icon: Activity, permissionKey: "activity_monitoring" },
      { id: "manage-parameters", section: "manage parameters", icon: Settings, permissionKey: "manage_parameters" },
    ],
  },
];

function SidebarContent({
  activeSection,
  onSectionChange,
  permissions,
  mobile = false,
}: {
  activeSection: string;
  onSectionChange: (section: string) => void;
  permissions: Record<string, boolean>;
  mobile?: boolean;
}) {
  const tSections = useTranslations("sections");

  const sectionLabel: Record<string, string> = {
    analytics: tSections("analytics"),
    properties: tSections("properties"),
    "visit requests": tSections("visitRequests"),
    users: tSections("users"),
    "manage admins": tSections("manageAdmins"),
    chats: tSections("chats"),
    reports: tSections("reports"),
    boosts: tSections("boosts"),
    "activity monitoring": tSections("activityMonitoring"),
    "manage parameters": tSections("manageParameters"),
  };

  return (
    <div className={cn("flex h-full flex-col bg-sidebar", mobile ? "w-72 p-4" : "w-64 pl-4 py-5")}>
      <div className="mb-7 flex flex-col items-center gap-3 px-2 ">
        <div className="flex w-full items-center justify-center">
          <Logo imageClassName="h-16 -my-4 w-full object-contain" />
        </div>
        <div className="flex items-center">
          <span className="block text-xs -mt-2 text-foreground">Admin Monitoring Platform</span>
        </div>
      </div>

      <nav className="flex flex-1 flex-col gap-5 overflow-y-auto pr-2">
        {NAV_GROUPS.map((group, groupIndex) => {
          const visibleItems = group.items.filter(
            (item) => !item.permissionKey || permissions[item.permissionKey]
          );

          if (visibleItems.length === 0) return null;

          return (
            <div key={group.label} className={cn(groupIndex > 0 && "border-t border-sidebar-border pt-5")}>
              <p className="mb-2 px-2 text-[11px] font-medium uppercase tracking-wide text-sidebar-foreground/70">
                {group.label}
              </p>
              <div className="space-y-1">
                {visibleItems.map((item) => {
                  const label = sectionLabel[item.section] || item.section;
                  const active = activeSection === item.section;
                  const Icon = item.icon;

                  return (
                    <button
                      key={item.id}
                      onClick={() => onSectionChange(item.section)}
                      className={cn(
                        "flex w-full items-center gap-3 rounded-lg px-3 py-2 text-sm transition-colors",
                        active
                          ? "bg-sidebar-primary text-sidebar-primary-foreground font-medium"
                          : "text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
                      )}
                    >
                      <Icon className="h-4 w-4 flex-shrink-0" strokeWidth={active ? 2.25 : 2} />
                      <span className="truncate">{label}</span>
                      {active && <ChevronRight className="ml-auto h-3.5 w-3.5 text-sidebar-primary-foreground/60" />}
                    </button>
                  );
                })}
              </div>
            </div>
          );
        })}
      </nav>

      <div className="mt-5 border-t border-sidebar-border pt-4">
        <NavUser setActiveSection={onSectionChange} />
      </div>
    </div>
  );
}

export function AppSidebar({
  setActiveSection,
  activeSection,
}: {
  setActiveSection: (section: string) => void;
  activeSection: string;
}) {
  const isMobile = useIsMobile();
  const [permissions, setPermissions] = useState<Record<string, boolean>>({});
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    const user = getUserFromToken();
    if (!user) return;

    const stored = localStorage.getItem(`permissions_${user.id}`);
    if (stored) {
      try {
        setPermissions(JSON.parse(stored));
        return;
      } catch {
        // Fall through to admin defaults when stored permissions are malformed.
      }
    }

    if (isAdmin()) {
      const defaults = {
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
      localStorage.setItem(`permissions_${user.id}`, JSON.stringify(defaults));
      setPermissions(defaults);
    }
  }, []);

  const handleChange = (section: string) => {
    setActiveSection(section);
    setMobileOpen(false);
  };

  if (isMobile) {
    return (
      <Sheet open={mobileOpen} onOpenChange={setMobileOpen}>
        <SheetTrigger asChild>
          <Button variant="outline" size="icon" className="fixed left-4 top-4 z-50 bg-white">
            <Menu className="h-4 w-4" />
          </Button>
        </SheetTrigger>
        <SheetContent side="left" className="w-72 border-sidebar-border bg-sidebar p-0">
          <SidebarContent
            activeSection={activeSection}
            onSectionChange={handleChange}
            permissions={permissions}
            mobile
          />
        </SheetContent>
      </Sheet>
    );
  }

  return (
    <aside className="fixed left-0 top-0 z-40 h-screen w-64 border-r border-sidebar-border bg-sidebar">
      <SidebarContent
        activeSection={activeSection}
        onSectionChange={handleChange}
        permissions={permissions}
      />
    </aside>
  );
}
