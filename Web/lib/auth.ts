export interface AuthUser {
  id: string
  name: string
  email: string
  roles: string[]
  emailVerified: boolean
  avatarUrl?: string | null
}

export function getUserFromToken(): AuthUser | null {
  if (globalThis.window === undefined) return null
  const stored = localStorage.getItem("auth_user")
  if (!stored) return null

  try {
    return JSON.parse(stored) as AuthUser
  } catch {
    localStorage.removeItem("auth_user")
    return null
  }
}

export function isAdmin(): boolean {
  const user = getUserFromToken()
  return user?.roles?.includes("ADMIN") ?? false
}
