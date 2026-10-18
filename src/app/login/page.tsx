import { redirect } from "next/navigation";
import { Marca } from "@/components/marca";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { createClient } from "@/lib/supabase/server";
import { FormularioLogin } from "./formulario-login";

export default async function LoginPage({ searchParams }: PageProps<"/login">) {
  const supabase = await createClient();
  const { data } = await supabase.auth.getClaims();
  if (data?.claims?.sub) redirect("/");

  const { erro } = await searchParams;

  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-6 px-4 py-10">
      <Marca />
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle>Entrar</CardTitle>
          <CardDescription>
            Use seu e-mail e senha. Estudante sem conta? Clique em “Cadastre-se”.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <FormularioLogin aviso={erro === "link" ? "link" : undefined} />
        </CardContent>
      </Card>
    </main>
  );
}
