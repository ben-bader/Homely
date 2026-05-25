import axios from "axios"
import { clearAuthStorage } from "./auth"

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8080/api"

export const api = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true,
  headers: {
    "ngrok-skip-browser-warning": "true",
  },
})

api.interceptors.request.use(
  (config) => {
    if (typeof window === "undefined") return config
    const accessToken = localStorage.getItem("access_token")
    if (accessToken) {
      config.headers.Authorization = `Bearer ${accessToken}`
    }
    console.log("📤 Sending request to:", config.baseURL + config.url)
    return config
  },
  (error) => {
    console.error("❌ Request error:", error)
    return Promise.reject(error)
  }
)

api.interceptors.response.use(
  (response) => {
    console.log("📥 Response from:", response.config.url, response.data)
    return response
  },
  async (error) => {
    const originalRequest = error.config
    if (typeof window === "undefined") {
      throw error
    }

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true
      const refreshToken = localStorage.getItem("refresh_token")
      if (refreshToken) {
        try {
          const refreshResponse = await api.post("/auth/refresh", { refreshToken })
          const newAccessToken = refreshResponse.data.accessToken
          const newRefreshToken = refreshResponse.data.refreshToken
          if (newAccessToken) {
            localStorage.setItem("access_token", newAccessToken)
          }
          if (newRefreshToken) {
            localStorage.setItem("refresh_token", newRefreshToken)
          }
          originalRequest.headers.Authorization = `Bearer ${newAccessToken}`
          return api(originalRequest)
        } catch (refreshError) {
          console.warn("Refresh failed", refreshError)
          clearAuthStorage()
        }
      }
    }

    console.error("❌ Response error:", error.response?.status, error.response?.data || error.message)
    throw error
  }
)

/**
 * Pagination type for API responses
 */
export interface PaginatedResponse<T> {
  content: T[]
  pageNumber: number
  pageSize: number
  totalElements: number
  totalPages: number
  isFirst: boolean
  isLast: boolean
  hasNext: boolean
  hasPrevious: boolean
}

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
