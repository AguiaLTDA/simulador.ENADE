export type Area = "PORTUGUES" | "ATUALIDADES" | "MATEMATICA";
export type Nivel = "INICIAL" | "INTERMEDIARIO" | "AVANCADO";

export const AREAS: Area[] = ["PORTUGUES", "ATUALIDADES", "MATEMATICA"];

export const NOME_AREA: Record<Area, string> = {
  PORTUGUES: "Português",
  ATUALIDADES: "Atualidades",
  MATEMATICA: "Matemática e raciocínio lógico",
};

export const NOME_NIVEL: Record<Nivel, string> = {
  INICIAL: "Inicial",
  INTERMEDIARIO: "Intermediário",
  AVANCADO: "Avançado",
};

export type ResultadoArea = { acertos: number; total: number; percentual: number; nivel: Nivel };
