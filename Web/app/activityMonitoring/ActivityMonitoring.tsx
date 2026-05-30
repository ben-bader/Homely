"use client";

import React, { useState, useMemo, useEffect } from "react";
import { useLocale } from "next-intl";
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
  DrawerFooter,
} from "@/components/ui/drawer";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { FaEye, FaArrowLeft, FaArrowRight } from "react-icons/fa";
import { Badge } from "@/components/ui/badge";

type DateSort = "" | "newest" | "oldest";
type Tab = "admin" | "users";
type Language = "en" | "fr";

const dict = {
  en: {
    title: "Activity Monitoring",
    subtitle: "Review system-wide actions and user activities.",
    tabUsers: "Users Activities",
    tabAdmin: "Admin Logs",
    searchUsers: "Search by user, type or entity...",
    searchAdmin: "Search by action or admin...",
    filters: "Filters",
    clearAll: "Clear all",
    activityType: "Activity Type",
    action: "Action",
    entityType: "Entity Type",
    sortByDate: "Sort by Date",
    newest: "Newest first",
    oldest: "Oldest first",
    createdBetween: "Created Between",
    after: "After",
    before: "Before",
    all: "ALL",
    loading: "Loading activities...",
    noResults: "No records found.",
    colTime: "Time",
    colUser: "User",
    colShowMore: "Show More",
    details: {
      userTitle: "Activity Details",
      adminTitle: "Audit Log Details",
      desc: "Full information regarding this recorded action.",
      coreInfo: "Core Info",
      timestamp: "Timestamp",
      entity: "Entity",
      userActor: "User / Actor",
      name: "Name",
      email: "Email",
      description: "Description",
      dataChanges: "Data Changes / Details",
      close: "Close"
    }
  },
  fr: {
    title: "Suivi des Activités",
    subtitle: "Consulter les actions système et les activités des utilisateurs.",
    tabUsers: "Activités des Utilisateurs",
    tabAdmin: "Journaux Admin",
    searchUsers: "Rechercher par utilisateur, type ou entité...",
    searchAdmin: "Rechercher par action ou administrateur...",
    filters: "Filtres",
    clearAll: "Tout effacer",
    activityType: "Type d'activité",
    action: "Action",
    entityType: "Type d'entité",
    sortByDate: "Trier par date",
    newest: "Plus récent",
    oldest: "Plus ancien",
    createdBetween: "Créé entre",
    after: "Après",
    before: "Avant",
    all: "TOUT",
    loading: "Chargement des activités...",
    noResults: "Aucun enregistrement trouvé.",
    colTime: "Date/Heure",
    colUser: "Utilisateur",
    colShowMore: "Détails",
    details: {
      userTitle: "Détails de l'Activité",
      adminTitle: "Détails du Journal d'Audit",
      desc: "Informations complètes sur cette action enregistrée.",
      coreInfo: "Informations de Base",
      timestamp: "Date/Heure",
      entity: "Entité",
      userActor: "Utilisateur / Acteur",
      name: "Nom",
      email: "E-mail",
      description: "Description",
      dataChanges: "Modifications de Données",
      close: "Fermer"
    }
  }
};

/* ---------------- HELPERS ---------------- */

function fmtFull(v: any, locale: string = "en-US") {
  if (!v) return "—";
  const d = new Date(v);
  return isNaN(d.getTime()) ? "—" : d.toLocaleString(locale);
}

/* ---------------- INFO ROW FOR DRAWER ---------------- */

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[10px] uppercase tracking-widest text-muted-foreground font-bold">{label}</span>
      <div className="text-sm font-medium text-foreground">{value ?? "—"}</div>
    </div>
  );
}

/* ---------------- LOG DETAILS DRAWER ---------------- */

function LogDetailsDrawer({ log, type, t, lang }: { log: any; type: Tab; t: any; lang: string }) {
  const isUserActivity = type === "users";
  const dateLocale = lang === "fr" ? "fr-FR" : "en-US";

  const formattedChanges = useMemo(() => {
    const data = isUserActivity ? log.changes : log.details;
    if (!data) return null;
    try {
      const parsed = typeof data === "string" ? JSON.parse(data) : data;
      return JSON.stringify(parsed, null, 2);
    } catch {
      return String(data);
    }
  }, [log, isUserActivity]);

  return (
    <Drawer direction="right">
      <DrawerTrigger asChild>
        <Button variant="ghost" size="icon" className="h-8 w-8">
          <FaEye className="h-4 w-4 text-muted-foreground hover:text-primary" />
        </Button>
      </DrawerTrigger>
      <DrawerContent className="flex flex-col max-w-md ml-auto h-full">
        <DrawerHeader className="border-b">
          <DrawerTitle>{isUserActivity ? t.details.userTitle : t.details.adminTitle}</DrawerTitle>
          <DrawerDescription>{t.details.desc}</DrawerDescription>
        </DrawerHeader>

        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          <section className="space-y-4">
            <p className="text-[10px] font-bold uppercase tracking-tight text-primary border-b pb-1">{t.details.coreInfo}</p>
            <InfoRow label={t.details.timestamp} value={fmtFull(log.createdAt, dateLocale)} />
            <InfoRow label={isUserActivity ? t.activityType : t.action} value={<Badge variant="outline">{isUserActivity ? log.activityType : log.action}</Badge>} />
            {isUserActivity && <InfoRow label={t.details.entity} value={log.entityType} />}
          </section>

          <section className="space-y-4">
            <p className="text-[10px] font-bold uppercase tracking-tight text-primary border-b pb-1">{t.details.userActor}</p>
            <InfoRow label={t.details.name} value={isUserActivity ? log.userName : log.adminName} />
            <InfoRow label={t.details.email} value={isUserActivity ? log.userEmail : log.adminEmail} />
          </section>

          {log.description && (
            <section className="space-y-4">
              <p className="text-[10px] font-bold uppercase tracking-tight text-primary border-b pb-1">{t.details.description}</p>
              <p className="text-sm text-muted-foreground italic">"{log.description}"</p>
            </section>
          )}

          {formattedChanges && (
            <section className="space-y-4">
              <p className="text-[10px] font-bold uppercase tracking-tight text-primary border-b pb-1">{t.details.dataChanges}</p>
              <pre className="bg-muted p-3 rounded text-[11px] font-mono overflow-x-auto whitespace-pre-wrap">
                {formattedChanges}
              </pre>
            </section>
          )}
        </div>

        <DrawerFooter className="border-t">
          <DrawerClose asChild>
            <Button variant="outline" className="w-full bg-black hover:bg-gray-900 text-white border-gray-700">{t.details.close}</Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}

/* ---------------- FILTER PANEL ---------------- */

function FilterPanel({
  tab,
  actionFilter, setActionFilter,
  entityTypeFilter, setEntityTypeFilter,
  dateSort, setDateSort,
  createdAfter, setCreatedAfter,
  createdBefore, setCreatedBefore,
  onClear,
  activityTypeOptions,
  entityTypeOptions,
  t,
}: {
  tab: Tab;
  actionFilter: string; setActionFilter: (v: string) => void;
  entityTypeFilter: string; setEntityTypeFilter: (v: string) => void;
  dateSort: DateSort; setDateSort: (v: DateSort) => void;
  createdAfter: string; setCreatedAfter: (v: string) => void;
  createdBefore: string; setCreatedBefore: (v: string) => void;
  onClear: () => void;
  activityTypeOptions: string[];
  entityTypeOptions: string[];
  t: any;
}) {
  const activeCount = [
    actionFilter !== "",
    entityTypeFilter !== "",
    dateSort !== "",
    createdAfter !== "",
    createdBefore !== "",
  ].filter(Boolean).length;

  const dateSortOptions: { value: DateSort; label: string; icon: string }[] = [
    { value: "newest", label: t.newest, icon: "↓" },
    { value: "oldest", label: t.oldest, icon: "↑" },
  ];

  return (
    <div className="rounded-lg border bg-background shadow-sm overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/40">
        <div className="flex items-center gap-2">
          <svg className="w-3.5 h-3.5 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L13 13.414V19a1 1 0 01-.553.894l-4 2A1 1 0 017 21v-7.586L3.293 6.707A1 1 0 013 6V4z" />
          </svg>
          <span className="text-xs font-semibold text-foreground uppercase tracking-widest">{t.filters}</span>
          {activeCount > 0 && (
            <span className="inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
              {activeCount}
            </span>
          )}
        </div>
        {activeCount > 0 && (
          <button onClick={onClear} className="text-[11px] text-muted-foreground hover:text-foreground transition-colors font-medium">
            {t.clearAll}
          </button>
        )}
      </div>

      <div className="p-4 space-y-5">
        {/* Activity / Action Type */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">
            {tab === "users" ? t.activityType : t.action}
          </label>
          <div className="flex flex-wrap gap-1.5">
            <button
              onClick={() => setActionFilter("")}
              className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                actionFilter === ""
                  ? "bg-primary text-primary-foreground border-primary"
                  : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
              }`}
            >
              {t.all}
            </button>
            {activityTypeOptions.map((type) => (
              <button
                key={type}
                onClick={() => setActionFilter(actionFilter === type ? "" : type)}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  actionFilter === type
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {type}
              </button>
            ))}
          </div>
        </div>

        {/* Entity Type — users tab only */}
        {tab === "users" && entityTypeOptions.length > 0 && (
          <div className="space-y-2">
            <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.entityType}</label>
            <div className="flex flex-wrap gap-1.5">
              <button
                onClick={() => setEntityTypeFilter("")}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  entityTypeFilter === ""
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {t.all}
              </button>
              {entityTypeOptions.map((type) => (
                <button
                  key={type}
                  onClick={() => setEntityTypeFilter(entityTypeFilter === type ? "" : type)}
                  className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                    entityTypeFilter === type
                      ? "bg-primary text-primary-foreground border-primary"
                      : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                  }`}
                >
                  {type}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Date sort */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.sortByDate}</label>
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

        {/* Date range */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.createdBetween}</label>
          <div className="grid grid-cols-2 gap-2">
            <div className="space-y-1">
              <span className="text-[10px] text-muted-foreground">{t.after}</span>
              <Input type="date" value={createdAfter} onChange={(e) => setCreatedAfter(e.target.value)} />
            </div>
            <div className="space-y-1">
              <span className="text-[10px] text-muted-foreground">{t.before}</span>
              <Input type="date" value={createdBefore} onChange={(e) => setCreatedBefore(e.target.value)} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ---------------- MAIN PAGE ---------------- */

export default function ActivityMonitoring() {
  const locale = useLocale();
  const lang = (locale === "fr" ? "fr" : "en") as Language;
  const t = dict[lang];
  const dateLocale = lang === "fr" ? "fr-FR" : "en-US";

  const { logs, loading: auditLoading, error: auditError } = useAuditLogs();
  const { activities, loading: activityLoading, error: activityError } = useLogActivities();

  const [activeTab, setActiveTab] = useState<Tab>("users");
  const [search, setSearch] = useState("");
  const [actionFilter, setActionFilter] = useState("");
  const [entityTypeFilter, setEntityTypeFilter] = useState("");
  const [dateSort, setDateSort] = useState<DateSort>("newest");
  const [createdAfter, setCreatedAfter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [filterOpen, setFilterOpen] = useState(false);
  const [currentPage, setCurrentPage] = useState(0);

  // Reset page when tab, search, or filters change
  useEffect(() => {
    setCurrentPage(0);
  }, [activeTab, search, actionFilter, entityTypeFilter, dateSort, createdAfter, createdBefore]);

  const clearFilters = () => {
    setActionFilter("");
    setEntityTypeFilter("");
    setDateSort("newest");
    setCreatedAfter("");
    setCreatedBefore("");
  };

  // Reset filters when switching tabs
  const handleTabChange = (tab: Tab) => {
    setActiveTab(tab);
    clearFilters();
    setFilterOpen(false);
  };

  /* ---- Dynamic options derived from data ---- */
  const activityTypeOptions = useMemo(() => {
    if (activeTab === "users") {
      return [...new Set(activities.map((a) => a.activityType).filter((x): x is string => !!x))];
    }
    return [...new Set(logs.map((l) => l.action).filter((x): x is string => !!x))];
  }, [activeTab, activities, logs]);

  const entityTypeOptions = useMemo(() => {
    return [...new Set(activities.map((a) => a.entityType).filter((x): x is string => !!x))];
  }, [activities]);

  /* ---- Active filter count ---- */
  const activeFilterCount = [
    actionFilter !== "",
    entityTypeFilter !== "",
    dateSort !== "" && dateSort !== "newest",
    createdAfter !== "",
    createdBefore !== "",
  ].filter(Boolean).length;

  /* ---- LOG ACTIVITIES (USERS) ---- */
  const filteredActivities = useMemo(() => {
    let filtered = activities.filter((act) => {
      const textMatch = [act.activityType, act.entityType, act.description, act.userName, act.userEmail]
        .filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
      const typeMatch = !actionFilter || act.activityType?.toLowerCase() === actionFilter.toLowerCase();
      const entityMatch = !entityTypeFilter || act.entityType?.toLowerCase() === entityTypeFilter.toLowerCase();
      const ts = act.createdAt ? new Date(act.createdAt).getTime() : 0;
      const afterMatch = !createdAfter || ts >= new Date(createdAfter).getTime();
      const beforeMatch = !createdBefore || ts <= new Date(createdBefore + "T23:59:59Z").getTime();
      return textMatch && typeMatch && entityMatch && afterMatch && beforeMatch;
    });
    return dateSort === "oldest"
      ? filtered.sort((a, b) => new Date(a.createdAt || 0).getTime() - new Date(b.createdAt || 0).getTime())
      : filtered.sort((a, b) => new Date(b.createdAt || 0).getTime() - new Date(a.createdAt || 0).getTime());
  }, [activities, search, actionFilter, entityTypeFilter, dateSort, createdAfter, createdBefore]);

  /* ---- AUDIT LOGS (ADMIN) ---- */
  const filteredAuditLogs = useMemo(() => {
    let filtered = logs.filter((log) => {
      const textMatch = [log.action, log.adminName, log.adminEmail].filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
      const actionMatch = !actionFilter || log.action?.toLowerCase() === actionFilter.toLowerCase();
      const ts = log.createdAt ? new Date(log.createdAt).getTime() : 0;
      const afterMatch = !createdAfter || ts >= new Date(createdAfter).getTime();
      const beforeMatch = !createdBefore || ts <= new Date(createdBefore + "T23:59:59Z").getTime();
      return textMatch && actionMatch && afterMatch && beforeMatch;
    });
    return dateSort === "oldest"
      ? filtered.sort((a, b) => new Date(a.createdAt || 0).getTime() - new Date(b.createdAt || 0).getTime())
      : filtered.sort((a, b) => new Date(b.createdAt || 0).getTime() - new Date(a.createdAt || 0).getTime());
  }, [logs, search, actionFilter, dateSort, createdAfter, createdBefore]);

  const isLoading = activeTab === "admin" ? auditLoading : activityLoading;
  const currentData = activeTab === "admin" ? filteredAuditLogs : filteredActivities;

  // Pagination calculations
  const itemsPerPage = 10;
  const totalPages = Math.ceil(currentData.length / itemsPerPage);
  const paginatedData = useMemo(() => {
    return currentData.slice(currentPage * itemsPerPage, (currentPage + 1) * itemsPerPage);
  }, [currentData, currentPage]);

  return (
    <div className="p-6 space-y-6">
      <div>
        <h2 className="text-xl font-bold">{t.title}</h2>
        <p className="text-muted-foreground text-sm">{t.subtitle}</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 border-b">
        {(["users", "admin"] as Tab[]).map((tab) => (
          <button
            key={tab}
            onClick={() => handleTabChange(tab)}
            className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors -mb-px ${
              activeTab === tab ? "border-primary text-primary" : "border-transparent text-muted-foreground hover:text-foreground"
            }`}
          >
            {tab === "users" ? t.tabUsers : t.tabAdmin}
          </button>
        ))}
      </div>

      {/* Search + Filter toggle */}
      <div className="flex gap-2">
        <Input
          placeholder={activeTab === "users" ? t.searchUsers : t.searchAdmin}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <Button
          variant="outline"
          onClick={() => setFilterOpen((v) => !v)}
          className="relative shrink-0"
        >
          <svg className="w-3.5 h-3.5 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L13 13.414V19a1 1 0 01-.553.894l-4 2A1 1 0 017 21v-7.586L3.293 6.707A1 1 0 013 6V4z" />
          </svg>
          {t.filters}
          {activeFilterCount > 0 && (
            <span className="absolute -top-1.5 -right-1.5 inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
              {activeFilterCount}
            </span>
          )}
        </Button>
      </div>

      {/* Filter panel */}
      {filterOpen && (
        <FilterPanel
          tab={activeTab}
          actionFilter={actionFilter} setActionFilter={setActionFilter}
          entityTypeFilter={entityTypeFilter} setEntityTypeFilter={setEntityTypeFilter}
          dateSort={dateSort} setDateSort={setDateSort}
          createdAfter={createdAfter} setCreatedAfter={setCreatedAfter}
          createdBefore={createdBefore} setCreatedBefore={setCreatedBefore}
          onClear={clearFilters}
          activityTypeOptions={activityTypeOptions}
          entityTypeOptions={entityTypeOptions}
          t={t}
        />
      )}

      {/* Table */}
      <div className="rounded-lg border overflow-hidden">
        <Table>
          <TableHeader className="bg-primary hover:bg-primary">
            <TableRow>
              <TableHead className="text-white w-[180px]">{t.colTime}</TableHead>
              <TableHead className="text-white">{t.colUser}</TableHead>
              <TableHead className="text-white">{activeTab === "users" ? t.activityType : t.action}</TableHead>
              {activeTab === "users" && <TableHead className="text-white">{t.entityType}</TableHead>}
              <TableHead className="text-white text-right">{t.colShowMore}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading ? (
              <TableRow><TableCell colSpan={6} className="text-center py-10">{t.loading}</TableCell></TableRow>
            ) : currentData.length === 0 ? (
              <TableRow><TableCell colSpan={6} className="text-center py-10 text-muted-foreground">{t.noResults}</TableCell></TableRow>
            ) : (
              paginatedData.map((item: any) => (
                <TableRow key={item.id}>
                  <TableCell className="text-xs font-medium">
                    {fmtFull(item.createdAt, dateLocale)}
                  </TableCell>
                  <TableCell>
                    <div className="flex flex-col">
                      <span className="text-sm font-semibold">{activeTab === "users" ? item.userName : item.adminName}</span>
                      <span className="text-[11px] text-muted-foreground">{activeTab === "users" ? item.userEmail : item.adminEmail}</span>
                    </div>
                  </TableCell>
                  <TableCell>
                    <Badge variant="secondary" className="text-[10px] uppercase tracking-tighter">
                      {activeTab === "users" ? item.activityType : item.action}
                    </Badge>
                  </TableCell>
                  {activeTab === "users" && (
                    <TableCell>
                      <span className="text-xs font-medium px-1.5 py-0.5 rounded bg-muted border">{item.entityType}</span>
                    </TableCell>
                  )}
                  <TableCell className="text-right">
                    <LogDetailsDrawer log={item} type={activeTab} t={t} lang={lang} />
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      {/* Pagination Footer */}
      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-4 mt-4 px-4 py-2.5 bg-secondary/20 rounded-2xl border border-secondary-foreground/15 shadow-sm text-sm text-foreground w-fit mx-auto">
          <Button
            variant="outline"
            size="icon"
            onClick={() => setCurrentPage((p) => Math.max(p - 1, 0))}
            disabled={currentPage === 0}
            className="h-8 w-8 rounded-xl border-secondary-foreground/25 hover:bg-secondary-foreground/10 hover:text-secondary-foreground text-secondary-foreground font-bold transition-all disabled:opacity-40"
          >
            <FaArrowLeft className="size-3.5 text-secondary-foreground" />
          </Button>

          <span className="font-extrabold text-sm text-secondary-foreground select-none">
            {currentPage + 1} / {totalPages}
          </span>

          <Button
            variant="outline"
            size="icon"
            onClick={() => setCurrentPage((p) => Math.min(p + 1, totalPages - 1))}
            disabled={currentPage >= totalPages - 1}
            className="h-8 w-8 rounded-xl border-secondary-foreground/25 hover:bg-secondary-foreground/10 hover:text-secondary-foreground text-secondary-foreground font-bold transition-all disabled:opacity-40"
          >
            <FaArrowRight className="size-3.5 text-secondary-foreground" />
          </Button>
        </div>
      )}
    </div>
  );
}