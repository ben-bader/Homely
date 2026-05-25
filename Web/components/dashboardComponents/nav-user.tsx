"use client"

import * as React from "react"
import {
  IconDotsVertical,
  IconLogout,
  IconUserCircle,
} from "@tabler/icons-react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
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
import { api } from "@/lib/api"

interface NavUserProps {
  readonly setActiveSection: (section: string) => void
}

export function NavUser({ setActiveSection }: NavUserProps) {
  const { isMobile } = useSidebar()
  const [user, setUser] = React.useState<any>(null)
  const [avatarUrl, setAvatarUrl] = React.useState<string | null>(null)

  const fetchAvatar = React.useCallback(async () => {
    try {
      const res = await api.get("/profile/me")
      if (res.data?.avatarUrl) setAvatarUrl(res.data.avatarUrl)
      else setAvatarUrl(null)
    } catch {
      setAvatarUrl(null)
    }
  }, [])

  React.useEffect(() => {
    const currentUser = getUserFromToken()
    setUser(currentUser)
    fetchAvatar()
  }, [fetchAvatar])

  // Re-fetch avatar whenever the user navigates back to this component
  // (e.g. after updating it in the Profile page)
  React.useEffect(() => {
    const handleFocus = () => fetchAvatar()
    globalThis.window.addEventListener("focus", handleFocus)
    return () => globalThis.window.removeEventListener("focus", handleFocus)
  }, [fetchAvatar])

  // Listen for a custom event dispatched by Profile.tsx after a successful upload
  React.useEffect(() => {
    const handleAvatarUpdate = (e: CustomEvent<{ avatarUrl: string | null }>) => {
      setAvatarUrl(e.detail.avatarUrl)
    }
    globalThis.window.addEventListener("avatar-updated", handleAvatarUpdate as EventListener)
    return () => globalThis.window.removeEventListener("avatar-updated", handleAvatarUpdate as EventListener)
  }, [])

  if (!user) return null

  const logout = async () => {
    const refreshToken = localStorage.getItem("refresh_token")
    try {
      if (refreshToken) await api.post("/auth/logout", { refreshToken })
    } catch {
      // ignore
    }
    localStorage.removeItem("jwt")
    localStorage.removeItem("access_token")
    localStorage.removeItem("refresh_token")
    localStorage.removeItem("auth_user")
    setActiveSection("dashboard")
  }

  const userInitial = (user.name ?? "?").charAt(0).toUpperCase()

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <SidebarMenuButton size="lg">
              <Avatar className="h-8 w-8 rounded-lg">
                {avatarUrl && (
                  <AvatarImage
                    src={avatarUrl}
                    alt={user.name}
                    className="rounded-lg object-cover"
                  />
                )}
                <AvatarFallback className="rounded-lg">
                  {userInitial}
                </AvatarFallback>
              </Avatar>

              <div className="grid flex-1 text-left text-sm ml-2">
                <span className="font-medium">{user.name}</span>
                <span className="text-xs text-muted-foreground">{user.email}</span>
              </div>

              <IconDotsVertical className="ml-auto size-4" />
            </SidebarMenuButton>
          </DropdownMenuTrigger>

          <DropdownMenuContent
            side={isMobile ? "bottom" : "right"}
            align="end"
            sideOffset={4}
          >
            <DropdownMenuLabel>
              <div className="flex items-center gap-3 py-1">
                <Avatar className="h-9 w-9 rounded-lg">
                  {avatarUrl && (
                    <AvatarImage
                      src={avatarUrl}
                      alt={user.name}
                      className="rounded-lg object-cover"
                    />
                  )}
                  <AvatarFallback className="rounded-lg text-sm">
                    {userInitial}
                  </AvatarFallback>
                </Avatar>
                <div>
                  <p className="text-sm font-medium leading-none">{user.name}</p>
                  <p className="text-xs text-muted-foreground mt-1">{user.email}</p>
                </div>
              </div>
            </DropdownMenuLabel>

            <DropdownMenuSeparator />

            <DropdownMenuGroup>
              <DropdownMenuItem onClick={() => setActiveSection("profile")}>
                <IconUserCircle />
                Profile
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