"use client";

import React, { useMemo, useState, useCallback } from "react";
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getPaginationRowModel,
  flexRender,
  type ColumnDef,
} from "@tanstack/react-table";

import { Badge } from "@/components/ui/badge";
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
  DrawerTrigger,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerDescription,
  DrawerFooter,
  DrawerClose,
} from "@/components/ui/drawer";

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { useReports } from "@/app/reports/useReports";
import { api } from "@/lib/api";
import { FaEye } from "react-icons/fa";

/* ---------------- TRANSLATIONS ---------------- */

type Language = "en" | "fr";

const dict = {
  en: {
    title: "Reports",
    searchPlaceholder: "Search by reporter, target, reason...",
    filters: "Filters",
    clearAll: "Clear all",
    status: "Status",
    type: "Report Type",
    sortByDate: "Sort by Date",
    newest: "Newest first",
    oldest: "Oldest first",
    createdBetween: "Created Between",
    after: "After",
    before: "Before",
    total: "Total Reports",
    waiting: "Waiting / Open",
    resolved: "Resolved",
    dismissed: "Dismissed",
    all: "ALL",
    user: "USER",
    property: "PROPERTY",
    noResults: "No reports match your filters",
    page: "Page",
    of: "of",
    next: "Next",
    prev: "Previous",
    details: {
      title: "Report Info",
      desc: "Full details for this report",
      overview: "Overview",
      reporter: "Reporter",
      target: "Target",
      reviewedBy: "Reviewed By",
      notReviewed: "Not yet reviewed",
      timestamps: "Timestamps",
      close: "Close",
    },
  },
  fr: {
    title: "Signalements",
    searchPlaceholder: "Rechercher par auteur, cible, raison...",
    filters: "Filtres",
    clearAll: "Tout effacer",
    status: "Statut",
    type: "Type de rapport",
    sortByDate: "Trier par date",
    newest: "Plus récent",
    oldest: "Plus ancien",
    createdBetween: "Créé entre",
    after: "Après",
    before: "Avant",
    total: "Total des rapports",
    waiting: "En attente / Ouvert",
    resolved: "Résolu",
    dismissed: "Rejeté",
    all: "TOUT",
    user: "UTILISATEUR",
    property: "PROPRIÉTÉ",
    noResults: "Aucun rapport ne correspond à vos filtres",
    page: "Page",
    of: "sur",
    next: "Suivant",
    prev: "Précédent",
    details: {
      title: "Info du rapport",
      desc: "Détails complets de ce signalement",
      overview: "Aperçu",
      reporter: "Auteur",
      target: "Cible",
      reviewedBy: "Examiné par",
      notReviewed: "Pas encore examiné",
      timestamps: "Horodatage",
      close: "Fermer",
    },
  },
};

/* ---------------- TYPES ---------------- */

export type ReportStatus = "OPEN" | "RESOLVED" | "DISMISSED";

export type Report = {
  id: string;
  reason: string;
  status: ReportStatus;
  createdAt: string;
  updatedAt: string;
  reporterId: string;
  reporterName: string;
  reporterEmail: string;
  reportedUserId: string | null;
  reportedUserName: string | null;
  reportedUserEmail: string | null;
  reportedPropertyId: string | null;
  reportedPropertyTitle: string | null;
  reviewedByAdminId: string | null;
  reviewedByAdminName: string | null;
  reviewedByAdminEmail: string | null;
};

type DateSort = "" | "newest" | "oldest";

/* ---------------- HELPERS ---------------- */

function parseDate(v: string | number | null | undefined): Date | null {
  if (!v) return null;
  if (typeof v === "number") return new Date(v);
  if (typeof v === "string" && !v.endsWith("Z") && !v.includes("+"))
    return new Date(v + "Z");
  return new Date(v);
}

function fmt(v: string | number | null | undefined, locale: string = "en-US") {
  const d = parseDate(v);
  return d ? d.toLocaleDateString(locale) : "—";
}

function fmtFull(v: string | number | null | undefined, locale: string = "en-US") {
  const d = parseDate(v);
  return d ? d.toLocaleString(locale) : "—";
}

/* ---------------- SUMMARY CARDS ---------------- */

function SummaryCards({ reports, t }: { reports: Report[]; t: any }) {
  const open = reports.filter((r) => r.status === "OPEN").length;
  const resolved = reports.filter((r) => r.status === "RESOLVED").length;
  const dismissed = reports.filter((r) => r.status === "DISMISSED").length;

  const cards = [
    { label: t.total, value: reports.length, colorClass: "text-foreground", bgClass: "bg-muted/50" },
    { label: t.waiting, value: open, colorClass: "text-destructive", bgClass: "bg-destructive/10" },
    { label: t.resolved, value: resolved, colorClass: "text-green-600", bgClass: "bg-green-50 dark:bg-green-950/30" },
    { label: t.dismissed, value: dismissed, colorClass: "text-muted-foreground", bgClass: "bg-muted/50" },
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
      {cards.map((card) => (
        <div key={card.label} className={`rounded-lg border p-4 flex items-center gap-3 ${card.bgClass}`}>
          <div>
            <p className="text-[11px] uppercase tracking-widest text-muted-foreground font-semibold">{card.label}</p>
            <p className={`text-2xl font-bold ${card.colorClass}`}>{card.value}</p>
          </div>
        </div>
      ))}
    </div>
  );
}

/* ---------------- FILTER PANEL ---------------- */

function FilterPanel({
  t,
  filterStatus, setFilterStatus,
  reportType, setReportType,
  dateSort, setDateSort,
  createdAfter, setCreatedAfter,
  createdBefore, setCreatedBefore,
  onClear,
}: {
  t: typeof dict["en"];
  filterStatus: ReportStatus | "ALL"; setFilterStatus: (v: ReportStatus | "ALL") => void;
  reportType: "ALL" | "USER" | "PROPERTY"; setReportType: (v: "ALL" | "USER" | "PROPERTY") => void;
  dateSort: DateSort; setDateSort: (v: DateSort) => void;
  createdAfter: string; setCreatedAfter: (v: string) => void;
  createdBefore: string; setCreatedBefore: (v: string) => void;
  onClear: () => void;
}) {
  const activeCount = [
    filterStatus !== "ALL",
    reportType !== "ALL",
    dateSort !== "",
    createdAfter !== "",
    createdBefore !== "",
  ].filter(Boolean).length;

  const statusOptions: { value: ReportStatus | "ALL"; label: string }[] = [
    { value: "ALL", label: t.all },
    { value: "OPEN", label: t.waiting },
    { value: "RESOLVED", label: t.resolved },
    { value: "DISMISSED", label: t.dismissed },
  ];

  const typeOptions: { value: "ALL" | "USER" | "PROPERTY"; label: string }[] = [
    { value: "ALL", label: t.all },
    { value: "USER", label: t.user },
    { value: "PROPERTY", label: t.property },
  ];

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
        {/* Status */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.status}</label>
          <div className="flex flex-wrap gap-1.5">
            {statusOptions.map(({ value, label }) => (
              <button
                key={value}
                onClick={() => setFilterStatus(value)}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  filterStatus === value
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {label}
              </button>
            ))}
          </div>
        </div>

        {/* Report Type */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.type}</label>
          <div className="flex flex-wrap gap-1.5">
            {typeOptions.map(({ value, label }) => (
              <button
                key={value}
                onClick={() => setReportType(value)}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  reportType === value
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {label}
              </button>
            ))}
          </div>
        </div>

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

export default function Reports() {
  const [lang, setLang] = useState<Language>("en");
  const t = dict[lang];

  const { reports, loading, error, setReports } = useReports();

  const [search, setSearch] = useState("");
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
  const [filterStatus, setFilterStatus] = useState<ReportStatus | "ALL">("ALL");
  const [reportType, setReportType] = useState<"ALL" | "USER" | "PROPERTY">("ALL");
  const [createdAfter, setCreatedAfter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [dateSort, setDateSort] = useState<DateSort>("");
  const [filterOpen, setFilterOpen] = useState(false);

  const clearFilters = () => {
    setFilterStatus("ALL");
    setReportType("ALL");
    setDateSort("");
    setCreatedAfter("");
    setCreatedBefore("");
  };

  const activeFilterCount = [
    filterStatus !== "ALL",
    reportType !== "ALL",
    dateSort !== "",
    createdAfter !== "",
    createdBefore !== "",
  ].filter(Boolean).length;

  const handleStatusUpdate = useCallback(
    async (id: string, status: ReportStatus) => {
      await api.put(`/admin/reports/${id}/status`, null, { params: { status } });
      setReports((prev) => prev.map((r) => (r.id === id ? { ...r, status } : r)));
    },
    [setReports]
  );

  const columns = useMemo<ColumnDef<Report>[]>(
    () => [
      {
        accessorKey: "reporterName",
        header: t.details.reporter,
        cell: ({ row }) => (
          <div>
            <p className="text-sm font-medium">{row.original.reporterName}</p>
            <p className="text-xs text-muted-foreground">{row.original.reporterEmail}</p>
          </div>
        ),
      },
      {
        id: "target",
        header: t.details.target,
        cell: ({ row }) => {
          const r = row.original;
          const typeLabel = r.reportedPropertyTitle ? t.property : t.user;
          const title = r.reportedPropertyTitle || r.reportedUserName || "—";
          return (
            <div>
              <p className="text-xs text-muted-foreground uppercase tracking-wide">{typeLabel}</p>
              <p className="text-sm font-medium">{title}</p>
            </div>
          );
        },
      },
      {
        accessorKey: "reason",
        header: "Reason",
        cell: ({ row }) => <span className="text-sm">{row.original.reason}</span>,
      },
      {
        accessorKey: "status",
        header: t.status,
        cell: ({ row }) => (
          <Select
            value={row.original.status}
            onValueChange={(v) => handleStatusUpdate(row.original.id, v as ReportStatus)}
          >
            <SelectTrigger className="h-7 w-[130px] text-xs"><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="OPEN">{t.waiting}</SelectItem>
              <SelectItem value="RESOLVED">{t.resolved}</SelectItem>
              <SelectItem value="DISMISSED">{t.dismissed}</SelectItem>
            </SelectContent>
          </Select>
        ),
      },
      {
        accessorKey: "createdAt",
        header: t.sortByDate,
        cell: ({ row }) => fmt(row.original.createdAt, lang === "fr" ? "fr-FR" : "en-US"),
      },
      {
        id: "seeMore",
        header: "",
        cell: ({ row }) => <ReportDrawer report={row.original} t={t} lang={lang} />,
      },
    ],
    [t, lang, handleStatusUpdate]
  );

  const filteredData = useMemo(() => {
    const filtered = reports.filter((r) => {
      const textMatch = [r.reporterName, r.reason].join(" ").toLowerCase().includes(search.toLowerCase());
      const statusMatch = filterStatus === "ALL" || r.status === filterStatus;
      const typeMatch =
        reportType === "ALL" ||
        (reportType === "PROPERTY" && !!r.reportedPropertyId) ||
        (reportType === "USER" && !!r.reportedUserId);
      const created = parseDate(r.createdAt)?.getTime() ?? null;
      const afterMatch = !createdAfter || (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());
      return textMatch && statusMatch && typeMatch && afterMatch && beforeMatch;
    });

    if (dateSort === "newest") {
      filtered.sort((a, b) => (parseDate(b.createdAt)?.getTime() ?? 0) - (parseDate(a.createdAt)?.getTime() ?? 0));
    } else if (dateSort === "oldest") {
      filtered.sort((a, b) => (parseDate(a.createdAt)?.getTime() ?? 0) - (parseDate(b.createdAt)?.getTime() ?? 0));
    }

    return filtered;
  }, [reports, search, filterStatus, reportType, createdAfter, createdBefore, dateSort]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: { pagination },
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  if (loading) return <div className="p-8">...</div>;

  return (
    <div className="px-8 space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">{t.title}</h2>
        <Button variant="ghost" size="sm" onClick={() => setLang(lang === "en" ? "fr" : "en")}>
          {lang === "en" ? "🇫🇷 FR" : "🇺🇸 EN"}
        </Button>
      </div>

      <SummaryCards reports={reports} t={t} />

      {/* Search + Filter toggle */}
      <div className="flex gap-2">
        <Input placeholder={t.searchPlaceholder} value={search} onChange={(e) => setSearch(e.target.value)} />
        <Button variant="outline" onClick={() => setFilterOpen((v) => !v)} className="relative shrink-0">
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
          t={t}
          filterStatus={filterStatus} setFilterStatus={setFilterStatus}
          reportType={reportType} setReportType={setReportType}
          dateSort={dateSort} setDateSort={setDateSort}
          createdAfter={createdAfter} setCreatedAfter={setCreatedAfter}
          createdBefore={createdBefore} setCreatedBefore={setCreatedBefore}
          onClear={clearFilters}
        />
      )}

      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader className="bg-primary">
            {table.getHeaderGroups().map((hg) => (
              <TableRow key={hg.id}>
                {hg.headers.map((header) => (
                  <TableHead key={header.id} className="text-white">
                    {flexRender(header.column.columnDef.header, header.getContext())}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length === 0 ? (
              <TableRow>
                <TableCell colSpan={columns.length} className="text-center text-muted-foreground py-12 text-sm">
                  {t.noResults}
                </TableCell>
              </TableRow>
            ) : (
              table.getRowModel().rows.map((row) => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>
                  ))}
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-center items-center gap-4 py-2">
        <Button size="sm" variant="outline" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>{t.prev}</Button>
        <span className="text-sm">{t.page} {pagination.pageIndex + 1} {t.of} {Math.max(table.getPageCount(), 1)}</span>
        <Button size="sm" variant="outline" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>{t.next}</Button>
      </div>
    </div>
  );
}

/* ---------------- DRAWER ---------------- */

function ReportDrawer({ report, t, lang }: { report: Report; t: any; lang: string }) {
  return (
    <Drawer direction="right">
      <DrawerTrigger asChild><Button variant="ghost" size="icon"><FaEye /></Button></DrawerTrigger>
      <DrawerContent className="max-w-md ml-auto h-full p-6">
        <DrawerHeader>
          <DrawerTitle>{t.details.title}</DrawerTitle>
          <DrawerDescription>{t.details.desc}</DrawerDescription>
        </DrawerHeader>
        <div className="space-y-4 mt-4">
          <p><strong>{t.status}:</strong> {report.status}</p>
          <p><strong>{t.details.reporter}:</strong> {report.reporterName}</p>
          <p><strong>{t.sortByDate}:</strong> {fmtFull(report.createdAt, lang === "fr" ? "fr-FR" : "en-US")}</p>
        </div>
        <DrawerFooter><DrawerClose asChild><Button variant="outline">{t.details.close}</Button></DrawerClose></DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}