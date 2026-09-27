import { redirect } from "next/navigation";
import { Cabecalho } from "@/components/cabecalho";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { NOME_CURSO, destinoInicial, obterContexto } from "@/lib/contexto";

export default async function InicioPage() {
  const ctx = await obterContexto();
  if (!ctx.estudante || ctx.estudante.status !== "ATIVO") redirect(destinoInicial(ctx));
  const { nome, curso, turma } = ctx.estudante;
  const primeiroNome = nome.split(" ")[0];

  return (
    <>
      <Cabecalho nome={nome} detalhe={`${NOME_CURSO[curso]} · ${turma}`} />
      <main className="mx-auto w-full max-w-5xl space-y-6 px-4 py-8">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight">Olá, {primeiroNome}!</h1>
          <p className="text-muted-foreground">Seu cadastro está ativo. Escolha como quer treinar.</p>
        </div>
        <div className="grid gap-4 sm:grid-cols-3">
          {[
            ["Treino Livre", "Questões por componente, eixo e dificuldade, com devolutiva na hora."],
            ["Simulados", "Provas cronometradas no formato ENADE, com relatório ao final."],
            ["Meu desempenho", "Mapa por eixo, evolução, conquistas e ranking."],
          ].map(([titulo, desc]) => (
            <Card key={titulo} className="opacity-70">
              <CardHeader>
                <CardTitle>{titulo}</CardTitle>
                <CardDescription>{desc}</CardDescription>
                <p className="pt-2 text-xs font-medium text-muted-foreground">Em breve</p>
              </CardHeader>
            </Card>
          ))}
        </div>
      </main>
    </>
  );
}
