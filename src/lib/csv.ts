// CSV simples (RFC 4180) — aceita ";" (Excel em português), "," ou tabulação,
// aspas, quebras de linha dentro de campos e BOM.

function detectarSeparador(texto: string): string {
  const primeira = texto.split(/\r?\n/, 1)[0] ?? "";
  const contagem = [";", ",", "\t"].map((s) => [s, primeira.split(s).length] as const);
  return contagem.sort((a, b) => b[1] - a[1])[0][0];
}

export function lerCsv(texto: string): string[][] {
  const t = texto.replace(/^﻿/, "");
  const sep = detectarSeparador(t);
  const linhas: string[][] = [];
  let linha: string[] = [];
  let campo = "";
  let aspas = false;

  for (let i = 0; i < t.length; i++) {
    const c = t[i];
    if (aspas) {
      if (c === '"' && t[i + 1] === '"') {
        campo += '"';
        i++;
      } else if (c === '"') {
        aspas = false;
      } else {
        campo += c;
      }
    } else if (c === '"' && campo === "") {
      aspas = true;
    } else if (c === sep) {
      linha.push(campo);
      campo = "";
    } else if (c === "\n" || c === "\r") {
      if (c === "\r" && t[i + 1] === "\n") i++;
      linha.push(campo);
      linhas.push(linha);
      linha = [];
      campo = "";
    } else {
      campo += c;
    }
  }
  if (campo !== "" || linha.length) {
    linha.push(campo);
    linhas.push(linha);
  }
  return linhas.filter((l) => l.some((v) => v.trim() !== ""));
}

export function escreverCsv(linhas: string[][]): string {
  const campo = (v: string) => (/[;"\r\n]/.test(v) ? `"${v.replace(/"/g, '""')}"` : v);
  return "﻿" + linhas.map((l) => l.map(campo).join(";")).join("\r\n");
}

// "Alternativa A" → "alternativa_a"
export const normalizarChave = (v: string) =>
  v
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_|_$/g, "");
