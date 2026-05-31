"use client";

import React, { useMemo, useState, useCallback } from "react";
import { useLocale } from "next-intl";
import { useReactTable, getCoreRowModel, getSortedRowModel, getPaginationRowModel, flexRender, type ColumnDef } from "@tanstack/react-table";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Drawer, DrawerTrigger, DrawerContent, DrawerHeader, DrawerTitle, DrawerDescription, DrawerFooter, DrawerClose } from "@/components/ui/drawer";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Eye, CalendarCheck, Clock, CheckCircle2, XCircle, ThumbsUp, SlidersHorizontal } from "lucide-react";
// KPI cards inlined (avoid shared KPI component)
import { PaginationFooter } from "@/components/ui/pagination";
import { api } from "@/lib/api";
import { useVisitRequests } from "@/app/visitRequests/useVisitRequests";
import { useProperties } from "@/app/properties/useProperties";
import { useUsers } from "@/app/users/useUsers";
import { VisitStatus, type VisitRequest } from "@/types/dashboard-types";
import { StatusBadge } from "@/components/platform/status-badge";

type Language = "en" | "fr";
type DateSort = "" | "newest" | "oldest";

const dict = {
  en: {
    title: "Visit Requests", subtitle: "Manage property visit scheduling requests",
    searchPlaceholder: "Search by client, property, status...", filters: "Filters", clearAll: "Clear all",
    total: "Total", pending: "Pending", approved: "Approved", completed: "Completed", rejected: "Rejected",
    property: "Property", seller: "Seller", client: "Client", reqDate: "Requested Date", status: "Status",
    sortByDate: "Sort by Date", newest: "Newest first", oldest: "Oldest first",
    createdBetween: "Created Between", after: "After", before: "Before", all: "ALL",
    noResults: "No visit requests match your filters", page: "Page", of: "of",
    details: { title: "Visit Request", desc: "Full details for this visit request", overview: "Overview", propInfo: "Property", sellerInfo: "Seller", clientInfo: "Client", name: "Name", email: "Email", createdAt: "Created At", updatedAt: "Updated At", timestamps: "Timestamps", close: "Close" },
  },
  fr: {
    title: "Demandes de Visite", subtitle: "Gérer les demandes de visite de propriétés",
    searchPlaceholder: "Chercher par client, propriété, statut...", filters: "Filtres", clearAll: "Tout effacer",
    total: "Total", pending: "En attente", approved: "Approuvé", completed: "Terminé", rejected: "Rejeté",
    property: "Propriété", seller: "Vendeur", client: "Client", reqDate: "Date demandée", status: "Statut",
    sortByDate: "Trier par date", newest: "Plus récent", oldest: "Plus ancien",
    createdBetween: "Créé entre", after: "Après", before: "Avant", all: "TOUT",
    noResults: "Aucune demande ne correspond aux filtres", page: "Page", of: "sur",
    details: { title: "Détails de la visite", desc: "Informations complètes sur cette demande", overview: "Aperçu", propInfo: "Propriété", sellerInfo: "Vendeur", clientInfo: "Client", name: "Nom", email: "E-mail", createdAt: "Créé le", updatedAt: "Mis à jour le", timestamps: "Horodatage", close: "Fermer" },
  },
};

function parseDate(v: string | number | null | undefined): Date | null { if (!v) return null; if (typeof v === "number") return new Date(v); if (typeof v === "string" && !v.endsWith("Z") && !v.includes("+")) return new Date(v + "Z"); return new Date(v); }
function fmt(v: string | number | null | undefined, locale: string) { const d = parseDate(v); return d ? d.toLocaleDateString(locale) : "—"; }
function fmtFull(v: string | number | null | undefined, locale: string) { const d = parseDate(v); return d ? d.toLocaleString(locale) : "—"; }
function InfoRow({ label, value }: { label: string; value: React.ReactNode }) { return (<div className="flex flex-col gap-0.5"><span className="text-[11px] uppercase tracking-widest text-muted-foreground font-medium">{label}</span><span className="text-sm font-medium text-foreground">{typeof value === "string" || typeof value === "number" ? value : <div className="mt-0.5">{value}</div>}</span></div>); }

export default function VisitRequests() {
  const locale = useLocale();
  const lang = (locale === "fr" ? "fr" : "en") as Language;
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

  const clearFilters = () => { setFilterStatus("ALL"); setDateSort(""); setCreatedAfter(""); setCreatedBefore(""); };
  const activeFilterCount = [filterStatus !== "ALL", createdAfter !== "", createdBefore !== "", dateSort !== ""].filter(Boolean).length;

  const handleStatusUpdate = useCallback(async (id: string, status: VisitStatus) => {
    await api.put(`/admin/visit-requests/${id}/status`, null, { params: { status } });
  }, []);

  const visitRequestsWithSeller = useMemo(() => {
    const propMap = properties ? Object.fromEntries(properties.map((p) => [p.id, p])) : {};
    const userMap = users ? Object.fromEntries(users.map((u) => [u.id, u])) : {};
    return visitRequests.map((req) => {
      const prop = propMap[req.propertyId];
      const seller = prop?.sellerId ? userMap[prop.sellerId] : null;
      return { ...req, propertyTitle: prop?.title ?? "—", sellerName: prop?.sellerName ?? "—", sellerEmail: seller?.email ?? "—" };
    });
  }, [visitRequests, properties, users]);

  const columns = useMemo<ColumnDef<any>[]>(() => [
    { accessorKey: "propertyTitle", header: t.property, cell: ({ row }) => <span className="text-sm font-medium">{row.original.propertyTitle}</span> },
    { accessorKey: "sellerName", header: t.seller, cell: ({ row }) => <div><p className="text-sm font-medium">{row.original.sellerName ?? "—"}</p><p className="text-xs text-muted-foreground">{row.original.sellerEmail ?? ""}</p></div> },
    { accessorKey: "userName", header: t.client, cell: ({ row }) => <div><p className="text-sm font-medium">{row.original.userName}</p><p className="text-xs text-muted-foreground">{row.original.userEmail}</p></div> },
    { accessorKey: "requestedDate", header: t.reqDate, cell: ({ row }) => <span className="text-sm text-muted-foreground">{fmt(row.original.requestedDate, dateLocale)}</span> },
    { accessorKey: "status", header: t.status, cell: ({ row }) => (
      <Select value={row.original.status} onValueChange={(v: string) => handleStatusUpdate(row.original.id, v as VisitStatus)}>
        <SelectTrigger className="h-7 w-[130px] text-xs"><SelectValue /></SelectTrigger>
        <SelectContent>
          <SelectItem value={VisitStatus.PENDING}>{VisitStatus.PENDING}</SelectItem>
          <SelectItem value={VisitStatus.APPROVED}>{VisitStatus.APPROVED}</SelectItem>
          <SelectItem value={VisitStatus.COMPLETED}>{VisitStatus.COMPLETED}</SelectItem>
          <SelectItem value={VisitStatus.REJECTED}>{VisitStatus.REJECTED}</SelectItem>
        </SelectContent>
      </Select>
    ) },
    { id: "view", header: "", cell: ({ row }) => (
      <Drawer direction="right">
        <DrawerTrigger asChild><Button variant="ghost" size="icon" className="h-8 w-8 text-muted-foreground hover:text-foreground"><Eye className="w-4 h-4" /></Button></DrawerTrigger>
        <DrawerContent className="max-w-md ml-auto h-full">
          <div className="flex flex-col h-full p-6">
            <DrawerHeader className="px-0 pb-4"><DrawerTitle className="text-lg">{t.details.title}</DrawerTitle><DrawerDescription className="text-sm">{t.details.desc}</DrawerDescription></DrawerHeader>
            <div className="flex-1 overflow-y-auto space-y-6">
              <div className="space-y-3"><p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.overview}</p><InfoRow label={t.status} value={<StatusBadge status={row.original.status} />} /><InfoRow label={t.reqDate} value={fmtFull(row.original.requestedDate, dateLocale)} /></div>
              <div className="space-y-3"><p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.propInfo}</p><InfoRow label="Title" value={row.original.propertyTitle} /></div>
              <div className="space-y-3"><p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.sellerInfo}</p><InfoRow label={t.details.name} value={row.original.sellerName ?? "—"} /><InfoRow label={t.details.email} value={row.original.sellerEmail ?? "—"} /></div>
              <div className="space-y-3"><p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.clientInfo}</p><InfoRow label={t.details.name} value={row.original.userName} /><InfoRow label={t.details.email} value={row.original.userEmail} /></div>
              <div className="space-y-3"><p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.timestamps}</p><div className="grid grid-cols-2 gap-3"><InfoRow label={t.details.createdAt} value={fmtFull(row.original.createdAt, dateLocale)} /><InfoRow label={t.details.updatedAt} value={fmtFull(row.original.updatedAt, dateLocale)} /></div></div>
            </div>
            <DrawerFooter className="mt-auto px-0"><DrawerClose asChild><Button variant="outline" className="w-full">{t.details.close}</Button></DrawerClose></DrawerFooter>
          </div>
        </DrawerContent>
      </Drawer>
    ) },
  ], [t, dateLocale, handleStatusUpdate]);

  const filteredData = useMemo(() => {
    const filtered = visitRequestsWithSeller.filter((r) => {
      const textMatch = [r.userName, r.userEmail, r.propertyTitle, r.status, r.sellerName, r.sellerEmail].filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
      const statusMatch = filterStatus === "ALL" || r.status === filterStatus;
      const created = parseDate(r.createdAt)?.getTime() ?? null;
      const afterMatch = !createdAfter || (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());
      return textMatch && statusMatch && afterMatch && beforeMatch;
    });
    if (dateSort === "newest") filtered.sort((a, b) => (parseDate(b.createdAt)?.getTime() ?? 0) - (parseDate(a.createdAt)?.getTime() ?? 0));
    else if (dateSort === "oldest") filtered.sort((a, b) => (parseDate(a.createdAt)?.getTime() ?? 0) - (parseDate(b.createdAt)?.getTime() ?? 0));
    return filtered;
  }, [visitRequestsWithSeller, search, filterStatus, createdAfter, createdBefore, dateSort]);

  const table = useReactTable({ data: filteredData, columns, state: { pagination }, onPaginationChange: setPagination, getCoreRowModel: getCoreRowModel(), getSortedRowModel: getSortedRowModel(), getPaginationRowModel: getPaginationRowModel() });

  const pendingCount = visitRequestsWithSeller.filter(r => r.status === VisitStatus.PENDING).length;
  const approvedCount = visitRequestsWithSeller.filter(r => r.status === VisitStatus.APPROVED).length;
  const completedCount = visitRequestsWithSeller.filter(r => r.status === VisitStatus.COMPLETED).length;
  const rejectedCount = visitRequestsWithSeller.filter(r => r.status === VisitStatus.REJECTED).length;

  if (loading) return <div className="px-6 py-12 text-center text-sm text-muted-foreground">Loading…</div>;

  return (
    <div className="px-6 py-6 max-w-7xl mx-auto space-y-6 animate-fade-up">
      <div><h1 className="text-2xl font-semibold text-foreground">{t.title}</h1><p className="text-sm text-muted-foreground mt-1">{t.subtitle}</p></div>

      <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
        {[ { label: t.total, value: visitRequestsWithSeller.length, icon: <CalendarCheck className="w-4 h-4" />, bg: "bg-blue-50", tc: "text-blue-600" },
           { label: t.pending, value: pendingCount, icon: <Clock className="w-4 h-4" />, bg: "bg-amber-50", tc: "text-amber-600" },
           { label: t.approved, value: approvedCount, icon: <ThumbsUp className="w-4 h-4" />, bg: "bg-emerald-50", tc: "text-emerald-600" },
           { label: t.completed, value: completedCount, icon: <CheckCircle2 className="w-4 h-4" />, bg: "bg-violet-50", tc: "text-violet-600" },
           { label: t.rejected, value: rejectedCount, icon: <XCircle className="w-4 h-4" />, bg: "bg-red-50", tc: "text-red-600" },
        ].map(c => (
          <div key={c.label} className="bg-card border rounded-xl p-5">
            <div className="flex items-start justify-between">
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">{c.label}</p>
              <div className={`w-9 h-9 rounded-lg ${c.bg} ${c.tc} flex items-center justify-center`}>{c.icon}</div>
            </div>
            <p className={`text-2xl font-bold mt-2`}>{c.value}</p>
          </div>
        ))}
      </div>

      <div className="flex items-center gap-2">
        <input placeholder={t.searchPlaceholder} value={search} onChange={(e) => setSearch(e.target.value)} className="flex-1 h-9 px-3 text-sm bg-card border rounded-lg outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/50 placeholder:text-muted-foreground/60 transition-all" />
        <Button variant="outline" size="sm" onClick={() => setFilterOpen(v => !v)} className="relative h-9 gap-1.5 text-xs font-medium">
          <SlidersHorizontal className="w-3.5 h-3.5" />{t.filters}
          {activeFilterCount > 0 && <span className="flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-white">{activeFilterCount}</span>}
        </Button>
      </div>

      {filterOpen && (
        <div className="bg-card border rounded-xl overflow-hidden animate-fade-up">
          <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/30"><span className="text-xs font-semibold uppercase tracking-wider">{t.filters}</span>{activeFilterCount > 0 && <button onClick={clearFilters} className="text-xs text-muted-foreground hover:text-foreground">{t.clearAll}</button>}</div>
          <div className="p-4 space-y-4">
            <div className="space-y-2"><label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.status}</label>
              <div className="flex flex-wrap gap-1.5">{(["ALL", VisitStatus.PENDING, VisitStatus.APPROVED, VisitStatus.COMPLETED, VisitStatus.REJECTED] as const).map(s => (<button key={s} onClick={() => setFilterStatus(s as any)} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${filterStatus === s ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>{s === "ALL" ? t.all : s}</button>))}</div>
            </div>
            <div className="space-y-2"><label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.sortByDate}</label>
              <div className="flex gap-1.5"><button onClick={() => setDateSort(dateSort === "newest" ? "" : "newest")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${dateSort === "newest" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>↓ {t.newest}</button><button onClick={() => setDateSort(dateSort === "oldest" ? "" : "oldest")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${dateSort === "oldest" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>↑ {t.oldest}</button></div>
            </div>
            <div className="space-y-2"><label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.createdBetween}</label>
              <div className="grid grid-cols-2 gap-2"><div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t.after}</span><Input type="date" value={createdAfter} onChange={(e) => setCreatedAfter(e.target.value)} /></div><div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t.before}</span><Input type="date" value={createdBefore} onChange={(e) => setCreatedBefore(e.target.value)} /></div></div>
            </div>
          </div>
        </div>
      )}

      <div className="bg-card border rounded-xl overflow-hidden">
        <Table><TableHeader>{table.getHeaderGroups().map(hg => (<TableRow key={hg.id} className="border-b bg-muted/30 hover:bg-muted/30">{hg.headers.map(h => <TableHead key={h.id} className="text-xs font-medium text-muted-foreground uppercase tracking-wider h-10">{flexRender(h.column.columnDef.header, h.getContext())}</TableHead>)}</TableRow>))}</TableHeader>
          <TableBody>{table.getRowModel().rows.length === 0 ? <TableRow><TableCell colSpan={columns.length} className="text-center text-muted-foreground py-16 text-sm">{t.noResults}</TableCell></TableRow> : table.getRowModel().rows.map(row => <TableRow key={row.id} className="hover:bg-muted/20 transition-colors">{row.getVisibleCells().map(cell => <TableCell key={cell.id} className="py-3">{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>)}</TableRow>)}</TableBody>
        </Table>
      </div>

      <div className="flex justify-between items-center">
        <span className="text-xs text-muted-foreground">{filteredData.length} requests</span>
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