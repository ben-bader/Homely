"use client"

import * as React from "react"

import { DashboardSidebar } from "./dashboard-sidebar"
import { DashboardTopbar } from "./dashboard-topbar"

type DashboardShellProps = {
  activeSection: string
  title: string
  onSectionChange: (section: string) => void
  children: React.ReactNode
}

export function DashboardShell({
  activeSection,
  title,
  onSectionChange,
  children,
}: DashboardShellProps) {
  return (
    <div className="min-h-screen bg-[#F8FAFC] text-slate-950">
      <div className="flex gap-6 p-6">
        <DashboardSidebar activeSection={activeSection} onSectionChange={onSectionChange} />
        <div className="min-w-0 flex-1 overflow-hidden rounded-[28px] border border-slate-200 bg-[#F8FAFC]">
          <DashboardTopbar title={title} />
          <main className="mx-auto flex w-full max-w-[1600px] flex-col gap-8 p-8">
            {children}
          </main>
        </div>
      </div>
    </div>
  )
}
