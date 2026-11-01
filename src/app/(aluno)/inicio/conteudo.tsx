import Link from "next/link";
import { ArrowRight, Award, CheckCircle2, CircleDashed, ListChecks, Sparkles, Target, Trophy } from "lucide-react";
import { BarrasAcerto, GraficoColunas } from "@/components/aluno/graficos";
import { Indicador, Pagina, Secao } from "@/components/aluno/pagina";
import { IconeConquista } from "@/components/icone-conquista";
import { buttonVariants } from "@/components/ui/button";
import type { Curso } from "@/lib/cursos";
import { NOME_CURSO } from "@/lib/contexto";
import type { carregarDesempenho } from "@/lib/desempenho";
import { NOME_COMPONENTE } from "@/lib/questoes";
import { percentual } from "@/lib/ranking";
import { formatarDataHora, type SimuladoAluno } from "@/lib/simulados";
import { cn } from "@/lib/utils";


type Acao = { href: string; rotulo: string; detalhe: string };

// A ação principal é sempre algo que o aluno pode fazer agora.
function proximaAcao(simulados: SimuladoAluno[], diag: { concluido: boolean; respondidas: number }): Acao {
  const emAndamento = simulados.find((s) => s.situacao === "EM_ANDAMENTO");
  if (emAndamento) {
    return {
      href: `/simulados/${emAndamento.id}`,
      rotulo: "Continuar preparação",
      detalhe: `${emAndamento.titulo} em andamento${emAndamento.termina_em ? ` · termina ${formatarDataHora(emAndamento.termina_em)}` : ""}`,
    };
  }
  if (!diag.concluido) {
    return {
      href: "/perfil/diagnostico",
      rotulo: diag.respondidas > 0 ? "Continuar diagnóstico" : "Fazer diagnóstico inicial",
      detalhe: "O primeiro passo: um retrato rápido de Português, Conhecimentos gerais e Matemática.",
    };
  }
  const disponivel = simulados.find((s) => s.situacao === "DISPONIVEL");
  if (disponivel) {
    return {
      href: `/simulados/${disponivel.id}`,
      rotulo: "Fazer simulado",
      detalhe: `${disponivel.titulo} · aberto até ${formatarDataHora(disponivel.fim)}`,
    };
  }
  const agendado = simulados.filter((s) => s.situacao === "AGENDADO").at(-1);
  return {
    href: "/simulados",
    rotulo: "Ver simulados",
    detalhe: agendado
      ? `Próximo: ${agendado.titulo}, abre ${formatarDataHora(agendado.inicio)}`
      : "Nenhum simulado aberto agora. Revise seus resultados e acompanhe a classificação.",
  };
}

export function ConteudoInicio({
  estudante,
  dados,
}: {
  estudante: { nome: string; curso: Curso };
  dados: Awaited<ReturnType<typeof carregarDesempenho>>;
}) {
  const e = estudante;
  const { resumo, simulados, ranking, catalogo, evolucao } = dados;
  const primeiroNome = e.nome.split(" ")[0];
  const d = resumo.diagnostico;
  const acao = proximaAcao(simulados, d);
  const obtidas = new Map(resumo.conquistas.map((c) => [c.codigo, c.obtida_em]));
  const proxima = catalogo.find((c) => !obtidas.has(c.codigo));
  const conclusaoDiag = obtidas.get("DIAGNOSTICO_INICIAL");
  const acerto = percentual(evolucao.acertos, evolucao.objetivas);
  const semanaComDados = evolucao.semanas.some((s) => s.respondidas > 0);

  return (
    <Pagina
      titulo={`Olá, ${primeiroNome}! 👋`}
      descricao={
        <>
          Acompanhe sua preparação para o ENADE · <span className="text-foreground/70">{NOME_CURSO[e.curso]}</span>
        </>
      }
    >
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Indicador icone={<Sparkles />} valor={resumo.pontos.toLocaleString("pt-BR")} titulo="Pontos acumulados" />
        <Indicador icone={<ListChecks />} valor={resumo.questoes_respondidas.toLocaleString("pt-BR")} titulo="Questões respondidas" />
        <Indicador
          icone={<Award />}
          tom="dourado"
          valor={
            <>
              {obtidas.size}
              <span className="text-base font-normal text-muted-foreground">/{catalogo.length}</span>
            </>
          }
          titulo="Conquistas"
        />
        <Indicador
          icone={<Trophy />}
          valor={ranking?.eu.posicao ? `${ranking.eu.posicao}º` : "—"}
          titulo="Classificação no curso"
          detalhe={ranking?.eu.posicao ? `de ${ranking.participantes} com pontos` : "Pontue para entrar"}
        />
      </div>

      <div className="flex flex-col gap-4 rounded-xl border bg-card p-5 shadow-[0_1px_2px_rgb(16_24_20/0.04)] sm:flex-row sm:items-center">
        <div className="min-w-0 flex-1">
          <p className="text-sm font-medium text-verde">O que fazer agora</p>
          <p className="mt-0.5 text-sm text-muted-foreground">{acao.detalhe}</p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <span
            className={cn(buttonVariants({ variant: "outline", size: "xl" }), "flex-1 cursor-default opacity-60 sm:flex-none")}
            aria-disabled="true"
            title="Em breve"
          >
            Treino livre
            <span className="rounded bg-muted px-1.5 text-[10px] text-muted-foreground">em breve</span>
          </span>
          <Link href="/ranking" className={cn(buttonVariants({ variant: "outline", size: "xl" }), "flex-1 sm:flex-none")}>
            Ver classificação
          </Link>
          <Link
            href={acao.href}
            className={cn(buttonVariants({ variant: "acao", size: "xl" }), "order-first basis-full sm:order-none sm:basis-auto")}
          >
            {acao.rotulo}
            <ArrowRight />
          </Link>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <Secao
          titulo="Minha evolução"
          className="lg:col-span-2"
          acao={
            <Link href="/desempenho" className="text-sm font-medium text-verde hover:underline">
              Ver desempenho
            </Link>
          }
        >
          <div className="space-y-5 rounded-xl border bg-card p-5 shadow-[0_1px_2px_rgb(16_24_20/0.04)]">
            {evolucao.respondidas === 0 ? (
              <p className="py-6 text-center text-sm text-muted-foreground">
                Sua evolução aparece aqui quando você tiver respostas corrigidas — de simulados com gabarito liberado e,
                em breve, do treino livre.
              </p>
            ) : (
              <>
                <div className="flex flex-wrap gap-x-8 gap-y-2">
                  <div>
                    <p className="text-2xl font-semibold tabular-nums">{evolucao.respondidas}</p>
                    <p className="text-xs text-muted-foreground">respostas corrigidas</p>
                  </div>
                  {acerto !== null && (
                    <div>
                      <p className="text-2xl font-semibold tabular-nums">{acerto}%</p>
                      <p className="text-xs text-muted-foreground">de acerto nas objetivas</p>
                    </div>
                  )}
                </div>
                {semanaComDados && (
                  <div>
                    <p className="mb-2 text-xs font-medium text-muted-foreground">Respostas por semana</p>
                    <GraficoColunas
                      titulo="Respostas por semana"
                      altura={96}
                      dados={evolucao.semanas.map((s) => ({
                        rotulo: s.rotulo,
                        valor: s.respondidas,
                        dica: `${s.respondidas} resposta(s)${s.objetivas ? ` · ${percentual(s.acertos, s.objetivas)}% de acerto` : ""}`,
                      }))}
                    />
                  </div>
                )}
                {evolucao.componentes.length > 0 && (
                  <BarrasAcerto
                    itens={evolucao.componentes.map((c) => ({
                      rotulo: NOME_COMPONENTE[c.componente],
                      acertos: c.acertos,
                      total: c.total,
                    }))}
                  />
                )}
              </>
            )}
          </div>
        </Secao>

        <div className="space-y-6">
          <Secao titulo="Diagnóstico inicial">
            <div className="space-y-3 rounded-xl border bg-card p-4 shadow-[0_1px_2px_rgb(16_24_20/0.04)]">
              <div className="flex items-center gap-2 text-sm font-medium">
                {d.concluido ? (
                  <>
                    <CheckCircle2 className="size-4 text-verde" /> Concluído
                  </>
                ) : (
                  <>
                    <CircleDashed className="size-4 text-[#b45309]" /> Pendente
                    {d.respondidas > 0 && (
                      <span className="font-normal text-muted-foreground">
                        · {d.respondidas}/{d.total}
                      </span>
                    )}
                  </>
                )}
              </div>
              <p className="text-xs text-muted-foreground">
                {d.concluido
                  ? `Feito em ${conclusaoDiag ? new Date(conclusaoDiag).toLocaleDateString("pt-BR") : "—"}. O resultado orienta a coordenação no planejamento da sua turma.`
                  : `${d.total} questões básicas, cerca de 15 minutos. Não é prova: errar não tira pontos.`}
              </p>
              {!d.concluido && (
                <Link href="/perfil/diagnostico" className={buttonVariants({ variant: "outline", size: "sm" })}>
                  <Target />
                  {d.respondidas > 0 ? "Continuar" : "Começar"}
                </Link>
              )}
            </div>
          </Secao>

          {proxima && (
            <Secao titulo="Próxima meta">
              <Link
                href="/conquistas"
                className="flex items-start gap-3 rounded-xl border bg-card p-4 shadow-[0_1px_2px_rgb(16_24_20/0.04)] transition-colors hover:border-dourado"
              >
                <span className="flex size-9 shrink-0 items-center justify-center rounded-full bg-muted text-muted-foreground">
                  <IconeConquista icone={proxima.icone} className="size-4" />
                </span>
                <span>
                  <span className="block text-sm font-medium">{proxima.nome}</span>
                  <span className="block text-xs text-muted-foreground">{proxima.descricao}</span>
                </span>
              </Link>
            </Secao>
          )}
        </div>
      </div>
    </Pagina>
  );
}
