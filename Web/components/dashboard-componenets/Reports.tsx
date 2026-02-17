"use client"

import * as React from "react"
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  flexRender,
  type ColumnDef,
  type ColumnFiltersState,
  type SortingState,
  type VisibilityState,
} from "@tanstack/react-table"
import { useReports } from "@/hooks/useReports"
import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { ReportStatus, type Report } from "@/types/dashboard-types"

const getStatusColor = (status: ReportStatus) => {
  switch (status) {
    case ReportStatus.OPEN:
      return "bg-yellow-500/20 text-yellow-600"
    case ReportStatus.REVIEWED:
      return "bg-blue-500/20 text-blue-600"
    case ReportStatus.RESOLVED:
      return "bg-green-500/20 text-green-600"
    case ReportStatus.DISMISSED:
      return "bg-red-500/20 text-red-600"
  }
}

export default function Reports() {
  const { reports, loading, error } = useReports()
  const router = useRouter()
  const [search, setSearch] = React.useState("")

  // Stats
  const waitingReports = reports.filter(r => r.status === ReportStatus.OPEN).length
  const viewingReports = reports.filter(r => r.status === ReportStatus.REVIEWED).length
  const totalReports = reports.length

  // Columns
  const columns = React.useMemo<ColumnDef<Report>[]>(
    () => [
      { accessorKey: "reason", header: "Reason" },
      {
        id: "status",
        header: "Status",
        cell: ({ row }) => (
          <span
            className={`text-xs px-2 py-1 rounded-full ${getStatusColor(row.original.status)}`}
          >
            {row.original.status}
          </span>
        ),
      },
      {
        id: "reporter",
        header: "Reporter",
        cell: ({ row }) => row.original.reporterEmail,
      },
      {
        id: "reportedUser",
        header: "Reported User",
        cell: ({ row }) => row.original.reportedUserEmail ?? "—",
      },
      {
        id: "property",
        header: "Property",
        cell: ({ row }) => row.original.reportedPropertyTitle ?? "—",
      },
      {
        id: "actions",
        header: "Actions",
        cell: ({ row }) => (
          <Button
            size="sm"
            variant="outline"
            onClick={() => router.push(`/dashboard/reports/${row.original.id}`)}
          >
            View Details →
          </Button>
        ),
      },
    ],
    [router]
  )

  const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>([])
  const [sorting, setSorting] = React.useState<SortingState>([])
  const [columnVisibility, setColumnVisibility] = React.useState<VisibilityState>({})
  const [pagination, setPagination] = React.useState({ pageIndex: 0, pageSize: 10 })

  const filteredReports = React.useMemo(
    () =>
      reports.filter((r) =>
        [
          r.reason,
          r.status,
          r.reporterEmail,
          r.reportedUserEmail,
          r.reportedPropertyTitle,
        ]
          .filter(Boolean)
          .join(" ")
          .toLowerCase()
          .includes(search.toLowerCase())
      ),
    [reports, search]
  )

  const table = useReactTable({
    data: filteredReports,
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
  })

  if (loading) return <div className="p-6">Loading reports…</div>
  if (error) return <div className="p-6 text-destructive">{error}</div>
  if (!reports.length) return <div className="p-6">No reports found.</div>

  return (
    <div className="px-6">
      <h2 className="text-lg font-semibold mb-4">Reports</h2>

      {/* Stats Cards */}
      <div className="grid gap-4 md:grid-cols-3 mb-6">
        <div className="rounded-xl border bg-card p-4 shadow-sm">
          <p className="text-sm text-muted-foreground">Waiting Reports</p>
          <p className="text-2xl font-semibold">{waitingReports}</p>
        </div>

        <div className="rounded-xl border bg-card p-4 shadow-sm">
          <p className="text-sm text-muted-foreground">Reports in Review</p>
          <p className="text-2xl font-semibold">{viewingReports}</p>
        </div>

        <div className="rounded-xl border bg-card p-4 shadow-sm">
          <p className="text-sm text-muted-foreground">All Reports</p>
          <p className="text-2xl font-semibold">{totalReports}</p>
        </div>
      </div>

      <Input
        placeholder="Search reports…"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="mb-4 w-full rounded-xl border border-neutral-200 bg-neutral-50 px-4 py-2 text-sm text-neutral-900 focus:border-neutral-900 focus:outline-none focus:bg-white"
      />

      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader className="bg-muted sticky top-0 z-10">
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <TableHead key={header.id}>
                    {header.isPlaceholder
                      ? null
                      : flexRender(header.column.columnDef.header, header.getContext())}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length ? (
              table.getRowModel().rows.map((row) => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={columns.length} className="text-center h-24">
                  No reports.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
