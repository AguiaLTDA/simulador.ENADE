"use server";

import { headers } from "next/headers";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export type EstadoLogin = { erro?: string; email?: string };

// Login tradicional com e-mail e senha.
export async function entrar(_prev: EstadoLogin, formData: FormData): Promise<EstadoLogin> {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  const senha = String(formData.get("senha") ?? "");
  if (!EMAIL_RE.test(email)) return { erro: "Informe um e-mail válido.", email };
  if (!senha) return { erro: "Informe a senha.", email };

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithPassword({ email, password: senha });

  if (error) {
    if (error.status === 429) {
      return { erro: "Muitas tentativas em pouco tempo. Aguarde alguns minutos.", email };
    }
    if (error.code === "invalid_credentials" || error.status === 400) {
      return {
        erro:
          "E-mail ou senha incorretos. Se este é o seu primeiro acesso, use “Primeiro acesso ou esqueci minha senha” para criar a sua senha.",
        email,
      };
    }
    console.error("signInWithPassword", error.status, error.code, error.message);
    return { erro: "Não foi possível entrar agora. Tente novamente.", email };
  }

  redirect("/");
}

export type EstadoLink = { status: "inicial" | "enviado" | "erro"; mensagem?: string; email?: string };

// "Primeiro acesso ou esqueci minha senha": envia um link por e-mail que abre a
// tela de criar/redefinir senha. Serve para contas novas e existentes.
// O envio é feito pelo próprio Supabase Auth (SMTP do Resend configurado no painel).
export async function enviarLinkSenha(_prev: EstadoLink, formData: FormData): Promise<EstadoLink> {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  if (!EMAIL_RE.test(email)) {
    return { status: "erro", mensagem: "Informe um e-mail válido.", email };
  }

  const origin = (await headers()).get("origin") ?? process.env.NEXT_PUBLIC_SITE_URL ?? "";
  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithOtp({
    email,
    options: { emailRedirectTo: `${origin}/auth/confirm`, shouldCreateUser: true },
  });

  if (error) {
    if (error.status === 429) {
      return {
        status: "erro",
        mensagem: "Muitos pedidos em pouco tempo. Aguarde alguns minutos e tente de novo.",
        email,
      };
    }
    console.error("signInWithOtp", error.status, error.message);
    return { status: "erro", mensagem: "Não foi possível enviar o e-mail agora. Tente novamente.", email };
  }

  return { status: "enviado", email };
}
