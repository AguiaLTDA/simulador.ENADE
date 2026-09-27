"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export type EstadoCadastro = {
  erro?: string;
  valores?: { cpf: string; nascimento: string; telefone: string };
};

type RespostaCadastro = { ok: boolean; codigo?: string; mensagem?: string };

export async function concluirCadastro(
  _prev: EstadoCadastro,
  formData: FormData,
): Promise<EstadoCadastro> {
  const valores = {
    cpf: String(formData.get("cpf") ?? ""),
    nascimento: String(formData.get("nascimento") ?? ""),
    telefone: String(formData.get("telefone") ?? ""),
  };
  const aceite = formData.get("aceite_lgpd") === "on";

  if (!/^\d{4}-\d{2}-\d{2}$/.test(valores.nascimento)) {
    return { erro: "Informe a data de nascimento.", valores };
  }

  // CPF e data são conferidos no banco contra a base acadêmica; o banco também
  // limita tentativas e grava o consentimento LGPD.
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("concluir_cadastro", {
    p_cpf: valores.cpf,
    p_data_nascimento: valores.nascimento,
    p_telefone: valores.telefone,
    p_aceite_lgpd: aceite,
  });

  if (error) {
    console.error("concluir_cadastro", error.code, error.message);
    return { erro: "Não foi possível concluir o cadastro agora. Tente novamente.", valores };
  }

  const r = data as RespostaCadastro;
  if (!r.ok) {
    if (r.codigo === "CADASTRO_EXISTENTE") redirect("/");
    return { erro: r.mensagem ?? "Não foi possível concluir o cadastro.", valores };
  }

  redirect("/inicio");
}
