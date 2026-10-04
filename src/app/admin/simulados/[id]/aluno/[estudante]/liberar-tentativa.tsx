"use client";

import { useState, useTransition } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { deCampoLocal } from "@/lib/simulados";
import { liberarNovaTentativa } from "../../../actions";

export function LiberarTentativa({
  sessaoId,
  estudanteId,
  encerradoGeral,
}: {
  sessaoId: string;
  estudanteId: string;
  encerradoGeral: boolean;
}) {
  const [aberto, setAberto] = useState(false);
  const [motivo, setMotivo] = useState("");
  const [prazo, setPrazo] = useState("");
  const [erro, setErro] = useState<string | null>(null);
  const [pendente, iniciar] = useTransition();

  const valido = motivo.trim().length >= 5 && (!encerradoGeral || prazo);

  function liberar() {
    setErro(null);
    iniciar(async () => {
      const r = await liberarNovaTentativa(sessaoId, estudanteId, motivo, prazo ? deCampoLocal(prazo) : null);
      if (r.erro) return setErro(r.erro);
      setAberto(false);
      setMotivo("");
      setPrazo("");
    });
  }

  return (
    <div className="space-y-3 rounded-xl border bg-background p-5">
      <p className="font-medium">Liberar nova tentativa</p>
      <p className="text-sm text-muted-foreground">
        A tentativa atual é anulada (fica registrada no histórico) e o aluno recomeça do zero, com o cronômetro
        completo. Questões que ele já tinha respondido não pontuam de novo no ranking.
      </p>
      {!aberto ? (
        <Button variant="outline" onClick={() => setAberto(true)}>
          Liberar nova tentativa
        </Button>
      ) : (
        <div className="grid gap-3 sm:grid-cols-[1fr_14rem]">
          <div className="space-y-1.5">
            <Label htmlFor="motivo">Motivo</Label>
            <Textarea
              id="motivo"
              rows={2}
              value={motivo}
              onChange={(e) => setMotivo(e.target.value)}
              placeholder="Ex.: queda de internet durante a prova (registrado pela coordenação)"
              maxLength={500}
            />
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="prazo">Pode refazer até {encerradoGeral ? "" : "(opcional)"}</Label>
            <Input id="prazo" type="datetime-local" value={prazo} onChange={(e) => setPrazo(e.target.value)} />
            <p className="text-xs text-muted-foreground">
              {encerradoGeral
                ? "O simulado já encerrou: defina um prazo. Os colegas já receberam o gabarito."
                : "Vazio = até o encerramento do simulado."}
            </p>
          </div>
          <div className="flex gap-2 sm:col-span-2">
            <Button onClick={liberar} disabled={!valido || pendente}>
              {pendente ? "Liberando..." : "Confirmar e anular a tentativa atual"}
            </Button>
            <Button variant="ghost" onClick={() => setAberto(false)} disabled={pendente}>
              Cancelar
            </Button>
          </div>
        </div>
      )}
      {erro && (
        <Alert variant="destructive">
          <AlertDescription>{erro}</AlertDescription>
        </Alert>
      )}
    </div>
  );
}
