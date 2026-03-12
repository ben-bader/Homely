// hooks/useNotifications.ts
"use client";

import { useState, useEffect, useCallback } from "react";
import { api } from "@/lib/api"; // axios or fetch wrapper

export type Notification = {
  id: string;
  title: string;
  message: string;
  read: boolean;
  createdAt: string;
};

export function useNotifications() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchNotifications = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await api.get<Notification[]>("/api/notifications");
      setNotifications(res.data);
      setUnreadCount(res.data.filter(n => !n.read).length);
    } catch (err: any) {
      console.error("Failed to fetch notifications", err);
      setError("Could not load notifications");
      setNotifications([]);
      setUnreadCount(0);
    } finally {
      setLoading(false);
    }
  }, []);

  const markAsRead = useCallback(async (id: string) => {
    try {
      await api.patch(`/api/notifications/${id}/read`);
      setNotifications(prev =>
        prev.map(n => (n.id === id ? { ...n, read: true } : n))
      );
      setUnreadCount(prev => Math.max(prev - 1, 0));
    } catch (err) {
      console.error("Failed to mark notification as read", err);
    }
  }, []);

  useEffect(() => {
    fetchNotifications();
  }, [fetchNotifications]);

  return { notifications, unreadCount, loading, error, markAsRead, fetchNotifications };
}