"use client";

import React, { useMemo, useState, useCallback, useEffect } from "react";
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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

import { api } from "@/lib/api";
import type { Boost, BoostStatus, BoostPackage } from "@/types/dashboard-types";
import { FaEye } from "react-icons/fa";
import useBoostPackages from "@/hooks/useBoostPackages";

/* ---------------- HELPERS ---------------- */

function parseDate(v: string | number | null | undefined): Date | null {
  if (!v) return null;
  if (typeof v === "number") return new Date(v);
  if (typeof v === "string" && !v.endsWith("Z") && !v.includes("+"))
    return new Date(v + "Z");
  return new Date(v);
}

function fmt(v: string | number | null | undefined) {
  const d = parseDate(v);
  return d ? d.toLocaleDateString() : "—";
}

function fmtFull(v: string | number | null | undefined) {
  const d = parseDate(v);
  return d ? d.toLocaleString() : "—";
}

function statusVariant(status: BoostStatus): "default" | "secondary" | "destructive" | "outline" {
  switch (status) {
    case "COMPLETED": return "default";
    case "PENDING": return "secondary";
    case "FAILED": return "destructive";
    default: return "outline";
  }
}

/* ---------------- INFO ROW ---------------- */

function InfoRow({ label, value, mono = false }: { label: string; value: React.ReactNode; mono?: boolean }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">{label}</span>
      {typeof value === "string" || typeof value === "number" ? (
        <span className={mono ? "font-mono text-xs break-all text-foreground" : "text-sm font-medium text-foreground"}>
          {value}
        </span>
      ) : (
        <div className="mt-0.5">{value}</div>
      )}
    </div>
  );
}

/* ---------------- BOOST DRAWER ---------------- */

function BoostDrawer({ boost, packageName }: { boost: Boost; packageName?: string }) {
  return (
    <Drawer direction="right">
      <DrawerTrigger asChild>
        <Button variant="ghost" size="icon"><FaEye /></Button>
      </DrawerTrigger>

      <DrawerContent className="flex flex-col max-w-md ml-auto h-full">
        <DrawerHeader className="border-b pb-4">
          <DrawerTitle className="text-base font-semibold">Boost Info</DrawerTitle>
          <DrawerDescription className="text-xs text-muted-foreground">
            Full details for this boost purchase
          </DrawerDescription>
        </DrawerHeader>

        <div className="flex-1 overflow-y-auto p-5 space-y-6">
          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Boost</p>
            <InfoRow label="Status" value={<Badge variant={statusVariant(boost.status)}>{boost.status}</Badge>} />
            <InfoRow label="Package Name" value={packageName ?? "—"} />
          </section>

          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Property</p>
            <InfoRow label="Title" value={boost.propertyTitle} />
          </section>

          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Seller</p>
            <InfoRow label="Name" value={boost.userName} />
            <InfoRow label="Email" value={boost.userEmail} />
          </section>

          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Timestamps</p>
            <div className="grid grid-cols-2 gap-3">
              <InfoRow label="Created At" value={fmtFull(boost.createdAt)} />
              <InfoRow label="Updated At" value={fmtFull(boost.updatedAt)} />
            </div>
          </section>
        </div>

        <DrawerFooter className="border-t">
          <DrawerClose asChild>
            <Button variant="outline" className="w-full">Close</Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}

/* ---------------- STATUS SELECT ---------------- */

function StatusSelect({ boost, onUpdate }: { boost: Boost; onUpdate: (id: string, status: BoostStatus) => Promise<void> }) {
  return (
    <Select value={boost.status} onValueChange={(value: string) => onUpdate(boost.id, value as BoostStatus)}>
      <SelectTrigger className="w-32">
        <SelectValue placeholder="Select status" />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="PENDING">PENDING</SelectItem>
        <SelectItem value="COMPLETED">COMPLETED</SelectItem>
        <SelectItem value="FAILED">FAILED</SelectItem>
      </SelectContent>
    </Select>
  );
}

/* ---------------- COLUMNS ---------------- */

function buildColumns(
  onUpdate: (id: string, status: BoostStatus) => Promise<void>,
  boostPackages: BoostPackage[]
): ColumnDef<Boost>[] {
  // Map durationDays -> package name
  const durationToName = Object.fromEntries(boostPackages.map(p => [p.durationDays, p.name]));

  return [
    {
      accessorKey: "propertyTitle",
      header: "Property",
      cell: ({ row }) => <p className="text-sm font-medium">{row.original.propertyTitle}</p>,
    },
    {
      accessorKey: "userName",
      header: "Seller",
      cell: ({ row }) => (
        <div>
          <p className="text-sm font-medium">{row.original.userName}</p>
          <p className="text-xs text-muted-foreground">{row.original.userEmail}</p>
        </div>
      ),
    },
    {
      accessorKey: "durationDays",
      header: "Package Name",
      cell: ({ row }) => <span className="text-sm">{durationToName[row.original.durationDays] ?? "—"}</span>,
    },
    {
      accessorKey: "createdAt",
      header: "Created At",
      cell: ({ row }) => fmt(row.original.createdAt),
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }) => <StatusSelect boost={row.original} onUpdate={onUpdate} />,
    },
    {
      id: "seeMore",
      header: "",
      cell: ({ row }) => <BoostDrawer boost={row.original} packageName={durationToName[row.original.durationDays]} />,
    },
  ];
}
/* ---------------- MAIN PAGE ---------------- */

export default function Boosts() {
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
    api
      .get<Boost[]>("/admin/boosts")
      .then((res) => setBoosts(res.data ?? []))
      .catch(() => setError("Failed to load boosts"))
      .finally(() => setLoading(false));
  }, []);

  const handleStatusUpdate = useCallback(
    async (id: string, status: BoostStatus) => {
      await api.put(`/admin/boosts/${id}/status`, null, { params: { status } });
      setBoosts((prev) => prev.map((b) => (b.id === id ? { ...b, status } : b)));
    },
    []
  );

  const clearFilters = () => {
    setFilterStatus("ALL");
    setCreatedAfter("");
    setCreatedBefore("");
    setDateSort("");
  };

  const activeFilterCount = [
    filterStatus !== "ALL",
    createdAfter !== "",
    createdBefore !== "",
    dateSort !== "",
  ].filter(Boolean).length;

  const columns = useMemo(() => buildColumns(handleStatusUpdate, boostPackages), [handleStatusUpdate, boostPackages]);

  const filteredData = useMemo(() => {
    return boosts.filter(b => {
      const textMatch = [b.propertyTitle, b.userName, b.userEmail, b.id]
        .filter(Boolean)
        .join(" ")
        .toLowerCase()
        .includes(search.toLowerCase());
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

  const table = useReactTable({
    data: filteredData,
    columns,
    state: { pagination },
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  if (loading || loadingPackages) return <div className="p-8">Loading boosts…</div>;
  if (error) return <div className="p-8 text-red-500">{error}</div>;

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">Boosts</h2>

      {/* Search + Filter toggle */}
      <div className="flex gap-2">
        <Input placeholder="Search by property, seller…" value={search} onChange={(e) => setSearch(e.target.value)} />
        <Button variant="outline" onClick={() => setFilterOpen(v => !v)} className="relative">
          Filter
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
          filterStatus={filterStatus} setFilterStatus={setFilterStatus}
          createdAfter={createdAfter} setCreatedAfter={setCreatedAfter}
          createdBefore={createdBefore} setCreatedBefore={setCreatedBefore}
          dateSort={dateSort} setDateSort={setDateSort}
          onClear={clearFilters}
        />
      )}

      {/* Table */}
      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader className="bg-blue-900 text-white">
            {table.getHeaderGroups().map(hg => (
              <TableRow key={hg.id}>
                {hg.headers.map(header => (
                  <TableHead key={header.id}>
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
                  No boosts match your filters
                </TableCell>
              </TableRow>
            ) : (
              table.getRowModel().rows.map(row => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map(cell => (
                    <TableCell key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>
                  ))}
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      {/* Pagination */}
      <div className="flex justify-center items-center gap-2 px-4 py-2 border-t text-sm text-muted-foreground">
  <Button
    variant="outline"
    size="sm"
    onClick={() => table.previousPage()}
    disabled={!table.getCanPreviousPage()}
  >
    Previous
  </Button>

  <span>
    Page {pagination.pageIndex + 1} of {Math.max(table.getPageCount(), 1)}
  </span>

  <Button
    variant="outline"
    size="sm"
    onClick={() => table.nextPage()}
    disabled={!table.getCanNextPage()}
  >
    Next
  </Button>
</div>
    </div>
  );
}