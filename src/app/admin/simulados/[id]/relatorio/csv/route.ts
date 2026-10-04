import { exigirStaff } from "@/lib/contexto";
import { NOME_CURSO } from "@/lib/cursos";
import { carregarRelatorio } from "../dados";

// Planilha por aluno (separador ";" e BOM para abrir direto no Excel em pt-BR).
export async function GET(_req: Request, ctx: RouteContext<"/admin/simulados/[id]/relatorio/csv">) {
  await exigirStaff();
  const { id } = await ctx.params;
  const r = /^[0-9a-f-]{36}$/i.test(id) ? await carregarRelatorio(id) : null;
  if (!r) return new Response("Simulado não encontrado.", { status: 404 });

  const num = (n: number | null | undefined) => (n == null ? "" : String(n).replace(".", ","));
  const campo = (v: string) => (/[;"\n]/.test(v) ? `"${v.replace(/"/g, '""')}"` : v);
  const linhas = [
    ["Aluno", "Curso", "Turma", "Situação", "Iniciado em", "Finalizado em", "FG objetivas (acertos)",
     "FG objetivas (total)", "CE objetivas (acertos)", "CE objetivas (total)", "Nota FG", "Nota CE",
     "Nota estimada", "Discursivas pendentes", "Respondidas", "Total de questões"],
    ...r.participantes.map((p) => {
      const fg = p.desempenho.componentes.FG;
      const ce = p.desempenho.componentes.CE;
      return [
        p.nome, NOME_CURSO[p.curso], p.turma, p.encerrado ? "Concluído" : "Em andamento",
        p.iniciada_em, p.finalizada_em ?? "",
        num(fg?.obj_acertos), num(fg?.obj_total), num(ce?.obj_acertos), num(ce?.obj_total),
        num(fg?.nota), num(ce?.nota), num(p.desempenho.nota), num(p.desempenho.pendentes),
        num(p.desempenho.respondidas), num(p.desempenho.total),
      ];
    }),
  ];
  const csv = "﻿" + linhas.map((l) => l.map((v) => campo(String(v))).join(";")).join("\r\n");
  const nome = r.sessao.titulo.normalize("NFD").replace(/[^\w]+/g, "-").replace(/^-|-$/g, "").toLowerCase();

  return new Response(csv, {
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="relatorio-${nome || "simulado"}.csv"`,
      "Cache-Control": "no-store",
    },
  });
}
