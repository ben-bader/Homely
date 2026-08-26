"use client";

import React from "react";
import { cn } from "@/lib/utils";

type StatusTone = "success" | "warning" | "danger" | "info" | "violet" | "slate";

const TONE_STYLES: Record<StatusTone, { dot: string; bg: string; text: string }> = {
  success: { dot: "bg-emerald-500", bg: "bg-emerald-50", text: "text-emerald-700" },
  warning: { dot: "bg-amber-500", bg: "bg-amber-50", text: "text-amber-700" },
  danger: { dot: "bg-red-500", bg: "bg-red-50", text: "text-red-700" },
  info: { dot: "bg-blue-500", bg: "bg-blue-50", text: "text-blue-700" },
  violet: { dot: "bg-violet-500", bg: "bg-violet-50", text: "text-violet-700" },
  slate: { dot: "bg-slate-400", bg: "bg-slate-100", text: "text-slate-600" },
};

const STATUS_MAP: Record<string, StatusTone> = {
  ACTIVE: "success",
  APPROVED: "success",
  COMPLETED: "success",
  AVAILABLE: "success",
  CONFIRMED: "success",
  RESOLVED: "success",
  true: "success",
  PENDING: "warning",
  DRAFT: "warning",
  OPEN: "info",
  REVIEWED: "info",
  REJECTED: "danger",
  FAILED: "danger",
  DISMISSED: "danger",
  SUSPENDED: "danger",
  CANCELLED: "danger",
  false: "danger",
  INACTIVE: "danger",
};

export function StatusBadge({
  status,
  tone,
  className,
}: {
  status: string | boolean | null | undefined;
  tone?: StatusTone;
  className?: string;
}) {
  const statusStr = String(status ?? "").toUpperCase();
  const resolvedTone = tone || STATUS_MAP[statusStr] || "slate";
  const styles = TONE_STYLES[resolvedTone];
  const label = typeof status === "boolean"
    ? status ? "Active" : "Inactive"
    : String(status ?? "—");

  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium",
        styles.bg,
        styles.text,
        className
      )}
    >
      <span className={cn("w-1.5 h-1.5 rounded-full flex-shrink-0", styles.dot)} />
      {label}
    </span>
  );
}
