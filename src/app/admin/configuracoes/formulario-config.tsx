"use client";

import { useState, useTransition } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { salvarConfig } from "./actions";

// "pct": guardado como fração (0,25) e exibido como percentual (25).
type Campo = { chave: string; rotulo: string; ajuda: string; tipo: "int" | "dec" | "pct" };

const GRUPOS: { titulo: string; descricao: string; campos: Campo[] }[] = [
  {
    titulo: "Pontos por questão",
    descricao: "Peso padrão de cada questão objetiva, conforme a dificuldade. Cada questão pode ter peso próprio.",
    campos: [
      { chave: "pontos_facil", rotulo: "Fácil", ajuda: "pontos", tipo: "int" },
      { chave: "pontos_media", rotulo: "Média", ajuda: "pontos", tipo: "int" },
      { chave: "pontos_dificil", rotulo: "Difícil", ajuda: "pontos", tipo: "int" },
      { chave: "multiplicador_fg", rotulo: "Multiplicador da Formação Geral", ajuda: "× sobre os pontos", tipo: "dec" },
    ],
  },
  {
    titulo: "Bônus de tempo e sequência",
    descricao: "Resposta rápida e acertos seguidos rendem mais pontos.",
    campos: [
      { chave: "bonus_tempo_max", rotulo: "Bônus para resposta imediata", ajuda: "×", tipo: "dec" },
      { chave: "bonus_tempo_min", rotulo: "Bônus mínimo", ajuda: "×", tipo: "dec" },
      { chave: "limite_bonus_tempo_seg", rotulo: "Tempo até o bônus mínimo", ajuda: "segundos", tipo: "int" },
      { chave: "sequencia_incremento", rotulo: "Acréscimo por acerto seguido", ajuda: "× por acerto (0,05 = +5%)", tipo: "dec" },
      { chave: "sequencia_teto", rotulo: "Teto da sequência", ajuda: "×", tipo: "dec" },
    ],
  },
  {
    titulo: "Nota estimada do simulado",
    descricao: "Composição da nota de 0 a 100, nos moldes do ENADE. O complemento de cada peso é calculado automaticamente.",
    campos: [
      { chave: "enade_peso_fg", rotulo: "Peso da Formação Geral", ajuda: "% (Específico = restante)", tipo: "pct" },
      { chave: "enade_fg_peso_objetivas", rotulo: "Objetivas dentro da FG", ajuda: "% (discursivas = restante)", tipo: "pct" },
      { chave: "enade_ce_peso_objetivas", rotulo: "Objetivas dentro do Específico", ajuda: "% (discursivas = restante)", tipo: "pct" },
    ],
  },
  {
    titulo: "Diagnóstico inicial",
    descricao: "Pontos por concluir e cortes de nível por área.",
    campos: [
      { chave: "pontos_diagnostico", rotulo: "Pontos por concluir", ajuda: "pontos", tipo: "int" },
      { chave: "diagnostico_corte_intermediario", rotulo: "Corte do nível Intermediário", ajuda: "% de acertos", tipo: "dec" },
      { chave: "diagnostico_corte_avancado", rotulo: "Corte do nível Avançado", ajuda: "% de acertos", tipo: "dec" },
    ],
  },
];

const CAMPOS = GRUPOS.flatMap((g) => g.campos);
const exibir = (c: Campo, v: number) =>
  String(c.tipo === "pct" ? Math.round(v * 10000) / 100 : v).replace(".", ",");
const ler = (c: Campo, s: string) => {
  const n = Number(s.replace(",", ".").trim());
  return c.tipo === "pct" ? n / 100 : n;
};

export function FormularioConfig({ valores }: { valores: Record<string, number> }) {
  const [form, setForm] = useState(() =>
    Object.fromEntries(CAMPOS.map((c) => [c.chave, exibir(c, valores[c.chave] ?? 0)])),
  );
  const [atualizarQuestoes, setAtualizarQuestoes] = useState(true);
  const [msg, setMsg] = useState<{ erro?: string; ok?: string }>({});
  const [pendente, iniciar] = useTransition();

  const alterados = CAMPOS.filter((c) => {
    const n = ler(c, form[c.chave]);
    return Number.isFinite(n) && Math.abs(n - (valores[c.chave] ?? 0)) > 1e-9;
  });
  const invalidos = CAMPOS.filter((c) => form[c.chave].trim() === "" || !Number.isFinite(ler(c, form[c.chave])));
  const mexeuNosPesos = alterados.some((c) => c.chave.startsWith("pontos_") && c.chave !== "pontos_diagnostico");

  function salvar() {
    setMsg({});
    iniciar(async () => {
      const r = await salvarConfig(
        Object.fromEntries(alterados.map((c) => [c.chave, ler(c, form[c.chave])])),
        atualizarQuestoes,
      );
      if (r.erro) return setMsg({ erro: r.erro });
      setMsg({
        ok: `${r.alteradas} configuração(ões) salva(s).${
          r.questoes_atualizadas ? ` ${r.questoes_atualizadas} questão(ões) passaram ao novo peso padrão.` : ""
        }`,
      });
    });
  }

  return (
    <div className="space-y-4">
      <div className="grid gap-4 lg:grid-cols-2">
        {GRUPOS.map((g) => (
          <Card key={g.titulo}>
            <CardHeader>
              <CardTitle>{g.titulo}</CardTitle>
              <CardDescription>{g.descricao}</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-3 sm:grid-cols-2">
              {g.campos.map((c) => (
                <div key={c.chave} className="space-y-1">
                  <Label htmlFor={c.chave}>{c.rotulo}</Label>
                  <Input
                    id={c.chave}
                    inputMode="decimal"
                    value={form[c.chave]}
                    onChange={(e) => setForm((f) => ({ ...f, [c.chave]: e.target.value }))}
                    aria-invalid={invalidos.includes(c)}
                  />
                  <p className="text-xs text-muted-foreground">{c.ajuda}</p>
                </div>
              ))}
            </CardContent>
          </Card>
        ))}
      </div>

      {mexeuNosPesos && (
        <label className="flex items-start gap-2 rounded-lg border bg-background p-3 text-sm">
          <input
            type="checkbox"
            className="mt-0.5"
            checked={atualizarQuestoes}
            onChange={(e) => setAtualizarQuestoes(e.target.checked)}
          />
          <span>
            Aplicar o novo peso às questões que estão com o peso padrão antigo.
            <span className="block text-xs text-muted-foreground">
              Questões com peso personalizado não mudam. Pontos já ganhos pelos alunos não são recalculados.
            </span>
          </span>
        </label>
      )}

      {(msg.erro || msg.ok) && (
        <Alert variant={msg.erro ? "destructive" : "default"}>
          <AlertDescription>{msg.erro ?? msg.ok}</AlertDescription>
        </Alert>
      )}

      <div className="flex justify-end">
        <Button onClick={salvar} disabled={pendente || !alterados.length || invalidos.length > 0}>
          {pendente ? "Salvando..." : alterados.length ? `Salvar ${alterados.length} alteração(ões)` : "Nada alterado"}
        </Button>
      </div>
    </div>
  );
}
