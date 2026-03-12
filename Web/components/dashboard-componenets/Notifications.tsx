// components/Notifications.tsx
"use client";

import React, { useState } from "react";
import { useNotifications } from "@/hooks/useNotifications";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";

export default function Notifications() {
  const { notifications, unreadCount, loading, error, markAsRead } =
    useNotifications();
  const [open, setOpen] = useState(false);

  if (loading) return <p>Loading notifications…</p>;
  if (error) return <p className="text-red-500">{error}</p>;

  return (
    <div className="relative">
      {/* Bell + unread count */}
      <Button
        variant="ghost"
        className="relative"
        onClick={() => setOpen(prev => !prev)}
      >
        🔔
        {unreadCount > 0 && (
          <Badge className="absolute -top-1 -right-1">{unreadCount}</Badge>
        )}
      </Button>

      {/* Dropdown */}
      {open && (
        <div className="absolute right-0 mt-2 w-80 max-h-96 overflow-y-auto rounded-lg border bg-background shadow-lg z-50">
          {notifications.length === 0 ? (
            <p className="p-4 text-sm text-muted-foreground">
              No notifications
            </p>
          ) : (
            <ul className="divide-y">
              {notifications.map(n => (
                <li
                  key={n.id}
                  className={`p-3 cursor-pointer hover:bg-muted ${
                    n.read ? "opacity-60" : "font-medium"
                  }`}
                  onClick={() => markAsRead(n.id)}
                >
                  <p className="text-sm">{n.title}</p>
                  <p className="text-xs text-muted-foreground truncate">
                    {n.message}
                  </p>
                  <p className="text-[10px] text-right text-muted-foreground">
                    {new Date(n.createdAt).toLocaleString()}
                  </p>
                </li>
              ))}
            </ul>
          )}
        </div>
      )}
    </div>
  );
}