"use client";

import { useRouter } from "next/navigation";
import { useState, useTransition } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { excluirAlunoLgpd } from "../actions";

// Exclusão definitiva (LGPD, art. 18): exige digitar o primeiro nome do aluno.
export function ExcluirLgpd({ id, nome }: { id: string; nome: string }) {
  const router = useRouter();
  const [aberto, setAberto] = useState(false);
  const [confirmacao, setConfirmacao] = useState("");
  const [erro, setErro] = useState<string | null>(null);
  const [pendente, iniciar] = useTransition();
  const primeiroNome = nome.split(" ")[0];

  function excluir() {
    setErro(null);
    iniciar(async () => {
      const r = await excluirAlunoLgpd(id);
      if (r.erro) return setErro(r.erro);
      router.push("/admin/alunos?excluido=1");
    });
  }

  return (
    <div className="space-y-3 rounded-xl border border-destructive/40 bg-background p-5">
      <p className="font-medium">Exclusão de dados (LGPD)</p>
      <p className="text-sm text-muted-foreground">
        Apaga definitivamente a conta do aluno, respostas, simulados, conquistas e histórico. Use apenas quando o
        aluno pedir a eliminação dos dados. Não pode ser desfeito.
      </p>
      {!aberto ? (
        <Button variant="destructive" onClick={() => setAberto(true)}>
          Excluir dados do aluno
        </Button>
      ) : (
        <div className="flex flex-wrap items-center gap-2">
          <Input
            className="max-w-xs"
            placeholder={`Digite “${primeiroNome}” para confirmar`}
            value={confirmacao}
            onChange={(e) => setConfirmacao(e.target.value)}
          />
          <Button
            variant="destructive"
            onClick={excluir}
            disabled={confirmacao.trim().toLowerCase() !== primeiroNome.toLowerCase() || pendente}
          >
            {pendente ? "Excluindo..." : "Excluir definitivamente"}
          </Button>
          <Button variant="ghost" onClick={() => setAberto(false)} disabled={pendente}>
            Cancelar
          </Button>
        </div>
      )}
      {erro && (
        <Alert variant="destructive">
          <AlertDescription>{erro}</AlertDescription>
        </Alert>
      )}
    </div>
  );
}
