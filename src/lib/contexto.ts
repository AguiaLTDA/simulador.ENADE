import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export type Curso = "ENG_MEC" | "ENG_PROD" | "ADS";

export const NOME_CURSO: Record<Curso, string> = {
  ENG_MEC: "Engenharia Mecânica",
  ENG_PROD: "Engenharia de Produção",
  ADS: "Análise e Desenvolvimento de Sistemas",
};

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
