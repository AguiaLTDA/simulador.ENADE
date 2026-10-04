import "server-only";
import type { Curso } from "@/lib/cursos";
import type { Componente, Formato, Letra } from "@/lib/questoes";
import type { Desempenho } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";

export type Relatorio = {
  sessao: {
    id: string;
    titulo: string;
    curso: Curso | null;
    inicio: string;
    fim: string;
    duracao_minutos: number;
    publicada: boolean;
  };
  elegiveis: number;
  questoes: {
    numero: number;
    id: string;
    componente: Componente;
    eixo: string;
    formato: Formato;
    dificuldade: number;
    enunciado: string;
    gabarito: Letra | null;
    respostas: Record<Letra, number> & {
      total: number;
      acertos: number;
      corrigidas: number;
      nota_media: number | null;
    };
  }[];
  participantes: {
    estudante_id: string;
    nome: string;
    curso: Curso;
    turma: string;
    tipo: "CONCLUINTE" | "INGRESSANTE";
    tentativa: number;
    iniciada_em: string;
    finalizada_em: string | null;
    encerrado: boolean;
    desempenho: Desempenho;
  }[];
  aguardando_nova_tentativa: { estudante_id: string; nome: string; turma: string; fim: string }[];
};

// relatorio_simulado já restringe aos alunos dos cursos do perfil.
export async function carregarRelatorio(id: string): Promise<Relatorio | null> {
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("relatorio_simulado", { p_sessao_id: id });
  if (error) return null;
  return data as Relatorio;
}
