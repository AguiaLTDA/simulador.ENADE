import Link from "next/link";
import { notFound } from "next/navigation";
import { buttonVariants } from "@/components/ui/button";
import { exigirGestor } from "@/lib/contexto";
import { CURSOS, type Curso } from "@/lib/cursos";
import { paraCampoLocal } from "@/lib/simulados";
import { createClient } from "@/lib/supabase/server";
import { carregarBanco } from "../dados";
import { FormularioSimulado } from "../formulario-simulado";

export const metadata = { title: "Editar simulado — Portal Simulado ENADE" };

export default async function EditarSimuladoPage({ params }: PageProps<"/admin/simulados/[id]">) {
  const { staff } = await exigirGestor();
  const { id } = await params;
  if (!/^[0-9a-f-]{36}$/i.test(id)) notFound();

  const supabase = await createClient();
  const [{ data: s }, { count }] = await Promise.all([
    supabase.from("sessoes").select("*").eq("id", id).eq("tipo", "SIMULADO").maybeSingle(),
    supabase.from("sessoes_participacao").select("*", { count: "exact", head: true }).eq("sessao_id", id),
  ]);
  if (!s) notFound();
  // Coordenador vê simulados abertos a todos os cursos, mas só o ADMIN os edita.
  if (staff.papel !== "ADMIN" && (!s.curso || !staff.cursos?.includes(s.curso))) notFound();

  const banco = await carregarBanco(s.questoes as string[]);
  const cursos = staff.cursos ?? CURSOS;

  return (
    <>
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <Link href="/admin/simulados" className="text-sm text-muted-foreground hover:text-foreground">
            ← Simulados
          </Link>
          <h1 className="mt-1 text-2xl font-semibold tracking-tight">{s.titulo}</h1>
        </div>
        {s.publicada && (
          <Link href={`/admin/simulados/${id}/relatorio`} className={buttonVariants({ variant: "outline" })}>
            Ver relatório
          </Link>
        )}
      </div>
      <FormularioSimulado
        inicial={{
          id: s.id,
          titulo: s.titulo,
          curso: (s.curso as Curso | null) ?? "",
          inicio: paraCampoLocal(s.inicio),
          fim: paraCampoLocal(s.fim),
          duracao_minutos: String(s.duracao_minutos),
          questoes: s.questoes as string[],
          publicada: s.publicada,
        }}
        cursos={cursos}
        podeTodos={staff.papel === "ADMIN"}
        banco={banco}
        participantes={count ?? 0}
      />
    </>
  );
}
