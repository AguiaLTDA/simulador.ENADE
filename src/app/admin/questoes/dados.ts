import "server-only";
import type { PesosPadrao } from "@/lib/questoes";
import { createClient } from "@/lib/supabase/server";

// Pesos padrão por dificuldade, lidos da tabela config (editável sem redeploy).
export async function carregarPesos(): Promise<PesosPadrao> {
  const supabase = await createClient();
  const { data } = await supabase
    .from("config")
    .select("chave, valor")
    .in("chave", ["pontos_facil", "pontos_media", "pontos_dificil"]);
  const v = Object.fromEntries((data ?? []).map((r) => [r.chave, Number(r.valor)]));
  return { 1: v.pontos_facil ?? 10, 2: v.pontos_media ?? 20, 3: v.pontos_dificil ?? 35 };
}

export async function carregarEixos(): Promise<string[]> {
  const supabase = await createClient();
  const { data } = await supabase.from("questoes").select("eixo").order("eixo");
  return [...new Set((data ?? []).map((r) => r.eixo as string))];
}
