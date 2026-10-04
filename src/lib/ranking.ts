// Tipos e rótulos da classificação (compartilhados entre servidor e cliente).
import type { Curso } from "@/lib/cursos";

export type Escopo = "CURSO" | "TURMA" | "GERAL";
export type Periodo = "TOTAL" | "MES" | "SEMANA";

export const NOME_ESCOPO: Record<Escopo, string> = { CURSO: "Meu curso", TURMA: "Minha turma", GERAL: "Todos os cursos" };
export const NOME_PERIODO: Record<Periodo, string> = {
  TOTAL: "Desde o início",
  MES: "Últimos 30 dias",
  SEMANA: "Últimos 7 dias",
};

export const lerEscopo = (v: unknown): Escopo => (v === "TURMA" || v === "GERAL" ? v : "CURSO");
export const lerPeriodo = (v: unknown): Periodo => (v === "MES" || v === "SEMANA" ? v : "TOTAL");

// ranking_aluno()
export type RankingAluno = {
  escopo: Escopo;
  periodo: Periodo;
  participantes: number;
  eu: { posicao: number | null; pontos: number; respondidas: number; acertos: number; objetivas: number };
  lideres: { posicao: number; nome: string; curso: Curso; turma: string; pontos: number; eu: boolean }[];
};

// ranking_equipe()
export type AlunoRanking = {
  estudante_id: string;
  posicao: number | null;
  nome: string;
  email: string;
  curso: Curso;
  turma: string;
  tipo: "CONCLUINTE" | "INGRESSANTE";
  pontos: number;
  respondidas: number;
  objetivas: number;
  acertos: number;
  simulados: number;
  ultima_atividade: string | null;
};
export type RankingEquipe = { alunos: AlunoRanking[]; turmas: string[] };

export const percentual = (a: number, t: number) => (t ? Math.round((100 * a) / t) : null);
