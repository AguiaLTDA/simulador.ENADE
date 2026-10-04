import type { NextRequest } from "next/server";
import { exigirStaff } from "@/lib/contexto";
import { escreverCsv } from "@/lib/csv";
import { NOME_CURSO } from "@/lib/cursos";
import { NOME_PERIODO, percentual } from "@/lib/ranking";
import { carregarRanking, lerFiltros } from "../dados";

// Planilha da classificação com os mesmos filtros da tela.
export async function GET(req: NextRequest) {
  await exigirStaff();
  const f = lerFiltros(Object.fromEntries(req.nextUrl.searchParams));
  const { alunos } = await carregarRanking(f);

  const csv = escreverCsv([
    ["Posição", "Aluno", "E-mail", "Curso", "Turma", "Situação", "Pontos", "Questões respondidas",
     "Objetivas (1ª tentativa)", "Acertos", "Acerto (%)", "Simulados concluídos", "Última atividade"],
    ...alunos.map((a) => [
      a.posicao ? String(a.posicao) : "", a.nome, a.email, NOME_CURSO[a.curso], a.turma,
      a.tipo === "CONCLUINTE" ? "Concluinte" : "Ingressante", String(a.pontos), String(a.respondidas),
      String(a.objetivas), String(a.acertos), String(percentual(a.acertos, a.objetivas) ?? ""),
      String(a.simulados), a.ultima_atividade ?? "",
    ]),
  ]);
  const periodo = NOME_PERIODO[f.periodo].toLowerCase().replace(/[^\w]+/g, "-");

  return new Response(csv, {
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="classificacao-${periodo}.csv"`,
      "Cache-Control": "no-store",
    },
  });
}
