"use client";

import { useState, useEffect, useRef } from "react";
import { Bell, Search, Globe, Command, Loader2, User, FileText, Home } from "lucide-react";
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
  const PAGE_SIZE = 6; // Show up to 6 notifications per page

  // Global search state
  const [query, setQuery] = useState("");
  const [isOpen, setIsOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState<{ properties: any[]; users: any[]; reports: any[] }>({
    properties: [],
    users: [],
    reports: [],
  });

  // Reset query on section transition
  useEffect(() => {
    setQuery("");
  }, [activeSection]);

  const searchRef = useRef<HTMLDivElement>(null);

  // Close search results dropdown on outside click
  useEffect(() => {
    if (typeof window === "undefined") return;
    const handleOutsideClick = (e: MouseEvent) => {
      if (searchRef.current && !searchRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleOutsideClick);
    return () => document.removeEventListener("mousedown", handleOutsideClick);
  }, []);

  // Fetch search results based on query (debounced)
  useEffect(() => {
    if (query.trim().length < 2) {
      setResults({ properties: [], users: [], reports: [] });
      setIsOpen(false);
      return;
    }

    const delayDebounce = setTimeout(async () => {
      setLoading(true);
      try {
        const [propRes, userRes, reportRes] = await Promise.all([
          api.get<any[]>("/properties/search", { params: { keyword: query } }),
          api.get<any[]>("/admin/users"),
          api.get<any[]>("/admin/reports"),
        ]);

        const keyword = query.toLowerCase();

        const filteredUsers = (userRes.data || []).filter((u: any) =>
          [u.name, u.email, u.role].join(" ").toLowerCase().includes(keyword)
        ).slice(0, 5);

        const filteredReports = (reportRes.data || []).filter((r: any) =>
          [r.reason, r.reporterName, r.reportedUserName].join(" ").toLowerCase().includes(keyword)
        ).slice(0, 5);

        setResults({
          properties: (propRes.data || []).slice(0, 5),
          users: filteredUsers,
          reports: filteredReports,
        });
        setIsOpen(true);
      } catch (err) {
        console.error("Global search failed", err);
      } finally {
        setLoading(false);
      }
    }, 300);

    return () => clearTimeout(delayDebounce);
  }, [query]);

  // Handle clicking on a search result
  const handleSelect = (section: string, matchText: string) => {
    // 1. Change section
    window.dispatchEvent(new CustomEvent("change-section", { detail: section }));
    
    // 2. Update URL parameters
    if (typeof window !== "undefined") {
      const url = new URL(window.location.href);
      url.searchParams.set("section", section);
      url.searchParams.set("search", matchText);
      window.history.replaceState(null, "", url.pathname + url.search);
    }

    // 3. Fire search event after a short timeout so that the component has time to mount/listen
    setTimeout(() => {
      window.dispatchEvent(
        new CustomEvent("global-search-apply", {
          detail: { section, query: matchText },
        })
      );
    }, 150);

    setQuery("");
    setIsOpen(false);
  };

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
      <div className="flex-1 max-w-md relative" ref={searchRef}>
        <div className="relative group">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground pointer-events-none" />
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onFocus={() => {
              if (query.trim().length >= 2) setIsOpen(true);
            }}
            placeholder="Search properties, users, reports..."
            className="w-full h-9 pl-10 pr-12 text-sm bg-white border border-border rounded-lg outline-none focus:ring-2 focus:ring-ring/30 focus:border-ring placeholder:text-muted-foreground/60 transition-colors"
          />
          <div className="absolute right-2.5 top-1/2 -translate-y-1/2 flex items-center gap-1.5 px-2 py-1 rounded-md bg-muted/80 border border-border/50">
            <Command className="w-3 h-3 text-muted-foreground/60" />
            <span className="text-[10px] font-medium text-muted-foreground/60">K</span>
          </div>
        </div>

        {/* Search Results Dropdown Overlay */}
        {isOpen && (
          <div className="absolute top-full left-0 right-0 mt-1 max-h-[400px] overflow-y-auto z-50 bg-background border border-border rounded-xl shadow-lg p-2 space-y-3">
            {loading ? (
              <div className="flex items-center justify-center py-6 text-sm text-muted-foreground gap-2">
                <Loader2 className="w-4 h-4 animate-spin text-primary" />
                Searching...
              </div>
            ) : (
              <>
                {results.properties.length === 0 &&
                results.users.length === 0 &&
                results.reports.length === 0 ? (
                  <div className="py-6 text-center text-sm text-muted-foreground">
                    No results found for "{query}"
                  </div>
                ) : (
                  <>
                    {/* Properties Section */}
                    {results.properties.length > 0 && (
                      <div className="space-y-1">
                        <div className="flex items-center gap-1 px-2.5 py-1 text-[10px] font-bold text-muted-foreground uppercase tracking-wider">
                          <Home className="w-3 h-3" />
                          Properties
                        </div>
                        {results.properties.map((p) => (
                          <div
                            key={p.id}
                            onClick={() => handleSelect("properties", p.title)}
                            className="flex flex-col px-2.5 py-1.5 hover:bg-muted/50 rounded-lg cursor-pointer transition-colors"
                          >
                            <span className="text-xs font-semibold text-foreground truncate">{p.title}</span>
                            <span className="text-[10px] text-muted-foreground truncate">{p.address} • ${p.price?.toLocaleString()}</span>
                          </div>
                        ))}
                      </div>
                    )}

                    {/* Users Section */}
                    {results.users.length > 0 && (
                      <div className="space-y-1 border-t border-border/40 pt-2">
                        <div className="flex items-center gap-1 px-2.5 py-1 text-[10px] font-bold text-muted-foreground uppercase tracking-wider">
                          <User className="w-3 h-3" />
                          Users
                        </div>
                        {results.users.map((u) => (
                          <div
                            key={u.id}
                            onClick={() => handleSelect("users", u.name || u.email)}
                            className="flex flex-col px-2.5 py-1.5 hover:bg-muted/50 rounded-lg cursor-pointer transition-colors"
                          >
                            <span className="text-xs font-semibold text-foreground truncate">{u.name}</span>
                            <span className="text-[10px] text-muted-foreground truncate">{u.email} • {u.role}</span>
                          </div>
                        ))}
                      </div>
                    )}

                    {/* Reports Section */}
                    {results.reports.length > 0 && (
                      <div className="space-y-1 border-t border-border/40 pt-2">
                        <div className="flex items-center gap-1 px-2.5 py-1 text-[10px] font-bold text-muted-foreground uppercase tracking-wider">
                          <FileText className="w-3 h-3" />
                          Reports
                        </div>
                        {results.reports.map((r) => (
                          <div
                            key={r.id}
                            onClick={() => handleSelect("reports", r.reason)}
                            className="flex flex-col px-2.5 py-1.5 hover:bg-muted/50 rounded-lg cursor-pointer transition-colors"
                          >
                            <span className="text-xs font-semibold text-foreground truncate">{r.reason || "No Reason"}</span>
                            <span className="text-[10px] text-muted-foreground truncate">Reporter: {r.reporterName || r.reporterEmail || "Unknown"}</span>
                          </div>
                        ))}
                      </div>
                    )}
                  </>
                )}
              </>
            )}
          </div>
        )}
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
              className="relative h-9 w-9 text-primary hover:text-foreground hover:bg-muted/50 transition-colors"
            >
              <Bell className="w-4 h-4" />
              {unreadCount > 0 && (
                <span className="absolute top-1.5 right-1.5 flex h-2 w-2 items-center justify-center rounded-full bg-destructive" />
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
                    onClick={() => {
                      const ids = getReadIds();
                      ids.add(n.id);
                      saveReadIds(ids);
                      setNotifs((prev) =>
                        prev.map((item) =>
                          item.id === n.id ? { ...item, read: true } : item
                        )
                      );
                    }}
                  >
                    <div className={cn(
                      "w-1.5 h-1.5 rounded-full mt-2 flex-shrink-0 transition-all",
                      !n.read ? "bg-destructive" : "bg-transparent"
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
