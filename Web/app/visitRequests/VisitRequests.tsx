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

import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { FaEye } from "react-icons/fa";
import { api } from "@/lib/api";

import { useVisitRequests } from "@/app/visitRequests/useVisitRequests";
import { useProperties } from "@/app/properties/useProperties";
import { useUsers } from "@/app/users/useUsers";
import { VisitStatus, type VisitRequest } from "@/types/dashboard-types";

/* ---------------- TRANSLATIONS ---------------- */

type Language = "en" | "fr";

const dict = {
  en: {
    title: "Visit Requests",
    searchPlaceholder: "Search by client, property, status...",
    filters: "Filters",
    clearAll: "Clear all",
    total: "Total",
    pending: "Pending",
    approved: "Approved",
    completed: "Completed",
    rejected: "Rejected",
    property: "Property",
    seller: "Seller",
    client: "Client",
    reqDate: "Requested Date",
    status: "Status",
    sortByDate: "Sort by Date",
    newest: "Newest first",
    oldest: "Oldest first",
    createdBetween: "Created Between",
    after: "After",
    before: "Before",
    all: "ALL",
    noResults: "No visit requests match your filters",
    page: "Page",
    of: "of",
    next: "Next",
    prev: "Previous",
    details: {
      title: "Visit Request",
      desc: "Full details for this visit request",
      overview: "Overview",
      propInfo: "Property",
      sellerInfo: "Seller",
      clientInfo: "Client",
      name: "Name",
      email: "Email",
      createdAt: "Created At",
      updatedAt: "Updated At",
      timestamps: "Timestamps",
      close: "Close",
    },
  },
  fr: {
    title: "Demandes de Visite",
    searchPlaceholder: "Chercher par client, propriété, statut...",
    filters: "Filtres",
    clearAll: "Tout effacer",
    total: "Total",
    pending: "En attente",
    approved: "Approuvé",
    completed: "Terminé",
    rejected: "Rejeté",
    property: "Propriété",
    seller: "Vendeur",
    client: "Client",
    reqDate: "Date demandée",
    status: "Statut",
    sortByDate: "Trier par date",
    newest: "Plus récent",
    oldest: "Plus ancien",
    createdBetween: "Créé entre",
    after: "Après",
    before: "Avant",
    all: "TOUT",
    noResults: "Aucune demande ne correspond aux filtres",
    page: "Page",
    of: "sur",
    next: "Suivant",
    prev: "Précédent",
    details: {
      title: "Détails de la visite",
      desc: "Informations complètes sur cette demande",
      overview: "Aperçu",
      propInfo: "Propriété",
      sellerInfo: "Vendeur",
      clientInfo: "Client",
      name: "Nom",
      email: "E-mail",
      createdAt: "Créé le",
      updatedAt: "Mis à jour le",
      timestamps: "Horodatage",
      close: "Fermer",
    },
  },
};

/* ---------------- HELPERS ---------------- */

function parseDate(v: string | number | null | undefined): Date | null {
  if (!v) return null;
  if (typeof v === "number") return new Date(v);
  if (typeof v === "string" && !v.endsWith("Z") && !v.includes("+"))
    return new Date(v + "Z");
  return new Date(v);
}

function fmt(v: string | number | null | undefined, locale: string) {
  const d = parseDate(v);
  return d ? d.toLocaleDateString(locale) : "—";
}

function fmtFull(v: string | number | null | undefined, locale: string) {
  const d = parseDate(v);
  return d ? d.toLocaleString(locale) : "—";
}

function statusVariant(status: VisitStatus): "default" | "secondary" | "destructive" | "outline" {
  switch (status) {
    case VisitStatus.APPROVED: return "default";
    case VisitStatus.COMPLETED: return "secondary";
    case VisitStatus.PENDING: return "outline";
    case VisitStatus.REJECTED: return "destructive";
    default: return "outline";
  }
}

function StatusSelect({ request, onUpdate }: { request: any; onUpdate: (id: string, status: VisitStatus) => Promise<void> }) {
  const status = request.status;
  let triggerClass = "h-7 w-[130px] text-xs";
  if (status === VisitStatus.PENDING) triggerClass += " bg-yellow-50 dark:bg-yellow-950/30 text-yellow-700 dark:text-yellow-400 border-yellow-200/50 dark:border-yellow-900/50";
  else if (status === VisitStatus.APPROVED) triggerClass += " bg-green-50 dark:bg-green-950/30 text-green-700 dark:text-green-400 border-green-200/50 dark:border-green-900/50";
  else if (status === VisitStatus.COMPLETED) triggerClass += " bg-blue-50 dark:bg-blue-950/30 text-blue-700 dark:text-blue-400 border-blue-200/50 dark:border-blue-900/50";
  else if (status === VisitStatus.REJECTED) triggerClass += " bg-destructive/10 text-destructive border-destructive/30";
  
  return (
    <Select value={status} onValueChange={(value: string) => onUpdate(request.id, value as VisitStatus)}>
      <SelectTrigger className={triggerClass}><SelectValue /></SelectTrigger>
      <SelectContent>
        <SelectItem value={VisitStatus.PENDING}>{VisitStatus.PENDING}</SelectItem>
        <SelectItem value={VisitStatus.APPROVED}>{VisitStatus.APPROVED}</SelectItem>
        <SelectItem value={VisitStatus.COMPLETED}>{VisitStatus.COMPLETED}</SelectItem>
        <SelectItem value={VisitStatus.REJECTED}>{VisitStatus.REJECTED}</SelectItem>
      </SelectContent>
    </Select>
  );
}

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">{label}</span>
      {typeof value === "string" || typeof value === "number" ? (
        <span className="text-sm font-medium text-foreground">{value}</span>
      ) : (
        <div className="mt-0.5">{value}</div>
      )}
    </div>
  );
}

/* ---------------- SUMMARY CARDS ---------------- */

function SummaryCards({ visitRequests, t }: { visitRequests: VisitRequest[]; t: any }) {
  const total = visitRequests.length;
  const pending = visitRequests.filter((r) => r.status === VisitStatus.PENDING).length;
  const approved = visitRequests.filter((r) => r.status === VisitStatus.APPROVED).length;
  const completed = visitRequests.filter((r) => r.status === VisitStatus.COMPLETED).length;
  const rejected = visitRequests.filter((r) => r.status === VisitStatus.REJECTED).length;

  const cards = [
    { label: t.total, value: total, colorClass: "text-foreground", bgClass: "bg-muted/50" },
    { label: t.pending, value: pending, colorClass: "text-yellow-600 dark:text-yellow-400", bgClass: "bg-yellow-50 dark:bg-yellow-950/30" },
    { label: t.approved, value: approved, colorClass: "text-green-600", bgClass: "bg-green-50 dark:bg-green-950/30" },
    { label: t.completed, value: completed, colorClass: "text-blue-600 dark:text-blue-400", bgClass: "bg-blue-50 dark:bg-blue-950/30" },
    { label: t.rejected, value: rejected, colorClass: "text-destructive", bgClass: "bg-destructive/10" },
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
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

type DateSort = "" | "newest" | "oldest";

function FilterPanel({
  t,
  filterStatus, setFilterStatus,
  dateSort, setDateSort,
  createdAfter, setCreatedAfter,
  createdBefore, setCreatedBefore,
  onClear,
}: {
  t: typeof dict["en"];
  filterStatus: VisitStatus | "ALL"; setFilterStatus: (v: VisitStatus | "ALL") => void;
  dateSort: DateSort; setDateSort: (v: DateSort) => void;
  createdAfter: string; setCreatedAfter: (v: string) => void;
  createdBefore: string; setCreatedBefore: (v: string) => void;
  onClear: () => void;
}) {
  const activeCount = [
    filterStatus !== "ALL",
    dateSort !== "",
    createdAfter !== "",
    createdBefore !== "",
  ].filter(Boolean).length;

  const statusOptions: { value: VisitStatus | "ALL"; label: string }[] = [
    { value: "ALL", label: t.all },
    { value: VisitStatus.PENDING, label: t.pending },
    { value: VisitStatus.APPROVED, label: t.approved },
    { value: VisitStatus.COMPLETED, label: t.completed },
    { value: VisitStatus.REJECTED, label: t.rejected },
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

export default function VisitRequests() {
  const [lang, setLang] = useState<Language>("en");
  const t = dict[lang];
  const dateLocale = lang === "fr" ? "fr-FR" : "en-US";

  const { visitRequests, loading, error } = useVisitRequests();
  const { properties } = useProperties();
  const { users } = useUsers();

  const [search, setSearch] = useState("");
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
  const [filterStatus, setFilterStatus] = useState<VisitStatus | "ALL">("ALL");
  const [createdAfter, setCreatedAfter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [dateSort, setDateSort] = useState<DateSort>("");
  const [filterOpen, setFilterOpen] = useState(false);

  const clearFilters = () => {
    setFilterStatus("ALL");
    setDateSort("");
    setCreatedAfter("");
    setCreatedBefore("");
  };

  const handleStatusUpdate = useCallback(
    async (id: string, status: VisitStatus) => {
      await api.put(`/admin/visit-requests/${id}/status`, null, { params: { status } });
      // Update local state here if visitRequests is updatable
    },
    []
  );

  const activeFilterCount = [
    filterStatus !== "ALL",
    createdAfter !== "",
    createdBefore !== "",
    dateSort !== "",
  ].filter(Boolean).length;

  const columns = useMemo<ColumnDef<any>[]>(
    () => [
      {
        accessorKey: "propertyTitle",
        header: t.property,
        cell: ({ row }) => <p className="text-sm font-medium">{row.original.propertyTitle}</p>,
      },
      {
        accessorKey: "sellerName",
        header: t.seller,
        cell: ({ row }) => (
          <div>
            <p className="text-sm font-medium">{row.original.sellerName ?? "—"}</p>
            <p className="text-xs text-muted-foreground">{row.original.sellerEmail ?? ""}</p>
          </div>
        ),
      },
      {
        accessorKey: "userName",
        header: t.client,
        cell: ({ row }) => (
          <div>
            <p className="text-sm font-medium">{row.original.userName}</p>
            <p className="text-xs text-muted-foreground">{row.original.userEmail}</p>
          </div>
        ),
      },
      {
        accessorKey: "requestedDate",
        header: t.reqDate,
        cell: ({ row }) => fmt(row.original.requestedDate, dateLocale),
      },
      {
        accessorKey: "status",
        header: t.status,
        cell: ({ row }) => (
          <StatusSelect request={row.original} onUpdate={handleStatusUpdate} />
        ),
      },
      {
        id: "seeMore",
        header: "",
        cell: ({ row }) => (
          <Drawer direction="right">
            <DrawerTrigger asChild>
              <Button variant="ghost" size="icon"><FaEye /></Button>
            </DrawerTrigger>
            <DrawerContent className="flex flex-col max-w-md ml-auto h-full p-6">
              <DrawerHeader>
                <DrawerTitle>{t.details.title}</DrawerTitle>
                <DrawerDescription>{t.details.desc}</DrawerDescription>
              </DrawerHeader>
              <div className="flex-1 overflow-y-auto space-y-6 mt-4">
                <section className="space-y-4">
                  <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.overview}</p>
                  <InfoRow label={t.status} value={<Badge variant={statusVariant(row.original.status)}>{row.original.status}</Badge>} />
                  <InfoRow label={t.reqDate} value={fmtFull(row.original.requestedDate, dateLocale)} />
                </section>
                <section className="space-y-4">
                  <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.propInfo}</p>
                  <InfoRow label="Title" value={row.original.propertyTitle} />
                </section>
                <section className="space-y-4">
                  <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.sellerInfo}</p>
                  <InfoRow label={t.details.name} value={row.original.sellerName ?? "—"} />
                  <InfoRow label={t.details.email} value={row.original.sellerEmail ?? "—"} />
                </section>
                <section className="space-y-4">
                  <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.clientInfo}</p>
                  <InfoRow label={t.details.name} value={row.original.userName} />
                  <InfoRow label={t.details.email} value={row.original.userEmail} />
                </section>
                <section className="space-y-4">
                  <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.timestamps}</p>
                  <div className="grid grid-cols-2 gap-3">
                    <InfoRow label={t.details.createdAt} value={fmtFull(row.original.createdAt, dateLocale)} />
                    <InfoRow label={t.details.updatedAt} value={fmtFull(row.original.updatedAt, dateLocale)} />
                  </div>
                </section>
              </div>
              <DrawerFooter>
                <DrawerClose asChild>
                  <Button variant="outline" className="w-full bg-black hover:bg-gray-900 text-white border-gray-700">{t.details.close}</Button>
                </DrawerClose>
              </DrawerFooter>
            </DrawerContent>
          </Drawer>
        ),
      },
    ],
    [t, dateLocale, handleStatusUpdate]
  );

  const visitRequestsWithSeller = useMemo(() => {
    const propMap = properties ? Object.fromEntries(properties.map((p) => [p.id, p])) : {};
    const userMap = users ? Object.fromEntries(users.map((u) => [u.id, u])) : {};
    return visitRequests.map((req) => {
      const prop = propMap[req.propertyId];
      const seller = prop?.sellerId ? userMap[prop.sellerId] : null;
      return {
        ...req,
        propertyTitle: prop?.title ?? "—",
        sellerName: prop?.sellerName ?? "—",
        sellerEmail: seller?.email ?? "—",
      };
    });
  }, [visitRequests, properties, users]);

  const filteredData = useMemo(() => {
    const filtered = visitRequestsWithSeller.filter((r) => {
      const textMatch = [r.userName, r.userEmail, r.propertyTitle, r.status, r.sellerName, r.sellerEmail]
        .filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
      const statusMatch = filterStatus === "ALL" || r.status === filterStatus;
      const created = parseDate(r.createdAt)?.getTime() ?? null;
      const afterMatch = !createdAfter || (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());
      return textMatch && statusMatch && afterMatch && beforeMatch;
    });

    if (dateSort === "newest") {
      filtered.sort((a, b) => (parseDate(b.createdAt)?.getTime() ?? 0) - (parseDate(a.createdAt)?.getTime() ?? 0));
    } else if (dateSort === "oldest") {
      filtered.sort((a, b) => (parseDate(a.createdAt)?.getTime() ?? 0) - (parseDate(b.createdAt)?.getTime() ?? 0));
    }

    return filtered;
  }, [visitRequestsWithSeller, search, filterStatus, createdAfter, createdBefore, dateSort]);

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

      <SummaryCards visitRequests={visitRequestsWithSeller} t={t} />

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
          dateSort={dateSort} setDateSort={setDateSort}
          createdAfter={createdAfter} setCreatedAfter={setCreatedAfter}
          createdBefore={createdBefore} setCreatedBefore={setCreatedBefore}
          onClear={clearFilters}
        />
      )}

      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader className="bg-primary text-white">
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

      <div className="flex justify-center items-center gap-2 px-4 py-2 text-sm text-muted-foreground">
        <Button variant="outline" size="sm" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>←</Button>
        <span>{t.page} {pagination.pageIndex + 1} {t.of} {Math.max(table.getPageCount(), 1)}</span>
        <Button variant="outline" size="sm" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>→</Button>
      </div>
    </div>
  );
}