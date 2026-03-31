"use client"

import { AppSidebar } from "@/components/dashboardComponents/app-sidebar"
import Boosts from "@/app/features/boosts/Boosts"
import Dashboard from "@/app/dashboard/Dashboard"
import Properties from "@/app/features/properties/Properties"
import Reports from "@/app/features/reports/Reports"
import ActivityMonitoring from "@/app/features/activityMonitoring/ActivityMonitoring"
import { SiteHeader } from "@/components/dashboardComponents/site-header"
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar"
import Users from "@/app/features/users/Users"
import { useState } from "react"
import AdminDashboardWrapper from "@/app/dashboard/AdminDashboardWrapper"
import VisitRequests from "@/app/features/visitRequests/VisitRequests"
import Profile from "@/app/features/profile/profile"
import Chat from "@/app/features/chats/Chat";
import ManageParameters from "@/app/features/ManageParametres/ManageParametres"

export default function Page() {
  const [activeSection, setActiveSection] = useState("dashboard")
  
  const components: Record<string, React.ReactNode> = {
  users: <Users />,
  properties: <Properties />,
  reports: <Reports />,
  boosts: <Boosts />,
  "visit requests": <VisitRequests />,
  dashboard: <Dashboard />,
  "activity monitoring": <ActivityMonitoring />,
  profile: <Profile />,
  chats: <Chat />,
  "manage parameters": <ManageParameters />,


};
  
  
    return (
      <AdminDashboardWrapper>

      <SidebarProvider
        style={
          {
            "--sidebar-width": "calc(var(--spacing) * 72)",
            "--header-height": "calc(var(--spacing) * 12)",
          } as React.CSSProperties
        }
        >
        <AppSidebar variant="inset" setActiveSection={setActiveSection} activeSection={activeSection}/>
        <SidebarInset>
          <SiteHeader />
          <div className="flex flex-1 flex-col">
            <div className="@container/main flex flex-1 flex-col gap-2">
              <div className="flex flex-col gap-4 py-4 md:gap-6 md:py-6"> 
                   {components[activeSection]}
              </div>
            </div>
          </div>
        </SidebarInset>
      </SidebarProvider>
        </AdminDashboardWrapper>
    )
  }
