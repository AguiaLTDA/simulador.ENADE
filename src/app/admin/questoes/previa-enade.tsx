import { cn } from "@/lib/utils";
import { LETRAS, NOME_COMPONENTE, type DadosQuestao } from "@/lib/questoes";

// Pré-visualização no formato do caderno de prova do ENADE.
export function PreviaEnade({ q, mostrarGabarito }: { q: DadosQuestao; mostrarGabarito: boolean }) {
  const alternativas = [q.alt_a, q.alt_b, q.alt_c, q.alt_d, q.alt_e];

  return (
    <div className="rounded-lg border bg-white p-5 font-serif text-[15px] leading-relaxed text-neutral-900 shadow-sm">
      <div className="mb-4 flex items-center justify-between border-b border-neutral-300 pb-2 font-sans text-xs font-semibold uppercase tracking-wider text-neutral-600">
        <span>Questão {q.formato === "DISCURSIVA" ? "discursiva" : "objetiva"}</span>
        <span>{NOME_COMPONENTE[q.componente]}</span>
      </div>

      {q.texto_apoio.trim() && <p className="mb-4 whitespace-pre-wrap text-justify">{q.texto_apoio}</p>}

      <p className={cn("whitespace-pre-wrap text-justify", !q.enunciado.trim() && "italic text-neutral-400")}>
        {q.enunciado.trim() || "O enunciado aparecerá aqui."}
      </p>

      {q.formato === "OBJETIVA" ? (
        <ol className="mt-4 space-y-2">
          {LETRAS.map((letra, i) => {
            const certa = mostrarGabarito && q.gabarito === letra;
            return (
              <li
                key={letra}
                className={cn(
                  "flex gap-3 rounded px-2 py-1",
                  certa && "bg-emerald-50 ring-1 ring-emerald-600",
                )}
              >
                <span className="font-sans font-bold">{letra}</span>
                <span className={cn("whitespace-pre-wrap", !alternativas[i].trim() && "italic text-neutral-400")}>
                  {alternativas[i].trim() || "—"}
                </span>
              </li>
            );
          })}
        </ol>
      ) : (
        <div className="mt-4 space-y-2">
          {[...Array(6)].map((_, i) => (
            <div key={i} className="h-6 border-b border-dotted border-neutral-400" />
          ))}
        </div>
      )}

      {mostrarGabarito && q.justificativa.trim() && (
        <div className="mt-5 rounded border border-neutral-300 bg-neutral-50 p-3 font-sans text-sm">
          <p className="mb-1 font-semibold">
            {q.formato === "DISCURSIVA" ? "Padrão de resposta" : "Justificativa"}
          </p>
          <p className="whitespace-pre-wrap">{q.justificativa}</p>
        </div>
      )}

      {q.fonte.trim() && (
        <p className="mt-4 font-sans text-xs text-neutral-500">Fonte: {q.fonte}</p>
      )}
    </div>
  );
}
