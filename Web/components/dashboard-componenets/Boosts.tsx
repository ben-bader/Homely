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
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { api } from "@/lib/api"

type Boost = {
  id: string
  status?: string
  amount?: number
  property?: { id: string; title?: string }
}

export default function Boosts() {
  const [boosts, setBoosts] = React.useState<Boost[]>([])
  const [loading, setLoading] = React.useState(true)
  const [search, setSearch] = React.useState("")

  // Fetch boosts from API
  const fetchBoosts = async () => {
    try {
      const res = await api.get<Boost[]>("/admin/boosts")
      setBoosts(res.data || [])
    } catch (err) {
      console.error("Failed to load boosts", err)
    } finally {
      setLoading(false)
    }
  }

  React.useEffect(() => {
    fetchBoosts()
  }, [])

  // Columns definition
  const columns = React.useMemo<ColumnDef<Boost>[]>(
    () => [
      {
        accessorKey: "property",
        header: "Property / ID",
        cell: ({ row }) => row.original.property?.title ?? row.original.id,
      },
      {
        accessorKey: "status",
        header: "Status",
        cell: ({ row }) => row.original.status ?? "-",
      },
      {
        accessorKey: "amount",
        header: "Amount",
        cell: ({ row }) => row.original.amount ?? "-",
      },
      {
        id: "actions",
        header: "Actions",
        cell: ({ row }) => (
          <Button size="sm" onClick={() => alert(`Edit boost ${row.original.id}`)}>
            Edit
          </Button>
        ),
      },
    ],
    []
  )

  const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>([])
  const [sorting, setSorting] = React.useState<SortingState>([])
  const [columnVisibility, setColumnVisibility] = React.useState<VisibilityState>({})
  const [pagination, setPagination] = React.useState({ pageIndex: 0, pageSize: 10 })

  // Filter boosts by search input
  const filteredBoosts = React.useMemo(
    () =>
      boosts.filter((b) =>
        [b.property?.title, b.id, b.status, b.amount?.toString()]
          .filter(Boolean)
          .join(" ")
          .toLowerCase()
          .includes(search.toLowerCase())
      ),
    [boosts, search]
  )

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
  })

  if (loading) return <div className="p-6">Loading boosts…</div>

  return (
    <div className="px-8">
      <h2 className="text-xl font-semibold mb-4">Boosts</h2>

      <Input
        placeholder="Search boosts…"
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
                  No boosts found.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
