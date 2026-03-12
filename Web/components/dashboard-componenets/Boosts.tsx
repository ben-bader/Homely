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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { api } from "@/lib/api";
import type { Boost, BoostStatus } from "@/types/dashboard-types";

/* ---------------- TYPES ---------------- */

type DateSort = "" | "newest" | "oldest";

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

function statusDot(status: BoostStatus) {
  switch (status) {
    case "COMPLETED": return "bg-green-500";
    case "PENDING": return "bg-yellow-400";
    case "FAILED": return "bg-destructive";
    default: return "bg-muted-foreground";
  }
}

/* ---------------- SUMMARY CARDS ---------------- */

function SummaryCards({ boosts }: { boosts: Boost[] }) {
  const total = boosts.length;
  const pending = boosts.filter((b) => b.status === "PENDING").length;
  const completed = boosts.filter((b) => b.status === "COMPLETED").length;
  const failed = boosts.filter((b) => b.status === "FAILED").length;
  const revenue = boosts
    .filter((b) => b.status === "COMPLETED")
    .reduce((sum, b) => sum + (b.amount ?? 0), 0);

  const cards = [
    {
      label: "Total Boosts",
      value: total,
      icon: (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
      ),
      colorClass: "text-foreground",
      bgClass: "bg-muted/50",
      display: String(total),
    },
    {
      label: "Pending",
      value: pending,
      icon: (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      colorClass: "text-yellow-600 dark:text-yellow-400",
      bgClass: "bg-yellow-50 dark:bg-yellow-950/30",
      display: String(pending),
    },
    {
      label: "Completed",
      value: completed,
      icon: (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      colorClass: "text-green-600",
      bgClass: "bg-green-50 dark:bg-green-950/30",
      display: String(completed),
    },
    {
      label: "Revenue",
      value: revenue,
      icon: (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      colorClass: "text-primary",
      bgClass: "bg-primary/5",
      display: `$${revenue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`,
    },
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
      {cards.map((card) => (
        <div key={card.label} className={`rounded-lg border p-4 flex items-center gap-3 ${card.bgClass}`}>
          <div className={`shrink-0 ${card.colorClass}`}>{card.icon}</div>
          <div>
            <p className="text-[11px] uppercase tracking-widest text-muted-foreground font-semibold">
              {card.label}
            </p>
            <p className={`text-2xl font-bold ${card.colorClass}`}>{card.display}</p>
          </div>
        </div>
      ))}
    </div>
  );
}


    // Handle adding new package
    const handleAddPackage = async () => {
      if (!newPackage.name || !newPackage.price || !newPackage.durationDays) {
        alert('Please fill in all fields');
        return;
      }
      
      setSavingPackage(true);
      try {
        await addPackage({
          name: newPackage.name,
          description: newPackage.description,
          durationDays: parseInt(newPackage.durationDays),
          price: parseFloat(newPackage.price),
        });
        setNewPackage({ name: '', description: '', durationDays: '', price: '' });
        setShowAddPackageForm(false);
      } catch (err) {
        console.error('Failed to add package', err);
        alert('Failed to add package');
      } finally {
        setSavingPackage(false);
      }
    };

    // Handle deleting package
    const handleDeletePackage = async (packageId: number) => {
      if (!confirm('Are you sure you want to delete this package?')) return;
      try {
        await deletePackage(packageId);
      } catch (err) {
        console.error('Failed to delete package', err);
        alert('Failed to delete package');
      }
    };

    // Columns
    const columns = React.useMemo<ColumnDef<Boost>[]>(
      () => [
        {
          accessorKey: "propertyTitle",
          header: "Property Title",
          cell: ({ row }) => <BoostDrawer boost={row.original} onStatusChange={updateStatus} />,
        },
        { accessorKey: "userName", header: "Seller Name" },
        { accessorKey: "userEmail", header: "Seller Email" },
        { accessorKey: "amount", header: "Amount" },
        {
          id: "status",
          header: "Status",
          cell: ({ row }) => {
            const currentStatus = row.original.status;
            return (
              <Select
                value={currentStatus}
                onValueChange={(value: string) => updateStatus(row.original.id, value as BoostStatus)}
              >
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
          },
        },
      ],
      [updateStatus]
    );

function StatusSelect({
  boost,
  onUpdate,
}: {
  boost: Boost;
  onUpdate: (id: string, status: BoostStatus) => Promise<void>;
}) {
  const [loading, setLoading] = useState(false);

  const handleChange = async (value: string) => {
    setLoading(true);
    try {
      await onUpdate(boost.id, value as BoostStatus);
    } finally {
      setLoading(false);
    }
  };



    const table = useReactTable({
      data: filteredBoosts,
      columns,
      state: { columnFilters, sorting, columnVisibility, pagination },
      onColumnFiltersChange: setColumnFilters,
      onSortingChange: setSorting,
      onColumnVisibilityChange: setColumnVisibility,
      onPaginationChange: setPagination,
      getCoreRowModel: getCoreRowModel(),
      getSortedRowModel: getSortedRowModel(),
      getFilteredRowModel: getFilteredRowModel(),
      getPaginationRowModel: getPaginationRowModel(),
    });

/* ---------------- INFO ROW ---------------- */

function InfoRow({
  label,
  value,
  mono = false,
}: {
  label: string;
  value: React.ReactNode;
  mono?: boolean;
}) {
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

/* ---------------- FILTER PANEL ---------------- */

function FilterPanel({
  filterStatus, setFilterStatus,
  createdAfter, setCreatedAfter,
  createdBefore, setCreatedBefore,
  dateSort, setDateSort,
  onClear,
}: {
  filterStatus: BoostStatus | "ALL"; setFilterStatus: (v: BoostStatus | "ALL") => void;
  createdAfter: string; setCreatedAfter: (v: string) => void;
  createdBefore: string; setCreatedBefore: (v: string) => void;
  dateSort: DateSort; setDateSort: (v: DateSort) => void;
  onClear: () => void;
}) {
  const statuses: (BoostStatus | "ALL")[] = ["ALL", "PENDING", "COMPLETED", "FAILED"];
  const dateSortOptions: { value: DateSort; label: string; icon: string }[] = [
    { value: "newest", label: "Newest first", icon: "↓" },
    { value: "oldest", label: "Oldest first", icon: "↑" },
  ];

  const activeCount = [
    filterStatus !== "ALL",
    createdAfter !== "",
    createdBefore !== "",
    dateSort !== "",
  ].filter(Boolean).length;

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
        {/* Status */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Status</label>
          <div className="flex flex-wrap gap-1.5">
            {statuses.map((s) => (
              <button
                key={s}
                onClick={() => setFilterStatus(s)}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  filterStatus === s
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {s}
              </button>
            ))}
          </div>
        </div>

        {/* Sort by Date */}
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

        {/* Date Range */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Created Between</label>
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

/* ---------------- BOOST DRAWER ---------------- */

function BoostDrawer({ boost }: { boost: Boost }) {
  return (
    <Drawer direction="right">
      <DrawerTrigger asChild>
        <Button variant="ghost" size="icon">👁</Button>
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
            <InfoRow
              label="Amount"
              value={`${boost.amount?.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 }) ?? "—"} ${boost.currency ?? ""}`}
            />
            <InfoRow label="Duration" value={boost.durationDays ? `${boost.durationDays} days` : "—"} />
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

/* ---------------- COLUMNS ---------------- */

function buildColumns(
  onUpdate: (id: string, status: BoostStatus) => Promise<void>
): ColumnDef<Boost>[] {
  return [
    {
      accessorKey: "propertyTitle",
      header: "Property",
      cell: ({ row }) => (
        <p className="text-sm font-medium">{row.original.propertyTitle}</p>
      ),
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
      accessorKey: "amount",
      header: "Amount",
      cell: ({ row }) => (
        <span className="text-sm font-medium">
          {row.original.amount != null
            ? `$${row.original.amount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
            : "—"}
          {row.original.currency ? (
            <span className="ml-1 text-xs text-muted-foreground">{row.original.currency}</span>
          ) : null}
        </span>
      ),
    },
    {
      accessorKey: "durationDays",
      header: "Duration",
      cell: ({ row }) =>
        row.original.durationDays ? (
          <span className="text-sm">{row.original.durationDays}d</span>
        ) : (
          <span className="text-muted-foreground">—</span>
        ),
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
      cell: ({ row }) => <BoostDrawer boost={row.original} />,
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
  const [dateSort, setDateSort] = useState<DateSort>("");
  const [filterOpen, setFilterOpen] = useState(false);

  useEffect(() => {
    api
      .get<Boost[]>("/admin/boosts")
      .then((res) => setBoosts(res.data ?? []))
      .catch(() => setError("Failed to load boosts"))
      .finally(() => setLoading(false));
  }, []);

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

  const handleStatusUpdate = useCallback(
    async (id: string, status: BoostStatus) => {
      await api.put(`/admin/boosts/${id}/status`, null, { params: { status } });
      setBoosts((prev) => prev.map((b) => (b.id === id ? { ...b, status } : b)));
    },
    []
  );

  const columns = useMemo(() => buildColumns(handleStatusUpdate), [handleStatusUpdate]);

  const filteredData = useMemo(() => {
    const filtered = boosts.filter((b) => {
      const textMatch = [b.propertyTitle, b.userName, b.userEmail, b.id, b.amount?.toString()]
        .filter(Boolean)
        .join(" ")
        .toLowerCase()
        .includes(search.toLowerCase());

      const statusMatch = filterStatus === "ALL" || b.status === filterStatus;

      const created = parseDate(b.createdAt)?.getTime() ?? null;
      const afterMatch =
        !createdAfter ||
        (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch =
        !createdBefore ||
        (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());

      return textMatch && statusMatch && afterMatch && beforeMatch;
    });

    if (dateSort === "newest") {
      filtered.sort((a, b) => (parseDate(b.createdAt)?.getTime() ?? 0) - (parseDate(a.createdAt)?.getTime() ?? 0));
    } else if (dateSort === "oldest") {
      filtered.sort((a, b) => (parseDate(a.createdAt)?.getTime() ?? 0) - (parseDate(b.createdAt)?.getTime() ?? 0));
    }

    return filtered;
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

  if (loading) return <div className="p-8">Loading boosts…</div>;
  if (error) return <div className="p-8 text-red-500">{error}</div>;

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">Boosts</h2>

      {/* Summary Cards */}
      <SummaryCards boosts={boosts} />

      {/* Search + Filter toggle */}
      <div className="flex gap-2">
        <Input
          placeholder="Search by property, seller, amount…"
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
          filterStatus={filterStatus} setFilterStatus={setFilterStatus}
          createdAfter={createdAfter} setCreatedAfter={setCreatedAfter}
          createdBefore={createdBefore} setCreatedBefore={setCreatedBefore}
          dateSort={dateSort} setDateSort={setDateSort}
          onClear={clearFilters}
        />
      )}

      {/* Results count */}
      <div className="flex items-center justify-between">
        <span className="text-xs text-muted-foreground">
          {filteredData.length} boost{filteredData.length !== 1 ? "s" : ""}
          {activeFilterCount > 0 && " (filtered)"}
        </span>
      </div>

      {/* Table */}
      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((hg) => (
              <TableRow key={hg.id}>
                {hg.headers.map((header) => (
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
              table.getRowModel().rows.map((row) => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      {/* Pagination */}
      <div className="flex justify-between items-center">
        <Button variant="outline" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
          Previous
        </Button>
        <span>Page {pagination.pageIndex + 1} of {Math.max(table.getPageCount(), 1)}</span>
        <Button variant="outline" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>
          Next
        </Button>
      </div>
    </div>
  );
}}