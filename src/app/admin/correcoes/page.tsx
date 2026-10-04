import Link from "next/link";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { exigirStaff } from "@/lib/contexto";
import { CURSOS, SIGLA_CURSO, type Curso } from "@/lib/cursos";
import { NOME_COMPONENTE, type Componente } from "@/lib/questoes";
import { formatarDataHora } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";
import { cn } from "@/lib/utils";
import { FormularioCorrecao } from "./formulario-correcao";

export const metadata = { title: "Correções — Portal Simulado ENADE" };

type Linha = {
  id: string;
  resposta_texto: string;
  criado_em: string;
  tentativa_n: number;
  estudantes: { nome: string; curso: Curso; turma: string } | null;
  questoes: {
    enunciado: string;
    texto_apoio: string | null;
    eixo: string;
    componente: Componente;
    peso_pontos: number;
    questoes_gabarito: { justificativa: string | null } | null;
  } | null;
  sessoes: { titulo: string } | null;
  correcoes_discursivas: { nota: number; comentario: string | null; corrigida_em: string } | null;
};

export default async function CorrecoesPage({ searchParams }: PageProps<"/admin/correcoes">) {
  const { staff } = await exigirStaff();
  const sp = await searchParams;
  const aba = sp.aba === "corrigidas" ? "corrigidas" : "pendentes";
  const curso = typeof sp.curso === "string" ? sp.curso : "";
  const cursosDoPerfil = staff.cursos ?? CURSOS;

  // RLS limita às respostas dos alunos dos cursos do perfil.
  const supabase = await createClient();
  let consulta = supabase
    .from("respostas")
    .select(
      `id, resposta_texto, criado_em, tentativa_n,
       estudantes!inner(nome, curso, turma),
       questoes(enunciado, texto_apoio, eixo, componente, peso_pontos, questoes_gabarito(justificativa)),
       sessoes(titulo),
       correcoes_discursivas(nota, comentario, corrigida_em)`,
    )
    .not("resposta_texto", "is", null)
    .order("criado_em", { ascending: aba === "pendentes" })
    .limit(500);
  if (curso) consulta = consulta.eq("estudantes.curso", curso);
  const { data, error } = await consulta;

  const todas = (data ?? []) as unknown as Linha[];
  const pendentes = todas.filter((r) => !r.correcoes_discursivas);
  const lista = aba === "pendentes" ? pendentes : todas.filter((r) => r.correcoes_discursivas).slice(0, 100);
  const link = (a: string) => `/admin/correcoes?aba=${a}${curso ? `&curso=${curso}` : ""}`;

  return (
    <>
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Correção de discursivas</h1>
        <p className="text-muted-foreground">
          Nota de 0 a 100. Os pontos do aluno saem proporcionais ao peso da questão (Formação Geral com bônus).
        </p>
      </div>

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex gap-1 rounded-lg border bg-background p-1 text-sm">
          {[
            ["pendentes", `Pendentes (${pendentes.length})`],
            ["corrigidas", "Corrigidas"],
          ].map(([a, rotulo]) => (
            <Link
              key={a}
              href={link(a)}
              className={cn(
                "rounded-md px-3 py-1",
                aba === a ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:text-foreground",
              )}
            >
              {rotulo}
            </Link>
          ))}
        </div>
        {cursosDoPerfil.length > 1 && (
          <div className="flex flex-wrap gap-1 text-sm">
            {["", ...cursosDoPerfil].map((c) => (
              <Link
                key={c || "todos"}
                href={`/admin/correcoes?aba=${aba}${c ? `&curso=${c}` : ""}`}
                className={cn(
                  "rounded-md border px-2.5 py-1",
                  curso === c ? "border-primary text-foreground" : "text-muted-foreground hover:text-foreground",
                )}
              >
                {c ? SIGLA_CURSO[c as Curso] : "Todos"}
              </Link>
            ))}
          </div>
        )}
      </div>

      {error && (
        <Alert variant="destructive">
          <AlertDescription>Não foi possível carregar as respostas: {error.message}</AlertDescription>
        </Alert>
      )}

      {lista.length === 0 ? (
        <div className="rounded-xl border border-dashed bg-background p-10 text-center text-sm text-muted-foreground">
          {aba === "pendentes" ? "Nenhuma discursiva aguardando correção." : "Nenhuma correção feita ainda."}
        </div>
      ) : (
        <div className="space-y-4">
          {lista.map((r) => (
            <article key={r.id} className="space-y-4 rounded-xl border bg-background p-5">
              <header className="flex flex-wrap items-start justify-between gap-2 text-sm">
                <div>
                  <p className="font-medium">{r.estudantes?.nome}</p>
                  <p className="text-xs text-muted-foreground">
                    {r.estudantes && `${SIGLA_CURSO[r.estudantes.curso]} · ${r.estudantes.turma} · `}
                    {r.sessoes ? `Simulado “${r.sessoes.titulo}”` : "Treino Livre"} · {formatarDataHora(r.criado_em)}
                  </p>
                </div>
                {r.questoes && (
                  <p className="text-xs text-muted-foreground">
                    {NOME_COMPONENTE[r.questoes.componente]} · {r.questoes.eixo} · peso {r.questoes.peso_pontos}
                  </p>
                )}
              </header>

              {r.questoes && (
                <details className="rounded-lg bg-muted/50 p-3 text-sm">
                  <summary className="cursor-pointer font-medium">Enunciado e padrão de resposta</summary>
                  <div className="mt-2 space-y-2">
                    {r.questoes.texto_apoio && <p className="whitespace-pre-wrap">{r.questoes.texto_apoio}</p>}
                    <p className="whitespace-pre-wrap">{r.questoes.enunciado}</p>
                    {r.questoes.questoes_gabarito?.justificativa && (
                      <div className="rounded-md border bg-background p-3">
                        <p className="mb-1 font-semibold">Padrão de resposta</p>
                        <p className="whitespace-pre-wrap">{r.questoes.questoes_gabarito.justificativa}</p>
                      </div>
                    )}
                  </div>
                </details>
              )}

              <div>
                <p className="mb-1 text-sm font-medium">Resposta do aluno</p>
                <p className="whitespace-pre-wrap rounded-lg border p-3 text-[15px] leading-relaxed">
                  {r.resposta_texto}
                </p>
                {r.tentativa_n > 1 && (
                  <p className="mt-1 text-xs text-muted-foreground">
                    Tentativa {r.tentativa_n}: a nota fica registrada, mas não gera pontos (só a 1ª tentativa pontua).
                  </p>
                )}
              </div>

              <FormularioCorrecao
                respostaId={r.id}
                notaInicial={r.correcoes_discursivas?.nota ?? null}
                comentarioInicial={r.correcoes_discursivas?.comentario ?? ""}
              />
            </article>
          ))}
        </div>
      )}
    </>
  );
}
