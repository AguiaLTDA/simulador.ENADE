"use client";

import { useState, useTransition } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { NativeSelect } from "@/components/ui/native-select";
import { excluirAjuste, lancarAjuste } from "../actions";

export function FormularioAjuste({
  estudanteId,
  atividades,
}: {
  estudanteId: string;
  atividades: { sessao_id: string; titulo: string }[];
}) {
  const [tipo, setTipo] = useState<"BONUS" | "DESCONTO">("BONUS");
  const [pontos, setPontos] = useState("");
  const [motivo, setMotivo] = useState("");
  const [sessao, setSessao] = useState("");
  const [erro, setErro] = useState<string | null>(null);
  const [ok, setOk] = useState<string | null>(null);
  const [pendente, iniciar] = useTransition();

  const valor = Math.trunc(Number(pontos));
  const valido = Number.isFinite(valor) && valor > 0 && motivo.trim().length >= 3;

  function lancar() {
    if (!valido) return;
    setErro(null);
    setOk(null);
    const final = tipo === "BONUS" ? valor : -valor;
    iniciar(async () => {
      const r = await lancarAjuste(estudanteId, final, motivo.trim(), sessao || null);
      if (r.erro) return setErro(r.erro);
      setOk(`${final > 0 ? "Bônus" : "Desconto"} de ${Math.abs(final)} ponto(s) lançado.`);
      setPontos("");
      setMotivo("");
    });
  }

  return (
    <div className="space-y-4">
      <div className="grid gap-4 sm:grid-cols-[auto_10rem_1fr]">
        <div className="space-y-1.5">
          <Label htmlFor="tipo">Tipo</Label>
          <NativeSelect id="tipo" value={tipo} onChange={(e) => setTipo(e.target.value as "BONUS" | "DESCONTO")}>
            <option value="BONUS">Bônus (+)</option>
            <option value="DESCONTO">Desconto (−)</option>
          </NativeSelect>
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="pontos">Pontos</Label>
          <Input
            id="pontos"
            type="number"
            min={1}
            max={100000}
            step={1}
            value={pontos}
            onChange={(e) => setPontos(e.target.value)}
          />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="atividade">Atividade relacionada (opcional)</Label>
          <NativeSelect id="atividade" value={sessao} onChange={(e) => setSessao(e.target.value)}>
            <option value="">Nenhuma</option>
            {atividades.map((a) => (
              <option key={a.sessao_id} value={a.sessao_id}>
                {a.titulo}
              </option>
            ))}
          </NativeSelect>
        </div>
      </div>
      <div className="space-y-1.5">
        <Label htmlFor="motivo">Motivo</Label>
        <Input
          id="motivo"
          value={motivo}
          onChange={(e) => setMotivo(e.target.value)}
          maxLength={300}
          placeholder="Ex.: entrega da atividade complementar; correção de lançamento"
        />
        <p className="text-xs text-muted-foreground">Fica visível na auditoria e no histórico deste aluno.</p>
      </div>
      {erro && (
        <Alert variant="destructive">
          <AlertDescription>{erro}</AlertDescription>
        </Alert>
      )}
      {ok && (
        <Alert>
          <AlertDescription>{ok}</AlertDescription>
        </Alert>
      )}
      <Button onClick={lancar} disabled={!valido || pendente}>
        {pendente ? "Lançando..." : "Lançar ajuste"}
      </Button>
    </div>
  );
}

export function BotaoExcluirAjuste({ id, estudanteId }: { id: number; estudanteId: string }) {
  const [erro, setErro] = useState<string | null>(null);
  const [pendente, iniciar] = useTransition();

  function excluir() {
    if (!window.confirm("Excluir este ajuste? Os pontos saem do total do aluno.")) return;
    setErro(null);
    iniciar(async () => {
      const r = await excluirAjuste(id, estudanteId);
      if (r.erro) setErro(r.erro);
    });
  }

  return (
    <span className="inline-flex flex-col items-end gap-1">
      <Button variant="ghost" size="sm" onClick={excluir} disabled={pendente}>
        {pendente ? "Excluindo..." : "Excluir"}
      </Button>
      {erro && <span className="text-xs text-destructive">{erro}</span>}
    </span>
  );
}
