import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Conversation } from "@/types/chat-types";

export function useChats() {
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchConversations = async () => {
      try {
        setLoading(true);
        const res = await api.get<Conversation[]>("/admin/conversations");
        setConversations(res.data);
      } catch (err: any) {
        setError(err?.response?.data?.message || err.message || "Failed to fetch conversations");
      } finally {
        setLoading(false);
      }
    };

    fetchConversations();
  }, []);

  return { conversations, loading, error, setConversations };
}