  "use client";

  import * as React from "react";
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
  } from "@tanstack/react-table";

  import { Input } from "@/components/ui/input";
  import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
  import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
  import { Button } from "@/components/ui/button";
  import { Drawer, DrawerTrigger, DrawerContent, DrawerHeader, DrawerTitle, DrawerDescription, DrawerFooter, DrawerClose } from "@/components/ui/drawer";

  import { api } from "@/lib/api";
  import type { Boost, BoostStatus } from "@/types/dashboard-types";
import Link from "next/link";

  /* ------------------------------------------------ */
  /* Boost Drawer Component */
  /* ------------------------------------------------ */

  function BoostDrawer({
    boost,
    onStatusChange,
  }: {
    boost: Boost;
    onStatusChange: (id: string, status: BoostStatus) => Promise<void>;
  }) {
    const [status, setStatus] = React.useState(boost.status);
    const [saving, setSaving] = React.useState(false);

    const handleStatusChange = async (value: string) => {
      const newStatus = value as BoostStatus;
      setSaving(true);
      try {
        await onStatusChange(boost.id, newStatus);
        setStatus(newStatus);
      } finally {
        setSaving(false);
      }
    };

    return (
      <Drawer direction="right">
        <DrawerTrigger asChild>
          <DrawerTitle className="text-left px-0 truncate w-full hover:underline">
            {boost.propertyTitle}
          </DrawerTitle>
        </DrawerTrigger>

        <DrawerContent>
          <DrawerHeader>
            <DrawerTitle>Boost Details</DrawerTitle>
            <DrawerDescription>View boost info and update status</DrawerDescription>
          </DrawerHeader>

          <div className="p-4 flex flex-col gap-4">
            <p><strong>Property:</strong> {boost.propertyTitle}</p>
            <p><strong>Seller Name:</strong> {boost.userName}</p>
            <p><strong>Seller Email:</strong> {boost.userEmail}</p>
            <p><strong>Amount:</strong> ${boost.amount?.toLocaleString() ?? "—"}</p>

            <div className="flex flex-col gap-2">
              <label>Status</label>
              <Select value={status} onValueChange={handleStatusChange} disabled={saving}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="PENDING">PENDING</SelectItem>
                  <SelectItem value="COMPLETED">COMPLETED</SelectItem>
                  <SelectItem value="FAILED">FAILED</SelectItem>
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
    );
  }

  /* ------------------------------------------------ */
  /* Boosts Page */
  /* ------------------------------------------------ */

  export default function Boosts() {
    const [boosts, setBoosts] = React.useState<Boost[]>([]);
    const [loading, setLoading] = React.useState(true);
    const [search, setSearch] = React.useState("");

    // Fetch boosts 
    const fetchBoosts = async () => {
      try {
        const res = await api.get<Boost[]>("/admin/boosts");
        console.log(res.data);
        setBoosts(res.data || []);
      } catch (err) {
        console.error("Failed to load boosts", err);
      } finally {
        setLoading(false);
      }
    };

    React.useEffect(() => {
      fetchBoosts();
    }, []);

    // Update boost status
    const updateStatus = async (id: string, newStatus: BoostStatus) => {
      try {
        await api.put(`/admin/boosts/${id}/status`, null, { params: { status: newStatus } });
        setBoosts((prev) => prev.map((b) => (b.id === id ? { ...b, status: newStatus } : b)));
      } catch (err) {
        console.error("Failed to update boost status", err);
      }
    };

    // Columns
    const columns = React.useMemo<ColumnDef<Boost>[]>(
      () => [
        {
          accessorKey: "propertyTitle",
          header: "Property Title",
          cell: ({ row }) => <BoostDrawer boost={row.original} onStatusChange={updateStatus} />,
        },
        { accessorKey: "userName", header: "Seller Name" },
        { accessorKey: "userEmail", header: "Seller Email" },
        { accessorKey: "amount", header: "Amount" },
        {
          id: "status",
          header: "Status",
          cell: ({ row }) => {
            const currentStatus = row.original.status;
            return (
              <Select
                value={currentStatus}
                onValueChange={(value: string) => updateStatus(row.original.id, value as BoostStatus)}
              >
                <SelectTrigger className="w-32">
                  <SelectValue placeholder="Select status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="PENDING">PENDING</SelectItem>
                  <SelectItem value="COMPLETED">COMPLETED</SelectItem>
                  <SelectItem value="FAILED">FAILED</SelectItem>
                </SelectContent>
              </Select>
            );
          },
        },
      ],
      [updateStatus]
    );

    const [columnFilters, setColumnFilters] = React.useState<ColumnFiltersState>([]);
    const [sorting, setSorting] = React.useState<SortingState>([]);
    const [columnVisibility, setColumnVisibility] = React.useState<VisibilityState>({});
    const [pagination, setPagination] = React.useState({ pageIndex: 0, pageSize: 10 });

    // Filter boosts by search input
    const filteredBoosts = React.useMemo(
      () =>
        boosts.filter((b) =>
          [b.propertyTitle, b.userName, b.userEmail, b.id, b.amount?.toString()]
            .filter(Boolean)
            .join(" ")
            .toLowerCase()
            .includes(search.toLowerCase())
        ),
      [boosts, search]
    );

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
    });

    if (loading) return <div className="p-6">Loading boosts…</div>;

    return (
      <div className="px-8 space-y-4">
        <h2 className="text-xl font-semibold">Boosts</h2>

        <Input
          placeholder="Search boosts…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="mb-4 w-full"
        />

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
                    No boosts found.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>

          {/* Pagination controls */}
          <div className="flex items-center justify-between px-4 py-2 border-t text-sm text-muted-foreground">
            <span>
              Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount() || 1}
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
      </div>
    );
  }
