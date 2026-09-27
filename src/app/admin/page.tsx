import Link from "next/link";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { obterContexto } from "@/lib/contexto";
import { createClient } from "@/lib/supabase/server";

export default async function AdminPage() {
  const ctx = await obterContexto();
  const supabase = await createClient();

  const contar = async (tabela: "questoes" | "estudantes", filtro?: [string, string]) => {
    let q = supabase.from(tabela).select("*", { count: "exact", head: true });
    if (filtro) q = q.eq(filtro[0], filtro[1]);
    const { count } = await q;
    return count ?? 0;
  };

  const [publicadas, rascunhos, alunos] = await Promise.all([
    contar("questoes", ["status", "PUBLICADA"]),
    contar("questoes", ["status", "RASCUNHO"]),
    contar("estudantes"),
  ]);

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Painel da coordenação</h1>
          <p className="text-muted-foreground">Olá, {ctx.staff?.nome}.</p>
        </div>
        {ctx.staff?.papel === "ADMIN" && (
          <Link href="/admin/questoes/nova" className={buttonVariants()}>
            Nova questão
          </Link>
        )}
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        {[
          ["Questões publicadas", publicadas, "Visíveis para os alunos no treino"],
          ["Rascunhos", rascunhos, "Ainda não visíveis para os alunos"],
          ["Alunos cadastrados", alunos, "Contas de estudantes criadas"],
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
