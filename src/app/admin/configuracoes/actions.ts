"use server";

import { revalidatePath } from "next/cache";
import { exigirAdminGeral } from "@/lib/contexto";
import { createClient } from "@/lib/supabase/server";

export type ResultadoConfig = { erro?: string; alteradas?: number; questoes_atualizadas?: number };

// Limites e coerência entre valores são validados em salvar_config.
export async function salvarConfig(
  valores: Record<string, number>,
  atualizarQuestoes: boolean,
): Promise<ResultadoConfig> {
  await exigirAdminGeral();
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("salvar_config", {
    p_valores: valores,
    p_atualizar_questoes: atualizarQuestoes,
  });
  if (error) return { erro: error.message };
  revalidatePath("/admin/configuracoes");
  revalidatePath("/admin/questoes");
  return data as ResultadoConfig;
}
