import { redirect } from "next/navigation";
import { Cabecalho } from "@/components/cabecalho";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { destinoInicial, obterContexto } from "@/lib/contexto";

export default async function AdminPage() {
  const ctx = await obterContexto();
  if (!ctx.staff) redirect(destinoInicial(ctx));

  return (
    <>
      <Cabecalho
        nome={ctx.staff.nome}
        detalhe={ctx.staff.papel === "ADMIN" ? "Coordenação / NDE" : "Docente"}
      />
      <main className="mx-auto w-full max-w-5xl space-y-6 px-4 py-8">
        <h1 className="text-2xl font-semibold tracking-tight">Painel da coordenação</h1>
        <Card>
          <CardHeader>
            <CardTitle>Em construção</CardTitle>
            <CardDescription>
              Banco de questões, importação CSV, simulados, correção de discursivas e relatórios
              chegam nos próximos sprints.
            </CardDescription>
          </CardHeader>
        </Card>
      </main>
    </>
  );
}
