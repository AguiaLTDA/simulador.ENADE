import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

// Rotas acessíveis sem login.
const ROTAS_PUBLICAS = ["/login", "/auth", "/termo-lgpd"];

// Aponta a variável mal configurada em vez de um 500 genérico.
function problemaDeConfiguracao(): string | null {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY;
  if (!url) return "NEXT_PUBLIC_SUPABASE_URL ausente";
  if (!/^https:\/\/[a-z0-9]+\.supabase\.co$/.test(url)) {
    return "NEXT_PUBLIC_SUPABASE_URL inválida (esperado https://<ref>.supabase.co, sem aspas, espaços ou barra final)";
  }
  if (!key) return "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY ausente";
  if (!/^sb_publishable_[A-Za-z0-9_-]+$/.test(key)) {
    return "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY inválida (esperado sb_publishable_..., sem aspas ou espaços)";
  }
  return null;
}

export async function updateSession(request: NextRequest) {
  const problema = problemaDeConfiguracao();
  if (problema) {
    console.error(`Configuração: ${problema}`);
    return new NextResponse(`Erro de configuração do servidor: ${problema}.`, { status: 500 });
  }

  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet, headers) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options),
          );
          Object.entries(headers).forEach(([key, value]) => response.headers.set(key, value));
        },
      },
    },
  );

  // Não coloque código entre createServerClient e getClaims: getClaims valida o
  // JWT e renova a sessão quando necessário.
  const { data } = await supabase.auth.getClaims();
  const logado = Boolean(data?.claims?.sub);

  const { pathname } = request.nextUrl;
  const publica = ROTAS_PUBLICAS.some((r) => pathname === r || pathname.startsWith(`${r}/`));

  if (!logado && !publica) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    url.search = "";
    return NextResponse.redirect(url);
  }

  return response;
}
