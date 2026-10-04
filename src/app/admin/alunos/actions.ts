"use server";

import { revalidatePath } from "next/cache";
import { exigirAdminGeral, exigirGestor } from "@/lib/contexto";
import type { Curso } from "@/lib/cursos";
import { createClient } from "@/lib/supabase/server";

export type DadosAluno = {
  nome: string;
  cpf: string;
  data_nascimento: string;
  telefone: string;
  curso: Curso;
  turma: string;
  tipo: "CONCLUINTE" | "INGRESSANTE";
  matricula: string;
  status: "ATIVO" | "PENDENTE" | "BLOQUEADO";
};

export type ResultadoAcao = { erro?: string; ok?: boolean };

// Escopo por curso e validações ficam em atualizar_estudante.
export async function atualizarAluno(id: string, dados: DadosAluno): Promise<ResultadoAcao> {
  await exigirGestor();
  const supabase = await createClient();
  const { error } = await supabase.rpc("atualizar_estudante", { p_id: id, p_dados: dados });
  if (error) return { erro: error.message };
  revalidatePath("/admin/alunos");
  revalidatePath(`/admin/alunos/${id}`);
  return { ok: true };
}

export async function excluirAlunoLgpd(id: string): Promise<ResultadoAcao> {
  await exigirAdminGeral();
  const supabase = await createClient();
  const { error } = await supabase.rpc("excluir_estudante_lgpd", { p_estudante_id: id });
  if (error) return { erro: error.message };
  revalidatePath("/admin/alunos");
  return { ok: true };
}
