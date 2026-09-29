// Valores compartilhados entre servidor e cliente (sem dependências de servidor).
export type Curso = "ENG_MEC" | "ENG_PROD" | "ADS" | "VET" | "ARQ";

export const CURSOS: Curso[] = ["ENG_MEC", "ENG_PROD", "ADS", "VET", "ARQ"];

export const NOME_CURSO: Record<Curso, string> = {
  ENG_MEC: "Engenharia Mecânica",
  ENG_PROD: "Engenharia de Produção",
  ADS: "Análise e Desenvolvimento de Sistemas",
  VET: "Medicina Veterinária",
  ARQ: "Arquitetura e Urbanismo",
};

export const SIGLA_CURSO: Record<Curso, string> = {
  ENG_MEC: "Eng. Mecânica",
  ENG_PROD: "Eng. Produção",
  ADS: "ADS",
  VET: "Med. Veterinária",
  ARQ: "Arquitetura",
};

export type Papel = "ADMIN" | "COORDENADOR" | "DOCENTE";

// Rótulo curto do perfil da equipe, ex.: "Coordenação — Medicina Veterinária".
export function descreverPerfil(papel: Papel, cursos: Curso[] | null): string {
  if (papel === "ADMIN") return "Administração geral";
  const lista = (cursos ?? []).map((c) => (cursos!.length > 1 ? SIGLA_CURSO[c] : NOME_CURSO[c])).join(", ");
  return `${papel === "COORDENADOR" ? "Coordenação" : "Docente"} — ${lista}`;
}
