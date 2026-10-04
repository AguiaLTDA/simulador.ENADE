// Conversão da planilha de importação ↔ dados de salvar_questao.
import { CURSOS, type Curso } from "@/lib/cursos";
import { escreverCsv, lerCsv, normalizarChave } from "@/lib/csv";
import type { DadosQuestao } from "@/lib/questoes";

export const COLUNAS = [
  "componente", "cursos", "eixo", "formato", "dificuldade", "texto_apoio", "enunciado",
  "alt_a", "alt_b", "alt_c", "alt_d", "alt_e", "gabarito", "justificativa", "peso", "fonte", "situacao",
] as const;

// Nomes alternativos de cabeçalho aceitos.
const SINONIMOS: Record<string, (typeof COLUNAS)[number]> = {
  alternativa_a: "alt_a", alternativa_b: "alt_b", alternativa_c: "alt_c", alternativa_d: "alt_d", alternativa_e: "alt_e",
  a: "alt_a", b: "alt_b", c: "alt_c", d: "alt_d", e: "alt_e",
  curso: "cursos", texto_de_apoio: "texto_apoio", resposta: "gabarito", resposta_correta: "gabarito",
  padrao_de_resposta: "justificativa", peso_pontos: "peso", status: "situacao", conteudo: "eixo",
};

const CURSO_POR_NOME: Record<string, Curso> = {
  eng_mec: "ENG_MEC", mec: "ENG_MEC", mecanica: "ENG_MEC", engenharia_mecanica: "ENG_MEC",
  eng_prod: "ENG_PROD", prod: "ENG_PROD", producao: "ENG_PROD", engenharia_de_producao: "ENG_PROD",
  ads: "ADS", analise_e_desenvolvimento_de_sistemas: "ADS",
  vet: "VET", veterinaria: "VET", medicina_veterinaria: "VET",
  arq: "ARQ", arquitetura: "ARQ", arquitetura_e_urbanismo: "ARQ",
};

export type LinhaImportacao = {
  linha: number; // número da linha na planilha (cabeçalho = 1)
  dados: DadosQuestao & { _linha: number };
  erros: string[];
};

export function modeloCsv(): string {
  return escreverCsv([
    [...COLUNAS],
    ["FG", "", "Ética e cidadania", "OBJETIVA", "2", "Texto de apoio (opcional).",
     "Enunciado da questão de Formação Geral.", "Alternativa A", "Alternativa B", "Alternativa C",
     "Alternativa D", "Alternativa E", "B", "Por que a B está correta.", "", "ENADE 2023", "RASCUNHO"],
    ["CE", "VET", "Clínica médica", "DISCURSIVA", "3", "", "Enunciado da discursiva do curso.",
     "", "", "", "", "", "", "Padrão de resposta esperado.", "", "Autoria própria", "RASCUNHO"],
  ]);
}

export function interpretarPlanilha(texto: string): { linhas: LinhaImportacao[]; erroGeral?: string } {
  const tabela = lerCsv(texto);
  if (tabela.length < 2) return { linhas: [], erroGeral: "A planilha precisa do cabeçalho e de ao menos uma questão." };

  const cabecalho = tabela[0].map((h) => {
    const k = normalizarChave(h);
    return (COLUNAS as readonly string[]).includes(k) ? k : (SINONIMOS[k] ?? null);
  });
  const faltando = ["componente", "eixo", "enunciado", "dificuldade"].filter((c) => !cabecalho.includes(c));
  if (faltando.length) {
    return { linhas: [], erroGeral: `Colunas obrigatórias ausentes: ${faltando.join(", ")}. Use o modelo.` };
  }

  const linhas = tabela.slice(1).map((valores, i): LinhaImportacao => {
    const v: Record<string, string> = {};
    cabecalho.forEach((col, j) => {
      if (col) v[col] = (valores[j] ?? "").trim();
    });
    const erros: string[] = [];

    const comp = normalizarChave(v.componente ?? "");
    const componente = comp.startsWith("fg") || comp.includes("geral") ? "FG"
      : comp.startsWith("ce") || comp.includes("especifico") ? "CE" : null;
    if (!componente) erros.push("componente deve ser FG ou CE");

    const cursos: Curso[] = [];
    for (const t of (v.cursos ?? "").split(/[,|/+]/).map(normalizarChave).filter(Boolean)) {
      const c = CURSO_POR_NOME[t] ?? (CURSOS.includes(t.toUpperCase() as Curso) ? (t.toUpperCase() as Curso) : null);
      if (c) {
        if (!cursos.includes(c)) cursos.push(c);
      } else erros.push(`curso desconhecido: ${t}`);
    }

    const fmt = normalizarChave(v.formato ?? "");
    const formato = !fmt || fmt.startsWith("obj") || fmt === "o" ? "OBJETIVA"
      : fmt.startsWith("disc") || fmt === "d" ? "DISCURSIVA" : null;
    if (!formato) erros.push("formato deve ser OBJETIVA ou DISCURSIVA");

    const dif = normalizarChave(v.dificuldade ?? "");
    const dificuldade = ({ "1": 1, facil: 1, "2": 2, media: 2, medio: 2, "3": 3, dificil: 3 } as Record<string, 1 | 2 | 3>)[dif];
    if (!dificuldade) erros.push("dificuldade deve ser 1, 2 ou 3 (Fácil, Média, Difícil)");

    const sit = normalizarChave(v.situacao ?? "");
    const status = !sit || sit.startsWith("rasc") ? "RASCUNHO" : sit.startsWith("publ") ? "PUBLICADA" : null;
    if (!status) erros.push("situação deve ser RASCUNHO ou PUBLICADA");

    const peso = (v.peso ?? "").replace(",", ".");
    if (peso && !/^\d+$/.test(peso)) erros.push("peso deve ser um número inteiro");

    return {
      linha: i + 2,
      erros,
      dados: {
        _linha: i + 2,
        componente: componente ?? "CE",
        cursos,
        eixo: v.eixo ?? "",
        formato: formato ?? "OBJETIVA",
        texto_apoio: v.texto_apoio ?? "",
        enunciado: v.enunciado ?? "",
        alt_a: v.alt_a ?? "",
        alt_b: v.alt_b ?? "",
        alt_c: v.alt_c ?? "",
        alt_d: v.alt_d ?? "",
        alt_e: v.alt_e ?? "",
        gabarito: ((v.gabarito ?? "").toUpperCase() as DadosQuestao["gabarito"]),
        justificativa: v.justificativa ?? "",
        dificuldade: dificuldade ?? 2,
        peso_pontos: peso,
        fonte: v.fonte ?? "",
        status: status ?? "RASCUNHO",
      },
    };
  });
  return { linhas };
}
