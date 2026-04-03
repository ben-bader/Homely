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
      close: "Close"
    }
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
      close: "Fermer"
    }
  }
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
                <DrawerClose asChild><Button variant="outline">{t.details.close}</Button></DrawerClose>
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
      const statusMatch = !statusFilter || (statusFilter === "active" && u.active) || (statusFilter === "inactive" && !u.active);
      return textMatch && roleMatch && statusMatch;
    });

    if (dateSort === "newest") {
      filtered.sort((a, b) => (parseDate(b.createdAt)?.getTime() ?? 0) - (parseDate(a.createdAt)?.getTime() ?? 0));
    } else if (dateSort === "oldest") {
      filtered.sort((a, b) => (parseDate(a.createdAt)?.getTime() ?? 0) - (parseDate(b.createdAt)?.getTime() ?? 0));
    }
    return filtered;
  }, [users, search, roleFilter, statusFilter, dateSort]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: { pagination },
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  if (loading) return <div className="p-8">...</div>;

  return (
    <div className="px-8 space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-xl font-semibold">{t.title}</h2>
        <Button variant="outline" size="sm" onClick={() => setLang(lang === "en" ? "fr" : "en")}>
          {lang === "en" ? "🇫🇷 FR" : "🇺🇸 EN"}
        </Button>
      </div>

      <div className="flex gap-2">
        <Input placeholder={t.searchPlaceholder} value={search} onChange={(e) => setSearch(e.target.value)} />
        <Button variant="outline" onClick={() => setFilterOpen(!filterOpen)}>
          {t.filters} {filteredData.length < users.length && t.filtered}
        </Button>
      </div>

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
            {table.getRowModel().rows.map((row) => (
              <TableRow key={row.id}>
                {row.getVisibleCells().map((cell) => (
                  <TableCell key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-center items-center gap-4 py-2 text-sm">
        <Button size="sm" variant="outline" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>{t.prev}</Button>
        <span>{t.page} {pagination.pageIndex + 1} {t.of} {table.getPageCount()}</span>
        <Button size="sm" variant="outline" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>{t.next}</Button>
      </div>
    </div>
  );
}