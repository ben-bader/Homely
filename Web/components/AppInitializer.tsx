'use client'

import { useEffect } from 'react'
import { initializeAuthOnStartup, migrateOldAuthState } from '@/lib/auth-init'

/**
 * App initialization component
 * Runs auth validation on app startup
 * Should wrap the entire app in layout.tsx
 */
export function AppInitializer() {
  useEffect(() => {
    // Run once on app load
    migrateOldAuthState()
    initializeAuthOnStartup()
  }, [])

  return null // This component doesn't render anything
}
