"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";

const items = [
  { label: "Dashboard", path: "/dashboard"},
  { label: "Properties", path: "/dashboard/properties"},
  { label: "Users", path: "/dashboard/users"},
  { label: "Reports", path: "/dashboard/reports"},
  { label: "boosts", path: "/dashboard/boosts"},
];

export default function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 bg-white border-r flex flex-col min-h-screen">
      <div className="h-16 flex items-center justify-center font-bold text-lg border-b">
        Homely Admin
      </div>
      <nav className="flex-1 p-4 space-y-2">
        {items.map((item) => {
          const isActive = pathname === item.path;
          return (
            <Link
              key={item.label}
              href={item.path}
              className={cn(
                "flex items-center gap-2 p-2 rounded hover:bg-gray-100 transition-colors",
                isActive ? "bg-gray-200 font-semibold" : ""
              )}
            >
              {item.label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}