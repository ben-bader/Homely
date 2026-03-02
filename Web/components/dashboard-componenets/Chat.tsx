"use client";

import React, { useEffect, useMemo, useState } from "react";
import {
  useReactTable,
  getCoreRowModel,
  getPaginationRowModel,
  flexRender,
  type ColumnDef,
} from "@tanstack/react-table";

import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
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

import { api } from "@/lib/api";

/* -----------------------------
   Types
----------------------------- */
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

/* -----------------------------
   Chat Drawer Component
----------------------------- */
function ChatDrawer({
  conversation,
  setConversations,
}: {
  conversation: Conversation;
  setConversations: React.Dispatch<React.SetStateAction<Conversation[]>>;
}) {
  const [messages, setMessages] = useState<ChatMessageResponse[]>([]);
  const [loading, setLoading] = useState(false);
  const [updatingUser, setUpdatingUser] = useState<string | null>(null);

  /* Fetch messages for this conversation */
  const fetchMessages = async (open: boolean) => {
    if (!open) return;
    if (messages.length > 0) return; // already loaded
    try {
      setLoading(true);
      const res = await api.get<ChatMessageResponse[]>(`/chat/messages?conversationId=${conversation.id}`);
      const newMessages = res.data;
      setMessages(newMessages);

      // Update conversation with messages
      setConversations((prev) =>
        prev.map((c) => (c.id === conversation.id ? { ...c, messages: newMessages } : c))
      );
    } finally {
      setLoading(false);
    }
  };

  /* Toggle user (seller/client) active status */
  const toggleUser = async (userId: string, active: boolean) => {
    try {
      setUpdatingUser(userId);
      if (active) {
        await api.put(`/admin/users/${userId}/deactivate`);
      } else {
        await api.put(`/admin/users/${userId}/activate`);
      }
      // Update local conversation state
      setConversations((prev) =>
        prev.map((c) => {
          if (c.id !== conversation.id) return c;
          return {
            ...c,
            sellerActive: c.sellerId === userId ? !active : c.sellerActive,
            clientActive: c.clientId === userId ? !active : c.clientActive,
          };
        })
      );
    } finally {
      setUpdatingUser(null);
    }
  };

  return (
    <Drawer direction="right" onOpenChange={fetchMessages}>
      <DrawerTrigger asChild>
        <Button variant="outline">Show Conversation</Button>
      </DrawerTrigger>

      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>Conversation</DrawerTitle>
          <DrawerDescription>
            Conversation about property ID {conversation.propertyId}
          </DrawerDescription>
        </DrawerHeader>

        {/* Users controls */}
        <div className="flex gap-4 px-4 pb-4">
          <div className="flex flex-col gap-1">
            <span className="font-semibold">{conversation.sellerName} (Seller)</span>
            <Button
              size="sm"
              variant="outline"
              onClick={() => toggleUser(conversation.sellerId, conversation.sellerActive)}
              disabled={updatingUser === conversation.sellerId}
            >
              {conversation.sellerActive ? "Deactivate" : "Activate"}
            </Button>
          </div>

          <div className="flex flex-col gap-1">
            <span className="font-semibold">{conversation.clientName} (Client)</span>
            <Button
              size="sm"
              variant="outline"
              onClick={() => toggleUser(conversation.clientId, conversation.clientActive)}
              disabled={updatingUser === conversation.clientId}
            >
              {conversation.clientActive ? "Deactivate" : "Activate"}
            </Button>
          </div>
        </div>

        {/* Messages */}
        <div className="flex flex-col gap-2 p-4 max-h-[60vh] overflow-y-auto border-t">
          {loading ? (
            <p>Loading messages…</p>
          ) : messages.length > 0 ? (
            messages.map((msg) => (
              <div key={msg.id} className="flex flex-col border-b pb-2">
                <span className="font-semibold">{msg.senderName}</span>
                <span>{msg.body}</span>
                <span className="text-xs text-muted-foreground">
                  {new Date(msg.createdAt).toLocaleString()}
                </span>
              </div>
            ))
          ) : (
            <p>No messages</p>
          )}
        </div>

        <div className="p-4 mt-auto border-t text-center text-sm text-muted-foreground">
          Conversation about property ID {conversation.propertyId}
        </div>

        <DrawerFooter>
          <DrawerClose asChild>
            <Button variant="outline">Close</Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}

/* -----------------------------
   Main Table Component
----------------------------- */
export default function Chat() {
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 10 });

  /* Fetch conversations */
  useEffect(() => {
    const fetchConversations = async () => {
      try {
        setLoading(true);
        const res = await api.get<Conversation[]>("/chat/conversations");
        setConversations(res.data);
      } catch (err: any) {
        setError(err.message || "Failed to fetch conversations");
      } finally {
        setLoading(false);
      }
    };
    fetchConversations();
  }, []);

  const columns = useMemo<ColumnDef<Conversation>[]>(
    () => [
      { accessorKey: "sellerName", header: "Seller" },
      { accessorKey: "clientName", header: "Client" },
      { accessorKey: "propertyId", header: "Property ID" },
      {
        id: "actions",
        header: "Actions",
        cell: ({ row }) => <ChatDrawer conversation={row.original} setConversations={setConversations} />,
      },
    ],
    []
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
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <TableHead key={header.id}>
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
                  <TableCell key={cell.id}>
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      <div className="flex justify-between items-center mt-4">
        <Button onClick={() => table.previousPage()} disabled={!table.getCanPreviousPage()}>
          Previous
        </Button>
        <span>
          Page {pagination.pageIndex + 1} of {table.getPageCount()}
        </span>
        <Button onClick={() => table.nextPage()} disabled={!table.getCanNextPage()}>
          Next
        </Button>
      </div>
    </div>
  );
}