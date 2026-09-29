"use server";

import { redirect } from "next/navigation";
import { senhaForteOuErro } from "@/lib/senha";
import { createClient } from "@/lib/supabase/server";

export type EstadoSenha = { erro?: string };

export async function definirSenha(_prev: EstadoSenha, formData: FormData): Promise<EstadoSenha> {
  const senha = String(formData.get("senha") ?? "");
  const confirmacao = String(formData.get("confirmacao") ?? "");

  const problema = senhaForteOuErro(senha);
  if (problema) return { erro: problema };
  if (senha !== confirmacao) return { erro: "As senhas não conferem." };

  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();
  if (!auth?.claims?.sub) redirect("/login?erro=link");

  const { error } = await supabase.auth.updateUser({ password: senha });
  if (error) {
    if (error.code === "same_password") {
      return { erro: "A nova senha precisa ser diferente da atual." };
    }
    if (error.code === "weak_password") {
      return { erro: "Senha fraca. Use pelo menos 8 caracteres, com letras e números." };
    }
    if (error.code === "reauthentication_needed") {
      return { erro: "Por segurança, peça um novo link em “Primeiro acesso ou esqueci minha senha”." };
    }
    console.error("updateUser(password)", error.status, error.code, error.message);
    return { erro: "Não foi possível salvar a senha agora. Tente novamente." };
  }

  redirect("/?senha=ok");
}
