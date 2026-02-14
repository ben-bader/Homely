import React, { useEffect, useState } from "react";
import { api } from "@/lib/api";

type Property = {
  id: string;
  title: string;
  address?: string;
  price?: number;
  status?: string;
};

const Properties = () => {
  const [properties, setProperties] = useState<Property[]>([]);

  const fetchProperties = async () => {
    try {
      const res = await api.get<Property[]>("/admin/properties");
      setProperties(res.data || []);
    } catch (err) {
      console.error("Failed to load properties", err);
    }
  };

  useEffect(() => {
    fetchProperties();
  }, []);

  return (
    <div className="px-8">
      <h2 className="text-xl font-semibold mb-2">Properties</h2>
      <ul>
        {properties.map((p) => (
          <li key={p.id} className="py-2 border-b">
            <div className="font-medium">{p.title}</div>
            <div className="text-sm text-muted-foreground">{p.address} — {p.price} {p.status}</div>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default Properties;
