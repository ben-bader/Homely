"use client";

import React, { useMemo, useState, useCallback } from "react";
import { useLocale } from "next-intl";
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
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from "@/components/ui/table";
import {
  Drawer, DrawerContent, DrawerHeader, DrawerTitle,
  DrawerDescription, DrawerFooter, DrawerClose, DrawerTrigger,
} from "@/components/ui/drawer";
// KPI cards inlined per UI standardization (no shared KPI component)
import { PaginationFooter } from "@/components/ui/pagination";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Eye, Users as UsersIcon, UserCheck, UserX, SlidersHorizontal } from "lucide-react";

type Language = "en" | "fr";
const dict = {
  en: {
    title: "Users", subtitle: "Manage platform users and their access",
    searchPlaceholder: "Search users...", filters: "Filters", clearAll: "Clear all",
    role: "Role", status: "Status", sortByDate: "Sort by Date",
    newest: "Newest first", oldest: "Oldest first",
    joinedBetween: "Joined Between", after: "After", before: "Before",
    all: "ALL", active: "Active", inactive: "Inactive",
    noResults: "No users match your filters",
    results: "user", resultsPlural: "users", filtered: "(filtered)",
    page: "Page", of: "of", next: "Next", prev: "Previous",
    details: { title: "User Details", desc: "Full details for this user", name: "Name", email: "Email", created: "Created", activeStatus: "Active", yes: "Yes", no: "No", close: "Close" },
  },
  fr: {
    title: "Utilisateurs", subtitle: "Gérer les utilisateurs de la plateforme et leurs accès",
    searchPlaceholder: "Rechercher des utilisateurs...", filters: "Filtres", clearAll: "Tout effacer",
    role: "Rôle", status: "Statut", sortByDate: "Trier par date",
    newest: "Plus récent", oldest: "Plus ancien",
    joinedBetween: "Inscrit entre", after: "Après", before: "Avant",
    all: "TOUT", active: "Actif", inactive: "Inactif",
    noResults: "Aucun utilisateur ne correspond à vos filtres",
    results: "utilisateur", resultsPlural: "utilisateurs", filtered: "(filtré)",
    page: "Page", of: "sur", next: "Suivant", prev: "Précédent",
    details: { title: "Info Utilisateur", desc: "Détails complets de cet utilisateur", name: "Nom", email: "E-mail", created: "Créé le", activeStatus: "Actif", yes: "Oui", no: "Non", close: "Fermer" },
  },
};

export type User = { id: string; name: string; email: string; role: string; active: boolean; createdAt: string | number; avatarUrl?: string; };
type DateSort = "" | "newest" | "oldest";

function parseDate(value: string | number | null | undefined): Date | null {
  if (!value) return null;
  if (typeof value === "number") return new Date(value);
  if (typeof value === "string" && !value.endsWith("Z") && !value.includes("+")) return new Date(value + "Z");
  return new Date(value);
}

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground font-medium">{label}</span>
      <span className="text-sm font-medium text-foreground">{value}</span>
    </div>
  );
}

export default function Users() {
  const locale = useLocale();
  const lang = (locale === "fr" ? "fr" : "en") as Language;
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

  const clearFilters = () => { setRoleFilter(""); setStatusFilter(""); setDateSort(""); setCreatedAfter(""); setCreatedBefore(""); };
  const activeFilterCount = [roleFilter !== "", statusFilter !== "", dateSort !== "", createdAfter !== "", createdBefore !== ""].filter(Boolean).length;

  const handleToggle = useCallback(async (id: string, currentActive: boolean) => {
    if (currentActive) { await api.put(`/admin/users/${id}/deactivate`); }
    else { await api.put(`/admin/users/${id}/activate`); }
    setUsers((prev) => prev.map((u) => (u.id === id ? { ...u, active: !currentActive } : u)));
  }, [setUsers]);

  const columns = useMemo<ColumnDef<User>[]>(() => [
    {
      accessorKey: "name", header: t.details.name,
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <Avatar className="w-8 h-8">
            {row.original.avatarUrl && <AvatarImage src={row.original.avatarUrl} alt={row.original.name} />}
            <AvatarFallback className="bg-primary/10 text-primary text-xs font-semibold">{(row.original.name || "?")[0].toUpperCase()}</AvatarFallback>
          </Avatar>
          <span className="font-medium text-sm">{row.original.name}</span>
        </div>
      ),
    },
    { accessorKey: "email", header: t.details.email, cell: ({ row }) => <span className="text-sm text-muted-foreground">{row.original.email}</span> },
    {
      accessorKey: "role", header: t.role,
      cell: ({ row }) => (
        <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-muted text-muted-foreground">{row.original.role}</span>
      ),
    },
    {
      accessorKey: "createdAt", header: t.details.created,
      cell: ({ row }) => <span className="text-sm text-muted-foreground">{parseDate(row.original.createdAt)?.toLocaleDateString(lang === "fr" ? "fr-FR" : "en-US") ?? "—"}</span>,
    },
    {
      id: "action", header: t.status,
      cell: ({ row }) => (
        <Switch
          checked={row.original.active}
          onCheckedChange={() => handleToggle(row.original.id, row.original.active)}
          className="data-[state=checked]:bg-emerald-500 data-[state=unchecked]:bg-slate-300"
        />
      ),
    },
    {
      id: "view", header: "",
      cell: ({ row }) => (
        <Drawer direction="right">
          <DrawerTrigger asChild>
            <Button variant="ghost" size="icon" className="h-8 w-8 text-muted-foreground hover:text-foreground"><Eye className="w-4 h-4" /></Button>
          </DrawerTrigger>
          <DrawerContent className="max-w-md ml-auto h-full">
            <div className="flex flex-col h-full p-6">
              <DrawerHeader className="pb-4 px-0">
                <DrawerTitle className="text-lg">{t.details.title}</DrawerTitle>
                <DrawerDescription className="text-sm">{t.details.desc}</DrawerDescription>
              </DrawerHeader>
              <div className="flex flex-col items-center py-6 border-b">
                <Avatar className="h-20 w-20 text-2xl font-bold">
                  {row.original.avatarUrl && <AvatarImage src={row.original.avatarUrl} alt={row.original.name} />}
                  <AvatarFallback className="bg-primary/10 text-primary font-bold text-xl">{(row.original.name || "?")[0].toUpperCase()}</AvatarFallback>
                </Avatar>
                <p className="mt-3 font-semibold text-foreground">{row.original.name}</p>
                <p className="text-sm text-muted-foreground">{row.original.email}</p>
              </div>
              <div className="space-y-4 mt-6 flex-1">
                <InfoRow label={t.details.name} value={row.original.name} />
                <InfoRow label={t.details.email} value={row.original.email} />
                <InfoRow label={t.role} value={row.original.role} />
                <InfoRow label={t.details.created} value={parseDate(row.original.createdAt)?.toLocaleString(lang === "fr" ? "fr-FR" : "en-US") ?? "—"} />
                <InfoRow label={t.details.activeStatus} value={
                  <span className={`inline-flex items-center gap-1.5 text-xs font-medium ${row.original.active ? "text-emerald-600" : "text-red-500"}`}>
                    <span className={`w-1.5 h-1.5 rounded-full ${row.original.active ? "bg-emerald-500" : "bg-red-500"}`} />
                    {row.original.active ? t.details.yes : t.details.no}
                  </span>
                } />
              </div>
              <DrawerFooter className="mt-auto px-0">
                <DrawerClose asChild><Button variant="outline" className="w-full">{t.details.close}</Button></DrawerClose>
              </DrawerFooter>
            </div>
          </DrawerContent>
        </Drawer>
      ),
    },
  ], [handleToggle, t, lang]);

  const filteredData = useMemo(() => {
    const filtered = users.filter((u) => {
      const textMatch = [u.name, u.email, u.role].join(" ").toLowerCase().includes(search.toLowerCase());
      const roleMatch = !roleFilter || u.role.toLowerCase() === roleFilter.toLowerCase();
      const statusMatch = !statusFilter || (statusFilter === "active" && u.active) || (statusFilter === "inactive" && !u.active);
      const created = parseDate(u.createdAt)?.getTime() ?? null;
      const afterMatch = !createdAfter || (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());
      return textMatch && roleMatch && statusMatch && afterMatch && beforeMatch;
    });
    if (dateSort === "newest") filtered.sort((a, b) => (parseDate(b.createdAt)?.getTime() ?? 0) - (parseDate(a.createdAt)?.getTime() ?? 0));
    else if (dateSort === "oldest") filtered.sort((a, b) => (parseDate(a.createdAt)?.getTime() ?? 0) - (parseDate(b.createdAt)?.getTime() ?? 0));
    return filtered;
  }, [users, search, roleFilter, statusFilter, dateSort, createdAfter, createdBefore]);

  const table = useReactTable({
    data: filteredData, columns,
    state: { pagination },
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  const totalMembers = users.length;
  const totalActivated = users.filter((u) => u.active).length;
  const totalDeactivated = users.filter((u) => !u.active).length;

  if (loading) return <div className="px-6 py-12 text-center text-sm text-muted-foreground">Loading…</div>;

  return (
    <div className="px-6 py-6 max-w-7xl mx-auto space-y-6 animate-fade-up">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-semibold text-foreground">{t.title}</h1>
        <p className="text-sm text-muted-foreground mt-1">{t.subtitle}</p>
      </div>

      {/* Summary Cards (kept inline, styling improved) */}
      <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
        <div className="bg-card border rounded-xl p-5">
          <div className="flex items-start justify-between">
            <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">{t.resultsPlural}</p>
            <div className="w-9 h-9 rounded-lg bg-blue-500 text-white flex items-center justify-center"><UsersIcon className="w-4 h-4" /></div>
          </div>
          <p className="text-2xl font-bold mt-2">{totalMembers}</p>
        </div>

        <div className="bg-card border rounded-xl p-5">
          <div className="flex items-start justify-between">
            <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">{t.active}</p>
            <div className="w-9 h-9 rounded-lg bg-emerald-500 text-white flex items-center justify-center"><UserCheck className="w-4 h-4" /></div>
          </div>
          <p className="text-2xl font-bold text-emerald-600 mt-2">{totalActivated}</p>
        </div>

        <div className="bg-card border rounded-xl p-5">
          <div className="flex items-start justify-between">
            <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">{t.inactive}</p>
            <div className="w-9 h-9 rounded-lg bg-red-500 text-white flex items-center justify-center"><UserX className="w-4 h-4" /></div>
          </div>
          <p className="text-2xl font-bold text-red-500 mt-2">{totalDeactivated}</p>
        </div>
      </div>

      {/* Search + Filter */}
      <div className="flex items-center gap-2">
        <div className="relative flex-1">
          <input placeholder={t.searchPlaceholder} value={search} onChange={(e) => setSearch(e.target.value)}
            className="w-full h-9 pl-3 pr-3 text-sm bg-card border rounded-lg outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/50 placeholder:text-muted-foreground/60 transition-all" />
        </div>
        <Button variant="outline" size="sm" onClick={() => setFilterOpen(!filterOpen)} className="relative h-9 gap-1.5 text-xs font-medium">
          <SlidersHorizontal className="w-3.5 h-3.5" />
          {t.filters}
          {activeFilterCount > 0 && <span className="flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-white">{activeFilterCount}</span>}
        </Button>
      </div>

      {/* Filter Panel */}
      {filterOpen && (
        <div className="bg-card border rounded-xl overflow-hidden animate-fade-up">
          <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/30">
            <span className="text-xs font-semibold text-foreground uppercase tracking-wider">{t.filters}</span>
            {activeFilterCount > 0 && <button onClick={clearFilters} className="text-xs text-muted-foreground hover:text-foreground">{t.clearAll}</button>}
          </div>
          <div className="p-4 space-y-4">
            {roles.length > 0 && (
              <div className="space-y-2">
                <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.role}</label>
                <div className="flex flex-wrap gap-1.5">
                  <button onClick={() => setRoleFilter("")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${roleFilter === "" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>{t.all}</button>
                  {roles.map((role) => (
                    <button key={role} onClick={() => setRoleFilter(roleFilter === role ? "" : role)} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${roleFilter === role ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>{role}</button>
                  ))}
                </div>
              </div>
            )}
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.status}</label>
              <div className="flex flex-wrap gap-1.5">
                <button onClick={() => setStatusFilter("")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${statusFilter === "" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>{t.all}</button>
                <button onClick={() => setStatusFilter(statusFilter === "active" ? "" : "active")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${statusFilter === "active" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>{t.active}</button>
                <button onClick={() => setStatusFilter(statusFilter === "inactive" ? "" : "inactive")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${statusFilter === "inactive" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>{t.inactive}</button>
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.sortByDate}</label>
              <div className="flex gap-1.5">
                <button onClick={() => setDateSort(dateSort === "newest" ? "" : "newest")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${dateSort === "newest" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>↓ {t.newest}</button>
                <button onClick={() => setDateSort(dateSort === "oldest" ? "" : "oldest")} className={`px-3 py-1 rounded-full text-[11px] font-medium transition-all ${dateSort === "oldest" ? "bg-primary text-white" : "bg-muted text-muted-foreground hover:text-foreground"}`}>↑ {t.oldest}</button>
              </div>
            </div>
            <div className="space-y-2">
              <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t.joinedBetween}</label>
              <div className="grid grid-cols-2 gap-2">
                <div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t.after}</span><Input type="date" value={createdAfter} onChange={(e) => setCreatedAfter(e.target.value)} /></div>
                <div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t.before}</span><Input type="date" value={createdBefore} onChange={(e) => setCreatedBefore(e.target.value)} /></div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Table */}
      <div className="bg-card border rounded-xl overflow-hidden">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((hg) => (
              <TableRow key={hg.id} className="border-b bg-muted/30 hover:bg-muted/30">
                {hg.headers.map((header) => (
                  <TableHead key={header.id} className="text-xs font-medium text-muted-foreground uppercase tracking-wider h-10">
                    {flexRender(header.column.columnDef.header, header.getContext())}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length === 0 ? (
              <TableRow><TableCell colSpan={columns.length} className="text-center text-muted-foreground py-16 text-sm">{t.noResults}</TableCell></TableRow>
            ) : (
              table.getRowModel().rows.map((row) => (
                <TableRow key={row.id} className="hover:bg-muted/20 transition-colors">
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id} className="py-3">{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>
                  ))}
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      {/* Pagination (standardized) */}
      <div className="flex justify-between items-center">
        <span className="text-xs text-muted-foreground">{filteredData.length} {filteredData.length === 1 ? t.results : t.resultsPlural} {activeFilterCount > 0 ? t.filtered : ""}</span>
        <PaginationFooter
          pageInfo={`${t.page} ${pagination.pageIndex + 1} ${t.of} ${Math.max(table.getPageCount(), 1)}`}
          onPrevious={() => table.previousPage()}
          onNext={() => table.nextPage()}
          canPrevious={table.getCanPreviousPage()}
          canNext={table.getCanNextPage()}
        />
      </div>
    </div>
  );
}