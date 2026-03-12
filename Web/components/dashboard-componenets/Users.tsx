"use client";

import React, { useMemo, useState, useCallback } from "react";
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

import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";

import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";

/* ---------------- TYPES ---------------- */

export type User = {
  id: string;
  name: string;
  email: string;
  role: string;
  active: boolean;
  createdAt: string | number;
};

/* ---------------- PARSE DATE ---------------- */

function parseDate(value: string | number): Date {
  if (!value) return new Date(0);
  if (typeof value === "number") return new Date(value);
  if (
    typeof value === "string" &&
    !value.endsWith("Z") &&
    !value.includes("+")
  ) {
    return new Date(value + "Z");
  }
  return new Date(value);
}

/* ---------------- INFO ROW ---------------- */

function InfoRow({
  label,
  value,
}: {
  label: string;
  value: React.ReactNode;
}) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">
        {label}
      </span>
      <span className="text-sm font-medium">{value}</span>
    </div>
  );
}

/* ---------------- USER DETAILS DRAWER ---------------- */

function MoreOptionsDrawer({ user }: { user: User }) {
  return (
    <Drawer direction="right">
      <DrawerTrigger asChild>
        <Button variant="ghost" size="icon">
          👁
        </Button>
      </DrawerTrigger>

      <DrawerContent className="flex flex-col max-w-md ml-auto h-full">
        <DrawerHeader className="border-b pb-4">
          <DrawerTitle>User Info</DrawerTitle>
          <DrawerDescription>Full details for this user</DrawerDescription>
        </DrawerHeader>

        <div className="p-5 space-y-4">
          <InfoRow label="Name" value={user.name} />
          <InfoRow label="Email" value={user.email} />
          <InfoRow label="Role" value={user.role} />
          <InfoRow
            label="Created"
            value={parseDate(user.createdAt).toLocaleString()}
          />
          <InfoRow label="Active" value={user.active ? "Yes" : "No"} />
        </div>

        <DrawerFooter className="border-t">
          <DrawerClose asChild>
            <Button variant="outline">Close</Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}

/* ---------------- STATUS SWITCH ---------------- */

function StatusSwitch({
  user,
  onToggle,
}: {
  user: User;
  onToggle: (id: string, currentActive: boolean) => Promise<void>;
}) {
  const [loading, setLoading] = useState(false);

  const toggle = async () => {
    setLoading(true);
    try {
      await onToggle(user.id, user.active);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Switch checked={user.active} disabled={loading} onCheckedChange={toggle} />
  );
}

/* ---------------- PAGE ---------------- */

export default function Users() {
  const { users, loading, error, setUsers } = useUsers();

  const [search, setSearch] = useState("");
  const [sorting, setSorting] = useState<SortingState>([]);
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
  const [roleFilter, setRoleFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [createdAfter, setCreatedAfter] = useState("");

  const handleToggle = useCallback(
    async (id: string, currentActive: boolean) => {
      if (currentActive) {
        await api.put(`/admin/users/${id}/deactivate`);
      } else {
        await api.put(`/admin/users/${id}/activate`);
      }

      setUsers((prev) =>
        prev.map((u) => (u.id === id ? { ...u, active: !currentActive } : u))
      );
    },
    [setUsers]
  );

  const columns = useMemo<ColumnDef<User>[]>(
    () => [
      { accessorKey: "name", header: "Name" },
      { accessorKey: "email", header: "Email" },
      { accessorKey: "role", header: "Role" },
      {
        accessorKey: "createdAt",
        header: "Created",
        cell: ({ row }) =>
          parseDate(row.original.createdAt).toLocaleDateString(),
      },
      {
        id: "status",
        header: "Status",
        cell: ({ row }) => (
          <StatusSwitch user={row.original} onToggle={handleToggle} />
        ),
      },
      {
        id: "view",
        header: "",
        cell: ({ row }) => <MoreOptionsDrawer user={row.original} />,
      },
    ],
    [handleToggle]
  );

  const filteredData = useMemo(() => {
    if (!users) return [];

    return users.filter((u) => {
      const textMatch = [u.name, u.email, u.role]
        .join(" ")
        .toLowerCase()
        .includes(search.toLowerCase());

      const roleMatch =
        !roleFilter || u.role.toLowerCase().includes(roleFilter.toLowerCase());

      const statusMatch =
        !statusFilter ||
        (statusFilter === "active" && u.active) ||
        (statusFilter === "inactive" && !u.active);

      const created = parseDate(u.createdAt).getTime();

      const beforeMatch =
        !createdBefore ||
        created <= new Date(createdBefore + "T23:59:59Z").getTime();

      const afterMatch =
        !createdAfter ||
        created >= new Date(createdAfter + "T00:00:00Z").getTime();

      return textMatch && roleMatch && statusMatch && beforeMatch && afterMatch;
    });
  }, [users, search, roleFilter, statusFilter, createdBefore, createdAfter]);

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

      <div className="flex gap-2">
        <Input
          placeholder="Search users..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />

        <Popover>
          <PopoverTrigger asChild>
            <Button variant="outline">Filter</Button>
          </PopoverTrigger>

          <PopoverContent className="w-72 space-y-3">
            <Input
              placeholder="Role"
              value={roleFilter}
              onChange={(e) => setRoleFilter(e.target.value)}
            />
            <Input
              placeholder="Status (active/inactive)"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
            />
            <Input
              type="date"
              value={createdAfter}
              onChange={(e) => setCreatedAfter(e.target.value)}
            />
            <Input
              type="date"
              value={createdBefore}
              onChange={(e) => setCreatedBefore(e.target.value)}
            />
          </PopoverContent>
        </Popover>
      </div>

      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((hg) => (
              <TableRow key={hg.id}>
                {hg.headers.map((header) => (
                  <TableHead key={header.id}>
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
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-between">
        <Button
          variant="outline"
          onClick={() => table.previousPage()}
          disabled={!table.getCanPreviousPage()}
        >
          Previous
        </Button>

        <span>
          Page {pagination.pageIndex + 1} of {Math.max(table.getPageCount(), 1)}
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