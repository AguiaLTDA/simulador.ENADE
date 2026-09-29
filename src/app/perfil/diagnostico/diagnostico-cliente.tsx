"use client";

import Link from "next/link";
import { useState, useTransition } from "react";
import { Target } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button, buttonVariants } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { NOME_AREA } from "@/lib/diagnostico";
import { cn } from "@/lib/utils";
import {
  iniciarDiagnostico,
  responderDiagnostico,
  type QuestaoDiagnostico,
} from "./actions";

type Fase = "intro" | "respondendo" | "concluido";

export function DiagnosticoCliente({ respondidasAntes, total }: { respondidasAntes: number; total: number }) {
  const [fase, setFase] = useState<Fase>("intro");
  const [fila, setFila] = useState<QuestaoDiagnostico[]>([]);
  const [feitas, setFeitas] = useState(respondidasAntes);
  const [escolha, setEscolha] = useState<string | null>(null);
  const [pontos, setPontos] = useState<number | null>(null);
  const [erro, setErro] = useState<string | null>(null);
  const [pendente, iniciar] = useTransition();

  const atual = fila[0];

  function comecar() {
    setErro(null);
    iniciar(async () => {
      const r = await iniciarDiagnostico();
      if (r.erro) return setErro(r.erro);
      if (r.concluido) return setFase("concluido");
      const feitasIds = new Set(r.respondidas_ids);
      setFila(r.questoes.filter((q) => !feitasIds.has(q.id)));
      setFeitas(feitasIds.size);
      setFase("respondendo");
    });
  }

  function confirmar() {
    if (!atual || !escolha) return;
    setErro(null);
    iniciar(async () => {
      const r = await responderDiagnostico(atual.id, escolha);
      if (r.erro) return setErro(r.erro);
      setEscolha(null);
      setFeitas(r.respondidas);
      if (r.concluido) {
        setPontos(r.pontos ?? null);
        setFase("concluido");
      } else {
        setFila((f) => f.slice(1));
        window.scrollTo({ top: 0 });
      }
    });
  }

  if (fase === "concluido") {
    return (
      <Card className="text-center">
        <CardHeader className="items-center">
          <div className="mx-auto flex size-16 items-center justify-center rounded-full bg-amber-100 text-amber-700 dark:bg-amber-950 dark:text-amber-300">
            <Target className="size-8" />
          </div>
          <CardTitle className="text-xl">Conquista desbloqueada: Ponto de partida</CardTitle>
          <CardDescription>
            Você concluiu o diagnóstico inicial
            {pontos !== null && (
              <>
                {" "}e ganhou <strong className="text-foreground">+{pontos} pontos</strong> no ranking
              </>
            )}
            . Suas respostas ajudam a coordenação a planejar a preparação da sua turma.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex justify-center gap-3">
          <Link href="/perfil" className={buttonVariants()}>
            Ver meu perfil
          </Link>
          <Link href="/inicio" className={buttonVariants({ variant: "outline" })}>
            Início
          </Link>
        </CardContent>
      </Card>
    );
  }

  if (fase === "intro") {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Antes de começar</CardTitle>
          <CardDescription>São {total} questões de nível básico, em três blocos:</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4 text-sm">
          <ul className="list-disc space-y-1 pl-5">
            <li>Português — leitura, ortografia e norma-padrão</li>
            <li>Atualidades — cidadania, meio ambiente, tecnologia e sociedade</li>
            <li>Matemática e raciocínio lógico — porcentagem, proporção, sequências e lógica</li>
          </ul>
          <ul className="space-y-1 text-muted-foreground">
            <li>• Não é prova: você não perde pontos por errar e não verá a correção.</li>
            <li>• Cada resposta é definitiva. Se precisar parar, continue depois de onde parou.</li>
            <li>• Ao terminar, você ganha a conquista “Ponto de partida” e pontos no ranking.</li>
          </ul>
          {erro && (
            <Alert variant="destructive">
              <AlertDescription>{erro}</AlertDescription>
            </Alert>
          )}
          <Button onClick={comecar} disabled={pendente}>
            {pendente ? "Carregando..." : respondidasAntes > 0 ? `Continuar (${respondidasAntes}/${total})` : "Começar"}
          </Button>
        </CardContent>
      </Card>
    );
  }

  if (!atual) return null;
  const progresso = (100 * feitas) / total;

  return (
    <div className="space-y-4">
      <div className="space-y-2">
        <div className="flex justify-between text-sm">
          <span className="font-medium">{NOME_AREA[atual.area]}</span>
          <span className="tabular-nums text-muted-foreground">
            Questão {feitas + 1} de {total}
          </span>
        </div>
        <div className="h-2 overflow-hidden rounded-full bg-muted">
          <div className="h-full bg-primary transition-all" style={{ width: `${progresso}%` }} />
        </div>
      </div>

      <Card>
        <CardContent className="space-y-4 pt-6">
          {atual.texto_apoio && (
            <p className="whitespace-pre-wrap rounded-lg bg-muted/60 p-4 text-[15px] leading-relaxed">
              {atual.texto_apoio}
            </p>
          )}
          <p className="whitespace-pre-wrap text-[15px] font-medium leading-relaxed">{atual.enunciado}</p>
          <div className="space-y-2" role="radiogroup" aria-label="Alternativas">
            {(Object.entries(atual.alternativas) as [string, string][]).map(([letra, texto]) => (
              <button
                key={letra}
                type="button"
                role="radio"
                aria-checked={escolha === letra}
                onClick={() => setEscolha(letra)}
                className={cn(
                  "flex w-full items-start gap-3 rounded-lg border bg-background p-3 text-left text-[15px] transition-colors hover:bg-muted/60",
                  escolha === letra && "border-primary bg-primary/5 ring-1 ring-primary",
                )}
              >
                <span
                  className={cn(
                    "flex size-6 shrink-0 items-center justify-center rounded-full border text-xs font-bold",
                    escolha === letra && "border-primary bg-primary text-primary-foreground",
                  )}
                >
                  {letra}
                </span>
                <span>{texto}</span>
              </button>
            ))}
          </div>
          {erro && (
            <Alert variant="destructive">
              <AlertDescription>{erro}</AlertDescription>
            </Alert>
          )}
          <div className="flex justify-end">
            <Button onClick={confirmar} disabled={!escolha || pendente}>
              {pendente ? "Salvando..." : fila.length === 1 ? "Concluir diagnóstico" : "Confirmar e avançar"}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
