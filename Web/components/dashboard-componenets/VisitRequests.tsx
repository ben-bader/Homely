"use client";

import React, { useMemo, useState } from "react";
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
import { FaEye } from "react-icons/fa";

import { useVisitRequests } from "@/hooks/useVisitRequests";
import { useProperties } from "@/hooks/useProperties";
import { useUsers } from "@/hooks/useUsers";
import { VisitStatus, type VisitRequest } from "@/types/dashboard-types";

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

function statusVariant(status: VisitStatus): "default" | "secondary" | "destructive" | "outline" {
  switch (status) {
    case VisitStatus.APPROVED: return "default";
    case VisitStatus.COMPLETED: return "secondary";
    case VisitStatus.PENDING: return "outline";
    case VisitStatus.REJECTED: return "destructive";
    default: return "outline";
  }
}

/* ---------------- SUMMARY CARDS ---------------- */

function SummaryCards({ visitRequests }: { visitRequests: VisitRequest[] }) {
  const total = visitRequests.length;
  const pending = visitRequests.filter((r) => r.status === VisitStatus.PENDING).length;
  const approved = visitRequests.filter((r) => r.status === VisitStatus.APPROVED).length;
  const completed = visitRequests.filter((r) => r.status === VisitStatus.COMPLETED).length;
  const rejected = visitRequests.filter((r) => r.status === VisitStatus.REJECTED).length;

  const cards = [
    { label: "Total", value: total, colorClass: "text-foreground", bgClass: "bg-muted/50" },
    { label: "Pending", value: pending, colorClass: "text-yellow-600 dark:text-yellow-400", bgClass: "bg-yellow-50 dark:bg-yellow-950/30" },
    { label: "Approved", value: approved, colorClass: "text-green-600", bgClass: "bg-green-50 dark:bg-green-950/30" },
    { label: "Completed", value: completed, colorClass: "text-blue-600 dark:text-blue-400", bgClass: "bg-blue-50 dark:bg-blue-950/30" },
    { label: "Rejected", value: rejected, colorClass: "text-destructive", bgClass: "bg-destructive/10" },
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
      {cards.map((card) => (
        <div key={card.label} className={`rounded-lg border p-4 flex items-center gap-3 ${card.bgClass}`}>
          <div className={`shrink-0 ${card.colorClass}`}>{card.icon}</div>
          <div>
            <p className="text-[11px] uppercase tracking-widest text-muted-foreground font-semibold">{card.label}</p>
            <p className={`text-2xl font-bold ${card.colorClass}`}>{card.value}</p>
          </div>
        </div>
      ))}
    </div>
  );
}

/* ---------------- INFO ROW ---------------- */

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

/* ---------------- FILTER PANEL ---------------- */
// Keep your existing FilterPanel code here without changes

/* ---------------- VISIT REQUEST DRAWER ---------------- */

function VisitRequestDrawer({ request }: { request: VisitRequest }) {
  return (
    <Drawer direction="right">
      <DrawerTrigger asChild>
        <Button variant="ghost" size="icon"><FaEye /></Button>
      </DrawerTrigger>

      <DrawerContent className="flex flex-col max-w-md ml-auto h-full">
        <DrawerHeader className="border-b pb-4">
          <DrawerTitle className="text-base font-semibold">Visit Request</DrawerTitle>
          <DrawerDescription className="text-xs text-muted-foreground">
            Full details for this visit request
          </DrawerDescription>
        </DrawerHeader>

        <div className="flex-1 overflow-y-auto p-5 space-y-6">
          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Overview</p>
            <InfoRow label="Status" value={<Badge variant={statusVariant(request.status)}>{request.status}</Badge>} />
            <InfoRow label="Requested Date" value={fmtFull(request.requestedDate)} />
          </section>

          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Property</p>
            <InfoRow label="Title" value={request.propertyTitle} />
          </section>

          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Seller</p>
            <InfoRow label="Name" value={request.sellerName ?? "—"} />
            <InfoRow label="Email" value={request.sellerEmail ?? "—"} />
          </section>

          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Client</p>
            <InfoRow label="Name" value={request.userName} />
            <InfoRow label="Email" value={request.userEmail} />
          </section>

          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Timestamps</p>
            <div className="grid grid-cols-2 gap-3">
              <InfoRow label="Created At" value={fmtFull(request.createdAt)} />
              <InfoRow label="Updated At" value={fmtFull(request.updatedAt)} />
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

function buildColumns(): ColumnDef<VisitRequest>[] {
  return [
    { accessorKey: "propertyTitle", header: "Property", cell: ({ row }) => <p className="text-sm font-medium">{row.original.propertyTitle}</p> },
    { accessorKey: "sellerName", header: "Seller", cell: ({ row }) => (
      <div>
        <p className="text-sm font-medium">{row.original.sellerName ?? "—"}</p>
        <p className="text-xs text-muted-foreground">{row.original.sellerEmail ?? ""}</p>
      </div>
    ) },
    { accessorKey: "userName", header: "Client", cell: ({ row }) => (
      <div>
        <p className="text-sm font-medium">{row.original.userName}</p>
        <p className="text-xs text-muted-foreground">{row.original.userEmail}</p>
      </div>
    ) },
    { accessorKey: "requestedDate", header: "Requested Date", cell: ({ row }) => fmt(row.original.requestedDate) },
    { accessorKey: "status", header: "Status", cell: ({ row }) => <Badge variant={statusVariant(row.original.status)}>{row.original.status.toLowerCase()}</Badge> },
    { id: "seeMore", header: "", cell: ({ row }) => <VisitRequestDrawer request={row.original} /> },
  ];
}

/* ---------------- MAIN PAGE ---------------- */

export default function VisitRequests() {
  const { visitRequests, loading, error } = useVisitRequests();
  const { properties, loading: loadingProperties } = useProperties();
  const { users, loading: loadingUsers } = useUsers();

  const [search, setSearch] = useState("");
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
  const [filterStatus, setFilterStatus] = useState<VisitStatus | "ALL">("ALL");
  const [createdAfter, setCreatedAfter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [dateSort, setDateSort] = useState<DateSort>("");
  const [filterOpen, setFilterOpen] = useState(false);

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

  const columns = useMemo(() => buildColumns(), []);

  // Map property + seller user email
  const visitRequestsWithSeller = useMemo(() => {
    if (!properties || !users) return visitRequests;
    const propMap = Object.fromEntries(properties.map(p => [p.id, p]));
    const userMap = Object.fromEntries(users.map(u => [u.id, u]));

    return visitRequests.map(req => {
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
    const filtered = visitRequestsWithSeller.filter(r => {
      const textMatch = [r.userName, r.userEmail, r.propertyTitle, r.status, r.sellerName, r.sellerEmail]
        .filter(Boolean)
        .join(" ")
        .toLowerCase()
        .includes(search.toLowerCase());

      const statusMatch = filterStatus === "ALL" || r.status === filterStatus;

      const created = parseDate(r.requestedDate)?.getTime() ?? null;
      const afterMatch = !createdAfter || (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());

      return textMatch && statusMatch && afterMatch && beforeMatch;
    });

    if (dateSort === "newest") {
      filtered.sort((a, b) => (parseDate(b.requestedDate)?.getTime() ?? 0) - (parseDate(a.requestedDate)?.getTime() ?? 0));
    } else if (dateSort === "oldest") {
      filtered.sort((a, b) => (parseDate(a.requestedDate)?.getTime() ?? 0) - (parseDate(b.requestedDate)?.getTime() ?? 0));
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

  if (loading || loadingProperties || loadingUsers) return <div className="p-8">Loading visit requests…</div>;
  if (error) return <div className="p-8 text-red-500">{error}</div>;

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">Visit Requests</h2>

      <SummaryCards visitRequests={visitRequestsWithSeller} />

      {/* Search + Filter toggle */}
      <div className="flex gap-2">
        <Input
          placeholder="Search by client, property, status…"
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
          {filteredData.length} request{filteredData.length !== 1 ? "s" : ""}
          {activeFilterCount > 0 && " (filtered)"}
        </span>
      </div>

      {/* Table */}
      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader className="bg-primary text-white">
            {table.getHeaderGroups().map(hg => (
              <TableRow key={hg.id}>
                {hg.headers.map(header => (
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
                  No visit requests match your filters
                </TableCell>
              </TableRow>
            ) : (
              table.getRowModel().rows.map(row => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map(cell => (
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