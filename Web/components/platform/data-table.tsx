"use client"

import * as React from "react"
import { flexRender, type Table as TanstackTable } from "@tanstack/react-table"
import { ChevronLeft, ChevronRight } from "lucide-react"

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

/* -------------------------------------------------------------------------- */
/*  Pagination                                                                */
/* -------------------------------------------------------------------------- */

interface DataTablePaginationProps<T> {
  table: TanstackTable<T>
  className?: string
}

export function DataTablePagination<T>({
  table,
  className,
}: DataTablePaginationProps<T>) {
  const pageIndex = table.getState().pagination.pageIndex
  const pageCount = table.getPageCount()

  return (
    <div
      className={cn(
        "flex items-center justify-between border-t border-border/50 px-4 py-3",
        className
      )}
    >
      <p className="text-xs text-muted-foreground">
        Page{" "}
        <span className="font-medium text-foreground">
          {pageIndex + 1}
        </span>{" "}
        of{" "}
        <span className="font-medium text-foreground">
          {pageCount || 1}
        </span>
      </p>

      <div className="flex items-center gap-1.5">
        <Button
          variant="outline"
          size="icon-sm"
          onClick={() => table.previousPage()}
          disabled={!table.getCanPreviousPage()}
          className="h-8 w-8 rounded-lg"
        >
          <ChevronLeft className="size-4" />
          <span className="sr-only">Previous page</span>
        </Button>
        <Button
          variant="outline"
          size="icon-sm"
          onClick={() => table.nextPage()}
          disabled={!table.getCanNextPage()}
          className="h-8 w-8 rounded-lg"
        >
          <ChevronRight className="size-4" />
          <span className="sr-only">Next page</span>
        </Button>
      </div>
    </div>
  )
}

/* -------------------------------------------------------------------------- */
/*  DataTable                                                                 */
/* -------------------------------------------------------------------------- */

interface DataTableProps<T> {
  table: TanstackTable<T>
  columns: any[]
  emptyMessage?: string
  onRowClick?: (row: T) => void
  className?: string
}

export function DataTable<T>({
  table,
  columns,
  emptyMessage = "No results found.",
  onRowClick,
  className,
}: DataTableProps<T>) {
  return (
    <div
      className={cn(
        "overflow-hidden rounded-xl border border-border bg-card",
        className
      )}
    >
      <Table>
        <TableHeader>
          {table.getHeaderGroups().map((headerGroup) => (
            <TableRow
              key={headerGroup.id}
              className="border-b border-border/50 bg-muted/40 hover:bg-muted/40"
            >
              {headerGroup.headers.map((header) => (
                <TableHead
                  key={header.id}
                  className="h-10 px-4 text-xs font-medium uppercase tracking-wider text-muted-foreground"
                >
                  {header.isPlaceholder
                    ? null
                    : flexRender(
                        header.column.columnDef.header,
                        header.getContext()
                      )}
                </TableHead>
              ))}
            </TableRow>
          ))}
        </TableHeader>

        <TableBody>
          {table.getRowModel().rows?.length ? (
            table.getRowModel().rows.map((row) => (
              <TableRow
                key={row.id}
                data-state={row.getIsSelected() && "selected"}
                onClick={() => onRowClick?.(row.original)}
                className={cn(
                  "border-b border-border/50 transition-colors hover:bg-muted/30",
                  onRowClick && "cursor-pointer"
                )}
              >
                {row.getVisibleCells().map((cell) => (
                  <TableCell key={cell.id} className="px-4 py-3">
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </TableCell>
                ))}
              </TableRow>
            ))
          ) : (
            <TableRow className="hover:bg-transparent">
              <TableCell
                colSpan={columns.length}
                className="h-32 text-center"
              >
                <p className="text-sm text-muted-foreground">
                  {emptyMessage}
                </p>
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>

      {/* Pagination */}
      {table.getPageCount() > 1 && (
        <DataTablePagination table={table} />
      )}
    </div>
  )
}
