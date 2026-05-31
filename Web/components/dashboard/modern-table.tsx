"use client";

import React from "react";
import { cn } from "@/lib/utils";
import {
  ChevronDown,
  ChevronUp,
  MoreHorizontal,
  Search,
  Filter,
  Download,
  RefreshCw,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Badge } from "@/components/ui/badge";

export type Column<T> = {
  id: string;
  header: string;
  accessor: (row: T) => React.ReactNode;
  sortable?: boolean;
  width?: string;
  align?: "left" | "center" | "right";
};

export type Action<T> = {
  label: string;
  onClick: (row: T) => void;
  icon?: React.ElementType;
  variant?: "default" | "destructive";
};

type ModernTableProps<T> = {
  data: T[];
  columns: Column<T>[];
  loading?: boolean;
  emptyMessage?: string;
  emptyDescription?: string;
  searchable?: boolean;
  onSearch?: (query: string) => void;
  actions?: Action<T>[];
  onRefresh?: () => void;
  onExport?: () => void;
  rowClassName?: (row: T) => string;
  getRowId?: (row: T) => string;
};

export function ModernTable<T>({
  data,
  columns,
  loading = false,
  emptyMessage = "No data found",
  emptyDescription,
  searchable = false,
  onSearch,
  actions,
  onRefresh,
  onExport,
  rowClassName,
  getRowId,
}: ModernTableProps<T>) {
  const [sortColumn, setSortColumn] = React.useState<string | null>(null);
  const [sortDirection, setSortDirection] = React.useState<"asc" | "desc">("asc");
  const [searchQuery, setSearchQuery] = React.useState("");

  const handleSort = (columnId: string) => {
    if (sortColumn === columnId) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortColumn(columnId);
      setSortDirection("asc");
    }
  };

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const query = e.target.value;
    setSearchQuery(query);
    if (onSearch) {
      onSearch(query);
    }
  };

  if (loading) {
    return (
      <div className="space-y-3">
        {[...Array(5)].map((_, i) => (
          <div key={i} className="flex items-center gap-4 p-4 bg-muted/30 rounded-lg animate-pulse">
            <div className="flex-1 space-y-2">
              <div className="h-4 bg-muted/50 rounded w-1/4" />
              <div className="h-3 bg-muted/50 rounded w-1/3" />
            </div>
            <div className="flex-1 space-y-2">
              <div className="h-4 bg-muted/50 rounded w-1/3" />
              <div className="h-3 bg-muted/50 rounded w-1/4" />
            </div>
            <div className="w-8 h-8 bg-muted/50 rounded-lg" />
          </div>
        ))}
      </div>
    );
  }

  if (data.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-16 text-center">
        <div className="w-16 h-16 rounded-full bg-muted/20 flex items-center justify-center mb-4">
          <Search className="w-6 h-6 text-muted-foreground/40" />
        </div>
        <p className="text-sm font-semibold text-foreground mb-1">{emptyMessage}</p>
        {emptyDescription && (
          <p className="text-xs text-muted-foreground max-w-sm">{emptyDescription}</p>
        )}
        {searchQuery && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {
              setSearchQuery("");
              if (onSearch) onSearch("");
            }}
            className="mt-4"
          >
            Clear search
          </Button>
        )}
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Table Header */}
      {(searchable || onRefresh || onExport) && (
        <div className="flex items-center justify-between gap-4">
          {searchable && (
            <div className="relative flex-1 max-w-sm">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground/50 pointer-events-none" />
              <Input
                type="text"
                placeholder="Search..."
                value={searchQuery}
                onChange={handleSearchChange}
                className="pl-9 h-9 text-sm bg-muted/50 border-border/80 focus:border-primary/30"
              />
            </div>
          )}
          <div className="flex items-center gap-2">
            {onRefresh && (
              <Button
                variant="ghost"
                size="icon"
                onClick={onRefresh}
                className="h-9 w-9 text-muted-foreground hover:text-foreground hover:bg-muted/50"
              >
                <RefreshCw className="w-4 h-4" />
              </Button>
            )}
            {onExport && (
              <Button
                variant="ghost"
                size="icon"
                onClick={onExport}
                className="h-9 w-9 text-muted-foreground hover:text-foreground hover:bg-muted/50"
              >
                <Download className="w-4 h-4" />
              </Button>
            )}
          </div>
        </div>
      )}

      {/* Table */}
      <div className="rounded-xl border border-border/50 bg-background overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-muted/30 border-b border-border/50">
              <tr>
                {columns.map((column) => (
                  <th
                    key={column.id}
                    className={cn(
                      "px-4 py-3 text-xs font-semibold uppercase tracking-wider text-muted-foreground/70 whitespace-nowrap",
                      column.align === "center" && "text-center",
                      column.align === "right" && "text-right",
                      column.sortable && "cursor-pointer hover:bg-muted/50 transition-colors group"
                    )}
                    style={{ width: column.width }}
                    onClick={() => column.sortable && handleSort(column.id)}
                  >
                    <div className="flex items-center gap-2">
                      {column.header}
                      {column.sortable && (
                        <div className="flex flex-col">
                          <ChevronUp
                            className={cn(
                              "w-3 h-3 transition-colors",
                              sortColumn === column.id && sortDirection === "asc"
                                ? "text-foreground"
                                : "text-muted-foreground/30 group-hover:text-muted-foreground/60"
                            )}
                          />
                          <ChevronDown
                            className={cn(
                              "w-3 h-3 -mt-2 transition-colors",
                              sortColumn === column.id && sortDirection === "desc"
                                ? "text-foreground"
                                : "text-muted-foreground/30 group-hover:text-muted-foreground/60"
                            )}
                          />
                        </div>
                      )}
                    </div>
                  </th>
                ))}
                {actions && actions.length > 0 && (
                  <th className="px-4 py-3 text-xs font-semibold uppercase tracking-wider text-muted-foreground/70 w-12">
                    Actions
                  </th>
                )}
              </tr>
            </thead>
            <tbody className="divide-y divide-border/30">
              {data.map((row, index) => {
                const rowId = getRowId ? getRowId(row) : index.toString();
                return (
                  <tr
                    key={rowId}
                    className={cn(
                      "hover:bg-muted/20 transition-colors group",
                      rowClassName && rowClassName(row)
                    )}
                  >
                    {columns.map((column) => (
                      <td
                        key={column.id}
                        className={cn(
                          "px-4 py-3 text-sm text-foreground whitespace-nowrap",
                          column.align === "center" && "text-center",
                          column.align === "right" && "text-right"
                        )}
                      >
                        {column.accessor(row)}
                      </td>
                    ))}
                    {actions && actions.length > 0 && (
                      <td className="px-4 py-3 text-right">
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button
                              variant="ghost"
                              size="icon"
                              className="h-8 w-8 text-muted-foreground hover:text-foreground hover:bg-muted/50 opacity-0 group-hover:opacity-100 transition-opacity"
                            >
                              <MoreHorizontal className="w-4 h-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end" className="w-32">
                            {actions.map((action, actionIndex) => (
                              <DropdownMenuItem
                                key={actionIndex}
                                onClick={() => action.onClick(row)}
                                className={cn(
                                  "text-xs cursor-pointer",
                                  action.variant === "destructive" && "text-destructive hover:text-destructive hover:bg-destructive/10"
                                )}
                              >
                                {action.icon && <action.icon className="w-3.5 h-3.5 mr-2" />}
                                {action.label}
                              </DropdownMenuItem>
                            ))}
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </td>
                    )}
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Table Footer */}
      <div className="flex items-center justify-between text-xs text-muted-foreground">
        <p>Showing {data.length} {data.length === 1 ? "result" : "results"}</p>
        {searchQuery && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {
              setSearchQuery("");
              if (onSearch) onSearch("");
            }}
            className="h-7 text-xs"
          >
            Clear search
          </Button>
        )}
      </div>
    </div>
  );
}
