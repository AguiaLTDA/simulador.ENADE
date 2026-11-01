import { redirect } from "next/navigation";

// O antigo "Meu perfil" virou "Meu desempenho" (pontos e evolução) + "Conquistas".
export default function PerfilPage() {
  redirect("/desempenho");
}
