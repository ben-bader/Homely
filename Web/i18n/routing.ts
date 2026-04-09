import {defineRouting} from 'next-intl/routing';
import {createNavigation} from 'next-intl/navigation';

export const routing = defineRouting({
  // A list of all locales that are supported
  locales: ['en', 'fr'],

  // Used when no locale matches
  defaultLocale: 'en'
});

// These are the wrappers you will use in your components
export const {Link, redirect, usePathname, useRouter, getPathname} =
  createNavigation(routing);