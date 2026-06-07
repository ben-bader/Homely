"use client";

import React from "react";
import { ArrowUpRight, ArrowDownRight } from "lucide-react";
import { cn } from "@/lib/utils";

const ACCENT_STYLES: Record<string, { card: string; icon: string; text: string; bar: string }> = {
  blue: { card: "border-blue-200 bg-blue-50/80", icon: "bg-blue-500 text-white shadow-blue-500/20", text: "text-blue-700", bar: "bg-blue-500" },
  emerald: { card: "border-emerald-200 bg-emerald-50/80", icon: "bg-emerald-500 text-white shadow-emerald-500/20", text: "text-emerald-700", bar: "bg-emerald-500" },
  violet: { card: "border-violet-200 bg-violet-50/80", icon: "bg-violet-500 text-white shadow-violet-500/20", text: "text-violet-700", bar: "bg-violet-500" },
  amber: { card: "border-amber-200 bg-amber-50/80", icon: "bg-amber-500 text-white shadow-amber-500/20", text: "text-amber-700", bar: "bg-amber-500" },
  rose: { card: "border-rose-200 bg-rose-50/80", icon: "bg-rose-500 text-white shadow-rose-500/20", text: "text-rose-700", bar: "bg-rose-500" },
  red: { card: "border-red-200 bg-red-50/80", icon: "bg-red-500 text-white shadow-red-500/20", text: "text-red-700", bar: "bg-red-500" },
  teal: { card: "border-teal-200 bg-teal-50/80", icon: "bg-teal-500 text-white shadow-teal-500/20", text: "text-teal-700", bar: "bg-teal-500" },
  slate: { card: "border-slate-200 bg-slate-50/90", icon: "bg-slate-700 text-white shadow-slate-700/20", text: "text-slate-700", bar: "bg-slate-600" },
};

export function MetricCard({
  label,
  value,
  detail,
  icon,
  trend,
  progress,
  accent = "blue",
  className,
  ...props
}: {
  label: React.ReactNode;
  value: React.ReactNode;
  detail?: React.ReactNode;
  icon?: React.ReactNode;
  trend?: {
    value: React.ReactNode;
    direction?: "up" | "down" | "neutral";
  };
  progress?: number;
  accent?: "blue" | "emerald" | "violet" | "amber" | "rose" | "red" | "teal" | "slate";
} & React.ComponentProps<"article">) {
  const colors = ACCENT_STYLES[accent] || ACCENT_STYLES.blue;

  return (
    <article
      className={cn(
        "relative overflow-hidden rounded-xl border p-5 shadow-sm transition-all hover:-translate-y-0.5 hover:shadow-md",
        colors.card,
        className
      )}
      {...props}
    >
      <div className="flex items-start justify-between">
        <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">
          {label}
        </p>
        {icon && (
          <div
            className={cn(
              "w-11 h-11 rounded-lg flex items-center justify-center flex-shrink-0 shadow-lg",
              colors.icon
            )}
          >
            {icon}
          </div>
        )}
      </div>

      <div className="mt-2 flex items-end gap-2">
        <span className={cn("text-3xl font-bold tracking-tight leading-none", colors.text)}>
          {value}
        </span>
        {trend && (
          <span
            className={cn(
              "inline-flex items-center gap-0.5 text-xs font-medium",
              trend.direction === "up" && "text-emerald-600",
              trend.direction === "down" && "text-rose-600",
              trend.direction === "neutral" && "text-muted-foreground"
            )}
          >
            {trend.direction === "up" && <ArrowUpRight className="w-3 h-3" />}
            {trend.direction === "down" && <ArrowDownRight className="w-3 h-3" />}
            {trend.value}
          </span>
        )}
      </div>

      {detail && (
        <p className="text-xs font-medium text-slate-600 mt-1.5">{detail}</p>
      )}

      {typeof progress === "number" && (
        <div className="mt-4 h-1.5 overflow-hidden rounded-full bg-white/80">
          <div
            className={cn("h-full rounded-full", colors.bar)}
            style={{ width: `${Math.min(100, Math.max(progress, progress > 0 ? 6 : 0))}%` }}
          />
        </div>
      )}
    </article>
  );
}
