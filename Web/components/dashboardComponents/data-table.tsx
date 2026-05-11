"use client"

import * as React from "react"
import { flexRender, getCoreRowModel, getFilteredRowModel, getPaginationRowModel, getSortedRowModel, useReactTable, type ColumnDef, type ColumnFiltersState, type SortingState, type VisibilityState } from "@tanstack/react-table"
import { Badge } from "@/components/ui/badge"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Drawer, DrawerTrigger, DrawerContent, DrawerHeader, DrawerTitle, DrawerDescription, DrawerFooter, DrawerClose } from "@/components/ui/drawer"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@/components/ui/select"
import { Report, ReportStatus } from "@/types/dashboard-types"
import { Button } from "../ui/button"
import { useTranslations } from "next-intl"

function reporterDisplay(report: Report) {
  if (report.reporterName) return `${report.reporterName} (${report.reporterEmail ?? report.reporterId})`
  return report.reporterEmail ?? report.reporterId
}

function reportedUserDisplay(report: Report, fallback: string) {
  if (!report.reportedUserId) return fallback
  if (report.reportedUserName) return `${report.reportedUserName} (${report.reportedUserEmail ?? report.reportedUserId})`
  return report.reportedUserEmail ?? report.reportedUserId
}

function reportedPropertyDisplay(report: Report, fallback: string) {
  if (!report.reportedPropertyId) return fallback
  return report.reportedPropertyTitle ?? report.reportedPropertyId
}

function reviewedByDisplay(report: Report, fallback: string) {
  if (!report.reviewedByAdminId) return fallback
  if (report.reviewedByAdminName) return `${report.reviewedByAdminName} (${report.reviewedByAdminEmail ?? report.reviewedByAdminId})`
  return report.reviewedByAdminEmail ?? report.reviewedByAdminId
}

function TableCellViewer({ report, onStatusChange }: { report: Report; onStatusChange: (reportId: string, status: ReportStatus) => Promise<void> }) {
  const t = useTranslations('dashboard.table.drawer')
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
          <DrawerTitle>{t('title')}</DrawerTitle>
          <DrawerDescription>{t('description')}</DrawerDescription>
        </DrawerHeader>
        <div className="flex flex-col gap-4 p-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label>{t('reporter')}</Label>
              <Input value={reporterDisplay(report)} readOnly />
            </div>
            <div className="flex flex-col gap-2">
              <Label>{t('reportedUser')}</Label>
              <Input value={reportedUserDisplay(report, '—')} readOnly />
            </div>
          </div>
          <div className="grid grid-cols-2 gap-4">
            <div className="flex flex-col gap-2">
              <Label>{t('reportedProperty')}</Label>
              <Input value={reportedPropertyDisplay(report, '—')} readOnly />
            </div>
            <div className="flex flex-col gap-2">
              <Label>{t('reviewedBy')}</Label>
              <Input value={reviewedByDisplay(report, '—')} readOnly />
            </div>
          </div>
          <div className="flex flex-col gap-2">
            <Label>{t('reason')}</Label>
            <Input value={report.reason} readOnly className="min-h-[80px]" />
          </div>
          {report.createdAt && (
            <div className="flex flex-col gap-2">
              <Label>{t('reportedAt')}</Label>
              <Input value={new Date(report.createdAt).toLocaleString()} readOnly />
            </div>
          )}
          <div className="flex flex-col gap-2">
            <Label>{t('statusLabel')}</Label>
            <Select value={status} onValueChange={handleStatusChange} disabled={saving}>
              <SelectTrigger>
                <SelectValue placeholder={t('statusPlaceholder')} />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value={ReportStatus.OPEN}>{t('statusOpen')}</SelectItem>
                <SelectItem value={ReportStatus.REVIEWED}>{t('statusReviewed')}</SelectItem>
                <SelectItem value={ReportStatus.RESOLVED}>{t('statusResolved')}</SelectItem>
                <SelectItem value={ReportStatus.DISMISSED}>{t('statusDismissed')}</SelectItem>
              </SelectContent>
            </Select>
            {saving && <p className="text-xs text-muted-foreground">{t('saving')}</p>}
          </div>
        </div>
        <DrawerFooter>
          <DrawerClose asChild>
            <Button variant="outline" className="bg-black hover:bg-gray-900 text-white border-gray-700">{t('close')}</Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  )
}

function buildColumns(
  onStatusChange: (reportId: string, status: ReportStatus) => Promise<void>,
  t: ReturnType<typeof useTranslations>
): ColumnDef<Report>[] {
  return [
    {
      accessorKey: "reason",
      header: t('reason'),
      cell: ({ row }) => <TableCellViewer report={row.original} onStatusChange={onStatusChange} />,
    },
    {
      id: "reporter",
      header: t('reporter'),
      cell: ({ row }) => reporterDisplay(row.original),
    },
    {
      id: "reportedUser",
      header: t('reportedUser'),
      cell: ({ row }) => reportedUserDisplay(row.original, '—'),
    },
    {
      id: "reportedProperty",
      header: t('reportedProperty'),
      cell: ({ row }) => reportedPropertyDisplay(row.original, '—'),
    },
    {
      accessorKey: "status",
      header: t('status'),
      cell: ({ row }) => <Badge variant="outline">{row.original.status}</Badge>,
    },
    {
      id: "reviewedBy",
      header: t('reviewedBy'),
      cell: ({ row }) => reviewedByDisplay(row.original, '—'),
    },
  ]
}

export function DataTable({ data, onStatusChange }: { data: Report[]; onStatusChange?: (reportId: string, status: ReportStatus) => Promise<void> }) {
  const t = useTranslations('dashboard.table')
  const columns = React.useMemo(
    () => buildColumns(onStatusChange ?? (async () => {}), t),
    [onStatusChange, t]
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
    <div className="overflow-auto rounded-lg border">
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
                {t('noReports')}
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
      <div className="flex items-center justify-between px-4 py-2 border-t text-sm text-muted-foreground">
        <span>
          {t('page')} {table.getState().pagination.pageIndex + 1} {t('of')} {table.getPageCount() || 1}
        </span>
        <div className="space-x-2">
          <Button variant="outline" size="sm" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
            {t('previous')}
          </Button>
          <Button variant="outline" size="sm" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>
            {t('next')}
          </Button>
        </div>
      </div>
    </div>
  )
}