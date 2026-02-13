  "use client"
  import { AppSidebar,data } from "@/components/app-sidebar"
  import { ChartAreaInteractive } from "@/components/chart-area-interactive"
import Boosts from "@/components/dashboard-componenets/Boosts"
import Properties from "@/components/dashboard-componenets/Properties"
import Reports from "@/components/dashboard-componenets/Reports"
import Team from "@/components/dashboard-componenets/Team"
  import { SiteHeader } from "@/components/site-header"
  import {
    SidebarInset,
    SidebarProvider,
  } from "@/components/ui/sidebar"
import Users from "@/components/dashboard-componenets/Users"
  import { api } from "@/lib/api"
  import { useState, useEffect } from "react"
import Dashboard from "@/components/dashboard-componenets/Dashboard"


  export default function Page() {
    

     const [activeSection, setActiveSection] = useState("dashboard")
const components: Record<string, React.ReactNode> = {
  users: <Users />,
  properties: <Properties />,
  reports: <Reports />,
  boosts: <Boosts />,
  team: <Team />,
  dashboard: <Dashboard/>
}
  
  
    return (

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
    )
  }
