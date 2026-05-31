"use client";

import React from "react";
import { ArrowUpRight, ArrowDownRight } from "lucide-react";
import { cn } from "@/lib/utils";

const ACCENT_STYLES: Record<string, { card: string; icon: string; text: string }> = {
  blue: { card: "bg-[#EEF4FF]", icon: "bg-white/70", text: "text-blue-700" },
  emerald: { card: "bg-[#ECFDF3]", icon: "bg-white/70", text: "text-emerald-700" },
  violet: { card: "bg-[#F4F3FF]", icon: "bg-white/70", text: "text-violet-700" },
  amber: { card: "bg-[#FFF7ED]", icon: "bg-white/70", text: "text-amber-700" },
  rose: { card: "bg-[#FFF1F3]", icon: "bg-white/70", text: "text-rose-700" },
  red: { card: "bg-[#FEF3F2]", icon: "bg-white/70", text: "text-red-700" },
  teal: { card: "bg-[#F0FDF9]", icon: "bg-white/70", text: "text-teal-700" },
  slate: { card: "bg-[#F8FAFC]", icon: "bg-white/70", text: "text-slate-700" },
};

export function MetricCard({
  label,
  value,
  detail,
  icon,
  trend,
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
  accent?: "blue" | "emerald" | "violet" | "amber" | "rose" | "red" | "teal" | "slate";
} & React.ComponentProps<"article">) {
  const colors = ACCENT_STYLES[accent] || ACCENT_STYLES.blue;

  return (
    <article
      className={cn(
        "rounded-lg border border-transparent p-5",
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
              "w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0 border border-white/70",
              colors.icon,
              colors.text
            )}
          >
            {icon}
          </div>
        )}
      </div>

      <div className="mt-2 flex items-end gap-2">
        <span className="text-3xl font-semibold text-foreground tracking-tight leading-none">
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
        <p className="text-xs text-muted-foreground mt-1.5">{detail}</p>
      )}
    </article>
  );
}
