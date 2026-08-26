"use client";

import React from "react";
import { cn } from "@/lib/utils";

export function AnalyticsCard({
  title,
  description,
  action,
  children,
  className,
  ...props
}: {
  title: React.ReactNode;
  description?: React.ReactNode;
  action?: React.ReactNode;
  children: React.ReactNode;
} & React.ComponentProps<"div">) {
  return (
    <div
      className={cn(
        "bg-card border border-border rounded-xl overflow-hidden",
        className
      )}
      {...props}
    >
      <div className="flex items-start justify-between px-5 pt-5 pb-1">
        <div>
          <h4 className="text-sm font-semibold text-foreground">{title}</h4>
          {description && (
            <p className="text-xs text-muted-foreground mt-0.5">{description}</p>
          )}
        </div>
        {action && <div className="flex-shrink-0 ml-4">{action}</div>}
      </div>
      <div className="p-5 pt-3">{children}</div>
    </div>
  );
}
