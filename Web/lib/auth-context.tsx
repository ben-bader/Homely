'use client'

import React, { createContext, useContext, useEffect, useState } from 'react'
import { getUserFromToken, isAdmin, isTokenExpired, AuthUser } from '@/lib/auth'

interface AuthContextType {
  user: AuthUser | null
  isLoading: boolean
  isAuthenticated: boolean
  hasRole: (role: string) => boolean
  isAdminUser: boolean
  refreshUser: () => void
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

/**
 * AuthProvider component
 * Wraps the app to provide centralized auth state
 * 
 * Usage:
 * - Wrap your app in <AuthProvider>
 * - Use const auth = useAuth() in components
 */
export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null)
  const [isLoading, setIsLoading] = useState(true)

  const loadUser = () => {
    const currentUser = getUserFromToken()
    setUser(currentUser)
    setIsLoading(false)
  }

  useEffect(() => {
    loadUser()
  }, [])

  const isAuthenticated = !!user
  const hasRole = (role: string) => user?.roles?.includes(role) ?? false
  const isAdminUser = hasRole('ROLE_ADMIN')

  const value: AuthContextType = {
    user,
    isLoading,
    isAuthenticated,
    hasRole,
    isAdminUser,
    refreshUser: loadUser,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

/**
 * Hook to use auth context
 * Must be called within a component wrapped by AuthProvider
 */
export function useAuth(): AuthContextType {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}

/**
 * Hook to check if user is admin
 */
export function useIsAdmin(): boolean {
  const auth = useAuth()
  return auth.isAdminUser
}

/**
 * Hook to check if user has a specific role
 */
export function useHasRole(role: string): boolean {
  const auth = useAuth()
  return auth.hasRole(role)
}
