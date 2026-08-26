import { FileText, MessageSquareWarning, Plus, Settings } from "lucide-react"

import { Button } from "@/components/ui/button"

const actions = [
  { label: "Add Listing", icon: Plus },
  { label: "Review Reports", icon: MessageSquareWarning },
  { label: "Export Data", icon: FileText },
  { label: "Settings", icon: Settings },
]

export function QuickActions() {
  return (
    <div className="grid grid-cols-2 gap-3">
      {actions.map((action) => (
        <Button
          key={action.label}
          variant="outline"
          className="h-14 justify-start rounded-2xl border-slate-200 bg-white text-slate-700 hover:bg-indigo-50 hover:text-indigo-700"
        >
          <action.icon className="size-4" />
          {action.label}
        </Button>
      ))}
    </div>
  )
}
