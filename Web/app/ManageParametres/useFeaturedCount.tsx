import { useEffect, useState } from "react";
import { api } from "../../lib/api";

export function useFeaturedCount() {
  const [count, setCount] = useState<number>(5);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [updating, setUpdating] = useState(false);
  const [updateError, setUpdateError] = useState<string | null>(null);

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

  const updateCount = async (newCount: number) => {
    setUpdating(true);
    setUpdateError(null);
    try {
      // controller expects count as request param
      const res = await api.post(
        "/featured-properties-setting",
        null,
        { params: { count: newCount } }
      );
      if (typeof res.data === "number") setCount(res.data);
      else if (res.data && typeof res.data.featuredCount === "number") setCount(res.data.featuredCount);
      return true;
    } catch (err) {
      console.error("Failed to update featured count", err);
      setUpdateError("Failed to save featured count");
      return false;
    } finally {
      setUpdating(false);
    }
  };

  return { count, loading, error, updating, updateError, updateCount };
}
