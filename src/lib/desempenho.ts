import "server-only";
import { cache } from "react";
import type { Componente } from "@/lib/questoes";
import type { RankingAluno } from "@/lib/ranking";
import type { ResultadoAluno, SimuladoAluno } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";

export type Resumo = {
  pontos: number;
  questoes_respondidas: number;
  conquistas: { codigo: string; nome: string; descricao: string; icone: string | null; obtida_em: string }[];
  diagnostico: { iniciado: boolean; concluido: boolean; respondidas: number; total: number };
};

export type Semana = { inicio: string; rotulo: string; respondidas: number; objetivas: number; acertos: number };
export type Area = { componente: Componente; eixo: string; total: number; acertos: number };
export type SimuladoFeito = { id: string; titulo: string; nota: number | null; quando: string; liberado: boolean };

export type Evolucao = {
  respondidas: number; // respostas visíveis (treino + simulados com gabarito liberado)
  objetivas: number;
  acertos: number;
  semanas: Semana[];
  componentes: Area[]; // agregado por FG/CE
  eixos: Area[];
  simulados: SimuladoFeito[];
};

const SEMANAS = 8;
const DIA = 86_400_000;
const FUSO_MS = 3 * 3_600_000; // horário de Brasília

// Segunda-feira (00h, horário de Brasília) da semana de uma data, em ms UTC.
function inicioDaSemana(ms: number): number {
  const local = new Date(ms - FUSO_MS);
  const dia = (local.getUTCDay() + 6) % 7; // 0 = segunda
  return Date.UTC(local.getUTCFullYear(), local.getUTCMonth(), local.getUTCDate() - dia) + FUSO_MS;
}

const rotuloSemana = (ms: number) => {
  const d = new Date(ms - FUSO_MS);
  return `${String(d.getUTCDate()).padStart(2, "0")}/${String(d.getUTCMonth() + 1).padStart(2, "0")}`;
};

// Tudo o que o painel e "Meu desempenho" mostram — só dados reais do aluno.
// Por RLS, o aluno lê as próprias respostas de treino e as de simulado cujo gabarito já saiu.
export const carregarDesempenho = cache(async () => {
  const agora = Date.now();
  const supabase = await createClient();
  const [resumoR, simuladosR, rankingR, catalogoR, respostasR] = await Promise.all([
    supabase.rpc("meu_resumo"),
    supabase.rpc("meus_simulados"),
    supabase.rpc("ranking_aluno", { p_escopo: "CURSO", p_periodo: "TOTAL" }),
    supabase.from("conquistas").select("codigo, nome, descricao, icone").order("ordem"),
    supabase
      .from("respostas")
      .select("criado_em, correta, alternativa, tentativa_n")
      .order("criado_em", { ascending: true })
      .limit(5000),
  ]);

  const resumo = resumoR.data as Resumo;
  const simulados = (simuladosR.data ?? []) as SimuladoAluno[];
  const ranking = (rankingR.data ?? null) as RankingAluno | null;
  const catalogo = (catalogoR.data ?? []) as { codigo: string; nome: string; descricao: string; icone: string | null }[];
  const respostas = (respostasR.data ?? []) as {
    criado_em: string;
    correta: boolean | null;
    alternativa: string | null;
    tentativa_n: number;
  }[];

  // Semanas: as últimas 8, terminando na atual.
  const atual = inicioDaSemana(agora);
  const semanas: Semana[] = Array.from({ length: SEMANAS }, (_, i) => {
    const ms = atual - (SEMANAS - 1 - i) * 7 * DIA;
    return { inicio: new Date(ms).toISOString(), rotulo: rotuloSemana(ms), respondidas: 0, objetivas: 0, acertos: 0 };
  });
  let objetivas = 0;
  let acertos = 0;
  for (const r of respostas) {
    const ms = Date.parse(r.criado_em);
    const primeiraObjetiva = r.alternativa !== null && r.tentativa_n === 1;
    if (primeiraObjetiva) {
      objetivas += 1;
      if (r.correta) acertos += 1;
    }
    const i = SEMANAS - 1 - Math.round((atual - inicioDaSemana(ms)) / (7 * DIA));
    if (i >= 0 && i < SEMANAS) {
      semanas[i].respondidas += 1;
      if (primeiraObjetiva) {
        semanas[i].objetivas += 1;
        if (r.correta) semanas[i].acertos += 1;
      }
    }
  }

  // Simulados concluídos: nota de cada um; áreas só quando o gabarito já foi liberado.
  const concluidos = simulados.filter((s) => s.situacao === "CONCLUIDO");
  const resultados = await Promise.all(
    concluidos.map(async (s) => {
      const { data } = await supabase.rpc("resultado_simulado", { p_sessao_id: s.id });
      return data as ResultadoAluno | null;
    }),
  );
  const porEixo = new Map<string, Area>();
  const porComponente = new Map<Componente, Area>();
  const feitos: SimuladoFeito[] = [];
  for (const r of resultados) {
    if (!r) continue;
    feitos.push({
      id: r.sessao.id,
      titulo: r.sessao.titulo,
      nota: r.desempenho.nota === null ? null : Number(r.desempenho.nota),
      quando: r.finalizada_em,
      liberado: r.gabarito_liberado,
    });
    for (const q of r.questoes ?? []) {
      if (q.formato !== "OBJETIVA") continue;
      const chave = `${q.componente}|${q.eixo}`;
      const e = porEixo.get(chave) ?? { componente: q.componente, eixo: q.eixo, total: 0, acertos: 0 };
      const c = porComponente.get(q.componente) ?? { componente: q.componente, eixo: "", total: 0, acertos: 0 };
      e.total += 1;
      c.total += 1;
      if (q.correta) {
        e.acertos += 1;
        c.acertos += 1;
      }
      porEixo.set(chave, e);
      porComponente.set(q.componente, c);
    }
  }
  feitos.sort((a, b) => Date.parse(a.quando) - Date.parse(b.quando));

  const evolucao: Evolucao = {
    respondidas: respostas.length,
    objetivas,
    acertos,
    semanas,
    componentes: (["FG", "CE"] as Componente[]).flatMap((c) => (porComponente.has(c) ? [porComponente.get(c)!] : [])),
    eixos: [...porEixo.values()].sort((a, b) => a.acertos / a.total - b.acertos / b.total),
    simulados: feitos,
  };

  return { resumo, simulados, ranking, catalogo, evolucao };
});
