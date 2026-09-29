"use client";

import { useRouter } from "next/navigation";
import { useState, useTransition } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { NativeSelect } from "@/components/ui/native-select";
import { Textarea } from "@/components/ui/textarea";
import { NOME_CURSO, type Curso } from "@/lib/cursos";
import {
  LETRAS,
  NOME_DIFICULDADE,
  NOME_STATUS,
  type DadosQuestao,
  type Letra,
  type PesosPadrao,
  type StatusQuestao,
} from "@/lib/questoes";
import { cn } from "@/lib/utils";
import { excluirQuestao, salvarQuestao } from "./actions";
import { PreviaEnade } from "./previa-enade";

const CAMPO_ALT = { A: "alt_a", B: "alt_b", C: "alt_c", D: "alt_d", E: "alt_e" } as const;

export function FormularioQuestao({
  inicial,
  pesos,
  eixos,
  cursosPermitidos,
}: {
  inicial: DadosQuestao;
  pesos: PesosPadrao;
  eixos: string[];
  cursosPermitidos: Curso[];
}) {
  const router = useRouter();
  const [q, setQ] = useState<DadosQuestao>(inicial);
  const [erro, setErro] = useState<string | null>(null);
  const [mostrarGabarito, setMostrarGabarito] = useState(true);
  const [pendente, iniciar] = useTransition();
  const editando = Boolean(inicial.id);

  const set = <K extends keyof DadosQuestao>(campo: K, valor: DadosQuestao[K]) =>
    setQ((atual) => ({ ...atual, [campo]: valor }));

  const alternarCurso = (curso: Curso) =>
    set("cursos", q.cursos.includes(curso) ? q.cursos.filter((c) => c !== curso) : [...q.cursos, curso]);

  const pesoEfetivo = q.peso_pontos.trim() ? Number(q.peso_pontos) : pesos[q.dificuldade];

  function salvar(status: StatusQuestao) {
    setErro(null);
    iniciar(async () => {
      const r = await salvarQuestao({ ...q, status });
      if (r.erro) {
        setErro(r.erro);
        window.scrollTo({ top: 0, behavior: "smooth" });
        return;
      }
      router.push(`/admin/questoes?salva=${status}`);
      router.refresh();
    });
  }

  function excluir() {
    if (!inicial.id) return;
    if (!window.confirm("Excluir esta questão? Se ela já tiver respostas, será arquivada.")) return;
    iniciar(async () => {
      const r = await excluirQuestao(inicial.id!);
      if (r.erro) return setErro(r.erro);
      router.push(`/admin/questoes?salva=${r.resultado}`);
      router.refresh();
    });
  }

  return (
    <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_minmax(0,26rem)]">
      <div className="space-y-6">
        {erro && (
          <Alert variant="destructive">
            <AlertDescription>{erro}</AlertDescription>
          </Alert>
        )}

        <Card>
          <CardHeader>
            <CardTitle>Classificação</CardTitle>
          </CardHeader>
          <CardContent className="space-y-5">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="componente">Componente</Label>
                <NativeSelect
                  id="componente"
                  value={q.componente}
                  onChange={(e) => set("componente", e.target.value as DadosQuestao["componente"])}
                >
                  <option value="FG">Formação Geral (todos os cursos)</option>
                  <option value="CE">Componente Específico</option>
                </NativeSelect>
              </div>
              <div className="space-y-2">
                <Label htmlFor="formato">Formato</Label>
                <NativeSelect
                  id="formato"
                  value={q.formato}
                  onChange={(e) => set("formato", e.target.value as DadosQuestao["formato"])}
                >
                  <option value="OBJETIVA">Objetiva (múltipla escolha)</option>
                  <option value="DISCURSIVA">Discursiva (correção manual)</option>
                </NativeSelect>
              </div>
            </div>

            {q.componente === "CE" && (
              <fieldset className="space-y-2">
                <legend className="text-sm font-medium">Cursos</legend>
                <p className="text-xs text-muted-foreground">
                  {cursosPermitidos.includes("ENG_MEC") && cursosPermitidos.includes("ENG_PROD")
                    ? "Marque Mecânica e Produção juntas para o núcleo comum de engenharia."
                    : "Aparecem apenas os cursos que você coordena."}
                </p>
                <div className="flex flex-wrap gap-2">
                  {cursosPermitidos.map((c) => (
                    <label
                      key={c}
                      className="flex cursor-pointer items-center gap-2 rounded-lg border bg-background px-3 py-2 text-sm has-checked:border-primary"
                    >
                      <input
                        type="checkbox"
                        className="size-4 accent-primary"
                        checked={q.cursos.includes(c)}
                        onChange={() => alternarCurso(c)}
                      />
                      {NOME_CURSO[c]}
                    </label>
                  ))}
                </div>
              </fieldset>
            )}

            <div className="space-y-2">
              <Label htmlFor="eixo">Eixo / conteúdo</Label>
              <Input
                id="eixo"
                list="eixos-existentes"
                placeholder="Ex.: Termodinâmica, Ética e cidadania, Banco de Dados"
                value={q.eixo}
                onChange={(e) => set("eixo", e.target.value)}
              />
              <datalist id="eixos-existentes">
                {eixos.map((e) => (
                  <option key={e} value={e} />
                ))}
              </datalist>
              <p className="text-xs text-muted-foreground">
                Use sempre o mesmo nome para o mesmo eixo: é por ele que o aluno filtra e que os
                relatórios agrupam.
              </p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Conteúdo</CardTitle>
          </CardHeader>
          <CardContent className="space-y-5">
            <div className="space-y-2">
              <Label htmlFor="texto_apoio">
                Texto de apoio <span className="font-normal text-muted-foreground">(opcional)</span>
              </Label>
              <Textarea
                id="texto_apoio"
                rows={5}
                value={q.texto_apoio}
                onChange={(e) => set("texto_apoio", e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="enunciado">Enunciado</Label>
              <Textarea
                id="enunciado"
                rows={4}
                value={q.enunciado}
                onChange={(e) => set("enunciado", e.target.value)}
              />
            </div>

            {q.formato === "OBJETIVA" ? (
              <fieldset className="space-y-3">
                <legend className="text-sm font-medium">Alternativas e gabarito</legend>
                <p className="text-xs text-muted-foreground">Marque a alternativa correta à esquerda.</p>
                {LETRAS.map((letra) => (
                  <div
                    key={letra}
                    className={cn(
                      "flex items-start gap-3 rounded-lg border p-2",
                      q.gabarito === letra ? "border-emerald-600 bg-emerald-50/60 dark:bg-emerald-950/30" : "bg-background",
                    )}
                  >
                    <label className="flex shrink-0 cursor-pointer items-center gap-2 pt-1.5">
                      <input
                        type="radio"
                        name="gabarito"
                        className="size-4 accent-emerald-600"
                        checked={q.gabarito === letra}
                        onChange={() => set("gabarito", letra as Letra)}
                        aria-label={`Alternativa ${letra} é a correta`}
                      />
                      <span className="w-4 font-bold">{letra}</span>
                    </label>
                    <Textarea
                      rows={2}
                      className="min-h-0"
                      aria-label={`Texto da alternativa ${letra}`}
                      value={q[CAMPO_ALT[letra]]}
                      onChange={(e) => set(CAMPO_ALT[letra], e.target.value)}
                    />
                  </div>
                ))}
              </fieldset>
            ) : (
              <p className="rounded-lg border border-dashed p-3 text-sm text-muted-foreground">
                Questões discursivas não têm alternativas. A resposta do aluno vai para a fila de
                correção docente e a nota é atribuída depois.
              </p>
            )}

            <div className="space-y-2">
              <Label htmlFor="justificativa">
                {q.formato === "DISCURSIVA" ? "Padrão de resposta (para o corretor)" : "Justificativa do gabarito"}
              </Label>
              <Textarea
                id="justificativa"
                rows={4}
                value={q.justificativa}
                onChange={(e) => set("justificativa", e.target.value)}
              />
              <p className="text-xs text-muted-foreground">
                O aluno vê este texto logo depois de responder no Treino Livre (nunca antes).
              </p>
            </div>

            <div className="space-y-2">
              <Label htmlFor="fonte">
                Fonte <span className="font-normal text-muted-foreground">(opcional)</span>
              </Label>
              <Input
                id="fonte"
                placeholder="Ex.: ENADE 2019 — Engenharia Mecânica, questão 12"
                value={q.fonte}
                onChange={(e) => set("fonte", e.target.value)}
              />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Pontuação</CardTitle>
          </CardHeader>
          <CardContent className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="dificuldade">Dificuldade</Label>
              <NativeSelect
                id="dificuldade"
                value={q.dificuldade}
                onChange={(e) => set("dificuldade", Number(e.target.value) as 1 | 2 | 3)}
              >
                {([1, 2, 3] as const).map((d) => (
                  <option key={d} value={d}>
                    {NOME_DIFICULDADE[d]} — padrão {pesos[d]} pts
                  </option>
                ))}
              </NativeSelect>
            </div>
            <div className="space-y-2">
              <Label htmlFor="peso">Peso (pontos base)</Label>
              <Input
                id="peso"
                type="number"
                min={1}
                inputMode="numeric"
                placeholder={`${pesos[q.dificuldade]} (padrão)`}
                value={q.peso_pontos}
                onChange={(e) => set("peso_pontos", e.target.value)}
              />
              <p className="text-xs text-muted-foreground">
                Deixe em branco para usar o padrão da dificuldade.
                {q.componente === "FG" && ` Formação Geral recebe multiplicador extra no ranking.`}
              </p>
            </div>
          </CardContent>
        </Card>

        <div className="flex flex-wrap items-center gap-3">
          <Button onClick={() => salvar("PUBLICADA")} disabled={pendente}>
            {pendente ? "Salvando..." : "Salvar e publicar"}
          </Button>
          <Button variant="outline" onClick={() => salvar("RASCUNHO")} disabled={pendente}>
            Salvar como rascunho
          </Button>
          {editando && inicial.status !== "ARQUIVADA" && (
            <Button variant="ghost" onClick={() => salvar("ARQUIVADA")} disabled={pendente}>
              Arquivar
            </Button>
          )}
          {editando && (
            <Button variant="destructive" className="ml-auto" onClick={excluir} disabled={pendente}>
              Excluir
            </Button>
          )}
        </div>
        {editando && (
          <p className="text-xs text-muted-foreground">
            Situação atual: <strong>{NOME_STATUS[inicial.status]}</strong>.
          </p>
        )}
      </div>

      <aside className="space-y-3 lg:sticky lg:top-4 lg:self-start">
        <div className="flex items-center justify-between">
          <h2 className="text-sm font-semibold">Pré-visualização (formato ENADE)</h2>
          <label className="flex items-center gap-2 text-xs text-muted-foreground">
            <input
              type="checkbox"
              className="size-3.5 accent-primary"
              checked={mostrarGabarito}
              onChange={(e) => setMostrarGabarito(e.target.checked)}
            />
            Mostrar gabarito
          </label>
        </div>
        <PreviaEnade q={q} mostrarGabarito={mostrarGabarito} />
        <p className="text-xs text-muted-foreground">
          Vale <strong>{Number.isFinite(pesoEfetivo) ? pesoEfetivo : "—"} pts</strong> na base, antes dos
          bônus de tempo e sequência.
        </p>
      </aside>
    </div>
  );
}
