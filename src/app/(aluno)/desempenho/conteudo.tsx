import Link from "next/link";
import { ClipboardCheck, Percent, ListChecks, Sparkles } from "lucide-react";
import { BarrasAcerto, GraficoColunas } from "@/components/aluno/graficos";
import { Indicador, Pagina, Secao } from "@/components/aluno/pagina";
import { buttonVariants } from "@/components/ui/button";
import type { carregarDesempenho } from "@/lib/desempenho";
import { NOME_COMPONENTE } from "@/lib/questoes";
import { percentual } from "@/lib/ranking";
import { formatarNota } from "@/lib/simulados";


const caixa = "rounded-xl border bg-card p-5 shadow-[0_1px_2px_rgb(16_24_20/0.04)]";

function Vazio({ children }: { children: React.ReactNode }) {
  return <p className="py-6 text-center text-sm text-muted-foreground">{children}</p>;
}

export function ConteudoDesempenho({ dados }: { dados: Awaited<ReturnType<typeof carregarDesempenho>> }) {
  const { resumo, evolucao } = dados;
  const acerto = percentual(evolucao.acertos, evolucao.objetivas);
  const comNota = evolucao.simulados.filter((s) => s.nota !== null);
  const semanasComObjetivas = evolucao.semanas.filter((s) => s.objetivas > 0);

  return (
    <Pagina titulo="Meu desempenho" descricao="Sua evolução com base nas respostas já corrigidas.">
      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Indicador icone={<Sparkles />} valor={resumo.pontos.toLocaleString("pt-BR")} titulo="Pontos acumulados" />
        <Indicador icone={<ListChecks />} valor={evolucao.respondidas} titulo="Respostas corrigidas" />
        <Indicador
          icone={<Percent />}
          valor={acerto === null ? "—" : `${acerto}%`}
          titulo="Acerto nas objetivas"
          detalhe={evolucao.objetivas ? `${evolucao.acertos} de ${evolucao.objetivas} (1ª tentativa)` : undefined}
        />
        <Indicador icone={<ClipboardCheck />} valor={evolucao.simulados.length} titulo="Simulados concluídos" />
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <Secao titulo="Respostas por semana">
          <div className={caixa}>
            {evolucao.semanas.some((s) => s.respondidas > 0) ? (
              <GraficoColunas
                titulo="Respostas corrigidas por semana, últimas 8 semanas"
                dados={evolucao.semanas.map((s) => ({
                  rotulo: s.rotulo,
                  valor: s.respondidas,
                  dica: `${s.respondidas} resposta(s) na semana`,
                }))}
              />
            ) : (
              <Vazio>Nenhuma resposta corrigida nas últimas 8 semanas.</Vazio>
            )}
          </div>
        </Secao>

        <Secao titulo="Acerto por semana">
          <div className={caixa}>
            {semanasComObjetivas.length >= 2 ? (
              <GraficoColunas
                titulo="Percentual de acerto nas objetivas por semana"
                maximo={100}
                sufixo="%"
                dados={evolucao.semanas.map((s) => ({
                  rotulo: s.rotulo,
                  valor: percentual(s.acertos, s.objetivas) ?? 0,
                  dica: s.objetivas ? `${s.acertos} de ${s.objetivas} objetivas` : "Sem objetivas na semana",
                }))}
              />
            ) : (
              <Vazio>Aparece quando houver objetivas corrigidas em pelo menos duas semanas.</Vazio>
            )}
          </div>
        </Secao>
      </div>

      <Secao titulo="Nota nos simulados">
        <div className={caixa}>
          {comNota.length ? (
            <GraficoColunas
              titulo="Nota estimada em cada simulado"
              maximo={100}
              dados={comNota.map((s) => ({
                rotulo: s.titulo,
                valor: s.nota ?? 0,
                dica: `Nota estimada ${formatarNota(s.nota)} de 100`,
              }))}
            />
          ) : (
            <Vazio>
              Você ainda não concluiu simulados.{" "}
              <Link href="/simulados" className="font-medium text-verde hover:underline">
                Ver simulados
              </Link>
            </Vazio>
          )}
        </div>
      </Secao>

      <div className="grid gap-6 lg:grid-cols-2">
        <Secao titulo="Por componente">
          <div className={caixa}>
            {evolucao.componentes.length ? (
              <BarrasAcerto
                itens={evolucao.componentes.map((c) => ({
                  rotulo: NOME_COMPONENTE[c.componente],
                  acertos: c.acertos,
                  total: c.total,
                }))}
              />
            ) : (
              <Vazio>Disponível quando o gabarito de um simulado for liberado.</Vazio>
            )}
          </div>
        </Secao>

        <Secao titulo="Onde focar">
          <div className={caixa}>
            {evolucao.eixos.length ? (
              <>
                <p className="mb-4 text-xs text-muted-foreground">Eixos dos simulados, do mais fraco para o mais forte.</p>
                <BarrasAcerto
                  itens={evolucao.eixos.slice(0, 8).map((e) => ({
                    rotulo: e.eixo,
                    detalhe: e.componente,
                    acertos: e.acertos,
                    total: e.total,
                  }))}
                />
              </>
            ) : (
              <Vazio>Disponível quando o gabarito de um simulado for liberado.</Vazio>
            )}
          </div>
        </Secao>
      </div>

      {evolucao.simulados.length > 0 && (
        <Secao titulo="Simulados concluídos">
          <ul className="divide-y rounded-xl border bg-card">
            {[...evolucao.simulados].reverse().map((s) => (
              <li key={s.id} className="flex flex-wrap items-center justify-between gap-3 px-4 py-3">
                <div className="min-w-0">
                  <p className="truncate text-sm font-medium">{s.titulo}</p>
                  <p className="text-xs text-muted-foreground">
                    {new Date(s.quando).toLocaleDateString("pt-BR")} · nota {formatarNota(s.nota)}
                    {!s.liberado && " · gabarito ainda não liberado"}
                  </p>
                </div>
                <Link href={`/simulados/${s.id}/resultado`} className={buttonVariants({ variant: "outline", size: "sm" })}>
                  Ver resultado
                </Link>
              </li>
            ))}
          </ul>
        </Secao>
      )}
    </Pagina>
  );
}
