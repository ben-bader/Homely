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

type Property = {
  id: string
  title: string
  address?: string
  price?: number
  status?: string
}

export default function Properties() {
  const [properties, setProperties] = React.useState<Property[]>([])
  const [loading, setLoading] = React.useState(true)
  const [search, setSearch] = React.useState("")

  // Fetch properties from API
  const fetchProperties = async () => {
    try {
      const res = await api.get<Property[]>("/admin/properties")
      setProperties(res.data || [])
    } catch (err) {
      console.error("Failed to load properties", err)
    } finally {
      setLoading(false)
    }
  }

  React.useEffect(() => {
    fetchProperties()
  }, [])

  // --- Metrics cards ---
  const totalProperties = properties.length
  const availableProperties = properties.filter((p) => p.status?.toLowerCase() === "available").length
  const rentedOrSoldProperties = properties.filter(
    (p) => p.status?.toLowerCase() === "rented" || p.status?.toLowerCase() === "sold"
  ).length

  // Columns definition
  const columns = React.useMemo<ColumnDef<Property>[]>(
    () => [
      { accessorKey: "title", header: "Title" },
      { accessorKey: "address", header: "Address" },
      { accessorKey: "price", header: "Price", cell: ({ row }) => row.original.price ?? "-" },
      { accessorKey: "status", header: "Status", cell: ({ row }) => row.original.status ?? "-" },
      {
        id: "actions",
        header: "Actions",
        cell: ({ row }) => (
          <Button size="sm" onClick={() => alert(`Edit ${row.original.title}`)}>
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

  // React Table instance
  const table = useReactTable({
    data: properties.filter((p) =>
      [p.title, p.address, p.status, p.price?.toString()]
        .filter(Boolean)
        .join(" ")
        .toLowerCase()
        .includes(search.toLowerCase())
    ),
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

  if (loading) return <div>Loading properties…</div>

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">Properties</h2>

      {/* --- Metrics Cards --- */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4">
        <div className="p-4 bg-white rounded-xl shadow text-center">
          <p className="text-sm text-muted-foreground">Available Properties</p>
          <p className="text-2xl font-bold">{availableProperties}</p>
        </div>
        <div className="p-4 bg-white rounded-xl shadow text-center">
          <p className="text-sm text-muted-foreground">Rented/Sold Properties</p>
          <p className="text-2xl font-bold">{rentedOrSoldProperties}</p>
        </div>
        <div className="p-4 bg-white rounded-xl shadow text-center">
          <p className="text-sm text-muted-foreground">Total Properties</p>
          <p className="text-2xl font-bold">{totalProperties}</p>
        </div>
      </div>

      {/* --- Search Bar --- */}
      <h2 className="text-md pt-6 font-semibold">Search in Properties</h2>
      <Input
        placeholder="Search properties…"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="mb-4 w-full rounded-xl border border-neutral-200 bg-neutral-50 px-4 py-2 text-sm text-neutral-900 focus:border-neutral-900 focus:outline-none focus:bg-white"
      />

      {/* --- Properties Table --- */}
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
                  No properties.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
