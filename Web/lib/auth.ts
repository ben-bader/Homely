// utils/auth.ts
import { jwtDecode } from "jwt-decode"

export interface JwtPayload {
  sub: string                 // email (Spring Security default)
  name: string                // full name / username
  role: "ADMIN"
  exp: number
}

export function getUserFromToken(): JwtPayload | null {
  if (typeof window === "undefined") return null

  const jwt = localStorage.getItem("jwt")
  if (!jwt) return null

  try {
    const decoded = jwtDecode<JwtPayload>(jwt)

    // expiration check
    if (decoded.exp * 1000 < Date.now()) {
      localStorage.removeItem("jwt")
      return null
    }

    return decoded
  } catch (err) {
    console.error("Invalid JWT", err)
    localStorage.removeItem("jwt")
    return null
  }
}

export function isAdmin(): boolean {
  const user = getUserFromToken()
  return user?.role === "ADMIN"
}
