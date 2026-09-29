import Link from "next/link";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { exigirStaff } from "@/lib/contexto";
import { descreverPerfil } from "@/lib/cursos";
import { createClient } from "@/lib/supabase/server";

// Os números já respeitam o escopo do perfil (RLS filtra por curso).
export default async function AdminPage() {
  const { staff } = await exigirStaff();
  const supabase = await createClient();

  const contar = async (
    tabela: "questoes" | "estudantes" | "diagnostico_resultados",
    filtro?: (q: any) => any, // eslint-disable-line @typescript-eslint/no-explicit-any
  ) => {
    let q = supabase.from(tabela).select("*", { count: "exact", head: true });
    if (filtro) q = filtro(q);
    const { count } = await q;
    return count ?? 0;
  };

  const [publicadas, rascunhos, alunos, diagnosticos] = await Promise.all([
    contar("questoes", (q) => q.eq("status", "PUBLICADA")),
    contar("questoes", (q) => q.eq("status", "RASCUNHO")),
    contar("estudantes"),
    contar("diagnostico_resultados", (q) => q.not("concluido_em", "is", null)),
  ]);

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Painel da coordenação</h1>
          <p className="text-muted-foreground">
            {staff.nome} · {descreverPerfil(staff.papel, staff.cursos)}
          </p>
        </div>
        {staff.papel !== "DOCENTE" && (
          <Link href="/admin/questoes/nova" className={buttonVariants()}>
            Nova questão
          </Link>
        )}
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {[
          ["Questões publicadas", publicadas, "Visíveis para os alunos no treino"],
          ["Rascunhos", rascunhos, "Ainda não visíveis para os alunos"],
          ["Alunos cadastrados", alunos, staff.cursos ? "Nos cursos do seu perfil" : "Em todos os cursos"],
          ["Diagnósticos concluídos", diagnosticos, `de ${alunos} aluno(s)`],
        ].map(([titulo, valor, dica]) => (
          <Card key={String(titulo)}>
            <CardHeader>
              <CardDescription>{titulo}</CardDescription>
              <CardTitle className="text-3xl tabular-nums">{valor}</CardTitle>
              <p className="text-xs text-muted-foreground">{dica}</p>
            </CardHeader>
          </Card>
        ))}
      </div>
    </>
  );
}
