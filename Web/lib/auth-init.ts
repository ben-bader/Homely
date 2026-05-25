/**
 * App initialization utility - runs on startup to validate auth state
 */

import { decodeAccessToken, isTokenExpired, clearAuthStorage } from './auth'

/**
 * Initialize app authentication state on startup
 * - Validates existing access token
 * - Clears expired or invalid tokens
 * - Removes legacy localStorage keys
 */
export function initializeAuthOnStartup(): void {
  // Only run in browser
  if (typeof window === 'undefined') return

  try {
    // Check if access token exists and is valid
    const accessToken = localStorage.getItem('access_token')

    if (!accessToken) {
      // No token - user needs to login
      clearAuthStorage()
      return
    }

    // Decode and validate token
    const payload = decodeAccessToken()

    if (!payload) {
      // Token is invalid or corrupted
      console.warn('Invalid or malformed access token - clearing auth state')
      clearAuthStorage()
      return
    }

    // Check if token is expired
    if (isTokenExpired(payload)) {
      console.warn('Access token expired - clearing auth state')
      clearAuthStorage()
      // In a real scenario, you'd attempt refresh here
      return
    }

    // Token is valid - clean up any legacy keys
    const legacyKeys = ['jwt', 'auth_user', 'permissions'] // Remove non-user-specific permissions
    legacyKeys.forEach(key => {
      const value = localStorage.getItem(key)
      if (value) {
        console.info(`Cleaning up legacy localStorage key: ${key}`)
        localStorage.removeItem(key)
      }
    })

    console.info('✅ Auth state restored successfully')
  } catch (error) {
    console.error('Error during auth initialization:', error)
    clearAuthStorage()
  }
}

/**
 * Migrate old auth state to new format if needed
 * Call this once on first app load to handle upgrades
 */
export function migrateOldAuthState(): void {
  if (typeof window === 'undefined') return

  try {
    // Check for legacy auth_user
    const legacyAuthUser = localStorage.getItem('auth_user')
    if (legacyAuthUser) {
      try {
        const parsed = JSON.parse(legacyAuthUser)
        // We don't need to migrate - just clear it
        localStorage.removeItem('auth_user')
        console.info('Migrated legacy auth_user key')
      } catch {
        localStorage.removeItem('auth_user')
      }
    }

    // Check for legacy jwt
    const legacyJwt = localStorage.getItem('jwt')
    if (legacyJwt) {
      // If no access_token exists, migrate jwt to access_token
      if (!localStorage.getItem('access_token')) {
        localStorage.setItem('access_token', legacyJwt)
      }
      localStorage.removeItem('jwt')
      console.info('Migrated legacy jwt key')
    }

    // Check for non-user-specific permissions
    const legacyPerms = localStorage.getItem('permissions')
    if (legacyPerms && !legacyPerms.startsWith('permissions_')) {
      localStorage.removeItem('permissions')
      console.info('Cleaned up legacy permissions key')
    }
  } catch (error) {
    console.error('Error during auth migration:', error)
  }
}
