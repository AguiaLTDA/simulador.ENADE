import Link from "next/link";
import { redirect } from "next/navigation";
import { Trophy } from "lucide-react";
import { Cabecalho } from "@/components/cabecalho";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { destinoInicial, obterContexto } from "@/lib/contexto";
import { NOME_CURSO, SIGLA_CURSO } from "@/lib/cursos";
import {
  NOME_ESCOPO,
  NOME_PERIODO,
  lerEscopo,
  lerPeriodo,
  percentual,
  type Escopo,
  type Periodo,
  type RankingAluno,
} from "@/lib/ranking";
import { createClient } from "@/lib/supabase/server";
import { cn } from "@/lib/utils";

export const metadata = { title: "Classificação — Portal Simulado ENADE" };

const COR_PODIO = ["text-amber-500", "text-slate-400", "text-orange-700"];

function Filtro<T extends string>({
  opcoes,
  atual,
  href,
}: {
  opcoes: Record<T, string>;
  atual: T;
  href: (v: T) => string;
}) {
  return (
    <div className="flex flex-wrap gap-1 rounded-lg border bg-background p-1 text-sm">
      {(Object.keys(opcoes) as T[]).map((v) => (
        <Link
          key={v}
          href={href(v)}
          className={cn(
            "rounded-md px-3 py-1",
            v === atual ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground",
          )}
        >
          {opcoes[v]}
        </Link>
      ))}
    </div>
  );
}

export default async function RankingPage({ searchParams }: PageProps<"/ranking">) {
  const ctx = await obterContexto();
  if (!ctx.estudante || ctx.estudante.status !== "ATIVO") redirect(destinoInicial(ctx));
  const sp = await searchParams;
  const escopo = lerEscopo(sp.escopo);
  const periodo = lerPeriodo(sp.periodo);

  const supabase = await createClient();
  const { data, error } = await supabase.rpc("ranking_aluno", { p_escopo: escopo, p_periodo: periodo });
  if (error) throw new Error(error.message);
  const r = data as RankingAluno;
  const euNaLista = r.lideres.some((l) => l.eu);
  const acerto = percentual(r.eu.acertos, r.eu.objetivas);
  const link = (e: Escopo, p: Periodo) => `/ranking?escopo=${e}&periodo=${p}`;

  return (
    <>
      <Cabecalho nome={ctx.estudante.nome} detalhe={`${NOME_CURSO[ctx.estudante.curso]} · ${ctx.estudante.turma}`} />
      <main className="mx-auto w-full max-w-3xl space-y-6 px-4 py-8">
        <div>
          <Link href="/inicio" className="text-sm text-muted-foreground hover:text-foreground">
            ← Início
          </Link>
          <h1 className="mt-1 text-2xl font-semibold tracking-tight">Classificação</h1>
          <p className="text-muted-foreground">
            Pontos de questões, discursivas corrigidas e conquistas. Pontos de simulado entram quando o gabarito é
            liberado.
          </p>
        </div>

        <div className="flex flex-wrap gap-2">
          <Filtro opcoes={NOME_ESCOPO} atual={escopo} href={(e) => link(e, periodo)} />
          <Filtro opcoes={NOME_PERIODO} atual={periodo} href={(p) => link(escopo, p)} />
        </div>

        <div className="grid gap-4 sm:grid-cols-3">
          <Card className="border-primary">
            <CardHeader>
              <CardDescription>Sua posição</CardDescription>
              <CardTitle className="text-4xl tabular-nums">{r.eu.posicao ? `${r.eu.posicao}º` : "—"}</CardTitle>
              <p className="text-xs text-muted-foreground">
                {r.eu.posicao
                  ? `de ${r.participantes} aluno(s) com pontos`
                  : "Responda questões para entrar na classificação."}
              </p>
            </CardHeader>
          </Card>
          <Card>
            <CardHeader>
              <CardDescription>Seus pontos</CardDescription>
              <CardTitle className="text-3xl tabular-nums">{r.eu.pontos}</CardTitle>
              <p className="text-xs text-muted-foreground">{NOME_PERIODO[periodo].toLowerCase()}</p>
            </CardHeader>
          </Card>
          <Card>
            <CardHeader>
              <CardDescription>Acerto nas objetivas</CardDescription>
              <CardTitle className="text-3xl tabular-nums">{acerto === null ? "—" : `${acerto}%`}</CardTitle>
              <p className="text-xs text-muted-foreground">{r.eu.objetivas} respondida(s) na 1ª tentativa</p>
            </CardHeader>
          </Card>
        </div>

        {r.lideres.length === 0 ? (
          <div className="rounded-xl border border-dashed bg-background p-10 text-center text-sm text-muted-foreground">
            Ninguém pontuou neste recorte ainda. Que tal ser o primeiro?
          </div>
        ) : (
          <div className="overflow-x-auto rounded-xl border bg-background">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-16 text-center">Posição</TableHead>
                  <TableHead>Aluno</TableHead>
                  {escopo === "GERAL" && <TableHead>Curso</TableHead>}
                  {escopo !== "TURMA" && <TableHead>Turma</TableHead>}
                  <TableHead className="text-right">Pontos</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {r.lideres.map((l, i) => (
                  <TableRow key={i} className={cn(l.eu && "bg-primary/10 font-medium")}>
                    <TableCell className="text-center tabular-nums">
                      {l.posicao <= 3 ? (
                        <span className="inline-flex items-center gap-1">
                          <Trophy className={cn("size-4", COR_PODIO[l.posicao - 1])} aria-hidden />
                          {l.posicao}º
                        </span>
                      ) : (
                        `${l.posicao}º`
                      )}
                    </TableCell>
                    <TableCell>
                      {l.nome}
                      {l.eu && <span className="ml-1.5 text-xs text-primary">(você)</span>}
                    </TableCell>
                    {escopo === "GERAL" && <TableCell>{SIGLA_CURSO[l.curso]}</TableCell>}
                    {escopo !== "TURMA" && <TableCell>{l.turma}</TableCell>}
                    <TableCell className="text-right tabular-nums">{l.pontos}</TableCell>
                  </TableRow>
                ))}
                {!euNaLista && r.eu.posicao && (
                  <TableRow className="bg-primary/10 font-medium">
                    <TableCell className="text-center tabular-nums">{r.eu.posicao}º</TableCell>
                    <TableCell>Você</TableCell>
                    {escopo === "GERAL" && <TableCell>{SIGLA_CURSO[ctx.estudante.curso]}</TableCell>}
                    {escopo !== "TURMA" && <TableCell>{ctx.estudante.turma}</TableCell>}
                    <TableCell className="text-right tabular-nums">{r.eu.pontos}</TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>
        )}
        <p className="text-xs text-muted-foreground">
          Mostramos os 50 primeiros. Os colegas aparecem com o primeiro nome e a inicial do sobrenome.
        </p>
      </main>
    </>
  );
}
