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

interface AppSidebarProps extends React.ComponentProps<typeof Sidebar> {
  setActiveSection: (section: string) => void;
  activeSection: string;
}

function AppSidebar({
  setActiveSection,
  activeSection,
  ...props
}: AppSidebarProps) {
  const navMain = [
    {
      title: "dashboard",
      url: "#",
      icon: IconDashboard,
    },
    {
      title: "Users",
      url: "/users",
      icon: IconUsers,
    },
    {
      title: "Properties",
      url: "#",
      icon: IconHome,
    },
    {
      title: "Reports",
      url: "#",
      icon: IconReport,
    },
    {
      title: "Boosts",
      url: "#",
      icon: IconRocket,
    },
    {
      title: "Visit Requests",
      url: "#",
      icon: PlusSquareIcon,
    },
    {
      title: "Activity Monitoring",
      url: "#",
      icon: IconHistory,
    },
    {
      title: "chats",
      url: "/chat",
      icon: IconMessageCircle,
    },
    {
      title: "Manage Parameters",
      url: "/dashboard/manage-parameters",
      icon: IconFileAi,
    },
  ];

  return (
    <Sidebar collapsible="offcanvas" {...props}>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton
              asChild
              className="data-[slot=sidebar-menu-button]:!p-1.5"
            >
              <div>
                <Logo />
              </div>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>

      <SidebarContent>
        <NavMain
          items={navMain}
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