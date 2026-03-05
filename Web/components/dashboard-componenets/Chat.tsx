"use client";

import React, { useMemo, useState } from "react";
import { useChats } from "@/hooks/useChats";

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

import { Button } from "@/components/ui/button";
import { Drawer, DrawerContent, DrawerTrigger } from "@/components/ui/drawer";
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
   Chat Drawer (unchanged)
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

  const fetchMessages = async (open: boolean) => {
    if (!open || messages.length > 0) return;

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

  const toggleUser = async (userId: string, active: boolean) => {
    try {
      setUpdatingUser(userId);

      if (active) {
        await api.put(`/admin/users/${userId}/deactivate`);
      } else {
        await api.put(`/admin/users/${userId}/activate`);
      }

      setConversations((prev) =>
        prev.map((c) => {
          if (c.id !== conversation.id) return c;

          return {
            ...c,
            sellerActive:
              c.sellerId === userId ? !active : c.sellerActive,
            clientActive:
              c.clientId === userId ? !active : c.clientActive,
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
        <div className="p-4 space-y-4">
          <h2 className="text-lg font-semibold">Conversation</h2>

          <div className="flex gap-4">
            <Button
              size="sm"
              variant="outline"
              onClick={() =>
                toggleUser(conversation.sellerId, conversation.sellerActive)
              }
            >
              {conversation.sellerActive ? "Deactivate Seller" : "Activate Seller"}
            </Button>

            <Button
              size="sm"
              variant="outline"
              onClick={() =>
                toggleUser(conversation.clientId, conversation.clientActive)
              }
            >
              {conversation.clientActive ? "Deactivate Client" : "Activate Client"}
            </Button>
          </div>

          <div className="max-h-[60vh] overflow-y-auto border-t pt-4">
            {loading ? (
              <p>Loading messages...</p>
            ) : messages.length > 0 ? (
              messages.map((msg) => (
                <div key={msg.id} className="border-b py-2">
                  <p className="font-semibold">{msg.senderName}</p>
                  <p>{msg.body}</p>
                  <p className="text-xs text-muted-foreground">
                    {new Date(msg.createdAt).toLocaleString()}
                  </p>
                </div>
              ))
            ) : (
              <p>No messages</p>
            )}
          </div>

          <Button variant="outline" className="w-full">
            Close
          </Button>
        </div>
      </DrawerContent>
    </Drawer>
  );
}

/* -----------------------------
   Page Component
----------------------------- */

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