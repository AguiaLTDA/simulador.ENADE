import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { MenuAluno } from "@/components/aluno/menu-aluno";
import { Cabecalho } from "@/components/cabecalho";
import { NOME_CURSO, destinoInicial, obterContexto } from "@/lib/contexto";

// Estrutura comum das telas do estudante: cabeçalho, menu lateral e área de conteúdo.
export default async function AlunoLayout({ children }: LayoutProps<"/">) {
  const ctx = await obterContexto();
  if (!ctx.estudante || ctx.estudante.status !== "ATIVO") redirect(destinoInicial(ctx));
  const recolhido = (await cookies()).get("menu_recolhido")?.value === "1";

  return (
    <>
      <Cabecalho nome={ctx.estudante.nome} detalhe={NOME_CURSO[ctx.estudante.curso]} />
      <div className="flex flex-1">
        <MenuAluno recolhidoInicial={recolhido} />
        <main className="min-w-0 flex-1 pb-24 lg:pb-0">{children}</main>
      </div>
    </>
  );
}
