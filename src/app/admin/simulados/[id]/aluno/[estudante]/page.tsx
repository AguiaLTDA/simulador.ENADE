import Link from "next/link";
import { notFound } from "next/navigation";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { exigirStaff } from "@/lib/contexto";
import { SIGLA_CURSO, type Curso } from "@/lib/cursos";
import { NOME_COMPONENTE, type Componente, type Formato, type Letra } from "@/lib/questoes";
import { formatarDataHora, formatarNota, type Desempenho } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";
import { cn } from "@/lib/utils";
import { LiberarTentativa } from "./liberar-tentativa";

export const metadata = { title: "Revisão do simulado — Portal Simulado ENADE" };

type Revisao = {
  sessao: { id: string; titulo: string; curso: Curso | null; inicio: string; fim: string; duracao_minutos: number };
  aluno: { id: string; nome: string; curso: Curso; turma: string };
  pode_gerir: boolean;
  fim_aluno: string;
  participacao: { tentativa: number; iniciada_em: string; finalizada_em: string | null; encerrado: boolean } | null;
  desempenho: Desempenho | null;
  questoes: {
    numero: number;
    id: string;
    componente: Componente;
    eixo: string;
    formato: Formato;
    enunciado: string;
    gabarito: Letra | null;
    resposta_id: string | null;
    alternativa: Letra | null;
    resposta_texto: string | null;
    correta: boolean | null;
    tempo_segundos: number | null;
    nota: number | null;
    comentario: string | null;
    pontos: number;
  }[];
  anuladas: {
    tentativa: number;
    iniciada_em: string;
    finalizada_em: string | null;
    nota: number | null;
    respondidas: number;
    motivo: string;
    prazo: string | null;
    liberada_em: string;
    liberada_por: string | null;
  }[];
};

const jaEncerrou = (iso: string) => Date.now() > Date.parse(iso);

export default async function RevisaoAlunoPage({ params }: PageProps<"/admin/simulados/[id]/aluno/[estudante]">) {
  await exigirStaff();
  const { id, estudante } = await params;
  if (!/^[0-9a-f-]{36}$/i.test(id) || !/^[0-9a-f-]{36}$/i.test(estudante)) notFound();

  const supabase = await createClient();
  const { data, error } = await supabase.rpc("revisao_simulado_aluno", { p_sessao_id: id, p_estudante_id: estudante });
  if (error || !data) notFound();
  const r = data as Revisao;
  const p = r.participacao;
  const d = r.desempenho;
  const encerradoGeral = jaEncerrou(r.sessao.fim);

  return (
    <>
      <div>
        <Link href={`/admin/simulados/${id}/relatorio`} className="text-sm text-muted-foreground hover:text-foreground">
          ← Relatório do simulado
        </Link>
        <h1 className="mt-1 text-2xl font-semibold tracking-tight">{r.aluno.nome}</h1>
        <p className="text-muted-foreground">
          {r.sessao.titulo} · {SIGLA_CURSO[r.aluno.curso]} · {r.aluno.turma} ·{" "}
          <Link href={`/admin/alunos/${r.aluno.id}`} className="underline">
            perfil do aluno
          </Link>
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Card>
          <CardHeader>
            <CardDescription>Tentativa vigente</CardDescription>
            <CardTitle className="text-2xl">
              {p ? `${p.tentativa}ª` : "—"}{" "}
              {p ? (
                p.encerrado ? <Badge variant="outline">Concluída</Badge> : <Badge>Em andamento</Badge>
              ) : (
                <Badge variant="secondary">Aguardando o aluno</Badge>
              )}
            </CardTitle>
            <p className="text-xs text-muted-foreground">
              {p
                ? `Iniciada em ${formatarDataHora(p.iniciada_em)}${p.finalizada_em ? ` · finalizada em ${formatarDataHora(p.finalizada_em)}` : ""}`
                : `Pode fazer até ${formatarDataHora(r.fim_aluno)}`}
            </p>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader>
            <CardDescription>Nota estimada</CardDescription>
            <CardTitle className="text-3xl tabular-nums">{formatarNota(d?.nota)}</CardTitle>
            {d && d.pendentes > 0 && (
              <p className="text-xs text-muted-foreground">Parcial: {d.pendentes} discursiva(s) pendente(s)</p>
            )}
          </CardHeader>
        </Card>
        <Card>
          <CardHeader>
            <CardDescription>Respondidas</CardDescription>
            <CardTitle className="text-3xl tabular-nums">{d ? `${d.respondidas}/${d.total}` : "—"}</CardTitle>
            {d && <p className="text-xs text-muted-foreground">{d.pontos} ponto(s) nesta tentativa</p>}
          </CardHeader>
        </Card>
      </div>

      {p && (
        <Card>
          <CardHeader>
            <CardTitle>Respostas</CardTitle>
          </CardHeader>
          <CardContent className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-10">Nº</TableHead>
                  <TableHead>Questão</TableHead>
                  <TableHead className="text-center">Resposta</TableHead>
                  <TableHead className="text-center">Gabarito</TableHead>
                  <TableHead className="text-right">Tempo</TableHead>
                  <TableHead className="text-right">Pontos</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {r.questoes.map((q) => (
                  <TableRow key={q.id}>
                    <TableCell className="font-semibold tabular-nums">{q.numero}</TableCell>
                    <TableCell className="max-w-md whitespace-normal">
                      <span className="block text-xs text-muted-foreground">
                        {NOME_COMPONENTE[q.componente]} · {q.eixo}
                      </span>
                      <span className="line-clamp-2">{q.enunciado}</span>
                      {q.formato === "DISCURSIVA" && q.resposta_texto && (
                        <details className="mt-1 text-sm">
                          <summary className="cursor-pointer text-primary">Ver resposta discursiva</summary>
                          <p className="mt-1 whitespace-pre-wrap rounded-md border p-2">{q.resposta_texto}</p>
                          {q.comentario && <p className="mt-1 text-muted-foreground">Comentário: {q.comentario}</p>}
                        </details>
                      )}
                    </TableCell>
                    {q.formato === "DISCURSIVA" ? (
                      <TableCell colSpan={2} className="text-center text-sm">
                        {!q.resposta_id ? (
                          <span className="text-muted-foreground">em branco</span>
                        ) : q.nota !== null ? (
                          `nota ${formatarNota(q.nota)}`
                        ) : (
                          <Link href="/admin/correcoes" className="text-amber-700 underline dark:text-amber-400">
                            corrigir
                          </Link>
                        )}
                      </TableCell>
                    ) : (
                      <>
                        <TableCell
                          className={cn(
                            "text-center font-semibold",
                            q.correta === true && "text-emerald-700 dark:text-emerald-400",
                            q.correta === false && "text-red-700 dark:text-red-400",
                          )}
                        >
                          {q.alternativa ?? <span className="font-normal text-muted-foreground">—</span>}
                        </TableCell>
                        <TableCell className="text-center">{q.gabarito}</TableCell>
                      </>
                    )}
                    <TableCell className="text-right text-xs tabular-nums">
                      {q.tempo_segundos !== null ? `${Math.max(1, Math.round(q.tempo_segundos / 60))} min` : "—"}
                    </TableCell>
                    <TableCell className="text-right tabular-nums">{q.pontos}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}

      {r.anuladas.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Tentativas anuladas</CardTitle>
          </CardHeader>
          <CardContent>
            <ul className="space-y-2 text-sm">
              {r.anuladas.map((a) => (
                <li key={a.tentativa} className="border-t pt-2 first:border-t-0 first:pt-0">
                  <strong>{a.tentativa}ª tentativa</strong> — iniciada em {formatarDataHora(a.iniciada_em)}, nota{" "}
                  {formatarNota(a.nota)}, {a.respondidas} respondida(s).
                  <span className="block text-muted-foreground">
                    Anulada em {formatarDataHora(a.liberada_em)} por {a.liberada_por ?? "—"}. Motivo: {a.motivo}
                    {a.prazo && ` · prazo para refazer: ${formatarDataHora(a.prazo)}`}
                  </span>
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      )}

      {r.pode_gerir && p && (
        <LiberarTentativa sessaoId={r.sessao.id} estudanteId={r.aluno.id} encerradoGeral={encerradoGeral} />
      )}
    </>
  );
}
