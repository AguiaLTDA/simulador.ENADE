// Valores compartilhados entre servidor e cliente (sem dependências de servidor).
export type Curso = "ENG_MEC" | "ENG_PROD" | "ADS";

export const NOME_CURSO: Record<Curso, string> = {
  ENG_MEC: "Engenharia Mecânica",
  ENG_PROD: "Engenharia de Produção",
  ADS: "Análise e Desenvolvimento de Sistemas",
};

export const SIGLA_CURSO: Record<Curso, string> = {
  ENG_MEC: "Eng. Mecânica",
  ENG_PROD: "Eng. Produção",
  ADS: "ADS",
};
