"use client"

import * as React from "react"
import {
  IconDotsVertical,
  IconLogout,
  IconUserCircle,
  IconNotification,
} from "@tabler/icons-react"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuLabel,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu"
import {
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  useSidebar,
} from "@/components/ui/sidebar"
import { getUserFromToken } from "@/lib/auth"

interface NavUserProps {
  setActiveSection: (section: string) => void
}

export function NavUser({ setActiveSection }: NavUserProps) {
  const { isMobile } = useSidebar()
  const [user, setUser] = React.useState<any>(null)

  React.useEffect(() => {
    const decoded = getUserFromToken()
    setUser(decoded)
  }, [])

  if (!user) return null

  const logout = () => {
    localStorage.removeItem("jwt")
    setActiveSection("dashboard") // Optional: reset to dashboard after logout
  }

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <SidebarMenuButton size="lg">
              <Avatar className="h-8 w-8 rounded-lg">
                <AvatarFallback>{user.sub.charAt(0).toUpperCase()}</AvatarFallback>
              </Avatar>

              <div className="grid flex-1 text-left text-sm ml-2">
                <span className="font-medium">{user.name}</span>
                <span className="text-xs text-muted-foreground">{user.sub}</span>
              </div>

              <IconDotsVertical className="ml-auto size-4" />
            </SidebarMenuButton>
          </DropdownMenuTrigger>

          <DropdownMenuContent
            side={isMobile ? "bottom" : "right"}
            align="end"
            sideOffset={4}
          >
            <DropdownMenuLabel>Account</DropdownMenuLabel>
            <DropdownMenuSeparator />

            <DropdownMenuGroup>
              <DropdownMenuItem onClick={() => setActiveSection("profile")}>
                <IconUserCircle />
                Profile
              </DropdownMenuItem>

              <DropdownMenuItem>
                <IconNotification />
                Notifications
              </DropdownMenuItem>
            </DropdownMenuGroup>

            <DropdownMenuSeparator />

            <DropdownMenuItem onClick={logout}>
              <IconLogout />
              Log out
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </SidebarMenuItem>
    </SidebarMenu>
  )
}
