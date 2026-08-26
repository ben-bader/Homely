import { NextRequest, NextResponse } from 'next/server';
import { jwtVerify } from 'jose';

// For simple JWT validation on the edge (optional - backend will validate on API calls)
const JWT_SECRET = new TextEncoder().encode(process.env.JWT_SECRET_FOR_EDGE || 'fallback-secret');

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const localeCookie = request.cookies.get('locale')?.value;
  const locale = localeCookie === 'fr' ? 'fr' : 'en';

  // Set locale cookie
  const response = NextResponse.next();
  response.cookies.set('locale', locale, {
    path: '/',
    maxAge: 31536000,
    sameSite: 'lax',
  });

  // ========================================
  // AUTH VALIDATION FOR PROTECTED ROUTES
  // ========================================

  // Protected routes that require authentication
  const protectedRoutes = ['/dashboard', '/AdminManager', '/profile', '/users', '/properties', '/reports', '/boosts', '/chats', '/visitRequests', '/activityMonitoring', '/ManageParametres'];
  const isProtectedRoute = protectedRoutes.some(route => pathname.startsWith(route));

  if (isProtectedRoute) {
    const accessToken = request.cookies.get('access_token')?.value;

    // If no token in cookies, check localStorage via URL param (client will pass it)
    if (!accessToken) {
      // Redirect to login if no token
      return NextResponse.redirect(new URL('/', request.url));
    }

    // Optional: Verify token signature (requires JWT_SECRET_FOR_EDGE env var)
    // Note: This is optional - the backend API will validate on each request
    // For now, we just check if token exists (client-side validation will handle the rest)
    try {
      // Basic validation: token should be a non-empty string
      if (!accessToken || accessToken.split('.').length !== 3) {
        throw new Error('Invalid token format');
      }
      // Tokens will be fully validated on API calls
    } catch {
      return NextResponse.redirect(new URL('/', request.url));
    }
  }

  return response;
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};