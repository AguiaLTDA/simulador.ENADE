"use client";

import { useRouter } from "next/navigation";
import { useState, useTransition } from "react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { importarQuestoes } from "./actions";
import { interpretarPlanilha, modeloCsv, type LinhaImportacao } from "./planilha";

function baixarModelo() {
  const blob = new Blob([modeloCsv()], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "modelo-questoes-enade.csv";
  a.click();
  URL.revokeObjectURL(url);
}

// Excel em português às vezes salva em Windows-1252; tenta UTF-8 primeiro.
async function lerArquivo(f: File): Promise<string> {
  const bytes = await f.arrayBuffer();
  const utf8 = new TextDecoder("utf-8").decode(bytes);
  return utf8.includes("�") ? new TextDecoder("windows-1252").decode(bytes) : utf8;
}

export function ImportarCliente() {
  const router = useRouter();
  const [arquivo, setArquivo] = useState<string | null>(null);
  const [linhas, setLinhas] = useState<LinhaImportacao[]>([]);
  const [errosBanco, setErrosBanco] = useState<Record<number, string>>({});
  const [conferido, setConferido] = useState(false);
  const [erro, setErro] = useState<string | null>(null);
  const [pendente, iniciar] = useTransition();

  const comErroLocal = linhas.filter((l) => l.erros.length);
  const totalErros = comErroLocal.length + Object.keys(errosBanco).length;
  const podeImportar = conferido && linhas.length > 0 && totalErros === 0;

  async function escolher(e: React.ChangeEvent<HTMLInputElement>) {
    const f = e.target.files?.[0];
    setErro(null);
    setErrosBanco({});
    setConferido(false);
    setLinhas([]);
    if (!f) return setArquivo(null);
    setArquivo(f.name);
    if (!/\.(csv|txt)$/i.test(f.name)) {
      return setErro("Envie o arquivo em CSV (no Excel: Arquivo › Salvar como › CSV).");
    }
    const r = interpretarPlanilha(await lerArquivo(f));
    if (r.erroGeral) return setErro(r.erroGeral);
    if (r.linhas.length > 500) return setErro(`O arquivo tem ${r.linhas.length} questões; o limite é 500 por vez.`);
    setLinhas(r.linhas);
  }

  function conferir() {
    setErro(null);
    iniciar(async () => {
      const validas = linhas.filter((l) => !l.erros.length).map((l) => l.dados);
      if (!validas.length) return setErro("Corrija os erros apontados na planilha e envie de novo.");
      const r = await importarQuestoes(validas, true);
      if (r.erro) return setErro(r.erro);
      setErrosBanco(Object.fromEntries((r.erros ?? []).map((x) => [x.linha, x.erro])));
      setConferido(true);
    });
  }

  function importar() {
    setErro(null);
    iniciar(async () => {
      const r = await importarQuestoes(linhas.map((l) => l.dados), false);
      if (r.erro) return setErro(r.erro);
      router.push(`/admin/questoes?importadas=${r.validas ?? 0}`);
    });
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center gap-3 rounded-xl border bg-background p-4">
        <Button variant="outline" onClick={baixarModelo}>
          Baixar modelo (CSV)
        </Button>
        <Input type="file" accept=".csv,text/csv,.txt" onChange={escolher} className="max-w-sm" />
        {arquivo && <span className="text-sm text-muted-foreground">{arquivo}</span>}
      </div>

      {erro && (
        <Alert variant="destructive">
          <AlertDescription>{erro}</AlertDescription>
        </Alert>
      )}

      {linhas.length > 0 && (
        <>
          <div className="flex flex-wrap items-center justify-between gap-3">
            <p className="text-sm">
              {linhas.length} questão(ões) no arquivo
              {totalErros > 0 && <span className="text-destructive"> · {totalErros} com erro</span>}
              {podeImportar && <span className="text-emerald-700 dark:text-emerald-400"> · todas conferidas</span>}
            </p>
            <div className="flex gap-2">
              <Button variant="outline" onClick={conferir} disabled={pendente}>
                {pendente && !conferido ? "Conferindo..." : "Conferir"}
              </Button>
              <Button onClick={importar} disabled={!podeImportar || pendente}>
                {pendente && conferido ? "Importando..." : `Importar ${linhas.length} questão(ões)`}
              </Button>
            </div>
          </div>
          {!conferido && (
            <p className="text-xs text-muted-foreground">
              Clique em “Conferir” para validar cada linha com as regras do banco antes de importar.
            </p>
          )}

          <div className="overflow-x-auto rounded-xl border bg-background">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-14">Linha</TableHead>
                  <TableHead>Questão</TableHead>
                  <TableHead>Gabarito</TableHead>
                  <TableHead>Situação</TableHead>
                  <TableHead>Conferência</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {linhas.map((l) => {
                  const problemas = [...l.erros, ...(errosBanco[l.linha] ? [errosBanco[l.linha]] : [])];
                  return (
                    <TableRow key={l.linha} className={problemas.length ? "bg-destructive/5" : undefined}>
                      <TableCell className="tabular-nums">{l.linha}</TableCell>
                      <TableCell className="max-w-md whitespace-normal">
                        <span className="block text-xs text-muted-foreground">
                          {l.dados.componente} · {l.dados.cursos.join(", ") || (l.dados.componente === "FG" ? "todos" : "—")}{" "}
                          · {l.dados.eixo || "sem eixo"} · {l.dados.formato.toLowerCase()} · dif. {l.dados.dificuldade}
                        </span>
                        <span className="line-clamp-2">{l.dados.enunciado || <em>sem enunciado</em>}</span>
                      </TableCell>
                      <TableCell className="text-center font-semibold">
                        {l.dados.formato === "DISCURSIVA" ? "—" : l.dados.gabarito || "?"}
                      </TableCell>
                      <TableCell>
                        <Badge variant={l.dados.status === "PUBLICADA" ? "default" : "secondary"}>
                          {l.dados.status === "PUBLICADA" ? "Publicada" : "Rascunho"}
                        </Badge>
                      </TableCell>
                      <TableCell className="whitespace-normal text-sm">
                        {problemas.length ? (
                          <span className="text-destructive">{problemas.join("; ")}</span>
                        ) : conferido ? (
                          <span className="text-emerald-700 dark:text-emerald-400">OK</span>
                        ) : (
                          <span className="text-muted-foreground">—</span>
                        )}
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </div>
        </>
      )}
    </div>
  );
}
