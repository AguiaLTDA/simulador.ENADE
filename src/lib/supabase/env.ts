// Lê a configuração do Supabase no servidor em tempo de execução.
// O acesso por chave dinâmica evita que o Next "congele" o valor no build
// (process.env.NEXT_PUBLIC_* literal é substituído na compilação).
function lerEnv(nome: string): string | undefined {
  const valor = process.env[nome];
  return valor?.trim() || undefined;
}

export function configSupabase() {
  const url = lerEnv("NEXT_PUBLIC_" + "SUPABASE_URL");
  const key = lerEnv("NEXT_PUBLIC_" + "SUPABASE_PUBLISHABLE_KEY");

  let problema: string | null = null;
  if (!url) problema = "NEXT_PUBLIC_SUPABASE_URL ausente";
  else if (!/^https:\/\/[a-z0-9]+\.supabase\.co\/?$/.test(url))
    problema = "NEXT_PUBLIC_SUPABASE_URL inválida (esperado https://<ref>.supabase.co, sem aspas)";
  else if (!key) problema = "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY ausente";
  else if (!/^sb_publishable_[A-Za-z0-9_-]+$/.test(key))
    problema = "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY inválida (esperado sb_publishable_..., sem aspas)";

  if (problema) {
    // Só NOMES (nunca valores), para diagnosticar nome digitado errado.
    const nomes = Object.keys(process.env).filter((k) => /supa/i.test(k));
    problema += `. Variáveis com "SUPA" no nome visíveis no servidor: ${
      nomes.length ? nomes.map((n) => JSON.stringify(n)).join(", ") : "nenhuma"
    }`;
  }

  return { url: url?.replace(/\/$/, "") ?? "", key: key ?? "", problema };
}
