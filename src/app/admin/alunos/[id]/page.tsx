import Link from "next/link";
import { notFound } from "next/navigation";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { exigirGestor } from "@/lib/contexto";
import { CURSOS, NOME_CURSO, type Curso } from "@/lib/cursos";
import { mascaraCpf, mascaraTelefone } from "@/lib/formatos";
import { formatarDataHora } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";
import { ExcluirLgpd } from "./excluir-lgpd";
import { FormularioAluno } from "./formulario-aluno";

export const metadata = { title: "Aluno — Portal Simulado ENADE" };

const ROTULO_CAMPO: Record<string, string> = {
  nome: "Nome", cpf: "CPF", data_nascimento: "Nascimento", telefone: "Telefone", curso: "Curso",
  turma: "Turma", tipo: "Situação", matricula: "Matrícula", status: "Status",
};

function descreverAuditoria(acao: string, d: Record<string, unknown>): string {
  if (acao === "ESTUDANTE_ALTERADO") {
    return Object.entries(d as Record<string, { de: unknown; para: unknown }>)
      .map(([k, v]) => `${ROTULO_CAMPO[k] ?? k}: ${v.de ?? "—"} → ${v.para ?? "—"}`)
      .join("; ");
  }
  if (acao === "NOVA_TENTATIVA") {
    return `Nova tentativa liberada em “${d.simulado}” (tentativa ${d.tentativa_anulada} anulada). Motivo: ${d.motivo}`;
  }
  return acao;
}

export default async function AlunoPage({ params }: PageProps<"/admin/alunos/[id]">) {
  const { staff } = await exigirGestor();
  const { id } = await params;
  if (!/^[0-9a-f-]{36}$/i.test(id)) notFound();

  const supabase = await createClient();
  const [{ data: a }, { data: participacoes }, { data: historico }, { data: equipe }, { data: resumo }, { data: liberacoes }] =
    await Promise.all([
      supabase.from("estudantes").select("*").eq("id", id).maybeSingle(),
      supabase
        .from("sessoes_participacao")
        .select("sessao_id, tentativa, iniciada_em, finalizada_em, sessoes(titulo)")
        .eq("estudante_id", id)
        .order("iniciada_em", { ascending: false }),
      supabase
        .from("auditoria")
        .select("acao, detalhes, autor_id, criado_em")
        .eq("alvo_tipo", "ESTUDANTE")
        .eq("alvo_id", id)
        .order("criado_em", { ascending: false })
        .limit(50),
      supabase.from("staff").select("user_id, nome"),
      supabase.from("respostas").select("pontos_ganhos").eq("estudante_id", id),
      supabase.from("sessoes_liberacoes").select("sessao_id, sessoes(titulo)").eq("estudante_id", id),
    ]);
  if (!a) notFound();

  // Tentativa anulada e o aluno ainda não recomeçou.
  const aguardando = [
    ...new Map(
      (liberacoes ?? [])
        .filter((l) => !(participacoes ?? []).some((p) => p.sessao_id === l.sessao_id))
        .map((l) => [l.sessao_id, (l.sessoes as unknown as { titulo: string } | null)?.titulo ?? ""]),
    ),
  ];
  const nomes = new Map((equipe ?? []).map((s) => [s.user_id, s.nome]));
  const pontos = (resumo ?? []).reduce((t, r) => t + r.pontos_ganhos, 0);
  // Coordenador só transfere entre os próprios cursos.
  const cursos = (staff.cursos ?? CURSOS) as Curso[];

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <Link href="/admin/alunos" className="text-sm text-muted-foreground hover:text-foreground">
            ← Alunos
          </Link>
          <h1 className="mt-1 text-2xl font-semibold tracking-tight">{a.nome}</h1>
          <p className="text-muted-foreground">
            {NOME_CURSO[a.curso as Curso]} · {a.turma} · {a.email_pessoal} · cadastrado em{" "}
            {formatarDataHora(a.criado_em)}
          </p>
        </div>
        <p className="text-sm text-muted-foreground">{pontos} pontos em questões objetivas</p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Perfil</CardTitle>
          <CardDescription>
            O e-mail é o login do aluno e não é alterado aqui. Bloquear impede o acesso sem apagar o histórico.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <FormularioAluno
            id={a.id}
            cursos={cursos.includes(a.curso) ? cursos : [a.curso, ...cursos]}
            inicial={{
              nome: a.nome,
              cpf: mascaraCpf(a.cpf),
              data_nascimento: a.data_nascimento,
              telefone: mascaraTelefone(a.telefone ?? ""),
              curso: a.curso,
              turma: a.turma,
              tipo: a.tipo,
              matricula: a.matricula ?? "",
              status: a.status,
            }}
          />
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Simulados</CardTitle>
          <CardDescription>Abra a revisão para ver as respostas ou liberar uma nova tentativa.</CardDescription>
        </CardHeader>
        <CardContent>
          {(participacoes?.length ?? 0) + aguardando.length > 0 ? (
            <ul className="divide-y text-sm">
              {aguardando.map(([sessaoId, titulo]) => (
                <li key={sessaoId} className="flex flex-wrap items-center justify-between gap-2 py-2">
                  <span>
                    {titulo}
                    <span className="block text-xs text-amber-700 dark:text-amber-400">
                      Nova tentativa liberada — aguardando o aluno recomeçar
                    </span>
                  </span>
                  <Link href={`/admin/simulados/${sessaoId}/aluno/${a.id}`} className="text-primary hover:underline">
                    Revisar
                  </Link>
                </li>
              ))}
              {(participacoes ?? []).map((p) => (
                <li key={p.sessao_id} className="flex flex-wrap items-center justify-between gap-2 py-2">
                  <span>
                    {(p.sessoes as unknown as { titulo: string } | null)?.titulo}
                    <span className="block text-xs text-muted-foreground">
                      {p.tentativa > 1 && `${p.tentativa}ª tentativa · `}iniciado em {formatarDataHora(p.iniciada_em)}
                      {p.finalizada_em ? ` · finalizado em ${formatarDataHora(p.finalizada_em)}` : " · não finalizado"}
                    </span>
                  </span>
                  <Link href={`/admin/simulados/${p.sessao_id}/aluno/${a.id}`} className="text-primary hover:underline">
                    Revisar
                  </Link>
                </li>
              ))}
            </ul>
          ) : (
            <p className="text-sm text-muted-foreground">Nenhum simulado iniciado.</p>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Histórico de alterações</CardTitle>
        </CardHeader>
        <CardContent>
          {historico && historico.length > 0 ? (
            <ul className="space-y-2 text-sm">
              {historico.map((h, i) => (
                <li key={i} className="border-t pt-2 first:border-t-0 first:pt-0">
                  <span className="text-muted-foreground">
                    {formatarDataHora(h.criado_em)} · {nomes.get(h.autor_id) ?? "—"}:
                  </span>{" "}
                  {descreverAuditoria(h.acao, (h.detalhes ?? {}) as Record<string, unknown>)}
                </li>
              ))}
            </ul>
          ) : (
            <p className="text-sm text-muted-foreground">Nenhuma alteração feita pela equipe.</p>
          )}
        </CardContent>
      </Card>

      {staff.papel === "ADMIN" && <ExcluirLgpd id={a.id} nome={a.nome} />}
    </>
  );
}
