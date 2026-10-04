import Link from "next/link";
import { Trophy } from "lucide-react";
import { Button, buttonVariants } from "@/components/ui/button";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { NativeSelect } from "@/components/ui/native-select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { exigirStaff } from "@/lib/contexto";
import { CURSOS, SIGLA_CURSO } from "@/lib/cursos";
import { NOME_PERIODO, percentual, type Periodo } from "@/lib/ranking";
import { formatarDataHora } from "@/lib/simulados";
import { cn } from "@/lib/utils";
import { carregarRanking, lerFiltros } from "./dados";

export const metadata = { title: "Classificação — Portal Simulado ENADE" };

const COR_PODIO = ["text-amber-500", "text-slate-400", "text-orange-700"];

export default async function RankingEquipePage({ searchParams }: PageProps<"/admin/ranking">) {
  const { staff } = await exigirStaff();
  const sp = await searchParams;
  const f = lerFiltros(sp);
  const { alunos, turmas } = await carregarRanking(f);
  const cursosDoPerfil = staff.cursos ?? CURSOS;

  const comPontos = alunos.filter((a) => a.pontos > 0);
  const objetivas = alunos.reduce((t, a) => t + a.objetivas, 0);
  const acertos = alunos.reduce((t, a) => t + a.acertos, 0);
  const media = comPontos.length ? Math.round(comPontos.reduce((t, a) => t + a.pontos, 0) / comPontos.length) : null;
  const query = new URLSearchParams(
    Object.entries({ curso: f.curso, turma: f.turma, tipo: f.tipo, periodo: f.periodo }).filter(([, v]) => v),
  ).toString();

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Classificação</h1>
          <p className="text-muted-foreground">
            Engajamento e desempenho dos alunos. Pontos de simulado entram quando o gabarito é liberado.
          </p>
        </div>
        <a href={`/admin/ranking/csv?${query}`} className={buttonVariants({ variant: "outline" })}>
          Exportar CSV
        </a>
      </div>

      <form className="grid gap-3 rounded-xl border bg-background p-4 sm:grid-cols-[repeat(4,1fr)_auto]">
        <NativeSelect name="curso" defaultValue={f.curso} aria-label="Curso">
          <option value="">{cursosDoPerfil.length > 1 ? "Todos os cursos" : SIGLA_CURSO[cursosDoPerfil[0]]}</option>
          {cursosDoPerfil.length > 1 &&
            cursosDoPerfil.map((c) => (
              <option key={c} value={c}>
                {SIGLA_CURSO[c]}
              </option>
            ))}
        </NativeSelect>
        <NativeSelect name="turma" defaultValue={f.turma} aria-label="Turma">
          <option value="">Todas as turmas</option>
          {turmas.map((t) => (
            <option key={t} value={t}>
              {t}
            </option>
          ))}
        </NativeSelect>
        <NativeSelect name="tipo" defaultValue={f.tipo} aria-label="Situação">
          <option value="">Concluintes e ingressantes</option>
          <option value="CONCLUINTE">Concluintes</option>
          <option value="INGRESSANTE">Ingressantes</option>
        </NativeSelect>
        <NativeSelect name="periodo" defaultValue={f.periodo} aria-label="Período">
          {(Object.keys(NOME_PERIODO) as Periodo[]).map((p) => (
            <option key={p} value={p}>
              {NOME_PERIODO[p]}
            </option>
          ))}
        </NativeSelect>
        <Button type="submit" variant="outline">
          Filtrar
        </Button>
      </form>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {[
          ["Alunos ativos", String(alunos.length), "neste filtro"],
          ["Com pontos", String(comPontos.length), `${percentual(comPontos.length, alunos.length) ?? 0}% engajados no período`],
          ["Média de pontos", media === null ? "—" : String(media), "entre quem pontuou"],
          ["Acerto nas objetivas", objetivas ? `${percentual(acertos, objetivas)}%` : "—", `${objetivas} respostas na 1ª tentativa`],
        ].map(([t, v, d]) => (
          <Card key={t}>
            <CardHeader>
              <CardDescription>{t}</CardDescription>
              <CardTitle className="text-3xl tabular-nums">{v}</CardTitle>
              <p className="text-xs text-muted-foreground">{d}</p>
            </CardHeader>
          </Card>
        ))}
      </div>

      <div className="overflow-x-auto rounded-xl border bg-background">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-16 text-center">Posição</TableHead>
              <TableHead>Aluno</TableHead>
              <TableHead>Curso</TableHead>
              <TableHead>Turma</TableHead>
              <TableHead className="text-right">Pontos</TableHead>
              <TableHead className="text-right">Questões</TableHead>
              <TableHead className="text-right">Acerto</TableHead>
              <TableHead className="text-right">Simulados</TableHead>
              <TableHead>Última atividade</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {alunos.map((a) => {
              const pct = percentual(a.acertos, a.objetivas);
              return (
                <TableRow key={a.estudante_id} className={cn(!a.posicao && "text-muted-foreground")}>
                  <TableCell className="text-center tabular-nums">
                    {a.posicao === null ? (
                      "—"
                    ) : a.posicao <= 3 ? (
                      <span className="inline-flex items-center gap-1">
                        <Trophy className={cn("size-4", COR_PODIO[a.posicao - 1])} aria-hidden />
                        {a.posicao}º
                      </span>
                    ) : (
                      `${a.posicao}º`
                    )}
                  </TableCell>
                  <TableCell>
                    {staff.papel === "DOCENTE" ? (
                      a.nome
                    ) : (
                      <Link href={`/admin/alunos/${a.estudante_id}`} className="font-medium hover:underline">
                        {a.nome}
                      </Link>
                    )}
                    <span className="block text-xs text-muted-foreground">
                      {a.tipo === "CONCLUINTE" ? "Concluinte" : "Ingressante"}
                    </span>
                  </TableCell>
                  <TableCell>{SIGLA_CURSO[a.curso]}</TableCell>
                  <TableCell>{a.turma}</TableCell>
                  <TableCell className="text-right font-medium tabular-nums">{a.pontos}</TableCell>
                  <TableCell className="text-right tabular-nums">{a.respondidas}</TableCell>
                  <TableCell className="text-right tabular-nums">{pct === null ? "—" : `${pct}%`}</TableCell>
                  <TableCell className="text-right tabular-nums">{a.simulados}</TableCell>
                  <TableCell className="text-xs">
                    {a.ultima_atividade ? formatarDataHora(a.ultima_atividade) : "sem atividade"}
                  </TableCell>
                </TableRow>
              );
            })}
            {alunos.length === 0 && (
              <TableRow>
                <TableCell colSpan={9} className="py-8 text-center text-muted-foreground">
                  Nenhum aluno ativo neste filtro.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
      <p className="text-xs text-muted-foreground">
        Alunos sem pontos no período aparecem no fim, sem posição — úteis para identificar quem ainda não engajou.
        Questões e acerto contam o período escolhido; simulados contam desde o início.
      </p>
    </>
  );
}
