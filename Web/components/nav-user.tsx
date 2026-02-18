"use client"

import * as React from "react"
import {
  IconDotsVertical,
  IconLogout,
  IconUserCircle,
  IconNotification,
} from "@tabler/icons-react"

import {
  Avatar,
  AvatarFallback,
} from "@/components/ui/avatar"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import {
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  useSidebar,
} from "@/components/ui/sidebar"

import { getUserFromToken } from "@/lib/auth"
import { useRouter } from "next/navigation"

export function NavUser() {
  const { isMobile } = useSidebar()
  const router = useRouter()
  const [user, setUser] = React.useState<any>(null)

  React.useEffect(() => {
    setUser(getUserFromToken())
  }, [])

  if (!user) return null

  const logout = () => {
    localStorage.removeItem("jwt")
    router.push("/")
  }

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <SidebarMenuButton size="lg">
              <Avatar className="h-8 w-8 rounded-lg">
                <AvatarFallback>
                  {user.sub.charAt(0).toUpperCase()}
                </AvatarFallback>
              </Avatar>

              <div className="grid flex-1 text-left text-sm">
                <span className="font-medium">{user.name}</span>
                <span className="text-xs text-muted-foreground">
                  {user.sub}
                </span>
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
              <DropdownMenuItem>
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
