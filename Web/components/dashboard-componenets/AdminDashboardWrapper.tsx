"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import {jwtDecode} from "jwt-decode";

interface JwtPayload {
  role: string;
  // other fields
}

export default function AdminDashboardWrapper({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [isAdminUser, setIsAdminUser] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem("jwt"); // or your cookie
    if (!token) {
      router.replace("/");
      return;
    }

    try {
      const decoded = jwtDecode<JwtPayload>(token);
      if (decoded.role !== "ADMIN") {
        router.replace("/");
        return;
      }
      setIsAdminUser(true);
    } catch (err) {
      console.error("Invalid JWT", err);
      router.replace("/");
    } finally {
      setLoading(false);
    }
  }, [router]);

  if (loading) return <p>Checking permissions...</p>;
  if (!isAdminUser) return null;
  
  return <>{children}</>; // render dashboard content
}
