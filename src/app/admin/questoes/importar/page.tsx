import Link from "next/link";
import { exigirGestor } from "@/lib/contexto";
import { CURSOS, SIGLA_CURSO } from "@/lib/cursos";
import { ImportarCliente } from "./importar-cliente";

export const metadata = { title: "Importar questões — Portal Simulado ENADE" };

export default async function ImportarQuestoesPage() {
  const { staff } = await exigirGestor();
  const cursos = staff.cursos ?? CURSOS;

  return (
    <>
      <div>
        <Link href="/admin/questoes" className="text-sm text-muted-foreground hover:text-foreground">
          ← Banco de questões
        </Link>
        <h1 className="mt-1 text-2xl font-semibold tracking-tight">Importar questões por planilha</h1>
        <p className="text-muted-foreground">
          Até 500 questões por arquivo. Primeiro o sistema confere cada linha; nada é gravado até você confirmar.
        </p>
      </div>

      <div className="space-y-2 rounded-xl border bg-background p-5 text-sm">
        <p className="font-medium">Como preencher</p>
        <ol className="list-decimal space-y-1 pl-5 text-muted-foreground">
          <li>Baixe o modelo, abra no Excel (ou Google Planilhas) e preencha uma questão por linha.</li>
          <li>
            <strong>componente</strong>: FG (Formação Geral) ou CE (Componente Específico).{" "}
            <strong>cursos</strong>: só para CE, separados por vírgula —{" "}
            {cursos.map((c) => `${c} (${SIGLA_CURSO[c]})`).join(", ")}.
          </li>
          <li>
            <strong>formato</strong>: OBJETIVA ou DISCURSIVA. <strong>dificuldade</strong>: 1, 2 ou 3.{" "}
            <strong>gabarito</strong>: letra A–E (objetivas). <strong>justificativa</strong>: explicação do gabarito
            ou padrão de resposta da discursiva.
          </li>
          <li>
            <strong>peso</strong>: deixe vazio para usar o padrão da dificuldade. <strong>situacao</strong>: RASCUNHO
            (padrão) ou PUBLICADA.
          </li>
          <li>No Excel, salve como “CSV UTF-8 (separado por vírgulas)” ou “CSV (separado por ponto e vírgula)”.</li>
        </ol>
      </div>

      <ImportarCliente />
    </>
  );
}
