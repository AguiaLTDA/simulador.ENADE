// Tipos, rótulos e utilitários de simulados (compartilhados entre servidor e cliente).
import type { Curso } from "@/lib/cursos";
import type { Componente, Formato, Letra } from "@/lib/questoes";

export type SituacaoSimulado = "AGENDADO" | "DISPONIVEL" | "EM_ANDAMENTO" | "CONCLUIDO" | "PERDIDO";

export const NOME_SITUACAO: Record<SituacaoSimulado, string> = {
  AGENDADO: "Agendado",
  DISPONIVEL: "Disponível",
  EM_ANDAMENTO: "Em andamento",
  CONCLUIDO: "Concluído",
  PERDIDO: "Encerrado",
};

// Item de meus_simulados()
export type SimuladoAluno = {
  id: string;
  titulo: string;
  curso: Curso | null;
  inicio: string;
  fim: string;
  duracao_minutos: number;
  total_questoes: number;
  iniciada_em: string | null;
  finalizada_em: string | null;
  termina_em: string | null;
  situacao: SituacaoSimulado;
  gabarito_liberado: boolean;
};

// Questão como o aluno recebe (sem gabarito).
export type QuestaoProva = {
  id: string;
  componente: Componente;
  eixo: string;
  formato: Formato;
  texto_apoio: string | null;
  enunciado: string;
  alternativas: Record<Letra, string> | null;
  dificuldade: number;
  peso_pontos: number;
};

// Retorno de iniciar_simulado()
export type ProvaEmAndamento = {
  sessao_id: string;
  titulo: string;
  iniciada_em: string;
  termina_em: string;
  questoes: QuestaoProva[];
  respondidas: string[];
};

export type DesempenhoComponente = {
  obj_total: number;
  obj_acertos: number;
  disc_total: number;
  disc_pendentes: number;
  nota: number | null;
};

// interno.desempenho_simulado()
export type Desempenho = {
  componentes: Partial<Record<Componente, DesempenhoComponente>>;
  nota: number | null;
  pendentes: number;
  respondidas: number;
  total: number;
  pontos: number;
};

export type QuestaoResultado = QuestaoProva & {
  numero: number;
  gabarito: Letra | null;
  justificativa: string | null;
  alternativa: Letra | null;
  resposta_texto: string | null;
  correta: boolean | null;
  nota: number | null;
  comentario: string | null;
  tempo_segundos: number | null;
  pontos: number;
};

// resultado_simulado()
export type ResultadoAluno = {
  sessao: { id: string; titulo: string; curso: Curso | null; inicio: string; fim: string; duracao_minutos: number };
  iniciada_em: string;
  finalizada_em: string;
  gabarito_liberado: boolean;
  desempenho: Desempenho;
  media_participantes: number | null;
  participantes: number;
  questoes: QuestaoResultado[] | null;
};

// Composição da prova do ENADE (portaria do Inep): Formação Geral com 2
// discursivas e 8 objetivas; Componente Específico com 3 discursivas e 27 objetivas.
export const PADRAO_ENADE: { componente: Componente; formato: Formato; quantidade: number; rotulo: string }[] = [
  { componente: "FG", formato: "DISCURSIVA", quantidade: 2, rotulo: "FG discursivas" },
  { componente: "FG", formato: "OBJETIVA", quantidade: 8, rotulo: "FG objetivas" },
  { componente: "CE", formato: "DISCURSIVA", quantidade: 3, rotulo: "CE discursivas" },
  { componente: "CE", formato: "OBJETIVA", quantidade: 27, rotulo: "CE objetivas" },
];
export const DURACAO_ENADE_MIN = 240;

// Ordem do caderno: FG discursivas, FG objetivas, CE discursivas, CE objetivas.
export function ordemCaderno(q: { componente: Componente; formato: Formato }): number {
  return PADRAO_ENADE.findIndex((p) => p.componente === q.componente && p.formato === q.formato);
}

// ---------------------------------------------------------------------------
// Datas — horário de Brasília (sem horário de verão desde 2019).
// ---------------------------------------------------------------------------
const FUSO = "America/Sao_Paulo";
const DESLOCAMENTO_MS = 3 * 60 * 60 * 1000;

export function formatarDataHora(iso: string): string {
  return new Intl.DateTimeFormat("pt-BR", { timeZone: FUSO, dateStyle: "short", timeStyle: "short" }).format(
    new Date(iso),
  );
}

// ISO → valor de <input type="datetime-local"> em horário de Brasília.
export function paraCampoLocal(iso: string): string {
  return new Date(new Date(iso).getTime() - DESLOCAMENTO_MS).toISOString().slice(0, 16);
}

// Valor de <input type="datetime-local"> (horário de Brasília) → ISO com fuso.
export function deCampoLocal(valor: string): string {
  return valor ? `${valor}:00-03:00` : "";
}

export function formatarDuracao(minutos: number): string {
  const h = Math.floor(minutos / 60);
  const m = minutos % 60;
  if (!h) return `${m} min`;
  return m ? `${h}h${String(m).padStart(2, "0")}` : `${h}h`;
}

export function formatarNota(n: number | null | undefined): string {
  return n === null || n === undefined ? "—" : Number(n).toLocaleString("pt-BR", { maximumFractionDigits: 1 });
}
