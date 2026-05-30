"use client"

import {
  SidebarGroup,
  SidebarGroupContent,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import { LucideIcon } from "lucide-react"
import { useTranslations } from "next-intl"

export const NavMain = ({
  items,
  activeSection,
  setActiveSection,
}: {
  items: {
    id: string
    titleKey: string
    url: string
    icon?: LucideIcon
  }[]
  activeSection: string
  setActiveSection: (section: string) => void
}) => {
  const t = useTranslations("sections");

  return (
    <SidebarGroup>
      <SidebarGroupContent className="flex flex-col gap-2">
        <SidebarMenu>
          {items.map((item) => {
            const isActive = activeSection === item.id;
            const translatedTitle = t(item.titleKey);

            return (
              <SidebarMenuItem key={item.id}>
                <SidebarMenuButton
                  tooltip={translatedTitle}
                  onClick={() => setActiveSection(item.id)}
                  className={`
                    transition-all duration-300 rounded-xl mx-2 px-3 py-3 font-bold border overflow-hidden
                    flex items-center justify-start gap-2.5 w-full
                    ${isActive
                      ? "bg-gradient-to-r from-primary to-primary-light text-primary-foreground shadow-[0_4px_14px_rgba(14,165,233,0.3)] border-transparent scale-[1.02]"
                      : "text-sidebar-foreground/70 border-transparent hover:bg-sidebar-accent/50 hover:text-sidebar-foreground hover:scale-105"}
                  `}
                >
                  {item.icon && <item.icon className="size-4 shrink-0" />}
                  <span className="text-xs tracking-wide truncate">{translatedTitle}</span>
                </SidebarMenuButton>
              </SidebarMenuItem>
            )
          })}
        </SidebarMenu>
      </SidebarGroupContent>
    </SidebarGroup>
  )
}
