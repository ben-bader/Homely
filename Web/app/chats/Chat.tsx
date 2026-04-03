"use client";

import React, { useMemo, useRef, useEffect, useState } from "react";
import { useChats } from "@/app/chats/useChats";
import { api } from "@/lib/api";
import { DialogTitle } from "@/components/ui/dialog";
import { useReactTable, getCoreRowModel, getPaginationRowModel, flexRender, type ColumnDef } from "@tanstack/react-table";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Drawer, DrawerContent, DrawerTrigger, DrawerClose, DrawerHeader, DrawerTitle, DrawerDescription, DrawerFooter } from "@/components/ui/drawer";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { FaRocketchat } from "react-icons/fa";
import { useTranslations } from "next-intl";

interface ChatMessageResponse { id: number; conversationId: string; senderId: string; senderName: string; body: string; sentAt: string; }
interface Conversation { id: string; sellerName: string; sellerId: string; sellerAvatar: string | null; clientName: string; clientId: string; clientAvatar: string | null; propertyId: string; propertyTitle?: string; lastMessage?: string; lastMessageAt?: string; unreadCount?: number; createdAt: string; updatedAt: string; messages?: ChatMessageResponse[]; }
type DateSort = "" | "newest" | "oldest";

function parseDate(v: string | null | undefined): Date | null { if (!v) return null; if (!v.endsWith("Z") && !v.includes("+")) return new Date(v + "Z"); return new Date(v); }
function fmt(v: string | null | undefined) { const d = parseDate(v); return d ? d.toLocaleDateString() : "—"; }
function fmtFull(v: string | null | undefined) { const d = parseDate(v); return d ? d.toLocaleString() : "—"; }

function InfoRow({ label, value }: { label: string; value: React.ReactNode }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[11px] uppercase tracking-widest text-muted-foreground">{label}</span>
      {typeof value === "string" || typeof value === "number" ? <span className="text-sm font-medium text-foreground">{value}</span> : <div className="mt-0.5">{value}</div>}
    </div>
  );
}

function FilterPanel({ createdAfter, setCreatedAfter, createdBefore, setCreatedBefore, dateSort, setDateSort, onClear }: any) {
  const t = useTranslations('chats.filters');
  const dateSortOptions = [{ value: "newest", label: t('newestFirst'), icon: "↓" }, { value: "oldest", label: t('oldestFirst'), icon: "↑" }];
  const activeCount = [createdAfter !== "", createdBefore !== "", dateSort !== ""].filter(Boolean).length;
  return (
    <div className="rounded-lg border bg-background shadow-sm overflow-hidden">
      <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/40">
        <div className="flex items-center gap-2">
          <span className="text-xs font-semibold text-foreground uppercase tracking-widest">{t('label')}</span>
          {activeCount > 0 && <span className="inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">{activeCount}</span>}
        </div>
        {activeCount > 0 && <button onClick={onClear} className="text-[11px] text-muted-foreground hover:text-foreground transition-colors font-medium">{t('clearAll')}</button>}
      </div>
      <div className="p-4 space-y-5">
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t('sortByDate')}</label>
          <div className="flex gap-1.5">
            {dateSortOptions.map(({ value, label, icon }) => (
              <button key={value} onClick={() => setDateSort(dateSort === value ? "" : value)} className={`flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-semibold border transition-all ${dateSort === value ? "bg-primary text-primary-foreground border-primary" : "bg-background border-border text-muted-foreground hover:text-foreground hover:border-foreground/30"}`}>
                <span>{icon}</span>{label}
              </button>
            ))}
          </div>
        </div>
        <div className="space-y-2">
          <label className="text-[10px] uppercase tracking-widest text-muted-foreground font-semibold">{t('startedBetween')}</label>
          <div className="grid grid-cols-2 gap-2">
            <div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t('after')}</span><Input type="date" value={createdAfter} onChange={(e) => setCreatedAfter(e.target.value)} /></div>
            <div className="space-y-1"><span className="text-[10px] text-muted-foreground">{t('before')}</span><Input type="date" value={createdBefore} onChange={(e) => setCreatedBefore(e.target.value)} /></div>
          </div>
        </div>
      </div>
    </div>
  );
}

function ChatDrawer({ conversation, setConversations }: { conversation: Conversation; setConversations: React.Dispatch<React.SetStateAction<Conversation[]>> }) {
  const t = useTranslations('chats.drawer');
  const [messages, setMessages] = useState<ChatMessageResponse[]>(conversation.messages ?? []);
  const [loading, setLoading] = useState(false);
  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => { if (messages.length > 0) bottomRef.current?.scrollIntoView({ behavior: "smooth" }); }, [messages]);

  const fetchMessages = async (isOpen: boolean) => {
    if (!isOpen || messages.length > 0) return;
    try {
      setLoading(true);
      const res = await api.get<ChatMessageResponse[]>(`/chat/messages?conversationId=${conversation.id}`);
      const newMessages = res.data;
      setMessages(newMessages);
      setConversations((prev) => prev.map((c) => (c.id === conversation.id ? { ...c, messages: newMessages } : c)));
    } finally { setLoading(false); }
  };

  return (
    <Drawer direction="right" onOpenChange={fetchMessages}>
      <DrawerTrigger asChild><Button variant="ghost" size="icon"><FaRocketchat /></Button></DrawerTrigger>
      <DrawerContent className="flex flex-col max-w-md ml-auto h-full">
        <DialogTitle className="hidden">Conversation Drawer</DialogTitle>
        <DrawerHeader className="border-b pb-4">
          <DrawerTitle className="text-base font-semibold">{t('title')}</DrawerTitle>
          <DrawerDescription className="text-xs text-muted-foreground">{conversation.sellerName} & {conversation.clientName}</DrawerDescription>
        </DrawerHeader>
        <div className="px-5 py-4 border-b space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <InfoRow label={t('seller')} value={conversation.sellerName} />
            <InfoRow label={t('client')} value={conversation.clientName} />
          </div>
          {conversation.propertyTitle && <InfoRow label={t('property')} value={conversation.propertyTitle} />}
        </div>
        <div className="flex-1 overflow-y-auto px-4 py-4 space-y-2 bg-muted/30">
          {loading ? <p className="text-center text-sm text-muted-foreground py-8">{t('loadingMessages')}</p>
            : messages.length === 0 ? <p className="text-center text-sm text-muted-foreground py-8">{t('noMessages')}</p>
            : messages.map((msg) => {
              const isSeller = msg.senderId === conversation.sellerId;
              return (
                <div key={msg.id} className={`flex flex-col ${isSeller ? "items-end" : "items-start"}`}>
                  <span className="text-[10px] text-muted-foreground mb-0.5 px-1">{msg.senderName}</span>
                  <div className={`max-w-[75%] px-3 py-2 rounded-2xl text-sm leading-snug shadow-sm ${isSeller ? "bg-primary text-primary-foreground rounded-br-sm" : "bg-background text-foreground rounded-bl-sm border"}`}>{msg.body}</div>
                  <span className="text-[10px] text-muted-foreground mt-0.5 px-1">{fmtFull(msg.sentAt)}</span>
                </div>
              );
            })}
          <div ref={bottomRef} />
        </div>
        <DrawerFooter className="border-t">
          <DrawerClose asChild><Button variant="outline" className="w-full">{t('close')}</Button></DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}

export default function ChatPage() {
  const t = useTranslations('chats');
  const { conversations, loading, error, setConversations } = useChats();
  const [search, setSearch] = useState("");
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });
  const [createdAfter, setCreatedAfter] = useState("");
  const [createdBefore, setCreatedBefore] = useState("");
  const [dateSort, setDateSort] = useState<DateSort>("");
  const [filterOpen, setFilterOpen] = useState(false);

  const clearFilters = () => { setCreatedAfter(""); setCreatedBefore(""); setDateSort(""); };
  const activeFilterCount = [createdAfter !== "", createdBefore !== "", dateSort !== ""].filter(Boolean).length;

  const filteredData = useMemo(() => {
    const filtered = conversations.filter((c) => {
      const textMatch = [c.sellerName, c.clientName, c.propertyTitle ?? c.propertyId].filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
      const created = parseDate(c.createdAt)?.getTime() ?? null;
      const afterMatch = !createdAfter || (created !== null && created >= new Date(createdAfter + "T00:00:00Z").getTime());
      const beforeMatch = !createdBefore || (created !== null && created <= new Date(createdBefore + "T23:59:59Z").getTime());
      return textMatch && afterMatch && beforeMatch;
    });
    if (dateSort === "newest") filtered.sort((a, b) => (parseDate(b.createdAt)?.getTime() ?? 0) - (parseDate(a.createdAt)?.getTime() ?? 0));
    else if (dateSort === "oldest") filtered.sort((a, b) => (parseDate(a.createdAt)?.getTime() ?? 0) - (parseDate(b.createdAt)?.getTime() ?? 0));
    return filtered;
  }, [conversations, search, createdAfter, createdBefore, dateSort]);

  const columns = useMemo<ColumnDef<Conversation>[]>(() => [
    { accessorKey: "sellerName", header: t('table.seller'), cell: ({ row }) => <p className="text-sm font-medium">{row.original.sellerName}</p> },
    { accessorKey: "clientName", header: t('table.client'), cell: ({ row }) => <p className="text-sm font-medium">{row.original.clientName}</p> },
    { accessorKey: "propertyTitle", header: t('table.property'), cell: ({ row }) => <p className="text-sm">{row.original.propertyTitle ?? "—"}</p> },
    { accessorKey: "createdAt", header: t('table.startedAt'), cell: ({ row }) => <p className="text-sm">{fmt(row.original.createdAt)}</p> },
    { id: "seeMore", header: "", cell: ({ row }) => <ChatDrawer conversation={row.original} setConversations={setConversations} /> },
  ], [setConversations, t]);

  const table = useReactTable({ data: filteredData, columns, state: { pagination }, onPaginationChange: setPagination, getCoreRowModel: getCoreRowModel(), getPaginationRowModel: getPaginationRowModel() });

  if (loading) return <div className="p-8">{t('loading')}</div>;
  if (error) return <div className="p-8 text-red-500">{error}</div>;

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">{t('title')}</h2>
      <div className="flex gap-2">
        <Input placeholder={t('searchPlaceholder')} value={search} onChange={(e) => setSearch(e.target.value)} />
        <Button variant="outline" onClick={() => setFilterOpen((v) => !v)} className="relative">
          {t('filter')}
          {activeFilterCount > 0 && <span className="absolute -top-1.5 -right-1.5 inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">{activeFilterCount}</span>}
        </Button>
      </div>
      {filterOpen && <FilterPanel createdAfter={createdAfter} setCreatedAfter={setCreatedAfter} createdBefore={createdBefore} setCreatedBefore={setCreatedBefore} dateSort={dateSort} setDateSort={setDateSort} onClear={clearFilters} />}
      <div><span className="text-xs text-muted-foreground">{filteredData.length !== 1 ? t('countPlural', { count: filteredData.length }) : t('count', { count: filteredData.length })}{(search || activeFilterCount > 0) && ` ${t('filtered')}`}</span></div>
      <div className="overflow-auto rounded-lg border">
        <Table>
          <TableHeader className="bg-primary text-white">
            {table.getHeaderGroups().map((hg) => <TableRow key={hg.id}>{hg.headers.map((header) => <TableHead key={header.id} className="text-white">{flexRender(header.column.columnDef.header, header.getContext())}</TableHead>)}</TableRow>)}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length === 0 ? <TableRow><TableCell colSpan={columns.length} className="text-center text-muted-foreground py-12 text-sm">{t('noMatch')}</TableCell></TableRow>
              : table.getRowModel().rows.map((row) => <TableRow key={row.id}>{row.getVisibleCells().map((cell) => <TableCell key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>)}</TableRow>)}
          </TableBody>
        </Table>
      </div>
      <div className="flex justify-center items-center gap-2 px-4 py-2 border-t text-sm text-muted-foreground">
        <Button variant="outline" size="sm" onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>{t('previous')}</Button>
        <span>{t('page')} {pagination.pageIndex + 1} {t('of')} {Math.max(table.getPageCount(), 1)}</span>
        <Button variant="outline" size="sm" onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>{t('next')}</Button>
      </div>
    </div>
  );
}