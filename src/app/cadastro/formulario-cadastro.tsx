"use client";

import Link from "next/link";
import { useActionState, useState } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { cpfValido, mascaraCpf, mascaraTelefone, soDigitos } from "@/lib/formatos";
import { concluirCadastro, type EstadoCadastro } from "./actions";

export function FormularioCadastro() {
  const [estado, acao, pendente] = useActionState<EstadoCadastro, FormData>(concluirCadastro, {});
  const [cpf, setCpf] = useState(estado.valores?.cpf ?? "");
  const [telefone, setTelefone] = useState(estado.valores?.telefone ?? "");
  const [aceite, setAceite] = useState(false);

  const cpfCompleto = soDigitos(cpf).length === 11;
  const cpfErrado = cpfCompleto && !cpfValido(cpf);
  const telOk = /^[1-9]{2}\d{8,9}$/.test(soDigitos(telefone));
  const podeEnviar = cpfCompleto && !cpfErrado && telOk && aceite && !pendente;

  return (
    <form action={acao} className="space-y-5">
      {estado.erro && (
        <Alert variant="destructive">
          <AlertDescription>{estado.erro}</AlertDescription>
        </Alert>
      )}

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
          defaultValue={estado.valores?.nascimento}
          max={new Date().toISOString().slice(0, 10)}
          required
        />
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
        {pendente ? "Conferindo dados..." : "Concluir cadastro"}
      </Button>
    </form>
  );
}
