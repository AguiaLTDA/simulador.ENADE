# Portal Simulado ENADE — UNIVC

Treino gamificado para o ENADE: Eng. Mecânica, Eng. de Produção, ADS, Medicina Veterinária e Arquitetura e Urbanismo.
Stack: Next.js (Vercel) + Supabase (Postgres, Auth) + Resend (SMTP do Supabase Auth).

## Status

- [x] Sprint 1 — schema Postgres, RLS, motor de pontuação, seed da `config`
- [x] Sprint 2 — login com e-mail e senha (link por e-mail para criar/redefinir) + cadastro livre (um cadastro por CPF)
- [x] Sprint 3 — painel admin: CRUD de questões com gabarito e peso + importação por planilha CSV
- [ ] Sprint 4 — Treino Livre
- [~] Sprint 5 — perfil do aluno, badges e diagnóstico inicial prontos (falta ranking)
- [x] Extra — coordenadores por curso (VET, ARQ, Engenharias+ADS) e convites da equipe
- [x] Sprint 6 — simulado cronometrado + relatórios (por aluno, por eixo e por questão; exportação CSV)
- [x] Extra — correção de discursivas pela equipe docente
- [x] Extra — administração: edição de perfis de alunos com auditoria, configuração de pesos
      pela tela, nova tentativa de simulado liberada pela coordenação, revisão por aluno

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
   *Magic Link* e *Confirm signup* (é o e-mail de "Primeiro acesso ou esqueci minha senha").
4. **Authentication > Providers > Email**: manter *Email* habilitado e definir
   *Minimum password length* = 8.

Login: e-mail + senha. "Primeiro acesso ou esqueci minha senha" envia um link
(signInWithOtp) que leva a `/definir-senha`; nenhuma senha é enviada por e-mail.

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

## Simulados

- Coordenação monta o simulado em `/admin/simulados` (sorteio no padrão ENADE:
  FG 2 discursivas + 8 objetivas; CE 3 discursivas + 27 objetivas; 4 horas).
- Aluno faz em `/simulados`: cronômetro do servidor, resposta definitiva por questão,
  finalização automática quando o tempo acaba.
- Nota estimada (0–100) com os pesos do ENADE: FG 25% (objetivas 60%, discursivas 40%)
  e CE 75% (objetivas 85%, discursivas 15%). Em branco conta como erro.
- Docentes corrigem as discursivas em `/admin/correcoes`.

## Administração

- `/admin/alunos`: coordenação edita perfil (nome, CPF, curso, turma, status...) dos alunos
  dos seus cursos; ADMIN edita qualquer um e faz a exclusão LGPD. Toda alteração fica em
  `auditoria` (só os campos que mudaram).
- `/admin/configuracoes` (ADMIN): pesos da pontuação, bônus, sequência, nota ENADE e
  diagnóstico, com limites validados em `salvar_config`.
- `/admin/questoes/importar`: planilha CSV (modelo para baixar); o banco confere linha a
  linha antes, e a importação é tudo ou nada.
- Nova tentativa de simulado: na revisão do aluno (`/admin/simulados/<id>/aluno/<aluno>`),
  a coordenação anula a tentativa atual com motivo e, se o simulado já encerrou, um prazo
  individual. A tentativa anulada fica no histórico; questões já respondidas não pontuam
  de novo.

## Decisões de segurança

- Gabarito e justificativa ficam em `questoes_gabarito`, sem leitura para alunos.
  O aluno recebe questões e devolutiva apenas via RPCs `SECURITY DEFINER`.
- `respostas` é append-only (trigger bloqueia UPDATE/DELETE/TRUNCATE); só a
  exclusão LGPD (`excluir_estudante_lgpd`) remove linhas.
- Pontos e tempo de resposta são calculados no servidor.
- Respostas de simulado em andamento ficam invisíveis ao próprio aluno. Ao finalizar,
  ele vê a nota; gabarito e acerto questão a questão só saem quando o simulado fecha
  para todos (`sessoes.fim`), para ninguém repassar respostas a quem ainda vai fazer.
- Simulado aberto a todos os cursos aceita só Formação Geral; os demais só aceitam
  questões que valem para o curso. Depois que um aluno inicia, questões, curso,
  duração e abertura ficam travados.
- Para dar acesso administrativo, insira o usuário em `public.staff`
  (papel `ADMIN` ou `DOCENTE`) pelo SQL Editor do Supabase.
