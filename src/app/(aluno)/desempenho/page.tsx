import { carregarDesempenho } from "@/lib/desempenho";
import { ConteudoDesempenho } from "./conteudo";

export const metadata = { title: "Meu desempenho — Simulado ENADE UNIVC" };

export default async function DesempenhoPage() {
  return <ConteudoDesempenho dados={await carregarDesempenho()} />;
}
