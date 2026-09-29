"use client";

import { useActionState, useState } from "react";
import { Check, Eye, EyeOff, X } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { SENHA_MIN } from "@/lib/senha";
import { cn } from "@/lib/utils";
import { definirSenha, type EstadoSenha } from "./actions";

export function FormularioSenha() {
  const [estado, acao, pendente] = useActionState<EstadoSenha, FormData>(definirSenha, {});
  const [senha, setSenha] = useState("");
  const [confirmacao, setConfirmacao] = useState("");
  const [ver, setVer] = useState(false);

  const regras = [
    [`Pelo menos ${SENHA_MIN} caracteres`, senha.length >= SENHA_MIN],
    ["Letras e números", /[A-Za-zÀ-ÿ]/.test(senha) && /\d/.test(senha)],
    ["As duas senhas são iguais", senha.length > 0 && senha === confirmacao],
  ] as const;
  const ok = regras.every(([, v]) => v);

  return (
    <form action={acao} className="space-y-4">
      {estado.erro && (
        <Alert variant="destructive">
          <AlertDescription>{estado.erro}</AlertDescription>
        </Alert>
      )}
      <div className="space-y-2">
        <Label htmlFor="senha">Nova senha</Label>
        <div className="relative">
          <Input
            id="senha"
            name="senha"
            type={ver ? "text" : "password"}
            autoComplete="new-password"
            className="pr-10"
            value={senha}
            onChange={(e) => setSenha(e.target.value)}
            maxLength={72}
            required
          />
          <button
            type="button"
            onClick={() => setVer((v) => !v)}
            className="absolute inset-y-0 right-0 flex w-10 items-center justify-center text-muted-foreground hover:text-foreground"
            aria-label={ver ? "Ocultar senha" : "Mostrar senha"}
          >
            {ver ? <EyeOff className="size-4" /> : <Eye className="size-4" />}
          </button>
        </div>
      </div>
      <div className="space-y-2">
        <Label htmlFor="confirmacao">Confirme a nova senha</Label>
        <Input
          id="confirmacao"
          name="confirmacao"
          type={ver ? "text" : "password"}
          autoComplete="new-password"
          value={confirmacao}
          onChange={(e) => setConfirmacao(e.target.value)}
          maxLength={72}
          required
        />
      </div>
      <ul className="space-y-1 text-sm">
        {regras.map(([rotulo, atende]) => (
          <li key={rotulo} className={cn("flex items-center gap-2", atende ? "text-emerald-700 dark:text-emerald-400" : "text-muted-foreground")}>
            {atende ? <Check className="size-4" /> : <X className="size-4" />}
            {rotulo}
          </li>
        ))}
      </ul>
      <Button type="submit" className="w-full" disabled={!ok || pendente}>
        {pendente ? "Salvando..." : "Salvar senha"}
      </Button>
    </form>
  );
}
