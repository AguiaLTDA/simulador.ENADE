"use client";

import { useRouter } from "next/navigation";
import { useState, useTransition } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { iniciarSimulado } from "../actions";

export function IniciarSimulado({ sessaoId }: { sessaoId: string }) {
  const router = useRouter();
  const [erro, setErro] = useState<string | null>(null);
  const [pendente, iniciar] = useTransition();

  function comecar() {
    setErro(null);
    iniciar(async () => {
      const r = await iniciarSimulado(sessaoId);
      if (r.erro) return setErro(r.erro);
      router.refresh();
    });
  }

  return (
    <div className="space-y-3">
      {erro && (
        <Alert variant="destructive">
          <AlertDescription>{erro}</AlertDescription>
        </Alert>
      )}
      <Button onClick={comecar} disabled={pendente}>
        {pendente ? "Iniciando..." : "Iniciar simulado"}
      </Button>
    </div>
  );
}
