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
      <DrawerTrigger asChild><Button variant="ghost" size="icon" className="h-8 w-8 text-primary hover:bg-primary/10"><FaRocketchat size={16} /></Button></DrawerTrigger>
      <DrawerContent className="flex flex-col max-w-lg ml-auto h-full bg-background border-l border-border rounded-l-lg overflow-hidden">
        <DialogTitle className="hidden">Conversation</DialogTitle>
        
        {/* Chat Header */}
        <DrawerHeader className="border-b border-border/50 bg-background/80 backdrop-blur-md py-4 px-6 z-10 shadow-sm flex items-center justify-between">
          <div className="flex-1">
            <DrawerTitle className="text-md tracking-tight text-foreground">
              {t('seller')}: {conversation.participantOneName} & {t('client')}: {conversation.participantTwoName}
            </DrawerTitle>
            <DrawerDescription className="text-xs text-primary tracking-widest uppercase mt-1">{conversation.propertyTitle ?? "Direct Conversation"}</DrawerDescription>
          </div>

        </DrawerHeader>

        {/* Chat Body */}
        <div className="flex-1 overflow-y-auto px-6 py-6 space-y-6 bg-background custom-scrollbar">
          {loading ? <div className="flex justify-center items-center h-full"><span className="animate-pulse font-bold text-primary">{t('loadingMessages')}</span></div>
            : messages.length === 0 ? <p className="text-center text-sm text-muted-foreground py-8 italic font-medium">{t('noMessages')}</p>
            : messages.map((msg, idx) => {
              const isParticipantTwo = msg.senderId !== conversation.participantOneId;
              const showHeader = idx === 0 || messages[idx - 1].senderId !== msg.senderId;

              return (
                <div key={msg.id} className={`flex flex-col ${isParticipantTwo ? "items-end" : "items-start"}`}>
                  {showHeader && (
                    <span className={`text-[11px] font-bold tracking-wider uppercase mb-1.5 px-2 ${isParticipantTwo ? "text-primary/70" : "text-muted-foreground"}`}>
                      {msg.senderName}
                    </span>
                  )}
                  <div className={`max-w-[80%] px-4 py-3 rounded-lg text-sm leading-relaxed font-medium ${isParticipantTwo ? "bg-primary text-primary-foreground rounded-tr-sm" : "bg-card text-card-foreground rounded-tl-sm border border-border"}`}>
                    {msg.body}
                  </div>
                  <span className="text-[10px] text-muted-foreground/60 mt-1.5 px-2 font-medium">{fmtFull(msg.sentAt)}</span>
                </div>
              );
            })}
          <div ref={bottomRef} />
        </div>

        {/* Fake Input Footer to look like Messenger */}
        <div className="flex items-center justify-center w-full p-2">

          <DrawerClose asChild>
            <Button variant="secondary"  className="rounded-lg w-full bg-red-500 hover:bg-destructive/90 text-white">Close</Button>
          </DrawerClose>
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
    { accessorKey: "participantOneName", header: t('table.seller'), cell: ({ row }) => <p className="text-sm font-medium">{row.original.participantOneName}</p> },
    { accessorKey: "participantTwoName", header: t('table.client'), cell: ({ row }) => <p className="text-sm font-medium">{row.original.participantTwoName}</p> },
    { accessorKey: "propertyTitle", header: t('table.property'), cell: ({ row }) => <p className="max-w-[320px] truncate text-sm text-muted-foreground">{row.original.propertyTitle ?? "-"}</p> },
    { accessorKey: "createdAt", header: t('table.startedAt'), cell: ({ row }) => <p className="text-sm">{fmt(row.original.createdAt)}</p> },
    { id: "seeMore", header: "", cell: ({ row }) => <ChatDrawer conversation={row.original} setConversations={setConversations} /> },
  ], [setConversations, t]);

  const table = useReactTable({ data: filteredData, columns, state: { pagination }, onPaginationChange: setPagination, getCoreRowModel: getCoreRowModel(), getPaginationRowModel: getPaginationRowModel() });

  if (loading) return <div className="p-8">{t('loading')}</div>;
  if (error) return <div className="p-8 text-red-500">{error}</div>;

  return (
    <div className="px-6 py-6 max-w-7xl mx-auto space-y-6 animate-fade-up">
      <h1 className="text-2xl font-semibold text-foreground">{t('title')}</h1>
      <div className="flex items-center gap-2">
        <Input placeholder={t('searchPlaceholder')} value={search} onChange={(e) => setSearch(e.target.value)} className="h-9" />
        <Button variant="outline" size="sm" onClick={() => setFilterOpen((v) => !v)} className="relative h-9 gap-1.5 text-xs font-medium">
          <svg className="w-3.5 h-3.5 mr-1.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
            <path strokeLinecap="round" strokeLinejoin="round" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2a1 1 0 01-.293.707L13 13.414V19a1 1 0 01-.553.894l-4 2A1 1 0 017 21v-7.586L3.293 6.707A1 1 0 013 6V4z" />
          </svg>
          {t('filter')}
          {activeFilterCount > 0 && <span className="absolute -top-1.5 -right-1.5 inline-flex items-center justify-center w-4 h-4 rounded-full bg-primary text-[10px] font-bold text-primary-foreground">{activeFilterCount}</span>}
        </Button>
      </div>
      {filterOpen && <FilterPanel createdAfter={createdAfter} setCreatedAfter={setCreatedAfter} createdBefore={createdBefore} setCreatedBefore={setCreatedBefore} dateSort={dateSort} setDateSort={setDateSort} onClear={clearFilters} />}
      <div><span className="text-xs text-muted-foreground">{filteredData.length !== 1 ? t('countPlural', { count: filteredData.length }) : t('count', { count: filteredData.length })}{(search || activeFilterCount > 0) && ` ${t('filtered')}`}</span></div>
      <div className="bg-card border rounded-xl overflow-hidden">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((hg) => (
              <TableRow key={hg.id}>
                {hg.headers.map((header) => (
                  <TableHead key={header.id} className="h-10 text-xs font-medium uppercase tracking-wider">
                    {flexRender(header.column.columnDef.header, header.getContext())}
                  </TableHead>
                ))}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows.length === 0 ? <TableRow><TableCell colSpan={columns.length} className="text-center text-muted-foreground py-12 text-sm">{t('noMatch')}</TableCell></TableRow>
              : table.getRowModel().rows.map((row) => (
                <TableRow key={row.id} className="hover:bg-muted/20 transition-colors">
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id} className="py-3">
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </TableCell>
                  ))}
                </TableRow>
              ))}
          </TableBody>
        </Table>
      </div>
      <div className="flex justify-between items-center">
          <span className="text-xs text-muted-foreground">{conversations.length } Conversations</span>
          
      <PaginationFooter
        pageInfo={`${t('page')} ${pagination.pageIndex + 1} ${t('of')} ${Math.max(table.getPageCount(), 1)}`}
        onPrevious={() => table.previousPage()}
        onNext={() => table.nextPage()}
        canPrevious={table.getCanPreviousPage()}
        canNext={table.getCanNextPage()}
      />
      </div>
    </div>
  );
}
