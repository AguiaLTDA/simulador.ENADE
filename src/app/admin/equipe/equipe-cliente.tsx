"use client";

import { useRouter } from "next/navigation";
import { useState, useTransition } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { NativeSelect } from "@/components/ui/native-select";
import { CURSOS, NOME_CURSO, descreverPerfil, type Curso, type Papel } from "@/lib/cursos";
import { definirMembro, removerMembro, type EstadoEquipe } from "./actions";

export type Membro = {
  email: string;
  nome: string;
  papel: Papel;
  cursos: Curso[] | null;
  situacao: "ATIVO" | "CONVIDADO";
};

// Perfis prontos pedidos pela instituição.
const PERFIS: { id: string; rotulo: string; papel: Papel; cursos: Curso[]; nome: string }[] = [
  { id: "vet", rotulo: "Coordenação — Medicina Veterinária", papel: "COORDENADOR", cursos: ["VET"],
    nome: "Coordenação de Medicina Veterinária" },
  { id: "arq", rotulo: "Coordenação — Arquitetura e Urbanismo", papel: "COORDENADOR", cursos: ["ARQ"],
    nome: "Coordenação de Arquitetura e Urbanismo" },
  { id: "eng", rotulo: "Coordenação — Eng. Mecânica, Eng. de Produção e ADS", papel: "COORDENADOR",
    cursos: ["ENG_MEC", "ENG_PROD", "ADS"], nome: "Coordenação de Engenharias e ADS" },
  { id: "admin", rotulo: "Administração geral (todos os cursos)", papel: "ADMIN", cursos: [], nome: "" },
  { id: "custom", rotulo: "Outro (escolher perfil e cursos)", papel: "DOCENTE", cursos: [], nome: "" },
];

export function EquipeCliente({ membros, meuEmail }: { membros: Membro[]; meuEmail: string }) {
  const router = useRouter();
  const [pendente, iniciar] = useTransition();
  const [aviso, setAviso] = useState<EstadoEquipe>({});
  const [perfil, setPerfil] = useState(PERFIS[0].id);
  const [email, setEmail] = useState("");
  const [nome, setNome] = useState(PERFIS[0].nome);
  const [papel, setPapel] = useState<Papel>("DOCENTE");
  const [cursos, setCursos] = useState<Curso[]>([]);

  const escolhido = PERFIS.find((p) => p.id === perfil)!;
  const personalizado = perfil === "custom";

  function trocarPerfil(id: string) {
    setPerfil(id);
    const p = PERFIS.find((x) => x.id === id)!;
    if (p.nome) setNome(p.nome);
  }

  function salvar(e: React.FormEvent) {
    e.preventDefault();
    iniciar(async () => {
      const r = await definirMembro({
        email,
        nome,
        papel: personalizado ? papel : escolhido.papel,
        cursos: personalizado ? cursos : escolhido.cursos,
      });
      setAviso(r);
      if (r.ok) {
        setEmail("");
        router.refresh();
      }
    });
  }

  function remover(m: Membro) {
    if (!window.confirm(`Remover o acesso de ${m.nome} (${m.email})?`)) return;
    iniciar(async () => {
      setAviso(await removerMembro(m.email));
      router.refresh();
    });
  }

  return (
    <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_minmax(0,24rem)]">
      <div className="space-y-3">
        {aviso.erro && (
          <Alert variant="destructive">
            <AlertDescription>{aviso.erro}</AlertDescription>
          </Alert>
        )}
        {aviso.ok && (
          <Alert>
            <AlertDescription>{aviso.ok}</AlertDescription>
          </Alert>
        )}
        <div className="divide-y rounded-xl border bg-background">
          {membros.map((m) => (
            <div key={m.email} className="flex flex-wrap items-center gap-3 p-4">
              <div className="min-w-0 flex-1">
                <p className="font-medium">{m.nome}</p>
                <p className="truncate text-sm text-muted-foreground">{m.email}</p>
                <p className="text-sm">{descreverPerfil(m.papel, m.cursos)}</p>
              </div>
              <Badge variant={m.situacao === "ATIVO" ? "default" : "secondary"}>
                {m.situacao === "ATIVO" ? "Ativo" : "Aguardando 1º acesso"}
              </Badge>
              {m.email !== meuEmail && (
                <Button variant="ghost" size="sm" onClick={() => remover(m)} disabled={pendente}>
                  Remover
                </Button>
              )}
            </div>
          ))}
        </div>
      </div>

      <Card className="lg:self-start">
        <CardHeader>
          <CardTitle>Adicionar à equipe</CardTitle>
          <CardDescription>
            A pessoa entra pelo link de acesso enviado ao e-mail. Não use um e-mail já cadastrado
            como aluno.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={salvar} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="perfil">Perfil</Label>
              <NativeSelect id="perfil" value={perfil} onChange={(e) => trocarPerfil(e.target.value)}>
                {PERFIS.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.rotulo}
                  </option>
                ))}
              </NativeSelect>
            </div>

            {personalizado && (
              <>
                <div className="space-y-2">
                  <Label htmlFor="papel">Papel</Label>
                  <NativeSelect id="papel" value={papel} onChange={(e) => setPapel(e.target.value as Papel)}>
                    <option value="COORDENADOR">Coordenador (gere questões e alunos)</option>
                    <option value="DOCENTE">Docente (corrige discursivas)</option>
                  </NativeSelect>
                </div>
                <fieldset className="space-y-2">
                  <legend className="text-sm font-medium">Cursos</legend>
                  {CURSOS.map((c) => (
                    <label key={c} className="flex items-center gap-2 text-sm">
                      <input
                        type="checkbox"
                        className="size-4 accent-primary"
                        checked={cursos.includes(c)}
                        onChange={() =>
                          setCursos((x) => (x.includes(c) ? x.filter((y) => y !== c) : [...x, c]))
                        }
                      />
                      {NOME_CURSO[c]}
                    </label>
                  ))}
                </fieldset>
              </>
            )}

            <div className="space-y-2">
              <Label htmlFor="nome-membro">Nome exibido</Label>
              <Input id="nome-membro" value={nome} onChange={(e) => setNome(e.target.value)} required />
            </div>
            <div className="space-y-2">
              <Label htmlFor="email-membro">E-mail</Label>
              <Input
                id="email-membro"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="coordenacao@univc.edu.br"
                required
              />
            </div>
            <Button type="submit" className="w-full" disabled={pendente}>
              {pendente ? "Salvando..." : "Salvar perfil"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
