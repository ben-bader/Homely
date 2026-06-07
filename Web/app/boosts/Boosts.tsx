"use client";

import React, { useMemo, useState, useCallback, useEffect } from "react";
import { useReactTable, getCoreRowModel, getSortedRowModel, getPaginationRowModel, flexRender, type ColumnDef } from "@tanstack/react-table";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Drawer, DrawerTrigger, DrawerContent, DrawerHeader, DrawerTitle, DrawerDescription, DrawerFooter, DrawerClose } from "@/components/ui/drawer";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { api } from "@/lib/api";
import type { Boost, BoostStatus, BoostPackage } from "@/types/dashboard-types";
import { Eye, Rocket, Clock, CheckCircle2, XCircle, SlidersHorizontal } from "lucide-react";
// KPI cards inlined (no shared KPI component)
import { PaginationFooter } from "@/components/ui/pagination";
import useBoostPackages from "@/app/boosts/useBoostPackages";
import { useTranslations } from "next-intl";
import { StatusBadge } from "@/components/platform/status-badge";
import { MetricCard } from "@/components/platform/metric-card";

function parseDate(v: string | number | null | undefined): Date | null {
  if (!v) return null;
  if (typeof v === "number") return new Date(v);
  if (typeof v === "string" && !v.endsWith("Z") && !v.includes("+")) return new Date(v + "Z");
  return new Date(v);
}
function fmt(v: string | number | null | undefined) { const d = parseDate(v); return d ? d.toLocaleDateString() : "—"; }
function fmtFull(v: string | number | null | undefined) { const d = parseDate(v); return d ? d.toLocaleString() : "—"; }

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground font-medium">{label}</span>
      <span className="text-sm font-medium text-foreground">{typeof value === "string" || typeof value === "number" ? value : <div className="mt-0.5">{value}</div>}</span>
    </div>
  );
}

function BoostDrawer({ boost, packageName, t }: { boost: Boost; packageName?: string; t: any }) {
  return (
    <Drawer direction="right">
      <DrawerTrigger asChild><Button variant="ghost" size="icon" className="h-8 w-8 text-muted-foreground hover:text-foreground"><Eye className="w-4 h-4" /></Button></DrawerTrigger>
      <DrawerContent className="max-w-md ml-auto h-full">
        <div className="flex flex-col h-full p-6">
          <DrawerHeader className="px-0 pb-4">
            <DrawerTitle className="text-lg">{t('drawer.title')}</DrawerTitle>
            <DrawerDescription className="text-sm">{t('drawer.description')}</DrawerDescription>
          </DrawerHeader>
          <div className="flex-1 overflow-y-auto space-y-6">
            <section className="space-y-3">
              <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('drawer.sectionBoost')}</p>
              <InfoRow label={t('drawer.status')} value={<StatusBadge status={boost.status} />} />
              <InfoRow label={t('drawer.packageName')} value={packageName ?? "—"} />
            </section>
            <section className="space-y-3">
              <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('drawer.sectionProperty')}</p>
              <InfoRow label={t('drawer.propertyTitle')} value={boost.propertyTitle} />
            </section>
            <section className="space-y-3">
              <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('drawer.sectionSeller')}</p>
              <InfoRow label={t('drawer.sellerName')} value={boost.userName} />
              <InfoRow label={t('drawer.sellerEmail')} value={boost.userEmail} />
            </section>
            <section className="space-y-3">
              <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('drawer.sectionTimestamps')}</p>
              <div className="grid grid-cols-2 gap-3">
                <InfoRow label={t('drawer.createdAt')} value={fmtFull(boost.createdAt)} />
                <InfoRow label={t('drawer.updatedAt')} value={fmtFull(boost.updatedAt)} />
              </div>
            </section>
          </div>
          <DrawerFooter className="mt-auto px-0"><DrawerClose asChild><Button variant="outline" className="w-full">{t('drawer.close')}</Button></DrawerClose></DrawerFooter>
        </div>
      </DrawerContent>
    </Drawer>
  );
}

export default function Boosts() {
  const t = useTranslations('boosts');
  const [boosts, setBoosts] = useState<Boost[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
  const [filterStatus, setFilterStatus] = useState<BoostStatus | "ALL">("ALL");
  const [createdAfter, setCreatedAfter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [dateSort, setDateSort] = useState<"" | "newest" | "oldest">("");
  const [filterOpen, setFilterOpen] = useState(false);
  const { packages: boostPackages, loading: loadingPackages } = useBoostPackages();

  useEffect(() => {
    api.get<Boost[]>("/admin/boosts")
      .then((res) => setBoosts(res.data ?? []))
      .catch(() => setError(t('error')))
      .finally(() => setLoading(false));
  }, []);

  const handleStatusUpdate = useCallback(async (id: string, status: BoostStatus) => {
    await api.put(`/admin/boosts/${id}/status`, null, { params: { status } });
    setBoosts((prev) => prev.map((b) => (b.id === id ? { ...b, status } : b)));
  }, []);

  const clearFilters = () => { setFilterStatus("ALL"); setCreatedAfter(""); setCreatedBefore(""); setDateSort(""); };
  const activeFilterCount = [filterStatus !== "ALL", createdAfter !== "", createdBefore !== "", dateSort !== ""].filter(Boolean).length;

  const durationToName = useMemo(() => Object.fromEntries(boostPackages.map(p => [p.durationDays, p.name])), [boostPackages]);

  const columns = useMemo<ColumnDef<Boost>[]>(() => [
    { accessorKey: "propertyTitle", header: t('table.property'), cell: ({ row }) => <span className="text-sm font-medium">{row.original.propertyTitle}</span> },
    { accessorKey: "userName", header: t('table.seller'), cell: ({ row }) => <div><p className="text-sm font-medium">{row.original.userName}</p><p className="text-xs text-muted-foreground">{row.original.userEmail}</p></div> },
    { accessorKey: "durationDays", header: t('table.packageName'), cell: ({ row }) => <span className="text-sm">{durationToName[row.original.durationDays] ?? "—"}</span> },
    { accessorKey: "createdAt", header: t('table.createdAt'), cell: ({ row }) => <span className="text-sm text-muted-foreground">{fmt(row.original.createdAt)}</span> },
    {
      accessorKey: "status", header: t('table.status'),
      cell: ({ row }) => (
        <Select value={row.original.status} onValueChange={(v: string) => handleStatusUpdate(row.original.id, v as BoostStatus)}>
          <SelectTrigger className="w-32 h-7 text-xs"><SelectValue /></SelectTrigger>
          <SelectContent>
            <SelectItem value="PENDING">PENDING</SelectItem>
            <SelectItem value="COMPLETED">COMPLETED</SelectItem>
            <SelectItem value="FAILED">FAILED</SelectItem>
          </SelectContent>
        </Select>
      ),
    },
    { id: "view", header: "", cell: ({ row }) => <BoostDrawer boost={row.original} packageName={durationToName[row.original.durationDays]} t={t} /> },
  ], [handleStatusUpdate, durationToName, t]);

  const filteredData = useMemo(() => {
    return boosts.filter(b => {
      const textMatch = [b.propertyTitle, b.userName, b.userEmail, b.id].filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
      const statusMatch = filterStatus === "ALL" || b.status === filterStatus;
      const created = parseDate(b.createdAt)?.getTime() ?? null;
      const afterMatch = !createdAfter || (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());
      return textMatch && statusMatch && afterMatch && beforeMatch;
    }).sort((a, b) => {
      if (dateSort === "newest") return (parseDate(b.createdAt)?.getTime() ?? 0) - (parseDate(a.createdAt)?.getTime() ?? 0);
      if (dateSort === "oldest") return (parseDate(a.createdAt)?.getTime() ?? 0) - (parseDate(b.createdAt)?.getTime() ?? 0);
      return 0;
    });
  }, [boosts, search, filterStatus, createdAfter, createdBefore, dateSort]);

  const table = useReactTable({ data: filteredData, columns, state: { pagination }, onPaginationChange: setPagination, getCoreRowModel: getCoreRowModel(), getSortedRowModel: getSortedRowModel(), getPaginationRowModel: getPaginationRowModel() });

  const pending = boosts.filter(b => b.status === "PENDING").length;
  const completed = boosts.filter(b => b.status === "COMPLETED").length;
  const failed = boosts.filter(b => b.status === "FAILED").length;
  const percentOfBoosts = (value: number) =>
    boosts.length > 0 ? Math.round((value / boosts.length) * 100) : 0;

  if (loading || loadingPackages) return <div className="px-6 py-12 text-center text-sm text-muted-foreground">{t('loading')}</div>;
  if (error) return <div className="px-6 py-12 text-center text-sm text-red-500">{error}</div>;

  return (
    <div className="px-6 py-6 max-w-7xl mx-auto space-y-6 animate-fade-up">
      <div><h1 className="text-2xl font-semibold text-foreground">{t('title')}</h1></div>

      {/* Summary Cards (kept inline) */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <MetricCard label={t('total')} value={boosts.length} detail={t('title')} icon={<Rocket className="w-5 h-5" />} accent="blue" progress={100} />
        <MetricCard label={t('pending')} value={pending} detail={`${percentOfBoosts(pending)}% ${t('pending')}`} icon={<Clock className="w-5 h-5" />} accent="amber" progress={percentOfBoosts(pending)} />
        <MetricCard label={t('completed')} value={completed} detail={`${percentOfBoosts(completed)}% ${t('completed')}`} icon={<CheckCircle2 className="w-5 h-5" />} accent="emerald" progress={percentOfBoosts(completed)} />
        <MetricCard label={t('failed')} value={failed} detail={`${percentOfBoosts(failed)}% ${t('failed')}`} icon={<XCircle className="w-5 h-5" />} accent="red" progress={percentOfBoosts(failed)} />
      </div>

      {/* Search + Filter */}
      <div className="flex items-center gap-2">
        <input placeholder={t('searchPlaceholder')} value={search} onChange={(e) => setSearch(e.target.value)}
          className="flex-1 h-9 px-3 text-sm bg-card border rounded-lg outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/50 placeholder:text-muted-foreground/60 transition-all" />
        <Button variant="outline" size="sm" onClick={() => setFilterOpen(v => !v)} className="relative h-9 gap-1.5 text-xs font-medium">
          <SlidersHorizontal className="w-3.5 h-3.5" />{t('filter')}
          {activeFilterCount > 0 && <span className="flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-white">{activeFilterCount}</span>}
        </Button>
      </div>

      {filterOpen && (
        <div className="bg-card border rounded-xl overflow-hidden animate-fade-up">
          <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/30">
            <span className="text-xs font-semibold uppercase tracking-wider">{t('filter')}</span>
            {activeFilterCount > 0 && <button onClick={clearFilters} className="text-xs text-muted-foreground hover:text-foreground">{t('filters.clearAll')}</button>}
          </div>
          <div className="p-4 space-y-4">
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Status</label>
              <div className="flex flex-wrap gap-1.5">
                {(["ALL", "PENDING", "COMPLETED", "FAILED"] as const).map(s => (
                  <button key={s} onClick={() => setFilterStatus(s)} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${filterStatus === s ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>{s}</button>
                ))}
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t('filters.sortByDate')}</label>
              <div className="flex gap-1.5">
                <button onClick={() => setDateSort(dateSort === "newest" ? "" : "newest")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${dateSort === "newest" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>↓ {t('filters.newestFirst')}</button>
                <button onClick={() => setDateSort(dateSort === "oldest" ? "" : "oldest")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${dateSort === "oldest" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>↑ {t('filters.oldestFirst')}</button>
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t('filters.startedBetween')}</label>
              <div className="grid grid-cols-2 gap-2">
                <div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t('filters.after')}</span><Input type="date" value={createdAfter} onChange={(e) => setCreatedAfter(e.target.value)} /></div>
                <div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t('filters.before')}</span><Input type="date" value={createdBefore} onChange={(e) => setCreatedBefore(e.target.value)} /></div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Table */}
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
              <TableRow><TableCell colSpan={columns.length} className="text-center text-muted-foreground py-16 text-sm">{t('noMatch')}</TableCell></TableRow>
            ) : table.getRowModel().rows.map(row => (
              <TableRow key={row.id} className="hover:bg-muted/20 transition-colors">
                {row.getVisibleCells().map(cell => <TableCell key={cell.id} className="py-3">{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>)}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-between items-center">
        <span className="text-xs text-muted-foreground">{filteredData.length} boosts</span>
        <PaginationFooter
          pageInfo={`${t('page')} ${pagination.pageIndex + 1} ${t('of')} ${Math.max(table.getPageCount(), 1)}`}
          onPrevious={() => table.previousPage()}
          onNext={() => table.nextPage()}
          canPrevious={table.getCanPreviousPage()}
          canNext={table.getCanNextPage()}
        />
      </div>
    </div>
  );
}
