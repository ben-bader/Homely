"use client";

import React from "react";
import { cn } from "@/lib/utils";

/* ── PageShell ── */
export function PageShell({
  className,
  children,
  ...props
}: React.ComponentProps<"main">) {
  return (
    <main
      className={cn("max-w-7xl mx-auto px-6 py-6", className)}
      {...props}
    >
      {children}
    </main>
  );
}

/* ── PageHeader ── */
export function PageHeader({
  eyebrow,
  title,
  description,
  actions,
  className,
  ...props
}: {
  eyebrow?: React.ReactNode;
  title: React.ReactNode;
  description?: React.ReactNode;
  actions?: React.ReactNode;
} & React.ComponentProps<"section">) {
  return (
    <section
      className={cn("flex flex-col sm:flex-row sm:items-center justify-between gap-4", className)}
      {...props}
    >
      <div>
        {eyebrow && (
          <p className="text-xs font-medium text-primary uppercase tracking-wider mb-1">
            {eyebrow}
          </p>
        )}
        <h1 className="text-2xl font-semibold text-foreground tracking-tight">
          {title}
        </h1>
        {description && (
          <p className="text-sm text-muted-foreground mt-1">{description}</p>
        )}
      </div>
      {actions && <div className="flex items-center gap-2 flex-shrink-0">{actions}</div>}
    </section>
  );
}

/* ── SectionHeader ── */
export function SectionHeader({
  title,
  description,
  actions,
  className,
  ...props
}: {
  title: React.ReactNode;
  description?: React.ReactNode;
  actions?: React.ReactNode;
} & React.ComponentProps<"div">) {
  return (
    <div
      className={cn("flex items-center justify-between", className)}
      {...props}
    >
      <div>
        <h3 className="text-base font-semibold text-foreground">{title}</h3>
        {description && (
          <p className="text-xs text-muted-foreground mt-0.5">{description}</p>
        )}
      </div>
      {actions && <div className="flex items-center gap-2">{actions}</div>}
    </div>
  );
}
