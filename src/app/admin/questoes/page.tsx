import Link from "next/link";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { Button, buttonVariants } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { NativeSelect } from "@/components/ui/native-select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { exigirGestor } from "@/lib/contexto";
import { CURSOS, SIGLA_CURSO, type Curso } from "@/lib/cursos";
import { NOME_DIFICULDADE, NOME_STATUS, type StatusQuestao } from "@/lib/questoes";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Questões — Portal Simulado ENADE" };

const AVISO: Record<string, string> = {
  PUBLICADA: "Questão salva e publicada.",
  RASCUNHO: "Questão salva como rascunho.",
  ARQUIVADA: "Questão arquivada. Ela não aparece mais para os alunos, mas o histórico foi mantido.",
  EXCLUIDA: "Questão excluída.",
};

const VARIANTE_STATUS: Record<StatusQuestao, "default" | "secondary" | "outline"> = {
  PUBLICADA: "default",
  RASCUNHO: "secondary",
  ARQUIVADA: "outline",
};

type Linha = {
  id: string;
  componente: "FG" | "CE";
  cursos: string[];
  eixo: string;
  formato: "OBJETIVA" | "DISCURSIVA";
  enunciado: string;
  dificuldade: number;
  peso_pontos: number;
  status: StatusQuestao;
  questoes_gabarito: { gabarito: string | null } | null;
};

export default async function QuestoesPage({ searchParams }: PageProps<"/admin/questoes">) {
  const ctx = await exigirGestor();
  const cursosDoFiltro = ctx.staff.cursos ?? CURSOS;
  const sp = await searchParams;
  const filtro = (k: string) => (typeof sp[k] === "string" ? (sp[k] as string) : "");
  const status = filtro("status");
  const componente = filtro("componente");
  const curso = filtro("curso");
  const busca = filtro("q").trim();
  const salva = filtro("salva");

  const supabase = await createClient();
  let consulta = supabase
    .from("questoes")
    .select("id, componente, cursos, eixo, formato, enunciado, dificuldade, peso_pontos, status, questoes_gabarito(gabarito)")
    .order("criado_em", { ascending: false })
    .limit(300);
  if (status) consulta = consulta.eq("status", status);
  else consulta = consulta.neq("status", "ARQUIVADA");
  if (componente) consulta = consulta.eq("componente", componente);
  if (curso) consulta = consulta.overlaps("cursos", [curso, "ALL"]);
  if (busca) {
    const termo = busca.replace(/[%,()]/g, " ");
    consulta = consulta.or(`enunciado.ilike.%${termo}%,eixo.ilike.%${termo}%`);
  }

  const { data, error } = await consulta;
  const questoes = (data ?? []) as unknown as Linha[];

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Banco de questões</h1>
          <p className="text-muted-foreground">{questoes.length} questão(ões) neste filtro.</p>
        </div>
        <div className="flex gap-2">
          <Link href="/admin/questoes/importar" className={buttonVariants({ variant: "outline" })}>
            Importar planilha
          </Link>
          <Link href="/admin/questoes/nova" className={buttonVariants()}>
            Nova questão
          </Link>
        </div>
      </div>

      {filtro("importadas") && (
        <Alert>
          <AlertDescription>{filtro("importadas")} questão(ões) importada(s).</AlertDescription>
        </Alert>
      )}

      {salva && AVISO[salva] && (
        <Alert>
          <AlertDescription>{AVISO[salva]}</AlertDescription>
        </Alert>
      )}
      {error && (
        <Alert variant="destructive">
          <AlertDescription>Não foi possível carregar as questões: {error.message}</AlertDescription>
        </Alert>
      )}

      <form className="grid gap-3 rounded-xl border bg-background p-4 sm:grid-cols-[1fr_auto_auto_auto_auto]">
        <Input name="q" placeholder="Buscar no enunciado ou eixo" defaultValue={busca} />
        <NativeSelect name="componente" defaultValue={componente} aria-label="Componente">
          <option value="">Todos os componentes</option>
          <option value="FG">Formação Geral</option>
          <option value="CE">Específico</option>
        </NativeSelect>
        <NativeSelect name="curso" defaultValue={curso} aria-label="Curso">
          <option value="">Todos os cursos</option>
          {cursosDoFiltro.map((c) => (
            <option key={c} value={c}>
              {SIGLA_CURSO[c]}
            </option>
          ))}
        </NativeSelect>
        <NativeSelect name="status" defaultValue={status} aria-label="Situação">
          <option value="">Ativas</option>
          <option value="PUBLICADA">Publicadas</option>
          <option value="RASCUNHO">Rascunhos</option>
          <option value="ARQUIVADA">Arquivadas</option>
        </NativeSelect>
        <Button type="submit" variant="outline">
          Filtrar
        </Button>
      </form>

      {questoes.length === 0 ? (
        <div className="rounded-xl border border-dashed bg-background p-10 text-center">
          <p className="font-medium">Nenhuma questão encontrada.</p>
          <p className="text-sm text-muted-foreground">
            Cadastre a primeira questão para os alunos começarem a treinar.
          </p>
        </div>
      ) : (
        <div className="overflow-x-auto rounded-xl border bg-background">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Questão</TableHead>
                <TableHead>Cursos</TableHead>
                <TableHead>Dificuldade</TableHead>
                <TableHead className="text-right">Peso</TableHead>
                <TableHead className="text-center">Gabarito</TableHead>
                <TableHead>Situação</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {questoes.map((q) => (
                <TableRow key={q.id}>
                  <TableCell className="max-w-md">
                    <Link href={`/admin/questoes/${q.id}`} className="block hover:underline">
                      <span className="block text-xs text-muted-foreground">
                        {q.componente === "FG" ? "Formação Geral" : "Específico"} · {q.eixo}
                        {q.formato === "DISCURSIVA" && " · Discursiva"}
                      </span>
                      <span className="line-clamp-2 whitespace-normal">{q.enunciado}</span>
                    </Link>
                  </TableCell>
                  <TableCell className="whitespace-normal text-xs">
                    {q.cursos.includes("ALL")
                      ? "Todos"
                      : q.cursos.map((c) => SIGLA_CURSO[c as Curso]).join(", ")}
                  </TableCell>
                  <TableCell>{NOME_DIFICULDADE[q.dificuldade]}</TableCell>
                  <TableCell className="text-right tabular-nums">{q.peso_pontos}</TableCell>
                  <TableCell className="text-center font-semibold">
                    {q.formato === "DISCURSIVA" ? "—" : (q.questoes_gabarito?.gabarito ?? "?")}
                  </TableCell>
                  <TableCell>
                    <Badge variant={VARIANTE_STATUS[q.status]}>{NOME_STATUS[q.status]}</Badge>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      )}
    </>
  );
}
