"use client";

import Link from "next/link";
import { useEffect, useEffectEvent, useState, useTransition } from "react";
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

  function confirmar(letra = escolha) {
    if (!atual || !letra || pendente) return;
    setErro(null);
    setEscolha(letra);
    iniciar(async () => {
      const r = await responderDiagnostico(atual.id, letra);
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

  // Teclado: A–E (ou 1–5) escolhe a alternativa; Enter confirma e avança.
  const aoTeclar = useEffectEvent((e: KeyboardEvent) => {
    if (fase !== "respondendo" || !atual || e.ctrlKey || e.metaKey || e.altKey) return;
    const tecla = e.key.toUpperCase();
    const porNumero = "ABCDE"[Number(tecla) - 1];
    if ("ABCDE".includes(tecla) && tecla.length === 1) {
      setEscolha(tecla);
    } else if (/^[1-5]$/.test(tecla)) {
      setEscolha(porNumero);
    } else if (e.key === "Enter") {
      // Com o foco numa alternativa, o Enter confirma essa alternativa.
      const focada = (e.target as HTMLElement | null)?.closest<HTMLElement>("[data-letra]")?.dataset.letra;
      const letra = focada ?? escolha;
      if (!letra) return;
      e.preventDefault();
      confirmar(letra);
    }
  });

  useEffect(() => {
    window.addEventListener("keydown", aoTeclar);
    return () => window.removeEventListener("keydown", aoTeclar);
  }, []);

  if (fase === "concluido") {
    return (
      <Card className="text-center">
        <CardHeader className="items-center">
          <div className="mx-auto flex size-16 items-center justify-center rounded-full bg-dourado-suave text-[#9a7425]">
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
            . Suas respostas ajudam a coordenação a planejar a preparação do seu curso.
          </CardDescription>
        </CardHeader>
        <CardContent className="flex justify-center gap-3">
          <Link href="/conquistas" className={buttonVariants()}>
            Ver conquistas
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
            <li>Conhecimentos gerais — cidadania, meio ambiente, tecnologia e sociedade</li>
            <li>Matemática e raciocínio lógico — porcentagem, proporção, sequências e lógica</li>
          </ul>
          <ul className="space-y-1 text-muted-foreground">
            <li>• Não é prova: você não perde pontos por errar e não verá a correção.</li>
            <li>• Cada resposta é definitiva. Se precisar parar, continue depois de onde parou.</li>
            <li>• Atalho: tecle A a E para escolher e Enter para confirmar e avançar.</li>
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

  // Modo foco: cobre o menu do portal enquanto o aluno responde.
  return (
    <div className="fixed inset-0 z-40 overflow-y-auto bg-pagina">
      <header className="sticky top-0 z-10 border-b bg-background">
        <div className="mx-auto flex h-14 w-full max-w-2xl items-center justify-between gap-3 px-4">
          <span className="min-w-0">
            <span className="block text-[11px] font-medium uppercase tracking-wider text-verde">Diagnóstico inicial</span>
            <span className="block truncate text-sm font-semibold">{NOME_AREA[atual.area]}</span>
          </span>
          <span className="flex items-center gap-3">
            <span className="text-sm tabular-nums text-muted-foreground">
              {feitas + 1} de {total}
            </span>
            <Link href="/inicio" className={buttonVariants({ variant: "ghost", size: "sm" })}>
              Continuar depois
            </Link>
          </span>
        </div>
        <div
          className="h-0.5 bg-muted"
          role="progressbar"
          aria-label="Questões respondidas"
          aria-valuenow={feitas}
          aria-valuemin={0}
          aria-valuemax={total}
        >
          <div className="h-full bg-verde transition-[width] duration-300" style={{ width: `${progresso}%` }} />
        </div>
      </header>
      <div className="mx-auto w-full max-w-2xl space-y-4 px-4 py-6">

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
                data-letra={letra}
                onClick={() => setEscolha(letra)}
                className={cn(
                  "flex w-full items-start gap-3 rounded-lg border bg-background p-3 text-left text-[15px] transition-colors hover:bg-muted/60",
                  escolha === letra && "border-verde bg-verde-suave ring-1 ring-verde",
                )}
              >
                <span
                  className={cn(
                    "flex size-6 shrink-0 items-center justify-center rounded-full border text-xs font-bold",
                    escolha === letra && "border-verde bg-verde text-white",
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
          <div className="flex items-center justify-end gap-3">
            <span className="hidden text-xs text-muted-foreground sm:inline">
              Tecle A–E e <kbd className="rounded border bg-muted px-1 font-sans">Enter</kbd>
            </span>
            <Button variant="acao" size="lg" onClick={() => confirmar()} disabled={!escolha || pendente}>
              {pendente ? "Salvando..." : fila.length === 1 ? "Concluir diagnóstico" : "Confirmar e avançar"}
            </Button>
          </div>
        </CardContent>
      </Card>
      </div>
    </div>
  );
}
