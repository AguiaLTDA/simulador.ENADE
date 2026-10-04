"use server";

import { revalidatePath } from "next/cache";
import { exigirStaff } from "@/lib/contexto";
import { createClient } from "@/lib/supabase/server";

export type ResultadoCorrecao = { erro?: string; pontos?: number };

// Escopo por curso e cálculo dos pontos ficam em corrigir_discursiva.
export async function corrigirDiscursiva(
  respostaId: string,
  nota: number,
  comentario: string,
): Promise<ResultadoCorrecao> {
  await exigirStaff();
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("corrigir_discursiva", {
    p_resposta_id: respostaId,
    p_nota: nota,
    p_comentario: comentario.trim() || null,
  });
  if (error) return { erro: error.message };
  revalidatePath("/admin/correcoes");
  revalidatePath("/admin/simulados");
  return { pontos: (data as { pontos: number }).pontos };
}
