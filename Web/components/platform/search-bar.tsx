"use client";

import React from "react";
import { Search, SlidersHorizontal } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export function SearchBar({
  value,
  onChange,
  onFilterClick,
  filterCount,
  placeholder = "Search…",
  className,
  ...props
}: {
  value: string;
  onChange: (value: string) => void;
  onFilterClick?: () => void;
  filterCount?: number;
  placeholder?: string;
} & Omit<React.ComponentProps<"div">, "onChange">) {
  return (
    <div className={cn("flex items-center gap-2 flex-1", className)} {...props}>
      <div className="relative flex-1">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground pointer-events-none" />
        <input
          type="text"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          className="w-full h-9 pl-9 pr-3 text-sm bg-card border border-border rounded-lg outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary/50 placeholder:text-muted-foreground/60 transition-all"
        />
      </div>
      {onFilterClick && (
        <Button
          variant="outline"
          size="sm"
          onClick={onFilterClick}
          className="relative h-9 gap-1.5 text-xs font-medium flex-shrink-0"
        >
          <SlidersHorizontal className="w-3.5 h-3.5" />
          Filters
          {!!filterCount && filterCount > 0 && (
            <span className="flex items-center justify-center w-4.5 h-4.5 rounded-full bg-primary text-[10px] font-bold text-white ml-0.5">
              {filterCount}
            </span>
          )}
        </Button>
      )}
    </div>
  );
}
