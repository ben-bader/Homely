"use client";

import React, { useMemo, useRef, useEffect, useState } from "react";
import { useChats } from "@/hooks/useChats";
import { api } from "@/lib/api";
import { DialogTitle } from "@/components/ui/dialog";

import {
  useReactTable,
  getCoreRowModel,
  getPaginationRowModel,
  flexRender,
  type ColumnDef,
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
  DrawerTrigger,
  DrawerClose,
} from "@/components/ui/drawer";

import { Button } from "@/components/ui/button";

/* ---------------- TYPES ---------------- */

interface ChatMessageResponse {
  id: string;
  conversationId: string;
  senderId: string;
  senderName: string;
  body: string;
  createdAt: string;
}

interface Conversation {
  id: string;
  sellerName: string;
  sellerId: string;
  sellerActive: boolean;
  clientName: string;
  clientId: string;
  clientActive: boolean;
  propertyId: string;
  messages?: ChatMessageResponse[];
}

/* ---------------- CHAT DRAWER ---------------- */

function ChatDrawer({
  conversation,
  setConversations,
}: {
  conversation: Conversation;
  setConversations: React.Dispatch<React.SetStateAction<Conversation[]>>;
}) {
  const [messages, setMessages] = useState<ChatMessageResponse[]>([]);
  const [loading, setLoading] = useState(false);

  const bottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (messages.length > 0) {
      bottomRef.current?.scrollIntoView({ behavior: "smooth" });
    }
  }, [messages]);

  const fetchMessages = async (isOpen: boolean) => {
    if (!isOpen || messages.length > 0) return;

    try {
      setLoading(true);

      const res = await api.get<ChatMessageResponse[]>(
        `/chat/messages?conversationId=${conversation.id}`
      );

      const newMessages = res.data;

      setMessages(newMessages);

      setConversations((prev) =>
        prev.map((c) =>
          c.id === conversation.id ? { ...c, messages: newMessages } : c
        )
      );
    } finally {
      setLoading(false);
    }
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
  };

  return (
    <Drawer direction="right" onOpenChange={fetchMessages}>
      <DrawerTrigger asChild>
        <Button variant="outline">Show Conversation</Button>
      </DrawerTrigger>

      <DrawerContent className="flex flex-col h-full max-w-md ml-auto">
        <DialogTitle className="hidden">Conversation Drawer</DialogTitle>

        {/* Header */}
        <div className="px-4 py-3 border-b bg-white">
          <h2 className="text-base font-semibold">
            {conversation.sellerName} & {conversation.clientName}
          </h2>

          <p className="text-xs text-muted-foreground">
            Property: {conversation.propertyId}
          </p>
        </div>

        {/* COPY ID ACTIONS */}
        <div className="flex gap-2 px-4 py-2 border-b bg-gray-50">
          <Button
            size="sm"
            variant="outline"
            onClick={() => copyToClipboard(conversation.sellerId)}
          >
            Copy Seller ID
          </Button>

          <Button
            size="sm"
            variant="outline"
            onClick={() => copyToClipboard(conversation.clientId)}
          >
            Copy Client ID
          </Button>
        </div>

        {/* MESSAGES */}
        <div className="flex-1 overflow-y-auto px-4 py-4 space-y-2 bg-gray-100">
          {loading ? (
            <p className="text-center text-sm text-muted-foreground">
              Loading messages…
            </p>
          ) : messages.length === 0 ? (
            <p className="text-center text-sm text-muted-foreground">
              No messages yet
            </p>
          ) : (
            messages.map((msg) => {
              const isSeller = msg.senderId === conversation.sellerId;

              return (
                <div
                  key={msg.id}
                  className={`flex flex-col ${
                    isSeller ? "items-end" : "items-start"
                  }`}
                >
                  <span className="text-[10px] text-muted-foreground mb-0.5 px-1">
                    {msg.senderName}
                  </span>

                  <div
                    className={`max-w-[75%] px-3 py-2 rounded-2xl text-sm leading-snug shadow-sm ${
                      isSeller
                        ? "bg-[#3D5A80] text-white rounded-br-sm"
                        : "bg-white text-gray-900 rounded-bl-sm"
                    }`}
                  >
                    {msg.body}
                  </div>

                  <span className="text-[10px] text-muted-foreground mt-0.5 px-1">
                    {new Date(msg.createdAt).toLocaleString()}
                  </span>
                </div>
              );
            })
          )}

          <div ref={bottomRef} />
        </div>

        {/* FOOTER */}
        <div className="px-4 py-3 border-t bg-white">
          <DrawerClose asChild>
            <Button variant="outline" className="w-full">
              Close
            </Button>
          </DrawerClose>
        </div>
      </DrawerContent>
    </Drawer>
  );
}

/* ---------------- PAGE ---------------- */

export default function ChatPage() {
  const { conversations, loading, error, setConversations } = useChats();

  const [pagination, setPagination] = useState({
    pageIndex: 0,
    pageSize: 10,
  });

  const columns = useMemo<ColumnDef<Conversation>[]>(
    () => [
      { accessorKey: "sellerName", header: "Seller" },
      { accessorKey: "clientName", header: "Client" },
      { accessorKey: "propertyId", header: "Property ID" },
      {
        id: "actions",
        header: "Actions",
        cell: ({ row }) => (
          <ChatDrawer
            conversation={row.original}
            setConversations={setConversations}
          />
        ),
      },
    ],
    [setConversations]
  );

  const table = useReactTable({
    data: conversations,
    columns,
    state: { pagination },
    onPaginationChange: setPagination,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
  });

  if (loading) return <div>Loading conversations…</div>;
  if (error) return <div className="text-red-500">{error}</div>;

  return (
    <div className="px-8 space-y-6">
      <h2 className="text-xl font-semibold">Conversations</h2>

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
                    {flexRender(
                      cell.column.columnDef.cell,
                      cell.getContext()
                    )}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-between items-center">
        <Button
          variant="outline"
          onClick={() => table.previousPage()}
          disabled={!table.getCanPreviousPage()}
        >
          Previous
        </Button>

        <span>
          Page {pagination.pageIndex + 1} of {table.getPageCount() || 1}
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