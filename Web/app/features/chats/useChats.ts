import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import { Conversation, ChatMessageResponse } from "@/types/chat-types";

export function useChats() {
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchConversations = async () => {
      try {
        setLoading(true);
        console.log("🔄 Fetching conversations from /admin/conversations...");
        const res = await api.get("/admin/conversations");
        console.log("✅ Conversations fetched:", res.data);
        setConversations(res.data);
      } catch (err: any) {
        const errorMsg = err.response?.data?.message || err.message || "Failed to fetch conversations";
        console.error("❌ Error fetching conversations:", {
          status: err.response?.status,
          message: errorMsg,
          data: err.response?.data,
        });
        setError(errorMsg);
      } finally {
        setLoading(false);
      }
    };

    fetchConversations();
  }, []);

  return { conversations, loading, error, setConversations };
}