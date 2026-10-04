import Link from "next/link";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { exigirStaff } from "@/lib/contexto";
import { SIGLA_CURSO, type Curso } from "@/lib/cursos";
import { formatarDataHora, formatarDuracao } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Simulados — Portal Simulado ENADE" };

type Linha = {
  id: string;
  titulo: string;
  curso: Curso | null;
  inicio: string;
  fim: string;
  duracao_minutos: number;
  questoes: string[];
  publicada: boolean;
  sessoes_participacao: { count: number }[];
};

const agoraMs = () => Date.now();

function situacao(s: Linha, agora: number): { rotulo: string; variante: "default" | "secondary" | "outline" } {
  if (!s.publicada) return { rotulo: "Rascunho", variante: "secondary" };
  if (agora < Date.parse(s.inicio)) return { rotulo: "Agendado", variante: "secondary" };
  if (agora <= Date.parse(s.fim)) return { rotulo: "Aberto", variante: "default" };
  return { rotulo: "Encerrado", variante: "outline" };
}

export default async function SimuladosAdminPage({ searchParams }: PageProps<"/admin/simulados">) {
  const { staff } = await exigirStaff();
  const gestor = staff.papel !== "DOCENTE";
  const sp = await searchParams;

  // RLS já limita aos simulados dos cursos do perfil.
  const supabase = await createClient();
  const { data, error } = await supabase
    .from("sessoes")
    .select("id, titulo, curso, inicio, fim, duracao_minutos, questoes, publicada, sessoes_participacao(count)")
    .eq("tipo", "SIMULADO")
    .order("inicio", { ascending: false })
    .limit(200);
  const simulados = (data ?? []) as unknown as Linha[];
  const agora = agoraMs();

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Simulados</h1>
          <p className="text-muted-foreground">Provas cronometradas no formato ENADE e seus relatórios.</p>
        </div>
        {gestor && (
          <Link href="/admin/simulados/novo" className={buttonVariants()}>
            Novo simulado
          </Link>
        )}
      </div>

      {sp.salvo === "1" && (
        <Alert>
          <AlertDescription>Simulado salvo.</AlertDescription>
        </Alert>
      )}
      {sp.excluido === "1" && (
        <Alert>
          <AlertDescription>Simulado excluído.</AlertDescription>
        </Alert>
      )}
      {error && (
        <Alert variant="destructive">
          <AlertDescription>Não foi possível carregar os simulados: {error.message}</AlertDescription>
        </Alert>
      )}

      {simulados.length === 0 ? (
        <div className="rounded-xl border border-dashed bg-background p-10 text-center">
          <p className="font-medium">Nenhum simulado ainda.</p>
          <p className="text-sm text-muted-foreground">
            {gestor ? "Monte o primeiro a partir das questões publicadas." : "A coordenação ainda não criou simulados."}
          </p>
        </div>
      ) : (
        <div className="overflow-x-auto rounded-xl border bg-background">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Simulado</TableHead>
                <TableHead>Curso</TableHead>
                <TableHead>Janela</TableHead>
                <TableHead className="text-right">Questões</TableHead>
                <TableHead className="text-right">Participantes</TableHead>
                <TableHead>Situação</TableHead>
                <TableHead />
              </TableRow>
            </TableHeader>
            <TableBody>
              {simulados.map((s) => {
                const st = situacao(s, agora);
                const podeEditar = staff.papel === "ADMIN" || (gestor && !!s.curso && !!staff.cursos?.includes(s.curso));
                return (
                  <TableRow key={s.id}>
                    <TableCell className="font-medium">
                      {podeEditar ? (
                        <Link href={`/admin/simulados/${s.id}`} className="hover:underline">
                          {s.titulo}
                        </Link>
                      ) : (
                        s.titulo
                      )}
                      <span className="block text-xs font-normal text-muted-foreground">
                        {formatarDuracao(s.duracao_minutos)} de prova
                      </span>
                    </TableCell>
                    <TableCell>{s.curso ? SIGLA_CURSO[s.curso] : "Todos"}</TableCell>
                    <TableCell className="whitespace-normal text-xs">
                      {formatarDataHora(s.inicio)} a {formatarDataHora(s.fim)}
                    </TableCell>
                    <TableCell className="text-right tabular-nums">{s.questoes.length}</TableCell>
                    <TableCell className="text-right tabular-nums">{s.sessoes_participacao[0]?.count ?? 0}</TableCell>
                    <TableCell>
                      <Badge variant={st.variante}>{st.rotulo}</Badge>
                    </TableCell>
                    <TableCell className="text-right">
                      {s.publicada && (
                        <Link
                          href={`/admin/simulados/${s.id}/relatorio`}
                          className={buttonVariants({ variant: "outline", size: "sm" })}
                        >
                          Relatório
                        </Link>
                      )}
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </div>
      )}
    </>
  );
}
