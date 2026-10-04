"use server";

import { revalidatePath } from "next/cache";
import { exigirGestor } from "@/lib/contexto";
import type { DadosQuestao } from "@/lib/questoes";
import { createClient } from "@/lib/supabase/server";

export type ResultadoImportacao = {
  validas?: number;
  erros?: { linha: number; erro: string }[];
  erro?: string;
};

// simular = true: valida linha a linha com as regras do banco, sem gravar.
// simular = false: grava tudo ou nada.
export async function importarQuestoes(
  linhas: (DadosQuestao & { _linha: number })[],
  simular: boolean,
): Promise<ResultadoImportacao> {
  await exigirGestor();
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("importar_questoes", { p_linhas: linhas, p_simular: simular });
  if (error) return { erro: error.message };
  if (!simular) {
    revalidatePath("/admin/questoes");
    revalidatePath("/admin");
  }
  return data as ResultadoImportacao;
}
