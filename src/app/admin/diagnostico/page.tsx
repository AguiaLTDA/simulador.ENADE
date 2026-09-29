import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { NativeSelect } from "@/components/ui/native-select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { exigirStaff } from "@/lib/contexto";
import { CURSOS, SIGLA_CURSO, type Curso } from "@/lib/cursos";
import { AREAS, NOME_AREA, NOME_NIVEL, type Area, type Nivel, type ResultadoArea } from "@/lib/diagnostico";
import { createClient } from "@/lib/supabase/server";
import { cn } from "@/lib/utils";

export const metadata = { title: "Diagnóstico inicial — Portal Simulado ENADE" };

const COR_NIVEL: Record<Nivel, string> = {
  INICIAL: "bg-amber-100 text-amber-900 dark:bg-amber-950 dark:text-amber-200",
  INTERMEDIARIO: "bg-sky-100 text-sky-900 dark:bg-sky-950 dark:text-sky-200",
  AVANCADO: "bg-emerald-100 text-emerald-900 dark:bg-emerald-950 dark:text-emerald-200",
};

type Linha = {
  estudante_id: string;
  concluido_em: string | null;
  iniciado_em: string;
  acertos: number | null;
  total: number | null;
  resultado: Record<Area, ResultadoArea> | null;
  estudantes: { nome: string; curso: Curso; turma: string; tipo: string } | null;
};

export default async function DiagnosticoAdminPage({ searchParams }: PageProps<"/admin/diagnostico">) {
  const { staff } = await exigirStaff();
  const sp = await searchParams;
  const curso = typeof sp.curso === "string" ? sp.curso : "";
  const cursosDoPerfil = staff.cursos ?? CURSOS;

  const supabase = await createClient();
  // RLS já limita aos alunos dos cursos do perfil.
  let consulta = supabase
    .from("diagnostico_resultados")
    .select("estudante_id, concluido_em, iniciado_em, acertos, total, resultado, estudantes!inner(nome, curso, turma, tipo)")
    .order("concluido_em", { ascending: false, nullsFirst: false });
  if (curso) consulta = consulta.eq("estudantes.curso", curso);

  let alunosQ = supabase.from("estudantes").select("*", { count: "exact", head: true });
  if (curso) alunosQ = alunosQ.eq("curso", curso);

  const [{ data, error }, { count: totalAlunos }, { data: questoes }, { data: respostas }] = await Promise.all([
    consulta,
    alunosQ,
    supabase.from("diagnostico_questoes").select("id, area, ordem, habilidade").order("area").order("ordem"),
    supabase.from("diagnostico_respostas").select("questao_id, correta, estudantes!inner(curso)")
      .match(curso ? { "estudantes.curso": curso } : {}),
  ]);

  const linhas = (data ?? []) as unknown as Linha[];
  const concluidos = linhas.filter((l) => l.concluido_em && l.resultado);

  const resumo = AREAS.map((area) => {
    const rs = concluidos.map((l) => l.resultado![area]).filter(Boolean);
    const media = rs.length ? rs.reduce((s, r) => s + r.percentual, 0) / rs.length : null;
    const dist = { INICIAL: 0, INTERMEDIARIO: 0, AVANCADO: 0 } as Record<Nivel, number>;
    rs.forEach((r) => dist[r.nivel]++);
    return { area, media, dist, n: rs.length };
  });

  const porQuestao = new Map<string, { acertos: number; total: number }>();
  (respostas ?? []).forEach((r: { questao_id: string; correta: boolean }) => {
    const x = porQuestao.get(r.questao_id) ?? { acertos: 0, total: 0 };
    x.total++;
    if (r.correta) x.acertos++;
    porQuestao.set(r.questao_id, x);
  });

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Diagnóstico inicial</h1>
          <p className="text-muted-foreground">
            {concluidos.length} de {totalAlunos ?? 0} aluno(s) concluíram. Estes resultados não são
            mostrados aos alunos.
          </p>
        </div>
        {cursosDoPerfil.length > 1 && (
          <form className="flex gap-2">
            <NativeSelect name="curso" defaultValue={curso} aria-label="Curso" className="w-56">
              <option value="">Todos os cursos</option>
              {cursosDoPerfil.map((c) => (
                <option key={c} value={c}>
                  {SIGLA_CURSO[c]}
                </option>
              ))}
            </NativeSelect>
            <Button type="submit" variant="outline">
              Filtrar
            </Button>
          </form>
        )}
      </div>

      {error && (
        <Alert variant="destructive">
          <AlertDescription>Não foi possível carregar os resultados: {error.message}</AlertDescription>
        </Alert>
      )}

      <div className="grid gap-4 md:grid-cols-3">
        {resumo.map(({ area, media, dist, n }) => (
          <Card key={area}>
            <CardHeader>
              <CardDescription>{NOME_AREA[area]}</CardDescription>
              <CardTitle className="text-3xl tabular-nums">
                {media === null ? "—" : `${Math.round(media)}%`}
              </CardTitle>
              <p className="text-xs text-muted-foreground">média de acertos</p>
            </CardHeader>
            <CardContent className="space-y-2">
              {(Object.keys(dist) as Nivel[]).map((nv) => (
                <div key={nv} className="flex items-center gap-2 text-sm">
                  <span className="w-28 text-muted-foreground">{NOME_NIVEL[nv]}</span>
                  <div className="h-2 flex-1 overflow-hidden rounded-full bg-muted">
                    <div
                      className={cn("h-full", nv === "INICIAL" ? "bg-amber-500" : nv === "INTERMEDIARIO" ? "bg-sky-500" : "bg-emerald-500")}
                      style={{ width: n ? `${(100 * dist[nv]) / n}%` : 0 }}
                    />
                  </div>
                  <span className="w-6 text-right tabular-nums">{dist[nv]}</span>
                </div>
              ))}
            </CardContent>
          </Card>
        ))}
      </div>

      <section className="space-y-3">
        <h2 className="text-lg font-semibold">Por aluno</h2>
        {linhas.length === 0 ? (
          <p className="rounded-xl border border-dashed bg-background p-8 text-center text-sm text-muted-foreground">
            Nenhum aluno iniciou o diagnóstico ainda.
          </p>
        ) : (
          <div className="overflow-x-auto rounded-xl border bg-background">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Aluno</TableHead>
                  <TableHead>Curso / turma</TableHead>
                  {AREAS.map((a) => (
                    <TableHead key={a}>{NOME_AREA[a].split(" ")[0]}</TableHead>
                  ))}
                  <TableHead className="text-right">Acertos</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {linhas.map((l) => (
                  <TableRow key={l.estudante_id}>
                    <TableCell className="font-medium">{l.estudantes?.nome}</TableCell>
                    <TableCell className="text-sm">
                      {l.estudantes && SIGLA_CURSO[l.estudantes.curso]} · {l.estudantes?.turma}
                    </TableCell>
                    {AREAS.map((a) => {
                      const r = l.resultado?.[a];
                      return (
                        <TableCell key={a}>
                          {r ? (
                            <span className={cn("rounded px-2 py-0.5 text-xs font-medium", COR_NIVEL[r.nivel])}>
                              {NOME_NIVEL[r.nivel]} · {r.acertos}/{r.total}
                            </span>
                          ) : (
                            <Badge variant="outline">Em andamento</Badge>
                          )}
                        </TableCell>
                      );
                    })}
                    <TableCell className="text-right tabular-nums">
                      {l.acertos !== null ? `${l.acertos}/${l.total}` : "—"}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
      </section>

      <section className="space-y-3">
        <h2 className="text-lg font-semibold">Por questão</h2>
        <p className="text-sm text-muted-foreground">
          Índice de acerto de cada habilidade avaliada. Valores baixos indicam temas para reforço.
        </p>
        <div className="grid gap-4 md:grid-cols-3">
          {AREAS.map((area) => (
            <div key={area} className="rounded-xl border bg-background p-4">
              <h3 className="mb-3 text-sm font-semibold">{NOME_AREA[area]}</h3>
              <ul className="space-y-2 text-sm">
                {(questoes ?? [])
                  .filter((q) => q.area === area)
                  .map((q) => {
                    const s = porQuestao.get(q.id);
                    const pct = s?.total ? Math.round((100 * s.acertos) / s.total) : null;
                    return (
                      <li key={q.id} className="flex items-center justify-between gap-3">
                        <span className="text-muted-foreground">
                          {q.ordem}. {q.habilidade}
                        </span>
                        <span className={cn("tabular-nums font-medium", pct !== null && pct < 50 && "text-amber-600")}>
                          {pct === null ? "—" : `${pct}%`}
                        </span>
                      </li>
                    );
                  })}
              </ul>
            </div>
          ))}
        </div>
      </section>
    </>
  );
}
