// hooks/useVisitRequests.ts
"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { VisitRequest } from "@/types/dashboard-types";

interface UseVisitRequestsResult {
  visitRequests: VisitRequest[];
  loading: boolean;
  error: string | null;
}

export const useVisitRequests = (): UseVisitRequestsResult => {
  const [visitRequests, setVisitRequests] = useState<VisitRequest[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchVisitRequests = async () => {
      setLoading(true);
      setError(null);
      try {
        const { data } = await api.get<VisitRequest[]>("/admin/visit-requests");
        setVisitRequests(data);
      } catch (err: any) {
        console.error("Failed to fetch visit requests:", err);
        setError(err?.response?.data?.message || "Failed to fetch visit requests");
      } finally {
        setLoading(false);
      }
    };

    fetchVisitRequests();
  }, []);

  return { visitRequests, loading, error };
};
