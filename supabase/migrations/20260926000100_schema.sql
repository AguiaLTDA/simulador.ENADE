-- =============================================================================
-- Portal Simulado ENADE — UNIVC
-- Migration 1/3: tipos, tabelas, índices e seed da configuração
-- =============================================================================

-- gen_random_uuid() é nativo desde o Postgres 13; nenhuma extensão necessária.

-- -----------------------------------------------------------------------------
-- Tipos
-- -----------------------------------------------------------------------------
create type public.curso            as enum ('ENG_MEC', 'ENG_PROD', 'ADS');
-- Cursos-alvo de uma questão: 'ALL' = Formação Geral (vale para todos).
create type public.curso_alvo       as enum ('ALL', 'ENG_MEC', 'ENG_PROD', 'ADS');
create type public.tipo_estudante   as enum ('CONCLUINTE', 'INGRESSANTE');
create type public.status_estudante as enum ('ATIVO', 'PENDENTE', 'BLOQUEADO');
create type public.componente       as enum ('FG', 'CE');
create type public.formato_questao  as enum ('OBJETIVA', 'DISCURSIVA');
create type public.status_questao   as enum ('RASCUNHO', 'PUBLICADA', 'ARQUIVADA');
create type public.tipo_sessao      as enum ('TREINO', 'SIMULADO');
create type public.papel_staff      as enum ('ADMIN', 'DOCENTE');

-- -----------------------------------------------------------------------------
-- Equipe (coordenação / NDE / docentes corretores)
-- -----------------------------------------------------------------------------
create table public.staff (
  user_id   uuid primary key references auth.users (id) on delete cascade,
  nome      text not null,
  papel     public.papel_staff not null default 'DOCENTE',
  criado_em timestamptz not null default now()
);
comment on table public.staff is
  'Usuários com acesso administrativo. ADMIN = coordenação/NDE; DOCENTE = corrige discursivas.';

-- -----------------------------------------------------------------------------
-- Matrículas autorizadas (importadas do sistema acadêmico)
-- -----------------------------------------------------------------------------
create table public.matriculas_autorizadas (
  matricula    text primary key check (matricula = btrim(matricula) and matricula <> ''),
  nome         text not null,
  curso        public.curso not null,
  turma        text not null,
  tipo         public.tipo_estudante not null,
  importado_em timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Estudantes
-- -----------------------------------------------------------------------------
create table public.estudantes (
  id                  uuid primary key references auth.users (id) on delete cascade,
  email_pessoal       text not null unique check (email_pessoal = lower(btrim(email_pessoal))),
  nome                text not null,
  matricula           text not null unique references public.matriculas_autorizadas (matricula),
  curso               public.curso not null,
  turma               text not null,
  tipo                public.tipo_estudante not null,
  status              public.status_estudante not null default 'PENDENTE',
  consentimento_lgpd  boolean not null default false,
  consentimento_data  timestamptz,
  criado_em           timestamptz not null default now(),
  ultimo_acesso       timestamptz,
  constraint estudantes_ativo_exige_lgpd
    check (status <> 'ATIVO' or (consentimento_lgpd and consentimento_data is not null))
);
create index estudantes_curso_turma_idx on public.estudantes (curso, turma);

-- -----------------------------------------------------------------------------
-- Questões (SEM gabarito — ver questoes_gabarito)
-- -----------------------------------------------------------------------------
create table public.questoes (
  id           uuid primary key default gen_random_uuid(),
  componente   public.componente not null,
  cursos       public.curso_alvo[] not null,
  eixo         text not null check (btrim(eixo) <> ''),
  formato      public.formato_questao not null default 'OBJETIVA',
  texto_apoio  text,
  enunciado    text not null check (btrim(enunciado) <> ''),
  alt_a        text,
  alt_b        text,
  alt_c        text,
  alt_d        text,
  alt_e        text,
  dificuldade  smallint not null check (dificuldade between 1 and 3),
  peso_pontos  integer check (peso_pontos > 0),  -- preenchido por trigger a partir da config
  fonte        text,
  status       public.status_questao not null default 'RASCUNHO',
  autor_id     uuid references auth.users (id) on delete set null default auth.uid(),
  criado_em    timestamptz not null default now(),
  atualizado_em timestamptz not null default now(),

  -- FG vale para todos os cursos; CE nunca usa ALL e precisa de ao menos um curso.
  constraint questoes_cursos_coerentes check (
    cardinality(cursos) >= 1 and
    case componente
      when 'FG' then cursos = array['ALL']::public.curso_alvo[]
      else not ('ALL' = any (cursos))
    end
  ),
  -- Objetiva exige as 5 alternativas; discursiva não tem alternativas.
  constraint questoes_alternativas_coerentes check (
    case formato
      when 'OBJETIVA' then coalesce(btrim(alt_a), '') <> '' and coalesce(btrim(alt_b), '') <> ''
                       and coalesce(btrim(alt_c), '') <> '' and coalesce(btrim(alt_d), '') <> ''
                       and coalesce(btrim(alt_e), '') <> ''
      else alt_a is null and alt_b is null and alt_c is null and alt_d is null and alt_e is null
    end
  )
);
create index questoes_filtro_idx on public.questoes (status, componente, eixo, dificuldade);
create index questoes_cursos_idx on public.questoes using gin (cursos);

-- Gabarito e justificativa ficam em tabela separada, sem nenhuma política de
-- leitura para estudantes. O aluno só recebe esses campos via RPC, depois de
-- ter gravado a resposta.
create table public.questoes_gabarito (
  questao_id    uuid primary key references public.questoes (id) on delete cascade,
  gabarito      char(1) check (gabarito in ('A', 'B', 'C', 'D', 'E')),
  justificativa text,  -- para discursivas: padrão de resposta esperado
  atualizado_em timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Sessões (simulados cronometrados / treinos dirigidos)
-- -----------------------------------------------------------------------------
create table public.sessoes (
  id              uuid primary key default gen_random_uuid(),
  tipo            public.tipo_sessao not null default 'SIMULADO',
  titulo          text not null check (btrim(titulo) <> ''),
  curso           public.curso,             -- null = aberta a todos os cursos
  inicio          timestamptz not null,
  fim             timestamptz not null,
  duracao_minutos integer not null check (duracao_minutos > 0),
  questoes        uuid[] not null default '{}',
  publicada       boolean not null default false,
  criado_por      uuid references auth.users (id) on delete set null default auth.uid(),
  criado_em       timestamptz not null default now(),
  constraint sessoes_janela_valida check (fim > inicio),
  constraint sessoes_publicada_com_questoes check (not publicada or cardinality(questoes) > 0)
);

-- Participação do aluno num simulado (início/fim individuais do cronômetro).
create table public.sessoes_participacao (
  sessao_id     uuid not null references public.sessoes (id) on delete cascade,
  estudante_id  uuid not null references public.estudantes (id) on delete cascade,
  iniciada_em   timestamptz not null default now(),
  finalizada_em timestamptz,
  primary key (sessao_id, estudante_id)
);

-- -----------------------------------------------------------------------------
-- Exibições: registro de quando a questão foi entregue ao aluno. O tempo de
-- resposta é calculado no servidor a partir daqui (o cliente não informa).
-- -----------------------------------------------------------------------------
create table public.exibicoes_questao (
  id            bigint generated always as identity primary key,
  estudante_id  uuid not null references public.estudantes (id) on delete cascade,
  questao_id    uuid not null references public.questoes (id) on delete cascade,
  exibida_em    timestamptz not null default now()
);
create index exibicoes_lookup_idx on public.exibicoes_questao (estudante_id, questao_id, exibida_em desc);

-- -----------------------------------------------------------------------------
-- Respostas — APPEND-ONLY (trigger bloqueia UPDATE/DELETE/TRUNCATE)
-- -----------------------------------------------------------------------------
create table public.respostas (
  id              uuid primary key default gen_random_uuid(),
  estudante_id    uuid not null references public.estudantes (id) on delete cascade,
  questao_id      uuid not null references public.questoes (id) on delete restrict,
  sessao_id       uuid references public.sessoes (id) on delete restrict,
  alternativa     char(1) check (alternativa in ('A', 'B', 'C', 'D', 'E')),
  resposta_texto  text,                       -- discursivas
  correta         boolean,                    -- null = discursiva aguardando correção
  tempo_segundos  integer not null check (tempo_segundos >= 0),
  pontos_ganhos   integer not null default 0 check (pontos_ganhos >= 0),
  tentativa_n     integer not null check (tentativa_n >= 1),
  sequencia_atual integer,                    -- acertos consecutivos após esta resposta (só 1ª tentativa objetiva)
  criado_em       timestamptz not null default now(),
  constraint respostas_conteudo check (alternativa is not null or resposta_texto is not null),
  constraint respostas_tentativa_unica unique (estudante_id, questao_id, tentativa_n)
);
create index respostas_estudante_idx on public.respostas (estudante_id, criado_em desc);
create index respostas_questao_idx   on public.respostas (questao_id);
-- Em simulado, uma única resposta por questão por aluno.
create unique index respostas_simulado_unica_idx
  on public.respostas (estudante_id, sessao_id, questao_id) where sessao_id is not null;

-- Correção manual de discursivas (a resposta original nunca é alterada).
create table public.correcoes_discursivas (
  resposta_id   uuid primary key references public.respostas (id) on delete cascade,
  docente_id    uuid references auth.users (id) on delete set null,
  nota          numeric(5,2) not null check (nota between 0 and 100),
  pontos        integer not null check (pontos >= 0),
  comentario    text,
  corrigida_em  timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Configuração editável sem redeploy
-- -----------------------------------------------------------------------------
create table public.config (
  chave         text primary key,
  valor         jsonb not null,
  descricao     text,
  atualizado_em timestamptz not null default now()
);

insert into public.config (chave, valor, descricao) values
  ('pontos_facil',           '10',   'Peso base de questão com dificuldade 1'),
  ('pontos_media',           '20',   'Peso base de questão com dificuldade 2'),
  ('pontos_dificil',         '35',   'Peso base de questão com dificuldade 3'),
  ('bonus_tempo_max',        '1.0',  'Multiplicador de tempo para resposta instantânea'),
  ('bonus_tempo_min',        '0.7',  'Multiplicador de tempo a partir do limite'),
  ('limite_bonus_tempo_seg', '120',  'Segundos até o bônus de tempo chegar ao mínimo'),
  ('sequencia_incremento',   '0.05', 'Acréscimo por acerto consecutivo'),
  ('sequencia_teto',         '1.5',  'Teto do multiplicador de sequência'),
  ('multiplicador_fg',       '1.3',  'Multiplicador para Formação Geral (25% da nota ENADE)')
on conflict (chave) do nothing;

-- -----------------------------------------------------------------------------
-- Conquistas (badges)
-- -----------------------------------------------------------------------------
create table public.conquistas (
  codigo    text primary key,
  nome      text not null,
  descricao text not null,
  icone     text,
  ordem     integer not null default 0
);

create table public.conquistas_estudante (
  estudante_id uuid not null references public.estudantes (id) on delete cascade,
  conquista    text not null references public.conquistas (codigo) on delete cascade,
  obtida_em    timestamptz not null default now(),
  primary key (estudante_id, conquista)
);

insert into public.conquistas (codigo, nome, descricao, icone, ordem) values
  ('CONSTANCIA_7_DIAS', 'Constância',         'Respondeu questões em 7 dias seguidos',                  'flame',          1),
  ('FG_50',             'Formação Geral 50',  'Respondeu 50 questões de Formação Geral',                'globe',          2),
  ('EXPLORADOR_EIXOS',  'Explorador',         'Visitou todos os eixos do seu curso',                    'compass',        3),
  ('SIMULADO_COMPLETO', 'Até o fim',          'Concluiu um simulado sem abandonar nenhuma discursiva',  'flag',           4)
on conflict (codigo) do nothing;
