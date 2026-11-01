"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import {
  Award,
  ClipboardCheck,
  House,
  PanelLeftClose,
  PanelLeftOpen,
  PencilLine,
  TrendingUp,
  Trophy,
  type LucideIcon,
} from "lucide-react";
import { cn } from "@/lib/utils";

type Item = { href: string; rotulo: string; curto: string; icone: LucideIcon; emBreve?: boolean };

const ITENS: Item[] = [
  { href: "/inicio", rotulo: "Início", curto: "Início", icone: House },
  { href: "/simulados", rotulo: "Simulados", curto: "Simulados", icone: ClipboardCheck },
  { href: "/treino", rotulo: "Treino livre", curto: "Treino", icone: PencilLine, emBreve: true },
  { href: "/desempenho", rotulo: "Meu desempenho", curto: "Desempenho", icone: TrendingUp },
  { href: "/ranking", rotulo: "Classificação", curto: "Ranking", icone: Trophy },
  { href: "/conquistas", rotulo: "Conquistas", curto: "Conquistas", icone: Award },
];

const ativo = (pathname: string, href: string) => pathname === href || pathname.startsWith(`${href}/`);

// Menu lateral recolhível (desktop) e barra inferior (celular).
export function MenuAluno({ recolhidoInicial }: { recolhidoInicial: boolean }) {
  const pathname = usePathname();
  const [recolhido, setRecolhido] = useState(recolhidoInicial);

  function alternar() {
    const novo = !recolhido;
    setRecolhido(novo);
    document.cookie = `menu_recolhido=${novo ? 1 : 0}; path=/; max-age=31536000; samesite=lax`;
  }

  return (
    <>
      <nav
        aria-label="Menu principal"
        className={cn(
          "sticky top-14 hidden h-[calc(100svh-3.5rem)] shrink-0 flex-col border-r bg-background py-4 transition-[width] duration-200 lg:flex",
          recolhido ? "w-[4.5rem] px-3" : "w-60 px-3",
        )}
      >
        <ul className="flex flex-col gap-1">
          {ITENS.map((item) => {
            const Icone = item.icone;
            const atual = ativo(pathname, item.href);
            const conteudo = (
              <>
                <Icone className={cn("size-[18px] shrink-0", atual ? "text-verde" : "text-muted-foreground")} />
                {!recolhido && <span className="truncate">{item.rotulo}</span>}
                {!recolhido && item.emBreve && (
                  <span className="ml-auto rounded-md bg-muted px-1.5 py-0.5 text-[10px] font-medium text-muted-foreground">
                    Em breve
                  </span>
                )}
              </>
            );
            const classe = cn(
              "flex h-10 items-center gap-3 rounded-lg px-3 text-sm transition-colors",
              recolhido && "justify-center px-0",
              atual ? "bg-verde-suave font-semibold text-verde-profundo" : "text-foreground/80 hover:bg-muted",
            );
            return (
              <li key={item.href}>
                {item.emBreve ? (
                  <span
                    className={cn(classe, "cursor-default text-muted-foreground hover:bg-transparent")}
                    title={recolhido ? `${item.rotulo} (em breve)` : undefined}
                    aria-disabled="true"
                  >
                    {conteudo}
                  </span>
                ) : (
                  <Link
                    href={item.href}
                    className={classe}
                    aria-current={atual ? "page" : undefined}
                    title={recolhido ? item.rotulo : undefined}
                  >
                    {conteudo}
                  </Link>
                )}
              </li>
            );
          })}
        </ul>
        <button
          type="button"
          onClick={alternar}
          className={cn(
            "mt-auto flex h-9 items-center gap-3 rounded-lg px-3 text-xs text-muted-foreground transition-colors hover:bg-muted hover:text-foreground",
            recolhido && "justify-center px-0",
          )}
          aria-label={recolhido ? "Expandir menu" : "Recolher menu"}
        >
          {recolhido ? <PanelLeftOpen className="size-4" /> : <PanelLeftClose className="size-4" />}
          {!recolhido && "Recolher menu"}
        </button>
      </nav>

      {/* Celular e tablet: barra inferior com os destinos disponíveis. */}
      <nav
        aria-label="Menu principal"
        className="fixed inset-x-0 bottom-0 z-30 border-t bg-background/95 pb-[env(safe-area-inset-bottom)] backdrop-blur lg:hidden"
      >
        <ul className="mx-auto flex max-w-lg items-stretch justify-around">
          {ITENS.filter((i) => !i.emBreve).map((item) => {
            const Icone = item.icone;
            const atual = ativo(pathname, item.href);
            return (
              <li key={item.href} className="flex-1">
                <Link
                  href={item.href}
                  aria-current={atual ? "page" : undefined}
                  className={cn(
                    "flex min-h-14 flex-col items-center justify-center gap-1 text-[11px]",
                    atual ? "font-semibold text-verde" : "text-muted-foreground",
                  )}
                >
                  <Icone className="size-5" />
                  {item.curto}
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>
    </>
  );
}
