import Link from "next/link";
import { cn } from "@/lib/utils";

// Logomarca oficial (public/marca/). Com null, usa a marca em texto.
const LOGO_OFICIAL: string | null = "/marca/univc.png";

function LogoUnivc({ className }: { className?: string }) {
  if (LOGO_OFICIAL) {
    return (
      // eslint-disable-next-line @next/next/no-img-element
      <img
        src={LOGO_OFICIAL}
        alt="UNIVC — Centro Universitário Vale do Cricaré"
        width={384}
        height={121}
        className={cn("h-8 w-auto", className)}
      />
    );
  }
  return (
    <span className={cn("text-lg font-extrabold tracking-tight text-verde", className)} aria-label="UNIVC">
      UNIVC
    </span>
  );
}

// Logo + nome da plataforma, para cabeçalhos.
export function MarcaCompacta({ href = "/", recolhida = false }: { href?: string; recolhida?: boolean }) {
  return (
    <Link href={href} className="flex items-center gap-2.5 rounded-md">
      <LogoUnivc />
      {!recolhida && (
        <>
          <span className="h-5 w-px bg-border" aria-hidden />
          <span className="text-sm font-semibold tracking-tight text-foreground">Simulado ENADE</span>
        </>
      )}
    </Link>
  );
}

// Bloco centralizado das telas de entrada (login, cadastro, senha).
export function Marca() {
  return (
    <div className="flex flex-col items-center gap-2 text-center">
      <LogoUnivc className={LOGO_OFICIAL ? "h-16" : "text-3xl"} />
      <h1 className="text-xl font-semibold tracking-tight">Simulado ENADE</h1>
    </div>
  );
}
