"use client";

import React, { useMemo, useState } from "react";

import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  getSortedRowModel,
  getPaginationRowModel,
  flexRender,
  type ColumnDef,
  type SortingState,
} from "@tanstack/react-table";

import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

import {
  Drawer,
  DrawerTrigger,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerDescription,
  DrawerFooter,
  DrawerClose,
} from "@/components/ui/drawer";

import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";

import { useProperties } from "@/hooks/useProperties";
import { Property, PropertyStatus } from "@/types/dashboard-types";

/* ------------------------------------------------ */
/* Property Drawer */
/* ------------------------------------------------ */

function PropertyDrawer({
  property,
  onStatusChange,
  fetchDetail,
  selectedProperty,
  loadingDetail,
}: {
  property: Property;
  onStatusChange: (propertyId: string, status: PropertyStatus) => Promise<void>;
  fetchDetail: (id: string) => void;
  selectedProperty: Property | null;
  loadingDetail: boolean;
}) {
  const [status, setStatus] = useState(property.status);
  const [saving, setSaving] = useState(false);

  const handleStatusChange = async (value: string) => {
    const newStatus = value as PropertyStatus;
    setSaving(true);
    try {
      await onStatusChange(property.id, newStatus);
      setStatus(newStatus);
    } finally {
      setSaving(false);
    }
  };

  return (
    <Drawer
      direction="right"
      onOpenChange={(open) => {
        if (open) fetchDetail(property.id);
      }}
    >
      <DrawerTrigger asChild>
        <Button
          variant="link"
          className="text-foreground w-fit px-0 text-left truncate"
        >
          {property.title}
        </Button>
      </DrawerTrigger>

      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>Property Details</DrawerTitle>
          <DrawerDescription>
            View full property info and update status.
          </DrawerDescription>
        </DrawerHeader>

        <div className="flex flex-col gap-4 p-4">
          {loadingDetail ? (
            <p>Loading property details…</p>
          ) : selectedProperty ? (
            <>
              <div className="grid grid-cols-1 gap-4">
                <div className="flex flex-col gap-2">
                  <Label>Title</Label>
                  <Input value={selectedProperty.title} readOnly />
                </div>

                <div className="flex flex-col gap-2">
                  <Label>Address</Label>
                  <Input value={selectedProperty.address ?? "—"} readOnly />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="flex flex-col gap-2">
                  <Label>Price</Label>
                  <Input
                    value={
                      selectedProperty.price
                        ? `$${selectedProperty.price.toLocaleString()}`
                        : "—"
                    }
                    readOnly
                  />
                </div>

                <div className="flex flex-col gap-2">
                  <Label>Status</Label>
                  <Select
                    value={status}
                    onValueChange={handleStatusChange}
                    disabled={saving}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="AVAILABLE">
                        Available
                      </SelectItem>
                      <SelectItem value="SUSPENDED">
                        Suspended
                      </SelectItem>
                      <SelectItem value="DRAFT">Draft</SelectItem>
                    </SelectContent>
                  </Select>
                  {saving && (
                    <p className="text-xs text-muted-foreground">
                      Saving…
                    </p>
                  )}
                </div>
              </div>
            </>
          ) : (
            <p>No details available</p>
          )}
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
/* Columns */
/* ------------------------------------------------ */

function buildColumns(
  fetchDetail: (id: string) => void,
  selectedProperty: Property | null,
  loadingDetail: boolean,
  onStatusChange: (id: string, status: PropertyStatus) => Promise<void>
): ColumnDef<Property>[] {
  return [
    {
      accessorKey: "title",
      header: "Title",
      cell: ({ row }) => (
        <PropertyDrawer
          property={row.original}
          onStatusChange={onStatusChange}
          fetchDetail={fetchDetail}
          selectedProperty={selectedProperty}
          loadingDetail={loadingDetail}
        />
      ),
    },
    {
      accessorKey: "address",
      header: "Address",
    },
    {
      accessorKey: "price",
      header: "Price",
      cell: ({ row }) =>
        row.original.price
          ? `$${row.original.price.toLocaleString()}`
          : "—",
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }) => (
        <Badge variant="outline">{row.original.status}</Badge>
      ),
    },
  ];
}

/* ------------------------------------------------ */
/* Main Page */
/* ------------------------------------------------ */

export default function Properties() {
  const {
    properties,
    loading,
    error,
    updatePropertyStatus,
    fetchPropertyDetail,
    selectedProperty,
    loadingDetail,
  } = useProperties();

  const [search, setSearch] = useState("");
  const [sorting, setSorting] = useState<SortingState>([]);
  const [pagination, setPagination] = useState({
    pageIndex: 0,
    pageSize: 10,
  });

  const columns = useMemo(
    () =>
      buildColumns(
        fetchPropertyDetail,
        selectedProperty,
        loadingDetail,
        updatePropertyStatus
      ),
    [fetchPropertyDetail, selectedProperty, loadingDetail, updatePropertyStatus]
  );

  const filteredData = useMemo(() => {
    return properties.filter((p) =>
      [p.title, p.address, p.status, p.price?.toString()]
        .filter(Boolean)
        .join(" ")
        .toLowerCase()
        .includes(search.toLowerCase())
    );
  }, [properties, search]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: {
      sorting,
      pagination,
    },
    onSortingChange: setSorting,
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  if (loading) return <div>Loading properties…</div>;
  if (error) return <div className="text-red-500">{error}</div>;

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">Properties</h2>

      {/* Search */}
      <Input
        placeholder="Search properties…"
        value={search}
        onChange={(e) => setSearch(e.target.value)}
      />

      {/* Table */}
      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <TableHead
                    key={header.id}
                    onClick={header.column.getToggleSortingHandler()}
                    className="cursor-pointer select-none"
                  >
                    {flexRender(
                      header.column.columnDef.header,
                      header.getContext()
                    )}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>

          <TableBody>
            {table.getRowModel().rows.map((row) => (
              <TableRow key={row.id}>
                {row.getVisibleCells().map((cell) => (
                  <TableCell key={cell.id}>
                    {flexRender(
                      cell.column.columnDef.cell,
                      cell.getContext()
                    )}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      {/* Pagination */}
      <div className="flex justify-between items-center">
        <Button
          variant="outline"
          onClick={() => table.previousPage()}
          disabled={!table.getCanPreviousPage()}
        >
          Previous
        </Button>

        <span>
          Page {pagination.pageIndex + 1} of{" "}
          {table.getPageCount()}
        </span>

        <Button
          variant="outline"
          onClick={() => table.nextPage()}
          disabled={!table.getCanNextPage()}
        >
          Next
        </Button>
      </div>
    </div>
  );
}
