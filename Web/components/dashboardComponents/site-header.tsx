"use client";

import { useState, useEffect } from "react";
import { Bell, Search, Globe, Command } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useTranslations, useLocale } from "next-intl";
import { api } from "@/lib/api";
import { cn } from "@/lib/utils";

/* ── Section title map ── */
const SECTION_TITLES: Record<string, string> = {
  analytics: "Analytics",
  dashboard: "Dashboard",
  users: "Users",
  properties: "Properties",
  reports: "Reports",
  boosts: "Boosts",
  "visit requests": "Visit Requests",
  "activity monitoring": "Activity Monitoring",
  "manage admins": "Administrators",
  chats: "Chats",
  "manage parameters": "Parameters",
  profile: "Profile",
};

type NotifItem = {
  id: string;
  title: string;
  subtitle: string;
  time: string;
  type: "boost" | "report" | "property" | "visit";
  read: boolean;
};

const READ_KEY = "homely_read_notif_ids";

function getReadIds(): Set<string> {
  try {
    const raw = localStorage.getItem(READ_KEY);
    return raw ? new Set(JSON.parse(raw)) : new Set();
  } catch {
    return new Set();
  }
}

function saveReadIds(ids: Set<string>) {
  try {
    localStorage.setItem(READ_KEY, JSON.stringify([...ids]));
  } catch {}
}

export function SiteHeader({ activeSection = "analytics" }: { activeSection?: string }) {
  const t = useTranslations("header");
  const locale = useLocale();
  const [notifs, setNotifs] = useState<NotifItem[]>([]);
  const [page, setPage] = useState(0);
  const PAGE_SIZE = 5;

  const unreadCount = notifs.filter((n) => !n.read).length;
  const paginated = notifs.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE);
  const totalPages = Math.ceil(notifs.length / PAGE_SIZE);

  useEffect(() => {
    const fetchNotifs = async () => {
      try {
        const [boostsRes, reportsRes, propertiesRes, visitsRes] = await Promise.all([
          api.get<any[]>("/admin/boosts"),
          api.get<any[]>("/admin/reports"),
          api.get<any[]>("/admin/properties"),
          api.get<any[]>("/admin/visit-requests"),
        ]);

        const readIds = getReadIds();

        const propertyPayload = propertiesRes.data as any;
        const propertyItems = propertyPayload?.content || propertyPayload || [];

        const all: NotifItem[] = [
          ...(boostsRes.data || []).filter((b: any) => b.status === "PENDING").map((b: any) => ({
            id: `boost-${b.id}`,
            title: "Boost Pending",
            subtitle: b.propertyTitle || "Unknown property",
            time: b.createdAt || "",
            type: "boost" as const,
            read: readIds.has(`boost-${b.id}`),
          })),
          ...(reportsRes.data || []).filter((r: any) => r.status === "OPEN").map((r: any) => ({
            id: `report-${r.id}`,
            title: "Open Report",
            subtitle: r.reason || "No reason",
            time: r.createdAt || "",
            type: "report" as const,
            read: readIds.has(`report-${r.id}`),
          })),
          ...propertyItems.filter((p: any) => p.status === "DRAFT").map((p: any) => ({
            id: `property-${p.id}`,
            title: "Property Pending Review",
            subtitle: p.title || "Unknown",
            time: p.createdAt || "",
            type: "property" as const,
            read: readIds.has(`property-${p.id}`),
          })),
          ...(visitsRes.data || []).filter((v: any) => v.status === "PENDING").map((v: any) => ({
            id: `visit-${v.id}`,
            title: "Visit Request",
            subtitle: v.propertyTitle || "Unknown property",
            time: v.createdAt || "",
            type: "visit" as const,
            read: readIds.has(`visit-${v.id}`),
          })),
        ].sort((a, b) => new Date(b.time).getTime() - new Date(a.time).getTime());

        setNotifs(all);
      } catch {
        // silently fail
      }
    };
    fetchNotifs();
  }, []);

  const markAllRead = () => {
    const ids = new Set(notifs.map((n) => n.id));
    saveReadIds(ids);
    setNotifs((prev) => prev.map((n) => ({ ...n, read: true })));
  };

  const toggleLocale = () => {
    const next = locale === "en" ? "fr" : "en";
    fetch(`/api/set-locale?locale=${next}`, { method: "GET" }).then(() => {
      window.location.reload();
    });
  };

  const pageTitle = SECTION_TITLES[activeSection] ?? activeSection.charAt(0).toUpperCase() + activeSection.slice(1);

  return (
    <header className="sticky top-0 z-30 flex h-16 items-center gap-6 border-b border-border bg-background/95 px-6">
      {/* Page title - Premium typography */}
      <div className="min-w-0 flex-shrink-0">
        <h2 className="text-sm font-semibold text-foreground tracking-tight">
          {pageTitle}
        </h2>
      </div>

      {/* Search - Prominent, Premium */}
      <div className="flex-1 max-w-md">
        <div className="relative group">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground pointer-events-none" />
          <input
            type="text"
            placeholder="Search properties, users, reports..."
            className="w-full h-9 pl-10 pr-12 text-sm bg-white border border-border rounded-lg outline-none focus:ring-2 focus:ring-ring/30 focus:border-ring placeholder:text-muted-foreground/60 transition-colors"
          />
          <div className="absolute right-2.5 top-1/2 -translate-y-1/2 flex items-center gap-1.5 px-2 py-1 rounded-md bg-muted/80 border border-border/50">
            <Command className="w-3 h-3 text-muted-foreground/60" />
            <span className="text-[10px] font-medium text-muted-foreground/60">K</span>
          </div>
        </div>
      </div>

      {/* Actions - Premium spacing */}
      <div className="flex items-center gap-2 ml-auto">
        {/* Locale toggle - Refined */}
        <Button
          variant="ghost"
          size="sm"
          onClick={toggleLocale}
          className="h-9 px-3 text-xs font-medium text-muted-foreground hover:text-foreground hover:bg-muted/50 gap-2 transition-colors"
        >
          <Globe className="w-3.5 h-3.5" />
          {locale.toUpperCase()}
        </Button>

        {/* Notification bell - Premium */}
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              className="relative h-9 w-9 text-muted-foreground hover:text-foreground hover:bg-muted/50 transition-colors"
            >
              <Bell className="w-4 h-4" />
              {unreadCount > 0 && (
                <span className="absolute top-1.5 right-1.5 flex h-2 w-2 items-center justify-center rounded-full bg-primary" />
              )}
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-80 p-0 border-border bg-background shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_20px_rgba(16,24,40,0.08)]">
            <div className="flex items-center justify-between px-4 py-3 border-b border-border/50">
              <span className="text-sm font-semibold text-foreground">Notifications</span>
              {unreadCount > 0 && (
                <button
                  onClick={markAllRead}
                  className="text-xs font-medium text-primary hover:text-primary/80 transition-colors"
                >
                  Mark all read
                </button>
              )}
            </div>

            <div className="max-h-80 overflow-y-auto">
              {paginated.length === 0 ? (
                <div className="py-12 text-center">
                  <Bell className="w-8 h-8 mx-auto text-muted-foreground/30 mb-3" />
                  <p className="text-sm text-muted-foreground/70">No notifications</p>
                </div>
              ) : (
                paginated.map((n) => (
                  <div
                    key={n.id}
                    className={cn(
                      "flex items-start gap-3 px-4 py-3 hover:bg-muted/30 transition-colors cursor-pointer border-b border-border/30 last:border-0",
                      !n.read && "bg-primary/[0.02]"
                    )}
                  >
                    <div className={cn(
                      "w-1.5 h-1.5 rounded-full mt-2 flex-shrink-0 transition-all",
                      !n.read ? "bg-primary" : "bg-transparent"
                    )} />
                    <div className="min-w-0 flex-1">
                      <p className="text-xs font-medium text-foreground mb-0.5">{n.title}</p>
                      <p className="text-xs text-muted-foreground truncate">{n.subtitle}</p>
                    </div>
                  </div>
                ))
              )}
            </div>

            {totalPages > 1 && (
              <div className="flex items-center justify-between px-4 py-2.5 border-t border-border/50 bg-muted/20">
                <button
                  onClick={() => setPage((p) => Math.max(0, p - 1))}
                  disabled={page === 0}
                  className="text-xs font-medium text-muted-foreground hover:text-foreground disabled:opacity-40 transition-colors"
                >
                  ← Prev
                </button>
                <span className="text-xs text-muted-foreground/70">
                  {page + 1} / {totalPages}
                </span>
                <button
                  onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
                  disabled={page === totalPages - 1}
                  className="text-xs font-medium text-muted-foreground hover:text-foreground disabled:opacity-40 transition-colors"
                >
                  Next →
                </button>
              </div>
            )}
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
