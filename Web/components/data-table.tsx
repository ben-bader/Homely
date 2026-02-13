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
  type Row,
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

function TableCellViewer({ report }: { report: Report }) {
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
          <DrawerDescription>Detailed report information</DrawerDescription>
        </DrawerHeader>
        <div className="flex flex-col gap-4 p-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label>Reporter</Label>
              <Input value={report.reporter?.email || report.reporterId} readOnly />
            </div>
            <div className="flex flex-col gap-2">
              <Label>Reported User</Label>
              <Input value={report.reportedUser?.email || report.reportedUserId || "-"} readOnly />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label>Reported Property</Label>
              <Input value={report.reportedProperty?.title || report.reportedPropertyId || "-"} readOnly />
            </div>
            <div className="flex flex-col gap-2">
              <Label>Reviewed By</Label>
              <Input value={report.reviewedByAdmin?.email || report.reviewedByAdminId || "-"} readOnly />
            </div>
          </div>
          <div className="flex flex-col gap-2">
            <Label>Reason</Label>
            <Input value={report.reason} readOnly />
          </div>
          <div className="flex flex-col gap-2">
            <Label>Status</Label>
            <Select defaultValue={report.status}>
              <SelectTrigger>
                <SelectValue placeholder="Select status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value={ReportStatus.PENDING}>Pending</SelectItem>
                <SelectItem value={ReportStatus.IN_PROGRESS}>In Progress</SelectItem>
                <SelectItem value={ReportStatus.RESOLVED}>Resolved</SelectItem>
              </SelectContent>
            </Select>
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

const columns: ColumnDef<Report>[] = [
  {
    accessorKey: "reason",
    header: "Reason",
    cell: ({ row }) => <TableCellViewer report={row.original} />,
  },
  {
    id: "reporter",
    header: "Reporter",
    cell: ({ row }) => row.original.reporter?.email || row.original.reporterId,
  },
  {
    id: "reportedUser",
    header: "Reported User",
    cell: ({ row }) => row.original.reportedUser?.email || row.original.reportedUserId || "-",
  },
  {
    id: "reportedProperty",
    header: "Reported Property",
    cell: ({ row }) => row.original.reportedProperty?.title || row.original.reportedPropertyId || "-",
  },
  {
    accessorKey: "status",
    header: "Status",
    cell: ({ row }) => <Badge variant="outline">{row.original.status}</Badge>,
  },
  {
    id: "reviewedBy",
    header: "Reviewed By",
    cell: ({ row }) => row.original.reviewedByAdmin?.email || row.original.reviewedByAdminId || "-",
  },
]

export function DataTable({ data }: { data: Report[] }) {
  const [rowSelection, setRowSelection] = React.useState({})
  const [columnVisibility, setColumnVisibility] = React.useState<VisibilityState>({})
  const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>([])
  const [sorting, setSorting] = React.useState<SortingState>([])
  const [pagination, setPagination] = React.useState({ pageIndex: 0, pageSize: 10 })

  const table = useReactTable({
    data,
    columns,
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
    </div>
  )
}