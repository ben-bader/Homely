import * as React from "react"

import { cn } from "@/lib/utils"

type AnalyticsCardProps = React.ComponentProps<"section"> & {
  title: string
  description?: string
  action?: React.ReactNode
}

export function AnalyticsCard({
  title,
  description,
  action,
  className,
  children,
  ...props
}: AnalyticsCardProps) {
  return (
    <section
      className={cn(
        "rounded-lg border border-[#EAECEF] bg-white p-6 shadow-[0_1px_2px_rgba(16,24,40,0.04),0_4px_12px_rgba(16,24,40,0.04)]",
        className
      )}
      {...props}
    >
      <div className="mb-6 flex items-start justify-between gap-4">
        <div>
          <h2 className="text-xl font-semibold text-slate-950">{title}</h2>
          {description ? <p className="mt-1 text-sm text-slate-500">{description}</p> : null}
        </div>
        {action ? <div className="shrink-0">{action}</div> : null}
      </div>
      {children}
    </section>
  )
}
