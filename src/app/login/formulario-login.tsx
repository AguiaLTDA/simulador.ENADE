"use client";

import { useActionState } from "react";
import { MailCheck } from "lucide-react";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { enviarLink, type EstadoLogin } from "./actions";

export function FormularioLogin({ erroLink }: { erroLink: boolean }) {
  const [estado, acao, pendente] = useActionState<EstadoLogin, FormData>(enviarLink, {
    status: "inicial",
  });

  if (estado.status === "enviado") {
    return (
      <Alert>
        <MailCheck />
        <AlertTitle>Confira seu e-mail</AlertTitle>
        <AlertDescription>
          Enviamos um link de acesso para <strong>{estado.email}</strong>. Abra o e-mail e toque
          no link para entrar. Se não chegar em alguns minutos, olhe a caixa de spam.
        </AlertDescription>
      </Alert>
    );
  }

  return (
    <form action={acao} className="space-y-4">
      {erroLink && estado.status === "inicial" && (
        <Alert variant="destructive">
          <AlertDescription>
            O link expirou ou já foi usado. Peça um novo abaixo.
          </AlertDescription>
        </Alert>
      )}
      {estado.status === "erro" && (
        <Alert variant="destructive">
          <AlertDescription>{estado.mensagem}</AlertDescription>
        </Alert>
      )}
      <div className="space-y-2">
        <Label htmlFor="email">E-mail pessoal</Label>
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
        {pendente ? "Enviando..." : "Receber link de acesso"}
      </Button>
      <p className="text-center text-xs text-muted-foreground">
        Sem senha: você entra pelo link que chega no seu e-mail.
      </p>
    </form>
  );
}
