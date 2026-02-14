import React, { useEffect, useState } from "react";
import { api } from "@/lib/api";

type Boost = {
  id: string;
  status?: string;
  amount?: number;
  property?: { id: string; title?: string };
};

const Boosts = () => {
  const [boosts, setBoosts] = useState<Boost[]>([]);

  const fetchBoosts = async () => {
    try {
      const res = await api.get<Boost[]>("/admin/boosts");
      setBoosts(res.data || []);
    } catch (err) {
      console.error("Failed to load boosts", err);
    }
  };

  useEffect(() => {
    fetchBoosts();
  }, []);

  return (
    <div className="px-8">
      <h2 className="text-xl font-semibold mb-2">Boosts</h2>
      <ul>
        {boosts.map((b) => (
          <li key={b.id} className="py-2 border-b">
            <div className="font-medium">{b.property?.title ?? b.id}</div>
            <div className="text-sm text-muted-foreground">{b.status} — {b.amount}</div>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default Boosts;
