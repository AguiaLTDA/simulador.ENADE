"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";

// Abas do painel da coordenação, com o item ativo sublinhado em verde.
export function AbasAdmin({ itens }: { itens: [string, string][] }) {
  const pathname = usePathname();
  const ativo = (href: string) => (href === "/admin" ? pathname === href : pathname.startsWith(href));
  return (
    <nav aria-label="Painel da coordenação" className="border-b bg-background">
      <div className="mx-auto flex w-full max-w-6xl gap-1 overflow-x-auto px-4 text-sm">
        {itens.map(([href, rotulo]) => (
          <Link
            key={href}
            href={href}
            aria-current={ativo(href) ? "page" : undefined}
            className={cn(
              "-mb-px whitespace-nowrap border-b-2 px-3 py-2.5 transition-colors",
              ativo(href)
                ? "border-verde font-medium text-verde-profundo"
                : "border-transparent text-muted-foreground hover:text-foreground",
            )}
          >
            {rotulo}
          </Link>
        ))}
      </div>
    </nav>
  );
}
