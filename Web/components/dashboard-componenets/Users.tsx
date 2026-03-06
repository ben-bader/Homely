"use client";

import React, { useMemo, useState } from "react";
import { useUsers } from "@/hooks/useUsers";
import { api } from "@/lib/api";

import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getPaginationRowModel,
  flexRender,
  type ColumnDef,
  type SortingState,
} from "@tanstack/react-table";

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
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerDescription,
  DrawerFooter,
  DrawerClose,
  DrawerTrigger,
} from "@/components/ui/drawer";

import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";

/* ---------------- TYPES ---------------- */

export type User = {
  id: string;
  name: string;
  email: string;
  role: string;
  active: boolean;
};

type PropertySummary = {
  id: string;
  title: string;
  status: string;
};

/* ---------------- INFO ROW ---------------- */

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

/* ---------------- MORE OPTIONS DRAWER ---------------- */

function MoreOptionsDrawer({ user }: { user: User }) {
  const [properties, setProperties] = useState<PropertySummary[]>([]);
  const [loadingProps, setLoadingProps] = useState(false);

  const isSeller = user.role?.toUpperCase() === "SELLER";

  const handleOpen = async (open: boolean) => {
    if (!open || !isSeller || properties.length > 0) return;
    try {
      setLoadingProps(true);
      const res = await api.get<PropertySummary[]>("/admin/properties");
      const sellerProps = res.data.filter(
        (p: any) => p.sellerId === user.id || p.ownerId === user.id
      );
      setProperties(sellerProps);
    } finally {
      setLoadingProps(false);
    }
  };

  return (
    <Drawer direction="right" onOpenChange={handleOpen}>
      <DrawerTrigger asChild>
        <Button variant="outline" size="sm">
          More Options
        </Button>
      </DrawerTrigger>

      <DrawerContent className="flex flex-col max-w-md ml-auto h-full">
        <DrawerHeader className="border-b pb-4">
          <DrawerTitle className="text-base font-semibold">
            User Info
          </DrawerTitle>
          <DrawerDescription className="text-xs text-muted-foreground">
            Full details for this user
          </DrawerDescription>
        </DrawerHeader>

        <div className="flex-1 overflow-y-auto p-5 space-y-6">
          <section className="space-y-4">
            <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">
              User
            </p>
            <InfoRow label="Name" value={user.name} />
            <InfoRow label="User ID" value={user.id} mono />
            <InfoRow label="Email" value={user.email} />
            <InfoRow label="Role" value={user.role} />
          </section>

          {isSeller && (
            <section className="space-y-4">
              <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">
                Listed Properties
              </p>

              {loadingProps ? (
                <p className="text-sm text-muted-foreground">
                  Loading properties…
                </p>
              ) : properties.length === 0 ? (
                <p className="text-sm text-muted-foreground">
                  No properties found for this seller.
                </p>
              ) : (
                <div className="rounded-md border overflow-hidden">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead className="text-xs">Property ID</TableHead>
                        <TableHead className="text-xs">Title</TableHead>
                        <TableHead className="text-xs">Status</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {properties.map((p) => (
                        <TableRow key={p.id}>
                          <TableCell className="font-mono text-xs text-muted-foreground">
                            {p.id}
                          </TableCell>
                          <TableCell className="text-xs">{p.title}</TableCell>
                          <TableCell>
                            <Badge
                              variant={
                                p.status === "AVAILABLE"
                                  ? "default"
                                  : p.status === "SUSPENDED"
                                  ? "destructive"
                                  : "secondary"
                              }
                              className="text-xs"
                            >
                              {p.status}
                            </Badge>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              )}
            </section>
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

/* ---------------- ACTION CELL ---------------- */

function ActionCell({
  user,
  onToggle,
}: {
  user: User;
  onToggle: (id: string, currentActive: boolean) => Promise<void>;
}) {
  const [loading, setLoading] = useState(false);

  const handleClick = async () => {
    setLoading(true);
    try {
      await onToggle(user.id, user.active);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Button
      size="sm"
      variant={user.active ? "destructive" : "outline"}
      disabled={loading}
      onClick={handleClick}
    >
      {loading ? "Updating…" : user.active ? "Deactivate" : "Activate"}
    </Button>
  );
}

/* ---------------- PAGE ---------------- */

export default function Users() {
  const { users, loading, error, setUsers } = useUsers();

  const [search, setSearch] = useState("");
  const [sorting, setSorting] = useState<SortingState>([]);
  const [pagination, setPagination] = useState({
    pageIndex: 0,
    pageSize: 10,
  });

  const handleToggle = async (id: string, currentActive: boolean) => {
    if (currentActive) {
      await api.put(`/admin/users/${id}/deactivate`);
    } else {
      await api.put(`/admin/users/${id}/activate`);
    }
    setUsers((prev) =>
      prev.map((u) => (u.id === id ? { ...u, active: !currentActive } : u))
    );
  };

  const columns = useMemo<ColumnDef<User>[]>(
    () => [
      {
        accessorKey: "id",
        header: "User ID",
        cell: ({ row }) => (
          <span className="font-mono text-xs text-muted-foreground">
            {row.original.id}
          </span>
        ),
      },
      { accessorKey: "name", header: "Name" },
      { accessorKey: "email", header: "Email" },
      { accessorKey: "role", header: "Role" },
      {
        id: "actions",
        header: "Actions",
        cell: ({ row }) => (
          <ActionCell user={row.original} onToggle={handleToggle} />
        ),
      },
      {
        id: "more",
        header: "",
        cell: ({ row }) => <MoreOptionsDrawer user={row.original} />,
      },
    ],
    [users]
  );

  const filteredData = useMemo(() => {
  if (!users) return [];
  return users.filter((u) =>
    [u.id, u.name, u.email, u.role] // include the ID here
      .filter(Boolean)
      .join(" ")
      .toLowerCase()
      .includes(search.toLowerCase())
  );
}, [users, search]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: { sorting, pagination },
    onSortingChange: setSorting,
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  if (loading) return <div className="p-8">Loading users…</div>;
  if (error) return <div className="p-8 text-red-500">{error}</div>;

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">Users</h2>

      <Input
        placeholder="Search users…"
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
            {table.getRowModel().rows.length > 0 ? (
              table.getRowModel().rows.map((row) => (
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
              ))
            ) : (
              <TableRow>
                <TableCell
                  colSpan={columns.length}
                  className="text-center py-10"
                >
                  No users found
                </TableCell>
              </TableRow>
            )}
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
          Page {pagination.pageIndex + 1} of{" "}
          {Math.max(table.getPageCount(), 1)}
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