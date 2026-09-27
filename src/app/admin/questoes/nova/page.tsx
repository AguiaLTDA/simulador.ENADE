import Link from "next/link";
import { exigirAdmin } from "@/lib/contexto";
import { QUESTAO_VAZIA } from "@/lib/questoes";
import { carregarEixos, carregarPesos } from "../dados";
import { FormularioQuestao } from "../formulario-questao";

export const metadata = { title: "Nova questão — Portal Simulado ENADE" };

export default async function NovaQuestaoPage() {
  await exigirAdmin();
  const [pesos, eixos] = await Promise.all([carregarPesos(), carregarEixos()]);

  return (
    <>
      <div>
        <Link href="/admin/questoes" className="text-sm text-muted-foreground hover:text-foreground">
          ← Questões
        </Link>
        <h1 className="mt-1 text-2xl font-semibold tracking-tight">Nova questão</h1>
      </div>
      <FormularioQuestao inicial={QUESTAO_VAZIA} pesos={pesos} eixos={eixos} />
    </>
  );
}
