import { AlertTriangle, Home, MessageCircle, Rocket, UserPlus } from "lucide-react"

const icons = [Home, Rocket, UserPlus, AlertTriangle, MessageCircle]

export type ActivityItem = {
  title: string
  description: string
  time: string
}

export function ActivityFeed({ items }: { items: ActivityItem[] }) {
  return (
    <div className="space-y-3">
      {items.map((item, index) => {
        const Icon = icons[index % icons.length]
        return (
          <div key={`${item.title}-${item.time}`} className="flex gap-3 rounded-2xl border border-slate-100 bg-slate-50/60 p-4">
            <div className="flex size-10 shrink-0 items-center justify-center rounded-2xl bg-white text-indigo-600 shadow-[0_1px_2px_rgba(15,23,42,.04)]">
              <Icon className="size-4" />
            </div>
            <div className="min-w-0 flex-1">
              <div className="flex items-start justify-between gap-3">
                <p className="font-semibold text-slate-900">{item.title}</p>
                <span className="shrink-0 text-xs font-medium text-slate-400">{item.time}</span>
              </div>
              <p className="mt-1 text-sm text-slate-500">{item.description}</p>
            </div>
          </div>
        )
      })}
    </div>
  )
}
