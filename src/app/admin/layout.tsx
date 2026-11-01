import { AbasAdmin } from "@/components/abas-admin";
import { Cabecalho } from "@/components/cabecalho";
import { exigirStaff } from "@/lib/contexto";
import { descreverPerfil } from "@/lib/cursos";

export default async function AdminLayout({ children }: LayoutProps<"/admin">) {
  const { staff } = await exigirStaff();
  const gestor = staff.papel !== "DOCENTE";

  const itens: [string, string, boolean][] = [
    ["/admin", "Visão geral", true],
    ["/admin/questoes", "Questões", gestor],
    ["/admin/alunos", "Alunos", gestor],
    ["/admin/simulados", "Simulados", true],
    ["/admin/correcoes", "Correções", true],
    ["/admin/ranking", "Classificação", true],
    ["/admin/pontuacao", "Pontuação", gestor],
    ["/admin/diagnostico", "Diagnóstico inicial", true],
    ["/admin/equipe", "Equipe", staff.papel === "ADMIN"],
    ["/admin/configuracoes", "Configurações", staff.papel === "ADMIN"],
  ];

  return (
    <>
      <Cabecalho nome={staff.nome} detalhe={descreverPerfil(staff.papel, staff.cursos)} />
      <AbasAdmin itens={itens.filter(([, , visivel]) => visivel).map(([href, rotulo]) => [href, rotulo])} />
      <main className="mx-auto w-full max-w-6xl space-y-6 px-4 py-8">{children}</main>
    </>
  );
}
