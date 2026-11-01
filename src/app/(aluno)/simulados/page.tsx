import Link from "next/link";
import { CalendarClock, CheckCircle2, CircleSlash, Clock, PlayCircle } from "lucide-react";
import { Pagina, Secao } from "@/components/aluno/pagina";
import { buttonVariants } from "@/components/ui/button";
import {
  NOME_SITUACAO,
  formatarDataHora,
  formatarDuracao,
  type SimuladoAluno,
  type SituacaoSimulado,
} from "@/lib/simulados";
import { cn } from "@/lib/utils";
import { carregarSimuladosDoAluno } from "./dados";

export const metadata = { title: "Simulados — Simulado ENADE UNIVC" };

// Situação com ícone + texto (nunca só cor).
const SELO: Record<SituacaoSimulado, { icone: typeof Clock; classe: string }> = {
  DISPONIVEL: { icone: PlayCircle, classe: "bg-verde-suave text-verde-profundo" },
  EM_ANDAMENTO: { icone: Clock, classe: "bg-[#fdeee0] text-[#9a4a0b]" },
  AGENDADO: { icone: CalendarClock, classe: "bg-muted text-muted-foreground" },
  CONCLUIDO: { icone: CheckCircle2, classe: "bg-muted text-foreground/80" },
  PERDIDO: { icone: CircleSlash, classe: "bg-muted text-muted-foreground" },
};

function Acao({ s }: { s: SimuladoAluno }) {
  switch (s.situacao) {
    case "DISPONIVEL":
      return (
        <Link href={`/simulados/${s.id}`} className={buttonVariants({ variant: "acao", size: "lg" })}>
          Fazer simulado
        </Link>
      );
    case "EM_ANDAMENTO":
      return (
        <Link href={`/simulados/${s.id}`} className={buttonVariants({ variant: "acao", size: "lg" })}>
          Continuar
        </Link>
      );
    case "CONCLUIDO":
      return (
        <Link href={`/simulados/${s.id}/resultado`} className={buttonVariants({ variant: "outline", size: "lg" })}>
          Ver resultado
        </Link>
      );
    default:
      return null;
  }
}

function Lista({ itens }: { itens: SimuladoAluno[] }) {
  return (
    <ul className="grid gap-3">
      {itens.map((s) => {
        const selo = SELO[s.situacao];
        const Icone = selo.icone;
        return (
          <li
            key={s.id}
            className="flex flex-wrap items-center justify-between gap-4 rounded-xl border bg-card p-4 shadow-[0_1px_2px_rgb(16_24_20/0.04)]"
          >
            <div className="min-w-0 space-y-1">
              <div className="flex flex-wrap items-center gap-2">
                <p className="font-medium">{s.titulo}</p>
                <span className={cn("inline-flex items-center gap-1 rounded-md px-1.5 py-0.5 text-[11px] font-medium", selo.classe)}>
                  <Icone className="size-3" />
                  {NOME_SITUACAO[s.situacao]}
                </span>
              </div>
              <p className="text-sm text-muted-foreground">
                {s.total_questoes} questões · {formatarDuracao(s.duracao_minutos)} · {formatarDataHora(s.inicio)} a{" "}
                {formatarDataHora(s.fim)}
              </p>
              {s.nova_tentativa && s.situacao === "DISPONIVEL" && (
                <p className="text-xs font-medium text-verde">A coordenação liberou uma nova tentativa para você.</p>
              )}
              {s.situacao === "CONCLUIDO" && !s.gabarito_liberado && (
                <p className="text-xs text-muted-foreground">
                  Gabarito e correção em {formatarDataHora(s.fim)}, quando o simulado fecha para todos.
                </p>
              )}
            </div>
            <Acao s={s} />
          </li>
        );
      })}
    </ul>
  );
}

export default async function SimuladosPage() {
  const { simulados } = await carregarSimuladosDoAluno();
  const abertos = simulados.filter((s) => ["DISPONIVEL", "EM_ANDAMENTO", "AGENDADO"].includes(s.situacao));
  const anteriores = simulados.filter((s) => !abertos.includes(s));

  return (
    <Pagina titulo="Simulados" descricao="Provas cronometradas no formato do ENADE, montadas pela coordenação do seu curso.">
      <Secao titulo="Abertos e agendados">
        {abertos.length ? (
          <Lista itens={abertos} />
        ) : (
          <div className="rounded-xl border border-dashed bg-card p-8 text-center text-sm text-muted-foreground">
            Nenhum simulado aberto no momento. A coordenação avisa quando houver um novo.
          </div>
        )}
      </Secao>
      {anteriores.length > 0 && (
        <Secao titulo="Anteriores">
          <Lista itens={anteriores} />
        </Secao>
      )}
    </Pagina>
  );
}
