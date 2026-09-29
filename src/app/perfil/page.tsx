import Link from "next/link";
import { redirect } from "next/navigation";
import { Cabecalho } from "@/components/cabecalho";
import { IconeConquista } from "@/components/icone-conquista";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { NOME_CURSO, destinoInicial, obterContexto } from "@/lib/contexto";
import { createClient } from "@/lib/supabase/server";
import { cn } from "@/lib/utils";

export const metadata = { title: "Meu perfil — Portal Simulado ENADE" };

type Resumo = {
  pontos: number;
  questoes_respondidas: number;
  conquistas: { codigo: string; obtida_em: string }[];
  diagnostico: { iniciado: boolean; concluido: boolean; respondidas: number; total: number };
};

export default async function PerfilPage() {
  const ctx = await obterContexto();
  if (!ctx.estudante || ctx.estudante.status !== "ATIVO") redirect(destinoInicial(ctx));
  const e = ctx.estudante;

  const supabase = await createClient();
  const [{ data: resumoBruto }, { data: catalogo }] = await Promise.all([
    supabase.rpc("meu_resumo"),
    supabase.from("conquistas").select("codigo, nome, descricao, icone").order("ordem"),
  ]);
  const resumo = resumoBruto as Resumo;
  const obtidas = new Map(resumo.conquistas.map((c) => [c.codigo, c.obtida_em]));
  const d = resumo.diagnostico;

  return (
    <>
      <Cabecalho nome={e.nome} detalhe={`${NOME_CURSO[e.curso]} · ${e.turma}`} />
      <main className="mx-auto w-full max-w-5xl space-y-6 px-4 py-8">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <Link href="/inicio" className="text-sm text-muted-foreground hover:text-foreground">
              ← Início
            </Link>
            <h1 className="mt-1 text-2xl font-semibold tracking-tight">{e.nome}</h1>
            <p className="text-muted-foreground">
              {NOME_CURSO[e.curso]} · Turma {e.turma} · {e.tipo === "CONCLUINTE" ? "Concluinte" : "Ingressante"}
            </p>
          </div>
        </div>

        <div className="grid gap-4 sm:grid-cols-3">
          <Card>
            <CardHeader>
              <CardDescription>Pontos</CardDescription>
              <CardTitle className="text-3xl tabular-nums">{resumo.pontos}</CardTitle>
            </CardHeader>
          </Card>
          <Card>
            <CardHeader>
              <CardDescription>Questões respondidas</CardDescription>
              <CardTitle className="text-3xl tabular-nums">{resumo.questoes_respondidas}</CardTitle>
            </CardHeader>
          </Card>
          <Card>
            <CardHeader>
              <CardDescription>Conquistas</CardDescription>
              <CardTitle className="text-3xl tabular-nums">
                {obtidas.size}
                <span className="text-base font-normal text-muted-foreground">/{catalogo?.length ?? 0}</span>
              </CardTitle>
            </CardHeader>
          </Card>
        </div>

        <Card className={cn(!d.concluido && "border-primary")}>
          <CardHeader>
            <CardTitle>Diagnóstico inicial</CardTitle>
            <CardDescription>
              {d.concluido
                ? "Concluído. Obrigado! Suas respostas ajudam a coordenação a planejar a sua preparação."
                : `${d.total} questões básicas de Português, Atualidades e Matemática. Leva cerca de 20 minutos e vale a conquista "Ponto de partida" e pontos no ranking — independentemente de acertos.`}
            </CardDescription>
          </CardHeader>
          {!d.concluido && (
            <CardContent className="flex flex-wrap items-center gap-4">
              <Link href="/perfil/diagnostico" className={buttonVariants()}>
                {d.respondidas > 0 ? `Continuar (${d.respondidas}/${d.total})` : "Começar diagnóstico"}
              </Link>
              {d.respondidas > 0 && (
                <div className="h-2 w-40 overflow-hidden rounded-full bg-muted">
                  <div className="h-full bg-primary" style={{ width: `${(100 * d.respondidas) / d.total}%` }} />
                </div>
              )}
            </CardContent>
          )}
        </Card>

        <section className="space-y-3">
          <h2 className="text-lg font-semibold">Conquistas</h2>
          <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {(catalogo ?? []).map((c) => {
              const quando = obtidas.get(c.codigo);
              return (
                <div
                  key={c.codigo}
                  className={cn(
                    "flex items-start gap-3 rounded-xl border bg-background p-4",
                    !quando && "opacity-50 grayscale",
                  )}
                >
                  <div
                    className={cn(
                      "flex size-10 shrink-0 items-center justify-center rounded-full",
                      quando ? "bg-amber-100 text-amber-700 dark:bg-amber-950 dark:text-amber-300" : "bg-muted text-muted-foreground",
                    )}
                  >
                    <IconeConquista icone={c.icone} className="size-5" />
                  </div>
                  <div>
                    <p className="font-medium">{c.nome}</p>
                    <p className="text-sm text-muted-foreground">{c.descricao}</p>
                    {quando && (
                      <p className="mt-1 text-xs text-muted-foreground">
                        Conquistada em {new Date(quando).toLocaleDateString("pt-BR")}
                      </p>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </section>

        <p className="text-sm text-muted-foreground">
          Em breve aqui: mapa de desempenho por eixo, evolução ao longo do tempo e sua posição no ranking.
        </p>
      </main>
    </>
  );
}
