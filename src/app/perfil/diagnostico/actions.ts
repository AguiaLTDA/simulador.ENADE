"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type QuestaoDiagnostico = {
  id: string;
  area: "PORTUGUES" | "ATUALIDADES" | "MATEMATICA";
  texto_apoio: string | null;
  enunciado: string;
  alternativas: Record<"A" | "B" | "C" | "D" | "E", string>;
};

export type EstadoDiagnostico = {
  concluido: boolean;
  questoes: QuestaoDiagnostico[];
  respondidas_ids: string[];
  erro?: string;
};

export async function iniciarDiagnostico(): Promise<EstadoDiagnostico> {
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("iniciar_diagnostico");
  if (error) return { concluido: false, questoes: [], respondidas_ids: [], erro: error.message };
  return data as EstadoDiagnostico;
}

export type RespostaDiagnostico = {
  concluido: boolean;
  respondidas: number;
  total: number;
  pontos?: number;
  erro?: string;
};

export async function responderDiagnostico(questaoId: string, alternativa: string): Promise<RespostaDiagnostico> {
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("responder_diagnostico", {
    p_questao_id: questaoId,
    p_alternativa: alternativa,
  });
  if (error) return { concluido: false, respondidas: 0, total: 0, erro: error.message };
  const r = data as RespostaDiagnostico;
  if (r.concluido) revalidatePath("/perfil");
  return r;
}
