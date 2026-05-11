// components/ui/AddressMapPopover.tsx
"use client";

import { useState } from "react";
import { MapPin, X } from "lucide-react";

export function AddressMapPopover({ address }: { address: string }) {
  const [open, setOpen] = useState(false);
  const encoded = encodeURIComponent(address);

  return (
    <div className="relative">
      <button
        onClick={() => setOpen((v) => !v)}
        className="text-sm text-left hover:text-primary hover:underline underline-offset-2 transition-colors flex items-center gap-1 group"
      >
        <MapPin className="w-3 h-3 text-muted-foreground group-hover:text-primary transition-colors shrink-0" />
        {address}
      </button>

      {open && (
        <>
          <div className="fixed inset-0 z-40" onClick={() => setOpen(false)} />

          <div className="absolute z-50 top-full mt-2 left-0 w-72 rounded-xl border bg-background shadow-lg overflow-hidden">
            <div className="flex items-center justify-between px-3 py-2 border-b bg-muted/40">
              <div className="flex items-center gap-1.5">
                <MapPin className="w-3.5 h-3.5 text-muted-foreground" />
                <span className="text-xs font-medium text-foreground truncate max-w-[200px]">
                  {address}
                </span>
              </div>
              <button
                onClick={() => setOpen(false)}
                className="text-muted-foreground hover:text-foreground transition-colors"
              >
                <X className="w-3.5 h-3.5" />
              </button>
            </div>

            <iframe
              title="map"
              width="100%"
              height="200"
              style={{ border: 0 }}
              loading="lazy"
              allowFullScreen
              src={`https://maps.google.com/maps?q=${encoded}&output=embed&z=15`}
            />

            <div className="px-3 py-1.5 border-t bg-muted/20">
              
                href={`https://www.google.com/maps/search/?api=1&query=${encoded}`}
                target="_blank"
                rel="noopener noreferrer"
                className="text-[11px] text-primary hover:underline"
                <a>
                Open in Google Maps →
              </a>
            </div>
          </div>
        </>
      )}
    </div>
  );
}