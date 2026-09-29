import Link from "next/link";
import { Cabecalho } from "@/components/cabecalho";
import { exigirStaff } from "@/lib/contexto";
import { descreverPerfil } from "@/lib/cursos";

export default async function AdminLayout({ children }: LayoutProps<"/admin">) {
  const { staff } = await exigirStaff();
  const gestor = staff.papel !== "DOCENTE";

  const itens: [string, string, boolean][] = [
    ["/admin", "Visão geral", true],
    ["/admin/questoes", "Questões", gestor],
    ["/admin/diagnostico", "Diagnóstico inicial", true],
    ["/admin/equipe", "Equipe", staff.papel === "ADMIN"],
  ];

  return (
    <>
      <Cabecalho nome={staff.nome} detalhe={descreverPerfil(staff.papel, staff.cursos)} />
      <nav className="border-b bg-background">
        <div className="mx-auto flex w-full max-w-6xl gap-1 overflow-x-auto px-4 text-sm">
          {itens
            .filter(([, , visivel]) => visivel)
            .map(([href, rotulo]) => (
              <Link
                key={href}
                href={href}
                className="whitespace-nowrap px-3 py-2.5 text-muted-foreground hover:text-foreground"
              >
                {rotulo}
              </Link>
            ))}
        </div>
      </nav>
      <main className="mx-auto w-full max-w-6xl space-y-6 px-4 py-8">{children}</main>
    </>
  );
}
