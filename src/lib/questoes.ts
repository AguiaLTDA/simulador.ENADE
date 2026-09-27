// Tipos e rótulos de questões (compartilhados entre servidor e cliente).
import type { Curso } from "@/lib/cursos";

export type Componente = "FG" | "CE";
export type Formato = "OBJETIVA" | "DISCURSIVA";
export type StatusQuestao = "RASCUNHO" | "PUBLICADA" | "ARQUIVADA";
export type Letra = "A" | "B" | "C" | "D" | "E";

export const LETRAS: Letra[] = ["A", "B", "C", "D", "E"];

export const NOME_COMPONENTE: Record<Componente, string> = {
  FG: "Formação Geral",
  CE: "Componente Específico",
};

export const NOME_STATUS: Record<StatusQuestao, string> = {
  RASCUNHO: "Rascunho",
  PUBLICADA: "Publicada",
  ARQUIVADA: "Arquivada",
};

export const NOME_DIFICULDADE: Record<number, string> = { 1: "Fácil", 2: "Média", 3: "Difícil" };

// Dados editáveis de uma questão (o que o formulário envia para salvar_questao).
export type DadosQuestao = {
  id?: string;
  componente: Componente;
  cursos: Curso[];
  eixo: string;
  formato: Formato;
  texto_apoio: string;
  enunciado: string;
  alt_a: string;
  alt_b: string;
  alt_c: string;
  alt_d: string;
  alt_e: string;
  gabarito: Letra | "";
  justificativa: string;
  dificuldade: 1 | 2 | 3;
  peso_pontos: string; // vazio = padrão da dificuldade
  fonte: string;
  status: StatusQuestao;
};

export const QUESTAO_VAZIA: DadosQuestao = {
  componente: "CE",
  cursos: [],
  eixo: "",
  formato: "OBJETIVA",
  texto_apoio: "",
  enunciado: "",
  alt_a: "",
  alt_b: "",
  alt_c: "",
  alt_d: "",
  alt_e: "",
  gabarito: "",
  justificativa: "",
  dificuldade: 2,
  peso_pontos: "",
  fonte: "",
  status: "RASCUNHO",
};

export type PesosPadrao = Record<1 | 2 | 3, number>;
