import Link from "next/link";
import { notFound } from "next/navigation";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { exigirGestor } from "@/lib/contexto";
import { NOME_CURSO, type Curso } from "@/lib/cursos";
import { formatarDataHora, formatarNota } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";
import { cn } from "@/lib/utils";
import { BotaoExcluirAjuste, FormularioAjuste } from "./formulario-ajuste";

export const metadata = { title: "Pontuação do aluno — Portal Simulado ENADE" };

type Detalhe = {
  aluno: { id: string; nome: string; curso: Curso; turma: string | null; tipo: string | null; status: string };
  resumo: {
    pontos: number;
    pontos_questoes: number;
    pontos_atividades: number;
    pontos_extras: number;
    pontos_ajustes: number;
  } | null;
  atividades: {
    sessao_id: string;
    titulo: string;
    fim: string;
    valor: number;
    participou: boolean;
    finalizada_em: string | null;
    liberado: boolean;
    nota: number | null;
    pontos: number;
  }[];
  ajustes: {
    id: number;
    pontos: number;
    motivo: string;
    criado_em: string;
    sessao_titulo: string | null;
    autor: string;
  }[];
};

function situacaoAtividade(a: Detalhe["atividades"][number]) {
  if (!a.participou) return a.liberado ? "Não fez" : "Não iniciou";
  if (!a.liberado) return a.finalizada_em ? "Entregue — aguardando encerramento" : "Em andamento";
  return `Nota ${formatarNota(a.nota)}`;
}

export default async function PontuacaoAlunoPage({ params }: PageProps<"/admin/pontuacao/[id]">) {
  await exigirGestor();
  const { id } = await params;
  if (!/^[0-9a-f-]{36}$/i.test(id)) notFound();

  const supabase = await createClient();
  const { data, error } = await supabase.rpc("pontuacao_aluno", { p_estudante_id: id });
  if (error) notFound();
  const d = data as Detalhe;
  const r = d.resumo;

  return (
    <>
      <div>
        <Link href="/admin/pontuacao" className="text-sm text-muted-foreground hover:text-foreground">
          ← Pontuação
        </Link>
        <h1 className="mt-1 text-2xl font-semibold tracking-tight">{d.aluno.nome}</h1>
        <p className="text-muted-foreground">
          {NOME_CURSO[d.aluno.curso]} · {d.aluno.turma ?? "sem turma"}
          {d.aluno.status !== "ATIVO" && " · fora da classificação (conta não ativa)"}
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3 lg:grid-cols-5">
        {[
          ["Total", r?.pontos ?? 0],
          ["Questões", r?.pontos_questoes ?? 0],
          ["Atividades", r?.pontos_atividades ?? 0],
          ["Extras", r?.pontos_extras ?? 0],
          ["Ajustes", r?.pontos_ajustes ?? 0],
        ].map(([t, v], i) => (
          <Card key={t}>
            <CardHeader>
              <CardDescription>{t}</CardDescription>
              <CardTitle className={cn("tabular-nums", i === 0 ? "text-3xl" : "text-2xl")}>{v}</CardTitle>
            </CardHeader>
          </Card>
        ))}
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Atividades avaliativas</CardTitle>
          <CardDescription>Pontos = valor × nota estimada ÷ 100, quando o gabarito é liberado.</CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Atividade</TableHead>
                <TableHead>Situação</TableHead>
                <TableHead className="text-right">Valor</TableHead>
                <TableHead className="text-right">Pontos</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {d.atividades.map((a) => (
                <TableRow key={a.sessao_id}>
                  <TableCell>
                    <Link href={`/admin/simulados/${a.sessao_id}/aluno/${d.aluno.id}`} className="font-medium hover:underline">
                      {a.titulo}
                    </Link>
                    <span className="block text-xs text-muted-foreground">Prazo {formatarDataHora(a.fim)}</span>
                  </TableCell>
                  <TableCell className="text-sm">{situacaoAtividade(a)}</TableCell>
                  <TableCell className="text-right tabular-nums">{a.valor}</TableCell>
                  <TableCell className="text-right font-medium tabular-nums">{a.liberado ? a.pontos : "—"}</TableCell>
                </TableRow>
              ))}
              {d.atividades.length === 0 && (
                <TableRow>
                  <TableCell colSpan={4} className="py-6 text-center text-muted-foreground">
                    Nenhuma atividade com valor em pontos para o curso deste aluno.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Lançar ajuste</CardTitle>
          <CardDescription>Bônus ou desconto manual. Entra no total e no ranking na hora.</CardDescription>
        </CardHeader>
        <CardContent>
          <FormularioAjuste
            estudanteId={d.aluno.id}
            atividades={d.atividades.map((a) => ({ sessao_id: a.sessao_id, titulo: a.titulo }))}
          />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Histórico de ajustes</CardTitle>
        </CardHeader>
        <CardContent>
          {d.ajustes.length === 0 ? (
            <p className="text-sm text-muted-foreground">Nenhum ajuste lançado.</p>
          ) : (
            <ul className="divide-y">
              {d.ajustes.map((a) => (
                <li key={a.id} className="flex flex-wrap items-start justify-between gap-3 py-2.5 text-sm">
                  <span className="min-w-0">
                    <span
                      className={cn("mr-2 font-semibold tabular-nums", a.pontos < 0 ? "text-destructive" : "text-verde")}
                    >
                      {a.pontos > 0 ? `+${a.pontos}` : a.pontos}
                    </span>
                    {a.motivo}
                    <span className="block text-xs text-muted-foreground">
                      {a.autor} · {formatarDataHora(a.criado_em)}
                      {a.sessao_titulo && ` · ${a.sessao_titulo}`}
                    </span>
                  </span>
                  <BotaoExcluirAjuste id={a.id} estudanteId={d.aluno.id} />
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>
    </>
  );
}
