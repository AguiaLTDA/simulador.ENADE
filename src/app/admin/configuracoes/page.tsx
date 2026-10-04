import { exigirAdminGeral } from "@/lib/contexto";
import { formatarDataHora } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";
import { FormularioConfig } from "./formulario-config";

export const metadata = { title: "Configurações — Portal Simulado ENADE" };

export default async function ConfiguracoesPage() {
  await exigirAdminGeral();
  const supabase = await createClient();
  const [{ data: config }, { data: historico }, { data: equipe }] = await Promise.all([
    supabase.from("config").select("chave, valor"),
    supabase
      .from("auditoria")
      .select("autor_id, detalhes, criado_em")
      .eq("acao", "CONFIG_ALTERADA")
      .order("criado_em", { ascending: false })
      .limit(10),
    supabase.from("staff").select("user_id, nome"),
  ]);
  const valores = Object.fromEntries((config ?? []).map((c) => [c.chave, Number(c.valor)]));
  const nomes = new Map((equipe ?? []).map((s) => [s.user_id, s.nome]));

  return (
    <>
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Configurações</h1>
        <p className="text-muted-foreground">
          Critérios e pesos da pontuação, da nota estimada e do diagnóstico. As mudanças valem para as próximas
          respostas; pontos já ganhos não são recalculados.
        </p>
      </div>

      <FormularioConfig valores={valores} />

      {historico && historico.length > 0 && (
        <div className="space-y-2 rounded-xl border bg-background p-5">
          <p className="font-medium">Últimas alterações</p>
          <ul className="space-y-2 text-sm">
            {historico.map((h, i) => {
              const d = h.detalhes as {
                valores: Record<string, { de: number; para: number }>;
                questoes_atualizadas: number;
              };
              return (
                <li key={i} className="border-t pt-2 first:border-t-0 first:pt-0">
                  <span className="text-muted-foreground">
                    {formatarDataHora(h.criado_em)} · {nomes.get(h.autor_id) ?? "—"}:
                  </span>{" "}
                  {Object.entries(d.valores)
                    .map(([k, v]) => `${k} ${v.de} → ${v.para}`)
                    .join("; ")}
                  {d.questoes_atualizadas > 0 && ` (${d.questoes_atualizadas} questões atualizadas)`}
                </li>
              );
            })}
          </ul>
        </div>
      )}
    </>
  );
}
