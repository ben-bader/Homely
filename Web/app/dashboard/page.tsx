"use client"

import { AppSidebar } from "@/components/app-sidebar"
import Boosts from "@/components/dashboard-componenets/Boosts"
import Dashboard from "@/components/dashboard-componenets/Dashboard"
import Properties from "@/components/dashboard-componenets/Properties"
import Reports from "@/components/dashboard-componenets/Reports"
import Team from "@/components/dashboard-componenets/VisitRequests"
import AuditLogs from "@/components/dashboard-componenets/AuditLogs"
import { SiteHeader } from "@/components/site-header"
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar"
import Users from "@/components/dashboard-componenets/Users"
import { useState } from "react"
import AdminDashboardWrapper from "@/components/dashboard-componenets/AdminDashboardWrapper"

export default function Page() {
  const [activeSection, setActiveSection] = useState("dashboard")
 
  const components: Record<string, React.ReactNode> = {
    users: <Users />,
    properties: <Properties />,
    reports: <Reports />,
    boosts: <Boosts />,
    team: <Team />,
    dashboard: <Dashboard />,
    "audit logs": <AuditLogs />,
  }
  
  
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
