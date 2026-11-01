"use client";

import Link from "next/link";
import { useEffect, useRef, useState } from "react";
import { ChevronDown, KeyRound, LogOut } from "lucide-react";
import { cn } from "@/lib/utils";

const iniciais = (nome: string) =>
  nome
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((p) => p[0]?.toUpperCase())
    .join("");

export function MenuPerfil({ nome, detalhe }: { nome: string; detalhe?: string }) {
  const [aberto, setAberto] = useState(false);
  const caixa = useRef<HTMLDivElement>(null);

  // Fecha ao clicar fora ou com Esc.
  useEffect(() => {
    if (!aberto) return;
    const fora = (e: MouseEvent) => {
      if (!caixa.current?.contains(e.target as Node)) setAberto(false);
    };
    const esc = (e: KeyboardEvent) => e.key === "Escape" && setAberto(false);
    document.addEventListener("mousedown", fora);
    document.addEventListener("keydown", esc);
    return () => {
      document.removeEventListener("mousedown", fora);
      document.removeEventListener("keydown", esc);
    };
  }, [aberto]);

  return (
    <div ref={caixa} className="relative">
      <button
        type="button"
        onClick={() => setAberto((a) => !a)}
        aria-haspopup="menu"
        aria-expanded={aberto}
        className="flex items-center gap-2.5 rounded-xl px-1.5 py-1 text-left transition-colors hover:bg-muted"
      >
        <span className="hidden text-right sm:block">
          <span className="block max-w-48 truncate text-sm font-medium leading-tight">{nome}</span>
          {detalhe && (
            <span className="block max-w-48 truncate text-xs leading-tight text-muted-foreground">{detalhe}</span>
          )}
        </span>
        <span className="flex size-8 items-center justify-center rounded-full bg-verde text-xs font-semibold text-white">
          {iniciais(nome)}
        </span>
        <ChevronDown className={cn("size-4 text-muted-foreground transition-transform", aberto && "rotate-180")} />
      </button>

      {aberto && (
        <div
          role="menu"
          className="absolute right-0 z-50 mt-2 w-60 overflow-hidden rounded-xl border bg-popover py-1 shadow-lg shadow-black/5"
        >
          <div className="border-b px-3 py-2.5 sm:hidden">
            <p className="truncate text-sm font-medium">{nome}</p>
            {detalhe && <p className="truncate text-xs text-muted-foreground">{detalhe}</p>}
          </div>
          <Link
            href="/definir-senha"
            role="menuitem"
            onClick={() => setAberto(false)}
            className="flex items-center gap-2.5 px-3 py-2.5 text-sm hover:bg-muted"
          >
            <KeyRound className="size-4 text-muted-foreground" />
            Alterar senha
          </Link>
          <form action="/sair" method="post">
            <button
              type="submit"
              role="menuitem"
              className="flex w-full items-center gap-2.5 px-3 py-2.5 text-left text-sm hover:bg-muted"
            >
              <LogOut className="size-4 text-muted-foreground" />
              Sair
            </button>
          </form>
        </div>
      )}
    </div>
  );
}
