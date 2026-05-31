import { Download, FilePlus, Home } from "lucide-react"

import { Button } from "@/components/ui/button"

export function DashboardHeader() {
  return (
    <section className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
      <div>
        <p className="text-[13px] font-semibold uppercase tracking-[0.16em] text-indigo-600">Executive Overview</p>
        <h1 className="mt-3 text-4xl font-bold tracking-tight text-slate-950 lg:text-5xl">
          Good Morning, Farouk 👋
        </h1>
        <p className="mt-3 text-[15px] text-slate-500">
          Here's what's happening across Homely today.
        </p>
      </div>
      <div className="flex flex-wrap gap-3">
        <Button variant="outline" className="h-12 rounded-2xl border-slate-200 bg-white px-4">
          <Download className="size-4" />
          Export
        </Button>
        <Button variant="outline" className="h-12 rounded-2xl border-slate-200 bg-white px-4">
          <FilePlus className="size-4" />
          Create Report
        </Button>
        <Button className="h-12 rounded-2xl bg-indigo-600 px-4 text-white hover:bg-indigo-500">
          <Home className="size-4" />
          Add Listing
        </Button>
      </div>
    </section>
  )
}
