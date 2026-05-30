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
  return (
    <div className="flex items-center justify-center gap-4 mt-4 px-4 py-2.5 bg-secondary/20 rounded-2xl border border-secondary-foreground/15 shadow-sm text-sm text-foreground w-fit mx-auto">
      <Button
        variant="outline"
        size="icon"
        onClick={onPrevious}
        disabled={!canPrevious}
        className="h-8 w-8 rounded-xl border-secondary-foreground/25 hover:bg-secondary-foreground/10 hover:text-secondary-foreground text-secondary-foreground font-bold transition-all disabled:opacity-40"
      >
        <ArrowLeft className="w-4 h-4" />
      </Button>

      <span className="font-extrabold text-sm text-secondary-foreground select-none">{pageInfo}</span>

      <Button
        variant="outline"
        size="icon"
        onClick={onNext}
        disabled={!canNext}
        className="h-8 w-8 rounded-xl border-secondary-foreground/25 hover:bg-secondary-foreground/10 hover:text-secondary-foreground text-secondary-foreground font-bold transition-all disabled:opacity-40"
      >
        <ArrowRight className="w-4 h-4" />
      </Button>
    </div>
  );
}
