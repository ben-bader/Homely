"use client";

import { useState, useEffect } from "react";
import { useNotifications, type Notification } from "@/hooks/useNotifications";

// ─── Helpers ──────────────────────────────────────────────────────────────────
function timeAgo(dateStr: string): string {
  const diff = Date.now() - new Date(dateStr).getTime();
  const m = Math.floor(diff / 60000);
  if (m < 1) return "Just now";
  if (m < 60) return `${m}m ago`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h ago`;
  return `${Math.floor(h / 24)}d ago`;
}

// Derive type from title keywords since your NotificationDto doesn't expose a type field.
// Remove this and use n.type directly if you add it to your backend DTO.
function inferType(n: Notification): "alert" | "success" | "warning" | "info" {
  const t = n.title.toLowerCase();
  if (t.includes("overdue") || t.includes("request") || t.includes("message")) return "alert";
  if (t.includes("received") || t.includes("signed") || t.includes("payment")) return "success";
  if (t.includes("expir") || t.includes("late") || t.includes("warn")) return "warning";
  return "info";
}

const TYPE_CONFIG = {
  alert:   { label: "Alert",   badgeBg: "bg-destructive/10",        badgeText: "text-destructive",       badgeBorder: "border-destructive/25",       bar: "bg-destructive",       dot: "bg-destructive"       },
  success: { label: "Success", badgeBg: "bg-[var(--success)]/10",   badgeText: "text-[var(--success)]",  badgeBorder: "border-[var(--success)]/25",  bar: "bg-[var(--success)]",  dot: "bg-[var(--success)]"  },
  warning: { label: "Warning", badgeBg: "bg-[var(--warning)]/10",   badgeText: "text-[var(--warning)]",  badgeBorder: "border-[var(--warning)]/25",  bar: "bg-[var(--warning)]",  dot: "bg-[var(--warning)]"  },
  info:    { label: "Info",    badgeBg: "bg-primary/10",            badgeText: "text-primary",           badgeBorder: "border-primary/25",           bar: "bg-primary",           dot: "bg-primary"           },
} as const;

type FilterType = "all" | "unread" | "alert" | "success" | "warning" | "info";

// ─── Stat Card ────────────────────────────────────────────────────────────────
function StatCard({ label, value, colorVar }: { label: string; value: number; colorVar?: string }) {
  return (
    <div className="flex flex-col gap-1.5 bg-card border border-border rounded-lg px-5 py-3.5">
      <span
        className="text-2xl font-semibold tracking-tight text-foreground"
        style={colorVar ? { color: `var(${colorVar})` } : undefined}
      >
        {value}
      </span>
      <span className="text-xs text-muted-foreground font-medium">{label}</span>
    </div>
  );
}

// ─── Filter Pill ──────────────────────────────────────────────────────────────
function FilterPill({
  label, active, count, onClick,
}: {
  label: string; active: boolean; count: number; onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-md text-sm font-medium border transition-all duration-150
        ${active
          ? "bg-primary text-primary-foreground border-primary"
          : "bg-transparent text-muted-foreground border-border hover:bg-accent hover:text-foreground"
        }`}
    >
      {label}
      {count > 0 && (
        <span className={`text-xs font-semibold px-1.5 py-0.5 rounded-sm leading-none min-w-[18px] text-center
          ${active ? "bg-white/20 text-white" : "bg-muted text-muted-foreground"}`}>
          {count}
        </span>
      )}
    </button>
  );
}

// ─── Notification Row ─────────────────────────────────────────────────────────
function NotificationRow({
  n, index, selected, onSelect, onRead,
}: {
  n: Notification; index: number; selected: boolean;
  onSelect: (id: string) => void; onRead: (id: string) => void;
}) {
  const [visible, setVisible] = useState(false);
  const type = inferType(n);
  const cfg = TYPE_CONFIG[type];

  useEffect(() => {
    const t = setTimeout(() => setVisible(true), index * 45);
    return () => clearTimeout(t);
  }, [index]);

  return (
    <div
      onClick={() => { onSelect(n.id); if (!n.read) onRead(n.id); }}
      style={{ transitionDelay: `${index * 35}ms` }}
      className={`flex items-center gap-4 px-6 py-4 border-b border-border cursor-pointer transition-all duration-200
        ${selected ? "bg-accent" : "hover:bg-accent/60"}
        ${visible ? "opacity-100 translate-x-0" : "opacity-0 -translate-x-1"}`}
    >
      {/* Unread bar */}
      <div className={`w-[3px] self-stretch rounded-full flex-shrink-0 transition-all duration-300 ${n.read ? "bg-transparent" : cfg.bar}`} />

      {/* Type badge */}
      <span className={`text-xs font-semibold px-2.5 py-0.5 rounded border flex-shrink-0 w-[76px] text-center
        ${cfg.badgeBg} ${cfg.badgeText} ${cfg.badgeBorder}`}>
        {cfg.label}
      </span>

      {/* Content */}
      <div className="flex-1 min-w-0">
        <p className={`text-sm truncate transition-colors ${n.read ? "font-normal text-muted-foreground" : "font-semibold text-foreground"}`}>
          {n.title}
        </p>
        <p className="text-xs text-muted-foreground truncate mt-0.5">{n.message}</p>
      </div>

      {/* Time */}
      <span className="text-xs text-muted-foreground flex-shrink-0 tabular-nums font-mono">
        {timeAgo(n.createdAt)}
      </span>

      {/* Unread dot */}
      <div className={`w-2 h-2 rounded-full flex-shrink-0 transition-all duration-300 ${n.read ? "opacity-0" : `opacity-100 ${cfg.dot}`}`} />
    </div>
  );
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────
function SkeletonRow() {
  return (
    <div className="flex items-center gap-4 px-6 py-4 border-b border-border animate-pulse">
      <div className="w-[3px] h-10 bg-muted rounded-full" />
      <div className="w-[76px] h-5 bg-muted rounded" />
      <div className="flex-1 flex flex-col gap-1.5">
        <div className="h-3.5 bg-muted rounded w-48" />
        <div className="h-3 bg-muted rounded w-72" />
      </div>
      <div className="w-10 h-3 bg-muted rounded" />
      <div className="w-2 h-2 bg-muted rounded-full" />
    </div>
  );
}

// ─── Detail Panel ─────────────────────────────────────────────────────────────
function DetailPanel({ n, onClose }: { n: Notification; onClose: () => void }) {
  const cfg = TYPE_CONFIG[inferType(n)];
  return (
    <div className="w-80 flex-shrink-0 border-l border-border flex flex-col bg-card"
      style={{ animation: "panelSlide 0.18s ease" }}>
      <div className="flex items-center justify-between px-5 py-4 border-b border-border">
        <h3 className="text-sm font-semibold text-foreground">Details</h3>
        <button
          onClick={onClose}
          className="w-7 h-7 flex items-center justify-center rounded-md text-muted-foreground hover:text-foreground hover:bg-accent transition-colors text-base leading-none"
        >✕</button>
      </div>
      <div className="p-5 flex flex-col gap-5 flex-1 overflow-y-auto">
        <span className={`self-start text-xs font-semibold px-2.5 py-1 rounded border ${cfg.badgeBg} ${cfg.badgeText} ${cfg.badgeBorder}`}>
          {cfg.label}
        </span>
        <div className="flex flex-col gap-2">
          <h4 className="text-base font-semibold text-foreground leading-snug">{n.title}</h4>
          <p className="text-sm text-muted-foreground leading-relaxed">{n.message}</p>
        </div>
        <div className="border-t border-border" />
        <dl className="flex flex-col gap-3">
          {([
            ["Status",   n.read ? "Read" : "Unread", !n.read ? "--warning" : undefined],
            ["Received", new Date(n.createdAt).toLocaleString(), undefined],
            ["ID",       `#${n.id}`, undefined],
          ] as [string, string, string | undefined][]).map(([k, v, colorVar]) => (
            <div key={k} className="flex items-center justify-between">
              <dt className="text-xs text-muted-foreground">{k}</dt>
              <dd className="text-xs font-medium text-foreground" style={colorVar ? { color: `var(${colorVar})` } : undefined}>
                {v}
              </dd>
            </div>
          ))}
        </dl>
      </div>
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────
export default function NotificationsPage() {
  const {
    notifications,
    unreadCount,
    loading,
    error,
    markAsRead,
    fetchNotifications,
  } = useNotifications();

  const [filter, setFilter]   = useState<FilterType>("all");
  const [selected, setSelected] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const handleRefresh = async () => {
    setRefreshing(true);
    await fetchNotifications();
    setRefreshing(false);
  };

  const handleMarkAllRead = async () => {
    // Call markAsRead for every unread notification (your controller handles per-ID)
    await Promise.all(
      notifications.filter((n) => !n.read).map((n) => markAsRead(n.id))
    );
  };

  const filtered = notifications.filter((n) => {
    if (filter === "all") return true;
    if (filter === "unread") return !n.read;
    return inferType(n) === filter;
  });

  const selectedNotif = selected ? notifications.find((n) => n.id === selected) : null;

  const counts: Record<FilterType, number> = {
    all:     notifications.length,
    unread:  unreadCount,
    alert:   notifications.filter((n) => inferType(n) === "alert"   && !n.read).length,
    warning: notifications.filter((n) => inferType(n) === "warning" && !n.read).length,
    success: notifications.filter((n) => inferType(n) === "success" && !n.read).length,
    info:    notifications.filter((n) => inferType(n) === "info"    && !n.read).length,
  };

  return (
    <>
      <style>{`
        @keyframes panelSlide { from { opacity:0; transform:translateX(6px); } to { opacity:1; transform:translateX(0); } }
        @keyframes rotateSpin { to { transform:rotate(360deg); } }
        .spin-icon { animation: rotateSpin 0.7s linear infinite; }
      `}</style>

      <div className="min-h-screen bg-background flex flex-col">

        {/* Header */}
        <header className="sticky top-0 z-10 bg-card border-b border-border px-6 py-4 flex items-center justify-between gap-4">
          <div>
            <h1 className="text-xl font-semibold text-foreground tracking-tight">Notifications</h1>
            <p className="text-sm text-muted-foreground mt-0.5">
              {loading
                ? "Loading..."
                : unreadCount > 0
                ? `${unreadCount} unread notification${unreadCount > 1 ? "s" : ""}`
                : "You're all caught up"}
            </p>
          </div>
          <div className="flex items-center gap-2">
            {unreadCount > 0 && (
              <button
                onClick={handleMarkAllRead}
                className="text-sm font-medium text-muted-foreground hover:text-foreground px-3 py-1.5 transition-colors"
              >
                Mark all read
              </button>
            )}
            <button
              onClick={handleRefresh}
              className="inline-flex items-center gap-2 text-sm font-medium px-4 py-2 rounded-lg border border-border bg-card hover:bg-accent text-foreground transition-colors"
            >
              <span className={refreshing ? "spin-icon inline-block" : "inline-block"}>↻</span>
              Refresh
            </button>
          </div>
        </header>

        {/* Stats */}
        <div className="px-6 py-4 border-b border-border bg-secondary grid grid-cols-2 sm:grid-cols-4 gap-3">
          <StatCard label="Total"    value={notifications.length} />
          <StatCard label="Unread"   value={unreadCount}          colorVar="--warning"     />
          <StatCard label="Alerts"   value={counts.alert}         colorVar="--destructive" />
          <StatCard label="Warnings" value={counts.warning}       colorVar="--warning"     />
        </div>

        {/* Filters */}
        <div className="px-6 py-3 flex items-center gap-2 flex-wrap border-b border-border bg-card">
          {(["all", "unread", "alert", "warning", "success", "info"] as FilterType[]).map((f) => (
            <FilterPill
              key={f}
              label={f.charAt(0).toUpperCase() + f.slice(1)}
              active={filter === f}
              count={counts[f]}
              onClick={() => setFilter(f)}
            />
          ))}
        </div>

        {/* Body */}
        <div className="flex flex-1 overflow-hidden">
          <div className="flex-1 flex flex-col overflow-hidden">

            {/* Column headers */}
            <div className="flex items-center gap-4 px-6 py-2.5 border-b border-border bg-secondary">
              <div className="w-[3px]" />
              <span className="text-xs font-medium text-muted-foreground w-[76px]">Type</span>
              <span className="flex-1 text-xs font-medium text-muted-foreground">Content</span>
              <span className="text-xs font-medium text-muted-foreground w-12 text-right">Time</span>
              <div className="w-2" />
            </div>

            {/* List */}
            <div className="flex-1 overflow-y-auto">
              {loading ? (
                Array.from({ length: 5 }).map((_, i) => <SkeletonRow key={i} />)
              ) : error ? (
                <div className="flex flex-col items-center justify-center h-48 gap-3">
                  <p className="text-sm font-medium text-destructive">{error}</p>
                  <button onClick={handleRefresh} className="text-sm text-muted-foreground underline underline-offset-2">
                    Try again
                  </button>
                </div>
              ) : filtered.length === 0 ? (
                <div className="flex flex-col items-center justify-center h-48 gap-2 text-center px-6">
                  <div className="w-10 h-10 rounded-full bg-muted flex items-center justify-center text-muted-foreground text-lg">○</div>
                  <p className="text-sm font-medium text-foreground">No notifications</p>
                  <p className="text-xs text-muted-foreground">
                    {filter !== "all" ? "Try a different filter" : "You're all caught up"}
                  </p>
                </div>
              ) : (
                filtered.map((n, i) => (
                  <NotificationRow
                    key={n.id}
                    n={n}
                    index={i}
                    selected={selected === n.id}
                    onSelect={setSelected}
                    onRead={markAsRead}
                  />
                ))
              )}
            </div>

            {/* Footer */}
            <div className="px-6 py-3 border-t border-border bg-secondary flex items-center justify-between">
              <span className="text-xs text-muted-foreground">
                {filtered.length} result{filtered.length !== 1 ? "s" : ""}
              </span>
              <span className="text-xs text-muted-foreground tabular-nums">
                Updated {new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })}
              </span>
            </div>
          </div>

          {/* Detail panel */}
          {selectedNotif && (
            <DetailPanel n={selectedNotif} onClose={() => setSelected(null)} />
          )}
        </div>
      </div>
    </>
  );
}