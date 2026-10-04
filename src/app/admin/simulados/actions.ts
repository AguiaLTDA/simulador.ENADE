"use server";

import { revalidatePath } from "next/cache";
import { exigirGestor } from "@/lib/contexto";
import type { Curso } from "@/lib/cursos";
import { createClient } from "@/lib/supabase/server";

export type DadosSimulado = {
  id?: string;
  titulo: string;
  curso: Curso | null;
  inicio: string; // ISO com fuso
  fim: string;
  duracao_minutos: number;
  questoes: string[];
  publicada: boolean;
};

export type ResultadoAcao = { erro?: string; id?: string };

// Escopo por curso, janela e compatibilidade das questões são validados em salvar_simulado.
export async function salvarSimulado(dados: DadosSimulado): Promise<ResultadoAcao> {
  await exigirGestor();
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("salvar_simulado", { p_dados: dados });
  if (error) return { erro: error.message };
  revalidatePath("/admin/simulados");
  return { id: data as string };
}

export async function excluirSimulado(id: string): Promise<ResultadoAcao> {
  await exigirGestor();
  const supabase = await createClient();
  const { error } = await supabase.rpc("excluir_simulado", { p_id: id });
  if (error) return { erro: error.message };
  revalidatePath("/admin/simulados");
  return {};
}
