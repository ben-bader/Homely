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
  import type { Boost, BoostStatus, BoostPackage } from "@/types/dashboard-types";
  import useBoostPackages from "@/hooks/useBoostPackages";
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
    const [activeTab, setActiveTab] = React.useState<'purchases' | 'packages'>('purchases');
    const [boosts, setBoosts] = React.useState<Boost[]>([]);
    const [loading, setLoading] = React.useState(true);
    const [search, setSearch] = React.useState("");
    
    // Boost Packages hook
    const { packages, loading: packagesLoading, addPackage, deletePackage, refetch: refetchPackages } = useBoostPackages();
    
    // Package form state
    const [showAddPackageForm, setShowAddPackageForm] = React.useState(false);
    const [newPackage, setNewPackage] = React.useState({
      name: '',
      description: '',
      durationDays: '',
      price: '',
    });
    const [savingPackage, setSavingPackage] = React.useState(false);

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

    // Handle adding new package
    const handleAddPackage = async () => {
      if (!newPackage.name || !newPackage.price || !newPackage.durationDays) {
        alert('Please fill in all fields');
        return;
      }
      
      setSavingPackage(true);
      try {
        await addPackage({
          name: newPackage.name,
          description: newPackage.description,
          durationDays: parseInt(newPackage.durationDays),
          price: parseFloat(newPackage.price),
        });
        setNewPackage({ name: '', description: '', durationDays: '', price: '' });
        setShowAddPackageForm(false);
      } catch (err) {
        console.error('Failed to add package', err);
        alert('Failed to add package');
      } finally {
        setSavingPackage(false);
      }
    };

    // Handle deleting package
    const handleDeletePackage = async (packageId: number) => {
      if (!confirm('Are you sure you want to delete this package?')) return;
      try {
        await deletePackage(packageId);
      } catch (err) {
        console.error('Failed to delete package', err);
        alert('Failed to delete package');
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

    if (loading && activeTab === 'purchases') return <div className="p-6">Loading boosts…</div>;
    if (packagesLoading && activeTab === 'packages') return <div className="p-6">Loading packages…</div>;

    return (
      <div className="px-8 space-y-4">
        <h2 className="text-xl font-semibold">Boosts Management</h2>

        {/* Tabs */}
        <div className="flex gap-2 border-b">
          <button
            onClick={() => setActiveTab('purchases')}
            className={`px-4 py-2 font-medium border-b-2 transition-colors ${
              activeTab === 'purchases'
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-600 hover:text-gray-900'
            }`}
          >
            Boost Purchases
          </button>
          <button
            onClick={() => setActiveTab('packages')}
            className={`px-4 py-2 font-medium border-b-2 transition-colors ${
              activeTab === 'packages'
                ? 'border-blue-500 text-blue-600'
                : 'border-transparent text-gray-600 hover:text-gray-900'
            }`}
          >
            Boost Packages
          </button>
        </div>

        {/* Boost Purchases Tab */}
        {activeTab === 'purchases' && (
          <div className="space-y-4">
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
        )}

        {/* Boost Packages Tab */}
        {activeTab === 'packages' && (
          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <h3 className="text-lg font-semibold">Available Boost Packages</h3>
              <Button
                onClick={() => setShowAddPackageForm(!showAddPackageForm)}
                className="bg-blue-600 hover:bg-blue-700"
              >
                {showAddPackageForm ? 'Cancel' : '+ Add Package'}
              </Button>
            </div>

            {/* Add Package Form */}
            {showAddPackageForm && (
              <div className="border rounded-lg p-4 bg-gray-50 space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-1">Package Name</label>
                    <Input
                      value={newPackage.name}
                      onChange={(e) => setNewPackage({ ...newPackage, name: e.target.value })}
                      placeholder="e.g., 7 Days Boost"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-1">Duration (Days)</label>
                    <Input
                      type="number"
                      value={newPackage.durationDays}
                      onChange={(e) => setNewPackage({ ...newPackage, durationDays: e.target.value })}
                      placeholder="7"
                    />
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-1">Price ($)</label>
                    <Input
                      type="number"
                      step="0.01"
                      value={newPackage.price}
                      onChange={(e) => setNewPackage({ ...newPackage, price: e.target.value })}
                      placeholder="9.99"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium mb-1">Description</label>
                  <Input
                    value={newPackage.description}
                    onChange={(e) => setNewPackage({ ...newPackage, description: e.target.value })}
                    placeholder="Brief description of the package"
                  />
                </div>
                <Button
                  onClick={handleAddPackage}
                  disabled={savingPackage}
                  className="w-full bg-green-600 hover:bg-green-700"
                >
                  {savingPackage ? 'Saving…' : 'Save Package'}
                </Button>
              </div>
            )}

            {/* Packages Table */}
            <div className="overflow-auto rounded-lg border">
              <Table>
                <TableHeader className="bg-muted">
                  <TableRow>
                    <TableHead>Name</TableHead>
                    <TableHead>Description</TableHead>
                    <TableHead>Duration (Days)</TableHead>
                    <TableHead>Price</TableHead>
                    <TableHead>Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {packages && packages.length > 0 ? (
                    packages.map((pkg) => (
                      <TableRow key={pkg.id}>
                        <TableCell className="font-medium">{pkg.name}</TableCell>
                        <TableCell>{pkg.description}</TableCell>
                        <TableCell>{pkg.durationDays}</TableCell>
                        <TableCell>${pkg.price.toLocaleString()}</TableCell>
                        <TableCell>
                          <Button
                            variant="destructive"
                            size="sm"
                            onClick={() => handleDeletePackage(pkg.id)}
                          >
                            Delete
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))
                  ) : (
                    <TableRow>
                      <TableCell colSpan={5} className="text-center h-24">
                        No boost packages available.
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </div>
          </div>
        )}
      </div>
    );
  }
