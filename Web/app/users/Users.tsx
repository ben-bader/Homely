"use client";

import React, { useMemo, useState, useCallback } from "react";
import { useUsers } from "@/app/users/useUsers";
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

/* ---------------- TRANSLATIONS ---------------- */

type Language = "en" | "fr";

const dict = {
  en: {
    title: "Users",
    searchPlaceholder: "Search users...",
    filters: "Filters",
    clearAll: "Clear all",
    role: "Role",
    status: "Status",
    sortByDate: "Sort by Date",
    newest: "Newest first",
    oldest: "Oldest first",
    joinedBetween: "Joined Between",
    after: "After",
    before: "Before",
    all: "ALL",
    active: "Active",
    inactive: "Inactive",
    noResults: "No users match your filters",
    results: "user",
    resultsPlural: "users",
    filtered: "(filtered)",
    page: "Page",
    of: "of",
    next: "Next",
    prev: "Previous",
    details: {
      title: "User Info",
      desc: "Full details for this user",
      name: "Name",
      email: "Email",
      created: "Created",
      activeStatus: "Active",
      yes: "Yes",
      no: "No",
      close: "Close",
    },
  },
  fr: {
    title: "Utilisateurs",
    searchPlaceholder: "Rechercher des utilisateurs...",
    filters: "Filtres",
    clearAll: "Tout effacer",
    role: "Rôle",
    status: "Statut",
    sortByDate: "Trier par date",
    newest: "Plus récent",
    oldest: "Plus ancien",
    joinedBetween: "Inscrit entre",
    after: "Après",
    before: "Avant",
    all: "TOUT",
    active: "Actif",
    inactive: "Inactif",
    noResults: "Aucun utilisateur ne correspond à vos filtres",
    results: "utilisateur",
    resultsPlural: "utilisateurs",
    filtered: "(filtré)",
    page: "Page",
    of: "sur",
    next: "Suivant",
    prev: "Précédent",
    details: {
      title: "Info Utilisateur",
      desc: "Détails complets de cet utilisateur",
      name: "Nom",
      email: "E-mail",
      created: "Créé le",
      activeStatus: "Actif",
      yes: "Oui",
      no: "Non",
      close: "Fermer",
    },
  },
};

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

/* ---------------- HELPERS ---------------- */

function parseDate(value: string | number | null | undefined): Date | null {
  if (!value) return null;
  if (typeof value === "number") return new Date(value);
  if (typeof value === "string" && !value.endsWith("Z") && !value.includes("+"))
    return new Date(value + "Z");
  return new Date(value);
}

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">{label}</span>
      <span className="text-sm font-medium">{value}</span>
    </div>
  );
}

/* ---------------- FILTER PANEL ---------------- */

function FilterPanel({
  t,
  roles,
  roleFilter, setRoleFilter,
  statusFilter, setStatusFilter,
  dateSort, setDateSort,
  createdAfter, setCreatedAfter,
  createdBefore, setCreatedBefore,
  onClear,
}: {
  t: typeof dict["en"];
  roles: string[];
  roleFilter: string; setRoleFilter: (v: string) => void;
  statusFilter: string; setStatusFilter: (v: string) => void;
  dateSort: DateSort; setDateSort: (v: DateSort) => void;
  createdAfter: string; setCreatedAfter: (v: string) => void;
  createdBefore: string; setCreatedBefore: (v: string) => void;
  onClear: () => void;
}) {
  const activeCount = [
    roleFilter !== "",
    statusFilter !== "",
    dateSort !== "",
    createdAfter !== "",
    createdBefore !== "",
  ].filter(Boolean).length;

  const dateSortOptions: { value: DateSort; label: string; icon: string }[] = [
    { value: "newest", label: t.newest, icon: "↓" },
    { value: "oldest", label: t.oldest, icon: "↑" },
  ];

  const statusOptions = [
    { value: "active", label: t.active },
    { value: "inactive", label: t.inactive },
  ];

  return (
    <div className="rounded-lg border bg-background shadow-sm overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/40">
        <div className="flex items-center gap-2">
          <svg className="w-3.5 h-3.5 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L13 13.414V19a1 1 0 01-.553.894l-4 2A1 1 0 017 21v-7.586L3.293 6.707A1 1 0 013 6V4z" />
          </svg>
          <span className="text-xs font-semibold text-foreground uppercase tracking-widest">{t.filters}</span>
          {activeCount > 0 && (
            <span className="inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
              {activeCount}
            </span>
          )}
        </div>
        {activeCount > 0 && (
          <button onClick={onClear} className="text-[11px] text-muted-foreground hover:text-foreground transition-colors font-medium">
            {t.clearAll}
          </button>
        )}
      </div>

      <div className="p-4 space-y-5">
        {/* Role */}
        {roles.length > 0 && (
          <div className="space-y-2">
            <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.role}</label>
            <div className="flex flex-wrap gap-1.5">
              <button
                onClick={() => setRoleFilter("")}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  roleFilter === ""
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {t.all}
              </button>
              {roles.map((role) => (
                <button
                  key={role}
                  onClick={() => setRoleFilter(roleFilter === role ? "" : role)}
                  className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                    roleFilter === role
                      ? "bg-primary text-primary-foreground border-primary"
                      : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                  }`}
                >
                  {role}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Status */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.status}</label>
          <div className="flex flex-wrap gap-1.5">
            <button
              onClick={() => setStatusFilter("")}
              className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                statusFilter === ""
                  ? "bg-primary text-primary-foreground border-primary"
                  : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
              }`}
            >
              {t.all}
            </button>
            {statusOptions.map(({ value, label }) => (
              <button
                key={value}
                onClick={() => setStatusFilter(statusFilter === value ? "" : value)}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  statusFilter === value
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {label}
              </button>
            ))}
          </div>
        </div>

        {/* Date sort */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.sortByDate}</label>
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

        {/* Date range */}
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.joinedBetween}</label>
          <div className="grid grid-cols-2 gap-2">
            <div className="space-y-1">
              <span className="text-[10px] text-muted-foreground">{t.after}</span>
              <Input type="date" value={createdAfter} onChange={(e) => setCreatedAfter(e.target.value)} />
            </div>
            <div className="space-y-1">
              <span className="text-[10px] text-muted-foreground">{t.before}</span>
              <Input type="date" value={createdBefore} onChange={(e) => setCreatedBefore(e.target.value)} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ---------------- MAIN PAGE ---------------- */

export default function Users() {
  const [lang, setLang] = useState<Language>("en");
  const t = dict[lang];

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

  const roles = useMemo(() => {
    const set = new Set(users.map((u) => u.role).filter(Boolean));
    return Array.from(set).sort();
  }, [users]);

  const clearFilters = () => {
    setRoleFilter("");
    setStatusFilter("");
    setDateSort("");
    setCreatedAfter("");
    setCreatedBefore("");
  };

  const activeFilterCount = [
    roleFilter !== "",
    statusFilter !== "",
    dateSort !== "",
    createdAfter !== "",
    createdBefore !== "",
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
      { accessorKey: "name", header: t.details.name },
      { accessorKey: "email", header: t.details.email },
      { accessorKey: "role", header: t.role },
      {
        accessorKey: "createdAt",
        header: t.details.created,
        cell: ({ row }) =>
          parseDate(row.original.createdAt)?.toLocaleDateString(lang === "fr" ? "fr-FR" : "en-US") ?? "—",
      },
      {
        id: "action",
        header: "Action",
        cell: ({ row }) => (
          <Switch
            checked={row.original.active}
            onCheckedChange={() => handleToggle(row.original.id, row.original.active)}
            className="data-[state=checked]:bg-green-500 data-[state=unchecked]:bg-red-500"
          />
        ),
      },
      {
        id: "view",
        header: "",
        cell: ({ row }) => (
          <Drawer direction="right">
            <DrawerTrigger asChild>
              <Button variant="ghost" size="icon"><FaEye /></Button>
            </DrawerTrigger>
            <DrawerContent className="max-w-md ml-auto h-full p-6">
              <DrawerHeader>
                <DrawerTitle>{t.details.title}</DrawerTitle>
                <DrawerDescription>{t.details.desc}</DrawerDescription>
              </DrawerHeader>
              <div className="space-y-4 mt-6">
                <InfoRow label={t.details.name} value={row.original.name} />
                <InfoRow label={t.details.email} value={row.original.email} />
                <InfoRow label={t.role} value={row.original.role} />
                <InfoRow
                  label={t.details.created}
                  value={parseDate(row.original.createdAt)?.toLocaleString(lang === "fr" ? "fr-FR" : "en-US") ?? "—"}
                />
                <InfoRow label={t.details.activeStatus} value={row.original.active ? t.details.yes : t.details.no} />
              </div>
              <DrawerFooter className="mt-auto">
                <DrawerClose asChild><Button variant="outline" className="bg-black hover:bg-gray-900 text-white border-gray-700">{t.details.close}</Button></DrawerClose>
              </DrawerFooter>
            </DrawerContent>
          </Drawer>
        ),
      },
    ],
    [handleToggle, t, lang]
  );

  const filteredData = useMemo(() => {
    const filtered = users.filter((u) => {
      const textMatch = [u.name, u.email, u.role].join(" ").toLowerCase().includes(search.toLowerCase());
      const roleMatch = !roleFilter || u.role.toLowerCase() === roleFilter.toLowerCase();
      const statusMatch =
        !statusFilter ||
        (statusFilter === "active" && u.active) ||
        (statusFilter === "inactive" && !u.active);
      const created = parseDate(u.createdAt)?.getTime() ?? null;
      const afterMatch = !createdAfter || (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());
      return textMatch && roleMatch && statusMatch && afterMatch && beforeMatch;
    });

    if (dateSort === "newest") {
      filtered.sort((a, b) => (parseDate(b.createdAt)?.getTime() ?? 0) - (parseDate(a.createdAt)?.getTime() ?? 0));
    } else if (dateSort === "oldest") {
      filtered.sort((a, b) => (parseDate(a.createdAt)?.getTime() ?? 0) - (parseDate(b.createdAt)?.getTime() ?? 0));
    }
    return filtered;
  }, [users, search, roleFilter, statusFilter, dateSort, createdAfter, createdBefore]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: { pagination },
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  // Summary calculations
  const totalMembers = users.length;
  const totalActivated = users.filter(u => u.active).length;
  const totalDeactivated = users.filter(u => !u.active).length;

  if (loading) return <div className="p-8">...</div>;

  return (
    <div className="px-8 space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">{t.title}</h2>
        <Button variant="outline" size="sm" onClick={() => setLang(lang === "en" ? "fr" : "en")}>
          {lang === "en" ? "🇫🇷 FR" : "🇺🇸 EN"}
        </Button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
        <div className="rounded-lg border p-4 flex items-center gap-3 bg-muted/50">
          <div>
            <p className="text-[11px] uppercase tracking-widest text-muted-foreground font-semibold">{t.resultsPlural}</p>
            <p className="text-2xl font-bold text-foreground">{totalMembers}</p>
          </div>
        </div>
        <div className="rounded-lg border p-4 flex items-center gap-3 bg-green-50 dark:bg-green-950/30">
          <div>
            <p className="text-[11px] uppercase tracking-widest text-muted-foreground font-semibold">{t.active}</p>
            <p className="text-2xl font-bold text-green-600">{totalActivated}</p>
          </div>
        </div>
        <div className="rounded-lg border p-4 flex items-center gap-3 bg-destructive/10">
          <div>
            <p className="text-[11px] uppercase tracking-widest text-muted-foreground font-semibold">{t.inactive}</p>
            <p className="text-2xl font-bold text-destructive">{totalDeactivated}</p>
          </div>
        </div>
      </div>

      {/* Search + Filter toggle */}
      <div className="flex gap-2">
        <Input placeholder={t.searchPlaceholder} value={search} onChange={(e) => setSearch(e.target.value)} />
        <Button variant="outline" onClick={() => setFilterOpen(!filterOpen)} className="relative shrink-0">
          <svg className="w-3.5 h-3.5 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L13 13.414V19a1 1 0 01-.553.894l-4 2A1 1 0 017 21v-7.586L3.293 6.707A1 1 0 013 6V4z" />
          </svg>
          {t.filters}
          {activeFilterCount > 0 && (
            <span className="absolute -top-1.5 -right-1.5 inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
              {activeFilterCount}
            </span>
          )}
        </Button>
      </div>

      {/* ✅ Filter panel — this was missing in the original */}
      {filterOpen && (
        <FilterPanel
          t={t}
          roles={roles}
          roleFilter={roleFilter} setRoleFilter={setRoleFilter}
          statusFilter={statusFilter} setStatusFilter={setStatusFilter}
          dateSort={dateSort} setDateSort={setDateSort}
          createdAfter={createdAfter} setCreatedAfter={setCreatedAfter}
          createdBefore={createdBefore} setCreatedBefore={setCreatedBefore}
          onClear={clearFilters}
        />
      )}

      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader className="bg-primary">
            {table.getHeaderGroups().map((hg) => (
              <TableRow key={hg.id}>
                {hg.headers.map((header) => (
                  <TableHead key={header.id} className="text-white">
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
                  {t.noResults}
                </TableCell>
              </TableRow>
            ) : (
              table.getRowModel().rows.map((row) => (
                <TableRow key={row.id}>
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>
                  ))}
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-center items-center gap-4 py-2 text-sm">
        <Button size="sm" variant="outline" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>←</Button>
        <span>{t.page} {pagination.pageIndex + 1} {t.of} {Math.max(table.getPageCount(), 1)}</span>
        <Button size="sm" variant="outline" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>→</Button>
      </div>
    </div>
  );
}