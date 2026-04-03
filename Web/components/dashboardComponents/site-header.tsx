"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { SidebarTrigger } from "@/components/ui/sidebar";
// Adjust the import path if your file has a specific export name
// import { languages } from "@/languages"; 

export function SiteHeader() {
  const [lang, setLang] = useState<"en" | "fr">("en");

  // A small local dictionary for the header text if not using the root file
  const t = {
    en: {
      title: "Admin Dashboard & moderation",
      github: "GitHub",
      toggle: "🇫🇷 FR",
    },
    fr: {
      title: "Tableau de bord & modération",
      github: "GitHub",
      toggle: "🇺🇸 EN",
    },
  };

  const current = t[lang];

  const toggleLanguage = () => {
    const newLang = lang === "en" ? "fr" : "en";
    setLang(newLang);
    // If you have a global state manager or a context provider, 
    // you would trigger the language change here.
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
          {current.title}
        </h1>

        <div className="ml-auto flex items-center gap-2">
          {/* Language Switcher Button */}
          <Button 
            variant="outline" 
            size="sm" 
            onClick={toggleLanguage}
            className="text-xs font-bold px-2 h-8"
          >
            {current.toggle}
          </Button>

          <Button variant="ghost" asChild size="sm" className="hidden sm:flex">
            <a
              href="https://github.com/ben-bader/Homely---PFE"
              rel="noopener noreferrer"
              target="_blank"
              className="dark:text-foreground"
            >
              {current.github}
            </a>
          </Button>
        </div>
      </div>
    </header>
  );
}