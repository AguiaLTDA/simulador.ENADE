"use server";

import { revalidatePath } from "next/cache";
import { exigirGestor } from "@/lib/contexto";
import { createClient } from "@/lib/supabase/server";

export type ResultadoAcao = { erro?: string; ok?: boolean };

// Escopo por curso, limites e auditoria ficam em ajustar_pontuacao.
export async function lancarAjuste(
  estudanteId: string,
  pontos: number,
  motivo: string,
  sessaoId: string | null,
): Promise<ResultadoAcao> {
  await exigirGestor();
  const supabase = await createClient();
  const { error } = await supabase.rpc("ajustar_pontuacao", {
    p_estudante_id: estudanteId,
    p_pontos: pontos,
    p_motivo: motivo,
    p_sessao_id: sessaoId,
  });
  if (error) return { erro: error.message };
  revalidatePath("/admin/pontuacao");
  revalidatePath(`/admin/pontuacao/${estudanteId}`);
  return { ok: true };
}

export async function excluirAjuste(id: number, estudanteId: string): Promise<ResultadoAcao> {
  await exigirGestor();
  const supabase = await createClient();
  const { error } = await supabase.rpc("excluir_ajuste_pontuacao", { p_id: id });
  if (error) return { erro: error.message };
  revalidatePath("/admin/pontuacao");
  revalidatePath(`/admin/pontuacao/${estudanteId}`);
  return { ok: true };
}
