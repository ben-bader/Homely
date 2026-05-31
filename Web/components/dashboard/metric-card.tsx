import * as React from "react"
import { ArrowDownRight, ArrowUpRight } from "lucide-react"

import { cn } from "@/lib/utils"

type MetricCardProps = {
  label: string
  value: string
  trend?: string
  trendDirection?: "up" | "down" | "neutral"
  icon: React.ReactNode
  sparkline?: number[]
  accent?: "indigo" | "cyan" | "emerald" | "amber"
}

const accents = {
  indigo: "bg-indigo-50 text-indigo-600",
  cyan: "bg-cyan-50 text-cyan-600",
  emerald: "bg-emerald-50 text-emerald-600",
  amber: "bg-amber-50 text-amber-600",
}

export function MetricCard({
  label,
  value,
  trend,
  trendDirection = "neutral",
  icon,
  sparkline = [12, 18, 14, 22, 20, 28, 34],
  accent = "indigo",
}: MetricCardProps) {
  const max = Math.max(...sparkline, 1)
  const points = sparkline
    .map((item, index) => {
      const x = (index / Math.max(sparkline.length - 1, 1)) * 112
      const y = 38 - (item / max) * 30
      return `${x},${y}`
    })
    .join(" ")

  return (
    <article className="rounded-lg border border-[#EAECEF] bg-white p-6 shadow-[0_1px_2px_rgba(16,24,40,0.04),0_4px_12px_rgba(16,24,40,0.04)]">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-[13px] font-medium text-slate-500">{label}</p>
          <p className="mt-4 text-3xl font-bold tracking-tight text-slate-950">{value}</p>
        </div>
        <div className={cn("flex size-11 items-center justify-center rounded-lg", accents[accent])}>
          {icon}
        </div>
      </div>
      <div className="mt-5 flex items-end justify-between gap-4">
        <div
          className={cn(
            "inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-semibold",
            trendDirection === "up" && "bg-emerald-50 text-emerald-700",
            trendDirection === "down" && "bg-red-50 text-red-700",
            trendDirection === "neutral" && "bg-slate-100 text-slate-600"
          )}
        >
          {trendDirection === "up" ? <ArrowUpRight className="size-3" /> : null}
          {trendDirection === "down" ? <ArrowDownRight className="size-3" /> : null}
          {trend ?? "Stable"}
        </div>
        <svg width="112" height="40" viewBox="0 0 112 40" aria-hidden="true">
          <polyline points={points} fill="none" stroke="#4F46E5" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      </div>
    </article>
  )
}
