# Portal Simulado ENADE — UNIVC

Treino gamificado para o ENADE (Engenharia Mecânica, Engenharia de Produção e ADS).
Stack: Next.js (Vercel) + Supabase (Postgres, Auth) + Resend (SMTP do Supabase Auth).

## Status

- [x] Sprint 1 — schema Postgres, RLS, motor de pontuação, seed da `config`
- [ ] Sprint 2 — magic link + cadastro validado
- [ ] Sprint 3 — painel admin (CRUD + import CSV)
- [ ] Sprint 4 — Treino Livre
- [ ] Sprint 5 — ranking, badges, perfil
- [ ] Sprint 6 — simulado cronometrado + relatórios

## Banco de dados

```
supabase/migrations/   schema, funções/RPCs e políticas RLS
supabase/seed.sql      dados só de desenvolvimento
tests/db/              testes de RLS e regras de negócio (PGlite)
```

Aplicar no projeto Supabase:

```bash
npx supabase link --project-ref <ref-do-projeto>
npx supabase db push
```

Rodar os testes (não precisa de Docker):

```bash
npm install
npm run test:db
```

## Decisões de segurança

- Gabarito e justificativa ficam em `questoes_gabarito`, sem leitura para alunos.
  O aluno recebe questões e devolutiva apenas via RPCs `SECURITY DEFINER`.
- `respostas` é append-only (trigger bloqueia UPDATE/DELETE/TRUNCATE); só a
  exclusão LGPD (`excluir_estudante_lgpd`) remove linhas.
- Pontos e tempo de resposta são calculados no servidor.
- Respostas de simulado em andamento ficam invisíveis ao próprio aluno.
- Para dar acesso administrativo, insira o usuário em `public.staff`
  (papel `ADMIN` ou `DOCENTE`) pelo SQL Editor do Supabase.
