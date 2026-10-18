import { redirect } from "next/navigation";
import { BotaoSair } from "@/components/botao-sair";
import { Marca } from "@/components/marca";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { destinoInicial, obterContexto } from "@/lib/contexto";
import { createClient } from "@/lib/supabase/server";
import type { CadastroPendente } from "./actions";
import { FormularioCadastro } from "./formulario-cadastro";

export const metadata = { title: "Cadastro de estudante — Portal Simulado ENADE" };

export default async function CadastroPage() {
  const supabase = await createClient();
  const { data: auth } = await supabase.auth.getClaims();

  // Visitante: cadastro público.
  if (!auth?.claims?.sub) {
    return (
      <main className="flex flex-1 flex-col items-center justify-center gap-6 px-4 py-10">
        <Marca />
        <Card className="w-full max-w-md">
          <CardHeader>
            <CardTitle>Cadastro de estudante</CardTitle>
            <CardDescription>
              Preencha seus dados. Você vai receber um e-mail para criar a sua senha e concluir o
              cadastro.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <FormularioCadastro modo="novo" />
          </CardContent>
        </Card>
      </main>
    );
  }

  // Logado e ainda sem perfil: confirma os dados informados no 1º passo.
  const ctx = await obterContexto();
  if (ctx.staff || ctx.estudante) redirect(destinoInicial(ctx));

  const { data: usuario } = await supabase.auth.getUser();
  const pendente = usuario.user?.user_metadata?.cadastro as CadastroPendente | undefined;

  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-6 px-4 py-10">
      <Marca />
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>{pendente ? "Confirme seus dados" : "Complete seu cadastro"}</CardTitle>
          <CardDescription>
            {pendente
              ? "Confira as informações e conclua o cadastro para começar a treinar."
              : "Preencha seus dados para começar a treinar."}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <FormularioCadastro
            modo="confirmar"
            inicial={{
              nome: pendente?.nome ?? "",
              email: ctx.email,
              telefone: pendente?.telefone ?? "",
              cpf: pendente?.cpf ?? "",
              curso: pendente?.curso ?? "",
            }}
          />
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
