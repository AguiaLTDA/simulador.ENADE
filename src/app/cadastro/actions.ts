"use server";

import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { CURSOS, type Curso } from "@/lib/cursos";
import { cpfValido, soDigitos } from "@/lib/formatos";
import { createClient } from "@/lib/supabase/server";

export type ValoresCadastro = { nome: string; email: string; telefone: string; cpf: string; curso: string };

export type EstadoCadastro = {
  erro?: string;
  enviado?: boolean;
  valores?: ValoresCadastro;
};

// Dados guardados na conta entre o envio do formulário e a criação da senha.
// São apagados assim que o cadastro é concluído.
export type CadastroPendente = { nome: string; cpf: string; telefone: string; curso: Curso };

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function lerFormulario(formData: FormData): ValoresCadastro {
  const campo = (n: string) => String(formData.get(n) ?? "").trim();
  return {
    nome: campo("nome").replace(/\s+/g, " "),
    email: campo("email").toLowerCase(),
    telefone: campo("telefone"),
    cpf: campo("cpf"),
    curso: campo("curso"),
  };
}

function validar(v: ValoresCadastro, aceite: boolean, exigirEmail: boolean): string | null {
  if (!/\S+\s+\S+/.test(v.nome) || v.nome.length > 120) return "Informe seu nome completo.";
  if (exigirEmail && !EMAIL_RE.test(v.email)) return "Informe um e-mail válido.";
  if (!/^[1-9]{2}\d{8,9}$/.test(soDigitos(v.telefone))) return "Informe o telefone com DDD (10 ou 11 dígitos).";
  if (!cpfValido(v.cpf)) return "CPF inválido.";
  if (!CURSOS.includes(v.curso as Curso)) return "Selecione o seu curso.";
  if (!aceite) return "É necessário aceitar o termo de consentimento (LGPD).";
  return null;
}

// 1º passo (sem login): recebe os dados e envia o e-mail para criar a senha.
// O envio é feito pelo próprio Supabase Auth (SMTP do Resend configurado no painel).
export async function solicitarCadastro(_prev: EstadoCadastro, formData: FormData): Promise<EstadoCadastro> {
  const valores = lerFormulario(formData);
  const problema = validar(valores, formData.get("aceite_lgpd") === "on", true);
  if (problema) return { erro: problema, valores };

  const pendente: CadastroPendente = {
    nome: valores.nome,
    cpf: soDigitos(valores.cpf),
    telefone: soDigitos(valores.telefone),
    curso: valores.curso as Curso,
  };

  const origin = (await headers()).get("origin") ?? process.env.NEXT_PUBLIC_SITE_URL ?? "";
  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithOtp({
    email: valores.email,
    options: {
      shouldCreateUser: true,
      emailRedirectTo: `${origin}/auth/confirm`,
      data: { cadastro: pendente },
    },
  });

  if (error) {
    if (error.status === 429) {
      return { erro: "Muitos pedidos em pouco tempo. Aguarde alguns minutos e tente de novo.", valores };
    }
    console.error("signInWithOtp (cadastro)", error.status, error.message);
    return { erro: "Não foi possível enviar o e-mail agora. Tente novamente.", valores };
  }

  return { enviado: true, valores: { ...valores, cpf: "", telefone: "" } };
}

// 2º passo (já com senha criada): confirma os dados e cria o perfil de estudante.
export async function concluirCadastro(_prev: EstadoCadastro, formData: FormData): Promise<EstadoCadastro> {
  const valores = lerFormulario(formData);
  const problema = validar(valores, formData.get("aceite_lgpd") === "on", false);
  if (problema) return { erro: problema, valores };

  const supabase = await createClient();
  const { data, error } = await supabase.rpc("concluir_cadastro", {
    p_nome: valores.nome,
    p_cpf: valores.cpf,
    p_telefone: valores.telefone,
    p_curso: valores.curso,
    p_aceite_lgpd: true,
  });

  if (error) {
    console.error("concluir_cadastro", error.code, error.message);
    return { erro: "Não foi possível concluir o cadastro agora. Tente novamente.", valores };
  }

  const r = data as { ok: boolean; codigo?: string; mensagem?: string };
  if (!r.ok) {
    if (r.codigo === "CADASTRO_EXISTENTE" || r.codigo === "CONTA_STAFF") redirect("/");
    return { erro: r.mensagem ?? "Não foi possível concluir o cadastro.", valores };
  }

  // Remove da conta os dados provisórios (inclui CPF).
  await supabase.auth.updateUser({ data: { cadastro: null } });
  redirect("/inicio");
}
