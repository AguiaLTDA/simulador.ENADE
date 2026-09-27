"use server";

import { revalidatePath } from "next/cache";
import { exigirAdmin } from "@/lib/contexto";
import type { DadosQuestao } from "@/lib/questoes";
import { createClient } from "@/lib/supabase/server";

export type ResultadoAcao = { erro?: string; id?: string; resultado?: string };

// A validação completa (e a checagem de ADMIN) é feita de novo em salvar_questao.
export async function salvarQuestao(dados: DadosQuestao): Promise<ResultadoAcao> {
  await exigirAdmin();
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("salvar_questao", { p_dados: dados });
  if (error) return { erro: error.message };
  revalidatePath("/admin/questoes");
  revalidatePath("/admin");
  return { id: data as string };
}

export async function excluirQuestao(id: string): Promise<ResultadoAcao> {
  await exigirAdmin();
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("excluir_questao", { p_id: id });
  if (error) return { erro: error.message };
  revalidatePath("/admin/questoes");
  revalidatePath("/admin");
  return { resultado: data as string };
}
