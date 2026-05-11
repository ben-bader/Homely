"use client";

import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { SidebarTrigger } from "@/components/ui/sidebar";
import { useTranslations, useLocale } from 'next-intl';

export function SiteHeader() {
  const locale = useLocale();
  const t = useTranslations('header');

  const toggleLocale = () => {
    const newLocale = locale === 'en' ? 'fr' : 'en';
    document.cookie = `locale=${newLocale}; path=/; max-age=31536000; samesite=lax`;
    // Small delay ensures the cookie is committed before the reload
    setTimeout(() => window.location.reload(), 50);
  };

  return (
    <header className="flex h-(--header-height) shrink-0 items-center gap-2 border-b transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-(--header-height)">
      <div className="flex w-full items-center gap-1 px-4 lg:gap-2 lg:px-6">
        <SidebarTrigger className="-ml-1" />
        <Separator
          orientation="vertical"
          className="mx-2 data-[orientation=vertical]:h-4"
        />

        <h1 className="text-sm md:text-base font-medium truncate">
          {t('title')}
        </h1>

        <div className="ml-auto flex items-center gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={toggleLocale}
            className="text-xs font-bold px-2 h-8"
          >
            {locale === 'en' ? t('toggleToFr') : t('toggleToEn')}
          </Button>

          <Button variant="ghost" asChild size="sm" className="hidden sm:flex">
            <a
              href="https://github.com/ben-bader/Homely---PFE"
              rel="noopener noreferrer"
              target="_blank"
              className="dark:text-foreground"
            >
              {t('github')}
            </a>
          </Button>
        </div>
      </div>
    </header>
  );
}