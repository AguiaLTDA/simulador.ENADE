import { cn } from "@/lib/utils";

// Figura de uma questão (gráfico, diagrama, tabela). O caminho é relativo a /public.
export function FiguraQuestao({
  caminho,
  descricao,
  className,
}: {
  caminho: string | null | undefined;
  descricao: string;
  className?: string;
}) {
  if (!caminho) return null;
  const src = `/${caminho.replace(/^\/+/, "")}`;
  return (
    <a href={src} target="_blank" rel="noopener" className={cn("my-4 block", className)} title="Abrir em tamanho real">
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img src={src} alt={descricao} loading="lazy" className="mx-auto h-auto max-w-full rounded border bg-white" />
    </a>
  );
}
