import { useEffect, useState } from "react";
import api from "../lib/api";

export function useReportReasons() {
  const [reasons, setReasons] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchReasons() {
      setLoading(true);
      setError(null);
      try {
        const res = await api.get("/report-reasons");
        setReasons(Array.isArray(res.data) ? res.data.map(r => r.reason) : []);
      } catch (err) {
        setError("Failed to load reasons");
      } finally {
        setLoading(false);
      }
    }
    fetchReasons();
  }, []);

  return { reasons, loading, error };
}
