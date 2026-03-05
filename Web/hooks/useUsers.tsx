import { useEffect, useState, useCallback } from "react";
import { api } from "@/lib/api";

export type User = {
  id: string;
  name: string;
  email: string;
  role: string;
  status: string;
};

export function useUsers() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const fetchUsers = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      const res = await api.get<User[]>("/admin/users");

      setUsers(res.data || []);
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