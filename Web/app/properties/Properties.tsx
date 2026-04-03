"use client";

import React, { useMemo, useState } from "react";
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
import { useProperties } from "@/app/properties/useProperties";
import { Property, PropertyStatus } from "@/types/dashboard-types";
import { api } from "@/lib/api";
import { FaEye } from "react-icons/fa";
import { useMedia } from "@/app/properties/useMedia";
import { useTranslations } from "next-intl";

/* ---------------- TYPES ---------------- */

type DateSort = "" | "newest" | "oldest";

/* ---------------- HELPERS ---------------- */

function parseDate(v: string | number | null | undefined): Date | null {
  if (!v) return null;
  if (typeof v === "number") return new Date(v);
  if (typeof v === "string" && !v.endsWith("Z") && !v.includes("+"))
    return new Date(v + "Z");
  return new Date(v);
}

function fmt(v: string | number | null | undefined) {
  const d = parseDate(v);
  return d ? d.toLocaleDateString() : "—";
}

function fmtFull(v: string | number | null | undefined) {
  const d = parseDate(v);
  return d ? d.toLocaleString() : "—";
}

/* ---------------- INFO ROW ---------------- */

function InfoRow({ label, value, mono = false }: { label: string; value: React.ReactNode; mono?: boolean }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">{label}</span>
      {typeof value === "string" || typeof value === "number" ? (
        <span className={mono ? "font-mono text-xs break-all text-foreground" : "text-sm font-medium text-foreground"}>
          {value}
        </span>
      ) : (
        <div className="mt-0.5">{value}</div>
      )}
    </div>
  );
}

/* ---------------- FILTER PANEL ---------------- */

function FilterPanel({
  filterStatus, setFilterStatus,
  minPrice, setMinPrice,
  maxPrice, setMaxPrice,
  city, setCity,
  createdAfter, setCreatedAfter,
  createdBefore, setCreatedBefore,
  dateSort, setDateSort,
  onClear,
}: {
  filterStatus: PropertyStatus | "ALL"; setFilterStatus: (v: PropertyStatus | "ALL") => void;
  minPrice: number | ""; setMinPrice: (v: number | "") => void;
  maxPrice: number | ""; setMaxPrice: (v: number | "") => void;
  city: string; setCity: (v: string) => void;
  createdAfter: string; setCreatedAfter: (v: string) => void;
  createdBefore: string; setCreatedBefore: (v: string) => void;
  dateSort: DateSort; setDateSort: (v: DateSort) => void;
  onClear: () => void;
}) {
  const t = useTranslations('properties.filters');
  const statuses: (PropertyStatus | "ALL")[] = ["ALL", "AVAILABLE", "SUSPENDED", "DRAFT"];
  const activeCount = [
    filterStatus !== "ALL", minPrice !== "", maxPrice !== "",
    city !== "", createdAfter !== "", createdBefore !== "",
    dateSort !== "",
  ].filter(Boolean).length;

  const dateSortOptions: { value: DateSort; label: string; icon: string }[] = [
    { value: "newest", label: t('dateNewest'), icon: "↓" },
    { value: "oldest", label: t('dateOldest'), icon: "↑" },
  ];

  return (
    <div className="rounded-lg border bg-background shadow-sm overflow-hidden">
      <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/40">
        <div className="flex items-center gap-2">
          <svg className="w-3.5 h-3.5 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L13 13.414V19a1 1 0 01-.553.894l-4 2A1 1 0 017 21v-7.586L3.293 6.707A1 1 0 013 6V4z" />
          </svg>
          <span className="text-xs font-semibold text-foreground uppercase tracking-widest">{t('title')}</span>
          {activeCount > 0 && (
            <span className="inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
              {activeCount}
            </span>
          )}
        </div>
        {activeCount > 0 && (
          <button onClick={onClear} className="text-[11px] text-muted-foreground hover:text-foreground transition-colors font-medium">
            {t('clearAll')}
          </button>
        )}
      </div>

      <div className="p-4 space-y-5">
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t('statusLabel')}</label>
          <div className="flex flex-wrap gap-1.5">
            {statuses.map((s) => (
              <button
                key={s}
                onClick={() => setFilterStatus(s)}
                className={`px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${
                  filterStatus === s
                    ? "bg-primary text-primary-foreground border-primary"
                    : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"
                }`}
              >
                {s}
              </button>
            ))}
          </div>
        </div>

        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t('priceRangeLabel')}</label>
          <div className="flex items-center gap-2">
            <div className="relative flex-1">
              <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground text-xs">$</span>
              <Input
                type="number"
                placeholder={t('minPricePlaceholder')}
                value={minPrice}
                onChange={(e) => setMinPrice(e.target.value ? Number(e.target.value) : "")}
                className="pl-6"
              />
            </div>
            <span className="text-muted-foreground text-xs font-medium">—</span>
            <div className="relative flex-1">
              <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground text-xs">$</span>
              <Input
                type="number"
                placeholder={t('maxPricePlaceholder')}
                value={maxPrice}
                onChange={(e) => setMaxPrice(e.target.value ? Number(e.target.value) : "")}
                className="pl-6"
              />
            </div>
          </div>
        </div>

        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t('locationLabel')}</label>
          <div className="relative">
            <svg className="absolute left-2.5 top-1/2 -translate-y-1/2 w-3 h-3 text-muted-foreground" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
              <path strokeLinecap="round" strokeLinejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            <Input
              placeholder={t('locationPlaceholder')}
              value={city}
              onChange={(e) => setCity(e.target.value)}
              className="pl-7"
            />
          </div>
        </div>

        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t('dateSortLabel')}</label>
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

        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t('createdBetweenLabel')}</label>
          <div className="grid grid-cols-2 gap-2">
            <div className="space-y-1">
              <span className="text-[10px] text-muted-foreground">{t('dateAfter')}</span>
              <Input type="date" value={createdAfter} onChange={(e) => setCreatedAfter(e.target.value)} />
            </div>
            <div className="space-y-1">
              <span className="text-[10px] text-muted-foreground">{t('dateBefore')}</span>
              <Input type="date" value={createdBefore} onChange={(e) => setCreatedBefore(e.target.value)} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ---------------- PROPERTY DRAWER ---------------- */

function PropertyDrawer({
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
  const t = useTranslations('properties.drawer');
  const p = selectedProperty?.id === property.id ? selectedProperty : null;
  const [deleteLoading, setDeleteLoading] = useState(false);
  const [message, setMessage] = useState<string | null>(null);

  const { media, loading: mediaLoading, error: mediaError, fetchMedia, deleteMedia } = useMedia();

  const handleDelete = async () => {
    if (!p) {
      setMessage(t('errorNoProperty'));
      return;
    }

    setDeleteLoading(true);
    setMessage(null);

    try {
      await api.delete(`/admin/properties/${p.id}`);
      setMessage(t('successDelete'));
    } catch (err: any) {
      if (err?.response?.status === 404) {
        setMessage(t('errorNotFound'));
      } else {
        setMessage(t('errorDeleteFailed'));
      }
    } finally {
      setDeleteLoading(false);
    }
  };

  return (
    <Drawer
      direction="right"
      onOpenChange={(open) => { if (open) { fetchDetail(property.id); fetchMedia(property.id); } }}
    >
      <DrawerTrigger asChild>
        <Button variant="ghost" size="icon"><FaEye /></Button>
      </DrawerTrigger>

      <DrawerContent className="flex flex-col max-w-lg ml-auto h-full">
        <DrawerHeader className="border-b pb-4">
          <DrawerTitle className="text-base font-semibold">{t('title')}</DrawerTitle>
          <DrawerDescription className="text-xs text-muted-foreground">{t('description')}</DrawerDescription>
        </DrawerHeader>

        <div className="flex-1 overflow-y-auto p-5 space-y-6">
          {loadingDetail && !p ? (
            <p className="text-sm text-muted-foreground">{t('loading')}</p>
          ) : p ? (
            <>
              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('sectionListing')}</p>
                <InfoRow label={t('labelTitle')} value={p.title} />
                <InfoRow label={t('labelStatus')} value={<Badge variant={p.status === "AVAILABLE" ? "default" : p.status === "SUSPENDED" ? "destructive" : "secondary"}>{p.status}</Badge>} />
                <div className="grid grid-cols-2 gap-3">
                  <InfoRow label={t('labelListingType')} value={p.listingType ?? "—"} />
                  <InfoRow label={t('labelPropertyType')} value={p.propertyType ?? "—"} />
                </div>
                <InfoRow label={t('labelPrice')} value={p.price ? `${p.price.toLocaleString()} ${p.currency}` : "—"} />
                <InfoRow label={t('labelBoosted')} value={p.isBoosted ? t('yes') : t('no')} />
              </section>

              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('sectionLocation')}</p>
                <InfoRow label={t('labelAddress')} value={p.address} />
                <div className="grid grid-cols-2 gap-3">
                  <InfoRow label={t('labelLat')} value={p.latitude ?? "—"} mono />
                  <InfoRow label={t('labelLng')} value={p.longitude ?? "—"} mono />
                </div>
              </section>

              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('sectionDescription')}</p>
                <p className="text-sm text-foreground leading-relaxed">{p.description || "—"}</p>
              </section>

              {p.apartment && (
                <section className="space-y-4">
                  <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('sectionApartment')}</p>
                  <div className="grid grid-cols-2 gap-3">
                    <InfoRow label={t('labelBedrooms')} value={p.apartment.bedrooms} />
                    <InfoRow label={t('labelBathrooms')} value={p.apartment.bathrooms} />
                    <InfoRow label={t('labelFloor')} value={p.apartment.floor} />
                    <InfoRow label={t('labelElevator')} value={p.apartment.hasElevator ? t('yes') : t('no')} />
                  </div>
                </section>
              )}

              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('sectionSeller')}</p>
                <InfoRow label={t('labelSellerName')} value={p.sellerName} />
              </section>

              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('sectionTimestamps')}</p>
                <div className="grid grid-cols-2 gap-3">
                  <InfoRow label={t('labelCreatedAt')} value={fmtFull(p.createdAt)} />
                  <InfoRow label={t('labelUpdatedAt')} value={fmtFull(p.updatedAt)} />
                </div>
              </section>

              <section className="space-y-4">
                <p className="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground border-b pb-1">{t('sectionMedia')}</p>
                {mediaLoading ? (
                  <p className="text-sm text-muted-foreground">{t('loadingMedia')}</p>
                ) : mediaError ? (
                  <p className="text-sm text-destructive">{mediaError}</p>
                ) : media.length === 0 ? (
                  <p className="text-sm text-muted-foreground">{t('noMedia')}</p>
                ) : (
                  <div className="grid grid-cols-2 gap-3">
                    {media.map((m) => (
                      <div key={m.id} className="relative group">
                        {m.type === 'video' ? (
                          <video
                            src={m.url}
                            controls
                            className="w-full h-24 object-cover rounded-md border"
                          />
                        ) : (
                          <img
                            src={m.url}
                            alt="Property media"
                            className="w-full h-24 object-cover rounded-md border"
                          />
                        )}
                        <button
                          onClick={() => deleteMedia(m.id)}
                          className="absolute top-1 right-1 bg-red-500 text-white text-xs px-1 py-0.5 rounded opacity-0 group-hover:opacity-100 transition-opacity"
                        >
                          ✕
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </section>
            </>
          ) : (
            <p className="text-sm text-muted-foreground">{t('noDetails')}</p>
          )}
        </div>

        {message && (
          <div className="px-5 pb-2">
            <p className="text-sm text-center text-muted-foreground">{message}</p>
          </div>
        )}

        <DrawerFooter className="border-t flex flex-col gap-2">
          <Button
            variant="destructive"
            className="w-full"
            onClick={handleDelete}
            disabled={deleteLoading}
          >
            {deleteLoading ? t('btnDeleting') : t('btnDelete')}
          </Button>

          <DrawerClose asChild>
            <Button variant="outline" className="w-full">{t('btnClose')}</Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}

/* ---------------- BUILD COLUMNS ---------------- */

function buildColumns(
  selectedProperty: Property | null,
  loadingDetail: boolean,
  fetchDetail: (id: string) => void,
  t: any
): ColumnDef<Property>[] {
  return [
    { accessorKey: "title", header: t('colTitle'), cell: ({ row }) => row.original.title },
    { accessorKey: "address", header: t('colAddress'), cell: ({ row }) => row.original.address },
    { accessorKey: "price", header: t('colPrice'), cell: ({ row }) => `$${row.original.price.toLocaleString()} ${row.original.currency}` },
    { accessorKey: "createdAt", header: t('colDate'), cell: ({ row }) => fmt(row.original.createdAt) },
    { accessorKey: "sellerName", header: t('colSeller'), cell: ({ row }) => row.original.sellerName },
    {
      accessorKey: "status", header: t('colStatus'),
      cell: ({ row }) => (
        <Badge variant={row.original.status === "AVAILABLE" ? "default" : row.original.status === "SUSPENDED" ? "destructive" : "secondary"}>
          {row.original.status}
        </Badge>
      ),
    },
    {
      id: "seeMore", header: t('colActions'),
      cell: ({ row }) => (
        <PropertyDrawer
          property={row.original}
          fetchDetail={fetchDetail}
          selectedProperty={selectedProperty}
          loadingDetail={loadingDetail}
        />
      ),
    },
  ];
}

/* ---------------- MAIN PAGE ---------------- */

export default function Properties() {
  const t = useTranslations('properties');
  const {
    properties, loading, error,
    fetchPropertyDetail, selectedProperty, loadingDetail,
  } = useProperties();

  const [search, setSearch] = useState("");
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
  const [filterStatus, setFilterStatus] = useState<PropertyStatus | "ALL">("ALL");
  const [minPrice, setMinPrice] = useState<number | "">("");
  const [maxPrice, setMaxPrice] = useState<number | "">("");
  const [city, setCity] = useState("");
  const [createdAfter, setCreatedAfter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [dateSort, setDateSort] = useState<DateSort>("");
  const [filterOpen, setFilterOpen] = useState(false);

  const clearFilters = () => {
    setFilterStatus("ALL");
    setMinPrice("");
    setMaxPrice("");
    setCity("");
    setCreatedAfter("");
    setCreatedBefore("");
    setDateSort("");
  };

  const activeFilterCount = [
    filterStatus !== "ALL", minPrice !== "", maxPrice !== "",
    city !== "", createdAfter !== "", createdBefore !== "",
    dateSort !== "",
  ].filter(Boolean).length;

  const columns = useMemo(
    () => buildColumns(selectedProperty, loadingDetail, fetchPropertyDetail, t),
    [selectedProperty, loadingDetail, fetchPropertyDetail, t]
  );

  const filteredData = useMemo(() => {
    const filtered = properties.filter((p) => {
      const textMatch = [p.title, p.address, p.sellerName]
        .join(" ").toLowerCase().includes(search.toLowerCase());

      const statusMatch = filterStatus === "ALL" || p.status === filterStatus;

      const price = Number(p.price);
      const minPriceMatch = minPrice === "" || price >= Number(minPrice);
      const maxPriceMatch = maxPrice === "" || price <= Number(maxPrice);

      const cityMatch = city === "" || p.address.toLowerCase().includes(city.toLowerCase());

      const created = parseDate(p.createdAt)?.getTime() ?? null;
      const afterMatch = !createdAfter || (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());

      return textMatch && statusMatch && minPriceMatch && maxPriceMatch && cityMatch && afterMatch && beforeMatch;
    });

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
  }, [properties, search, filterStatus, minPrice, maxPrice, city, createdAfter, createdBefore, dateSort]);

  const table = useReactTable({
    data: filteredData,
    columns,
    state: { pagination },
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  if (loading) return <div className="p-8">{t('loadingMain')}</div>;
  if (error) return <div className="p-8 text-red-500">{error}</div>;

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">{t('pageTitle')}</h2>

      <div className="flex gap-2">
        <Input
          placeholder={t('searchPlaceholder')}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <Button
          variant="outline"
          onClick={() => setFilterOpen((v) => !v)}
          className="relative"
        >
          {t('filterButton')}
          {activeFilterCount > 0 && (
            <span className="absolute -top-1.5 -right-1.5 inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">
              {activeFilterCount}
            </span>
          )}
        </Button>
      </div>

      {filterOpen && (
        <FilterPanel
          filterStatus={filterStatus} setFilterStatus={setFilterStatus}
          minPrice={minPrice} setMinPrice={setMinPrice}
          maxPrice={maxPrice} setMaxPrice={setMaxPrice}
          city={city} setCity={setCity}
          createdAfter={createdAfter} setCreatedAfter={setCreatedAfter}
          createdBefore={createdBefore} setCreatedBefore={setCreatedBefore}
          dateSort={dateSort} setDateSort={setDateSort}
          onClear={clearFilters}
        />
      )}

      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader className="bg-primary text-white">
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
                  {t('noResults')}
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
    {t('pagination.prev')}
  </Button>

  <span>
    {t('pagination.pageInfo', { current: pagination.pageIndex + 1, total: Math.max(table.getPageCount(), 1) })}
  </span>

  <Button
    variant="outline"
    size="sm"
    onClick={() => table.nextPage()}
    disabled={!table.getCanNextPage()}
  >
    {t('pagination.next')}
  </Button>
</div>
    </div>
  );
}