// utils/auth.ts
import {jwtDecode }from "jwt-decode";

interface JwtPayload {
  sub: string; // usually user id or email
  roles: string[]; // must match what Spring Boot sends
  exp: number;
}

export function getUserFromToken() {
  if (typeof window === "undefined") return null;
  const token = localStorage.getItem("token");
  if (!token) return null;

  try {
    const decoded = jwtDecode<JwtPayload>(token);

    // check expiration
    if (decoded.exp * 1000 < Date.now()) {
      localStorage.removeItem("token");
      return null;
    }

    return decoded;
  } catch (err) {
    console.error("Invalid token", err);
    localStorage.removeItem("token");
    return null;
  }
}

export function isAdmin() {
  const user = getUserFromToken();
  return user?.roles?.includes("ADMIN"); // adjust according to your Spring Boot role
}
