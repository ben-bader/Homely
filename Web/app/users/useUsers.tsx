
import { useEffect, useState, useCallback } from "react";
import { api } from "@/lib/api";

export type User = {
  id: string;
  name: string;
  email: string;
  role: string;
  active: boolean;
  createdAt: string | number;
};

export function useUsers() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const fetchUsers = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      const res = await api.get<any[]>("/admin/users");

      const mapped = (res.data || []).map((u: any) => ({
        ...u,
        createdAt:
          u.createdAt ??
          u.created_at ??
          u.joinedAt ??
          u.joined_at ??
          u.CreateAt ??
          u.createdat ??
          u.CREATED_AT ??
          u.dateCreated ??
          u.date_created ??
          u.registeredAt ??
          u.registered_at ??
          u.timestamp ??
          u.createdDate ??
          u.created_date ??
          Object.values(u).find(
            (v) =>
              typeof v === "string" &&
              (v as string).match(/^\d{4}-\d{2}-\d{2}/)
          ) ??
          Object.values(u).find(
            (v) => typeof v === "number" && (v as number) > 1000000000
          ),
      }));

      setUsers(mapped);
    } catch (err: any) {
      setError(
        err?.response?.data?.message ||
          err.message ||
          "Failed to fetch users"
      );
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  return {
    users,
    loading,
    error,
    refresh: fetchUsers,
    setUsers,
  };
}