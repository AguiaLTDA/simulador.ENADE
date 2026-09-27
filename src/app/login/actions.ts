"use server";

import { headers } from "next/headers";
import { createClient } from "@/lib/supabase/server";

export type EstadoLogin = { status: "inicial" | "enviado" | "erro"; mensagem?: string; email?: string };

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export async function enviarLink(_prev: EstadoLogin, formData: FormData): Promise<EstadoLogin> {
  const email = String(formData.get("email") ?? "").trim().toLowerCase();
  if (!EMAIL_RE.test(email)) {
    return { status: "erro", mensagem: "Informe um e-mail válido.", email };
  }

  const origin = (await headers()).get("origin") ?? process.env.NEXT_PUBLIC_SITE_URL ?? "";
  const supabase = await createClient();
  // O e-mail é enviado pelo próprio Supabase Auth (SMTP do Resend configurado no painel).
  const { error } = await supabase.auth.signInWithOtp({
    email,
    options: { emailRedirectTo: `${origin}/auth/confirm`, shouldCreateUser: true },
  });

  if (error) {
    if (error.status === 429) {
      return {
        status: "erro",
        mensagem: "Muitos pedidos de link em pouco tempo. Aguarde alguns minutos e tente de novo.",
        email,
      };
    }
    console.error("signInWithOtp", error.status, error.message);
    return { status: "erro", mensagem: "Não foi possível enviar o link agora. Tente novamente.", email };
  }

  return { status: "enviado", email };
}
