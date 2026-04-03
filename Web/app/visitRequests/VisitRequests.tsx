"use client";

import React, { useMemo, useState, useCallback } from "react";
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  getPaginationRowModel,
  flexRender,
  type ColumnDef,
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
import { Button } from "@/components/ui/button";
import { FaEye } from "react-icons/fa";

import { useVisitRequests } from "@/app/visitRequests/useVisitRequests";
import { useProperties } from "@/app/properties/useProperties";
import { useUsers } from "@/app/users/useUsers";
import { VisitStatus, type VisitRequest } from "@/types/dashboard-types";

/* ---------------- TRANSLATIONS ---------------- */

type Language = "en" | "fr";

const dict = {
  en: {
    title: "Visit Requests",
    searchPlaceholder: "Search by client, property, status...",
    filter: "Filter",
    total: "Total",
    pending: "Pending",
    approved: "Approved",
    completed: "Completed",
    rejected: "Rejected",
    property: "Property",
    seller: "Seller",
    client: "Client",
    reqDate: "Requested Date",
    status: "Status",
    noResults: "No visit requests match your filters",
    page: "Page",
    of: "of",
    next: "Next",
    prev: "Previous",
    filtered: "(filtered)",
    details: {
      title: "Visit Request",
      desc: "Full details for this visit request",
      overview: "Overview",
      propInfo: "Property",
      sellerInfo: "Seller",
      clientInfo: "Client",
      name: "Name",
      email: "Email",
      createdAt: "Created At",
      updatedAt: "Updated At",
      timestamps: "Timestamps",
      close: "Close"
    }
  },
  fr: {
    title: "Demandes de Visite",
    searchPlaceholder: "Chercher par client, propriété, statut...",
    filter: "Filtrer",
    total: "Total",
    pending: "En attente",
    approved: "Approuvé",
    completed: "Terminé",
    rejected: "Rejeté",
    property: "Propriété",
    seller: "Vendeur",
    client: "Client",
    reqDate: "Date demandée",
    status: "Statut",
    noResults: "Aucune demande ne correspond aux filtres",
    page: "Page",
    of: "sur",
    next: "Suivant",
    prev: "Précédent",
    filtered: "(filtré)",
    details: {
      title: "Détails de la visite",
      desc: "Informations complètes sur cette demande",
      overview: "Aperçu",
      propInfo: "Propriété",
      sellerInfo: "Vendeur",
      clientInfo: "Client",
      name: "Nom",
      email: "E-mail",
      createdAt: "Créé le",
      updatedAt: "Mis à jour le",
      timestamps: "Horodatage",
      close: "Fermer"
    }
  }
};

/* ---------------- HELPERS ---------------- */

function parseDate(v: string | number | null | undefined): Date | null {
  if (!v) return null;
  if (typeof v === "number") return new Date(v);
  if (typeof v === "string" && !v.endsWith("Z") && !v.includes("+"))
    return new Date(v + "Z");
  return new Date(v);
}

function fmt(v: string | number | null | undefined, locale: string) {
  const d = parseDate(v);
  return d ? d.toLocaleDateString(locale) : "—";
}

function fmtFull(v: string | number | null | undefined, locale: string) {
  const d = parseDate(v);
  return d ? d.toLocaleString(locale) : "—";
}

function statusVariant(status: VisitStatus): "default" | "secondary" | "destructive" | "outline" {
  switch (status) {
    case VisitStatus.APPROVED: return "default";
    case VisitStatus.COMPLETED: return "secondary";
    case VisitStatus.PENDING: return "outline";
    case VisitStatus.REJECTED: return "destructive";
    default: return "outline";
  }
}

/* ---------------- SUMMARY CARDS ---------------- */

function SummaryCards({ visitRequests, t }: { visitRequests: VisitRequest[], t: any }) {
  const total = visitRequests.length;
  const pending = visitRequests.filter((r) => r.status === VisitStatus.PENDING).length;
  const approved = visitRequests.filter((r) => r.status === VisitStatus.APPROVED).length;
  const completed = visitRequests.filter((r) => r.status === VisitStatus.COMPLETED).length;
  const rejected = visitRequests.filter((r) => r.status === VisitStatus.REJECTED).length;

  const cards = [
    { label: t.total, value: total, colorClass: "text-foreground", bgClass: "bg-muted/50" },
    { label: t.pending, value: pending, colorClass: "text-yellow-600 dark:text-yellow-400", bgClass: "bg-yellow-50 dark:bg-yellow-950/30" },
    { label: t.approved, value: approved, colorClass: "text-green-600", bgClass: "bg-green-50 dark:bg-green-950/30" },
    { label: t.completed, value: completed, colorClass: "text-blue-600 dark:text-blue-400", bgClass: "bg-blue-50 dark:bg-blue-950/30" },
    { label: t.rejected, value: rejected, colorClass: "text-destructive", bgClass: "bg-destructive/10" },
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
      {cards.map((card) => (
        <div key={card.label} className={`rounded-lg border p-4 flex items-center gap-3 ${card.bgClass}`}>
          <div>
            <p className="text-[11px] uppercase tracking-widest text-muted-foreground font-semibold">{card.label}</p>
            <p className={`text-2xl font-bold ${card.colorClass}`}>{card.value}</p>
          </div>
        </div>
      ))}
    </div>
  );
}

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">{label}</span>
      {typeof value === "string" || typeof value === "number" ? (
        <span className="text-sm font-medium text-foreground">{value}</span>
      ) : (
        <div className="mt-0.5">{value}</div>
      )}
    </div>
  );
}

/* ---------------- MAIN PAGE ---------------- */

export default function VisitRequests() {
  const [lang, setLang] = useState<Language>("en");
  const t = dict[lang];
  const dateLocale = lang === "fr" ? "fr-FR" : "en-US";

  const { visitRequests, loading, error } = useVisitRequests();
  const { properties } = useProperties();
  const { users } = useUsers();

  const [search, setSearch] = useState("");
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
  const [filterStatus, setFilterStatus] = useState<VisitStatus | "ALL">("ALL");
  const [createdAfter, setCreatedAfter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [dateSort, setDateSort] = useState<"" | "newest" | "oldest">("");
  const [filterOpen, setFilterOpen] = useState(false);

  const activeFilterCount = [
    filterStatus !== "ALL",
    createdAfter !== "",
    createdBefore !== "",
    dateSort !== "",
  ].filter(Boolean).length;

  const columns = useMemo<ColumnDef<any>[]>(() => [
    { accessorKey: "propertyTitle", header: t.property, cell: ({ row }) => <p className="text-sm font-medium">{row.original.propertyTitle}</p> },
    { accessorKey: "sellerName", header: t.seller, cell: ({ row }) => (
      <div>
        <p className="text-sm font-medium">{row.original.sellerName ?? "—"}</p>
        <p className="text-xs text-muted-foreground">{row.original.sellerEmail ?? ""}</p>
      </div>
    ) },
    { accessorKey: "userName", header: t.client, cell: ({ row }) => (
      <div>
        <p className="text-sm font-medium">{row.original.userName}</p>
        <p className="text-xs text-muted-foreground">{row.original.userEmail}</p>
      </div>
    ) },
    { accessorKey: "requestedDate", header: t.reqDate, cell: ({ row }) => fmt(row.original.requestedDate, dateLocale) },
    { accessorKey: "status", header: t.status, cell: ({ row }) => <Badge variant={statusVariant(row.original.status)}>{row.original.status.toLowerCase()}</Badge> },
    { id: "seeMore", header: "", cell: ({ row }) => (
        <Drawer direction="right">
          <DrawerTrigger asChild>
            <Button variant="ghost" size="icon"><FaEye /></Button>
          </DrawerTrigger>
          <DrawerContent className="flex flex-col max-w-md ml-auto h-full p-6">
            <DrawerHeader>
              <DrawerTitle>{t.details.title}</DrawerTitle>
              <DrawerDescription>{t.details.desc}</DrawerDescription>
            </DrawerHeader>
            <div className="flex-1 overflow-y-auto space-y-6 mt-4">
              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.overview}</p>
                <InfoRow label={t.status} value={<Badge variant={statusVariant(row.original.status)}>{row.original.status}</Badge>} />
                <InfoRow label={t.reqDate} value={fmtFull(row.original.requestedDate, dateLocale)} />
              </section>
              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.propInfo}</p>
                <InfoRow label="Title" value={row.original.propertyTitle} />
              </section>
              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.sellerInfo}</p>
                <InfoRow label={t.details.name} value={row.original.sellerName ?? "—"} />
                <InfoRow label={t.details.email} value={row.original.sellerEmail ?? "—"} />
              </section>
              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.clientInfo}</p>
                <InfoRow label={t.details.name} value={row.original.userName} />
                <InfoRow label={t.details.email} value={row.original.userEmail} />
              </section>
              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t.details.timestamps}</p>
                <div className="grid grid-cols-2 gap-3">
                  <InfoRow label={t.details.createdAt} value={fmtFull(row.original.createdAt, dateLocale)} />
                  <InfoRow label={t.details.updatedAt} value={fmtFull(row.original.updatedAt, dateLocale)} />
                </div>
              </section>
            </div>
            <DrawerFooter><DrawerClose asChild><Button variant="outline" className="w-full">{t.details.close}</Button></DrawerClose></DrawerFooter>
          </DrawerContent>
        </Drawer>
      )
    },
  ], [t, dateLocale]);

  const visitRequestsWithSeller = useMemo(() => {
    if (!properties || !users) return visitRequests;
    const propMap = Object.fromEntries(properties.map(p => [p.id, p]));
    const userMap = Object.fromEntries(users.map(u => [u.id, u]));

    return visitRequests.map(req => {
      const prop = propMap[req.propertyId];
      const seller = prop?.sellerId ? userMap[prop.sellerId] : null;
      return {
        ...req,
        propertyTitle: prop?.title ?? "—",
        sellerName: prop?.sellerName ?? "—",
        sellerEmail: seller?.email ?? "—",
      };
    });
  }, [visitRequests, properties, users]);

  const filteredData = useMemo(() => {
    const filtered = visitRequestsWithSeller.filter(r => {
      const textMatch = [r.userName, r.userEmail, r.propertyTitle, r.status, r.sellerName, r.sellerEmail]
        .filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
      const statusMatch = filterStatus === "ALL" || r.status === filterStatus;
      return textMatch && statusMatch;
    });
    return filtered;
  }, [visitRequestsWithSeller, search, filterStatus]);

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
        <Button variant="ghost" size="sm" onClick={() => setLang(lang === "en" ? "fr" : "en")}>
          {lang === "en" ? "🇫🇷 FR" : "🇺🇸 EN"}
        </Button>
      </div>

      <SummaryCards visitRequests={visitRequestsWithSeller} t={t} />

      <div className="flex gap-2">
        <Input placeholder={t.searchPlaceholder} value={search} onChange={(e) => setSearch(e.target.value)} />
        <Button variant="outline" onClick={() => setFilterOpen(!filterOpen)}>
          {t.filter} {activeFilterCount > 0 && t.filtered}
        </Button>
      </div>

      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader className="bg-primary text-white">
            {table.getHeaderGroups().map(hg => (
              <TableRow key={hg.id}>
                {hg.headers.map(header => (
                  <TableHead key={header.id} className="text-white">
                    {flexRender(header.column.columnDef.header, header.getContext())}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.map(row => (
              <TableRow key={row.id}>
                {row.getVisibleCells().map(cell => (
                  <TableCell key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-center items-center gap-2 px-4 py-2 text-sm text-muted-foreground">
        <Button variant="outline" size="sm" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>{t.prev}</Button>
        <span>{t.page} {pagination.pageIndex + 1} {t.of} {table.getPageCount()}</span>
        <Button variant="outline" size="sm" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>{t.next}</Button>
      </div>
    </div>
  );
}