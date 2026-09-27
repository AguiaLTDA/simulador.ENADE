import { Button } from "@/components/ui/button";

export function BotaoSair({ rotulo = "Sair" }: { rotulo?: string }) {
  return (
    <form action="/sair" method="post">
      <Button type="submit" variant="ghost" size="sm">
        {rotulo}
      </Button>
    </form>
  );
}
