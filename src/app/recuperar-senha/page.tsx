import { Marca } from "@/components/marca";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { FormularioRecuperar } from "./formulario-recuperar";

export const metadata = { title: "Criar ou redefinir senha — Portal Simulado ENADE" };

export default function RecuperarSenhaPage() {
  return (
    <main className="flex flex-1 flex-col items-center justify-center gap-6 px-4 py-10">
      <Marca />
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle>Esqueci minha senha</CardTitle>
          <CardDescription>
            Informe o seu e-mail. Vamos enviar um link para você definir uma nova senha. Equipe da
            coordenação: use esta opção também no primeiro acesso.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <FormularioRecuperar />
        </CardContent>
      </Card>
    </main>
  );
}
