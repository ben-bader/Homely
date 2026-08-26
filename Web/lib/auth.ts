import {jwtDecode }from "jwt-decode"

export interface AuthUser {
  id?: string
  username: string
  roles: string[]
  name?: string
}

export interface AccessTokenPayload {
  sub: string
  userId: string
  roles: string[]
  exp: number
  iat?: number
  [key: string]: unknown
}

const ACCESS_TOKEN_KEY = "access_token"
const REFRESH_TOKEN_KEY = "refresh_token"
const LEGACY_KEYS = ["jwt", "auth_user"]

function getStorage(): Storage | null {
  if (typeof window === "undefined") return null
  return window.localStorage
}

export function getAccessToken(): string | null {
  const storage = getStorage()
  return storage?.getItem(ACCESS_TOKEN_KEY) ?? null
}

export function getRefreshToken(): string | null {
  const storage = getStorage()
  return storage?.getItem(REFRESH_TOKEN_KEY) ?? null
}

export function decodeAccessToken(): AccessTokenPayload | null {
  const token = getAccessToken()
  if (!token) return null

  try {
    const decoded = jwtDecode<AccessTokenPayload>(token)
    if (!decoded || typeof decoded !== "object" || !Array.isArray(decoded.roles)) {
      clearAuthStorage()
      return null
    }
    return decoded
  } catch {
    clearAuthStorage()
    return null
  }
}

export function getUserFromToken(): AuthUser | null {
  const payload = decodeAccessToken()
  if (!payload) return null

  const username = typeof payload.sub === "string" ? payload.sub : ""
  const roles = Array.isArray(payload.roles) ? payload.roles.map((role) => String(role)) : []
  const id = typeof payload.userId === "string" ? payload.userId : undefined
  const name = typeof payload.name === "string" ? payload.name : undefined

  if (!username || roles.length === 0) return null

  return {
    id,
    username,
    roles,
    name,
  }
}

export function isTokenExpired(payload?: AccessTokenPayload): boolean {
  const tokenPayload = payload ?? decodeAccessToken()
  if (!tokenPayload?.exp) return true
  return Math.floor(Date.now() / 1000) >= tokenPayload.exp
}

export function isAdmin(): boolean {
  const user = getUserFromToken()
  return user?.roles?.includes("ROLE_ADMIN") ?? false
}

export function clearAuthStorage(): void {
  const storage = getStorage()
  if (!storage) return
  storage.removeItem(ACCESS_TOKEN_KEY)
  storage.removeItem(REFRESH_TOKEN_KEY)
  LEGACY_KEYS.forEach((key) => storage.removeItem(key))
}
