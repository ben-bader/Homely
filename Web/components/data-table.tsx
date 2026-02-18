"use client"

import * as React from "react"
import {
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  useReactTable,
  type ColumnDef,
  type ColumnFiltersState,
  type SortingState,
  type VisibilityState,
} from "@tanstack/react-table"
import { Badge } from "@/components/ui/badge"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Drawer, DrawerTrigger, DrawerContent, DrawerHeader, DrawerTitle, DrawerDescription, DrawerFooter, DrawerClose } from "@/components/ui/drawer"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select"
import { Report, ReportStatus } from "@/types/dashboard-types"
import { Button } from "./ui/button"

function reporterDisplay(report: Report) {
  if (report.reporterName) return `${report.reporterName} (${report.reporterEmail ?? report.reporterId})`
  return report.reporterEmail ?? report.reporterId
}

function reportedUserDisplay(report: Report) {
  if (!report.reportedUserId) return "—"
  if (report.reportedUserName) return `${report.reportedUserName} (${report.reportedUserEmail ?? report.reportedUserId})`
  return report.reportedUserEmail ?? report.reportedUserId
}

function reportedPropertyDisplay(report: Report) {
  if (!report.reportedPropertyId) return "—"
  return report.reportedPropertyTitle ?? report.reportedPropertyId
}

function reviewedByDisplay(report: Report) {
  if (!report.reviewedByAdminId) return "—"
  if (report.reviewedByAdminName) return `${report.reviewedByAdminName} (${report.reviewedByAdminEmail ?? report.reviewedByAdminId})`
  return report.reviewedByAdminEmail ?? report.reviewedByAdminId
}

function TableCellViewer({
  report,
  onStatusChange,
}: {
  report: Report
  onStatusChange: (reportId: string, status: ReportStatus) => Promise<void>
}) {
  const [status, setStatus] = React.useState(report.status)
  const [saving, setSaving] = React.useState(false)

  const handleStatusChange = async (value: string) => {
    const newStatus = value as ReportStatus
    setSaving(true)
    try {
      await onStatusChange(report.id, newStatus)
      setStatus(newStatus)
    } finally {
      setSaving(false)
    }
  }

  return (
    <Drawer direction="right">
      <DrawerTrigger asChild>
        <Button variant="link" className="text-foreground w-fit px-0 text-left truncate">
          {report.reason}
        </Button>
      </DrawerTrigger>
      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>Report Details</DrawerTitle>
          <DrawerDescription>View full report and update status. Changes are logged in Audit Log.</DrawerDescription>
        </DrawerHeader>
        <div className="flex flex-col gap-4 p-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label>Reporter</Label>
              <Input value={reporterDisplay(report)} readOnly />
            </div>
            <div className="flex flex-col gap-2">
              <Label>Reported User</Label>
              <Input value={reportedUserDisplay(report)} readOnly />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label>Reported Property</Label>
              <Input value={reportedPropertyDisplay(report)} readOnly />
            </div>
            <div className="flex flex-col gap-2">
              <Label>Reviewed By</Label>
              <Input value={reviewedByDisplay(report)} readOnly />
            </div>
          </div>
          <div className="flex flex-col gap-2">
            <Label>Reason</Label>
            <Input value={report.reason} readOnly className="min-h-[80px]" />
          </div>
          {report.createdAt && (
            <div className="flex flex-col gap-2">
              <Label>Reported at</Label>
              <Input value={new Date(report.createdAt).toLocaleString()} readOnly />
            </div>
          )}
          <div className="flex flex-col gap-2">
            <Label>Status</Label>
            <Select value={status} onValueChange={handleStatusChange} disabled={saving}>
              <SelectTrigger>
                <SelectValue placeholder="Select status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value={ReportStatus.OPEN}>Open</SelectItem>
                <SelectItem value={ReportStatus.REVIEWED}>Reviewed</SelectItem>
                <SelectItem value={ReportStatus.RESOLVED}>Resolved</SelectItem>
                <SelectItem value={ReportStatus.DISMISSED}>Dismissed</SelectItem>
              </SelectContent>
            </Select>
            {saving && <p className="text-xs text-muted-foreground">Saving…</p>}
          </div>
        </div>
        <DrawerFooter>
          <DrawerClose asChild>
            <Button variant="outline">Close</Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  )
}

function buildColumns(onStatusChange: (reportId: string, status: ReportStatus) => Promise<void>): ColumnDef<Report>[] {
  return [
    {
      accessorKey: "reason",
      header: "Reason",
      cell: ({ row }) => <TableCellViewer report={row.original} onStatusChange={onStatusChange} />,
    },
    {
      id: "reporter",
      header: "Reporter",
      cell: ({ row }) => reporterDisplay(row.original),
    },
    {
      id: "reportedUser",
      header: "Reported User",
      cell: ({ row }) => reportedUserDisplay(row.original),
    },
    {
      id: "reportedProperty",
      header: "Reported Property",
      cell: ({ row }) => reportedPropertyDisplay(row.original),
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }) => <Badge variant="outline">{row.original.status}</Badge>,
    },
    {
      id: "reviewedBy",
      header: "Reviewed By",
      cell: ({ row }) => reviewedByDisplay(row.original),
    },
  ]
}

export function DataTable({
  data,
  onStatusChange,
}: {
  data: Report[]
  onStatusChange?: (reportId: string, status: ReportStatus) => Promise<void>
}) {
  const columns = React.useMemo(
    () => buildColumns(onStatusChange ?? (async () => {})),
    [onStatusChange]
  )
  const [rowSelection, setRowSelection] = React.useState({})
  const [columnVisibility, setColumnVisibility] = React.useState<VisibilityState>({})
  const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>([])
  const [sorting, setSorting] = React.useState<SortingState>([])
  const [pagination, setPagination] = React.useState({ pageIndex: 0, pageSize: 10 })

  const table = useReactTable({
    data,
    columns: columns as ColumnDef<Report>[],
    state: { rowSelection, columnVisibility, columnFilters, sorting, pagination },
    getRowId: (row) => row.id,
    enableRowSelection: true,
    onRowSelectionChange: setRowSelection,
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    onColumnVisibilityChange: setColumnVisibility,
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    getSortedRowModel: getSortedRowModel(),
  })

  return (
    <div className="overflow-auto rounded-lg border ">
      <Table>
        <TableHeader className="bg-muted sticky top-0 z-10">
          {table.getHeaderGroups().map((headerGroup) => (
            <TableRow key={headerGroup.id}>
              {headerGroup.headers.map((header) => (
                <TableHead key={header.id}>
                  {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
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
      {/* Pagination controls */}
      <div className="flex items-center justify-between px-4 py-2 border-t text-sm text-muted-foreground">
        <span>
          Page {table.getState().pagination.pageIndex + 1} of{" "}
          {table.getPageCount() || 1}
        </span>
        <div className="space-x-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => table.previousPage()}
            disabled={!table.getCanPreviousPage()}
          >
            Previous
          </Button>
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
    </div>
  )
}