"use client";

import { useRouter } from "next/navigation";
import { useMemo, useState, useTransition } from "react";
import { ArrowDown, ArrowUp, X } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { NativeSelect } from "@/components/ui/native-select";
import { NOME_CURSO, type Curso } from "@/lib/cursos";
import { NOME_DIFICULDADE } from "@/lib/questoes";
import { DURACAO_ENADE_MIN, PADRAO_ENADE, deCampoLocal, ordemCaderno } from "@/lib/simulados";
import { cn } from "@/lib/utils";
import { excluirSimulado, salvarSimulado } from "./actions";
import type { QuestaoBanco } from "./dados";

export type FormSimulado = {
  id?: string;
  titulo: string;
  curso: Curso | "";
  inicio: string; // datetime-local, horário de Brasília
  fim: string;
  duracao_minutos: string;
  questoes: string[];
  publicada: boolean;
};

const valeParaCurso = (q: QuestaoBanco, curso: Curso | "") =>
  curso === "" ? q.cursos.includes("ALL") : q.cursos.includes("ALL") || q.cursos.includes(curso);

const rotuloTipo = (q: QuestaoBanco) => `${q.componente} ${q.formato === "DISCURSIVA" ? "disc." : "obj."}`;

export function FormularioSimulado({
  inicial,
  cursos,
  podeTodos,
  banco,
  participantes,
}: {
  inicial: FormSimulado;
  cursos: Curso[];
  podeTodos: boolean;
  banco: QuestaoBanco[];
  participantes: number;
}) {
  const router = useRouter();
  const bloqueado = participantes > 0;
  const [f, setF] = useState(inicial);
  const [filtroComp, setFiltroComp] = useState("");
  const [filtroFormato, setFiltroFormato] = useState("");
  const [busca, setBusca] = useState("");
  const [erro, setErro] = useState<string | null>(null);
  const [pendente, iniciar] = useTransition();

  const porId = useMemo(() => new Map(banco.map((q) => [q.id, q])), [banco]);
  const selecionadas = f.questoes.map((id) => porId.get(id)).filter(Boolean) as QuestaoBanco[];
  const escolhidas = new Set(f.questoes);
  const compativeis = banco.filter((q) => q.status === "PUBLICADA" && valeParaCurso(q, f.curso));
  const invalidas = selecionadas.filter((q) => q.status !== "PUBLICADA" || !valeParaCurso(q, f.curso));

  const termo = busca.trim().toLowerCase();
  const disponiveis = compativeis.filter(
    (q) =>
      !escolhidas.has(q.id) &&
      (!filtroComp || q.componente === filtroComp) &&
      (!filtroFormato || q.formato === filtroFormato) &&
      (!termo || q.enunciado.toLowerCase().includes(termo) || q.eixo.toLowerCase().includes(termo)),
  );

  const set = <K extends keyof FormSimulado>(k: K, v: FormSimulado[K]) => setF((x) => ({ ...x, [k]: v }));
  const setQuestoes = (ids: string[]) => set("questoes", ids);

  function mover(i: number, delta: number) {
    const ids = [...f.questoes];
    const j = i + delta;
    if (j < 0 || j >= ids.length) return;
    [ids[i], ids[j]] = [ids[j], ids[i]];
    setQuestoes(ids);
  }

  const ordenarCaderno = (ids: string[]) =>
    ids
      .map((id, i) => ({ id, i, q: porId.get(id) }))
      .sort((a, b) => (a.q ? ordemCaderno(a.q) : 9) - (b.q ? ordemCaderno(b.q) : 9) || a.i - b.i)
      .map((x) => x.id);

  // Completa cada bloco do padrão ENADE com questões sorteadas, sem tirar as já escolhidas.
  function sortear() {
    const ids = [...f.questoes];
    for (const p of PADRAO_ENADE) {
      const ja = ids.filter((id) => {
        const q = porId.get(id);
        return q && q.componente === p.componente && q.formato === p.formato;
      }).length;
      const pool = compativeis
        .filter((q) => q.componente === p.componente && q.formato === p.formato && !ids.includes(q.id))
        .map((q) => ({ q, r: Math.random() }))
        .sort((a, b) => a.r - b.r)
        .slice(0, Math.max(0, p.quantidade - ja));
      ids.push(...pool.map((x) => x.q.id));
    }
    setQuestoes(ordenarCaderno(ids));
  }

  function salvar(publicada: boolean) {
    setErro(null);
    iniciar(async () => {
      const r = await salvarSimulado({
        id: f.id,
        titulo: f.titulo,
        curso: f.curso || null,
        inicio: deCampoLocal(f.inicio),
        fim: deCampoLocal(f.fim),
        duracao_minutos: Number(f.duracao_minutos),
        questoes: f.questoes,
        publicada,
      });
      if (r.erro) return setErro(r.erro);
      router.push("/admin/simulados?salvo=1");
    });
  }

  function excluir() {
    if (!f.id || !window.confirm("Excluir este simulado? Esta ação não pode ser desfeita.")) return;
    setErro(null);
    iniciar(async () => {
      const r = await excluirSimulado(f.id!);
      if (r.erro) return setErro(r.erro);
      router.push("/admin/simulados?excluido=1");
    });
  }

  return (
    <div className="space-y-6">
      {bloqueado && (
        <Alert>
          <AlertDescription>
            {participantes} aluno(s) já iniciaram este simulado. Para manter a prova justa, só o título e o
            encerramento podem ser alterados.
          </AlertDescription>
        </Alert>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Dados do simulado</CardTitle>
          <CardDescription>Horários em horário de Brasília.</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-4 sm:grid-cols-2">
          <div className="space-y-1.5 sm:col-span-2">
            <Label htmlFor="titulo">Título</Label>
            <Input
              id="titulo"
              value={f.titulo}
              onChange={(e) => set("titulo", e.target.value)}
              placeholder="Ex.: Simulado ENADE — 1º bimestre"
              maxLength={120}
            />
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="curso">Curso</Label>
            <NativeSelect
              id="curso"
              value={f.curso}
              onChange={(e) => set("curso", e.target.value as Curso | "")}
              disabled={bloqueado}
            >
              {podeTodos && <option value="">Todos os cursos (só Formação Geral)</option>}
              {cursos.map((c) => (
                <option key={c} value={c}>
                  {NOME_CURSO[c]}
                </option>
              ))}
            </NativeSelect>
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="duracao">Duração da prova (minutos)</Label>
            <Input
              id="duracao"
              type="number"
              min={1}
              max={600}
              value={f.duracao_minutos}
              onChange={(e) => set("duracao_minutos", e.target.value)}
              disabled={bloqueado}
            />
            <p className="text-xs text-muted-foreground">O ENADE tem {DURACAO_ENADE_MIN} minutos (4 horas).</p>
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="inicio">Abertura</Label>
            <Input
              id="inicio"
              type="datetime-local"
              value={f.inicio}
              onChange={(e) => set("inicio", e.target.value)}
              disabled={bloqueado}
            />
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="fim">Encerramento</Label>
            <Input id="fim" type="datetime-local" value={f.fim} onChange={(e) => set("fim", e.target.value)} />
            <p className="text-xs text-muted-foreground">
              Após o encerramento, os alunos recebem gabarito e correções.
            </p>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row flex-wrap items-start justify-between gap-3">
          <div className="space-y-1">
            <CardTitle>Questões ({f.questoes.length})</CardTitle>
            <CardDescription>
              Padrão ENADE: 2 discursivas e 8 objetivas de Formação Geral; 3 discursivas e 27 objetivas do
              Componente Específico.
            </CardDescription>
          </div>
          {!bloqueado && (
            <div className="flex flex-wrap gap-2">
              <Button variant="outline" size="sm" onClick={sortear}>
                Completar por sorteio
              </Button>
              <Button variant="outline" size="sm" onClick={() => setQuestoes(ordenarCaderno(f.questoes))}>
                Ordenar como no caderno
              </Button>
              <Button variant="ghost" size="sm" onClick={() => setQuestoes([])} disabled={!f.questoes.length}>
                Limpar
              </Button>
            </div>
          )}
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-2 sm:grid-cols-4">
            {PADRAO_ENADE.map((p) => {
              const n = selecionadas.filter((q) => q.componente === p.componente && q.formato === p.formato).length;
              const banco = compativeis.filter((q) => q.componente === p.componente && q.formato === p.formato).length;
              return (
                <div key={p.rotulo} className="rounded-lg border p-3">
                  <p className="text-xs text-muted-foreground">{p.rotulo}</p>
                  <p className="text-lg font-semibold tabular-nums">
                    {n}
                    <span className="text-sm font-normal text-muted-foreground">/{p.quantidade}</span>
                  </p>
                  <p className="text-xs text-muted-foreground">{banco} no banco</p>
                </div>
              );
            })}
          </div>

          {invalidas.length > 0 && (
            <Alert variant="destructive">
              <AlertDescription>
                {invalidas.length} questão(ões) selecionada(s) não valem para o curso escolhido ou não estão mais
                publicadas. Remova-as antes de publicar.
              </AlertDescription>
            </Alert>
          )}

          <div className={cn("grid gap-4", !bloqueado && "lg:grid-cols-2")}>
            <div className="space-y-2">
              <p className="text-sm font-medium">Selecionadas, na ordem da prova</p>
              {selecionadas.length === 0 ? (
                <p className="rounded-lg border border-dashed p-6 text-center text-sm text-muted-foreground">
                  Nenhuma questão selecionada.
                </p>
              ) : (
                <ol className="max-h-[32rem] space-y-1.5 overflow-y-auto pr-1">
                  {selecionadas.map((q, i) => (
                    <li
                      key={q.id}
                      className={cn(
                        "flex items-start gap-2 rounded-lg border p-2 text-sm",
                        invalidas.includes(q) && "border-destructive bg-destructive/5",
                      )}
                    >
                      <span className="w-6 shrink-0 pt-0.5 text-right font-semibold tabular-nums">{i + 1}</span>
                      <span className="min-w-0 flex-1">
                        <span className="flex flex-wrap items-center gap-1.5 text-xs text-muted-foreground">
                          <Badge variant="outline">{rotuloTipo(q)}</Badge>
                          {q.eixo} · {NOME_DIFICULDADE[q.dificuldade]}
                        </span>
                        <span className="line-clamp-2">{q.enunciado}</span>
                      </span>
                      {!bloqueado && (
                        <span className="flex shrink-0 gap-0.5">
                          <Button variant="ghost" size="icon-sm" onClick={() => mover(i, -1)} aria-label="Subir">
                            <ArrowUp />
                          </Button>
                          <Button variant="ghost" size="icon-sm" onClick={() => mover(i, 1)} aria-label="Descer">
                            <ArrowDown />
                          </Button>
                          <Button
                            variant="ghost"
                            size="icon-sm"
                            onClick={() => setQuestoes(f.questoes.filter((x) => x !== q.id))}
                            aria-label="Remover"
                          >
                            <X />
                          </Button>
                        </span>
                      )}
                    </li>
                  ))}
                </ol>
              )}
            </div>

            {!bloqueado && (
              <div className="space-y-2">
                <p className="text-sm font-medium">Banco de questões publicadas ({disponiveis.length})</p>
                <div className="grid gap-2 sm:grid-cols-[1fr_auto_auto]">
                  <Input placeholder="Buscar no enunciado ou eixo" value={busca} onChange={(e) => setBusca(e.target.value)} />
                  <NativeSelect value={filtroComp} onChange={(e) => setFiltroComp(e.target.value)} aria-label="Componente">
                    <option value="">FG e CE</option>
                    <option value="FG">Formação Geral</option>
                    <option value="CE">Específico</option>
                  </NativeSelect>
                  <NativeSelect value={filtroFormato} onChange={(e) => setFiltroFormato(e.target.value)} aria-label="Formato">
                    <option value="">Todos os formatos</option>
                    <option value="OBJETIVA">Objetivas</option>
                    <option value="DISCURSIVA">Discursivas</option>
                  </NativeSelect>
                </div>
                <ul className="max-h-[32rem] space-y-1.5 overflow-y-auto pr-1">
                  {disponiveis.map((q) => (
                    <li key={q.id}>
                      <button
                        type="button"
                        onClick={() => setQuestoes([...f.questoes, q.id])}
                        className="flex w-full items-start gap-2 rounded-lg border p-2 text-left text-sm hover:bg-muted/60"
                      >
                        <span className="shrink-0 pt-0.5 text-lg leading-none text-primary">+</span>
                        <span className="min-w-0 flex-1">
                          <span className="flex flex-wrap items-center gap-1.5 text-xs text-muted-foreground">
                            <Badge variant="outline">{rotuloTipo(q)}</Badge>
                            {q.eixo} · {NOME_DIFICULDADE[q.dificuldade]}
                          </span>
                          <span className="line-clamp-2">{q.enunciado}</span>
                        </span>
                      </button>
                    </li>
                  ))}
                  {disponiveis.length === 0 && (
                    <li className="rounded-lg border border-dashed p-6 text-center text-sm text-muted-foreground">
                      Nenhuma questão publicada disponível neste filtro.
                    </li>
                  )}
                </ul>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {erro && (
        <Alert variant="destructive">
          <AlertDescription>{erro}</AlertDescription>
        </Alert>
      )}

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          {f.id && !bloqueado && (
            <Button variant="destructive" onClick={excluir} disabled={pendente}>
              Excluir
            </Button>
          )}
        </div>
        <div className="flex flex-wrap gap-2">
          {!bloqueado && (
            <Button variant="outline" onClick={() => salvar(false)} disabled={pendente}>
              {inicial.publicada ? "Despublicar" : "Salvar rascunho"}
            </Button>
          )}
          <Button onClick={() => salvar(true)} disabled={pendente}>
            {pendente ? "Salvando..." : inicial.publicada ? "Salvar" : "Publicar para os alunos"}
          </Button>
        </div>
      </div>
    </div>
  );
}
