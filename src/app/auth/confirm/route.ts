import type { EmailOtpType } from "@supabase/supabase-js";
import { NextResponse, type NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";

// Destino do link enviado em "Primeiro acesso ou esqueci minha senha".
// Depois de validar o link, o usuário é levado a criar/redefinir a senha.
// - token_hash: template de e-mail customizado (funciona mesmo abrindo o link em
//   outro aparelho, ex.: pediu no computador e abriu no celular).
// - code: fluxo PKCE padrão (só funciona no mesmo navegador que pediu o link).
export async function GET(request: NextRequest) {
  const { searchParams, origin } = request.nextUrl;
  const tokenHash = searchParams.get("token_hash");
  const type = searchParams.get("type") as EmailOtpType | null;
  const code = searchParams.get("code");

  const supabase = await createClient();

  if (tokenHash && type) {
    const { error } = await supabase.auth.verifyOtp({ type, token_hash: tokenHash });
    if (!error) return NextResponse.redirect(`${origin}/definir-senha`);
  } else if (code) {
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) return NextResponse.redirect(`${origin}/definir-senha`);
  }

  return NextResponse.redirect(`${origin}/login?erro=link`);
}
