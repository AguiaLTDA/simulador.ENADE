"use client";

import Link from "next/link";
import { useActionState } from "react";
import { MailCheck } from "lucide-react";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { enviarLinkSenha, type EstadoLink } from "../login/actions";

export function FormularioRecuperar() {
  const [estado, acao, pendente] = useActionState<EstadoLink, FormData>(enviarLinkSenha, {
    status: "inicial",
  });

  if (estado.status === "enviado") {
    return (
      <div className="space-y-4">
        <Alert>
          <MailCheck />
          <AlertTitle>Confira seu e-mail</AlertTitle>
          <AlertDescription>
            Enviamos um link para <strong>{estado.email}</strong>. Abra o e-mail, toque no link e
            crie a sua senha. O link vale por 1 hora. Se não chegar em alguns minutos, olhe a caixa
            de spam.
          </AlertDescription>
        </Alert>
        <Link href="/login" className="block text-center text-sm underline underline-offset-4">
          Voltar para o login
        </Link>
      </div>
    );
  }

  return (
    <form action={acao} className="space-y-4">
      {estado.status === "erro" && (
        <Alert variant="destructive">
          <AlertDescription>{estado.mensagem}</AlertDescription>
        </Alert>
      )}
      <div className="space-y-2">
        <Label htmlFor="email">E-mail</Label>
        <Input
          id="email"
          name="email"
          type="email"
          autoComplete="email"
          inputMode="email"
          placeholder="seunome@gmail.com"
          defaultValue={estado.email}
          required
        />
      </div>
      <Button type="submit" className="w-full" disabled={pendente}>
        {pendente ? "Enviando..." : "Enviar link para criar a senha"}
      </Button>
      <Link href="/login" className="block text-center text-sm underline underline-offset-4">
        Voltar para o login
      </Link>
    </form>
  );
}
