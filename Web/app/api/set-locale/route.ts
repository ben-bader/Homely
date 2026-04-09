import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const locale = request.nextUrl.searchParams.get('locale') || 'en';
  const redirectTo = request.nextUrl.searchParams.get('redirect') || '/';

  const response = NextResponse.redirect(new URL(redirectTo, request.url));
  response.cookies.set('locale', locale, {
    path: '/',
    maxAge: 31536000,
    sameSite: 'lax',
  });

  return response;
}