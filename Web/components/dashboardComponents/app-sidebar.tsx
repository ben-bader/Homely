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
import { getUserFromToken } from "@/lib/auth";

interface AppSidebarProps extends React.ComponentProps<typeof Sidebar> {
  setActiveSection: (section: string) => void;
  activeSection: string;
}

function AppSidebar({
  setActiveSection,
  activeSection,
  ...props
}: AppSidebarProps) {
  const user = getUserFromToken();

  // ✅ SAFE STATE (no localStorage in render)
  const [permissions, setPermissions] = React.useState<Record<string, boolean>>({});

  // ✅ LOAD PERMISSIONS SAFELY
  React.useEffect(() => {
    const stored = localStorage.getItem("permissions");

    if (stored) {
      try {
        setPermissions(JSON.parse(stored));
      } catch {
        setPermissions({});
      }
    }
  }, []);

  const permissionKeys: Record<string, string> = {
    dashboard: "dashboard",
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
    { title: "dashboard", url: "#", icon: IconDashboard },
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

  // ✅ STRICT PERMISSION FILTER (no undefined bugs)
  const filteredNavMain = navMain.filter((item) => {
    const key = permissionKeys[item.title];

    if (!key) return true; // no permission rule = allow

    return permissions[key] === true; // ONLY allow true
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
            <SidebarMenuButton
              asChild
              className="data-[slot=sidebar-menu-button]:!p-1"
            >
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