"use server";

import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

export type ValoresCadastro = {
  nome: string;
  cpf: string;
  nascimento: string;
  telefone: string;
  curso: string;
  turma: string;
  tipo: string;
  matricula: string;
};

export type EstadoCadastro = { erro?: string; valores?: ValoresCadastro };

type RespostaCadastro = { ok: boolean; codigo?: string; mensagem?: string };

const CURSOS = ["ENG_MEC", "ENG_PROD", "ADS"];
const TIPOS = ["CONCLUINTE", "INGRESSANTE"];

export async function concluirCadastro(
  _prev: EstadoCadastro,
  formData: FormData,
): Promise<EstadoCadastro> {
  const campo = (n: string) => String(formData.get(n) ?? "");
  const valores: ValoresCadastro = {
    nome: campo("nome"),
    cpf: campo("cpf"),
    nascimento: campo("nascimento"),
    telefone: campo("telefone"),
    curso: campo("curso"),
    turma: campo("turma"),
    tipo: campo("tipo"),
    matricula: campo("matricula"),
  };
  const aceite = formData.get("aceite_lgpd") === "on";

  if (!/^\d{4}-\d{2}-\d{2}$/.test(valores.nascimento)) {
    return { erro: "Informe a data de nascimento.", valores };
  }
  if (!CURSOS.includes(valores.curso)) return { erro: "Selecione o seu curso.", valores };
  if (!TIPOS.includes(valores.tipo)) {
    return { erro: "Informe se você é concluinte ou ingressante.", valores };
  }

  // Todas as regras são validadas de novo no banco (inclusive CPF único e LGPD).
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("concluir_cadastro", {
    p_nome: valores.nome,
    p_cpf: valores.cpf,
    p_data_nascimento: valores.nascimento,
    p_telefone: valores.telefone,
    p_curso: valores.curso,
    p_turma: valores.turma,
    p_tipo: valores.tipo,
    p_matricula: valores.matricula || null,
    p_aceite_lgpd: aceite,
  });

  if (error) {
    console.error("concluir_cadastro", error.code, error.message);
    return { erro: "Não foi possível concluir o cadastro agora. Tente novamente.", valores };
  }

  const r = data as RespostaCadastro;
  if (!r.ok) {
    if (r.codigo === "CADASTRO_EXISTENTE" || r.codigo === "CONTA_STAFF") redirect("/");
    return { erro: r.mensagem ?? "Não foi possível concluir o cadastro.", valores };
  }

  redirect("/inicio");
}
