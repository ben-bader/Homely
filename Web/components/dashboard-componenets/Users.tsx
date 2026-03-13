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

import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import { FaEye } from "react-icons/fa";

/* ---------------- TYPES ---------------- */

export type User = {
  id: string;
  name: string;
  email: string;
  role: string;
  active: boolean;
  createdAt: string | number;
};

type DateSort = "" | "newest" | "oldest";

/* ---------------- PARSE DATE ---------------- */

function parseDate(value: string | number | null | undefined): Date | null {
  if (!value) return null;
  if (typeof value === "number") return new Date(value);
  if (typeof value === "string" && !value.endsWith("Z") && !value.includes("+"))
    return new Date(value + "Z");
  return new Date(value);
}

/* ---------------- INFO ROW ---------------- */

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">
        {label}
      </span>
      <span className="text-sm font-medium">{value}</span>
    </div>
  );
}

/* ---------------- FILTER PANEL ---------------- */

function FilterPanel({
  roles,
  roleFilter, setRoleFilter,
  statusFilter, setStatusFilter,
  createdAfter, setCreatedAfter,
  createdBefore, setCreatedBefore,
  dateSort, setDateSort,
  onClear,
}: {
  roles: string[];
  roleFilter: string; setRoleFilter: (v: string) => void;
  statusFilter: string; setStatusFilter: (v: string) => void;
  createdAfter: string; setCreatedAfter: (v: string) => void;
  createdBefore: string; setCreatedBefore: (v: string) => void;
  dateSort: DateSort; setDateSort: (v: DateSort) => void;
  onClear: () => void;
}) {
  const activeCount = [
    roleFilter !== "",
    statusFilter !== "",
    createdAfter !== "",
    createdBefore !== "",
    dateSort !== "",
  ].filter(Boolean).length;

  const statuses = ["active", "inactive"];

  const dateSortOptions: { value: DateSort; label: string; icon: string }[] = [
    { value: "newest", label: "Newest first", icon: "↓" },
    { value: "oldest", label: "Oldest first", icon: "↑" },
  ];

  return (
    <div className="rounded-lg border bg-background shadow-sm overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/40">
        <div className="flex items-center gap-2">
          <svg className="w-3.5 h-3.5 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L13 13.414V19a1 1 0 01-.553.894l-4 2A1 1 0 017 21v-7.586L3.293 6.707A1 1 0 013 6V4z" />
          </svg>
          <span className="text-xs font-semibold text-foreground uppercase tracking-widest">Filters</span>
          {activeCount > 0 && (
            <span className="inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
              {activeCount}
            </span>
          )}
        </div>
        {activeCount > 0 && (
          <button onClick={onClear} className="text-[11px] text-muted-foreground hover:text-foreground transition-colors font-medium">
            Clear all
          </button>
        )}
      </div>

      <div className="p-4 space-y-5">
        {/* Role pills — dynamic from actual data */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Role</label>
          <div className="flex flex-wrap gap-1.5">
            {["", ...roles].map((r) => (
              <button
                key={r || "ALL"}
                onClick={() => setRoleFilter(r)}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  roleFilter === r
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {r || "ALL"}
              </button>
            ))}
          </div>
        </div>

        {/* Status pills */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Status</label>
          <div className="flex gap-1.5">
            {["", ...statuses].map((s) => (
              <button
                key={s || "ALL"}
                onClick={() => setStatusFilter(s)}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  statusFilter === s
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {s === "" ? "ALL" : s.charAt(0).toUpperCase() + s.slice(1)}
              </button>
            ))}
          </div>
        </div>

        {/* Date Sort */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Sort by Date</label>
          <div className="flex gap-1.5">
            {dateSortOptions.map(({ value, label, icon }) => (
              <button
                key={value}
                onClick={() => setDateSort(dateSort === value ? "" : value)}
                className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  dateSort === value
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                <span>{icon}</span>
                {label}
              </button>
            ))}
          </div>
        </div>

        {/* Date Range */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">Joined Between</label>
          <div className="grid grid-cols-2 gap-2">
            <div className="space-y-1">
              <span className="text-[10px] text-muted-foreground">After</span>
              <Input type="date" value={createdAfter} onChange={(e) => setCreatedAfter(e.target.value)} />
            </div>
            <div className="space-y-1">
              <span className="text-[10px] text-muted-foreground">Before</span>
              <Input type="date" value={createdBefore} onChange={(e) => setCreatedBefore(e.target.value)} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ---------------- USER DETAILS DRAWER ---------------- */

function MoreOptionsDrawer({ user }: { user: User }) {
  return (
    <Drawer direction="right">
      <DrawerTrigger asChild>
        <Button variant="ghost" size="icon"><FaEye /></Button>
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
            value={parseDate(user.createdAt)?.toLocaleString() ?? "—"}
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
  const [dateSort, setDateSort] = useState<DateSort>("");
  const [filterOpen, setFilterOpen] = useState(false);

  // Derive unique roles from actual data for dynamic pills
  const roles = useMemo(() => {
    const set = new Set(users.map((u) => u.role).filter(Boolean));
    return Array.from(set).sort();
  }, [users]);

  const clearFilters = () => {
    setRoleFilter("");
    setStatusFilter("");
    setCreatedAfter("");
    setCreatedBefore("");
    setDateSort("");
  };

  const activeFilterCount = [
    roleFilter !== "",
    statusFilter !== "",
    createdAfter !== "",
    createdBefore !== "",
    dateSort !== "",
  ].filter(Boolean).length;

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
          parseDate(row.original.createdAt)?.toLocaleDateString() ?? "—",
      },
      {
        id: "action",
        header: "Action",
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

    const filtered = users.filter((u) => {
      const textMatch = [u.name, u.email, u.role]
        .join(" ")
        .toLowerCase()
        .includes(search.toLowerCase());

      const roleMatch =
        !roleFilter || u.role.toLowerCase() === roleFilter.toLowerCase();

      const statusMatch =
        !statusFilter ||
        (statusFilter === "active" && u.active) ||
        (statusFilter === "inactive" && !u.active);

      const created = parseDate(u.createdAt)?.getTime() ?? null;

      const beforeMatch =
        !createdBefore ||
        (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());

      const afterMatch =
        !createdAfter ||
        (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());

      return textMatch && roleMatch && statusMatch && beforeMatch && afterMatch;
    });

    // Apply date sort if set
    if (dateSort === "newest") {
      filtered.sort((a, b) => {
        const aTime = parseDate(a.createdAt)?.getTime() ?? 0;
        const bTime = parseDate(b.createdAt)?.getTime() ?? 0;
        return bTime - aTime;
      });
    } else if (dateSort === "oldest") {
      filtered.sort((a, b) => {
        const aTime = parseDate(a.createdAt)?.getTime() ?? 0;
        const bTime = parseDate(b.createdAt)?.getTime() ?? 0;
        return aTime - bTime;
      });
    }

    return filtered;
  }, [users, search, roleFilter, statusFilter, createdBefore, createdAfter, dateSort]);

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
        <Button
          variant="outline"
          onClick={() => setFilterOpen((v) => !v)}
          className="relative"
        >
          Filter
          {activeFilterCount > 0 && (
            <span className="absolute -top-1.5 -right-1.5 inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
              {activeFilterCount}
            </span>
          )}
        </Button>
      </div>

      {filterOpen && (
        <FilterPanel
          roles={roles}
          roleFilter={roleFilter} setRoleFilter={setRoleFilter}
          statusFilter={statusFilter} setStatusFilter={setStatusFilter}
          createdAfter={createdAfter} setCreatedAfter={setCreatedAfter}
          createdBefore={createdBefore} setCreatedBefore={setCreatedBefore}
          dateSort={dateSort} setDateSort={setDateSort}
          onClear={clearFilters}
        />
      )}

      {/* Results count */}
      <div className="flex items-center justify-between">
        <span className="text-xs text-muted-foreground">
          {filteredData.length} user{filteredData.length !== 1 ? "s" : ""}
          {activeFilterCount > 0 && " (filtered)"}
        </span>
      </div>

      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader className="bg-blue-900 text-white">
            {table.getHeaderGroups().map((hg) => (
              <TableRow key={hg.id}>
                {hg.headers.map((header) => (
                  <TableHead key={header.id}>
                    {flexRender(header.column.columnDef.header, header.getContext())}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>

          <TableBody>
            {table.getRowModel().rows.length === 0 ? (
              <TableRow>
                <TableCell colSpan={columns.length} className="text-center text-muted-foreground py-12 text-sm">
                  No users match your filters
                </TableCell>
              </TableRow>
            ) : (
              table.getRowModel().rows.map((row) => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-center items-center gap-2 px-4 py-2 border-t text-sm text-muted-foreground">
  <Button
    variant="outline"
    size="sm"
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
    size="sm"
    onClick={() => table.nextPage()}
    disabled={!table.getCanNextPage()}
  >
    Next
  </Button>
</div>
    </div>
  );
}