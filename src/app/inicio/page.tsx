import Link from "next/link";
import { redirect } from "next/navigation";
import { Target } from "lucide-react";
import { Cabecalho } from "@/components/cabecalho";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { NOME_CURSO, destinoInicial, obterContexto } from "@/lib/contexto";
import type { SimuladoAluno } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";

export default async function InicioPage() {
  const ctx = await obterContexto();
  if (!ctx.estudante || ctx.estudante.status !== "ATIVO") redirect(destinoInicial(ctx));
  const { nome, curso, turma } = ctx.estudante;
  const primeiroNome = nome.split(" ")[0];

  const supabase = await createClient();
  const [{ data }, { data: simulados }] = await Promise.all([
    supabase.rpc("meu_resumo"),
    supabase.rpc("meus_simulados"),
  ]);
  const resumo = data as { pontos: number; diagnostico: { concluido: boolean; respondidas: number; total: number } };
  const simuladosAbertos = ((simulados ?? []) as SimuladoAluno[]).filter((s) =>
    ["DISPONIVEL", "EM_ANDAMENTO"].includes(s.situacao),
  ).length;

  return (
    <>
      <Cabecalho nome={nome} detalhe={`${NOME_CURSO[curso]} · ${turma}`} />
      <main className="mx-auto w-full max-w-5xl space-y-6 px-4 py-8">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Olá, {primeiroNome}!</h1>
          <p className="text-muted-foreground">
            Você tem <strong className="text-foreground">{resumo.pontos} pontos</strong>. Escolha como quer treinar.
          </p>
        </div>

        {!resumo.diagnostico.concluido && (
          <div className="flex flex-wrap items-center gap-4 rounded-xl border border-primary bg-background p-5">
            <div className="flex size-11 shrink-0 items-center justify-center rounded-full bg-amber-100 text-amber-700 dark:bg-amber-950 dark:text-amber-300">
              <Target className="size-5" />
            </div>
            <div className="min-w-0 flex-1">
              <p className="font-medium">Comece pelo diagnóstico inicial</p>
              <p className="text-sm text-muted-foreground">
                {resumo.diagnostico.total} questões básicas, cerca de 20 minutos. Vale conquista e pontos.
              </p>
            </div>
            <Link href="/perfil/diagnostico" className={buttonVariants()}>
              {resumo.diagnostico.respondidas > 0 ? "Continuar" : "Começar"}
            </Link>
          </div>
        )}

        <div className="grid gap-4 sm:grid-cols-3">
          <Link href="/perfil" className="rounded-xl transition-shadow hover:shadow-md">
            <Card className="h-full">
              <CardHeader>
                <CardTitle>Meu perfil</CardTitle>
                <CardDescription>Pontos, conquistas e diagnóstico inicial.</CardDescription>
              </CardHeader>
            </Card>
          </Link>
          <Link href="/simulados" className="rounded-xl transition-shadow hover:shadow-md">
            <Card className="h-full">
              <CardHeader>
                <CardTitle>Simulados</CardTitle>
                <CardDescription>Provas cronometradas no formato ENADE, com relatório ao final.</CardDescription>
                {simuladosAbertos > 0 && (
                  <p className="pt-2 text-xs font-medium text-primary">
                    {simuladosAbertos} disponível(is) agora
                  </p>
                )}
              </CardHeader>
            </Card>
          </Link>
          <Card className="opacity-70">
            <CardHeader>
              <CardTitle>Treino Livre</CardTitle>
              <CardDescription>Questões por componente, eixo e dificuldade, com devolutiva na hora.</CardDescription>
              <p className="pt-2 text-xs font-medium text-muted-foreground">Em breve</p>
            </CardHeader>
          </Card>
        </div>
      </main>
    </>
  );
}
