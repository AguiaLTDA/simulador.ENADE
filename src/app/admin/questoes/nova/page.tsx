import Link from "next/link";
import { exigirGestor } from "@/lib/contexto";
import { CURSOS } from "@/lib/cursos";
import { QUESTAO_VAZIA } from "@/lib/questoes";
import { carregarEixos, carregarPesos } from "../dados";
import { FormularioQuestao } from "../formulario-questao";

export const metadata = { title: "Nova questão — Portal Simulado ENADE" };

export default async function NovaQuestaoPage() {
  const ctx = await exigirGestor();
  const [pesos, eixos] = await Promise.all([carregarPesos(), carregarEixos()]);

  return (
    <>
      <div>
        <Link href="/admin/questoes" className="text-sm text-muted-foreground hover:text-foreground">
          ← Questões
        </Link>
        <h1 className="mt-1 text-2xl font-semibold tracking-tight">Nova questão</h1>
      </div>
      <FormularioQuestao
        inicial={{ ...QUESTAO_VAZIA, cursos: ctx.staff.cursos?.length === 1 ? ctx.staff.cursos : [] }}
        pesos={pesos}
        eixos={eixos}
        cursosPermitidos={ctx.staff.cursos ?? CURSOS}
      />
    </>
  );
}
