import { Lock } from "lucide-react";
import { Pagina } from "@/components/aluno/pagina";
import { IconeConquista } from "@/components/icone-conquista";
import type { carregarDesempenho } from "@/lib/desempenho";
import { cn } from "@/lib/utils";


export function ConteudoConquistas({ dados }: { dados: Awaited<ReturnType<typeof carregarDesempenho>> }) {
  const { resumo, catalogo } = dados;
  const obtidas = new Map(resumo.conquistas.map((c) => [c.codigo, c.obtida_em]));

  return (
    <Pagina
      titulo="Conquistas"
      descricao={`${obtidas.size} de ${catalogo.length} desbloqueadas. Cada uma marca um passo da sua preparação.`}
    >
      <ul className="grid gap-3 sm:grid-cols-2">
        {catalogo.map((c) => {
          const quando = obtidas.get(c.codigo);
          return (
            <li
              key={c.codigo}
              className={cn(
                "flex items-start gap-4 rounded-xl border bg-card p-4 shadow-[0_1px_2px_rgb(16_24_20/0.04)]",
                quando && "border-dourado/60",
              )}
            >
              <span
                className={cn(
                  "flex size-11 shrink-0 items-center justify-center rounded-full",
                  quando ? "bg-dourado-suave text-[#9a7425]" : "bg-muted text-muted-foreground",
                )}
                aria-hidden
              >
                <IconeConquista icone={c.icone} className="size-5" />
              </span>
              <div className="min-w-0 flex-1">
                <div className="flex flex-wrap items-center gap-2">
                  <p className={cn("font-medium", !quando && "text-foreground/80")}>{c.nome}</p>
                  {quando ? (
                    <span className="rounded-md bg-dourado-suave px-1.5 py-0.5 text-[11px] font-medium text-[#7a5c1c]">
                      Conquistada
                    </span>
                  ) : (
                    <span className="inline-flex items-center gap-1 rounded-md bg-muted px-1.5 py-0.5 text-[11px] font-medium text-muted-foreground">
                      <Lock className="size-3" /> Bloqueada
                    </span>
                  )}
                </div>
                <p className="mt-0.5 text-sm text-muted-foreground">{c.descricao}</p>
                {quando && (
                  <p className="mt-1.5 text-xs text-muted-foreground">
                    Desbloqueada em {new Date(quando).toLocaleDateString("pt-BR")}
                  </p>
                )}
              </div>
            </li>
          );
        })}
      </ul>
    </Pagina>
  );
}
