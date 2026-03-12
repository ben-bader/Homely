import { useEffect, useState } from "react";
import { api } from "../lib/api";

export function useFeaturedCount() {
  const [count, setCount] = useState<number>(5);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchCount() {
      setLoading(true);
      setError(null);
      try {
        const res = await api.get("/featured-properties-setting");
        if (typeof res.data === "number") setCount(res.data);
        else if (res.data && typeof res.data.featuredCount === "number") setCount(res.data.featuredCount);
      } catch (err) {
        setError("Failed to load featured count");
      } finally {
        setLoading(false);
      }
    }
    fetchCount();
  }, []);

  return { count, loading, error };
}
