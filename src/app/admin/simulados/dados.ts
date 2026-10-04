import "server-only";
import type { Curso } from "@/lib/cursos";
import type { Componente, Formato } from "@/lib/questoes";
import { createClient } from "@/lib/supabase/server";

export type QuestaoBanco = {
  id: string;
  componente: Componente;
  cursos: (Curso | "ALL")[];
  eixo: string;
  formato: Formato;
  dificuldade: number;
  enunciado: string;
  status: string;
};

// Questões publicadas visíveis ao perfil (RLS) — candidatas a entrar no simulado.
// `incluir` traz também questões já escolhidas que deixaram de estar publicadas.
export async function carregarBanco(incluir: string[] = []): Promise<QuestaoBanco[]> {
  const supabase = await createClient();
  const campos = "id, componente, cursos, eixo, formato, dificuldade, enunciado, status";
  const [{ data: publicadas }, { data: extras }] = await Promise.all([
    supabase.from("questoes").select(campos).eq("status", "PUBLICADA").order("eixo").limit(2000),
    incluir.length
      ? supabase.from("questoes").select(campos).in("id", incluir).neq("status", "PUBLICADA")
      : Promise.resolve({ data: [] }),
  ]);
  return [...((publicadas ?? []) as QuestaoBanco[]), ...((extras ?? []) as QuestaoBanco[])];
}
