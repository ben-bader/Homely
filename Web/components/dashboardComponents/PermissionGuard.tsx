"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { getUserFromToken } from "@/lib/auth";

export default function PermissionGuard({
  permission,
  children,
}: {
  permission: string;
  children: React.ReactNode;
}) {
  const router = useRouter();
  const [allowed, setAllowed] = useState<boolean | null>(null);

  useEffect(() => {
    const user = getUserFromToken();

    if (!user) {
      router.replace("/");
      return;
    }

    const stored = localStorage.getItem(`permissions_${user.id}`);

    if (!stored) {
      setAllowed(false);
      return;
    }

    const perms = JSON.parse(stored);

    if (!perms[permission]) {
      router.replace("/dashboard");
    } else {
      setAllowed(true);
    }
  }, [permission, router]);

  // ⏳ prevent flicker
  if (allowed === null) {
    return <div className="p-4 text-sm">Checking permissions...</div>;
  }

  // ❌ blocked
  if (!allowed) return null;

  // ✅ allowed
  return <>{children}</>;
}