import { Alert, AlertDescription } from "@/components/ui/alert";
import { exigirAdminGeral } from "@/lib/contexto";
import { createClient } from "@/lib/supabase/server";
import { EquipeCliente, type Membro } from "./equipe-cliente";

export const metadata = { title: "Equipe — Portal Simulado ENADE" };

export default async function EquipePage() {
  const ctx = await exigirAdminGeral();
  const supabase = await createClient();
  const { data, error } = await supabase.rpc("listar_equipe");

  return (
    <>
      <div>
        <h1 className="text-2xl font-semibold tracking-tight">Equipe</h1>
        <p className="text-muted-foreground">
          Coordenadores veem e gerem apenas os alunos e as questões dos seus cursos. Questões de
          Formação Geral são compartilhadas entre todos.
        </p>
      </div>
      {error && (
        <Alert variant="destructive">
          <AlertDescription>Não foi possível carregar a equipe: {error.message}</AlertDescription>
        </Alert>
      )}
      <EquipeCliente membros={(data ?? []) as Membro[]} meuEmail={ctx.email.toLowerCase()} />
    </>
  );
}
