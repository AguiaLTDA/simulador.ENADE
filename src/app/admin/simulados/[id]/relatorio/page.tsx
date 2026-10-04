import Link from "next/link";
import { notFound } from "next/navigation";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { exigirStaff } from "@/lib/contexto";
import { SIGLA_CURSO } from "@/lib/cursos";
import { LETRAS, NOME_COMPONENTE, NOME_DIFICULDADE, type Componente } from "@/lib/questoes";
import { formatarDataHora, formatarDuracao, formatarNota } from "@/lib/simulados";
import { cn } from "@/lib/utils";
import { carregarRelatorio, type Relatorio } from "./dados";

export const metadata = { title: "Relatório do simulado — Portal Simulado ENADE" };

const pct = (a: number, t: number) => (t ? Math.round((100 * a) / t) : null);

function mediana(v: number[]): number | null {
  if (!v.length) return null;
  const s = [...v].sort((a, b) => a - b);
  const m = Math.floor(s.length / 2);
  return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2;
}

function porEixo(r: Relatorio) {
  const mapa = new Map<string, { componente: Componente; eixo: string; total: number; acertos: number; questoes: number }>();
  for (const q of r.questoes.filter((x) => x.formato === "OBJETIVA")) {
    const k = `${q.componente}|${q.eixo}`;
    const e = mapa.get(k) ?? { componente: q.componente, eixo: q.eixo, total: 0, acertos: 0, questoes: 0 };
    e.total += q.respostas.total;
    e.acertos += q.respostas.acertos;
    e.questoes += 1;
    mapa.set(k, e);
  }
  return [...mapa.values()].sort((a, b) => (pct(a.acertos, a.total) ?? 101) - (pct(b.acertos, b.total) ?? 101));
}

// Faixa de cor do percentual de acerto (alerta abaixo de 40%, atenção até 60%).
const corPct = (p: number | null) =>
  p === null
    ? "text-muted-foreground"
    : p < 40
      ? "text-red-700 dark:text-red-400"
      : p < 60
        ? "text-amber-700 dark:text-amber-400"
        : "text-emerald-700 dark:text-emerald-400";

export default async function RelatorioPage({ params }: PageProps<"/admin/simulados/[id]/relatorio">) {
  await exigirStaff();
  const { id } = await params;
  if (!/^[0-9a-f-]{36}$/i.test(id)) notFound();
  const r = await carregarRelatorio(id);
  if (!r) notFound();

  const encerrados = r.participantes.filter((p) => p.encerrado);
  const notas = encerrados.map((p) => p.desempenho.nota).filter((n): n is number => n !== null).map(Number);
  const media = notas.length ? notas.reduce((a, b) => a + b, 0) / notas.length : null;
  const pendentes = r.participantes.reduce((a, p) => a + p.desempenho.pendentes, 0);
  const notaComp = (c: Componente) => {
    const v = encerrados.map((p) => p.desempenho.componentes[c]?.nota).filter((n) => n != null).map(Number);
    return v.length ? v.reduce((a, b) => a + b, 0) / v.length : null;
  };

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <Link href="/admin/simulados" className="text-sm text-muted-foreground hover:text-foreground">
            ← Simulados
          </Link>
          <h1 className="mt-1 text-2xl font-semibold tracking-tight">{r.sessao.titulo}</h1>
          <p className="text-muted-foreground">
            {r.sessao.curso ? SIGLA_CURSO[r.sessao.curso] : "Todos os cursos"} · {r.questoes.length} questões ·{" "}
            {formatarDuracao(r.sessao.duracao_minutos)} · {formatarDataHora(r.sessao.inicio)} a{" "}
            {formatarDataHora(r.sessao.fim)}
          </p>
        </div>
        <a href={`/admin/simulados/${id}/relatorio/csv`} className={buttonVariants({ variant: "outline" })}>
          Exportar CSV
        </a>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {[
          ["Participação", `${r.participantes.length}/${r.elegiveis}`, `${pct(r.participantes.length, r.elegiveis) ?? 0}% dos alunos ativos`],
          ["Nota média", formatarNota(media), `Mediana ${formatarNota(mediana(notas))} · ${encerrados.length} concluído(s)`],
          ["FG / CE", `${formatarNota(notaComp("FG"))} / ${formatarNota(notaComp("CE"))}`, "Média por componente (0 a 100)"],
          ["Discursivas pendentes", String(pendentes), pendentes ? "Corrija em Correções" : "Tudo corrigido"],
        ].map(([t, v, d]) => (
          <Card key={t}>
            <CardHeader>
              <CardDescription>{t}</CardDescription>
              <CardTitle className="text-3xl tabular-nums">{v}</CardTitle>
              <p className="text-xs text-muted-foreground">
                {t === "Discursivas pendentes" && pendentes ? (
                  <Link href="/admin/correcoes" className="underline">
                    {d}
                  </Link>
                ) : (
                  d
                )}
              </p>
            </CardHeader>
          </Card>
        ))}
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Desempenho por eixo</CardTitle>
          <CardDescription>Acerto nas objetivas, do eixo mais fraco para o mais forte.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          {porEixo(r).map((e) => {
            const p = pct(e.acertos, e.total);
            return (
              <div key={`${e.componente}${e.eixo}`} className="space-y-1">
                <div className="flex justify-between gap-3 text-sm">
                  <span>
                    {e.eixo} <Badge variant="outline">{e.componente}</Badge>{" "}
                    <span className="text-xs text-muted-foreground">{e.questoes} questão(ões)</span>
                  </span>
                  <span className={cn("tabular-nums", corPct(p))}>{p === null ? "sem respostas" : `${p}%`}</span>
                </div>
                <div className="h-2 overflow-hidden rounded-full bg-muted">
                  <div className="h-full bg-primary" style={{ width: `${p ?? 0}%` }} />
                </div>
              </div>
            );
          })}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Alunos</CardTitle>
        </CardHeader>
        <CardContent className="overflow-x-auto">
          {r.participantes.length === 0 ? (
            <p className="text-sm text-muted-foreground">Nenhum aluno com tentativa em curso ou concluída.</p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Aluno</TableHead>
                  <TableHead>Turma</TableHead>
                  <TableHead>Situação</TableHead>
                  <TableHead className="text-right">FG obj.</TableHead>
                  <TableHead className="text-right">CE obj.</TableHead>
                  <TableHead className="text-right">Respondidas</TableHead>
                  <TableHead className="text-right">Nota</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {[...r.participantes]
                  .sort((a, b) => Number(b.desempenho.nota ?? -1) - Number(a.desempenho.nota ?? -1))
                  .map((p) => {
                    const fg = p.desempenho.componentes.FG;
                    const ce = p.desempenho.componentes.CE;
                    return (
                      <TableRow key={p.estudante_id}>
                        <TableCell className="font-medium">
                          <Link href={`/admin/simulados/${id}/aluno/${p.estudante_id}`} className="hover:underline">
                            {p.nome}
                          </Link>
                          {p.tentativa > 1 && (
                            <Badge variant="secondary" className="ml-1.5">
                              {p.tentativa}ª tentativa
                            </Badge>
                          )}
                          <span className="block text-xs font-normal text-muted-foreground">
                            {SIGLA_CURSO[p.curso]} · {p.tipo === "CONCLUINTE" ? "Concluinte" : "Ingressante"}
                          </span>
                        </TableCell>
                        <TableCell>{p.turma}</TableCell>
                        <TableCell>
                          {p.encerrado ? (
                            <Badge variant="outline">Concluído</Badge>
                          ) : (
                            <Badge>Em andamento</Badge>
                          )}
                        </TableCell>
                        <TableCell className="text-right tabular-nums">
                          {fg?.obj_total ? `${fg.obj_acertos}/${fg.obj_total}` : "—"}
                        </TableCell>
                        <TableCell className="text-right tabular-nums">
                          {ce?.obj_total ? `${ce.obj_acertos}/${ce.obj_total}` : "—"}
                        </TableCell>
                        <TableCell className="text-right tabular-nums">
                          {p.desempenho.respondidas}/{p.desempenho.total}
                        </TableCell>
                        <TableCell className="text-right font-medium tabular-nums">
                          {formatarNota(p.desempenho.nota)}
                          {p.desempenho.pendentes > 0 && <span className="text-xs text-muted-foreground">*</span>}
                        </TableCell>
                      </TableRow>
                    );
                  })}
              </TableBody>
            </Table>
          )}
          {pendentes > 0 && (
            <p className="mt-2 text-xs text-muted-foreground">* Nota parcial: há discursivas aguardando correção.</p>
          )}
          {r.aguardando_nova_tentativa.length > 0 && (
            <div className="mt-4 rounded-lg border border-dashed p-3 text-sm">
              <p className="font-medium">Nova tentativa liberada, aguardando o aluno</p>
              <ul className="mt-1 space-y-1 text-muted-foreground">
                {r.aguardando_nova_tentativa.map((a) => (
                  <li key={a.estudante_id}>
                    <Link href={`/admin/simulados/${id}/aluno/${a.estudante_id}`} className="hover:underline">
                      {a.nome}
                    </Link>{" "}
                    · {a.turma} · até {formatarDataHora(a.fim)}
                  </li>
                ))}
              </ul>
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Questão a questão</CardTitle>
          <CardDescription>
            Distribuição das respostas. Alternativa errada muito marcada costuma indicar erro conceitual comum.
          </CardDescription>
        </CardHeader>
        <CardContent className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-10">Nº</TableHead>
                <TableHead>Questão</TableHead>
                <TableHead className="text-right">Acerto</TableHead>
                {LETRAS.map((l) => (
                  <TableHead key={l} className="text-center">
                    {l}
                  </TableHead>
                ))}
              </TableRow>
            </TableHeader>
            <TableBody>
              {r.questoes.map((q) => {
                const p = pct(q.respostas.acertos, q.respostas.total);
                return (
                  <TableRow key={q.id}>
                    <TableCell className="font-semibold tabular-nums">{q.numero}</TableCell>
                    <TableCell className="max-w-md whitespace-normal">
                      <span className="block text-xs text-muted-foreground">
                        {NOME_COMPONENTE[q.componente]} · {q.eixo} · {NOME_DIFICULDADE[q.dificuldade]}
                        {q.formato === "DISCURSIVA" && " · Discursiva"}
                      </span>
                      <span className="line-clamp-2">{q.enunciado}</span>
                    </TableCell>
                    {q.formato === "DISCURSIVA" ? (
                      <TableCell colSpan={6} className="text-sm text-muted-foreground">
                        {q.respostas.total} resposta(s) · {q.respostas.corrigidas} corrigida(s)
                        {q.respostas.nota_media !== null && ` · nota média ${formatarNota(q.respostas.nota_media)}`}
                      </TableCell>
                    ) : (
                      <>
                        <TableCell className={cn("text-right font-medium tabular-nums", corPct(p))}>
                          {p === null ? "—" : `${p}%`}
                        </TableCell>
                        {LETRAS.map((l) => (
                          <TableCell
                            key={l}
                            className={cn(
                              "text-center tabular-nums",
                              l === q.gabarito && "bg-emerald-50 font-semibold text-emerald-800 dark:bg-emerald-950/40 dark:text-emerald-300",
                            )}
                          >
                            {q.respostas[l]}
                          </TableCell>
                        ))}
                      </>
                    )}
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </>
  );
}
