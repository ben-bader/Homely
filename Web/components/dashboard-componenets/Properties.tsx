"use client";

import React, { useMemo, useState, useEffect } from "react";
import { useFeaturedCount } from "../../hooks/useFeaturedCount";

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
/* Status Change Drawer (on title click)            */
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
                      <SelectItem value="AVAILABLE">Available</SelectItem>
                      <SelectItem value="SUSPENDED">Suspended</SelectItem>
                      <SelectItem value="DRAFT">Draft</SelectItem>
                    </SelectContent>
                  </Select>
                  {saving && (
                    <p className="text-xs text-muted-foreground">Saving…</p>
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
/* Info Row helper                                  */
/* ------------------------------------------------ */

function InfoRow({
  label,
  value,
  mono = false,
}: {
  label: string;
  value: React.ReactNode;
  mono?: boolean;
}) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">
        {label}
      </span>
      {typeof value === "string" || typeof value === "number" ? (
        <span
          className={
            mono
              ? "font-mono text-xs break-all text-foreground"
              : "text-sm font-medium text-foreground"
          }
        >
          {value}
        </span>
      ) : (
        <div className="mt-0.5">{value}</div>
      )}
    </div>
  );
}

/* ------------------------------------------------ */
/* Copy Field helper                                */
/* ------------------------------------------------ */

function CopyField({ value }: { value: string }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(value).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    });
  };

  return (
    <div className="flex items-center gap-2 mt-0.5">
      <span className="font-mono text-xs break-all text-foreground flex-1">
        {value}
      </span>
      <Button
        variant="outline"
        size="sm"
        className="h-6 px-2 text-xs shrink-0"
        onClick={handleCopy}
      >
        {copied ? "Copied!" : "Copy"}
      </Button>
    </div>
  );
}

/* ------------------------------------------------ */
/* More Options Drawer                              */
/* ------------------------------------------------ */

function MoreOptionsDrawer({
  property,
  fetchDetail,
  selectedProperty,
  loadingDetail,
}: {
  property: Property;
  fetchDetail: (id: string) => void;
  selectedProperty: Property | null;
  loadingDetail: boolean;
}) {
  // Only use selectedProperty if it matches this row
  const p =
    selectedProperty?.id === property.id ? selectedProperty : null;

  return (
    <Drawer
      direction="right"
      onOpenChange={(open) => {
        if (open) fetchDetail(property.id);
      }}
    >
      <DrawerTrigger asChild>
        <Button variant="outline" size="sm">
          More Options
        </Button>
      </DrawerTrigger>

      <DrawerContent className="flex flex-col max-w-md ml-auto h-full">
        <DrawerHeader className="border-b pb-4">
          <DrawerTitle className="text-base font-semibold">
            Property Info
          </DrawerTitle>
          <DrawerDescription className="text-xs text-muted-foreground">
            Full details for this listing
          </DrawerDescription>
        </DrawerHeader>

        <div className="flex-1 overflow-y-auto p-5 space-y-6">
          {loadingDetail && !p ? (
            <p className="text-sm text-muted-foreground">Loading…</p>
          ) : p ? (
            <>
              {/* Property section */}
              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">
                  Property
                </p>
                <InfoRow label="Title" value={p.title} />
                <InfoRow label="Property ID" value={p.id} mono />
                <InfoRow label="Address" value={p.address ?? "—"} />
                <InfoRow
                  label="Price"
                  value={p.price ? `$${p.price.toLocaleString()}` : "—"}
                />
                <InfoRow
                  label="Status"
                  value={
                    <Badge
                      variant={
                        p.status === "AVAILABLE"
                          ? "default"
                          : p.status === "SUSPENDED"
                          ? "destructive"
                          : "secondary"
                      }
                    >
                      {p.status}
                    </Badge>
                  }
                />
              </section>

              {/* Seller section */}
              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">
                  Seller
                </p>
                <InfoRow
                  label="Seller Name"
                  value={(p as Property).sellerName ?? "—"}
                />
                <InfoRow
                  label="Seller ID"
                  value={
                    <CopyField value={(p as Property).sellerId ?? "—"} />
                  }
                />
              </section>
            </>
          ) : (
            <p className="text-sm text-muted-foreground">
              No details available.
            </p>
          )}
        </div>

        <DrawerFooter className="border-t">
          <DrawerClose asChild>
            <Button variant="outline" className="w-full">
              Close
            </Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}

/* ------------------------------------------------ */
/* Columns                                          */
/* ------------------------------------------------ */

function buildColumns(
  fetchDetail: (id: string) => void,
  selectedProperty: Property | null,
  loadingDetail: boolean,
  onStatusChange: (id: string, status: PropertyStatus) => Promise<void>
): ColumnDef<Property>[] {
  return [
    {
      accessorKey: "id",
      header: "Property ID",
      cell: ({ row }) => (
        <span className="font-mono text-xs text-muted-foreground">
          {row.original.id}
        </span>
      ),
    },
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
        <Badge
          variant={
            row.original.status === "AVAILABLE"
              ? "default"
              : row.original.status === "SUSPENDED"
              ? "destructive"
              : "secondary"
          }
        >
          {row.original.status}
        </Badge>
      ),
    },
    {
      id: "options",
      header: "",
      cell: ({ row }) => (
        <MoreOptionsDrawer
          property={row.original}
          fetchDetail={fetchDetail}
          selectedProperty={selectedProperty}
          loadingDetail={loadingDetail}
        />
      ),
    },
  ];
}

/* ------------------------------------------------ */
/* Main Page                                        */
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

  const {
    count: featuredCount,
    loading: featuredLoading,
    error: featuredError,
    updating: featuredUpdating,
    updateError: featuredUpdateError,
    updateCount,
  } = useFeaturedCount();

  const [editCount, setEditCount] = useState<number>(featuredCount);

  // keep editCount in sync with fetched value
  useEffect(() => {
    setEditCount(featuredCount);
  }, [featuredCount]);

  const saveFeatured = async () => {
    if (editCount !== featuredCount) {
      await updateCount(editCount);
    }
  };


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
      [p.title, p.status, p.price?.toString(), p.id]
        .filter(Boolean)
        .join(" ")
        .toLowerCase()
        .includes(search.toLowerCase())
    );
  }, [properties, search]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: { sorting, pagination },
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

      {/* featured count editor */}
      <div className="flex items-center gap-2">
        <label className="text-sm font-medium">Featured properties:</label>
        <Input
          type="number"
          min={1}
          value={editCount}
          onChange={(e) => setEditCount(Number(e.target.value))}
          disabled={featuredLoading || featuredUpdating}
          className="w-24"
        />
        <Button
          size="sm"
          onClick={saveFeatured}
          disabled={featuredLoading || featuredUpdating || editCount === featuredCount}
        >
          {featuredUpdating ? "Saving…" : "Save"}
        </Button>
        {featuredError && (
          <span className="text-red-500 text-sm">{featuredError}</span>
        )}
        {featuredUpdateError && (
          <span className="text-red-500 text-sm">{featuredUpdateError}</span>
        )}
      </div>

      <Input
        placeholder="Search properties…"
        value={search}
        onChange={(e) => {
          setSearch(e.target.value);
          setPagination((p) => ({ ...p, pageIndex: 0 }));
        }}
      />

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
                    {{ asc: " ↑", desc: " ↓" }[
                      header.column.getIsSorted() as string
                    ] ?? ""}
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
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-between items-center">
        <Button
          variant="outline"
          onClick={() => table.previousPage()}
          disabled={!table.getCanPreviousPage()}
        >
          Previous
        </Button>

        <span>
          Page {pagination.pageIndex + 1} of {table.getPageCount()}
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