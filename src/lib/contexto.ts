import { redirect } from "next/navigation";
import type { Curso } from "@/lib/cursos";
import { createClient } from "@/lib/supabase/server";

export { NOME_CURSO } from "@/lib/cursos";

export type Contexto = {
  email: string;
  staff: { nome: string; papel: "ADMIN" | "DOCENTE" } | null;
  estudante: {
    nome: string;
    curso: Curso;
    turma: string;
    tipo: "CONCLUINTE" | "INGRESSANTE";
    status: "ATIVO" | "PENDENTE" | "BLOQUEADO";
  } | null;
};

// Quem está logado e qual o perfil. Redireciona para /login se não houver sessão.
export async function obterContexto(): Promise<Contexto> {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims?.sub) redirect("/login");

  const { data, error } = await supabase.rpc("meu_contexto");
  if (error) throw new Error(`Falha ao carregar o perfil: ${error.message}`);

  return { email: String(auth.claims.email ?? ""), ...(data as Omit<Contexto, "email">) };
}

// Destino padrão de cada perfil.
export function destinoInicial(ctx: Contexto): string {
  if (ctx.staff) return "/admin";
  if (!ctx.estudante) return "/cadastro";
  if (ctx.estudante.status !== "ATIVO") return "/acesso-bloqueado";
  return "/inicio";
}

// Para páginas da coordenação que editam conteúdo (papel ADMIN).
export async function exigirAdmin(): Promise<Contexto & { staff: NonNullable<Contexto["staff"]> }> {
  const ctx = await obterContexto();
  if (!ctx.staff) redirect(destinoInicial(ctx));
  if (ctx.staff.papel !== "ADMIN") redirect("/admin");
  return ctx as Contexto & { staff: NonNullable<Contexto["staff"]> };
}
