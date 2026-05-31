"use client";

import { useState, useEffect, useCallback } from "react";
import { useRouter } from "next/navigation";
import { LogOut, UserCircle } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { getUserFromToken } from "@/lib/auth";
import { api } from "@/lib/api";
import { useTranslations } from "next-intl";

export function NavUser({
  setActiveSection,
}: {
  setActiveSection: (section: string) => void;
}) {
  const t = useTranslations("navUser");
  const router = useRouter();
  const user = getUserFromToken();
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null);

  const fetchAvatar = useCallback(async () => {
    try {
      const res = await api.get<{ avatarUrl?: string }>("/profile/me");
      if (res.data?.avatarUrl) setAvatarUrl(res.data.avatarUrl);
    } catch {
      // silently fail
    }
  }, []);

  useEffect(() => {
    fetchAvatar();
    const handleAvatarUpdate = (e: Event) => {
      const detail = (e as CustomEvent).detail;
      setAvatarUrl(detail?.avatarUrl ?? null);
    };
    window.addEventListener("avatar-updated", handleAvatarUpdate);
    window.addEventListener("focus", fetchAvatar);
    return () => {
      window.removeEventListener("avatar-updated", handleAvatarUpdate);
      window.removeEventListener("focus", fetchAvatar);
    };
  }, [fetchAvatar]);

  const handleLogout = async () => {
    try {
      const refreshToken = localStorage.getItem("refresh_token");
      await api.post("/auth/logout", { refreshToken });
    } catch {
      // continue
    } finally {
      localStorage.removeItem("access_token");
      localStorage.removeItem("refresh_token");
      router.push("/");
    }
  };

  const initials = (user?.name ?? user?.username ?? "?")
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button className="flex w-full items-center gap-3 rounded-lg px-2 py-2 text-left outline-none transition-colors hover:bg-sidebar-accent">
          <Avatar className="w-7 h-7">
            {avatarUrl && <AvatarImage src={avatarUrl} alt={user?.name ?? "User"} />}
            <AvatarFallback className="bg-primary text-white text-[10px] font-semibold">
              {initials}
            </AvatarFallback>
          </Avatar>
          <span className="min-w-0 flex-1">
            <span className="block truncate text-sm font-medium text-foreground">
              {user?.name ?? user?.username ?? "Admin"}
            </span>
            <span className="block truncate text-xs text-muted-foreground">
              {user?.username ?? ""}
            </span>
          </span>
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent
        side="right"
        align="end"
        sideOffset={8}
        className="w-52"
      >
        <div className="px-3 py-2">
          <p className="text-sm font-medium text-foreground truncate">
            {user?.name ?? user?.username ?? "Admin"}
          </p>
          <p className="text-xs text-muted-foreground truncate">
            {user?.username ?? ""}
          </p>
        </div>
        <DropdownMenuSeparator />
        <DropdownMenuItem
          onClick={() => setActiveSection("profile")}
          className="cursor-pointer"
        >
          <UserCircle className="w-4 h-4 mr-2 text-muted-foreground" />
          {t("profile")}
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem
          onClick={handleLogout}
          className="cursor-pointer text-destructive focus:text-destructive"
        >
          <LogOut className="w-4 h-4 mr-2" />
          {t("logout")}
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
