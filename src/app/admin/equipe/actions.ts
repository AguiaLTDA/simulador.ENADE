"use server";

import { revalidatePath } from "next/cache";
import { exigirAdminGeral } from "@/lib/contexto";
import type { Curso, Papel } from "@/lib/cursos";
import { createClient } from "@/lib/supabase/server";

export type EstadoEquipe = { erro?: string; ok?: string };

export async function definirMembro(dados: {
  email: string;
  nome: string;
  papel: Papel;
  cursos: Curso[];
}): Promise<EstadoEquipe> {
  await exigirAdminGeral();
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("definir_membro_equipe", {
    p_email: dados.email,
    p_nome: dados.nome,
    p_papel: dados.papel,
    p_cursos: dados.papel === "ADMIN" ? null : dados.cursos,
  });
  if (error) return { erro: error.message };
  revalidatePath("/admin/equipe");
  const r = data as { situacao: string; email: string };
  return {
    ok:
      r.situacao === "ATIVO"
        ? `${r.email} já tinha conta e agora tem o perfil definido.`
        : `Convite registrado. Quando ${r.email} entrar pelo link de acesso, a conta já abrirá com este perfil.`,
  };
}

export async function removerMembro(email: string): Promise<EstadoEquipe> {
  await exigirAdminGeral();
  const supabase = await createClient();
  const { error } = await supabase.rpc("remover_membro_equipe", { p_email: email });
  if (error) return { erro: error.message };
  revalidatePath("/admin/equipe");
  return { ok: `Acesso de ${email} removido.` };
}
