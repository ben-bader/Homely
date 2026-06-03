import axios from "axios"
import { clearAuthStorage } from "./auth"

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8083/api"

export const api = axios.create({
  baseURL: API_BASE_URL,
  withCredentials: true,
  headers: {
    "ngrok-skip-browser-warning": "true",
  },
})

// Request Interceptor: Attach Authorization Header
api.interceptors.request.use(
  (config) => {
    if (typeof window === "undefined") return config
    const accessToken = localStorage.getItem("access_token")
    if (accessToken && !config.headers.Authorization) {
      config.headers.Authorization = `Bearer ${accessToken}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response Interceptor: Handle Refresh Token Flow & Errors
api.interceptors.response.use(
  (response) => {
    return response
  },
  async (error) => {
    const originalRequest = error.config
    if (typeof window === "undefined") {
      throw error
    }

    // Handle 401 errors: Refresh token logic (skip if the failed request itself is the refresh endpoint)
    if (
      error.response?.status === 401 &&
      originalRequest &&
      !originalRequest._retry &&
      originalRequest.url !== "/auth/refresh"
    ) {
      originalRequest._retry = true
      const refreshToken = localStorage.getItem("refresh_token")
      if (refreshToken) {
        try {
          // Use axios directly or configure to bypass response interceptor on error for refresh call
          const refreshResponse = await axios.post(`${API_BASE_URL}/auth/refresh`, { refreshToken })
          const refreshPayload = refreshResponse.data?.data ?? refreshResponse.data
          const newAccessToken = refreshPayload?.accessToken
          const newRefreshToken = refreshPayload?.refreshToken

          if (newAccessToken) {
            localStorage.setItem("access_token", newAccessToken)
            originalRequest.headers.Authorization = `Bearer ${newAccessToken}`
          }
          if (newRefreshToken) {
            localStorage.setItem("refresh_token", newRefreshToken)
          }

          // Resend original request with new token
          return api(originalRequest)
        } catch (refreshError) {
          // Refresh token expired or invalid, log out the user
          clearAuthStorage()
          // Optionally redirect to login page
          if (window.location.pathname !== "/login") {
            window.location.href = "/login"
          }
        }
      }
    }

    // Graceful error logging (only for non-401/403 errors or actual failures)
    if (error.response?.status && error.response.status >= 500) {
      console.error(`❌ Server Error (500+) at ${originalRequest?.url}:`, error.message)
    }

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
