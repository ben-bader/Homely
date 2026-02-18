import { useState, useEffect, useCallback } from "react";
import { api } from "@/lib/api";
import { Property, PropertyStatus } from "@/types/dashboard-types";

export function useProperties() {
  const [properties, setProperties] = useState<Property[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [selectedProperty, setSelectedProperty] = useState<Property | null>(null);

  // Fetch all properties
  const fetchProperties = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await api.get<Property[]>("/admin/properties");
      setProperties(res.data ?? []);
    } catch (err) {
      console.error("Failed to fetch properties", err);
      setError("Failed to load properties");
    } finally {
      setLoading(false);
    }
  }, []);

  // Fetch single property detail from already loaded list (no extra API call)
  const fetchPropertyDetail = useCallback(
    (propertyId: string) => {
      const found = properties.find((p) => p.id === propertyId) ?? null;
      setSelectedProperty(found);
    },
    [properties]
  );

  // Update property status (matches AdminController: PUT /admin/properties/{id}/status?status=...)
  const updatePropertyStatus = useCallback(
    async (propertyId: string, newStatus: PropertyStatus) => {
      try {
        await api.put(`/admin/properties/${propertyId}/status`, null, {
          params: { status: newStatus },
        });
        // Update list locally
        setProperties((prev) =>
          prev.map((p) => (p.id === propertyId ? { ...p, status: newStatus } : p))
        );
        // Update selected property if currently opened
        if (selectedProperty?.id === propertyId) {
          setSelectedProperty({ ...selectedProperty, status: newStatus });
        }
      } catch (err) {
        console.error("Failed to update property status", err);
        throw err;
      }
    },
    [selectedProperty]
  );

  useEffect(() => {
    fetchProperties();
  }, [fetchProperties]);

  return {
    properties,
    loading,
    error,
    fetchProperties,
    selectedProperty,
    // detail loading/error no longer needed since we derive from list
    loadingDetail: false,
    errorDetail: null,
    fetchPropertyDetail,
    setSelectedProperty,
    updatePropertyStatus,
  };
}
