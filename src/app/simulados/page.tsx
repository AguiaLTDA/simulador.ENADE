import Link from "next/link";
import { Cabecalho } from "@/components/cabecalho";
import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { NOME_CURSO } from "@/lib/cursos";
import {
  NOME_SITUACAO,
  formatarDataHora,
  formatarDuracao,
  type SimuladoAluno,
  type SituacaoSimulado,
} from "@/lib/simulados";
import { carregarSimuladosDoAluno } from "./dados";

export const metadata = { title: "Simulados — Portal Simulado ENADE" };

const VARIANTE: Record<SituacaoSimulado, "default" | "secondary" | "outline"> = {
  DISPONIVEL: "default",
  EM_ANDAMENTO: "default",
  AGENDADO: "secondary",
  CONCLUIDO: "outline",
  PERDIDO: "outline",
};

function Acao({ s }: { s: SimuladoAluno }) {
  switch (s.situacao) {
    case "DISPONIVEL":
      return <Link href={`/simulados/${s.id}`} className={buttonVariants()}>Fazer simulado</Link>;
    case "EM_ANDAMENTO":
      return <Link href={`/simulados/${s.id}`} className={buttonVariants()}>Continuar</Link>;
    case "CONCLUIDO":
      return (
        <Link href={`/simulados/${s.id}/resultado`} className={buttonVariants({ variant: "outline" })}>
          Ver resultado
        </Link>
      );
    default:
      return null;
  }
}

function Lista({ itens }: { itens: SimuladoAluno[] }) {
  return (
    <div className="grid gap-4">
      {itens.map((s) => (
        <Card key={s.id}>
          <CardHeader className="flex flex-row flex-wrap items-center justify-between gap-4">
            <div className="min-w-0 space-y-1">
              <div className="flex flex-wrap items-center gap-2">
                <CardTitle>{s.titulo}</CardTitle>
                <Badge variant={VARIANTE[s.situacao]}>{NOME_SITUACAO[s.situacao]}</Badge>
              </div>
              <CardDescription>
                {s.total_questoes} questões · {formatarDuracao(s.duracao_minutos)} de prova · aberto de{" "}
                {formatarDataHora(s.inicio)} até {formatarDataHora(s.fim)}
              </CardDescription>
              {s.situacao === "CONCLUIDO" && !s.gabarito_liberado && (
                <p className="text-xs text-muted-foreground">
                  Gabarito e correção liberados em {formatarDataHora(s.fim)}, quando o simulado fecha para todos.
                </p>
              )}
            </div>
            <Acao s={s} />
          </CardHeader>
        </Card>
      ))}
    </div>
  );
}

export default async function SimuladosPage() {
  const { estudante, simulados } = await carregarSimuladosDoAluno();
  const abertos = simulados.filter((s) => ["DISPONIVEL", "EM_ANDAMENTO", "AGENDADO"].includes(s.situacao));
  const anteriores = simulados.filter((s) => !abertos.includes(s));

  return (
    <>
      <Cabecalho nome={estudante.nome} detalhe={`${NOME_CURSO[estudante.curso]} · ${estudante.turma}`} />
      <main className="mx-auto w-full max-w-5xl space-y-8 px-4 py-8">
        <div>
          <Link href="/inicio" className="text-sm text-muted-foreground hover:text-foreground">
            ← Início
          </Link>
          <h1 className="mt-1 text-2xl font-semibold tracking-tight">Simulados</h1>
          <p className="text-muted-foreground">
            Provas cronometradas no formato do ENADE, montadas pela coordenação do seu curso.
          </p>
        </div>

        <section className="space-y-3">
          <h2 className="font-medium">Abertos e agendados</h2>
          {abertos.length ? (
            <Lista itens={abertos} />
          ) : (
            <div className="rounded-xl border border-dashed bg-background p-8 text-center text-sm text-muted-foreground">
              Nenhum simulado aberto no momento. A coordenação avisa quando houver um novo.
            </div>
          )}
        </section>

        {anteriores.length > 0 && (
          <section className="space-y-3">
            <h2 className="font-medium">Anteriores</h2>
            <Lista itens={anteriores} />
          </section>
        )}
      </main>
    </>
  );
}
