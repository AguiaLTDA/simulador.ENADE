import "server-only";
import { redirect } from "next/navigation";
import { destinoInicial, obterContexto } from "@/lib/contexto";
import type { SimuladoAluno } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";

// Aluno ativo + os simulados do curso dele.
export async function carregarSimuladosDoAluno() {
  const ctx = await obterContexto();
  if (!ctx.estudante || ctx.estudante.status !== "ATIVO") redirect(destinoInicial(ctx));
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("meus_simulados");
  if (error) throw new Error(`Falha ao carregar os simulados: ${error.message}`);
  return { estudante: ctx.estudante, simulados: (data ?? []) as SimuladoAluno[], supabase };
}
