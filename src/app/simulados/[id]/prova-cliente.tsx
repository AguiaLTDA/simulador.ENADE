"use client";

import { useRouter } from "next/navigation";
import { useEffect, useMemo, useRef, useState, useTransition } from "react";
import { Clock } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { LETRAS, NOME_COMPONENTE, type Letra } from "@/lib/questoes";
import type { ProvaEmAndamento } from "@/lib/simulados";
import { cn } from "@/lib/utils";
import { finalizarSimulado, responderSimulado } from "../actions";

function formatarRelogio(ms: number): string {
  const total = Math.max(0, Math.floor(ms / 1000));
  const h = Math.floor(total / 3600);
  const m = Math.floor((total % 3600) / 60);
  const s = total % 60;
  const dois = (n: number) => String(n).padStart(2, "0");
  return h ? `${h}:${dois(m)}:${dois(s)}` : `${dois(m)}:${dois(s)}`;
}

// Rascunho de discursiva só neste navegador (a resposta oficial é a enviada).
const chaveRascunho = (sessao: string, questao: string) => `simulado:${sessao}:${questao}`;
function lerRascunho(chave: string): string {
  try {
    return localStorage.getItem(chave) ?? "";
  } catch {
    return "";
  }
}
function gravarRascunho(chave: string, texto: string) {
  try {
    if (texto) localStorage.setItem(chave, texto);
    else localStorage.removeItem(chave);
  } catch {
    // armazenamento indisponível (aba privativa etc.): segue sem rascunho
  }
}

export function ProvaCliente({ prova, servidorAgora }: { prova: ProvaEmAndamento; servidorAgora: string }) {
  const router = useRouter();
  const { questoes } = prova;
  const terminaEm = useMemo(() => Date.parse(prova.termina_em), [prova.termina_em]);
  // Diferença entre o relógio do servidor e o do aparelho do aluno.
  const [desvio] = useState(() => Date.parse(servidorAgora) - Date.now());

  const [restante, setRestante] = useState(() => terminaEm - (Date.now() + desvio));
  const [respondidas, setRespondidas] = useState(() => new Set(prova.respondidas));
  const [escolhidas, setEscolhidas] = useState<Record<string, Letra>>({});
  const [indice, setIndice] = useState(() => {
    const i = questoes.findIndex((q) => !prova.respondidas.includes(q.id));
    return i === -1 ? 0 : i;
  });
  const [escolha, setEscolha] = useState<Letra | null>(null);
  const [texto, setTexto] = useState(() => {
    const q = questoes[indice];
    return q.formato === "DISCURSIVA" ? lerRascunho(chaveRascunho(prova.sessao_id, q.id)) : "";
  });
  const [confirmandoFim, setConfirmandoFim] = useState(false);
  const [erro, setErro] = useState<string | null>(null);
  const [pendente, iniciar] = useTransition();
  const finalizando = useRef(false);

  const atual = questoes[indice];
  const jaRespondida = respondidas.has(atual.id);
  const faltam = questoes.length - respondidas.size;

  function finalizar() {
    if (finalizando.current) return;
    finalizando.current = true;
    iniciar(async () => {
      const r = await finalizarSimulado(prova.sessao_id);
      if (r.erro) {
        finalizando.current = false;
        return setErro(r.erro);
      }
      questoes.forEach((q) => gravarRascunho(chaveRascunho(prova.sessao_id, q.id), ""));
      router.push(`/simulados/${prova.sessao_id}/resultado`);
    });
  }

  // Cronômetro; ao zerar, finaliza automaticamente.
  useEffect(() => {
    const t = setInterval(() => {
      const r = terminaEm - (Date.now() + desvio);
      setRestante(r);
      if (r <= 0) {
        clearInterval(t);
        finalizar();
      }
    }, 1000);
    return () => clearInterval(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [terminaEm, desvio]);

  // Troca de questão: limpa a escolha e carrega o rascunho da discursiva.
  function irPara(i: number) {
    const q = questoes[i];
    setIndice(i);
    setEscolha(null);
    setErro(null);
    setTexto(q.formato === "DISCURSIVA" ? lerRascunho(chaveRascunho(prova.sessao_id, q.id)) : "");
    setConfirmandoFim(false);
    window.scrollTo({ top: 0 });
  }

  function proximaPendente(depoisDe: number, feitas: Set<string>) {
    for (let k = 1; k <= questoes.length; k++) {
      const i = (depoisDe + k) % questoes.length;
      if (!feitas.has(questoes[i].id)) return i;
    }
    return null;
  }

  function responder() {
    const objetiva = atual.formato === "OBJETIVA";
    if (objetiva ? !escolha : !texto.trim()) return;
    setErro(null);
    iniciar(async () => {
      const r = await responderSimulado(
        prova.sessao_id,
        atual.id,
        objetiva ? { alternativa: escolha! } : { texto: texto.trim() },
      );
      if (r.erro) {
        if (/esgotado|finalizado/i.test(r.erro)) return finalizar();
        if (!/já respondida/i.test(r.erro)) return setErro(r.erro);
      }
      const feitas = new Set(respondidas).add(atual.id);
      setRespondidas(feitas);
      if (objetiva) setEscolhidas((e) => ({ ...e, [atual.id]: escolha! }));
      else gravarRascunho(chaveRascunho(prova.sessao_id, atual.id), "");
      const prox = proximaPendente(indice, feitas);
      if (prox === null) setConfirmandoFim(true);
      else irPara(prox);
    });
  }

  const urgente = restante <= 10 * 60 * 1000;

  return (
    <div className="min-h-svh bg-muted/30">
      <header className="sticky top-0 z-10 border-b bg-background">
        <div className="mx-auto flex h-14 w-full max-w-5xl items-center justify-between gap-3 px-4">
          <span className="min-w-0 truncate font-semibold tracking-tight">{prova.titulo}</span>
          <div className="flex items-center gap-3">
            <span
              className={cn(
                "flex items-center gap-1.5 rounded-md px-2 py-1 font-mono text-sm tabular-nums",
                urgente ? "bg-destructive/10 text-destructive" : "bg-muted",
              )}
              aria-live={urgente ? "polite" : "off"}
              title="Tempo restante"
            >
              <Clock className="size-4" />
              {formatarRelogio(restante)}
            </span>
            <Button variant="outline" size="sm" onClick={() => setConfirmandoFim(true)} disabled={pendente}>
              Finalizar
            </Button>
          </div>
        </div>
      </header>

      <main className="mx-auto grid w-full max-w-5xl gap-6 px-4 py-6 lg:grid-cols-[1fr_15rem]">
        <div className="order-2 space-y-4 lg:order-1">
          {confirmandoFim && (
            <Alert>
              <AlertDescription className="space-y-3">
                <p>
                  {faltam === 0
                    ? "Você respondeu todas as questões. Deseja finalizar o simulado?"
                    : `Ainda há ${faltam} questão(ões) sem resposta, que contarão como erro. Deseja finalizar mesmo assim?`}
                </p>
                <div className="flex flex-wrap gap-2">
                  <Button size="sm" onClick={finalizar} disabled={pendente}>
                    {pendente ? "Finalizando..." : "Finalizar simulado"}
                  </Button>
                  <Button size="sm" variant="outline" onClick={() => setConfirmandoFim(false)} disabled={pendente}>
                    Continuar respondendo
                  </Button>
                </div>
              </AlertDescription>
            </Alert>
          )}

          <article className="rounded-lg border bg-white p-5 font-serif text-[15px] leading-relaxed text-neutral-900 shadow-sm">
            <div className="mb-4 flex items-center justify-between gap-3 border-b border-neutral-300 pb-2 font-sans text-xs font-semibold uppercase tracking-wider text-neutral-600">
              <span>
                Questão {indice + 1} de {questoes.length}
                {atual.formato === "DISCURSIVA" && " · discursiva"}
              </span>
              <span>{NOME_COMPONENTE[atual.componente]}</span>
            </div>

            {atual.texto_apoio && <p className="mb-4 whitespace-pre-wrap text-justify">{atual.texto_apoio}</p>}
            <p className="whitespace-pre-wrap text-justify">{atual.enunciado}</p>

            {atual.formato === "OBJETIVA" && atual.alternativas ? (
              <div className="mt-4 space-y-2" role="radiogroup" aria-label="Alternativas">
                {LETRAS.map((letra) => {
                  const marcada = jaRespondida ? escolhidas[atual.id] === letra : escolha === letra;
                  return (
                    <button
                      key={letra}
                      type="button"
                      role="radio"
                      aria-checked={marcada}
                      disabled={jaRespondida || pendente}
                      onClick={() => setEscolha(letra)}
                      className={cn(
                        "flex w-full items-start gap-3 rounded-md border border-transparent px-2 py-1.5 text-left transition-colors",
                        !jaRespondida && "hover:bg-neutral-100",
                        marcada && "border-neutral-900 bg-neutral-100",
                      )}
                    >
                      <span
                        className={cn(
                          "flex size-6 shrink-0 items-center justify-center rounded-full border border-neutral-400 font-sans text-xs font-bold",
                          marcada && "border-neutral-900 bg-neutral-900 text-white",
                        )}
                      >
                        {letra}
                      </span>
                      <span className="whitespace-pre-wrap">{atual.alternativas![letra]}</span>
                    </button>
                  );
                })}
              </div>
            ) : (
              <div className="mt-4 font-sans">
                {jaRespondida ? (
                  <p className="rounded-md bg-neutral-100 p-3 text-sm text-neutral-600">Resposta enviada.</p>
                ) : (
                  <Textarea
                    value={texto}
                    onChange={(e) => {
                      setTexto(e.target.value);
                      gravarRascunho(chaveRascunho(prova.sessao_id, atual.id), e.target.value);
                    }}
                    rows={12}
                    maxLength={6000}
                    placeholder="Escreva sua resposta. O rascunho fica salvo neste navegador até você enviar."
                    className="bg-white text-[15px] text-neutral-900"
                    disabled={pendente}
                  />
                )}
              </div>
            )}
          </article>

          {erro && (
            <Alert variant="destructive">
              <AlertDescription>{erro}</AlertDescription>
            </Alert>
          )}

          <div className="flex flex-wrap items-center justify-between gap-3">
            <div className="flex gap-2">
              <Button variant="outline" onClick={() => irPara(indice - 1)} disabled={indice === 0 || pendente}>
                Anterior
              </Button>
              <Button
                variant="outline"
                onClick={() => irPara(indice + 1)}
                disabled={indice === questoes.length - 1 || pendente}
              >
                Pular
              </Button>
            </div>
            {jaRespondida ? (
              <span className="text-sm text-muted-foreground">Questão respondida.</span>
            ) : (
              <Button
                onClick={responder}
                disabled={pendente || (atual.formato === "OBJETIVA" ? !escolha : !texto.trim())}
              >
                {pendente ? "Salvando..." : "Confirmar resposta"}
              </Button>
            )}
          </div>
          <p className="text-xs text-muted-foreground">Cada resposta confirmada é definitiva.</p>
        </div>

        <aside className="order-1 space-y-3 lg:order-2">
          <div className="rounded-xl border bg-background p-4">
            <p className="mb-3 text-sm font-medium">
              {respondidas.size} de {questoes.length} respondidas
            </p>
            <div className="grid grid-cols-8 gap-1.5 lg:grid-cols-5">
              {questoes.map((q, i) => (
                <button
                  key={q.id}
                  type="button"
                  onClick={() => irPara(i)}
                  aria-label={`Questão ${i + 1}${respondidas.has(q.id) ? ", respondida" : ""}`}
                  aria-current={i === indice ? "step" : undefined}
                  className={cn(
                    "flex aspect-square items-center justify-center rounded-md border text-xs font-medium tabular-nums",
                    respondidas.has(q.id) ? "border-primary bg-primary text-primary-foreground" : "bg-background",
                    q.formato === "DISCURSIVA" && !respondidas.has(q.id) && "border-dashed",
                    i === indice && "ring-2 ring-ring ring-offset-1",
                  )}
                >
                  {i + 1}
                </button>
              ))}
            </div>
            <p className="mt-3 text-xs text-muted-foreground">Borda tracejada = discursiva.</p>
          </div>
        </aside>
      </main>
    </div>
  );
}
