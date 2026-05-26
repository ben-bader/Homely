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

  // 🔑 map UI labels → permission keys
  const permissionKeys: Record<string, string> = {
    Analytics: "dashboard",
    Users: "users",
    Properties: "properties",
    Reports: "reports",
    Boosts: "boosts",
    "Visit Requests": "visit_requests",
    "Activity Monitoring": "activity_monitoring",
    chats: "chats",
    "Manage Parameters": "manage_parameters",
    "Manage admins": "manage_admins",
  };

  const navMain = [
    { title: "Analytics", url: "#", icon: IconDashboard },
    { title: "Users", url: "/users", icon: IconUsers },
    { title: "Properties", url: "#", icon: IconHome },
    { title: "Reports", url: "#", icon: IconReport },
    { title: "Boosts", url: "#", icon: IconRocket },
    { title: "Visit Requests", url: "#", icon: PlusSquareIcon },
    { title: "Activity Monitoring", url: "#", icon: IconHistory },
    { title: "chats", url: "#", icon: IconMessageCircle },
    { title: "Manage Parameters", url: "#", icon: IconFileAi },
    { title: "Manage admins", url: "#", icon: IconUsers },
  ];

  // ✅ SAFE FILTER (NO BUGS EVER)
  const filteredNavMain = navMain.filter((item) => {
    const key = permissionKeys[item.title];

    if (!key) return true;

    return permissions?.[key] === true;
  });

  return (
    <Sidebar
      collapsible="offcanvas"
      className="[--sidebar-width:200px]"
      {...props}
    >
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton asChild>
              <div className="scale-90 origin-left">
                <Logo />
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