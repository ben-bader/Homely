import { NextRequest, NextResponse } from 'next/server';

export function middleware(request: NextRequest) {
  const localeCookie = request.cookies.get('locale')?.value;
  const locale = localeCookie === 'fr' ? 'fr' : 'en';

  const response = NextResponse.next();
  // Keep the cookie in sync so getRequestConfig always sees it
  response.cookies.set('locale', locale, {
    path: '/',
    maxAge: 31536000,
    sameSite: 'lax',
  });

  return response;
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};