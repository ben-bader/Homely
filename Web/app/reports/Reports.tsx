"use client";

import React, { useMemo, useState, useCallback, useEffect } from "react";
import { useLocale } from "next-intl";
import {
  useReactTable, getCoreRowModel, getSortedRowModel, getPaginationRowModel, flexRender, type ColumnDef,
} from "@tanstack/react-table";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Drawer, DrawerTrigger, DrawerContent, DrawerHeader, DrawerTitle, DrawerDescription, DrawerFooter, DrawerClose } from "@/components/ui/drawer";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { useReports } from "@/app/reports/useReports";
import { api } from "@/lib/api";
import { Eye, Flag, AlertCircle, CheckCircle2, XCircle, SlidersHorizontal } from "lucide-react";
// Inline analytics (no shared KPI abstractions)
import { PaginationFooter } from "@/components/ui/pagination";
import { Report, ReportStatus } from "@/types/dashboard-types";
import { StatusBadge } from "@/components/platform/status-badge";
import { MetricCard } from "@/components/platform/metric-card";

type Language = "en" | "fr";
type DateSort = "" | "newest" | "oldest";

const dict = {
  en: {
    title: "Reports", subtitle: "Review and manage user-submitted reports",
    searchPlaceholder: "Search by reporter, target, reason...",
    filters: "Filters", clearAll: "Clear all", status: "Status", type: "Report Type",
    sortByDate: "Sort by Date", newest: "Newest first", oldest: "Oldest first",
    createdBetween: "Created Between", after: "After", before: "Before",
    total: "Total", waiting: "Open", resolved: "Resolved", dismissed: "Dismissed",
    all: "ALL", user: "USER", property: "PROPERTY",
    noResults: "No reports match your filters", page: "Page", of: "of",
    details: { title: "Report Info", desc: "Full details for this report", overview: "Overview", reporter: "Reporter", target: "Target", reviewedBy: "Reviewed By", notReviewed: "Not yet reviewed", timestamps: "Timestamps", close: "Close" },
  },
  fr: {
    title: "Signalements", subtitle: "Examiner et gérer les signalements des utilisateurs",
    searchPlaceholder: "Rechercher par auteur, cible, raison...",
    filters: "Filtres", clearAll: "Tout effacer", status: "Statut", type: "Type de rapport",
    sortByDate: "Trier par date", newest: "Plus récent", oldest: "Plus ancien",
    createdBetween: "Créé entre", after: "Après", before: "Avant",
    total: "Total des rapports", waiting: "En attente", resolved: "Résolu", dismissed: "Rejeté",
    all: "TOUT", user: "UTILISATEUR", property: "PROPRIÉTÉ",
    noResults: "Aucun rapport ne correspond à vos filtres", page: "Page", of: "sur",
    details: { title: "Info du rapport", desc: "Détails complets de ce signalement", overview: "Aperçu", reporter: "Auteur", target: "Cible", reviewedBy: "Examiné par", notReviewed: "Pas encore examiné", timestamps: "Horodatage", close: "Fermer" },
  },
};

function parseDate(v: string | number | null | undefined): Date | null {
  if (!v) return null;
  if (typeof v === "number") return new Date(v);
  if (typeof v === "string" && !v.endsWith("Z") && !v.includes("+")) return new Date(v + "Z");
  return new Date(v);
}
function fmt(v: string | number | null | undefined, locale: string = "en-US") { const d = parseDate(v); return d ? d.toLocaleDateString(locale) : "—"; }
function fmtFull(v: string | number | null | undefined, locale: string = "en-US") { const d = parseDate(v); return d ? d.toLocaleString(locale) : "—"; }

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex justify-between items-start gap-4 text-sm">
      <span className="text-muted-foreground shrink-0">{label}</span>
      <span className="text-right font-medium">{value ?? "—"}</span>
    </div>
  );
}

function Section({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="space-y-2">
      <p className="text-[10px] uppercase tracking-widest font-semibold text-muted-foreground border-b pb-1">{label}</p>
      <div className="space-y-2">{children}</div>
    </div>
  );
}

function ReportDrawer({ report, t, lang }: { report: Report; t: any; lang: string }) {
  const locale = lang === "fr" ? "fr-FR" : "en-US";
  const isProperty = !!report.reportedPropertyId;
  return (
    <Drawer direction="right">
      <DrawerTrigger asChild><Button variant="ghost" size="icon" className="h-8 w-8 text-muted-foreground hover:text-foreground"><Eye className="w-4 h-4" /></Button></DrawerTrigger>
      <DrawerContent className="max-w-md ml-auto h-full">
        <div className="flex flex-col h-full p-6">
          <DrawerHeader className="px-0 pb-4">
            <DrawerTitle className="text-lg">{t.details.title}</DrawerTitle>
            <DrawerDescription className="text-sm">{t.details.desc}</DrawerDescription>
          </DrawerHeader>
          <div className="flex-1 overflow-y-auto space-y-6">
            <Section label={t.details.overview}>
              <InfoRow label="Reason" value={report.reason} />
              <InfoRow label={t.status} value={<StatusBadge status={report.status} />} />
              <InfoRow label="Type" value={isProperty ? t.property : t.user} />
            </Section>
            <Section label={t.details.reporter}>
              <InfoRow label="Name" value={report.reporterName} />
              <InfoRow label="Email" value={report.reporterEmail} />
            </Section>
            <Section label={t.details.target}>
              {isProperty ? <InfoRow label="Property" value={report.reportedPropertyTitle} /> : (
                <><InfoRow label="Name" value={report.reportedUserName} /><InfoRow label="Email" value={report.reportedUserEmail} /></>
              )}
            </Section>
            <Section label={t.details.reviewedBy}>
              {report.reviewedByAdminId ? (
                <><InfoRow label="Name" value={report.reviewedByAdminName} /><InfoRow label="Email" value={report.reviewedByAdminEmail} /></>
              ) : <p className="text-sm text-muted-foreground italic">{t.details.notReviewed}</p>}
            </Section>
            <Section label={t.details.timestamps}>
              <InfoRow label="Created" value={fmtFull(report.createdAt, locale)} />
              <InfoRow label="Updated" value={fmtFull(report.updatedAt, locale)} />
            </Section>
          </div>
          <DrawerFooter className="px-0 mt-auto"><DrawerClose asChild><Button variant="outline" className="w-full">{t.details.close}</Button></DrawerClose></DrawerFooter>
        </div>
      </DrawerContent>
    </Drawer>
  );
}

export default function Reports() {
  const locale = useLocale();
  const lang = (locale === "fr" ? "fr" : "en") as Language;
  const t = dict[lang];
  const { reports, loading, error, setReports } = useReports();
  const [search, setSearch] = useState("");

  // Listen to global search events and URL query param
  useEffect(() => {
    if (typeof window === "undefined") return;

    // Load initial search query if present in URL
    const params = new URLSearchParams(window.location.search);
    const q = params.get("search");
    const sec = params.get("section");
    if (q && sec === "reports") {
      setSearch(q);
    }

    const handleSearchApply = (e: Event) => {
      const customEvent = e as CustomEvent<{ section: string; query: string }>;
      if (customEvent.detail && customEvent.detail.section === "reports") {
        setSearch(customEvent.detail.query);
      }
    };

    window.addEventListener("global-search-apply", handleSearchApply);
    return () => {
      window.removeEventListener("global-search-apply", handleSearchApply);
    };
  }, []);
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
  const [filterStatus, setFilterStatus] = useState<ReportStatus | "ALL">("ALL");
  const [reportType, setReportType] = useState<"ALL" | "USER" | "PROPERTY">("ALL");
  const [createdAfter, setCreatedAfter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [dateSort, setDateSort] = useState<DateSort>("");
  const [filterOpen, setFilterOpen] = useState(false);

  const clearFilters = () => { setFilterStatus("ALL"); setReportType("ALL"); setDateSort(""); setCreatedAfter(""); setCreatedBefore(""); };
  const activeFilterCount = [filterStatus !== "ALL", reportType !== "ALL", dateSort !== "", createdAfter !== "", createdBefore !== ""].filter(Boolean).length;

  const handleStatusUpdate = useCallback(async (id: string, status: ReportStatus) => {
    await api.put(`/admin/reports/${id}/status`, null, { params: { status } });
    setReports((prev) => prev.map((r) => (r.id === id ? { ...r, status } : r)));
  }, [setReports]);

  const columns = useMemo<ColumnDef<Report>[]>(() => [
    { accessorKey: "reporterName", header: t.details.reporter, cell: ({ row }) => <div><p className="text-sm font-medium">{row.original.reporterName}</p><p className="text-xs text-muted-foreground">{row.original.reporterEmail}</p></div> },
    { id: "target", header: t.details.target, cell: ({ row }) => { const r = row.original; const typeLabel = r.reportedPropertyTitle ? t.property : t.user; const title = r.reportedPropertyTitle || r.reportedUserName || "—"; return <div><p className="text-[10px] text-muted-foreground uppercase tracking-wide">{typeLabel}</p><p className="text-sm font-medium">{title}</p></div>; } },
    { accessorKey: "reason", header: "Reason", cell: ({ row }) => <span className="text-sm text-muted-foreground">{row.original.reason}</span> },
    { accessorKey: "status", header: t.status, cell: ({ row }) => (
      <Select value={row.original.status} onValueChange={(v) => handleStatusUpdate(row.original.id, v as ReportStatus)}>
        <SelectTrigger className="h-7 w-[130px] text-xs"><SelectValue /></SelectTrigger>
        <SelectContent>
          <SelectItem value="OPEN">{t.waiting}</SelectItem>
          <SelectItem value="RESOLVED">{t.resolved}</SelectItem>
          <SelectItem value="DISMISSED">{t.dismissed}</SelectItem>
        </SelectContent>
      </Select>
    ) },
    { accessorKey: "createdAt", header: "Date", cell: ({ row }) => <span className="text-sm text-muted-foreground">{fmt(row.original.createdAt, lang === "fr" ? "fr-FR" : "en-US")}</span> },
    { id: "view", header: "", cell: ({ row }) => <ReportDrawer report={row.original} t={t} lang={lang} /> },
  ], [t, lang, handleStatusUpdate]);

  const filteredData = useMemo(() => {
    const filtered = reports.filter((r) => {
      const textMatch = [r.reporterName, r.reason].join(" ").toLowerCase().includes(search.toLowerCase());
      const statusMatch = filterStatus === "ALL" || r.status === filterStatus;
      const typeMatch = reportType === "ALL" || (reportType === "PROPERTY" && !!r.reportedPropertyId) || (reportType === "USER" && !!r.reportedUserId);
      const created = parseDate(r.createdAt)?.getTime() ?? null;
      const afterMatch = !createdAfter || (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());
      return textMatch && statusMatch && typeMatch && afterMatch && beforeMatch;
    });
    if (dateSort === "newest") filtered.sort((a, b) => (parseDate(b.createdAt)?.getTime() ?? 0) - (parseDate(a.createdAt)?.getTime() ?? 0));
    else if (dateSort === "oldest") filtered.sort((a, b) => (parseDate(a.createdAt)?.getTime() ?? 0) - (parseDate(b.createdAt)?.getTime() ?? 0));
    return filtered;
  }, [reports, search, filterStatus, reportType, createdAfter, createdBefore, dateSort]);

  const table = useReactTable({ data: filteredData, columns, state: { pagination }, onPaginationChange: setPagination, getCoreRowModel: getCoreRowModel(), getSortedRowModel: getSortedRowModel(), getPaginationRowModel: getPaginationRowModel() });

  const openCount = reports.filter(r => r.status === "OPEN").length;
  const resolvedCount = reports.filter(r => r.status === "RESOLVED").length;
  const dismissedCount = reports.filter(r => r.status === "DISMISSED").length;
  const percentOfReports = (value: number) =>
    reports.length > 0 ? Math.round((value / reports.length) * 100) : 0;

  if (loading) return <div className="px-6 py-12 text-center text-sm text-muted-foreground">Loading…</div>;

  return (
    <div className="px-6 py-6 max-w-7xl mx-auto space-y-6 animate-fade-up">
      <div><h1 className="text-2xl font-semibold text-foreground">{t.title}</h1><p className="text-sm text-muted-foreground mt-1">{t.subtitle}</p></div>

      {/* Inline summary + small list (kept inline per instructions) */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <MetricCard
          label={t.total}
          value={reports.length}
          detail={t.subtitle}
          icon={<Flag className="w-5 h-5" />}
          accent="blue"
          progress={100}
        />
        <MetricCard
          label={t.waiting}
          value={openCount}
          detail={`${percentOfReports(openCount)}% ${t.waiting}`}
          icon={<AlertCircle className="w-5 h-5" />}
          accent="rose"
          progress={percentOfReports(openCount)}
        />
        <MetricCard
          label={t.resolved}
          value={resolvedCount}
          detail={`${percentOfReports(resolvedCount)}% ${t.resolved}`}
          icon={<CheckCircle2 className="w-5 h-5" />}
          accent="emerald"
          progress={percentOfReports(resolvedCount)}
        />
        <MetricCard
          label={t.dismissed}
          value={dismissedCount}
          detail={`${percentOfReports(dismissedCount)}% ${t.dismissed}`}
          icon={<XCircle className="w-5 h-5" />}
          accent="slate"
          progress={percentOfReports(dismissedCount)}
        />
      </div>

      <div className="flex items-center gap-2">
        <input placeholder={t.searchPlaceholder} value={search} onChange={(e) => setSearch(e.target.value)}
          className="flex-1 h-9 px-3 text-sm bg-card border rounded-lg outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/50 placeholder:text-muted-foreground/60 transition-all" />
        <Button variant="outline" size="sm" onClick={() => setFilterOpen(v => !v)} className="relative h-9 gap-1.5 text-xs font-medium">
          <SlidersHorizontal className="w-3.5 h-3.5" />{t.filters}
          {activeFilterCount > 0 && <span className="flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-white">{activeFilterCount}</span>}
        </Button>
      </div>

      {filterOpen && (
        <div className="bg-card border rounded-xl overflow-hidden animate-fade-up">
          <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/30">
            <span className="text-xs font-semibold uppercase tracking-wider">{t.filters}</span>
            {activeFilterCount > 0 && <button onClick={clearFilters} className="text-xs text-muted-foreground hover:text-foreground">{t.clearAll}</button>}
          </div>
          <div className="p-4 space-y-4">
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.status}</label>
              <div className="flex flex-wrap gap-1.5">
                {(["ALL", "OPEN", "RESOLVED", "DISMISSED"] as const).map(s => (
                  <button key={s} onClick={() => setFilterStatus(s as any)} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${filterStatus === s ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>{s === "ALL" ? t.all : s === "OPEN" ? t.waiting : s === "RESOLVED" ? t.resolved : t.dismissed}</button>
                ))}
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.type}</label>
              <div className="flex flex-wrap gap-1.5">
                {(["ALL", "USER", "PROPERTY"] as const).map(s => (
                  <button key={s} onClick={() => setReportType(s)} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${reportType === s ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>{s === "ALL" ? t.all : s === "USER" ? t.user : t.property}</button>
                ))}
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.sortByDate}</label>
              <div className="flex gap-1.5">
                <button onClick={() => setDateSort(dateSort === "newest" ? "" : "newest")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${dateSort === "newest" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>↓ {t.newest}</button>
                <button onClick={() => setDateSort(dateSort === "oldest" ? "" : "oldest")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${dateSort === "oldest" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>↑ {t.oldest}</button>
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.createdBetween}</label>
              <div className="grid grid-cols-2 gap-2">
                <div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t.after}</span><Input type="date" value={createdAfter} onChange={(e) => setCreatedAfter(e.target.value)} /></div>
                <div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t.before}</span><Input type="date" value={createdBefore} onChange={(e) => setCreatedBefore(e.target.value)} /></div>
              </div>
            </div>
          </div>
        </div>
      )}

      <div className="bg-card border rounded-xl overflow-hidden">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map(hg => (
              <TableRow key={hg.id}>
                {hg.headers.map(header => <TableHead key={header.id} className="text-xs font-medium uppercase tracking-wider h-10">{flexRender(header.column.columnDef.header, header.getContext())}</TableHead>)}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length === 0 ? (
              <TableRow><TableCell colSpan={columns.length} className="text-center text-muted-foreground py-16 text-sm">{t.noResults}</TableCell></TableRow>
            ) : table.getRowModel().rows.map(row => (
              <TableRow key={row.id} className="hover:bg-muted/20 transition-colors">
                {row.getVisibleCells().map(cell => <TableCell key={cell.id} className="py-3">{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>)}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-between items-center">
        <span className="text-xs text-muted-foreground">{filteredData.length} reports</span>
        <PaginationFooter
          pageInfo={`${t.page} ${pagination.pageIndex + 1} ${t.of} ${Math.max(table.getPageCount(), 1)}`}
          onPrevious={() => table.previousPage()}
          onNext={() => table.nextPage()}
          canPrevious={table.getCanPreviousPage()}
          canNext={table.getCanNextPage()}
        />
      </div>
    </div>
  );
}
