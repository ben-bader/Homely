"use client"

import { Bell, Command, Moon, Search, UserCircle } from "lucide-react"

import { Button } from "@/components/ui/button"

type DashboardTopbarProps = {
  title: string
}

export function DashboardTopbar({ title }: DashboardTopbarProps) {
  return (
    <header className="sticky top-0 z-40 flex h-20 items-center border-b border-slate-200/80 bg-[#F8FAFC]/90 px-6 backdrop-blur">
      <div className="flex min-w-0 flex-1 items-center gap-4">
        <div className="hidden min-w-[220px] lg:block">
          <p className="text-xs font-medium text-slate-400">Dashboard / {title}</p>
          <h1 className="mt-1 truncate text-xl font-semibold text-slate-950">{title}</h1>
        </div>
        <div className="relative mx-auto w-full max-w-2xl">
          <Search className="pointer-events-none absolute left-4 top-1/2 size-4 -translate-y-1/2 text-slate-400" />
          <input
            className="h-12 w-full rounded-2xl border border-slate-200 bg-white pl-11 pr-12 text-sm outline-none transition focus:border-indigo-300 focus:ring-4 focus:ring-indigo-500/10"
            placeholder="Search properties, users, reports, chats"
          />
          <div className="absolute right-3 top-1/2 flex -translate-y-1/2 items-center gap-1 rounded-lg border border-slate-200 bg-slate-50 px-2 py-1 text-xs text-slate-400">
            <Command className="size-3" />
            K
          </div>
        </div>
      </div>
      <div className="ml-4 flex items-center gap-2">
        <Button variant="outline" size="icon" className="size-11 rounded-2xl border-slate-200 bg-white">
          <Bell className="size-4" />
        </Button>
        <Button variant="outline" size="icon" className="size-11 rounded-2xl border-slate-200 bg-white">
          <Moon className="size-4" />
        </Button>
        <Button variant="outline" size="icon" className="size-11 rounded-2xl border-slate-200 bg-white">
          <UserCircle className="size-5" />
        </Button>
      </div>
    </header>
  )
}
