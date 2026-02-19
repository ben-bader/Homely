"use client";

import * as React from "react";
import {
  IconArrowUp,
  IconCamera,
  IconChartBar,
  IconDashboard,
  IconDatabase,
  IconFileAi,
  IconFileDescription,
  IconFileWord,
  IconFolder,
  IconHelp,
  IconHome,
  IconInnerShadowTop,
  IconListDetails,
  IconReport,
  IconRocket,
  IconSearch,
  IconSettings,
  IconUser,
  IconUsers,
  IconHistory,
} from "@tabler/icons-react";

import { NavDocuments } from "@/components/nav-documents";
import { NavMain } from "@/components/nav-main";
import { NavSecondary } from "@/components/nav-secondary";
import { NavUser } from "@/components/nav-user";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import Logo from "./logo/Logo";
import { BetweenVerticalStartIcon, PlusSquareIcon } from "lucide-react";

const data = {
  user: {
    name: "shadcn",
    email: "m@example.com",
    avatar: "/avatars/shadcn.jpg",
  },
  navMain: [
    {
      title: "dashboard",
      url: "#",
      icon: IconDashboard
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
      title: "Audit Logs",
      url: "#",
      icon: IconHistory,
    },
  ],
};
function AppSidebar(
  { setActiveSection, activeSection, ...props }: React.ComponentProps<typeof Sidebar> & {
    setActiveSection: (section: string) => void,
    activeSection: string
  }
) {
  return (
    <Sidebar collapsible="offcanvas" {...props}>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton
              asChild
              className="data-[slot=sidebar-menu-button]:!p-1.5"
            >
              <div className="">
                <Logo />
              </div>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        <NavMain items={data.navMain} setActiveSection={setActiveSection} activeSection={activeSection} />
      </SidebarContent>
      <SidebarFooter>
        <SidebarFooter>
          <NavUser setActiveSection={setActiveSection} />
        </SidebarFooter>

      </SidebarFooter>
    </Sidebar>
  );
}
export { data, AppSidebar };