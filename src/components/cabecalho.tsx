import Link from "next/link";
import { BotaoSair } from "@/components/botao-sair";

export function Cabecalho({ nome, detalhe }: { nome: string; detalhe?: string }) {
  return (
    <header className="border-b bg-background">
      <div className="mx-auto flex h-14 w-full max-w-5xl items-center justify-between gap-4 px-4">
        <Link href="/" className="font-semibold tracking-tight">
          Simulado ENADE <span className="font-normal text-muted-foreground">· UNIVC</span>
        </Link>
        <div className="flex items-center gap-3 text-sm">
          <span className="hidden text-right sm:block">
            <span className="block font-medium leading-tight">{nome}</span>
            {detalhe && <span className="block text-xs text-muted-foreground">{detalhe}</span>}
          </span>
          <BotaoSair />
        </div>
      </div>
    </header>
  );
}
