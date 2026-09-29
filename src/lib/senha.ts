// Regras de senha (mesmas no cliente e no servidor).
export const SENHA_MIN = 8;

export function senhaForteOuErro(senha: string): string | null {
  if (senha.length < SENHA_MIN) return `A senha precisa ter pelo menos ${SENHA_MIN} caracteres.`;
  if (senha.length > 72) return "A senha pode ter no máximo 72 caracteres.";
  if (!/[A-Za-zÀ-ÿ]/.test(senha) || !/\d/.test(senha)) return "Use letras e números na senha.";
  return null;
}
