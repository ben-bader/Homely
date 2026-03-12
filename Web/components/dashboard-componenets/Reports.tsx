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
import { useReports } from "@/hooks/useReports";
import { api } from "@/lib/api";
import { FaEye } from "react-icons/fa";

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

function fmt(v: string | number | null | undefined) {
  const d = parseDate(v);
  return d ? d.toLocaleDateString() : "—";
}

function fmtFull(v: string | number | null | undefined) {
  const d = parseDate(v);
  return d ? d.toLocaleString() : "—";
}

function statusVariant(status: ReportStatus): "destructive" | "default" | "secondary" {
  switch (status) {
    case "OPEN": return "destructive";
    case "RESOLVED": return "default";
    case "DISMISSED": return "secondary";
  }
}

/* ---------------- SUMMARY CARDS ---------------- */

function SummaryCards({ reports }: { reports: Report[] }) {
  const total = reports.length;
  const open = reports.filter((r) => r.status === "OPEN").length;
  const resolved = reports.filter((r) => r.status === "RESOLVED").length;
  const dismissed = reports.filter((r) => r.status === "DISMISSED").length;

  const cards = [
    {
      label: "Total Reports",
      value: total,
      icon: (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
      ),
      colorClass: "text-foreground",
      bgClass: "bg-muted/50",
    },
    {
      label: "Waiting / Open",
      value: open,
      icon: (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      colorClass: "text-destructive",
      bgClass: "bg-destructive/10",
    },
    {
      label: "Resolved",
      value: resolved,
      icon: (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      colorClass: "text-green-600",
      bgClass: "bg-green-50 dark:bg-green-950/30",
    },
    {
      label: "Dismissed",
      value: dismissed,
      icon: (
        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      colorClass: "text-muted-foreground",
      bgClass: "bg-muted/50",
    },
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
      {cards.map((card) => (
        <div
          key={card.label}
          className={`rounded-lg border p-4 flex items-center gap-3 ${card.bgClass}`}
        >
          <div className={`shrink-0 ${card.colorClass}`}>{card.icon}</div>
          <div>
            <p className="text-[11px] uppercase tracking-widest text-muted-foreground font-semibold">
              {card.label}
            </p>
            <p className={`text-2xl font-bold ${card.colorClass}`}>{card.value}</p>
          </div>
        </div>
      ))}
    </div>
  );
}

/* ---------------- STATUS SELECT ---------------- */

function StatusSelect({
  report,
  onUpdate,
}: {
  report: Report;
  onUpdate: (id: string, status: ReportStatus) => Promise<void>;
}) {
  const [loading, setLoading] = useState(false);

  const handleChange = async (value: string) => {
    setLoading(true);
    try {
      await onUpdate(report.id, value as ReportStatus);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Select value={report.status} onValueChange={handleChange} disabled={loading}>
      <SelectTrigger className="h-7 w-[130px] text-xs">
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="OPEN">
          <span className="flex items-center gap-1.5 text-xs">
            <span className="w-1.5 h-1.5 rounded-full bg-destructive inline-block" />
            OPEN
          </span>
        </SelectItem>
        <SelectItem value="RESOLVED">
          <span className="flex items-center gap-1.5 text-xs">
            <span className="w-1.5 h-1.5 rounded-full bg-green-500 inline-block" />
            RESOLVED
          </span>
        </SelectItem>
        <SelectItem value="DISMISSED">
          <span className="flex items-center gap-1.5 text-xs">
            <span className="w-1.5 h-1.5 rounded-full bg-muted-foreground inline-block" />
            DISMISSED
          </span>
        </SelectItem>
      </SelectContent>
    </Select>
  );
}

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
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">
        {label}
      </span>
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
  reportType, setReportType,
  createdAfter, setCreatedAfter,
  createdBefore, setCreatedBefore,
  dateSort, setDateSort,
  onClear,
}: {
  filterStatus: ReportStatus | "ALL"; setFilterStatus: (v: ReportStatus | "ALL") => void;
  reportType: "ALL" | "USER" | "PROPERTY"; setReportType: (v: "ALL" | "USER" | "PROPERTY") => void;
  createdAfter: string; setCreatedAfter: (v: string) => void;
  createdBefore: string; setCreatedBefore: (v: string) => void;
  dateSort: DateSort; setDateSort: (v: DateSort) => void;
  onClear: () => void;
}) {
  const statuses: (ReportStatus | "ALL")[] = ["ALL", "OPEN", "RESOLVED", "DISMISSED"];
  const reportTypes: ("ALL" | "USER" | "PROPERTY")[] = ["ALL", "USER", "PROPERTY"];
  const dateSortOptions: { value: DateSort; label: string; icon: string }[] = [
    { value: "newest", label: "Newest first", icon: "↓" },
    { value: "oldest", label: "Oldest first", icon: "↑" },
  ];

  const activeCount = [
    filterStatus !== "ALL",
    reportType !== "ALL",
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

        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Report Type</label>
          <div className="flex flex-wrap gap-1.5">
            {reportTypes.map((t) => (
              <button
                key={t}
                onClick={() => setReportType(t)}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  reportType === t
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {t}
              </button>
            ))}
          </div>
        </div>

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

/* ---------------- REPORT DRAWER ---------------- */

function ReportDrawer({ report }: { report: Report }) {
  const isPropertyReport = !!report.reportedPropertyId;
  const isUserReport = !!report.reportedUserId;

  return (
    <Drawer direction="right">
      <DrawerTrigger asChild>
        <Button variant="ghost" size="icon"><FaEye /></Button>
      </DrawerTrigger>

      <DrawerContent className="flex flex-col max-w-md ml-auto h-full">
        <DrawerHeader className="border-b pb-4">
          <DrawerTitle className="text-base font-semibold">Report Info</DrawerTitle>
          <DrawerDescription className="text-xs text-muted-foreground">
            Full details for this report
          </DrawerDescription>
        </DrawerHeader>

        <div className="flex-1 overflow-y-auto p-5 space-y-6">
          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Overview</p>
      
            <InfoRow label="Status" value={<Badge variant={statusVariant(report.status)}>{report.status}</Badge>} />
            <InfoRow label="Reason" value={report.reason} />
            <InfoRow
              label="Type"
              value={
                <Badge variant="outline">
                  {isPropertyReport ? "Property" : isUserReport ? "User" : "Unknown"}
                </Badge>
              }
            />
          </section>

          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Reporter</p>
            <InfoRow label="Name" value={report.reporterName} />
            <InfoRow label="Email" value={report.reporterEmail} />
          
          </section>

          {isPropertyReport && (
            <section className="space-y-4">
              <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Reported Property</p>
              <InfoRow label="Title" value={report.reportedPropertyTitle ?? "—"} />
              
            </section>
          )}

          {isUserReport && (
            <section className="space-y-4">
              <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Reported User</p>
              <InfoRow label="Name" value={report.reportedUserName ?? "—"} />
              <InfoRow label="Email" value={report.reportedUserEmail ?? "—"} />
        
            </section>
          )}

          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Reviewed By</p>
            {report.reviewedByAdminId ? (
              <>
                <InfoRow label="Admin Name" value={report.reviewedByAdminName ?? "—"} />
                <InfoRow label="Admin Email" value={report.reviewedByAdminEmail ?? "—"} />
              </>
            ) : (
              <p className="text-sm text-muted-foreground">Not yet reviewed</p>
            )}
          </section>

          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">Timestamps</p>
            <div className="grid grid-cols-2 gap-3">
              <InfoRow label="Created At" value={fmtFull(report.createdAt)} />
              <InfoRow label="Updated At" value={fmtFull(report.updatedAt)} />
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
  onUpdate: (id: string, status: ReportStatus) => Promise<void>
): ColumnDef<Report>[] {
  return [
    {
      accessorKey: "reporterName",
      header: "Reporter",
      cell: ({ row }) => (
        <div>
          <p className="text-sm font-medium">{row.original.reporterName}</p>
          <p className="text-xs text-muted-foreground">{row.original.reporterEmail}</p>
        </div>
      ),
    },
    {
      id: "target",
      header: "Target",
      cell: ({ row }) => {
        const r = row.original;
        if (r.reportedPropertyTitle) {
          return (
            <div>
              <p className="text-xs text-muted-foreground uppercase tracking-wide">Property</p>
              <p className="text-sm font-medium">{r.reportedPropertyTitle}</p>
            </div>
          );
        }
        if (r.reportedUserName) {
          return (
            <div>
              <p className="text-xs text-muted-foreground uppercase tracking-wide">User</p>
              <p className="text-sm font-medium">{r.reportedUserName}</p>
            </div>
          );
        }
        return <span className="text-muted-foreground text-sm">—</span>;
      },
    },
    {
      accessorKey: "reason",
      header: "Reason",
      cell: ({ row }) => <span className="text-sm">{row.original.reason}</span>,
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }) => (
        <StatusSelect report={row.original} onUpdate={onUpdate} />
      ),
    },
    {
      accessorKey: "createdAt",
      header: "Created At",
      cell: ({ row }) => fmt(row.original.createdAt),
    },
    {
      id: "seeMore",
      header: "",
      cell: ({ row }) => <ReportDrawer report={row.original} />,
    },
  ];
}

/* ---------------- MAIN PAGE ---------------- */

export default function Reports() {
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
    setCreatedAfter("");
    setCreatedBefore("");
    setDateSort("");
  };

  const activeFilterCount = [
    filterStatus !== "ALL",
    reportType !== "ALL",
    createdAfter !== "",
    createdBefore !== "",
    dateSort !== "",
  ].filter(Boolean).length;

  // Calls PUT /api/admin/reports/{id}/status?status=RESOLVED
  const handleStatusUpdate = useCallback(
    async (id: string, status: ReportStatus) => {
      await api.put(`/admin/reports/${id}/status`, null, { params: { status } });
      setReports((prev) =>
        prev.map((r) => (r.id === id ? { ...r, status } : r))
      );
    },
    [setReports]
  );

  const columns = useMemo(() => buildColumns(handleStatusUpdate), [handleStatusUpdate]);

  const filteredData = useMemo(() => {
    const filtered = reports.filter((r) => {
      const textMatch = [
        r.reporterName,
        r.reporterEmail,
        r.reportedPropertyTitle,
        r.reportedUserName,
        r.reportedUserEmail,
        r.reason,
      ]
        .join(" ")
        .toLowerCase()
        .includes(search.toLowerCase());

      const statusMatch = filterStatus === "ALL" || r.status === filterStatus;

      const typeMatch =
        reportType === "ALL" ||
        (reportType === "PROPERTY" && !!r.reportedPropertyId) ||
        (reportType === "USER" && !!r.reportedUserId);

      const created = parseDate(r.createdAt)?.getTime() ?? null;
      const afterMatch =
        !createdAfter ||
        (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch =
        !createdBefore ||
        (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());

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

  if (loading) return <div className="p-8">Loading reports…</div>;
  if (error) return <div className="p-8 text-red-500">{error}</div>;

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">Reports</h2>

      {/* Summary Cards — computed from full unfiltered list */}
      <SummaryCards reports={reports} />

      {/* Search + Filter toggle */}
      <div className="flex gap-2">
        <Input
          placeholder="Search by reporter, target, reason…"
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
          reportType={reportType} setReportType={setReportType}
          createdAfter={createdAfter} setCreatedAfter={setCreatedAfter}
          createdBefore={createdBefore} setCreatedBefore={setCreatedBefore}
          dateSort={dateSort} setDateSort={setDateSort}
          onClear={clearFilters}
        />
      )}

      <div className="flex items-center justify-between">
        <span className="text-xs text-muted-foreground">
          {filteredData.length} report{filteredData.length !== 1 ? "s" : ""}
          {activeFilterCount > 0 && " (filtered)"}
        </span>
      </div>

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
                  No reports match your filters
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