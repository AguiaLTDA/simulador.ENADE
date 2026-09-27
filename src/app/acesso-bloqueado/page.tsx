import { redirect } from "next/navigation";
import { BotaoSair } from "@/components/botao-sair";
import { Marca } from "@/components/marca";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { destinoInicial, obterContexto } from "@/lib/contexto";

export default async function AcessoBloqueadoPage() {
  const ctx = await obterContexto();
  if (!ctx.estudante || ctx.estudante.status === "ATIVO") redirect(destinoInicial(ctx));

  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-6 px-4 py-10">
      <Marca />
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>
            {ctx.estudante.status === "BLOQUEADO" ? "Acesso bloqueado" : "Cadastro em análise"}
          </CardTitle>
          <CardDescription>
            Procure a coordenação do seu curso para regularizar o acesso ao portal.
          </CardDescription>
        </CardHeader>
      </Card>
      <BotaoSair />
    </main>
  );
}
