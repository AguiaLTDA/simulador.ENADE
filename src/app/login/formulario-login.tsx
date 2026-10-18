"use client";

import Link from "next/link";
import { useActionState, useState } from "react";
import { Eye, EyeOff } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { entrar, type EstadoLogin } from "./actions";

export function FormularioLogin({ aviso }: { aviso?: "link" | "senha-criada" }) {
  const [estado, acao, pendente] = useActionState<EstadoLogin, FormData>(entrar, {});
  const [verSenha, setVerSenha] = useState(false);

  return (
    <form action={acao} className="space-y-4">
      {aviso === "link" && !estado.erro && (
        <Alert variant="destructive">
          <AlertDescription>O link expirou ou já foi usado. Peça um novo em “Esqueci minha senha”.</AlertDescription>
        </Alert>
      )}
      {estado.erro && (
        <Alert variant="destructive">
          <AlertDescription>{estado.erro}</AlertDescription>
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

      <div className="space-y-2">
        <Label htmlFor="senha">Senha</Label>
        <div className="relative">
          <Input
            id="senha"
            name="senha"
            type={verSenha ? "text" : "password"}
            autoComplete="current-password"
            className="pr-10"
            required
          />
          <button
            type="button"
            onClick={() => setVerSenha((v) => !v)}
            className="absolute inset-y-0 right-0 flex w-10 items-center justify-center text-muted-foreground hover:text-foreground"
            aria-label={verSenha ? "Ocultar senha" : "Mostrar senha"}
          >
            {verSenha ? <EyeOff className="size-4" /> : <Eye className="size-4" />}
          </button>
        </div>
      </div>

      <Button type="submit" className="w-full" disabled={pendente}>
        {pendente ? "Entrando..." : "Entrar"}
      </Button>

      <div className="space-y-2 text-center text-sm">
        <Link href="/recuperar-senha" className="block font-medium underline underline-offset-4">
          Esqueci minha senha
        </Link>
        <p className="text-muted-foreground">
          Ainda não tem conta?{" "}
          <Link href="/cadastro" className="font-medium text-foreground underline underline-offset-4">
            Cadastre-se
          </Link>
        </p>
      </div>
    </form>
  );
}
