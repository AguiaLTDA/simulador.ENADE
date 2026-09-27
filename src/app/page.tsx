import { redirect } from "next/navigation";
import { destinoInicial, obterContexto } from "@/lib/contexto";

export default async function Home() {
  redirect(destinoInicial(await obterContexto()));
}
