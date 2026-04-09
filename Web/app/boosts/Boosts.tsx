"use client";

import React, { useMemo, useState, useCallback, useEffect } from "react";
import { useReactTable, getCoreRowModel, getSortedRowModel, getPaginationRowModel, flexRender, type ColumnDef } from "@tanstack/react-table";
import { Badge } from "@/components/ui/badge";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Drawer, DrawerTrigger, DrawerContent, DrawerHeader, DrawerTitle, DrawerDescription, DrawerFooter, DrawerClose } from "@/components/ui/drawer";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { api } from "@/lib/api";
import type { Boost, BoostStatus, BoostPackage } from "@/types/dashboard-types";
import { FaEye } from "react-icons/fa";
import useBoostPackages from "@/app/boosts/useBoostPackages";
import { useTranslations } from "next-intl";

function parseDate(v: string | number | null | undefined): Date | null {
  if (!v) return null;
  if (typeof v === "number") return new Date(v);
  if (typeof v === "string" && !v.endsWith("Z") && !v.includes("+")) return new Date(v + "Z");
  return new Date(v);
}
function fmt(v: string | number | null | undefined) { const d = parseDate(v); return d ? d.toLocaleDateString() : "—"; }
function fmtFull(v: string | number | null | undefined) { const d = parseDate(v); return d ? d.toLocaleString() : "—"; }
function statusVariant(status: BoostStatus): "default" | "secondary" | "destructive" | "outline" {
  switch (status) {
    case "COMPLETED": return "default";
    case "PENDING": return "secondary";
    case "FAILED": return "destructive";
    default: return "outline";
  }
}

function InfoRow({ label, value, mono = false }: { label: string; value: React.ReactNode; mono?: boolean }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">{label}</span>
      {typeof value === "string" || typeof value === "number" ? (
        <span className={mono ? "font-mono text-xs break-all text-foreground" : "text-sm font-medium text-foreground"}>{value}</span>
      ) : <div className="mt-0.5">{value}</div>}
    </div>
  );
}

function BoostDrawer({ boost, packageName }: { boost: Boost; packageName?: string }) {
  const t = useTranslations('boosts.drawer');
  return (
    <Drawer direction="right">
      <DrawerTrigger asChild><Button variant="ghost" size="icon"><FaEye /></Button></DrawerTrigger>
      <DrawerContent className="flex flex-col max-w-md ml-auto h-full">
        <DrawerHeader className="border-b pb-4">
          <DrawerTitle className="text-base font-semibold">{t('title')}</DrawerTitle>
          <DrawerDescription className="text-xs text-muted-foreground">{t('description')}</DrawerDescription>
        </DrawerHeader>
        <div className="flex-1 overflow-y-auto p-5 space-y-6">
          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('sectionBoost')}</p>
            <InfoRow label={t('status')} value={<Badge variant={statusVariant(boost.status)}>{boost.status}</Badge>} />
            <InfoRow label={t('packageName')} value={packageName ?? "—"} />
          </section>
          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('sectionProperty')}</p>
            <InfoRow label={t('propertyTitle')} value={boost.propertyTitle} />
          </section>
          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('sectionSeller')}</p>
            <InfoRow label={t('sellerName')} value={boost.userName} />
            <InfoRow label={t('sellerEmail')} value={boost.userEmail} />
          </section>
          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('sectionTimestamps')}</p>
            <div className="grid grid-cols-2 gap-3">
              <InfoRow label={t('createdAt')} value={fmtFull(boost.createdAt)} />
              <InfoRow label={t('updatedAt')} value={fmtFull(boost.updatedAt)} />
            </div>
          </section>
        </div>
        <DrawerFooter className="border-t">
          <DrawerClose asChild><Button variant="outline" className="w-full bg-black hover:bg-gray-900 text-white border-gray-700">{t('close')}</Button></DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}

function SummaryCards({ boosts, t }: { boosts: Boost[]; t: any }) {
  const pending = boosts.filter((b) => b.status === "PENDING").length;
  const completed = boosts.filter((b) => b.status === "COMPLETED").length;
  const failed = boosts.filter((b) => b.status === "FAILED").length;

  const cards = [
    { label: t('total'), value: boosts.length, colorClass: "text-foreground", bgClass: "bg-muted/50" },
    { label: t('pending'), value: pending, colorClass: "text-yellow-600", bgClass: "bg-yellow-50 dark:bg-yellow-950/30" },
    { label: t('completed'), value: completed, colorClass: "text-green-600", bgClass: "bg-green-50 dark:bg-green-950/30" },
    { label: t('failed'), value: failed, colorClass: "text-destructive", bgClass: "bg-destructive/10" },
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

function StatusSelect({ boost, onUpdate }: { boost: Boost; onUpdate: (id: string, status: BoostStatus) => Promise<void> }) {
  const t = useTranslations('boosts');
  const status = boost.status;
  let triggerClass = "w-32 h-7 text-xs";
  if (status === "PENDING") triggerClass += " bg-yellow-50 dark:bg-yellow-950/30 text-yellow-700 dark:text-yellow-400 border-yellow-200/50 dark:border-yellow-900/50";
  else if (status === "COMPLETED") triggerClass += " bg-green-50 dark:bg-green-950/30 text-green-700 dark:text-green-400 border-green-200/50 dark:border-green-900/50";
  else if (status === "FAILED") triggerClass += " bg-destructive/10 text-destructive border-destructive/30";
  
  return (
    <Select value={status} onValueChange={(value: string) => onUpdate(boost.id, value as BoostStatus)}>
      <SelectTrigger className={triggerClass}><SelectValue placeholder={t('statusPlaceholder')} /></SelectTrigger>
      <SelectContent>
        <SelectItem value="PENDING">PENDING</SelectItem>
        <SelectItem value="COMPLETED">COMPLETED</SelectItem>
        <SelectItem value="FAILED">FAILED</SelectItem>
      </SelectContent>
    </Select>
  );
}

function buildColumns(
  onUpdate: (id: string, status: BoostStatus) => Promise<void>,
  boostPackages: BoostPackage[],
  t: ReturnType<typeof useTranslations>
): ColumnDef<Boost>[] {
  const durationToName = Object.fromEntries(boostPackages.map(p => [p.durationDays, p.name]));
  return [
    { accessorKey: "propertyTitle", header: t('table.property'), cell: ({ row }) => <p className="text-sm font-medium">{row.original.propertyTitle}</p> },
    { accessorKey: "userName", header: t('table.seller'), cell: ({ row }) => <div><p className="text-sm font-medium">{row.original.userName}</p><p className="text-xs text-muted-foreground">{row.original.userEmail}</p></div> },
    { accessorKey: "durationDays", header: t('table.packageName'), cell: ({ row }) => <span className="text-sm">{durationToName[row.original.durationDays] ?? "—"}</span> },
    { accessorKey: "createdAt", header: t('table.createdAt'), cell: ({ row }) => fmt(row.original.createdAt) },
    { accessorKey: "status", header: t('table.status'), cell: ({ row }) => <StatusSelect boost={row.original} onUpdate={onUpdate} /> },
    { id: "seeMore", header: "", cell: ({ row }) => <BoostDrawer boost={row.original} packageName={durationToName[row.original.durationDays]} /> },
  ];
}

function FilterPanel({ filterStatus, setFilterStatus, createdAfter, setCreatedAfter, createdBefore, setCreatedBefore, dateSort, setDateSort, onClear }: any) {
  const t = useTranslations('boosts.filters');
  const statusOptions = [
    { value: "ALL", label: "ALL" },
    { value: "PENDING", label: "PENDING" },
    { value: "COMPLETED", label: "COMPLETED" },
    { value: "FAILED", label: "FAILED" },
  ];
  const dateSortOptions = [
    { value: "newest", label: t('newestFirst'), icon: "↓" },
    { value: "oldest", label: t('oldestFirst'), icon: "↑" },
  ];
  const activeCount = [filterStatus !== "ALL", createdAfter !== "", createdBefore !== "", dateSort !== ""].filter(Boolean).length;

  return (
    <div className="rounded-lg border bg-background shadow-sm overflow-hidden">
      <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/40">
        <div className="flex items-center gap-2">
          <span className="text-xs font-semibold text-foreground uppercase tracking-widest">{t('label')}</span>
          {activeCount > 0 && <span className="inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">{activeCount}</span>}
        </div>
        {activeCount > 0 && <button onClick={onClear} className="text-[11px] text-muted-foreground hover:text-foreground transition-colors font-medium">{t('clearAll')}</button>}
      </div>
      <div className="p-4 space-y-5">
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Status</label>
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
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t('sortByDate')}</label>
          <div className="flex gap-1.5">
            {dateSortOptions.map(({ value, label, icon }) => (
              <button key={value} onClick={() => setDateSort(dateSort === value ? "" : value)} className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${dateSort === value ? "bg-primary text-primary-foreground border-primary" : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"}`}>
                <span>{icon}</span>{label}
              </button>
            ))}
          </div>
        </div>
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t('startedBetween')}</label>
          <div className="grid grid-cols-2 gap-2">
            <div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t('after')}</span><Input type="date" value={createdAfter} onChange={(e) => setCreatedAfter(e.target.value)} /></div>
            <div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t('before')}</span><Input type="date" value={createdBefore} onChange={(e) => setCreatedBefore(e.target.value)} /></div>
          </div>
        </div>
      </div>
    </div>
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
  const columns = useMemo(() => buildColumns(handleStatusUpdate, boostPackages, t), [handleStatusUpdate, boostPackages, t]);

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

  if (loading || loadingPackages) return <div className="p-8">{t('loading')}</div>;
  if (error) return <div className="p-8 text-red-500">{error}</div>;

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">{t('title')}</h2>
      <SummaryCards boosts={boosts} t={t} />
      <div className="flex gap-2">
        <Input placeholder={t('searchPlaceholder')} value={search} onChange={(e) => setSearch(e.target.value)} />
        <Button variant="outline" onClick={() => setFilterOpen(v => !v)} className="relative">
          {t('filter')}
          {activeFilterCount > 0 && <span className="absolute -top-1.5 -right-1.5 inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">{activeFilterCount}</span>}
        </Button>
      </div>
      {filterOpen && <FilterPanel filterStatus={filterStatus} setFilterStatus={setFilterStatus} createdAfter={createdAfter} setCreatedAfter={setCreatedAfter} createdBefore={createdBefore} setCreatedBefore={setCreatedBefore} dateSort={dateSort} setDateSort={setDateSort} onClear={clearFilters} />}
      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader className="bg-primary text-white">
            {table.getHeaderGroups().map(hg => <TableRow key={hg.id}>{hg.headers.map(header => <TableHead key={header.id} className="text-white">{flexRender(header.column.columnDef.header, header.getContext())}</TableHead>)}</TableRow>)}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length === 0 ? (
              <TableRow><TableCell colSpan={columns.length} className="text-center text-muted-foreground py-12 text-sm">{t('noMatch')}</TableCell></TableRow>
            ) : table.getRowModel().rows.map(row => <TableRow key={row.id}>{row.getVisibleCells().map(cell => <TableCell key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>)}</TableRow>)}
          </TableBody>
        </Table>
      </div>
      <div className="flex justify-center items-center gap-2 px-4 py-2 border-t text-sm text-muted-foreground">
        <Button variant="outline" size="sm" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>←</Button>
        <span>{t('page')} {pagination.pageIndex + 1} {t('of')} {Math.max(table.getPageCount(), 1)}</span>
        <Button variant="outline" size="sm" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>→</Button>
      </div>
    </div>
  );
}