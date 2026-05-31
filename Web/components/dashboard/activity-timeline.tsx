"use client";

import React from "react";
import { cn } from "@/lib/utils";
import {
  Building2,
  UserPlus,
  ShieldCheck,
  MessageSquare,
  Flag,
  Rocket,
  Activity,
  CheckCircle,
  XCircle,
  Clock,
} from "lucide-react";

export type ActivityItem = {
  id: string;
  type: "property" | "user" | "admin" | "chat" | "report" | "boost" | "system";
  title: string;
  description: string;
  timestamp: string;
  status?: "success" | "pending" | "error" | "info";
  metadata?: {
    entityName?: string;
    action?: string;
    userId?: string;
    userName?: string;
  };
};

type ActivityTimelineProps = {
  activities: ActivityItem[];
  loading?: boolean;
  emptyMessage?: string;
  maxItems?: number;
};

const activityIcons = {
  property: Building2,
  user: UserPlus,
  admin: ShieldCheck,
  chat: MessageSquare,
  report: Flag,
  boost: Rocket,
  system: Activity,
};

const statusColors = {
  success: "bg-emerald-500",
  pending: "bg-amber-500",
  error: "bg-red-500",
  info: "bg-blue-500",
};

const statusBgColors = {
  success: "bg-emerald-500/10",
  pending: "bg-amber-500/10",
  error: "bg-red-500/10",
  info: "bg-blue-500/10",
};

export function ActivityTimeline({
  activities,
  loading = false,
  emptyMessage = "No recent activity",
  maxItems = 10,
}: ActivityTimelineProps) {
  const displayActivities = activities.slice(0, maxItems);

  if (loading) {
    return (
      <div className="space-y-4">
        {[...Array(5)].map((_, i) => (
          <div key={i} className="flex gap-4 animate-pulse">
            <div className="w-10 h-10 rounded-full bg-muted/50 flex-shrink-0" />
            <div className="flex-1 space-y-2">
              <div className="h-4 bg-muted/50 rounded w-3/4" />
              <div className="h-3 bg-muted/50 rounded w-1/2" />
            </div>
          </div>
        ))}
      </div>
    );
  }

  if (displayActivities.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-12 text-center">
        <Activity className="w-12 h-12 text-muted-foreground/30 mb-4" />
        <p className="text-sm text-muted-foreground">{emptyMessage}</p>
      </div>
    );
  }

  return (
    <div className="space-y-0">
      {displayActivities.map((activity, index) => {
        const Icon = activityIcons[activity.type];
        const statusColor = activity.status ? statusColors[activity.status] : "bg-primary";
        const statusBgColor = activity.status ? statusBgColors[activity.status] : "bg-primary/10";

        return (
          <div
            key={activity.id}
            className={cn(
              "flex gap-4 pb-6 last:pb-0",
              index !== displayActivities.length - 1 && "relative"
            )}
          >
            {/* Timeline line */}
            {index !== displayActivities.length - 1 && (
              <div className="absolute left-5 top-10 w-0.5 h-full bg-border/50" />
            )}

            {/* Icon */}
            <div className={cn(
              "relative z-10 w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0",
              statusBgColor
            )}>
              <Icon className="w-4 h-4" style={{ color: `hsl(var(--${activity.status || 'primary'}))` }} />
              {activity.status === "pending" && (
                <span className="absolute top-0 right-0 w-2.5 h-2.5 rounded-full bg-amber-500 border-2 border-background" />
              )}
            </div>

            {/* Content */}
            <div className="flex-1 min-w-0 pt-1">
              <div className="flex items-start justify-between gap-2 mb-1">
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-semibold text-foreground truncate">{activity.title}</p>
                  <p className="text-xs text-muted-foreground mt-0.5 line-clamp-2">{activity.description}</p>
                </div>
                <div className="flex items-center gap-1.5 text-xs text-muted-foreground/70 flex-shrink-0">
                  <Clock className="w-3 h-3" />
                  <span>{formatTimestamp(activity.timestamp)}</span>
                </div>
              </div>

              {activity.metadata?.entityName && (
                <div className="mt-2">
                  <span className="inline-flex items-center gap-1.5 px-2 py-1 rounded-md bg-muted/50 border border-border/50 text-xs text-muted-foreground">
                    {activity.metadata.entityName}
                  </span>
                </div>
              )}

              {activity.status && (
                <div className="mt-2 flex items-center gap-2">
                  {activity.status === "success" && (
                    <span className="inline-flex items-center gap-1 text-xs text-emerald-600">
                      <CheckCircle className="w-3 h-3" />
                      Completed
                    </span>
                  )}
                  {activity.status === "pending" && (
                    <span className="inline-flex items-center gap-1 text-xs text-amber-600">
                      <Clock className="w-3 h-3" />
                      Pending
                    </span>
                  )}
                  {activity.status === "error" && (
                    <span className="inline-flex items-center gap-1 text-xs text-red-600">
                      <XCircle className="w-3 h-3" />
                      Failed
                    </span>
                  )}
                </div>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}

function formatTimestamp(timestamp: string): string {
  const date = new Date(timestamp);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMs / 3600000);
  const diffDays = Math.floor(diffMs / 86400000);

  if (diffMins < 1) return "Just now";
  if (diffMins < 60) return `${diffMins}m ago`;
  if (diffHours < 24) return `${diffHours}h ago`;
  if (diffDays < 7) return `${diffDays}d ago`;
  
  return date.toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
  });
}
