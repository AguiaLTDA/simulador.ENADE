import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { Cabecalho } from "@/components/cabecalho";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { NOME_CURSO } from "@/lib/cursos";
import { LETRAS, NOME_COMPONENTE, type Componente } from "@/lib/questoes";
import { formatarDataHora, formatarNota, type QuestaoResultado, type ResultadoAluno } from "@/lib/simulados";
import { cn } from "@/lib/utils";
import { carregarSimuladosDoAluno } from "../../dados";

export const metadata = { title: "Resultado do simulado — Portal Simulado ENADE" };

function porEixo(questoes: QuestaoResultado[]) {
  const mapa = new Map<string, { componente: Componente; eixo: string; total: number; acertos: number }>();
  for (const q of questoes.filter((x) => x.formato === "OBJETIVA")) {
    const chave = `${q.componente}|${q.eixo}`;
    const item = mapa.get(chave) ?? { componente: q.componente, eixo: q.eixo, total: 0, acertos: 0 };
    item.total += 1;
    if (q.correta) item.acertos += 1;
    mapa.set(chave, item);
  }
  return [...mapa.values()].sort((a, b) => a.acertos / a.total - b.acertos / b.total);
}

function Questao({ q }: { q: QuestaoResultado }) {
  const status =
    q.formato === "DISCURSIVA"
      ? q.resposta_texto === null
        ? { rotulo: "Em branco", cor: "bg-muted text-muted-foreground" }
        : q.nota === null
          ? { rotulo: "Aguardando correção", cor: "bg-amber-100 text-amber-900 dark:bg-amber-950 dark:text-amber-200" }
          : { rotulo: `Nota ${formatarNota(q.nota)}`, cor: "bg-sky-100 text-sky-900 dark:bg-sky-950 dark:text-sky-200" }
      : q.alternativa === null
        ? { rotulo: "Em branco", cor: "bg-muted text-muted-foreground" }
        : q.correta
          ? { rotulo: "Acertou", cor: "bg-emerald-100 text-emerald-900 dark:bg-emerald-950 dark:text-emerald-200" }
          : { rotulo: "Errou", cor: "bg-red-100 text-red-900 dark:bg-red-950 dark:text-red-200" };

  return (
    <details className="group rounded-xl border bg-background">
      <summary className="flex cursor-pointer list-none items-center gap-3 p-4">
        <span className="flex size-8 shrink-0 items-center justify-center rounded-full bg-muted text-sm font-semibold tabular-nums">
          {q.numero}
        </span>
        <span className="min-w-0 flex-1">
          <span className="block text-xs text-muted-foreground">
            {NOME_COMPONENTE[q.componente]} · {q.eixo}
          </span>
          <span className="line-clamp-1 text-sm">{q.enunciado}</span>
        </span>
        <span className={cn("shrink-0 rounded-md px-2 py-0.5 text-xs font-medium", status.cor)}>{status.rotulo}</span>
      </summary>
      <div className="space-y-4 border-t p-4 text-[15px] leading-relaxed">
        {q.texto_apoio && <p className="whitespace-pre-wrap rounded-lg bg-muted/60 p-3">{q.texto_apoio}</p>}
        <p className="whitespace-pre-wrap">{q.enunciado}</p>
        {q.formato === "OBJETIVA" && q.alternativas ? (
          <ol className="space-y-1.5">
            {LETRAS.map((l) => (
              <li
                key={l}
                className={cn(
                  "flex gap-3 rounded-md px-2 py-1",
                  l === q.gabarito && "bg-emerald-50 ring-1 ring-emerald-600 dark:bg-emerald-950/40",
                  l === q.alternativa && l !== q.gabarito && "bg-red-50 ring-1 ring-red-500 dark:bg-red-950/40",
                )}
              >
                <span className="font-bold">{l}</span>
                <span className="whitespace-pre-wrap">{q.alternativas![l]}</span>
              </li>
            ))}
          </ol>
        ) : (
          <div className="space-y-2">
            <p className="text-sm font-medium">Sua resposta</p>
            <p className="whitespace-pre-wrap rounded-lg border p-3 text-sm">
              {q.resposta_texto ?? <span className="italic text-muted-foreground">Em branco</span>}
            </p>
            {q.comentario && (
              <>
                <p className="text-sm font-medium">Comentário do docente</p>
                <p className="whitespace-pre-wrap rounded-lg bg-sky-50 p-3 text-sm dark:bg-sky-950/40">{q.comentario}</p>
              </>
            )}
          </div>
        )}
        {q.justificativa && (
          <div className="rounded-lg border bg-muted/40 p-3 text-sm">
            <p className="mb-1 font-semibold">{q.formato === "DISCURSIVA" ? "Padrão de resposta" : "Justificativa"}</p>
            <p className="whitespace-pre-wrap">{q.justificativa}</p>
          </div>
        )}
        <p className="text-xs text-muted-foreground">
          {q.pontos} ponto(s)
          {q.tempo_segundos !== null && ` · ${Math.round(q.tempo_segundos / 60)} min nesta questão`}
        </p>
      </div>
    </details>
  );
}

export default async function ResultadoPage({ params }: PageProps<"/simulados/[id]/resultado">) {
  const { id } = await params;
  if (!/^[0-9a-f-]{36}$/i.test(id)) notFound();

  const { estudante, simulados, supabase } = await carregarSimuladosDoAluno();
  const s = simulados.find((x) => x.id === id);
  if (!s) notFound();
  if (s.situacao !== "CONCLUIDO") redirect(`/simulados/${id}`);

  const { data, error } = await supabase.rpc("resultado_simulado", { p_sessao_id: id });
  if (error) throw new Error(error.message);
  const r = data as ResultadoAluno;
  const d = r.desempenho;
  const componentes = (["FG", "CE"] as Componente[]).filter((c) => d.componentes[c]);

  return (
    <>
      <Cabecalho nome={estudante.nome} detalhe={`${NOME_CURSO[estudante.curso]} · ${estudante.turma}`} />
      <main className="mx-auto w-full max-w-4xl space-y-6 px-4 py-8">
        <div>
          <Link href="/simulados" className="text-sm text-muted-foreground hover:text-foreground">
            ← Simulados
          </Link>
          <h1 className="mt-1 text-2xl font-semibold tracking-tight">{r.sessao.titulo}</h1>
          <p className="text-muted-foreground">
            {r.tentativa > 1 && `${r.tentativa}ª tentativa · `}Finalizado em {formatarDataHora(r.finalizada_em)}
          </p>
        </div>

        <div className="grid gap-4 sm:grid-cols-3">
          <Card className="sm:col-span-1">
            <CardHeader>
              <CardDescription>Nota estimada (0 a 100)</CardDescription>
              <CardTitle className="text-4xl tabular-nums">{formatarNota(d.nota)}</CardTitle>
              <p className="text-xs text-muted-foreground">
                Pesos do ENADE: Formação Geral 25% e Componente Específico 75%.
                {d.pendentes > 0 && ` Parcial: ${d.pendentes} discursiva(s) aguardando correção.`}
              </p>
            </CardHeader>
          </Card>
          <Card>
            <CardHeader>
              <CardDescription>Questões respondidas</CardDescription>
              <CardTitle className="text-3xl tabular-nums">
                {d.respondidas}/{d.total}
              </CardTitle>
              <p className="text-xs text-muted-foreground">Em branco contam como erro.</p>
            </CardHeader>
          </Card>
          <Card>
            <CardHeader>
              <CardDescription>Pontos no ranking</CardDescription>
              <CardTitle className="text-3xl tabular-nums">+{d.pontos}</CardTitle>
              {r.media_participantes !== null && (
                <p className="text-xs text-muted-foreground">
                  Média dos {r.participantes} participantes: {formatarNota(r.media_participantes)}
                </p>
              )}
            </CardHeader>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>Por componente</CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Componente</TableHead>
                  <TableHead className="text-right">Objetivas</TableHead>
                  <TableHead className="text-right">Discursivas</TableHead>
                  <TableHead className="text-right">Nota</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {componentes.map((c) => {
                  const x = d.componentes[c]!;
                  return (
                    <TableRow key={c}>
                      <TableCell>{NOME_COMPONENTE[c]}</TableCell>
                      <TableCell className="text-right tabular-nums">
                        {x.obj_total ? `${x.obj_acertos}/${x.obj_total} acertos` : "—"}
                      </TableCell>
                      <TableCell className="text-right tabular-nums">
                        {x.disc_total
                          ? `${x.disc_total}${x.disc_pendentes ? ` (${x.disc_pendentes} pendente)` : ""}`
                          : "—"}
                      </TableCell>
                      <TableCell className="text-right font-medium tabular-nums">{formatarNota(x.nota)}</TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        {!r.gabarito_liberado || !r.questoes ? (
          <Alert>
            <AlertDescription>
              O gabarito, as justificativas e a correção questão a questão serão liberados em{" "}
              <strong>{formatarDataHora(r.sessao.fim)}</strong>, quando o simulado fecha para todos os colegas.
            </AlertDescription>
          </Alert>
        ) : (
          <>
            <Card>
              <CardHeader>
                <CardTitle>Onde focar</CardTitle>
                <CardDescription>Acertos nas objetivas por eixo, do mais fraco para o mais forte.</CardDescription>
              </CardHeader>
              <CardContent className="space-y-3">
                {porEixo(r.questoes).map((e) => {
                  const pct = Math.round((100 * e.acertos) / e.total);
                  return (
                    <div key={`${e.componente}${e.eixo}`} className="space-y-1">
                      <div className="flex justify-between gap-3 text-sm">
                        <span>
                          {e.eixo} <Badge variant="outline">{e.componente}</Badge>
                        </span>
                        <span className="tabular-nums text-muted-foreground">
                          {e.acertos}/{e.total} · {pct}%
                        </span>
                      </div>
                      <div className="h-2 overflow-hidden rounded-full bg-muted">
                        <div className="h-full bg-primary" style={{ width: `${pct}%` }} />
                      </div>
                    </div>
                  );
                })}
              </CardContent>
            </Card>

            <section className="space-y-2">
              <h2 className="font-medium">Questão a questão</h2>
              {r.questoes.map((q) => (
                <Questao key={q.id} q={q} />
              ))}
            </section>
          </>
        )}
      </main>
    </>
  );
}
