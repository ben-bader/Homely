"use client";

import * as React from "react";
import { ArrowLeft, ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";

interface PaginationFooterProps {
  pageInfo: string;
  onPrevious: () => void;
  onNext: () => void;
  canPrevious: boolean;
  canNext: boolean;
}

export function PaginationFooter({
  pageInfo,
  onPrevious,
  onNext,
  canPrevious,
  canNext,
}: PaginationFooterProps) {
  // Render compact pagination as "current/total" for all localized page info strings.
  const pageNumbers = pageInfo.match(/\d+/g);
  const compact = pageNumbers && pageNumbers.length >= 2
    ? `${pageNumbers[0]}/${pageNumbers[1]}`
    : pageInfo
        .replace(/^\s*page\s*/i, "")
        .replace(/\b(of|sur)\b/gi, "/")
        .replace(/\s*\/\s*/g, "/")
        .replace(/\s+/g, " ")
        .trim();

  return (
    <div className="flex items-center justify-center gap-3 mt-4 text-sm text-muted-foreground">
      <Button
        variant="ghost"
        size="icon"
        onClick={onPrevious}
        disabled={!canPrevious}
        className="h-8 w-8 text-muted-foreground hover:text-foreground disabled:opacity-40"
      >
        <ArrowLeft className="w-4 h-4" />
      </Button>

      <span className="select-none">{compact}</span>

      <Button
        variant="ghost"
        size="icon"
        onClick={onNext}
        disabled={!canNext}
        className="h-8 w-8 text-muted-foreground hover:text-foreground disabled:opacity-40"
      >
        <ArrowRight className="w-4 h-4" />
      </Button>
    </div>
  );
}
