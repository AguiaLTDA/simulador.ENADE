"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type ResultadoAcao = { erro?: string };

// Toda a validação (curso, janela, tempo, resposta única) é feita no banco.
export async function iniciarSimulado(sessaoId: string): Promise<ResultadoAcao> {
  const supabase = await createClient();
  const { error } = await supabase.rpc("iniciar_simulado", { p_sessao_id: sessaoId });
  if (error) return { erro: error.message };
  revalidatePath("/simulados");
  return {};
}

export async function responderSimulado(
  sessaoId: string,
  questaoId: string,
  resposta: { alternativa?: string; texto?: string },
): Promise<ResultadoAcao> {
  const supabase = await createClient();
  const { error } = await supabase.rpc("responder_questao", {
    p_questao_id: questaoId,
    p_alternativa: resposta.alternativa ?? null,
    p_resposta_texto: resposta.texto ?? null,
    p_sessao_id: sessaoId,
  });
  if (error) return { erro: error.message };
  return {};
}

export async function finalizarSimulado(sessaoId: string): Promise<ResultadoAcao> {
  const supabase = await createClient();
  const { error } = await supabase.rpc("finalizar_simulado", { p_sessao_id: sessaoId });
  // Já finalizado (ou tempo esgotado e finalizado em outra aba): segue para o resultado.
  if (error && !/Nenhum simulado em andamento/.test(error.message)) return { erro: error.message };
  revalidatePath("/simulados");
  revalidatePath("/perfil");
  revalidatePath("/inicio");
  return {};
}
