import { redirect } from "next/navigation";
import { Pagina } from "@/components/aluno/pagina";
import { destinoInicial, obterContexto } from "@/lib/contexto";
import { createClient } from "@/lib/supabase/server";
import { DiagnosticoCliente } from "./diagnostico-cliente";

export const metadata = { title: "Diagnóstico inicial — Simulado ENADE UNIVC" };

export default async function DiagnosticoPage() {
  const ctx = await obterContexto();
  if (!ctx.estudante || ctx.estudante.status !== "ATIVO") redirect(destinoInicial(ctx));

  const supabase = await createClient();
  const { data } = await supabase.rpc("meu_resumo");
  const d = (data as { diagnostico: { concluido: boolean; respondidas: number; total: number } }).diagnostico;
  if (d.concluido) redirect("/conquistas");

  return (
    <Pagina titulo="Diagnóstico inicial" voltar={{ href: "/inicio", rotulo: "Início" }} largura="estreita">
      <DiagnosticoCliente respondidasAntes={d.respondidas} total={d.total} />
    </Pagina>
  );
}
