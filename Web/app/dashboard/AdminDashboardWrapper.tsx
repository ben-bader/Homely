"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { getUserFromToken, isAdmin } from "@/lib/auth";

export default function AdminDashboardWrapper({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const checkUser = () => {
      const user = getUserFromToken();

      // ❌ not logged in or not admin
      if (!user || !isAdmin()) {
        router.replace("/");
        return;
      }

      // ✅ load permissions (global system you're currently using)
const stored = user
  ? localStorage.getItem(`permissions_${user.id}`)
  : null;

      if (!stored) {
        // fallback default permissions
        const defaultPerms = {
          dashboard: true,
          users: true,
          properties: true,
          reports: true,
          boosts: true,
          visit_requests: true,
          activity_monitoring: true,
          chats: true,
          manage_parameters: true,
          manage_admins: true,
        };
        localStorage.setItem(`permissions_${user.id}`, JSON.stringify(defaultPerms));
        localStorage.setItem("permissions", JSON.stringify(defaultPerms));
      } else {
        localStorage.setItem("permissions", stored);
      }

      setLoading(false);
    };

    checkUser();
  }, [router]);

  if (loading) return <p>Checking permissions...</p>;

  return <>{children}</>;
}