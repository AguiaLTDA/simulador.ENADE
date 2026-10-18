"use client";

import Link from "next/link";
import { useActionState, useState } from "react";
import { MailCheck } from "lucide-react";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { NativeSelect } from "@/components/ui/native-select";
import { CURSOS, NOME_CURSO } from "@/lib/cursos";
import { cpfValido, mascaraCpf, mascaraTelefone, soDigitos } from "@/lib/formatos";
import { concluirCadastro, solicitarCadastro, type EstadoCadastro, type ValoresCadastro } from "./actions";

// modo "novo": visitante sem conta (pede e-mail e envia o link para criar a senha).
// modo "confirmar": já logado, sem perfil de estudante (e-mail fixo da conta).
export function FormularioCadastro({
  modo,
  inicial,
}: {
  modo: "novo" | "confirmar";
  inicial?: Partial<ValoresCadastro>;
}) {
  const [estado, acao, pendente] = useActionState<EstadoCadastro, FormData>(
    modo === "novo" ? solicitarCadastro : concluirCadastro,
    {},
  );
  const v = { ...inicial, ...estado.valores };
  const [nome, setNome] = useState(v.nome ?? "");
  const [email, setEmail] = useState(v.email ?? "");
  const [telefone, setTelefone] = useState(v.telefone ? mascaraTelefone(v.telefone) : "");
  const [cpf, setCpf] = useState(v.cpf ? mascaraCpf(v.cpf) : "");
  const [curso, setCurso] = useState(v.curso ?? "");
  const [aceite, setAceite] = useState(false);

  if (estado.enviado) {
    return (
      <div className="space-y-4">
        <Alert>
          <MailCheck />
          <AlertTitle>Confira seu e-mail</AlertTitle>
          <AlertDescription>
            Enviamos um link para <strong>{estado.valores?.email}</strong>. Abra o e-mail, toque no
            link e crie a sua senha para concluir o cadastro. O link vale por 1 hora. Se não chegar
            em alguns minutos, olhe a caixa de spam.
          </AlertDescription>
        </Alert>
        <Link href="/login" className="block text-center text-sm underline underline-offset-4">
          Voltar para o login
        </Link>
      </div>
    );
  }

  const cpfCompleto = soDigitos(cpf).length === 11;
  const cpfErrado = cpfCompleto && !cpfValido(cpf);
  const podeEnviar =
    /\S+\s+\S+/.test(nome.trim()) &&
    (modo === "confirmar" || /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) &&
    /^[1-9]{2}\d{8,9}$/.test(soDigitos(telefone)) &&
    cpfCompleto &&
    !cpfErrado &&
    curso &&
    aceite &&
    !pendente;

  return (
    <form action={acao} className="space-y-4">
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

      <div className="space-y-2">
        <Label htmlFor="email">E-mail</Label>
        {modo === "novo" ? (
          <Input
            id="email"
            name="email"
            type="email"
            autoComplete="email"
            inputMode="email"
            placeholder="seunome@gmail.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        ) : (
          <Input id="email" value={email} readOnly disabled />
        )}
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
        <Label htmlFor="curso">Curso de graduação</Label>
        <NativeSelect id="curso" name="curso" value={curso} onChange={(e) => setCurso(e.target.value)} required>
          <option value="" disabled>
            Selecione...
          </option>
          {CURSOS.map((c) => (
            <option key={c} value={c}>
              {NOME_CURSO[c]}
            </option>
          ))}
        </NativeSelect>
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
        {pendente ? "Enviando..." : modo === "novo" ? "Cadastrar" : "Concluir cadastro"}
      </Button>

      {modo === "novo" && (
        <p className="text-center text-sm text-muted-foreground">
          Já tem conta?{" "}
          <Link href="/login" className="font-medium text-foreground underline underline-offset-4">
            Entrar
          </Link>
        </p>
      )}
    </form>
  );
}
