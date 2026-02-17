"use client"

import { type Icon } from "@tabler/icons-react"
import {
  SidebarGroup,
  SidebarGroupContent,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar"
import { LucideIcon } from "lucide-react"

export const NavMain = ({
  items,
  activeSection,
  setActiveSection,
}: {
  items: {
    title: string
    url: string
    icon ?: LucideIcon
  }[]
  activeSection: string
  setActiveSection: (section: string) => void
}) => {
  return (
    <SidebarGroup>
      <SidebarGroupContent className="flex flex-col gap-2">
        <SidebarMenu>
          {items.map((item) => {
            const isActive =
              activeSection === item.title.toLowerCase()

            return (
              <SidebarMenuItem key={item.title}>
                <SidebarMenuButton
                  tooltip={item.title}
                  onClick={() =>
                    setActiveSection(item.title.toLowerCase())
                  }
                  className={`
                    transition-colors
                    ${isActive
                      ? "bg-primary text-primary-foreground"
                      : "hover:bg-muted"}
                  `}
                >
                  {item.icon && <item.icon className="mr-2" />}
                  <span>{item.title}</span>
                </SidebarMenuButton>
              </SidebarMenuItem>
            )
          })}
        </SidebarMenu>
      </SidebarGroupContent>
    </SidebarGroup>
  )
}
