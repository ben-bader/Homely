"use client";

import * as React from "react";
import {
  IconDashboard,
  IconHome,
  IconReport,
  IconRocket,
  IconUsers,
  IconHistory,
  IconMessageCircle,
  IconFileAi,
} from "@tabler/icons-react";

import { NavMain } from "@/components/dashboardComponents/nav-main";
import { NavUser } from "@/components/dashboardComponents/nav-user";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";

import Logo from "../logo/Logo";
import { PlusSquareIcon } from "lucide-react";
import { getUserFromToken, isAdmin } from "@/lib/auth";

interface AppSidebarProps extends React.ComponentProps<typeof Sidebar> {
  setActiveSection: (section: string) => void;
  activeSection: string;
}

function AppSidebar({
  setActiveSection,
  activeSection,
  ...props
}: AppSidebarProps) {

  const [permissions, setPermissions] = React.useState<Record<string, boolean> | null>(null);

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

  // ✅ Load permissions safely
  React.useEffect(() => {
    const user = getUserFromToken();
    if (!user) {
      setPermissions({});
      return;
    }

    const stored = localStorage.getItem(`permissions_${user.id}`);

    if (!stored) {
      if (isAdmin()) {
        localStorage.setItem(`permissions_${user.id}`, JSON.stringify(defaultAdminPermissions));
        setPermissions(defaultAdminPermissions);
        return;
      }
      setPermissions({});
      return;
    }

    try {
      const parsed = JSON.parse(stored);
      const flat = parsed?.dashboard !== undefined ? parsed : parsed?.DEFAULT_ADMIN || {};
      setPermissions(flat);
    } catch {
      setPermissions(isAdmin() ? defaultAdminPermissions : {});
    }
  }, []);

  if (!permissions) {
    return <div className="p-3 text-sm text-muted-foreground">Loading sidebar...</div>;
  }

  // 🔑 map section IDs → permission keys
  const permissionKeys: Record<string, string> = {
    analytics: "dashboard",
    users: "users",
    properties: "properties",
    reports: "reports",
    boosts: "boosts",
    "visit requests": "visit_requests",
    "activity monitoring": "activity_monitoring",
    chats: "chats",
    "manage parameters": "manage_parameters",
    "manage admins": "manage_admins",
  };

  const navMain = [
    { id: "analytics", titleKey: "analytics", url: "#", icon: IconDashboard },
    { id: "users", titleKey: "users", url: "/users", icon: IconUsers },
    { id: "properties", titleKey: "properties", url: "#", icon: IconHome },
    { id: "reports", titleKey: "reports", url: "#", icon: IconReport },
    { id: "boosts", titleKey: "boosts", url: "#", icon: IconRocket },
    { id: "visit requests", titleKey: "visitRequests", url: "#", icon: PlusSquareIcon },
    { id: "activity monitoring", titleKey: "activityMonitoring", url: "#", icon: IconHistory },
    { id: "chats", titleKey: "chats", url: "#", icon: IconMessageCircle },
    { id: "manage parameters", titleKey: "manageParameters", url: "#", icon: IconFileAi },
    { id: "manage admins", titleKey: "manageAdmins", url: "#", icon: IconUsers },
  ];

  // ✅ SAFE FILTER (NO BUGS EVER)
  const filteredNavMain = navMain.filter((item) => {
    const key = permissionKeys[item.id];

    if (!key) return true;

    return permissions?.[key] === true;
  });

  return (
    <Sidebar
      collapsible="offcanvas"
      className="[--sidebar-width:230px] bg-sidebar text-sidebar-foreground border-r-2 border-primary/20 shadow-[12px_0_40px_-10px_rgba(15,23,42,0.35)] transition-all duration-500 ease-in-out"
      {...props}
    >
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton asChild>
              <div className="flex justify-center items-center w-full scale-90">
                <Logo variant="white" />
              </div>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>

      <SidebarContent>
        <NavMain
          items={filteredNavMain}
          setActiveSection={setActiveSection}
          activeSection={activeSection}
        />
      </SidebarContent>

      <SidebarFooter>
        <NavUser setActiveSection={setActiveSection} />
      </SidebarFooter>
    </Sidebar>
  );
}

export { AppSidebar };