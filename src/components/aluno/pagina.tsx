import Link from "next/link";
import { ChevronLeft } from "lucide-react";
import { cn } from "@/lib/utils";

// Moldura padrão das páginas do estudante: título, descrição e ações.
export function Pagina({
  titulo,
  descricao,
  voltar,
  acoes,
  largura = "padrao",
  children,
}: {
  titulo: React.ReactNode;
  descricao?: React.ReactNode;
  voltar?: { href: string; rotulo: string };
  acoes?: React.ReactNode;
  largura?: "estreita" | "padrao";
  children: React.ReactNode;
}) {
  return (
    <div
      className={cn(
        "mx-auto w-full space-y-6 px-4 py-6 sm:px-6 lg:px-8 lg:py-8",
        largura === "estreita" ? "max-w-3xl" : "max-w-5xl",
      )}
    >
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div className="min-w-0 space-y-1">
          {voltar && (
            <Link
              href={voltar.href}
              className="-ml-1 inline-flex items-center gap-0.5 rounded text-sm text-muted-foreground hover:text-foreground"
            >
              <ChevronLeft className="size-4" />
              {voltar.rotulo}
            </Link>
          )}
          <h1 className="text-2xl font-semibold tracking-tight">{titulo}</h1>
          {descricao && <p className="text-sm text-muted-foreground">{descricao}</p>}
        </div>
        {acoes && <div className="flex flex-wrap gap-2">{acoes}</div>}
      </div>
      {children}
    </div>
  );
}

// Cartão de indicador: ícone pequeno, número em destaque e título discreto.
export function Indicador({
  icone,
  valor,
  titulo,
  detalhe,
  tom = "verde",
}: {
  icone: React.ReactNode;
  valor: React.ReactNode;
  titulo: string;
  detalhe?: React.ReactNode;
  tom?: "verde" | "dourado" | "laranja";
}) {
  return (
    <div className="rounded-xl border bg-card p-4 shadow-[0_1px_2px_rgb(16_24_20/0.04)]">
      <div
        className={cn(
          "mb-3 flex size-8 items-center justify-center rounded-lg [&_svg]:size-4",
          tom === "verde" && "bg-verde-suave text-verde",
          tom === "dourado" && "bg-dourado-suave text-[#9a7425]",
          tom === "laranja" && "bg-[#fdeee0] text-[#b45309]",
        )}
        aria-hidden
      >
        {icone}
      </div>
      <p className="text-2xl font-semibold tabular-nums tracking-tight">{valor}</p>
      <p className="text-sm text-muted-foreground">{titulo}</p>
      {detalhe && <p className="mt-1 text-xs text-muted-foreground">{detalhe}</p>}
    </div>
  );
}

// Seção com título discreto.
export function Secao({
  titulo,
  acao,
  children,
  className,
}: {
  titulo: string;
  acao?: React.ReactNode;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <section className={cn("space-y-3", className)}>
      <div className="flex items-center justify-between gap-3">
        <h2 className="text-base font-semibold">{titulo}</h2>
        {acao}
      </div>
      {children}
    </section>
  );
}
