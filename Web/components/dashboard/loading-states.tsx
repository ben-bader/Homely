"use client";

import React from "react";
import { cn } from "@/lib/utils";
import { Skeleton } from "@/components/ui/skeleton";

type LoadingCardProps = {
  className?: string;
  variant?: "card" | "list" | "metric";
};

export function LoadingCard({ className, variant = "card" }: LoadingCardProps) {
  if (variant === "metric") {
    return (
      <div className={cn("p-4 rounded-xl border border-border/50 bg-muted/30", className)}>
        <Skeleton className="h-4 w-24 mb-3" />
        <Skeleton className="h-8 w-20 mb-2" />
        <Skeleton className="h-3 w-32" />
      </div>
    );
  }

  if (variant === "list") {
    return (
      <div className={cn("flex items-center gap-4 p-4", className)}>
        <Skeleton className="w-10 h-10 rounded-full flex-shrink-0" />
        <div className="flex-1 space-y-2">
          <Skeleton className="h-4 w-3/4" />
          <Skeleton className="h-3 w-1/2" />
        </div>
      </div>
    );
  }

  return (
    <div className={cn("p-4 rounded-xl border border-border/50 bg-muted/30", className)}>
      <Skeleton className="h-4 w-28 mb-3" />
      <Skeleton className="h-8 w-20 mb-2" />
      <Skeleton className="h-3 w-36" />
    </div>
  );
}

type LoadingGridProps = {
  count?: number;
  className?: string;
  variant?: "card" | "metric" | "list";
};

export function LoadingGrid({ count = 4, className, variant = "card" }: LoadingGridProps) {
  return (
    <div className={cn("grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4", className)}>
      {[...Array(count)].map((_, i) => (
        <LoadingCard key={i} variant={variant} />
      ))}
    </div>
  );
}

type LoadingTableProps = {
  rows?: number;
  columns?: number;
  className?: string;
};

export function LoadingTable({ rows = 5, columns = 4, className }: LoadingTableProps) {
  return (
    <div className={cn("space-y-3", className)}>
      {[...Array(rows)].map((_, i) => (
        <div key={i} className="flex items-center gap-4 p-4 bg-muted/30 rounded-lg animate-pulse">
          {[...Array(columns)].map((_, j) => (
            <div key={j} className="flex-1 space-y-2">
              <Skeleton className="h-4 w-full" />
              <Skeleton className="h-3 w-2/3" />
            </div>
          ))}
        </div>
      ))}
    </div>
  );
}

type PageLoadingProps = {
  message?: string;
};

export function PageLoading({ message = "Loading..." }: PageLoadingProps) {
  return (
    <div className="flex flex-col items-center justify-center min-h-[400px] gap-4">
      <div className="relative">
        <div className="w-12 h-12 rounded-full border-4 border-primary/20 border-t-primary animate-spin" />
      </div>
      <p className="text-sm text-muted-foreground">{message}</p>
    </div>
  );
}
