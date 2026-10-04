"use client";

import { useState, useTransition } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { NativeSelect } from "@/components/ui/native-select";
import { NOME_CURSO, type Curso } from "@/lib/cursos";
import { cpfValido, mascaraCpf, mascaraTelefone, soDigitos } from "@/lib/formatos";
import { atualizarAluno, type DadosAluno } from "../actions";

export function FormularioAluno({ id, inicial, cursos }: { id: string; inicial: DadosAluno; cursos: Curso[] }) {
  const [f, setF] = useState(inicial);
  const [msg, setMsg] = useState<{ erro?: string; ok?: string }>({});
  const [pendente, iniciar] = useTransition();
  const set = <K extends keyof DadosAluno>(k: K, v: DadosAluno[K]) => setF((x) => ({ ...x, [k]: v }));

  const cpfErrado = soDigitos(f.cpf).length === 11 && !cpfValido(f.cpf);
  const alterado = JSON.stringify(f) !== JSON.stringify(inicial);

  function salvar() {
    setMsg({});
    iniciar(async () => {
      const r = await atualizarAluno(id, { ...f, cpf: soDigitos(f.cpf), telefone: soDigitos(f.telefone) });
      setMsg(r.erro ? { erro: r.erro } : { ok: "Perfil atualizado." });
    });
  }

  return (
    <div className="space-y-4">
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <div className="space-y-1.5 sm:col-span-2">
          <Label htmlFor="nome">Nome completo</Label>
          <Input id="nome" value={f.nome} onChange={(e) => set("nome", e.target.value)} maxLength={120} />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="status">Status</Label>
          <NativeSelect id="status" value={f.status} onChange={(e) => set("status", e.target.value as DadosAluno["status"])}>
            <option value="ATIVO">Ativo</option>
            <option value="BLOQUEADO">Bloqueado</option>
            {inicial.status === "PENDENTE" && <option value="PENDENTE">Pendente</option>}
          </NativeSelect>
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="cpf">CPF</Label>
          <Input
            id="cpf"
            inputMode="numeric"
            value={f.cpf}
            onChange={(e) => set("cpf", mascaraCpf(e.target.value))}
            aria-invalid={cpfErrado}
          />
          {cpfErrado && <p className="text-xs text-destructive">CPF inválido.</p>}
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="nasc">Data de nascimento</Label>
          <Input id="nasc" type="date" value={f.data_nascimento} onChange={(e) => set("data_nascimento", e.target.value)} />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="tel">Telefone</Label>
          <Input
            id="tel"
            inputMode="tel"
            value={f.telefone}
            onChange={(e) => set("telefone", mascaraTelefone(e.target.value))}
          />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="curso">Curso</Label>
          <NativeSelect id="curso" value={f.curso} onChange={(e) => set("curso", e.target.value as Curso)}>
            {cursos.map((c) => (
              <option key={c} value={c}>
                {NOME_CURSO[c]}
              </option>
            ))}
          </NativeSelect>
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="turma">Turma</Label>
          <Input id="turma" value={f.turma} onChange={(e) => set("turma", e.target.value)} maxLength={40} />
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="tipo">Situação no ENADE</Label>
          <NativeSelect id="tipo" value={f.tipo} onChange={(e) => set("tipo", e.target.value as DadosAluno["tipo"])}>
            <option value="CONCLUINTE">Concluinte</option>
            <option value="INGRESSANTE">Ingressante</option>
          </NativeSelect>
        </div>
        <div className="space-y-1.5">
          <Label htmlFor="mat">Matrícula (opcional)</Label>
          <Input id="mat" value={f.matricula} onChange={(e) => set("matricula", e.target.value)} maxLength={30} />
        </div>
      </div>

      {(msg.erro || msg.ok) && (
        <Alert variant={msg.erro ? "destructive" : "default"}>
          <AlertDescription>{msg.erro ?? msg.ok}</AlertDescription>
        </Alert>
      )}

      <div className="flex justify-end gap-2">
        {alterado && (
          <Button variant="ghost" onClick={() => setF(inicial)} disabled={pendente}>
            Desfazer
          </Button>
        )}
        <Button onClick={salvar} disabled={!alterado || cpfErrado || pendente}>
          {pendente ? "Salvando..." : "Salvar alterações"}
        </Button>
      </div>
    </div>
  );
}
