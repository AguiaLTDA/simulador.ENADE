import Link from "next/link";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { NativeSelect } from "@/components/ui/native-select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { exigirGestor } from "@/lib/contexto";
import { CURSOS, SIGLA_CURSO, type Curso } from "@/lib/cursos";
import { soDigitos } from "@/lib/formatos";
import { formatarDataHora } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";

export const metadata = { title: "Alunos — Portal Simulado ENADE" };

type Linha = {
  id: string;
  nome: string;
  email_pessoal: string;
  matricula: string | null;
  curso: Curso;
  turma: string;
  tipo: "CONCLUINTE" | "INGRESSANTE";
  status: "ATIVO" | "PENDENTE" | "BLOQUEADO";
  ultimo_acesso: string | null;
};

const VARIANTE = { ATIVO: "default", PENDENTE: "secondary", BLOQUEADO: "destructive" } as const;

export default async function AlunosPage({ searchParams }: PageProps<"/admin/alunos">) {
  const { staff } = await exigirGestor();
  const sp = await searchParams;
  const filtro = (k: string) => (typeof sp[k] === "string" ? (sp[k] as string).trim() : "");
  const busca = filtro("q");
  const curso = filtro("curso");
  const status = filtro("status");
  const cursosDoPerfil = staff.cursos ?? CURSOS;

  // RLS limita aos alunos dos cursos do perfil.
  const supabase = await createClient();
  let consulta = supabase
    .from("estudantes")
    .select("id, nome, email_pessoal, matricula, curso, turma, tipo, status, ultimo_acesso")
    .order("nome")
    .limit(500);
  if (curso) consulta = consulta.eq("curso", curso);
  if (status) consulta = consulta.eq("status", status);
  if (busca) {
    const termo = busca.replace(/[%,()]/g, " ");
    const cpf = soDigitos(busca);
    consulta = consulta.or(
      [`nome.ilike.%${termo}%`, `email_pessoal.ilike.%${termo}%`, `matricula.ilike.%${termo}%`, `turma.ilike.%${termo}%`,
       ...(cpf.length >= 3 ? [`cpf.like.%${cpf}%`] : [])].join(","),
    );
  }
  const { data, error } = await consulta;
  const alunos = (data ?? []) as Linha[];

  return (
    <>
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Alunos</h1>
        <p className="text-muted-foreground">
          {alunos.length} aluno(s) neste filtro. Clique no nome para editar o perfil, bloquear ou ver o histórico.
        </p>
      </div>

      {filtro("excluido") && (
        <Alert>
          <AlertDescription>Aluno e todos os seus dados foram excluídos (LGPD).</AlertDescription>
        </Alert>
      )}
      {error && (
        <Alert variant="destructive">
          <AlertDescription>Não foi possível carregar os alunos: {error.message}</AlertDescription>
        </Alert>
      )}

      <form className="grid gap-3 rounded-xl border bg-background p-4 sm:grid-cols-[1fr_auto_auto_auto]">
        <Input name="q" placeholder="Nome, e-mail, CPF, matrícula ou turma" defaultValue={busca} />
        <NativeSelect name="curso" defaultValue={curso} aria-label="Curso">
          <option value="">Todos os cursos</option>
          {cursosDoPerfil.map((c) => (
            <option key={c} value={c}>
              {SIGLA_CURSO[c]}
            </option>
          ))}
        </NativeSelect>
        <NativeSelect name="status" defaultValue={status} aria-label="Status">
          <option value="">Todos os status</option>
          <option value="ATIVO">Ativos</option>
          <option value="BLOQUEADO">Bloqueados</option>
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
              <TableHead>Turma</TableHead>
              <TableHead>Situação</TableHead>
              <TableHead>Último acesso</TableHead>
              <TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {alunos.map((a) => (
              <TableRow key={a.id}>
                <TableCell>
                  <Link href={`/admin/alunos/${a.id}`} className="font-medium hover:underline">
                    {a.nome}
                  </Link>
                  <span className="block text-xs text-muted-foreground">
                    {a.email_pessoal}
                    {a.matricula && ` · mat. ${a.matricula}`}
                  </span>
                </TableCell>
                <TableCell>{SIGLA_CURSO[a.curso]}</TableCell>
                <TableCell>{a.turma}</TableCell>
                <TableCell>{a.tipo === "CONCLUINTE" ? "Concluinte" : "Ingressante"}</TableCell>
                <TableCell className="text-xs">{a.ultimo_acesso ? formatarDataHora(a.ultimo_acesso) : "—"}</TableCell>
                <TableCell>
                  <Badge variant={VARIANTE[a.status]}>{a.status.toLowerCase()}</Badge>
                </TableCell>
              </TableRow>
            ))}
            {alunos.length === 0 && (
              <TableRow>
                <TableCell colSpan={6} className="py-8 text-center text-muted-foreground">
                  Nenhum aluno encontrado.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
    </>
  );
}
