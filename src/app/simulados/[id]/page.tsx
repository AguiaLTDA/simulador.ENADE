import Link from "next/link";
import { notFound, redirect } from "next/navigation";
import { Cabecalho } from "@/components/cabecalho";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { NOME_CURSO } from "@/lib/cursos";
import { formatarDataHora, formatarDuracao, type ProvaEmAndamento } from "@/lib/simulados";
import { carregarSimuladosDoAluno } from "../dados";
import { IniciarSimulado } from "./iniciar-simulado";
import { ProvaCliente } from "./prova-cliente";

export const metadata = { title: "Simulado — Portal Simulado ENADE" };

export default async function SimuladoPage({ params }: PageProps<"/simulados/[id]">) {
  const { id } = await params;
  if (!/^[0-9a-f-]{36}$/i.test(id)) notFound();

  const { estudante, simulados, supabase } = await carregarSimuladosDoAluno();
  const s = simulados.find((x) => x.id === id);
  if (!s) notFound();
  if (s.situacao === "CONCLUIDO") redirect(`/simulados/${id}/resultado`);

  // Em andamento: retoma (iniciar_simulado é idempotente para quem já começou).
  if (s.situacao === "EM_ANDAMENTO") {
    const { data, error } = await supabase.rpc("iniciar_simulado", { p_sessao_id: id });
    if (error) redirect(`/simulados/${id}/resultado`);
    return (
      <ProvaCliente prova={data as ProvaEmAndamento} servidorAgora={new Date().toISOString()} />
    );
  }

  return (
    <>
      <Cabecalho nome={estudante.nome} detalhe={`${NOME_CURSO[estudante.curso]} · ${estudante.turma}`} />
      <main className="mx-auto w-full max-w-2xl space-y-6 px-4 py-8">
        <div>
          <Link href="/simulados" className="text-sm text-muted-foreground hover:text-foreground">
            ← Simulados
          </Link>
          <h1 className="mt-1 text-2xl font-semibold tracking-tight">{s.titulo}</h1>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>
              {s.situacao === "AGENDADO"
                ? `Abre em ${formatarDataHora(s.inicio)}`
                : s.situacao === "PERDIDO"
                  ? "Este simulado já encerrou"
                  : "Antes de começar"}
            </CardTitle>
            <CardDescription>
              {s.total_questoes} questões · {formatarDuracao(s.duracao_minutos)} de prova · aberto até{" "}
              {formatarDataHora(s.fim)}
            </CardDescription>
          </CardHeader>
          {s.situacao === "DISPONIVEL" && (
            <CardContent className="space-y-4 text-sm">
              <ul className="space-y-1 text-muted-foreground">
                <li>• O cronômetro começa quando você clicar em “Iniciar” e não para se você fechar a página.</li>
                <li>
                  • Você terá {formatarDuracao(s.duracao_minutos)} (ou até {formatarDataHora(s.fim)}, o que vier
                  primeiro). Quando o tempo acabar, o simulado é finalizado automaticamente.
                </li>
                <li>• Responda na ordem que quiser. Cada resposta confirmada é definitiva.</li>
                <li>• Você vê a sua nota logo após finalizar.</li>
                <li>
                  • O gabarito, as justificativas e a correção das discursivas são liberados em{" "}
                  {formatarDataHora(s.fim)}, quando o simulado fecha para todos.
                </li>
              </ul>
              <IniciarSimulado sessaoId={s.id} />
            </CardContent>
          )}
        </Card>
      </main>
    </>
  );
}
