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

type User = {
  id: string
  name: string
  email: string
  role: string
  active: boolean
}

export default function Users() {
  const [users, setUsers] = React.useState<User[]>([])
  const [loading, setLoading] = React.useState(true)
  const [search, setSearch] = React.useState("")

  // Fetch users from API
  const fetchUsers = async () => {
    try {
      const res = await api.get<User[]>("/admin/users")
      setUsers(res.data || [])
    } catch (err) {
      console.error("Failed to load users", err)
    } finally {
      setLoading(false)
    }
  }

  React.useEffect(() => {
    fetchUsers()
  }, [])

  const toggleActive = async (user: User) => {
    try {
      if (user.active) {
        await api.put(`/admin/users/${user.id}/deactivate`)
      } else {
        await api.put(`/admin/users/${user.id}/activate`)
      }
      fetchUsers()
    } catch (err) {
      console.error("Failed to update user status", err)
    }
  }

  // --- Metrics cards ---
  const totalUsers = users.length
  const totalActive = users.filter((u) => u.active).length
  const totalDeactivated = users.filter((u) => !u.active).length

  // Columns definition
  const columns = React.useMemo<ColumnDef<User>[]>(
    () => [
      { accessorKey: "name", header: "Name" },
      { accessorKey: "email", header: "Email" },
      { accessorKey: "role", header: "Role" },
      {
        accessorKey: "active",
        header: "Status",
        cell: ({ row }) => (row.original.active ? "ACTIVE" : "DEACTIVATED"),
      },
      {
        id: "actions",
        header: "Actions",
        cell: ({ row }) => (
          <Button size="sm" onClick={() => toggleActive(row.original)}>
            {row.original.active ? "Deactivate" : "Activate"}
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
    data: users.filter((u) =>
      [u.name, u.email, u.role].join(" ").toLowerCase().includes(search.toLowerCase())
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

  if (loading) return <div>Loading users…</div>

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">Users</h2>

      {/* --- Metrics Cards --- */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4">
        <div className="p-4 bg-white rounded-xl shadow text-center">
          <p className="text-sm text-muted-foreground">Total Users</p>
          <p className="text-2xl font-bold">{totalUsers}</p>
        </div>
        <div className="p-4 bg-white rounded-xl shadow text-center">
          <p className="text-sm text-muted-foreground">Active Users</p>
          <p className="text-2xl font-bold">{totalActive}</p>
        </div>
        <div className="p-4 bg-white rounded-xl shadow text-center">
          <p className="text-sm text-muted-foreground">Deactivated Users</p>
          <p className="text-2xl font-bold">{totalDeactivated}</p>
        </div>
      </div>

      {/* --- Search Bar --- */}
      <h2 className="text-md pt-6 font-semibold">Search in users</h2>
      <Input
        placeholder="Search users…"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="mb-4 w-full rounded-xl border border-neutral-200 bg-neutral-50 px-4 py-2 text-sm text-neutral-900 focus:border-neutral-900 focus:outline-none focus:bg-white"
      />

      {/* --- Users Table --- */}
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
                  No users.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}
