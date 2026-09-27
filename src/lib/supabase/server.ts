import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { configSupabase } from "./env";

// Cliente para Server Components, Server Functions e Route Handlers.
export async function createClient() {
  const cookieStore = await cookies();
  const { url, key, problema } = configSupabase();
  if (problema) throw new Error(`Configuração do Supabase: ${problema}`);

  return createServerClient(url, key,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            );
          } catch {
            // Chamado de um Server Component: não pode gravar cookies.
            // O proxy renova a sessão, então é seguro ignorar.
          }
        },
      },
    },
  );
}
