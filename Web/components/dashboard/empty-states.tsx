"use client";

import React from "react";
import { cn } from "@/lib/utils";
import {
  Search,
  Inbox,
  FileText,
  Users,
  Building2,
  MessageSquare,
  AlertCircle,
  Plus,
  RefreshCw,
} from "lucide-react";
import { Button } from "@/components/ui/button";

type EmptyStateVariant = "default" | "search" | "users" | "properties" | "chats" | "reports" | "error";

type EmptyStateProps = {
  variant?: EmptyStateVariant;
  title?: string;
  description?: string;
  actionLabel?: string;
  onAction?: () => void;
  secondaryActionLabel?: string;
  onSecondaryAction?: () => void;
  className?: string;
};

const variantConfig = {
  default: {
    icon: Inbox,
    iconBg: "bg-muted/20",
    iconColor: "text-muted-foreground/40",
  },
  search: {
    icon: Search,
    iconBg: "bg-muted/20",
    iconColor: "text-muted-foreground/40",
  },
  users: {
    icon: Users,
    iconBg: "bg-blue-500/10",
    iconColor: "text-blue-500/40",
  },
  properties: {
    icon: Building2,
    iconBg: "bg-violet-500/10",
    iconColor: "text-violet-500/40",
  },
  chats: {
    icon: MessageSquare,
    iconBg: "bg-emerald-500/10",
    iconColor: "text-emerald-500/40",
  },
  reports: {
    icon: AlertCircle,
    iconBg: "bg-amber-500/10",
    iconColor: "text-amber-500/40",
  },
  error: {
    icon: AlertCircle,
    iconBg: "bg-red-500/10",
    iconColor: "text-red-500/40",
  },
};

const defaultMessages = {
  default: {
    title: "No data found",
    description: "There's nothing to display here yet.",
  },
  search: {
    title: "No results found",
    description: "Try adjusting your search or filters to find what you're looking for.",
  },
  users: {
    title: "No users yet",
    description: "Get started by inviting users to your platform.",
  },
  properties: {
    title: "No properties listed",
    description: "Properties will appear here once they're added to the platform.",
  },
  chats: {
    title: "No conversations",
    description: "Start a conversation to see it appear here.",
  },
  reports: {
    title: "No reports",
    description: "Great! There are no reports to review.",
  },
  error: {
    title: "Something went wrong",
    description: "An error occurred while loading this content.",
  },
};

export function EmptyState({
  variant = "default",
  title,
  description,
  actionLabel,
  onAction,
  secondaryActionLabel,
  onSecondaryAction,
  className,
}: EmptyStateProps) {
  const config = variantConfig[variant];
  const messages = defaultMessages[variant];
  const Icon = config.icon;

  return (
    <div className={cn("flex flex-col items-center justify-center py-16 px-4 text-center", className)}>
      {/* Icon */}
      <div className={cn("w-16 h-16 rounded-full flex items-center justify-center mb-4", config.iconBg)}>
        <Icon className={cn("w-7 h-7", config.iconColor)} />
      </div>

      {/* Content */}
      <h3 className="text-base font-semibold text-foreground mb-2">
        {title || messages.title}
      </h3>
      <p className="text-sm text-muted-foreground max-w-sm mb-6">
        {description || messages.description}
      </p>

      {/* Actions */}
      {(actionLabel || secondaryActionLabel) && (
        <div className="flex items-center gap-3">
          {actionLabel && onAction && (
            <Button onClick={onAction} size="sm" className="gap-2">
              <Plus className="w-4 h-4" />
              {actionLabel}
            </Button>
          )}
          {secondaryActionLabel && onSecondaryAction && (
            <Button
              variant="outline"
              size="sm"
              onClick={onSecondaryAction}
              className="gap-2"
            >
              <RefreshCw className="w-4 h-4" />
              {secondaryActionLabel}
            </Button>
          )}
        </div>
      )}
    </div>
  );
}

type EmptyCardProps = {
  title?: string;
  description?: string;
  className?: string;
};

export function EmptyCard({ title = "No data", description, className }: EmptyCardProps) {
  return (
    <div className={cn(
      "flex flex-col items-center justify-center p-8 rounded-xl border border-dashed border-border/50 bg-muted/20",
      className
    )}>
      <FileText className="w-8 h-8 text-muted-foreground/30 mb-3" />
      <p className="text-sm font-medium text-foreground mb-1">{title}</p>
      {description && (
        <p className="text-xs text-muted-foreground text-center">{description}</p>
      )}
    </div>
  );
}
