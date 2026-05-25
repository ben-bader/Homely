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
  const [profile, setProfile] = React.useState<any | null>(null)
  const [avatarUrl, setAvatarUrl] = React.useState<string | null>(null)

  const fetchProfile = React.useCallback(async () => {
    try {
      const res = await api.get("/profile/me")
      const data = res.data || {}
      setProfile(data)
      setAvatarUrl(data.avatarUrl ?? null)
    } catch {
      setProfile(null)
      setAvatarUrl(null)
    }
  }, [])

  React.useEffect(() => {
    const currentUser = getUserFromToken()
    setUser(currentUser)
    fetchProfile()
  }, [fetchProfile])

  // Re-fetch avatar whenever the user navigates back to this component
  // (e.g. after updating it in the Profile page)
  React.useEffect(() => {
    const handleFocus = () => fetchProfile()
    globalThis.window.addEventListener("focus", handleFocus)
    return () => globalThis.window.removeEventListener("focus", handleFocus)
  }, [fetchProfile])

  // Listen for a custom event dispatched by Profile.tsx after a successful upload
  React.useEffect(() => {
    const handleAvatarUpdate = (e: CustomEvent<{ avatarUrl: string | null }>) => {
      setAvatarUrl(e.detail.avatarUrl)
    }
    globalThis.window.addEventListener("avatar-updated", handleAvatarUpdate as EventListener)
    return () => globalThis.window.removeEventListener("avatar-updated", handleAvatarUpdate as EventListener)
  }, [])

  if (!user) return null

  // Extract first letter for avatar initial
  const userInitial = (profile?.name ?? user?.username)?.[0]?.toUpperCase() ?? "?"

  const logout = async () => {
    const refreshToken = localStorage.getItem("refresh_token")
    try {
      if (refreshToken) await api.post("/auth/logout", { refreshToken })
    } catch {
      // ignore
    }
    localStorage.removeItem("access_token")
    localStorage.removeItem("refresh_token")
    // Clear any legacy keys
    localStorage.removeItem("jwt")
    localStorage.removeItem("auth_user")
    // Redirect to home
    window.location.href = "/"
  }

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
                    alt={profile?.name ?? user?.username}
                    className="rounded-lg object-cover"
                  />
                )}
                <AvatarFallback className="rounded-lg">
                  {userInitial}
                </AvatarFallback>
              </Avatar>

              <div className="grid flex-1 text-left text-sm ml-2">
                <span className="font-medium">{profile?.name ?? user?.username}</span>
                <span className="text-xs text-muted-foreground">{profile?.email ?? ""}</span>
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
                      alt={profile?.name ?? user?.username}
                      className="rounded-lg object-cover"
                    />
                  )}
                  <AvatarFallback className="rounded-lg text-sm">
                    {userInitial}
                  </AvatarFallback>
                </Avatar>
                <div>
                  <p className="text-sm font-medium leading-none">{profile?.name ?? user?.username}</p>
                  <p className="text-xs text-muted-foreground mt-1">{profile?.email ?? ""}</p>
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
