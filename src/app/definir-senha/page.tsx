import { redirect } from "next/navigation";
import { Marca } from "@/components/marca";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { createClient } from "@/lib/supabase/server";
import { FormularioSenha } from "./formulario-senha";

export const metadata = { title: "Definir senha — Portal Simulado ENADE" };

export default async function DefinirSenhaPage() {
  const supabase = await createClient();
  const { data } = await supabase.auth.getClaims();
  if (!data?.claims?.sub) redirect("/login");

  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-6 px-4 py-10">
      <Marca />
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle>Defina a sua senha</CardTitle>
          <CardDescription>
            Conta: <strong>{String(data.claims.email ?? "")}</strong>. Nas próximas vezes, entre com
            este e-mail e a senha que você criar agora.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <FormularioSenha />
        </CardContent>
      </Card>
    </main>
  );
}
