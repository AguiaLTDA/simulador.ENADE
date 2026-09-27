"use client";

import Link from "next/link";
import { useActionState, useState } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { NativeSelect } from "@/components/ui/native-select";
import { NOME_CURSO } from "@/lib/cursos";
import { cpfValido, mascaraCpf, mascaraTelefone, soDigitos } from "@/lib/formatos";
import { concluirCadastro, type EstadoCadastro } from "./actions";

export function FormularioCadastro() {
  const [estado, acao, pendente] = useActionState<EstadoCadastro, FormData>(concluirCadastro, {});
  const v = estado.valores;
  const [nome, setNome] = useState(v?.nome ?? "");
  const [cpf, setCpf] = useState(v?.cpf ?? "");
  const [telefone, setTelefone] = useState(v?.telefone ?? "");
  const [curso, setCurso] = useState(v?.curso ?? "");
  const [tipo, setTipo] = useState(v?.tipo ?? "");
  const [turma, setTurma] = useState(v?.turma ?? "");
  const [aceite, setAceite] = useState(false);

  const cpfCompleto = soDigitos(cpf).length === 11;
  const cpfErrado = cpfCompleto && !cpfValido(cpf);
  const telOk = /^[1-9]{2}\d{8,9}$/.test(soDigitos(telefone));
  const nomeOk = /\S+\s+\S+/.test(nome.trim());
  const podeEnviar =
    nomeOk && cpfCompleto && !cpfErrado && telOk && curso && tipo && turma.trim() && aceite && !pendente;

  return (
    <form action={acao} className="space-y-5">
      {estado.erro && (
        <Alert variant="destructive">
          <AlertDescription>{estado.erro}</AlertDescription>
        </Alert>
      )}

      <div className="space-y-2">
        <Label htmlFor="nome">Nome completo</Label>
        <Input
          id="nome"
          name="nome"
          autoComplete="name"
          value={nome}
          onChange={(e) => setNome(e.target.value)}
          maxLength={120}
          required
        />
      </div>

      <div className="grid gap-5 sm:grid-cols-2">
        <div className="space-y-2">
          <Label htmlFor="cpf">CPF</Label>
          <Input
            id="cpf"
            name="cpf"
            inputMode="numeric"
            autoComplete="off"
            placeholder="000.000.000-00"
            value={cpf}
            onChange={(e) => setCpf(mascaraCpf(e.target.value))}
            aria-invalid={cpfErrado || undefined}
            required
          />
          {cpfErrado && <p className="text-sm text-destructive">CPF inválido. Confira os números.</p>}
        </div>
        <div className="space-y-2">
          <Label htmlFor="nascimento">Data de nascimento</Label>
          <Input
            id="nascimento"
            name="nascimento"
            type="date"
            defaultValue={v?.nascimento}
            max={new Date().toISOString().slice(0, 10)}
            required
          />
        </div>
      </div>

      <div className="space-y-2">
        <Label htmlFor="telefone">Telefone (com DDD)</Label>
        <Input
          id="telefone"
          name="telefone"
          type="tel"
          inputMode="tel"
          autoComplete="tel-national"
          placeholder="(27) 99999-9999"
          value={telefone}
          onChange={(e) => setTelefone(mascaraTelefone(e.target.value))}
          required
        />
      </div>

      <div className="space-y-2">
        <Label htmlFor="curso">Curso</Label>
        <NativeSelect id="curso" name="curso" value={curso} onChange={(e) => setCurso(e.target.value)} required>
          <option value="" disabled>
            Selecione...
          </option>
          {Object.entries(NOME_CURSO).map(([valor, rotulo]) => (
            <option key={valor} value={valor}>
              {rotulo}
            </option>
          ))}
        </NativeSelect>
      </div>

      <div className="grid gap-5 sm:grid-cols-2">
        <div className="space-y-2">
          <Label htmlFor="turma">Turma</Label>
          <Input
            id="turma"
            name="turma"
            placeholder="Ex.: ADS-2023/1"
            value={turma}
            onChange={(e) => setTurma(e.target.value)}
            maxLength={40}
            required
          />
        </div>
        <div className="space-y-2">
          <Label htmlFor="matricula">
            Matrícula <span className="font-normal text-muted-foreground">(opcional)</span>
          </Label>
          <Input id="matricula" name="matricula" defaultValue={v?.matricula} maxLength={30} />
        </div>
      </div>

      <fieldset className="space-y-2">
        <legend className="text-sm font-medium">Situação no ENADE</legend>
        <div className="grid gap-2 sm:grid-cols-2">
          {[
            ["CONCLUINTE", "Concluinte", "Faço o ENADE neste ciclo"],
            ["INGRESSANTE", "Ingressante", "Estou no início do curso"],
          ].map(([valor, rotulo, dica]) => (
            <label
              key={valor}
              className="flex cursor-pointer items-start gap-3 rounded-lg border bg-background p-3 text-sm has-checked:border-primary"
            >
              <input
                type="radio"
                name="tipo"
                value={valor}
                checked={tipo === valor}
                onChange={() => setTipo(valor)}
                className="mt-0.5 size-4 accent-primary"
              />
              <span>
                <span className="block font-medium">{rotulo}</span>
                <span className="block text-xs text-muted-foreground">{dica}</span>
              </span>
            </label>
          ))}
        </div>
      </fieldset>

      <label className="flex items-start gap-3 rounded-lg border bg-background p-3 text-sm">
        <input
          type="checkbox"
          name="aceite_lgpd"
          className="mt-0.5 size-4 accent-primary"
          checked={aceite}
          onChange={(e) => setAceite(e.target.checked)}
        />
        <span>
          Li e aceito o{" "}
          <Link href="/termo-lgpd" target="_blank" className="font-medium underline underline-offset-4">
            termo de consentimento para tratamento de dados (LGPD)
          </Link>
          .
        </span>
      </label>

      <Button type="submit" className="w-full" disabled={!podeEnviar}>
        {pendente ? "Salvando..." : "Concluir cadastro"}
      </Button>
    </form>
  );
}
