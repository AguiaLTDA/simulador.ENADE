import Link from "next/link";
import { Button, buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { NativeSelect } from "@/components/ui/native-select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { exigirGestor } from "@/lib/contexto";
import { CURSOS, SIGLA_CURSO, type Curso } from "@/lib/cursos";
import { formatarDataHora } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";
import { cn } from "@/lib/utils";

export const metadata = { title: "Pontuação — Portal Simulado ENADE" };

type LinhaPontuacao = {
  estudante_id: string;
  nome: string;
  curso: Curso;
  turma: string | null;
  tipo: "CONCLUINTE" | "INGRESSANTE" | null;
  pontos: number;
  pontos_questoes: number;
  pontos_atividades: number;
  pontos_extras: number;
  pontos_ajustes: number;
};

type Atividade = { id: string; titulo: string; curso: Curso | null; fim: string; pontos_atividade: number };

const agoraMs = () => Date.now();
const sinal = (n: number) => (n > 0 ? `+${n}` : String(n));

export default async function PontuacaoPage({ searchParams }: PageProps<"/admin/pontuacao">) {
  const { staff } = await exigirGestor();
  const sp = await searchParams;
  const cursosDoPerfil = staff.cursos ?? CURSOS;
  const curso = typeof sp.curso === "string" && cursosDoPerfil.includes(sp.curso as Curso) ? (sp.curso as Curso) : "";
  const busca = typeof sp.busca === "string" ? sp.busca.trim() : "";

  const supabase = await createClient();
  const [{ data, error }, { data: ativ }] = await Promise.all([
    supabase.rpc("pontuacao_equipe", { p_curso: curso || null }),
    supabase
      .from("sessoes")
      .select("id, titulo, curso, fim, pontos_atividade")
      .eq("tipo", "SIMULADO")
      .eq("publicada", true)
      .gt("pontos_atividade", 0)
      .order("fim", { ascending: false }),
  ]);
  if (error) throw new Error(`Falha ao carregar a pontuação: ${error.message}`);
  const termo = busca.toLowerCase();
  const alunos = ((data ?? []) as LinhaPontuacao[]).filter((a) => !termo || a.nome.toLowerCase().includes(termo));
  const atividades = (ativ ?? []) as Atividade[];
  const agora = agoraMs();

  return (
    <>
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Pontuação</h1>
        <p className="text-muted-foreground">
          De onde vêm os pontos de cada aluno, valor das atividades avaliativas e ajustes manuais (bônus ou
          desconto) com motivo registrado.
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Atividades avaliativas</CardTitle>
          <CardDescription>
            Simulados com valor em pontos. O aluno recebe valor × nota estimada ÷ 100 quando o gabarito é liberado.
            Para mudar o valor ou o prazo, edite o simulado.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {atividades.length === 0 ? (
            <p className="text-sm text-muted-foreground">Nenhum simulado com valor em pontos.</p>
          ) : (
            <ul className="divide-y">
              {atividades.map((a) => (
                <li key={a.id} className="flex flex-wrap items-center justify-between gap-3 py-2.5 text-sm">
                  <span className="min-w-0">
                    <span className="font-medium">{a.titulo}</span>
                    <span className="block text-xs text-muted-foreground">
                      {a.curso ? SIGLA_CURSO[a.curso] : "Todos os cursos"} ·{" "}
                      {Date.parse(a.fim) > agora ? "prazo" : "encerrou"} {formatarDataHora(a.fim)}
                    </span>
                  </span>
                  <span className="flex items-center gap-3">
                    <span className="font-semibold tabular-nums">{a.pontos_atividade.toLocaleString("pt-BR")} pts</span>
                    <Link href={`/admin/simulados/${a.id}`} className={buttonVariants({ variant: "outline", size: "sm" })}>
                      Editar valor
                    </Link>
                  </span>
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>

      <form className="grid gap-3 rounded-xl border bg-background p-4 sm:grid-cols-[1fr_1fr_auto]">
        <Input name="busca" defaultValue={busca} placeholder="Buscar aluno pelo nome" aria-label="Buscar aluno" />
        <NativeSelect name="curso" defaultValue={curso} aria-label="Curso">
          <option value="">{cursosDoPerfil.length > 1 ? "Todos os cursos" : SIGLA_CURSO[cursosDoPerfil[0]]}</option>
          {cursosDoPerfil.length > 1 &&
            cursosDoPerfil.map((c) => (
              <option key={c} value={c}>
                {SIGLA_CURSO[c]}
              </option>
            ))}
        </NativeSelect>
        <Button type="submit" variant="outline">
          Filtrar
        </Button>
      </form>

      <div className="overflow-x-auto rounded-xl border bg-background">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Aluno</TableHead>
              <TableHead>Curso</TableHead>
              <TableHead className="text-right">Questões</TableHead>
              <TableHead className="text-right">Atividades</TableHead>
              <TableHead className="text-right">Extras</TableHead>
              <TableHead className="text-right">Ajustes</TableHead>
              <TableHead className="text-right">Total</TableHead>
              <TableHead />
            </TableRow>
          </TableHeader>
          <TableBody>
            {alunos.map((a) => (
              <TableRow key={a.estudante_id}>
                <TableCell>
                  <span className="font-medium">{a.nome}</span>
                  <span className="block text-xs text-muted-foreground">
                    {a.turma ?? "Sem turma"} · {a.tipo === "INGRESSANTE" ? "Ingressante" : "Concluinte"}
                  </span>
                </TableCell>
                <TableCell>{SIGLA_CURSO[a.curso]}</TableCell>
                <TableCell className="text-right tabular-nums">{a.pontos_questoes}</TableCell>
                <TableCell className="text-right tabular-nums">{a.pontos_atividades}</TableCell>
                <TableCell className="text-right tabular-nums">{a.pontos_extras}</TableCell>
                <TableCell
                  className={cn(
                    "text-right tabular-nums",
                    a.pontos_ajustes < 0 && "text-destructive",
                    a.pontos_ajustes > 0 && "text-verde",
                  )}
                >
                  {a.pontos_ajustes ? sinal(a.pontos_ajustes) : "—"}
                </TableCell>
                <TableCell className="text-right font-semibold tabular-nums">{a.pontos}</TableCell>
                <TableCell className="text-right">
                  <Link
                    href={`/admin/pontuacao/${a.estudante_id}`}
                    className={buttonVariants({ variant: "outline", size: "sm" })}
                  >
                    Gerenciar
                  </Link>
                </TableCell>
              </TableRow>
            ))}
            {alunos.length === 0 && (
              <TableRow>
                <TableCell colSpan={8} className="py-8 text-center text-muted-foreground">
                  Nenhum aluno ativo neste filtro.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
      <p className="text-xs text-muted-foreground">
        Questões = objetivas pontuadas e discursivas corrigidas (as de simulado entram quando o gabarito sai).
        Extras = diagnóstico inicial. Todo ajuste fica registrado na auditoria.
      </p>
    </>
  );
}
