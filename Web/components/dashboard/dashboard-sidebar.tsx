"use client"

import * as React from "react"
import { useState, useEffect } from "react"
import {
  Activity,
  BarChart3,
  Building2,
  Home,
  MessageCircle,
  Rocket,
  Settings,
  ShieldAlert,
  UserCog,
  Users,
} from "lucide-react"

import { cn } from "@/lib/utils"
import { getUserFromToken } from "@/lib/auth"

type DashboardSidebarProps = {
  activeSection: string
  onSectionChange: (section: string) => void
}

const groups = [
  {
    label: "Overview",
    items: [
      { id: "dashboard", label: "Dashboard", icon: Home },
      { id: "analytics", label: "Analytics", icon: BarChart3 },
    ],
  },
  {
    label: "Marketplace",
    items: [
      { id: "properties", label: "Properties", icon: Building2 },
      { id: "visit requests", label: "Visits", icon: Activity },
      { id: "boosts", label: "Boosts", icon: Rocket },
    ],
  },
  {
    label: "Users",
    items: [
      { id: "users", label: "Users", icon: Users },
      { id: "manage admins", label: "Admins", icon: UserCog },
    ],
  },
  {
    label: "Operations",
    items: [
      { id: "chats", label: "Chats", icon: MessageCircle },
      { id: "reports", label: "Reports", icon: ShieldAlert },
      { id: "activity monitoring", label: "Activity", icon: Activity },
      { id: "manage parameters", label: "Settings", icon: Settings },
    ],
  },
]

export function DashboardSidebar({ activeSection, onSectionChange }: DashboardSidebarProps) {
  const user = getUserFromToken()
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  return (
    <aside className="sticky top-6 hidden h-[calc(100vh-48px)] w-[260px] shrink-0 rounded-lg border border-sidebar-border bg-sidebar p-4 text-sidebar-foreground lg:flex lg:flex-col">
      <div className="rounded-lg border border-sidebar-border bg-white p-4">
        <div className="flex items-center gap-3">
          <div className="flex size-10 items-center justify-center rounded-lg bg-sidebar-primary text-sidebar-primary-foreground">
            <span className="text-lg font-bold">H</span>
          </div>
          <div>
            <p className="text-sm font-semibold text-foreground">Homely</p>
            <p className="text-xs text-sidebar-foreground">Operations OS</p>
          </div>
        </div>
      </div>

      <nav className="mt-6 flex-1 space-y-5 overflow-hidden">
        {groups.map((group) => (
          <div key={group.label}>
            <p className="mb-2 px-3 text-[11px] font-medium uppercase tracking-wide text-sidebar-foreground/70">
              {group.label}
            </p>
            <div className="space-y-1">
              {group.items.map((item) => {
                const active = activeSection === item.id || (activeSection === "dashboard" && item.id === "dashboard")
                return (
                  <button
                    key={item.id}
                    type="button"
                    onClick={() => onSectionChange(item.id)}
                    className={cn(
                      "flex h-10 w-full items-center gap-3 rounded-lg px-3 text-left text-sm font-medium transition-colors",
                      active && "bg-sidebar-primary text-sidebar-primary-foreground",
                      !active && "text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
                    )}
                  >
                    <item.icon className="size-4" />
                    {item.label}
                  </button>
                )
              })}
            </div>
          </div>
        ))}
      </nav>

      <div className="rounded-lg border border-sidebar-border bg-white p-3">
        <div className="flex items-center gap-3">
          <div className="flex size-10 items-center justify-center rounded-lg bg-primary text-sm font-bold text-white">
            {mounted && user ? (user.name || user.username || "A").charAt(0).toUpperCase() : "A"}
          </div>
          <div className="min-w-0">
            <p className="truncate text-sm font-semibold text-foreground">{mounted && user ? (user.name || "Admin") : "Admin"}</p>
            <p className="truncate text-xs text-muted-foreground">{mounted && user ? (user.username || "admin@homely") : "admin@homely"}</p>
          </div>
        </div>
      </div>
    </aside>
  )
}
