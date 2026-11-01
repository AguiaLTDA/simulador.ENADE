import { carregarDesempenho } from "@/lib/desempenho";
import { ConteudoConquistas } from "./conteudo";

export const metadata = { title: "Conquistas — Simulado ENADE UNIVC" };

export default async function ConquistasPage() {
  return <ConteudoConquistas dados={await carregarDesempenho()} />;
}
