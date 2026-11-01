import Link from "next/link";
import { cn } from "@/lib/utils";

// Logomarca oficial: salve o arquivo em public/marca/ e informe o caminho aqui
// (ex.: "/marca/univc.svg"). Enquanto estiver vazio, usa a marca em texto.
const LOGO_OFICIAL: string | null = null;

function LogoUnivc({ className }: { className?: string }) {
  if (LOGO_OFICIAL) {
    // eslint-disable-next-line @next/next/no-img-element
    return <img src={LOGO_OFICIAL} alt="UNIVC" className={cn("h-7 w-auto", className)} />;
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
      <LogoUnivc className="text-3xl" />
      <div>
        <h1 className="text-xl font-semibold tracking-tight">Simulado ENADE</h1>
        <p className="text-xs text-muted-foreground">Centro Universitário Vale do Cricaré</p>
      </div>
    </div>
  );
}
