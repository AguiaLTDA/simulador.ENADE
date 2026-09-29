import { redirect } from "next/navigation";
import type { Curso, Papel } from "@/lib/cursos";
import { createClient } from "@/lib/supabase/server";

export { NOME_CURSO } from "@/lib/cursos";

export type Contexto = {
  email: string;
  staff: { nome: string; papel: Papel; cursos: Curso[] | null } | null;
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

type ContextoStaff = Contexto & { staff: NonNullable<Contexto["staff"]> };

// Páginas que editam conteúdo: administração geral ou coordenador de curso.
export async function exigirGestor(): Promise<ContextoStaff> {
  const ctx = await obterContexto();
  if (!ctx.staff) redirect(destinoInicial(ctx));
  if (ctx.staff.papel === "DOCENTE") redirect("/admin");
  return ctx as ContextoStaff;
}

// Páginas só da administração geral (equipe, configuração).
export async function exigirAdminGeral(): Promise<ContextoStaff> {
  const ctx = await exigirGestor();
  if (ctx.staff.papel !== "ADMIN") redirect("/admin");
  return ctx;
}

export async function exigirStaff(): Promise<ContextoStaff> {
  const ctx = await obterContexto();
  if (!ctx.staff) redirect(destinoInicial(ctx));
  return ctx as ContextoStaff;
}
