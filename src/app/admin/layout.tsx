import Link from "next/link";
import { Cabecalho } from "@/components/cabecalho";
import { destinoInicial, obterContexto } from "@/lib/contexto";
import { redirect } from "next/navigation";

export default async function AdminLayout({ children }: LayoutProps<"/admin">) {
  const ctx = await obterContexto();
  if (!ctx.staff) redirect(destinoInicial(ctx));
  const admin = ctx.staff.papel === "ADMIN";

  return (
    <>
      <Cabecalho nome={ctx.staff.nome} detalhe={admin ? "Coordenação / NDE" : "Docente"} />
      <nav className="border-b bg-background">
        <div className="mx-auto flex w-full max-w-6xl gap-1 overflow-x-auto px-4 text-sm">
          <Link href="/admin" className="px-3 py-2.5 text-muted-foreground hover:text-foreground">
            Visão geral
          </Link>
          {admin && (
            <Link href="/admin/questoes" className="px-3 py-2.5 text-muted-foreground hover:text-foreground">
              Questões
            </Link>
          )}
        </div>
      </nav>
      <main className="mx-auto w-full max-w-6xl space-y-6 px-4 py-8">{children}</main>
    </>
  );
}
