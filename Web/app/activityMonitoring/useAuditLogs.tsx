"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";

/* ---------------- TYPES ---------------- */

export type AuditLog = {
  id: string;
  action: string;
  adminId?: string;
  adminName?: string;
  adminEmail?: string;
  details?: string;
  createdAt?: string;
};

export type LogActivity = {
  id: string;

  activityType?: string;
  entityType?: string;
  entityId?: string;

  description?: string;
  metadata?: string;
  changes?: string;

  userId?: string;
  userName?: string;
  userEmail?: string;

  adminId?: string;
  adminName?: string;
  adminEmail?: string;

  createdAt?: string;
};

/* ---------------- HOOKS ---------------- */

// Audit Logs
export function useAuditLogs() {
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    api
      .get<AuditLog[]>("/admin/audit-logs")
      .then((res) => setLogs(res.data))
      .catch(() => setError("Failed to load audit logs."))
      .finally(() => setLoading(false));
  }, []);

  return { logs, loading, error };
}

// Log Activities
export function useLogActivities() {
  const [activities, setActivities] = useState<LogActivity[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    api
      .get<LogActivity[]>("/admin/log-activities")
      .then((res) => setActivities(res.data))
      .catch(() => setError("Failed to load log activities."))
      .finally(() => setLoading(false));
  }, []);

  return { activities, loading, error };
}