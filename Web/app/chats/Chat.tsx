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
import { PaginationFooter } from "@/components/ui/pagination";
import { FaRocketchat } from "react-icons/fa";
import { useTranslations } from "next-intl";
import { Conversation, ChatMessageResponse } from "@/types/chat-types";

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
      const res = await api.get<any>(`/chat/conversations/${conversation.id}/messages`, {
        params: { page: 0, size: 50 }
      });
      const newMessages = res.data.content || res.data;
      setMessages(Array.isArray(newMessages) ? newMessages : []);
      setConversations((prev) => prev.map((c) => (c.id === conversation.id ? { ...c, messages: newMessages } : c)));
    } catch (err) {
      console.error('Failed to fetch messages:', err);
    } finally { setLoading(false); }
  };

  return (
    <Drawer direction="right" onOpenChange={fetchMessages}>
      <DrawerTrigger asChild><Button variant="ghost" size="icon" className="text-primary hover:bg-primary/10 rounded-full h-10 w-10"><FaRocketchat size={20} /></Button></DrawerTrigger>
      <DrawerContent className="flex flex-col max-w-lg ml-auto h-full bg-subtle-background border-l-0 shadow-[-10px_0_40px_rgba(0,0,0,0.1)] rounded-l-[2rem] overflow-hidden">
        <DialogTitle className="hidden">Conversation</DialogTitle>
        
        {/* Chat Header */}
        <DrawerHeader className="border-b border-border/50 bg-background/80 backdrop-blur-md pb-4 pt-6 px-6 z-10 shadow-sm flex items-center gap-4">
          <div className="flex-1">
            <DrawerTitle className="text-xl font-extrabold tracking-tight text-foreground">{conversation.participantOneName} & {conversation.participantTwoName}</DrawerTitle>
            <DrawerDescription className="text-xs font-bold text-primary tracking-widest uppercase mt-1">{conversation.propertyTitle ?? "Direct Conversation"}</DrawerDescription>
          </div>
          <DrawerClose asChild>
            <Button variant="ghost" size="icon" className="rounded-full bg-muted/50 hover:bg-destructive/10 hover:text-destructive">✕</Button>
          </DrawerClose>
        </DrawerHeader>

        {/* Chat Body */}
        <div className="flex-1 overflow-y-auto px-6 py-6 space-y-6 bg-gradient-to-b from-subtle-background to-background custom-scrollbar">
          {loading ? <div className="flex justify-center items-center h-full"><span className="animate-pulse font-bold text-primary">{t('loadingMessages')}</span></div>
            : messages.length === 0 ? <p className="text-center text-sm text-muted-foreground py-8 italic font-medium">{t('noMessages')}</p>
            : messages.map((msg, idx) => {
              const isParticipantTwo = msg.senderId !== conversation.participantOneId;
              const showHeader = idx === 0 || messages[idx - 1].senderId !== msg.senderId;

              return (
                <div key={msg.id} className={`flex flex-col ${isParticipantTwo ? "items-end" : "items-start"} animate-in fade-in slide-in-from-bottom-2 duration-300`}>
                  {showHeader && (
                    <span className={`text-[11px] font-bold tracking-wider uppercase mb-1.5 px-2 ${isParticipantTwo ? "text-primary/70" : "text-muted-foreground"}`}>
                      {msg.senderName}
                    </span>
                  )}
                  <div className={`max-w-[80%] px-4 py-3 rounded-2xl text-sm leading-relaxed shadow-sm font-medium ${isParticipantTwo ? "bg-gradient-to-br from-primary to-primary-light text-primary-foreground rounded-tr-sm shadow-[0_4px_14px_0_rgba(14,165,233,0.2)]" : "bg-card text-card-foreground rounded-tl-sm border border-border/40"}`}>
                    {msg.body}
                  </div>
                  <span className="text-[10px] text-muted-foreground/60 mt-1.5 px-2 font-medium">{fmtFull(msg.sentAt)}</span>
                </div>
              );
            })}
          <div ref={bottomRef} />
        </div>

        {/* Fake Input Footer to look like Messenger */}
        <div className="p-4 bg-background border-t border-border/50">
          <div className="flex items-center gap-2 bg-subtle-background rounded-full px-4 py-2 border border-border/60 focus-within:border-primary focus-within:ring-2 focus-within:ring-primary/20 transition-all">
            <span className="text-muted-foreground/50 text-sm font-medium italic flex-1">Messaging is view-only...</span>
            <Button variant="ghost" size="icon" disabled className="rounded-full h-8 w-8 text-primary opacity-50"><FaRocketchat /></Button>
          </div>
        </div>
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
      const textMatch = [c.participantOneName, c.participantTwoName, c.propertyTitle ?? c.propertyId].filter(Boolean).join(" ").toLowerCase().includes(search.toLowerCase());
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
    { accessorKey: "participantOneName", header: t('table.participantOne'), cell: ({ row }) => <p className="text-sm font-medium">{row.original.participantOneName}</p> },
    { accessorKey: "participantTwoName", header: t('table.participantTwo'), cell: ({ row }) => <p className="text-sm font-medium">{row.original.participantTwoName}</p> },
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
          <svg className="w-3.5 h-3.5 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L13 13.414V19a1 1 0 01-.553.894l-4 2A1 1 0 017 21v-7.586L3.293 6.707A1 1 0 013 6V4z" />
          </svg>
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
      <PaginationFooter
        pageInfo={`${t('page')} ${pagination.pageIndex + 1} ${t('of')} ${Math.max(table.getPageCount(), 1)}`}
        onPrevious={() => table.previousPage()}
        onNext={() => table.nextPage()}
        canPrevious={table.getCanPreviousPage()}
        canNext={table.getCanNextPage()}
      />
    </div>
  );
}