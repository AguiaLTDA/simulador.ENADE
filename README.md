# Portal Simulado ENADE — UNIVC

Treino gamificado para o ENADE: Eng. Mecânica, Eng. de Produção, ADS, Medicina Veterinária e Arquitetura e Urbanismo.
Stack: Next.js (Vercel) + Supabase (Postgres, Auth) + Resend (SMTP do Supabase Auth).

## Status

- [x] Sprint 1 — schema Postgres, RLS, motor de pontuação, seed da `config`
- [x] Sprint 2 — magic link + cadastro livre do aluno (um cadastro por CPF)
- [~] Sprint 3 — painel admin: CRUD de questões com gabarito e peso (falta import CSV)
- [ ] Sprint 4 — Treino Livre
- [~] Sprint 5 — perfil do aluno, badges e diagnóstico inicial prontos (falta ranking)
- [x] Extra — coordenadores por curso (VET, ARQ, Engenharias+ADS) e convites da equipe
- [ ] Sprint 6 — simulado cronometrado + relatórios

## Rodar o app localmente

```bash
cp .env.example .env.local   # preencha URL e publishable key do Supabase
npm install
npm run dev
```

## Configuração do Supabase Auth (painel)

1. **Authentication > URL Configuration**: Site URL = URL da Vercel; em Redirect URLs
   adicione `https://<dominio>/auth/confirm` e `http://localhost:3000/auth/confirm`.
2. **Authentication > Emails > SMTP Settings** (Resend): host `smtp.resend.com`, porta
   `465`, usuário `resend`, senha = API key do Resend, remetente
   `nao-responda@aguiaunivc.site`.
3. **Authentication > Emails > Templates**: cole `supabase/templates/magic_link.html` em
   *Magic Link* e *Confirm signup*.

## Cadastro do aluno

Cadastro livre: no primeiro acesso o aluno informa nome, CPF, data de nascimento,
telefone, curso, turma, situação (concluinte/ingressante) e, opcionalmente, a matrícula.
Um cadastro por CPF (e por matrícula, quando informada). A coordenação pode bloquear
contas alterando `estudantes.status` para `BLOQUEADO`.
A tabela `matriculas_autorizadas` não é mais usada.

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
