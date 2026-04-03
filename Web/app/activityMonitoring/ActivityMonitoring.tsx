"use client";

import React, { useState, useMemo } from "react";
import { useAuditLogs } from "@/app/activityMonitoring/useAuditLogs";
import { useLogActivities } from "@/app/activityMonitoring/useAuditLogs";

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

import {
  Drawer,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerDescription,
  DrawerTrigger,
  DrawerClose,
} from "@/components/ui/drawer";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

type DateSort = "" | "newest" | "oldest";
type Tab = "admin" | "users";

/* ---------------- FILTER PANEL ---------------- */

function FilterPanel({
  actions,
  actionFilter, setActionFilter,
  dateSort, setDateSort,
  createdAfter, setCreatedAfter,
  createdBefore, setCreatedBefore,
  onClear,
}: {
  actions: string[];
  actionFilter: string; setActionFilter: (v: string) => void;
  dateSort: DateSort; setDateSort: (v: DateSort) => void;
  createdAfter: string; setCreatedAfter: (v: string) => void;
  createdBefore: string; setCreatedBefore: (v: string) => void;
  onClear: () => void;
}) {
  const activeCount = [
    actionFilter !== "",
    dateSort !== "",
    createdAfter !== "",
    createdBefore !== "",
  ].filter(Boolean).length;

  const dateSortOptions: { value: DateSort; label: string; icon: string }[] = [
    { value: "newest", label: "Newest first", icon: "↓" },
    { value: "oldest", label: "Oldest first", icon: "↑" },
  ];

  return (
    <div className="rounded-lg border bg-background shadow-sm overflow-hidden">
      <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/40">
        <div className="flex items-center gap-2">
          <svg className="w-3.5 h-3.5 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L13 13.414V19a1 1 0 01-.553.894l-4 2A1 1 0 017 21v-7.586L3.293 6.707A1 1 0 013 6V4z" />
          </svg>
          <span className="text-xs font-semibold text-foreground uppercase tracking-widest">Filters</span>
          {activeCount > 0 && (
            <span className="inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
              {activeCount}
            </span>
          )}
        </div>
        {activeCount > 0 && (
          <button onClick={onClear} className="text-[11px] text-muted-foreground hover:text-foreground transition-colors font-medium">
            Clear all
          </button>
        )}
      </div>

      <div className="p-4 space-y-5">
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Action / Type</label>
          <div className="flex flex-wrap gap-1.5">
            {["", ...actions].map((a) => (
              <button
                key={a || "ALL"}
                onClick={() => setActionFilter(a)}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  actionFilter === a
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {a || "ALL"}
              </button>
            ))}
          </div>
        </div>

        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Sort by Date</label>
          <div className="flex gap-1.5">
            {dateSortOptions.map(({ value, label, icon }) => (
              <button
                key={value}
                onClick={() => setDateSort(dateSort === value ? "" : value)}
                className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  dateSort === value
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                <span>{icon}</span>
                {label}
              </button>
            ))}
          </div>
        </div>

        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Date Between</label>
          <div className="grid grid-cols-2 gap-2">
            <div className="space-y-1">
              <span className="text-[10px] text-muted-foreground">After</span>
              <Input type="date" value={createdAfter} onChange={(e) => setCreatedAfter(e.target.value)} />
            </div>
            <div className="space-y-1">
              <span className="text-[10px] text-muted-foreground">Before</span>
              <Input type="date" value={createdBefore} onChange={(e) => setCreatedBefore(e.target.value)} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ---------------- JSON DETAILS DRAWER ---------------- */

function DetailsDrawer({ details, title }: { details: any; title?: string }) {
  const formatted = (() => {
    if (!details) return "—";
    try {
      const parsed = typeof details === "string" ? JSON.parse(details) : details;
      return JSON.stringify(parsed, null, 2);
    } catch {
      return typeof details === "string" ? details : JSON.stringify(details, null, 2);
    }
  })();

  return (
    <Drawer direction="right">
      <DrawerTrigger asChild>
        <Button variant="outline" size="sm">View Details</Button>
      </DrawerTrigger>
      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>{title ?? "Details"}</DrawerTitle>
          <DrawerDescription>Full JSON details for this log entry.</DrawerDescription>
        </DrawerHeader>
        <div className="p-4">
          <pre className="bg-muted p-4 rounded-md text-xs overflow-auto max-h-[70vh] whitespace-pre-wrap">
            {formatted}
          </pre>
        </div>
        <div className="p-4 pt-0">
          <DrawerClose asChild>
            <Button variant="outline">Close</Button>
          </DrawerClose>
        </div>
      </DrawerContent>
    </Drawer>
  );
}

/* ---------------- MAIN PAGE ---------------- */

export default function ActivityMonitoring() {
  const { logs, loading: auditLoading, error: auditError } = useAuditLogs();
  const { activities, loading: activityLoading, error: activityError } = useLogActivities();

  const [activeTab, setActiveTab] = useState<Tab>("users");
  const [search, setSearch] = useState("");
  const [actionFilter, setActionFilter] = useState("");
  const [dateSort, setDateSort] = useState<DateSort>("");
  const [createdAfter, setCreatedAfter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [filterOpen, setFilterOpen] = useState(false);

  const clearFilters = () => {
    setActionFilter("");
    setDateSort("");
    setCreatedAfter("");
    setCreatedBefore("");
  };

  const switchTab = (tab: Tab) => {
    setActiveTab(tab);
    clearFilters();
    setSearch("");
    setFilterOpen(false);
  };

  const activeFilterCount = [
    actionFilter !== "",
    dateSort !== "",
    createdAfter !== "",
    createdBefore !== "",
  ].filter(Boolean).length;

  /* ---- AUDIT LOGS ---- */
  const auditActions = useMemo(() => {
    const set = new Set(logs.map((l) => l.action).filter(Boolean));
    return Array.from(set).sort();
  }, [logs]);

  const filteredAuditLogs = useMemo(() => {
    const filtered = logs.filter((log) => {
      const textMatch = [log.action, log.adminName, log.adminEmail, log.adminId]
        .filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
      const actionMatch = !actionFilter || log.action?.toLowerCase() === actionFilter.toLowerCase();
      const ts = log.createdAt ? new Date(log.createdAt).getTime() : null;
      const afterMatch = !createdAfter || (ts !== null && ts >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (ts !== null && ts <= new Date(createdBefore + "T23:59:59Z").getTime());
      return textMatch && actionMatch && afterMatch && beforeMatch;
    });
    if (dateSort === "newest") filtered.sort((a, b) => new Date(b.createdAt ?? 0).getTime() - new Date(a.createdAt ?? 0).getTime());
    if (dateSort === "oldest") filtered.sort((a, b) => new Date(a.createdAt ?? 0).getTime() - new Date(b.createdAt ?? 0).getTime());
    return filtered;
  }, [logs, search, actionFilter, dateSort, createdAfter, createdBefore]);

  /* ---- LOG ACTIVITIES ---- */
  const activityTypes = useMemo(() => {
    const set = new Set(activities.map((a) => a.activityType).filter(Boolean));
    return Array.from(set).sort();
  }, [activities]);

  const filteredActivities = useMemo(() => {
    const filtered = activities.filter((act) => {
      const textMatch = [act.activityType, act.entityType, act.description, act.adminName, act.adminEmail]
        .filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
      const actionMatch = !actionFilter || act.activityType?.toLowerCase() === actionFilter.toLowerCase();
      const ts = act.createdAt ? new Date(act.createdAt).getTime() : null;
      const afterMatch = !createdAfter || (ts !== null && ts >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (ts !== null && ts <= new Date(createdBefore + "T23:59:59Z").getTime());
      return textMatch && actionMatch && afterMatch && beforeMatch;
    });
    if (dateSort === "newest") filtered.sort((a, b) => new Date(b.createdAt ?? 0).getTime() - new Date(a.createdAt ?? 0).getTime());
    if (dateSort === "oldest") filtered.sort((a, b) => new Date(a.createdAt ?? 0).getTime() - new Date(b.createdAt ?? 0).getTime());
    return filtered;
  }, [activities, search, actionFilter, dateSort, createdAfter, createdBefore]);

  const isLoading = activeTab === "admin" ? auditLoading : activityLoading;
  const isError = activeTab === "admin" ? auditError : activityError;
  const currentActions = activeTab === "admin" ? auditActions : activityTypes;
  const currentCount = activeTab === "admin" ? filteredAuditLogs.length : filteredActivities.length;

  return (
    <div className="p-6 space-y-6">
      <div>
        <h2 className="text-lg font-semibold">Activity Monitoring</h2>
        <p className="text-muted-foreground text-sm mt-1">
          All actions are recorded here.
        </p>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 border-b">
        {(["users", "admin"] as Tab[]).map((tab) => (
          <button
            key={tab}
            onClick={() => switchTab(tab)}
            className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors -mb-px ${
              activeTab === tab
                ? "border-primary text-primary"
                : "border-transparent text-muted-foreground hover:text-foreground"
            }`}
          >
            {tab === "users" ? "Users Activities" : "Admin Logs"}
          </button>
        ))}
      </div>

      {/* Search + Filter */}
      <div className="flex gap-2">
        <Input
          placeholder={
            activeTab === "admin"
              ? "Search by action or admin..."
              : "Search by type, entity or description..."
          }
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <Button
          variant="outline"
          onClick={() => setFilterOpen((v) => !v)}
          className="relative"
        >
          Filter
          {activeFilterCount > 0 && (
            <span className="absolute -top-1.5 -right-1.5 inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
              {activeFilterCount}
            </span>
          )}
        </Button>
      </div>

      {filterOpen && (
        <FilterPanel
          actions={currentActions}
          actionFilter={actionFilter} setActionFilter={setActionFilter}
          dateSort={dateSort} setDateSort={setDateSort}
          createdAfter={createdAfter} setCreatedAfter={setCreatedAfter}
          createdBefore={createdBefore} setCreatedBefore={setCreatedBefore}
          onClear={clearFilters}
        />
      )}

      <span className="text-xs text-muted-foreground">
        {currentCount} result{currentCount !== 1 ? "s" : ""}
        {(activeFilterCount > 0 || search) && " (filtered)"}
      </span>

      {/* Content */}
      {isLoading ? (
        <div className="py-12 text-center text-sm text-muted-foreground">Loading…</div>
      ) : isError ? (
        <div className="py-12 text-center text-sm text-destructive">{isError}</div>
      ) : currentCount === 0 ? (
        <div className="rounded-lg border py-12 text-center text-sm text-muted-foreground">
          No logs match your filters.
        </div>
      ) : activeTab === "admin" ? (
        <div className="rounded-lg border overflow-auto">
          <Table>
            <TableHeader className="bg-primary text-white">
              <TableRow>
                <TableHead className="text-white">Time</TableHead>
                <TableHead className="text-white">Admin</TableHead>
                <TableHead className="text-white">Action</TableHead>
                <TableHead className="text-white">Details</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredAuditLogs.map((log) => (
                <TableRow key={log.id}>
                  <TableCell className="whitespace-nowrap">
                    {log.createdAt ? new Date(log.createdAt).toLocaleString() : "—"}
                  </TableCell>
                  <TableCell>
                    {log.adminName ?? log.adminEmail ?? log.adminId ?? "—"}
                  </TableCell>
                  <TableCell>{log.action ?? "—"}</TableCell>
                  <TableCell>
                    {log.details
                      ? <DetailsDrawer details={log.details} title="Admin Log Details" />
                      : "—"}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      ) : (
        <div className="rounded-lg border overflow-auto">
          <Table>
            <TableHeader className="bg-primary text-white">
              <TableRow>
                <TableHead className="text-white">Time</TableHead>
                <TableHead className="text-white">Admin</TableHead>
                <TableHead className="text-white">Type</TableHead>
                <TableHead className="text-white">Entity</TableHead>
                <TableHead className="text-white">Description</TableHead>
                <TableHead className="text-white">Metadata</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredActivities.map((act) => (
                <TableRow key={act.id}>
                  <TableCell className="whitespace-nowrap">
                    {act.createdAt ? new Date(act.createdAt).toLocaleString() : "—"}
                  </TableCell>
                  <TableCell>
                    {act.adminName ?? act.adminEmail ?? act.adminId ?? "—"}
                  </TableCell>
                  <TableCell>
                    <span className="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-semibold bg-muted">
                      {act.activityType ?? "—"}
                    </span>
                  </TableCell>
                  <TableCell>
                    <span className="text-xs text-muted-foreground">{act.entityType}</span>
                    <span className="block text-xs font-mono truncate max-w-[120px]">{act.entityId}</span>
                  </TableCell>
                  <TableCell className="max-w-[200px] truncate text-sm">
                    {act.description ?? "—"}
                  </TableCell>
                  <TableCell>
                    {act.metadata
                      ? <DetailsDrawer details={act.metadata} title="Users Activity Metadata" />
                      : "—"}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      )}
    </div>
  );
}
