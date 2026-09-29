import Link from "next/link";
import { redirect } from "next/navigation";
import { Cabecalho } from "@/components/cabecalho";
import { NOME_CURSO, destinoInicial, obterContexto } from "@/lib/contexto";
import { createClient } from "@/lib/supabase/server";
import { DiagnosticoCliente } from "./diagnostico-cliente";

export const metadata = { title: "Diagnóstico inicial — Portal Simulado ENADE" };

export default async function DiagnosticoPage() {
  const ctx = await obterContexto();
  if (!ctx.estudante || ctx.estudante.status !== "ATIVO") redirect(destinoInicial(ctx));

  const supabase = await createClient();
  const { data } = await supabase.rpc("meu_resumo");
  const d = (data as { diagnostico: { concluido: boolean; respondidas: number; total: number } }).diagnostico;
  if (d.concluido) redirect("/perfil");

  return (
    <>
      <Cabecalho nome={ctx.estudante.nome} detalhe={`${NOME_CURSO[ctx.estudante.curso]} · ${ctx.estudante.turma}`} />
      <main className="mx-auto w-full max-w-2xl space-y-6 px-4 py-8">
        <div>
          <Link href="/perfil" className="text-sm text-muted-foreground hover:text-foreground">
            ← Meu perfil
          </Link>
          <h1 className="mt-1 text-2xl font-semibold tracking-tight">Diagnóstico inicial</h1>
        </div>
        <DiagnosticoCliente respondidasAntes={d.respondidas} total={d.total} />
      </main>
    </>
  );
}
