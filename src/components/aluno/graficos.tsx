"use client";

import { useState } from "react";
import { cn } from "@/lib/utils";

export type Coluna = { rotulo: string; valor: number; dica: string };

// Colunas de uma série só (verde institucional). Colunas finas com topo
// arredondado, linha de base discreta, rótulo só no último e no maior valor,
// dica ao passar o mouse ou focar, e tabela equivalente para leitores de tela.
export function GraficoColunas({
  titulo,
  dados,
  maximo,
  sufixo = "",
  altura = 120,
}: {
  titulo: string;
  dados: Coluna[];
  maximo?: number;
  sufixo?: string; // ex.: "%"
  altura?: number;
}) {
  const formatar = (v: number) => `${v.toLocaleString("pt-BR", { maximumFractionDigits: 1 })}${sufixo}`;
  const [foco, setFoco] = useState<number | null>(null);
  const topo = Math.max(maximo ?? 0, ...dados.map((d) => d.valor), 1);
  const iMaior = dados.reduce((m, d, i) => (d.valor > dados[m].valor ? i : m), 0);
  const rotulados = new Set([dados.length - 1, iMaior]);

  return (
    <figure className="w-full">
      <div className="relative" style={{ height: altura + 20 }} aria-hidden>
        <div className="absolute inset-x-0 flex items-end gap-1" style={{ top: 20, height: altura }}>
          {dados.map((d, i) => {
            const h = d.valor > 0 ? Math.max(3, (d.valor / topo) * altura) : 0;
            return (
              <div
                key={i}
                className="relative flex h-full flex-1 cursor-default flex-col items-center justify-end"
                onMouseEnter={() => setFoco(i)}
                onMouseLeave={() => setFoco(null)}
              >
                {(rotulados.has(i) || foco === i) && d.valor > 0 && (
                  <span className="mb-1 text-[11px] font-medium tabular-nums text-foreground">{formatar(d.valor)}</span>
                )}
                <div
                  className={cn("w-full max-w-6 rounded-t-[4px] bg-verde transition-opacity", foco !== null && foco !== i && "opacity-40")}
                  style={{ height: h }}
                />
                {foco === i && (
                  <div className="pointer-events-none absolute bottom-full z-10 mb-1 w-max max-w-48 rounded-lg border bg-popover px-2.5 py-1.5 text-xs shadow-md shadow-black/5">
                    <p className="font-medium">{d.rotulo}</p>
                    <p className="text-muted-foreground">{d.dica}</p>
                  </div>
                )}
              </div>
            );
          })}
        </div>
        <div className="absolute inset-x-0 bottom-0 h-px bg-border" />
      </div>
      <div className="mt-1.5 flex gap-1" aria-hidden>
        {dados.map((d, i) => (
          <span key={i} className="flex-1 truncate text-center text-[10px] text-muted-foreground">
            {d.rotulo}
          </span>
        ))}
      </div>
      <table className="sr-only">
        <caption>{titulo}</caption>
        <tbody>
          {dados.map((d, i) => (
            <tr key={i}>
              <th scope="row">{d.rotulo}</th>
              <td>{d.dica}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </figure>
  );
}

// Barras horizontais de acerto por área. O valor vai em texto ao lado,
// então a informação nunca depende só da cor.
export function BarrasAcerto({ itens }: { itens: { rotulo: string; detalhe?: string; acertos: number; total: number }[] }) {
  return (
    <ul className="space-y-3">
      {itens.map((it) => {
        const pct = it.total ? Math.round((100 * it.acertos) / it.total) : 0;
        return (
          <li key={it.rotulo + (it.detalhe ?? "")} className="space-y-1.5">
            <div className="flex items-baseline justify-between gap-3 text-sm">
              <span className="min-w-0 truncate">
                {it.rotulo}
                {it.detalhe && <span className="ml-1.5 text-xs text-muted-foreground">{it.detalhe}</span>}
              </span>
              <span className="shrink-0 tabular-nums text-muted-foreground">
                {it.acertos}/{it.total} · <span className="font-medium text-foreground">{pct}%</span>
              </span>
            </div>
            <div
              className="h-2 overflow-hidden rounded-full bg-muted"
              role="progressbar"
              aria-valuenow={pct}
              aria-valuemin={0}
              aria-valuemax={100}
              aria-label={`${it.rotulo}: ${pct}% de acerto`}
            >
              <div className="h-full rounded-full bg-verde" style={{ width: `${pct}%` }} />
            </div>
          </li>
        );
      })}
    </ul>
  );
}
