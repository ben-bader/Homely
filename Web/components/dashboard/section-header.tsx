import * as React from "react"

type SectionHeaderProps = {
  eyebrow?: string
  title: string
  description?: string
  action?: React.ReactNode
}

export function SectionHeader({ eyebrow, title, description, action }: SectionHeaderProps) {
  return (
    <div className="flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between">
      <div>
        {eyebrow ? <p className="text-[13px] font-semibold uppercase tracking-[0.16em] text-indigo-600">{eyebrow}</p> : null}
        <h2 className="mt-1 text-[28px] font-semibold tracking-tight text-slate-950">{title}</h2>
        {description ? <p className="mt-1 text-[15px] text-slate-500">{description}</p> : null}
      </div>
      {action ? <div className="flex shrink-0 gap-2">{action}</div> : null}
    </div>
  )
}
