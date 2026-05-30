"use client";

import { useState, useEffect } from "react";
import { api } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { SidebarTrigger } from "@/components/ui/sidebar";
import { useTranslations, useLocale } from "next-intl";
import {
  IconBell,
  IconRocket,
  IconAlertTriangle,
  IconHome,
  IconChevronLeft,
  IconChevronRight,
  IconCalendar,
} from "@tabler/icons-react";

export function SiteHeader({ activeSection = "dashboard" }: { activeSection?: string }) {
  const locale = useLocale();
  const t = useTranslations("header");
  const tSections = useTranslations("sections");

  const [notifOpen, setNotifOpen] = useState(false);
  const [notifications, setNotifications] = useState<any[]>([]);
  const [notifPage, setNotifPage] = useState(0);
  const [loadingNotifs, setLoadingNotifs] = useState(false);
  const [readNotifIds, setReadNotifIds] = useState<string[]>([]);

  useEffect(() => {
    if (typeof window !== "undefined") {
      const stored = localStorage.getItem("homely_read_notif_ids");
      if (stored) {
        try {
          setReadNotifIds(JSON.parse(stored));
        } catch {
          // ignore
        }
      }
    }
  }, []);

  const markAsRead = (id: string) => {
    setReadNotifIds((prev) => {
      if (prev.includes(id)) return prev;
      const updated = [...prev, id];
      if (typeof window !== "undefined") {
        localStorage.setItem("homely_read_notif_ids", JSON.stringify(updated));
      }
      return updated;
    });
  };

  const markAllAsRead = () => {
    const allIds = notifications.map((n) => n.id);
    setReadNotifIds(allIds);
    if (typeof window !== "undefined") {
      localStorage.setItem("homely_read_notif_ids", JSON.stringify(allIds));
    }
  };

  const toggleLocale = () => {
    const newLocale = locale === "en" ? "fr" : "en";
    const redirectPath = window.location.pathname + window.location.search;
    window.location.href = `/api/set-locale?locale=${newLocale}&redirect=${encodeURIComponent(redirectPath)}`;
  };

  const fetchNotifications = async () => {
    try {
      setLoadingNotifs(true);
      const [boostsRes, reportsRes, propertiesRes, visitRequestsRes] = await Promise.all([
        api.get<any[]>("/admin/boosts").catch(() => ({ data: [] })),
        api.get<any[]>("/admin/reports").catch(() => ({ data: [] })),
        api.get<any[]>("/admin/properties").catch(() => ({ data: [] })),
        api.get<any[]>("/admin/visit-requests").catch(() => ({ data: [] })),
      ]);

      const combined: any[] = [];

      // Map Boosts
      (boostsRes.data || []).forEach((b: any) => {
        if (!b.id) return;
        combined.push({
          id: `boost-${b.id}`,
          type: "boost",
          title: locale === "fr" ? "Nouveau Boost Acheté" : "New Boost Purchased",
          message: locale === "fr" 
            ? `Forfait : ${b.packageName || "Boost"} (${b.userName || b.userEmail || ""})` 
            : `Package: ${b.packageName || "Boost"} (${b.userName || b.userEmail || ""})`,
          createdAt: b.createdAt || b.created_at || Date.now(),
        });
      });

      // Map Reports
      (reportsRes.data || []).forEach((r: any) => {
        if (!r.id) return;
        combined.push({
          id: `report-${r.id}`,
          type: "report",
          title: locale === "fr" ? "Nouveau Signalement" : "New Report Filed",
          message: locale === "fr"
            ? `Motif : ${r.reason || "Signalement"}`
            : `Reason: ${r.reason || "Report"}`,
          createdAt: r.createdAt || r.created_at || Date.now(),
        });
      });

      // Map Properties
      (propertiesRes.data || []).forEach((p: any) => {
        if (!p.id) return;
        combined.push({
          id: `property-${p.id}`,
          type: "property",
          title: locale === "fr" ? "Nouvelle Propriété" : "New Property Created",
          message: `${p.title || "Propriété"} - ${p.price || 0} $`,
          createdAt: p.createdAt || p.created_at || Date.now(),
        });
      });

      // Map Visit Requests
      (visitRequestsRes.data || []).forEach((vr: any) => {
        if (!vr.id) return;
        combined.push({
          id: `visit-${vr.id}`,
          type: "visit",
          title: locale === "fr" ? "Demande de Visite" : "Visit Request Update",
          message: locale === "fr"
            ? `${vr.userName || "Client"} - ${vr.propertyTitle || "Propriété"} (${vr.status || ""})`
            : `${vr.userName || "Client"} - ${vr.propertyTitle || "Property"} (${vr.status || ""})`,
          createdAt: vr.createdAt || vr.updatedAt || vr.requestedDate || Date.now(),
        });
      });

      // Sort by date newest first
      combined.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());

      setNotifications(combined);
    } catch {
      // ignore
    } finally {
      setLoadingNotifs(false);
    }
  };

  useEffect(() => {
    fetchNotifications();
  }, [locale]);

  // Map activeSection string to translation key
  const getSectionTitle = (sec: string) => {
    const keyMap: Record<string, string> = {
      dashboard: "analytics",
      analytics: "analytics",
      users: "users",
      properties: "properties",
      reports: "reports",
      boosts: "boosts",
      "visit requests": "visitRequests",
      "activity monitoring": "activityMonitoring",
      "manage admins": "manageAdmins",
      chats: "chats",
      "manage parameters": "manageParameters",
      profile: "profile",
    };

    const key = keyMap[sec.toLowerCase()] || sec;
    try {
      return tSections(key);
    } catch {
      return sec.charAt(0).toUpperCase() + sec.slice(1);
    }
  };

  const dynamicTitle = getSectionTitle(activeSection);

  useEffect(() => {
    if (typeof window !== "undefined") {
      document.title = `Homely Admin - ${dynamicTitle}`;
    }
  }, [dynamicTitle]);

  // Pagination calculations
  const itemsPerPage = 5;
  const totalPages = Math.ceil(notifications.length / itemsPerPage);
  const paginatedNotifications = notifications.slice(
    notifPage * itemsPerPage,
    (notifPage + 1) * itemsPerPage
  );

  const unseenCount = notifications.filter((n) => !readNotifIds.includes(n.id)).length;

  return (
    <div className="p-4 sm:p-6 pb-0 relative z-50">
      <header className="flex h-16 shrink-0 items-center gap-2 rounded-2xl border border-secondary-foreground/15 bg-secondary/90 shadow-md backdrop-blur-xl transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-16">
        <div className="flex w-full items-center gap-2 px-4 lg:gap-4 lg:px-6">
          <SidebarTrigger className="hover:bg-secondary-foreground/10 hover:text-secondary-foreground text-secondary-foreground transition-colors rounded-xl h-9 w-9" />
          <Separator
            orientation="vertical"
            className="mx-2 data-[orientation=vertical]:h-6 bg-secondary-foreground/20"
          />

          <h1 className="text-sm md:text-xl font-extrabold tracking-tight text-secondary-foreground truncate">
            {dynamicTitle}
          </h1>

          <div className="ml-auto flex items-center gap-3">
            {/* Dynamic Notifications Dropdown */}
            <div className="relative">
              <Button
                variant="outline"
                size="icon"
                onClick={() => setNotifOpen(!notifOpen)}
                className="h-9 w-9 rounded-xl border-secondary-foreground/25 text-secondary-foreground hover:bg-secondary-foreground/10 hover:text-secondary-foreground hover:shadow-sm bg-transparent transition-all relative"
              >
                <IconBell className="size-5" />
                {unseenCount > 0 && (
                  <span className="absolute -top-1 -right-1 flex h-4 w-4 items-center justify-center rounded-full bg-destructive text-[9px] font-bold text-destructive-foreground animate-bounce">
                    {unseenCount}
                  </span>
                )}
              </Button>

              {notifOpen && (
                <div className="absolute right-0 mt-2.5 w-80 rounded-2xl border border-secondary-foreground/15 bg-secondary/95 backdrop-blur-xl p-4 shadow-xl z-50 animate-in fade-in slide-in-from-top-2 duration-200">
                  <div className="flex items-center justify-between pb-2 border-b border-secondary-foreground/10">
                    <span className="font-bold text-sm text-secondary-foreground">
                      {locale === "fr" ? "Notifications" : "Notifications"}
                    </span>
                    <div className="flex items-center gap-2">
                      {unseenCount > 0 && (
                        <button
                          onClick={markAllAsRead}
                          className="text-[10px] uppercase tracking-wider text-destructive hover:text-destructive/80 font-bold transition-colors"
                        >
                          {locale === "fr" ? "Tout lire" : "Mark all read"}
                        </button>
                      )}
                      {unseenCount > 0 && <span className="text-secondary-foreground/20 text-[10px]">|</span>}
                      <button
                        onClick={() => {
                          fetchNotifications();
                          setNotifPage(0);
                        }}
                        className="text-[10px] uppercase tracking-wider text-secondary-foreground/75 hover:text-secondary-foreground font-semibold"
                      >
                        {locale === "fr" ? "Rafraîchir" : "Refresh"}
                      </button>
                    </div>
                  </div>

                  {loadingNotifs ? (
                    <div className="py-8 text-center text-xs text-secondary-foreground/60">
                      {locale === "fr" ? "Chargement..." : "Loading..."}
                    </div>
                  ) : paginatedNotifications.length === 0 ? (
                    <div className="py-8 text-center text-xs text-secondary-foreground/60">
                      {locale === "fr" ? "Aucune notification" : "No notifications"}
                    </div>
                  ) : (
                    <div className="space-y-2 mt-3">
                      {paginatedNotifications.map((n) => {
                        const isUnread = !readNotifIds.includes(n.id);
                        return (
                          <div
                            key={n.id}
                            onClick={() => markAsRead(n.id)}
                            className={`flex gap-3 text-xs leading-normal p-2 rounded-xl transition-colors cursor-pointer relative group ${
                              isUnread 
                                ? "bg-secondary-foreground/5 hover:bg-secondary-foreground/10" 
                                : "hover:bg-secondary-foreground/5"
                            }`}
                          >
                            <div className="flex h-7 w-7 shrink-0 items-center justify-center rounded-lg bg-secondary-foreground/10 text-secondary-foreground">
                              {n.type === "boost" && <IconRocket className="size-4" />}
                              {n.type === "report" && <IconAlertTriangle className="size-4" />}
                              {n.type === "property" && <IconHome className="size-4" />}
                              {n.type === "visit" && <IconCalendar className="size-4" />}
                            </div>
                            <div className="flex-1 min-w-0">
                              <p className="font-bold text-secondary-foreground truncate text-left">{n.title}</p>
                              <p className="text-secondary-foreground/80 truncate text-left">{n.message}</p>
                              <p className="text-[9px] text-secondary-foreground/65 mt-0.5 text-left">
                                {new Date(n.createdAt).toLocaleTimeString(locale === "fr" ? "fr-FR" : "en-US", {
                                  hour: "2-digit",
                                  minute: "2-digit",
                                })}
                              </p>
                            </div>
                            {isUnread && (
                              <div className="flex items-center shrink-0 self-center pl-1">
                                <span className="h-2 w-2 rounded-full bg-destructive shadow-[0_0_8px_rgba(239,68,68,0.8)] animate-pulse" title="Unread" />
                              </div>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  )}

                  {/* Pagination Footer */}
                  {totalPages > 1 && (
                    <div className="flex items-center justify-between mt-4 pt-3 border-t border-secondary-foreground/10 text-xs text-secondary-foreground/85">
                      <Button
                        variant="ghost"
                        size="icon"
                        disabled={notifPage === 0}
                        onClick={() => setNotifPage((prev) => Math.max(prev - 1, 0))}
                        className="h-7 w-7 rounded-lg text-secondary-foreground hover:bg-secondary-foreground/10 disabled:opacity-40"
                      >
                        <IconChevronLeft className="size-4" />
                      </Button>
                      <span className="font-medium">
                        {notifPage + 1} / {totalPages}
                      </span>
                      <Button
                        variant="ghost"
                        size="icon"
                        disabled={notifPage >= totalPages - 1}
                        onClick={() => setNotifPage((prev) => Math.min(prev + 1, totalPages - 1))}
                        className="h-7 w-7 rounded-lg text-secondary-foreground hover:bg-secondary-foreground/10 disabled:opacity-40"
                      >
                        <IconChevronRight className="size-4" />
                      </Button>
                    </div>
                  )}
                </div>
              )}
            </div>

            <Button
              variant="outline"
              size="sm"
              onClick={toggleLocale}
              className="text-xs font-bold px-4 h-9 rounded-xl border-secondary-foreground/25 text-secondary-foreground hover:bg-secondary-foreground/10 hover:text-secondary-foreground hover:border-secondary-foreground/35 hover:shadow-sm bg-transparent transition-all"
            >
              {locale === "en" ? t("toggleToFr") : t("toggleToEn")}
            </Button>

            <Button
              variant="ghost"
              asChild
              size="sm"
              className="hidden sm:flex rounded-xl h-9 px-4 hover:bg-secondary-foreground/5 hover:text-secondary-foreground text-secondary-foreground/80 hover:text-secondary-foreground transition-all font-bold"
            >
              <a
                href="https://github.com/ben-bader/Homely---PFE"
                rel="noopener noreferrer"
                target="_blank"
              >
                {t("github")}
              </a>
            </Button>
          </div>
        </div>
      </header>
    </div>
  );
}