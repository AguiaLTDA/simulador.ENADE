import { obterContexto } from "@/lib/contexto";
import { carregarDesempenho } from "@/lib/desempenho";
import { ConteudoInicio } from "./conteudo";

export const metadata = { title: "Início — Simulado ENADE UNIVC" };

export default async function InicioPage() {
  const ctx = await obterContexto();
  return <ConteudoInicio estudante={ctx.estudante!} dados={await carregarDesempenho()} />;
}
