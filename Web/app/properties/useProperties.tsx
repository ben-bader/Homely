import { useState, useEffect, useCallback } from "react";
import { api, PaginatedResponse } from "@/lib/api";
import { Property, PropertyStatus } from "@/types/dashboard-types";

export function useProperties() {
  const [properties, setProperties] = useState<Property[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [selectedProperty, setSelectedProperty] = useState<Property | null>(null);

  // Pagination state
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize] = useState(30);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [hasMore, setHasMore] = useState(true);

  // Fetch properties paginated
  const fetchProperties = useCallback(async (page: number = 0) => {
    setLoading(true);
    setError(null);
    try {
      // Use public paginated endpoint - backend returns PageResponse<PropertyDto>
      const res = await api.get<PaginatedResponse<Property>>("/properties/paginated", {
        params: { page, pageSize },
      });
      
      // Replace or append based on page
      if (page === 0) {
        setProperties(res.data.content ?? []);
      } else {
        setProperties((prev) => [...prev, ...(res.data.content ?? [])]);
      }
      
      setCurrentPage(res.data.pageNumber);
      setTotalPages(res.data.totalPages);
      setTotalElements(res.data.totalElements);
      setHasMore(res.data.hasNext);
    } catch (err) {
      console.error("Failed to fetch properties", err);
      setError("Failed to load properties");
    } finally {
      setLoading(false);
    }
  }, [pageSize]);

  // Fetch single property detail from already loaded list (no extra API call)
  const fetchPropertyDetail = useCallback(
    (propertyId: string) => {
      const found = properties.find((p) => p.id === propertyId) ?? null;
      setSelectedProperty(found);
    },
    [properties]
  );

  // Load more properties (infinite scroll)
  const loadMore = useCallback(() => {
    if (hasMore && !loading) {
      fetchProperties(currentPage + 1);
    }
  }, [hasMore, loading, currentPage, fetchProperties]);

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

  // Initial fetch
  useEffect(() => {
    fetchProperties(0);
  }, [fetchProperties]);

  return {
    properties,
    loading,
    error,
    fetchProperties,
    selectedProperty,
    loadingDetail: false,
    errorDetail: null,
    fetchPropertyDetail,
    setSelectedProperty,
    updatePropertyStatus,
    // Pagination
    currentPage,
    pageSize,
    totalPages,
    totalElements,
    hasMore,
    loadMore,
  };
}
