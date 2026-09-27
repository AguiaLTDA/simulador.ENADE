import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";
import { configSupabase } from "./env";

// Rotas acessíveis sem login.
const ROTAS_PUBLICAS = ["/login", "/auth", "/termo-lgpd"];

export async function updateSession(request: NextRequest) {
  const { url, key, problema } = configSupabase();
  if (problema) {
    console.error(`Configuração: ${problema}`);
    return new NextResponse(`Erro de configuração do servidor: ${problema}.`, { status: 500 });
  }

  let response = NextResponse.next({ request });

  const supabase = createServerClient(url, key,
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
