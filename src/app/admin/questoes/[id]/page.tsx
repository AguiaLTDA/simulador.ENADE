import Link from "next/link";
import { notFound } from "next/navigation";
import { exigirGestor } from "@/lib/contexto";
import { CURSOS, type Curso } from "@/lib/cursos";
import type { DadosQuestao } from "@/lib/questoes";
import { createClient } from "@/lib/supabase/server";
import { carregarEixos, carregarPesos } from "../dados";
import { FormularioQuestao } from "../formulario-questao";

export const metadata = { title: "Editar questão — Portal Simulado ENADE" };

export default async function EditarQuestaoPage({ params }: PageProps<"/admin/questoes/[id]">) {
  const ctx = await exigirGestor();
  const { id } = await params;
  if (!/^[0-9a-f-]{36}$/i.test(id)) notFound();

  const supabase = await createClient();
  const [{ data: q }, { data: g }, pesos, eixos] = await Promise.all([
    supabase.from("questoes").select("*").eq("id", id).maybeSingle(),
    supabase.from("questoes_gabarito").select("gabarito, justificativa").eq("questao_id", id).maybeSingle(),
    carregarPesos(),
    carregarEixos(),
  ]);
  if (!q) notFound();

  const inicial: DadosQuestao = {
    id: q.id,
    componente: q.componente,
    cursos: (q.cursos as string[]).filter((c) => c !== "ALL") as Curso[],
    eixo: q.eixo,
    formato: q.formato,
    texto_apoio: q.texto_apoio ?? "",
    enunciado: q.enunciado,
    alt_a: q.alt_a ?? "",
    alt_b: q.alt_b ?? "",
    alt_c: q.alt_c ?? "",
    alt_d: q.alt_d ?? "",
    alt_e: q.alt_e ?? "",
    gabarito: g?.gabarito ?? "",
    justificativa: g?.justificativa ?? "",
    dificuldade: q.dificuldade,
    // Mostra o peso só se foi alterado em relação ao padrão da dificuldade.
    peso_pontos: q.peso_pontos === pesos[q.dificuldade as 1 | 2 | 3] ? "" : String(q.peso_pontos),
    fonte: q.fonte ?? "",
    status: q.status,
  };

  return (
    <>
      <div>
        <Link href="/admin/questoes" className="text-sm text-muted-foreground hover:text-foreground">
          ← Questões
        </Link>
        <h1 className="mt-1 text-2xl font-semibold tracking-tight">Editar questão</h1>
      </div>
      <FormularioQuestao
        inicial={inicial}
        pesos={pesos}
        eixos={eixos}
        cursosPermitidos={ctx.staff.cursos ?? CURSOS}
      />
    </>
  );
}
