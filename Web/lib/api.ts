import axios from "axios";

export const api = axios.create({
  baseURL: "https://elegant-jasiah-speedfully.ngrok-free.dev/api",
  withCredentials: true,
  headers: {
    "ngrok-skip-browser-warning": "true", 
  },
});


api.interceptors.request.use((config) => {
  const accessToken = localStorage.getItem("access_token") || localStorage.getItem("jwt");

  if (accessToken) {
    config.headers.Authorization = `Bearer ${accessToken}`;
  }
  
  console.log("📤 Sending request to:", config.baseURL + config.url);
  return config;
}, (error) => {
  console.error("❌ Request error:", error);
  return Promise.reject(error);
});

api.interceptors.response.use((response) => {
  console.log("📥 Response from:", response.config.url, response.data);
  return response;
}, async (error) => {
  const originalRequest = error.config;
  if (error.response?.status === 401 && !originalRequest._retry) {
    originalRequest._retry = true;
    const refreshToken = localStorage.getItem("refresh_token");
    if (refreshToken) {
      try {
        const refreshResponse = await api.post("/auth/refresh", { refreshToken });
        const newAccessToken = refreshResponse.data.accessToken;
        const newRefreshToken = refreshResponse.data.refreshToken;
        localStorage.setItem("access_token", newAccessToken);
        localStorage.setItem("jwt", newAccessToken);
        if (newRefreshToken) {
          localStorage.setItem("refresh_token", newRefreshToken);
        }
        originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;
        return api(originalRequest);
      } catch (refreshError) {
        console.warn("Refresh failed", refreshError);
        localStorage.removeItem("access_token");
        localStorage.removeItem("refresh_token");
        localStorage.removeItem("jwt");
        localStorage.removeItem("auth_user");
      }
    }
  }
  console.error("❌ Response error:", error.response?.status, error.response?.data || error.message);
  throw error;
});

/**
 * Pagination type for API responses
 */
export interface PaginatedResponse<T> {
  content: T[];
  pageNumber: number;
  pageSize: number;
  totalElements: number;
  totalPages: number;
  isFirst: boolean;
  isLast: boolean;
  hasNext: boolean;
  hasPrevious: boolean;
}
