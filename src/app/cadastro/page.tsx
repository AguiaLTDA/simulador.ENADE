import { redirect } from "next/navigation";
import { BotaoSair } from "@/components/botao-sair";
import { Marca } from "@/components/marca";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { destinoInicial, obterContexto } from "@/lib/contexto";
import { FormularioCadastro } from "./formulario-cadastro";

export default async function CadastroPage() {
  const ctx = await obterContexto();
  if (ctx.staff || ctx.estudante) redirect(destinoInicial(ctx));

  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-6 px-4 py-10">
      <Marca />
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>Primeiro acesso</CardTitle>
          <CardDescription>
            Complete seus dados para começar a treinar. Eles aparecem no seu perfil e nos
            relatórios da coordenação.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <FormularioCadastro />
        </CardContent>
      </Card>
      <div className="flex items-center gap-2 text-sm text-muted-foreground">
        <span>
          Entrou como <strong>{ctx.email}</strong>.
        </span>
        <BotaoSair rotulo="Não é você? Sair" />
      </div>
    </main>
  );
}
