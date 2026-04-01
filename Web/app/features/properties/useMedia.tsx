import { useState } from 'react';
import { api } from '@/lib/api';

export interface PropertyMedia {
  id: string;
  propertyId: string;
  url: string;
  type: string;
  // Add other fields as needed based on PropertyMediaDto
}

export function useMedia() {
  const [media, setMedia] = useState<PropertyMedia[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchMedia = async (propertyId: string) => {
    setLoading(true);
    setError(null);
    try {
      const response = await api.get(`/media/${propertyId}`);
      setMedia(response.data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch media');
    } finally {
      setLoading(false);
    }
  };

  const deleteMedia = async (id: string) => {
    try {
      await api.delete(`/media/${id}`);
      setMedia(prev => prev.filter(m => m.id !== id));
    } catch (err: any) {
      setError(err.message || 'Failed to delete media');
    }
  };

  return {
    media,
    loading,
    error,
    fetchMedia,
    deleteMedia,
  };
}