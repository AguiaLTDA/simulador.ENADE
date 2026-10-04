import Link from "next/link";
import { exigirGestor } from "@/lib/contexto";
import { CURSOS } from "@/lib/cursos";
import { DURACAO_ENADE_MIN, paraCampoLocal } from "@/lib/simulados";
import { carregarBanco } from "../dados";
import { FormularioSimulado } from "../formulario-simulado";

export const metadata = { title: "Novo simulado — Portal Simulado ENADE" };

export default async function NovoSimuladoPage() {
  const { staff } = await exigirGestor();
  const cursos = staff.cursos ?? CURSOS;
  const banco = await carregarBanco();

  // Sugestão: abre na próxima hora cheia e fica aberto por 7 dias.
  const inicio = new Date();
  inicio.setMinutes(60, 0, 0);
  const fim = new Date(inicio.getTime() + 7 * 24 * 60 * 60 * 1000);

  return (
    <>
      <div>
        <Link href="/admin/simulados" className="text-sm text-muted-foreground hover:text-foreground">
          ← Simulados
        </Link>
        <h1 className="mt-1 text-2xl font-semibold tracking-tight">Novo simulado</h1>
      </div>
      <FormularioSimulado
        inicial={{
          titulo: "",
          curso: cursos[0],
          inicio: paraCampoLocal(inicio.toISOString()),
          fim: paraCampoLocal(fim.toISOString()),
          duracao_minutos: String(DURACAO_ENADE_MIN),
          questoes: [],
          publicada: false,
        }}
        cursos={cursos}
        podeTodos={staff.papel === "ADMIN"}
        banco={banco}
        participantes={0}
      />
    </>
  );
}
