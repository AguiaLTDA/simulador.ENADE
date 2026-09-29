import { Award, Compass, Flag, Flame, Globe, Target, type LucideProps } from "lucide-react";

const ICONES: Record<string, React.ComponentType<LucideProps>> = {
  target: Target,
  flame: Flame,
  globe: Globe,
  compass: Compass,
  flag: Flag,
};

export function IconeConquista({ icone, ...props }: { icone: string | null } & LucideProps) {
  const Icone = (icone && ICONES[icone]) || Award;
  return <Icone {...props} />;
}
