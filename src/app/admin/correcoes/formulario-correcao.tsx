"use client";

import { useState, useTransition } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { corrigirDiscursiva } from "./actions";

export function FormularioCorrecao({
  respostaId,
  notaInicial,
  comentarioInicial,
}: {
  respostaId: string;
  notaInicial: number | null;
  comentarioInicial: string;
}) {
  const [nota, setNota] = useState(notaInicial === null ? "" : String(Number(notaInicial)));
  const [comentario, setComentario] = useState(comentarioInicial);
  const [erro, setErro] = useState<string | null>(null);
  const [ok, setOk] = useState<string | null>(null);
  const [pendente, iniciar] = useTransition();

  const valor = Number(nota.replace(",", "."));
  const valida = nota.trim() !== "" && Number.isFinite(valor) && valor >= 0 && valor <= 100;

  function salvar() {
    if (!valida) return;
    setErro(null);
    setOk(null);
    iniciar(async () => {
      const r = await corrigirDiscursiva(respostaId, valor, comentario);
      if (r.erro) return setErro(r.erro);
      setOk(`Correção salva. ${r.pontos ?? 0} ponto(s) para o aluno.`);
    });
  }

  return (
    <div className="grid gap-3 sm:grid-cols-[8rem_1fr_auto] sm:items-end">
      <div className="space-y-1.5">
        <Label htmlFor={`nota-${respostaId}`}>Nota (0–100)</Label>
        <Input
          id={`nota-${respostaId}`}
          inputMode="decimal"
          value={nota}
          onChange={(e) => setNota(e.target.value)}
          aria-invalid={nota.trim() !== "" && !valida}
        />
      </div>
      <div className="space-y-1.5">
        <Label htmlFor={`coment-${respostaId}`}>Comentário para o aluno (opcional)</Label>
        <Textarea
          id={`coment-${respostaId}`}
          rows={2}
          value={comentario}
          onChange={(e) => setComentario(e.target.value)}
          maxLength={2000}
        />
      </div>
      <Button onClick={salvar} disabled={!valida || pendente}>
        {pendente ? "Salvando..." : notaInicial === null ? "Salvar correção" : "Atualizar"}
      </Button>
      {(erro || ok) && (
        <Alert variant={erro ? "destructive" : "default"} className="sm:col-span-3">
          <AlertDescription>{erro ?? ok}</AlertDescription>
        </Alert>
      )}
    </div>
  );
}
