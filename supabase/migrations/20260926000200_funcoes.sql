-- =============================================================================
-- Migration 2/3: funções internas, triggers, motor de pontuação e RPCs
--
-- Schema "interno" NÃO é exposto pela API do Supabase (só "public" é). Tudo
-- que não deve ser chamado diretamente pelo cliente fica lá.
-- Todas as funções SECURITY DEFINER fixam search_path = '' e qualificam nomes.
-- =============================================================================

create schema if not exists interno;

-- -----------------------------------------------------------------------------
-- Helpers de autorização (usados nas políticas RLS)
-- -----------------------------------------------------------------------------
create or replace function interno.is_admin()
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.staff where user_id = auth.uid() and papel = 'ADMIN');
$$;

create or replace function interno.is_staff()
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.staff where user_id = auth.uid());
$$;

-- Retorna o estudante logado, exigindo cadastro concluído e status ATIVO.
create or replace function interno.estudante_ativo()
returns public.estudantes
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_est public.estudantes;
begin
  if auth.uid() is null then
    raise exception 'Não autenticado.' using errcode = '28000';
  end if;
  select * into v_est from public.estudantes where id = auth.uid();
  if not found then
    raise exception 'Cadastro não concluído.' using errcode = 'P0001', hint = 'CADASTRO_PENDENTE';
  end if;
  if v_est.status <> 'ATIVO' then
    raise exception 'Seu acesso está %. Procure a coordenação do curso.', lower(v_est.status::text)
      using errcode = '42501', hint = 'ACESSO_' || v_est.status::text;
  end if;
  return v_est;
end;
$$;

-- -----------------------------------------------------------------------------
-- Configuração
-- -----------------------------------------------------------------------------
create or replace function interno.cfg_num(p_chave text)
returns numeric
language plpgsql stable security definer set search_path = ''
as $$
declare
  v numeric;
begin
  select (valor #>> '{}')::numeric into v from public.config where chave = p_chave;
  if v is null then
    raise exception 'Configuração ausente ou inválida: %', p_chave;
  end if;
  return v;
end;
$$;

create or replace function interno.peso_por_dificuldade(p_dificuldade smallint)
returns integer
language sql stable security definer set search_path = ''
as $$
  select round(interno.cfg_num(case p_dificuldade
                                 when 1 then 'pontos_facil'
                                 when 2 then 'pontos_media'
                                 else 'pontos_dificil' end))::integer;
$$;

-- -----------------------------------------------------------------------------
-- Motor de pontuação
--   pontos = peso_base × bonus_tempo × mult_sequencia × mult_componente
-- p_sequencia_anterior = acertos consecutivos ANTES desta resposta.
-- -----------------------------------------------------------------------------
create or replace function interno.calcular_pontos(
  p_peso integer,
  p_tempo_segundos integer,
  p_sequencia_anterior integer,
  p_componente public.componente
)
returns integer
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_max   numeric := interno.cfg_num('bonus_tempo_max');
  v_min   numeric := interno.cfg_num('bonus_tempo_min');
  v_lim   numeric := interno.cfg_num('limite_bonus_tempo_seg');
  v_inc   numeric := interno.cfg_num('sequencia_incremento');
  v_teto  numeric := interno.cfg_num('sequencia_teto');
  v_fg    numeric := interno.cfg_num('multiplicador_fg');
  v_bonus numeric;
  v_seq   numeric;
  v_comp  numeric;
begin
  if v_lim <= 0 then
    v_bonus := v_max;
  else
    v_bonus := v_max - (v_max - v_min) * least(greatest(coalesce(p_tempo_segundos, 0), 0), v_lim) / v_lim;
  end if;
  v_seq  := least(v_teto, 1 + v_inc * greatest(coalesce(p_sequencia_anterior, 0), 0));
  v_comp := case when p_componente = 'FG' then v_fg else 1 end;
  return round(p_peso * v_bonus * v_seq * v_comp)::integer;
end;
$$;

-- -----------------------------------------------------------------------------
-- Visibilidade de questões para o aluno
-- -----------------------------------------------------------------------------
create or replace function interno.questao_visivel(p_q public.questoes, p_curso public.curso)
returns boolean
language sql immutable
as $$
  select p_q.status = 'PUBLICADA'
     and ('ALL' = any (p_q.cursos) or p_curso::text::public.curso_alvo = any (p_q.cursos));
$$;

-- Questão reservada para um simulado publicado que ainda não terminou: fica
-- fora do Treino Livre para não vazar a prova.
create or replace function interno.questao_reservada(p_questao_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.sessoes s
     where s.publicada and s.tipo = 'SIMULADO' and s.fim > now()
       and p_questao_id = any (s.questoes)
  );
$$;

-- Payload da questão para o aluno — nunca inclui gabarito/justificativa.
create or replace function interno.questao_json(p_q public.questoes)
returns jsonb
language sql immutable
as $$
  select jsonb_build_object(
    'id',          p_q.id,
    'componente',  p_q.componente,
    'eixo',        p_q.eixo,
    'formato',     p_q.formato,
    'texto_apoio', p_q.texto_apoio,
    'enunciado',   p_q.enunciado,
    'alternativas', case when p_q.formato = 'OBJETIVA' then
                      jsonb_build_object('A', p_q.alt_a, 'B', p_q.alt_b, 'C', p_q.alt_c,
                                         'D', p_q.alt_d, 'E', p_q.alt_e)
                    end,
    'dificuldade', p_q.dificuldade,
    'peso_pontos', p_q.peso_pontos
  );
$$;

-- =============================================================================
-- Triggers
-- =============================================================================

-- respostas é append-only. A única exceção é a exclusão LGPD feita pela função
-- excluir_estudante_lgpd, que liga a flag de transação abaixo.
create or replace function interno.tg_respostas_append_only()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'DELETE' and current_setting('interno.exclusao_lgpd', true) = 'on' then
    return old;
  end if;
  raise exception 'A tabela respostas é append-only: % não é permitido.', tg_op
    using errcode = '42501';
end;
$$;

create trigger respostas_append_only_row
  before update or delete on public.respostas
  for each row execute function interno.tg_respostas_append_only();

create trigger respostas_append_only_truncate
  before truncate on public.respostas
  for each statement execute function interno.tg_respostas_append_only();

-- Peso derivado da dificuldade (mas editável) + atualizado_em.
create or replace function interno.tg_questoes_peso()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    if new.peso_pontos is null then
      new.peso_pontos := interno.peso_por_dificuldade(new.dificuldade);
    end if;
  else
    if new.dificuldade is distinct from old.dificuldade
       and new.peso_pontos is not distinct from old.peso_pontos then
      new.peso_pontos := interno.peso_por_dificuldade(new.dificuldade);
    elsif new.peso_pontos is null then
      new.peso_pontos := interno.peso_por_dificuldade(new.dificuldade);
    end if;
    new.atualizado_em := now();
  end if;
  return new;
end;
$$;

create trigger questoes_peso
  before insert or update on public.questoes
  for each row execute function interno.tg_questoes_peso();

-- Questão objetiva só pode ser publicada com gabarito cadastrado.
create or replace function interno.tg_questoes_publicacao()
returns trigger
language plpgsql
as $$
begin
  if new.status = 'PUBLICADA' and new.formato = 'OBJETIVA' and not exists (
       select 1 from public.questoes_gabarito g
        where g.questao_id = new.id and g.gabarito is not null) then
    raise exception 'Questão objetiva não pode ser publicada sem gabarito.' using errcode = '23514';
  end if;
  -- Formato e componente não mudam depois de haver respostas.
  if tg_op = 'UPDATE'
     and (new.formato is distinct from old.formato or new.componente is distinct from old.componente)
     and exists (select 1 from public.respostas r where r.questao_id = new.id) then
    raise exception 'Formato/componente não podem mudar: a questão já tem respostas.' using errcode = '23514';
  end if;
  return new;
end;
$$;

create trigger questoes_publicacao
  before insert or update on public.questoes
  for each row execute function interno.tg_questoes_publicacao();

create or replace function interno.tg_gabarito_protege()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em := now();
  if new.gabarito is null and exists (
       select 1 from public.questoes q
        where q.id = new.questao_id and q.status = 'PUBLICADA' and q.formato = 'OBJETIVA') then
    raise exception 'Questão publicada não pode ficar sem gabarito.' using errcode = '23514';
  end if;
  return new;
end;
$$;

create trigger gabarito_protege
  before insert or update on public.questoes_gabarito
  for each row execute function interno.tg_gabarito_protege();

-- Simulado publicado: questões existentes, publicadas e sem duplicatas.
create or replace function interno.tg_sessoes_valida()
returns trigger
language plpgsql
as $$
begin
  if new.publicada then
    if (select count(distinct x) from unnest(new.questoes) x) <> cardinality(new.questoes) then
      raise exception 'Sessão contém questões duplicadas.' using errcode = '23514';
    end if;
    if exists (
         select 1 from unnest(new.questoes) x
          where not exists (select 1 from public.questoes q where q.id = x and q.status = 'PUBLICADA')) then
      raise exception 'Todas as questões da sessão precisam existir e estar publicadas.' using errcode = '23514';
    end if;
  end if;
  return new;
end;
$$;

create trigger sessoes_valida
  before insert or update on public.sessoes
  for each row execute function interno.tg_sessoes_valida();

create or replace function interno.tg_config_atualizado()
returns trigger
language plpgsql
as $$
begin
  new.atualizado_em := now();
  return new;
end;
$$;

create trigger config_atualizado
  before update on public.config
  for each row execute function interno.tg_config_atualizado();

-- =============================================================================
-- RPCs do aluno (public, SECURITY DEFINER)
-- =============================================================================

-- Conclui o cadastro após o primeiro login por magic link.
create or replace function public.concluir_cadastro(p_matricula text, p_aceite_lgpd boolean)
returns public.estudantes
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_uid   uuid := auth.uid();
  v_email text;
  v_mat   public.matriculas_autorizadas;
  v_est   public.estudantes;
begin
  if v_uid is null then
    raise exception 'Não autenticado.' using errcode = '28000';
  end if;
  if not coalesce(p_aceite_lgpd, false) then
    raise exception 'É necessário aceitar o termo de consentimento (LGPD).' using hint = 'LGPD_OBRIGATORIO';
  end if;
  if exists (select 1 from public.estudantes where id = v_uid) then
    raise exception 'Cadastro já concluído.' using hint = 'CADASTRO_EXISTENTE';
  end if;

  select lower(btrim(email)) into v_email from auth.users where id = v_uid;
  if v_email is null or v_email = '' then
    raise exception 'Conta sem e-mail.';
  end if;

  select * into v_mat from public.matriculas_autorizadas where matricula = btrim(p_matricula);
  if not found then
    raise exception 'Matrícula não encontrada entre os estudantes autorizados.' using hint = 'MATRICULA_INVALIDA';
  end if;
  if exists (select 1 from public.estudantes where matricula = v_mat.matricula) then
    raise exception 'Esta matrícula já está vinculada a outra conta. Procure a coordenação.'
      using hint = 'MATRICULA_EM_USO';
  end if;

  insert into public.estudantes
    (id, email_pessoal, nome, matricula, curso, turma, tipo, status,
     consentimento_lgpd, consentimento_data, ultimo_acesso)
  values
    (v_uid, v_email, v_mat.nome, v_mat.matricula, v_mat.curso, v_mat.turma, v_mat.tipo, 'ATIVO',
     true, now(), now())
  returning * into v_est;

  return v_est;
end;
$$;

create or replace function public.registrar_acesso()
returns void
language sql volatile security definer set search_path = ''
as $$
  update public.estudantes set ultimo_acesso = now() where id = auth.uid();
$$;

-- Eixos disponíveis para o curso do aluno (filtros do Treino Livre).
create or replace function public.eixos_disponiveis()
returns table (componente public.componente, eixo text, total bigint, respondidas bigint)
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_est public.estudantes := interno.estudante_ativo();
begin
  return query
    select q.componente, q.eixo, count(*),
           count(*) filter (where exists (
             select 1 from public.respostas r where r.estudante_id = v_est.id and r.questao_id = q.id))
      from public.questoes q
     where interno.questao_visivel(q, v_est.curso)
       and not interno.questao_reservada(q.id)
     group by q.componente, q.eixo
     order by q.componente, q.eixo;
end;
$$;

-- Entrega uma questão específica ao aluno e registra o instante da exibição.
create or replace function public.exibir_questao(p_questao_id uuid)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_est public.estudantes := interno.estudante_ativo();
  v_q   public.questoes;
begin
  select * into v_q from public.questoes where id = p_questao_id;
  if not found or not interno.questao_visivel(v_q, v_est.curso) or interno.questao_reservada(v_q.id) then
    raise exception 'Questão indisponível.' using errcode = 'P0002';
  end if;

  insert into public.exibicoes_questao (estudante_id, questao_id, exibida_em)
  values (v_est.id, v_q.id, clock_timestamp());

  return interno.questao_json(v_q) || jsonb_build_object(
    'ja_respondida', exists (select 1 from public.respostas r
                              where r.estudante_id = v_est.id and r.questao_id = v_q.id));
end;
$$;

-- Sorteia a próxima questão do Treino Livre dentro dos filtros.
create or replace function public.proxima_questao_treino(
  p_componente public.componente default null,
  p_eixo text default null,
  p_dificuldade smallint default null,
  p_incluir_respondidas boolean default false
)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_est public.estudantes := interno.estudante_ativo();
  v_id  uuid;
begin
  select q.id into v_id
    from public.questoes q
   where interno.questao_visivel(q, v_est.curso)
     and not interno.questao_reservada(q.id)
     and (p_componente is null or q.componente = p_componente)
     and (p_eixo is null or q.eixo = p_eixo)
     and (p_dificuldade is null or q.dificuldade = p_dificuldade)
     and (p_incluir_respondidas or not exists (
            select 1 from public.respostas r where r.estudante_id = v_est.id and r.questao_id = q.id))
   order by random()
   limit 1;

  if v_id is null then
    return null;
  end if;
  return public.exibir_questao(v_id);
end;
$$;

-- Grava a resposta (append-only), calcula pontos no servidor e devolve a
-- devolutiva. Em simulado, NÃO devolve gabarito/justificativa.
create or replace function public.responder_questao(
  p_questao_id uuid,
  p_alternativa text default null,
  p_resposta_texto text default null,
  p_sessao_id uuid default null
)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_est      public.estudantes := interno.estudante_ativo();
  v_q        public.questoes;
  v_gab      public.questoes_gabarito;
  v_sess     public.sessoes;
  v_part     public.sessoes_participacao;
  v_alt      text;
  v_texto    text;
  v_ref      timestamptz;
  v_agora    timestamptz;
  v_tempo    integer;
  v_tent     integer;
  v_seq_ant  integer;
  v_seq      integer;
  v_correta  boolean;
  v_pontos   integer := 0;
  v_id       uuid;
begin
  -- Serializa as respostas de um mesmo aluno (tentativa_n e sequência consistentes).
  perform pg_advisory_xact_lock(hashtextextended(v_est.id::text, 0));
  v_agora := clock_timestamp();

  select * into v_q from public.questoes where id = p_questao_id;
  if not found or v_q.status <> 'PUBLICADA' then
    raise exception 'Questão indisponível.' using errcode = 'P0002';
  end if;

  if v_q.formato = 'OBJETIVA' then
    v_alt := upper(nullif(btrim(p_alternativa), ''));
    if v_alt is null or v_alt not in ('A', 'B', 'C', 'D', 'E') then
      raise exception 'Alternativa inválida.' using errcode = '22023';
    end if;
  else
    v_texto := nullif(btrim(p_resposta_texto), '');
    if v_texto is null then
      raise exception 'A resposta discursiva não pode ficar em branco.' using errcode = '22023';
    end if;
  end if;

  if p_sessao_id is null then
    -- ---------------- Treino Livre ----------------
    if not interno.questao_visivel(v_q, v_est.curso) or interno.questao_reservada(v_q.id) then
      raise exception 'Questão indisponível.' using errcode = 'P0002';
    end if;
    -- Conta o tempo a partir da PRIMEIRA exibição desde a última resposta:
    -- reabrir a questão não reinicia o cronômetro.
    select min(e.exibida_em) into v_ref
      from public.exibicoes_questao e
     where e.estudante_id = v_est.id and e.questao_id = v_q.id
       and e.exibida_em > coalesce((select max(r.criado_em) from public.respostas r
                                     where r.estudante_id = v_est.id and r.questao_id = v_q.id),
                                   '-infinity'::timestamptz);
    if v_ref is null then
      raise exception 'Abra a questão antes de responder.' using hint = 'SEM_EXIBICAO';
    end if;
  else
    -- ---------------- Simulado ----------------
    select * into v_sess from public.sessoes
     where id = p_sessao_id and publicada and tipo = 'SIMULADO';
    if not found or (v_sess.curso is not null and v_sess.curso <> v_est.curso) then
      raise exception 'Simulado indisponível.' using errcode = 'P0002';
    end if;
    if not (v_q.id = any (v_sess.questoes)) then
      raise exception 'Questão não pertence a este simulado.' using errcode = '22023';
    end if;
    select * into v_part from public.sessoes_participacao
     where sessao_id = v_sess.id and estudante_id = v_est.id;
    if not found then
      raise exception 'Simulado não iniciado.' using hint = 'SIMULADO_NAO_INICIADO';
    end if;
    if v_part.finalizada_em is not null then
      raise exception 'Simulado já finalizado.' using hint = 'SIMULADO_FINALIZADO';
    end if;
    if v_agora > least(v_sess.fim, v_part.iniciada_em + make_interval(mins => v_sess.duracao_minutos)) then
      raise exception 'Tempo do simulado esgotado.' using hint = 'TEMPO_ESGOTADO';
    end if;
    if exists (select 1 from public.respostas r
                where r.estudante_id = v_est.id and r.sessao_id = v_sess.id and r.questao_id = v_q.id) then
      raise exception 'Questão já respondida neste simulado.' using hint = 'JA_RESPONDIDA';
    end if;
    -- Tempo da questão = desde a resposta anterior no simulado (ou do início).
    select greatest(v_part.iniciada_em, coalesce(max(r.criado_em), v_part.iniciada_em)) into v_ref
      from public.respostas r
     where r.estudante_id = v_est.id and r.sessao_id = v_sess.id;
  end if;

  v_tempo := greatest(0, floor(extract(epoch from (v_agora - v_ref))))::integer;

  select count(*) + 1 into v_tent
    from public.respostas r where r.estudante_id = v_est.id and r.questao_id = v_q.id;

  if v_q.formato = 'OBJETIVA' then
    select * into v_gab from public.questoes_gabarito where questao_id = v_q.id;
    if v_gab.gabarito is null then
      raise exception 'Questão sem gabarito cadastrado.' using errcode = 'P0002';
    end if;
    v_correta := (v_alt = v_gab.gabarito);

    if v_tent = 1 then
      -- Só a 1ª tentativa pontua e conta para a sequência. Erro vale 0 e zera a sequência.
      select r.sequencia_atual into v_seq_ant
        from public.respostas r
       where r.estudante_id = v_est.id and r.sequencia_atual is not null
       order by r.criado_em desc limit 1;
      v_seq_ant := coalesce(v_seq_ant, 0);
      if v_correta then
        v_pontos := interno.calcular_pontos(v_q.peso_pontos, v_tempo, v_seq_ant, v_q.componente);
        v_seq    := v_seq_ant + 1;
      else
        v_seq    := 0;
      end if;
    end if;
  else
    -- Discursiva: pontua depois, na correção docente.
    select * into v_gab from public.questoes_gabarito where questao_id = v_q.id;
  end if;

  insert into public.respostas
    (estudante_id, questao_id, sessao_id, alternativa, resposta_texto, correta,
     tempo_segundos, pontos_ganhos, tentativa_n, sequencia_atual, criado_em)
  values
    (v_est.id, v_q.id, p_sessao_id, v_alt, v_texto, v_correta,
     v_tempo, v_pontos, v_tent, v_seq, v_agora)
  returning id into v_id;

  if p_sessao_id is not null then
    return jsonb_build_object('registrada', true, 'resposta_id', v_id);
  end if;

  return jsonb_build_object(
    'registrada',      true,
    'resposta_id',     v_id,
    'formato',         v_q.formato,
    'correta',         v_correta,
    'aguardando_correcao', v_q.formato = 'DISCURSIVA',
    'alternativa',     v_alt,
    'gabarito',        v_gab.gabarito,
    'justificativa',   v_gab.justificativa,
    'pontos',          v_pontos,
    'tentativa_n',     v_tent,
    'pontuou',         v_tent = 1,
    'sequencia',       v_seq,
    'tempo_segundos',  v_tempo
  );
end;
$$;

-- Devolutiva de uma questão já respondida (revisão). Só libera o gabarito se o
-- aluno respondeu no treino, ou num simulado já encerrado para ele.
create or replace function public.devolutiva_questao(p_questao_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_est public.estudantes := interno.estudante_ativo();
  v_q   public.questoes;
  v_gab public.questoes_gabarito;
begin
  if not exists (
       select 1
         from public.respostas r
         left join public.sessoes s on s.id = r.sessao_id
         left join public.sessoes_participacao p on p.sessao_id = r.sessao_id and p.estudante_id = r.estudante_id
        where r.estudante_id = v_est.id and r.questao_id = p_questao_id
          and (r.sessao_id is null
               or p.finalizada_em is not null
               or now() > least(s.fim, p.iniciada_em + make_interval(mins => s.duracao_minutos)))) then
    raise exception 'Devolutiva indisponível: responda a questão primeiro.' using errcode = '42501';
  end if;

  select * into v_q   from public.questoes where id = p_questao_id;
  select * into v_gab from public.questoes_gabarito where questao_id = p_questao_id;

  return interno.questao_json(v_q) || jsonb_build_object(
    'gabarito',      v_gab.gabarito,
    'justificativa', v_gab.justificativa,
    'respostas', (select coalesce(jsonb_agg(jsonb_build_object(
                    'tentativa_n', r.tentativa_n, 'alternativa', r.alternativa,
                    'resposta_texto', r.resposta_texto, 'correta', r.correta,
                    'pontos', r.pontos_ganhos + coalesce(c.pontos, 0),
                    'nota', c.nota, 'comentario', c.comentario, 'criado_em', r.criado_em)
                    order by r.tentativa_n), '[]'::jsonb)
                    from public.respostas r
                    left join public.correcoes_discursivas c on c.resposta_id = r.id
                   where r.estudante_id = v_est.id and r.questao_id = p_questao_id)
  );
end;
$$;

-- Inicia (ou retoma) um simulado cronometrado.
create or replace function public.iniciar_simulado(p_sessao_id uuid)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_est  public.estudantes := interno.estudante_ativo();
  v_sess public.sessoes;
  v_part public.sessoes_participacao;
begin
  select * into v_sess from public.sessoes
   where id = p_sessao_id and publicada and tipo = 'SIMULADO';
  if not found or (v_sess.curso is not null and v_sess.curso <> v_est.curso) then
    raise exception 'Simulado indisponível.' using errcode = 'P0002';
  end if;
  if now() < v_sess.inicio then
    raise exception 'O simulado ainda não abriu.' using hint = 'SIMULADO_FUTURO';
  end if;

  select * into v_part from public.sessoes_participacao
   where sessao_id = v_sess.id and estudante_id = v_est.id;
  if not found then
    if now() >= v_sess.fim then
      raise exception 'O simulado já encerrou.' using hint = 'SIMULADO_ENCERRADO';
    end if;
    insert into public.sessoes_participacao (sessao_id, estudante_id, iniciada_em)
    values (v_sess.id, v_est.id, clock_timestamp())
    returning * into v_part;
  elsif v_part.finalizada_em is not null then
    raise exception 'Simulado já finalizado.' using hint = 'SIMULADO_FINALIZADO';
  end if;

  return jsonb_build_object(
    'sessao_id',   v_sess.id,
    'titulo',      v_sess.titulo,
    'iniciada_em', v_part.iniciada_em,
    'termina_em',  least(v_sess.fim, v_part.iniciada_em + make_interval(mins => v_sess.duracao_minutos)),
    'questoes', (select jsonb_agg(interno.questao_json(q) order by x.ord)
                   from unnest(v_sess.questoes) with ordinality as x(id, ord)
                   join public.questoes q on q.id = x.id),
    'respondidas', (select coalesce(jsonb_agg(r.questao_id), '[]'::jsonb)
                      from public.respostas r
                     where r.estudante_id = v_est.id and r.sessao_id = v_sess.id)
  );
end;
$$;

create or replace function public.finalizar_simulado(p_sessao_id uuid)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_est  public.estudantes := interno.estudante_ativo();
  v_part public.sessoes_participacao;
begin
  update public.sessoes_participacao
     set finalizada_em = clock_timestamp()
   where sessao_id = p_sessao_id and estudante_id = v_est.id and finalizada_em is null
  returning * into v_part;
  if not found then
    raise exception 'Nenhum simulado em andamento para finalizar.' using hint = 'SEM_PARTICIPACAO';
  end if;
  return jsonb_build_object('sessao_id', p_sessao_id, 'finalizada_em', v_part.finalizada_em);
end;
$$;

-- =============================================================================
-- RPCs da equipe
-- =============================================================================

create or replace function public.corrigir_discursiva(p_resposta_id uuid, p_nota numeric, p_comentario text default null)
returns public.correcoes_discursivas
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_r      public.respostas;
  v_q      public.questoes;
  v_pontos integer := 0;
  v_c      public.correcoes_discursivas;
begin
  if not interno.is_staff() then
    raise exception 'Acesso restrito à equipe docente.' using errcode = '42501';
  end if;
  if p_nota is null or p_nota < 0 or p_nota > 100 then
    raise exception 'A nota deve estar entre 0 e 100.' using errcode = '22023';
  end if;
  select * into v_r from public.respostas where id = p_resposta_id;
  if not found or v_r.resposta_texto is null then
    raise exception 'Resposta discursiva não encontrada.' using errcode = 'P0002';
  end if;
  select * into v_q from public.questoes where id = v_r.questao_id;

  if v_r.tentativa_n = 1 then
    v_pontos := round(v_q.peso_pontos * (p_nota / 100)
                      * case when v_q.componente = 'FG' then interno.cfg_num('multiplicador_fg') else 1 end)::integer;
  end if;

  insert into public.correcoes_discursivas (resposta_id, docente_id, nota, pontos, comentario, corrigida_em)
  values (v_r.id, auth.uid(), p_nota, v_pontos, p_comentario, now())
  on conflict (resposta_id) do update
     set docente_id = excluded.docente_id, nota = excluded.nota, pontos = excluded.pontos,
         comentario = excluded.comentario, corrigida_em = excluded.corrigida_em
  returning * into v_c;
  return v_c;
end;
$$;

-- Direito de eliminação (LGPD, art. 18). Única via que remove respostas.
create or replace function public.excluir_estudante_lgpd(p_estudante_id uuid)
returns void
language plpgsql volatile security definer set search_path = ''
as $$
begin
  if not interno.is_admin() then
    raise exception 'Acesso restrito à coordenação.' using errcode = '42501';
  end if;
  perform set_config('interno.exclusao_lgpd', 'on', true);
  delete from public.estudantes where id = p_estudante_id;
  perform set_config('interno.exclusao_lgpd', 'off', true);
end;
$$;
