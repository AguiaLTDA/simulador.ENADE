import { MarcaCompacta } from "@/components/marca";
import { MenuPerfil } from "@/components/menu-perfil";
import { cn } from "@/lib/utils";

// Cabeçalho horizontal e compacto: marca à esquerda, perfil à direita.
export function Cabecalho({
  nome,
  detalhe,
  inicio,
  className,
  children,
}: {
  nome: string;
  detalhe?: string;
  inicio?: React.ReactNode; // ex.: botão do menu no celular
  className?: string;
  children?: React.ReactNode;
}) {
  return (
    <header className={cn("sticky top-0 z-30 border-b bg-background/95 backdrop-blur", className)}>
      <div className="flex h-14 w-full items-center justify-between gap-4 px-4 lg:px-6">
        <div className="flex items-center gap-2">
          {inicio}
          <MarcaCompacta />
        </div>
        <div className="flex items-center gap-2">
          {children}
          <MenuPerfil nome={nome} detalhe={detalhe} />
        </div>
      </div>
    </header>
  );
}
