import "server-only";
import { CURSOS, type Curso } from "@/lib/cursos";
import { lerPeriodo, type RankingEquipe } from "@/lib/ranking";
import { createClient } from "@/lib/supabase/server";

export type FiltrosRanking = {
  curso: Curso | "";
  turma: string;
  tipo: "" | "CONCLUINTE" | "INGRESSANTE";
  periodo: ReturnType<typeof lerPeriodo>;
};

export function lerFiltros(sp: Record<string, string | string[] | undefined>): FiltrosRanking {
  const s = (k: string) => (typeof sp[k] === "string" ? (sp[k] as string).trim() : "");
  const curso = s("curso");
  const tipo = s("tipo");
  return {
    curso: CURSOS.includes(curso as Curso) ? (curso as Curso) : "",
    turma: s("turma"),
    tipo: tipo === "CONCLUINTE" || tipo === "INGRESSANTE" ? tipo : "",
    periodo: lerPeriodo(s("periodo")),
  };
}

// ranking_equipe já restringe aos alunos dos cursos do perfil.
export async function carregarRanking(f: FiltrosRanking): Promise<RankingEquipe> {
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("ranking_equipe", {
    p_curso: f.curso || null,
    p_turma: f.turma || null,
    p_tipo: f.tipo || null,
    p_periodo: f.periodo,
  });
  if (error) throw new Error(error.message);
  return data as RankingEquipe;
}
