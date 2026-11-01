-- =============================================================================
-- Migration 14: Atividades avaliativas e gestão da pontuação
--
--   * Questões podem ter figura (gráfico, diagrama, tabela) entre o texto-base e
--     o enunciado, e uma figura das alternativas quando elas são gráficas. O
--     caminho é relativo a /public (ex.: enade2023/mec/mec-q12.png).
--   * Simulado com "valor da atividade" (sessoes.pontos_atividade): quando o
--     gabarito é liberado ao aluno, ele recebe valor × nota estimada / 100.
--     É calculado na hora, então correções de discursivas e mudanças no valor
--     feitas pela coordenação refletem automaticamente no placar.
--   * Ajustes de pontuação pela coordenação (bônus ou desconto, com motivo),
--     auditados. Entram no placar e no ranking.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Figuras das questões
-- -----------------------------------------------------------------------------
alter table public.questoes
  add column figura_url              text check (figura_url ~ '^[a-z0-9/_.-]+\.(png|jpg|jpeg|svg|webp)$'),
  add column figura_alternativas_url text check (figura_alternativas_url ~ '^[a-z0-9/_.-]+\.(png|jpg|jpeg|svg|webp)$');

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
    'figura_url',  p_q.figura_url,
    'enunciado',   p_q.enunciado,
    'figura_alternativas_url', p_q.figura_alternativas_url,
    'alternativas', case when p_q.formato = 'OBJETIVA' then
                      jsonb_build_object('A', p_q.alt_a, 'B', p_q.alt_b, 'C', p_q.alt_c,
                                         'D', p_q.alt_d, 'E', p_q.alt_e)
                    end,
    'dificuldade', p_q.dificuldade,
    'peso_pontos', p_q.peso_pontos
  );
$$;

-- -----------------------------------------------------------------------------
-- Valor da atividade
-- -----------------------------------------------------------------------------
alter table public.sessoes
  add column pontos_atividade integer not null default 0 check (pontos_atividade between 0 and 100000);
comment on column public.sessoes.pontos_atividade is
  'Pontos da atividade: o aluno recebe pontos_atividade × nota estimada / 100 quando o gabarito é liberado.';

-- Pontos da atividade de um aluno (0 se a atividade não vale pontos ou o gabarito ainda não saiu).
create or replace function interno.pontos_atividade(p_sessao_id uuid, p_estudante_id uuid)
returns integer
language sql stable security definer set search_path = ''
as $$
  select case
           when s.pontos_atividade > 0
                and exists (select 1 from public.sessoes_participacao p
                             where p.sessao_id = s.id and p.estudante_id = p_estudante_id)
                and interno.simulado_liberado(s.id, p_estudante_id)
           then round(s.pontos_atividade
                      * coalesce((interno.desempenho_simulado(s.id, p_estudante_id)->>'nota')::numeric, 0)
                      / 100)::integer
           else 0 end
    from public.sessoes s
   where s.id = p_sessao_id;
$$;

-- salvar_simulado agora recebe pontos_atividade (pode mudar mesmo depois que
-- alunos iniciaram: a coordenação gerencia a pontuação a qualquer momento).
create or replace function public.salvar_simulado(p_dados jsonb)
returns uuid
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_id        uuid := nullif(p_dados->>'id', '')::uuid;
  v_titulo    text := btrim(coalesce(p_dados->>'titulo', ''));
  v_curso     public.curso := nullif(p_dados->>'curso', '')::public.curso;
  v_inicio    timestamptz := nullif(p_dados->>'inicio', '')::timestamptz;
  v_fim       timestamptz := nullif(p_dados->>'fim', '')::timestamptz;
  v_duracao   integer := nullif(p_dados->>'duracao_minutos', '')::integer;
  v_publicada boolean := coalesce((p_dados->>'publicada')::boolean, false);
  v_valor     integer := coalesce(nullif(p_dados->>'pontos_atividade', '')::integer, 0);
  v_questoes  uuid[];
  v_atual     public.sessoes;
begin
  if not interno.is_gestor() then
    raise exception 'Acesso restrito à coordenação.' using errcode = '42501';
  end if;
  if v_curso is null and not interno.is_admin() then
    raise exception 'Selecione o curso do simulado.';
  end if;
  if not interno.gestor_alcanca_sessao(v_curso) then
    raise exception 'Você não gerencia este curso.' using errcode = '42501';
  end if;
  if char_length(v_titulo) not between 3 and 120 then
    raise exception 'Informe um título entre 3 e 120 caracteres.';
  end if;
  if v_inicio is null or v_fim is null then
    raise exception 'Informe a abertura e o encerramento.';
  end if;
  if v_fim <= v_inicio then
    raise exception 'O encerramento precisa ser depois da abertura.';
  end if;
  if v_duracao is null or v_duracao not between 1 and 600 then
    raise exception 'A duração deve ficar entre 1 e 600 minutos.';
  end if;
  if v_valor not between 0 and 100000 then
    raise exception 'O valor da atividade deve ficar entre 0 e 100000 pontos.';
  end if;

  select coalesce(array_agg(x::uuid order by o), '{}')
    into v_questoes
    from jsonb_array_elements_text(coalesce(p_dados->'questoes', '[]'::jsonb)) with ordinality as t(x, o);

  if v_publicada and cardinality(v_questoes) = 0 then
    raise exception 'Selecione ao menos uma questão para publicar.';
  end if;
  if exists (select 1 from unnest(v_questoes) x
               left join public.questoes q on q.id = x
              where q.id is null or not interno.staff_ve_questao(q.cursos)) then
    raise exception 'Há questões inexistentes ou fora dos seus cursos.';
  end if;

  if v_id is null then
    insert into public.sessoes (tipo, titulo, curso, inicio, fim, duracao_minutos, questoes, publicada, pontos_atividade)
    values ('SIMULADO', v_titulo, v_curso, v_inicio, v_fim, v_duracao, v_questoes, v_publicada, v_valor)
    returning id into v_id;
  else
    select * into v_atual from public.sessoes where id = v_id and tipo = 'SIMULADO' for update;
    if not found then
      raise exception 'Simulado não encontrado.' using errcode = 'P0002';
    end if;
    if not interno.gestor_alcanca_sessao(v_atual.curso) then
      raise exception 'Você não gerencia este simulado.' using errcode = '42501';
    end if;
    update public.sessoes
       set titulo = v_titulo, curso = v_curso, inicio = v_inicio, fim = v_fim,
           duracao_minutos = v_duracao, questoes = v_questoes, publicada = v_publicada,
           pontos_atividade = v_valor
     where id = v_id;
    if v_atual.pontos_atividade <> v_valor then
      perform interno.auditar('VALOR_ATIVIDADE_ALTERADO', 'SESSAO', v_id::text,
                              jsonb_build_object('de', v_atual.pontos_atividade, 'para', v_valor));
    end if;
  end if;
  return v_id;
end;
$$;

-- -----------------------------------------------------------------------------
-- Ajustes de pontuação
-- -----------------------------------------------------------------------------
create table public.ajustes_pontuacao (
  id           bigint generated always as identity primary key,
  estudante_id uuid not null references public.estudantes (id) on delete cascade,
  pontos       integer not null check (pontos <> 0 and pontos between -100000 and 100000),
  motivo       text not null check (char_length(btrim(motivo)) between 3 and 300),
  sessao_id    uuid references public.sessoes (id) on delete set null,
  autor_id     uuid references auth.users (id) on delete set null default auth.uid(),
  criado_em    timestamptz not null default now()
);
create index ajustes_pontuacao_estudante_idx on public.ajustes_pontuacao (estudante_id, criado_em desc);
comment on table public.ajustes_pontuacao is
  'Bônus (positivo) ou desconto (negativo) lançado pela coordenação. Entra no placar.';

alter table public.ajustes_pontuacao enable row level security;
revoke all on public.ajustes_pontuacao from anon, authenticated;
grant select on public.ajustes_pontuacao to authenticated;
create policy ajustes_pontuacao_select on public.ajustes_pontuacao for select to authenticated
  using (estudante_id = auth.uid() or interno.staff_ve_estudante(estudante_id));

create or replace function public.ajustar_pontuacao(
  p_estudante_id uuid, p_pontos integer, p_motivo text, p_sessao_id uuid default null
)
returns bigint
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_est   public.estudantes;
  v_sess  public.sessoes;
  v_motivo text := btrim(coalesce(p_motivo, ''));
  v_id    bigint;
begin
  if not interno.is_gestor() then
    raise exception 'Acesso restrito à coordenação.' using errcode = '42501';
  end if;
  select * into v_est from public.estudantes where id = p_estudante_id;
  if not found or not interno.gestor_alcanca(v_est.curso) then
    raise exception 'Aluno não encontrado nos seus cursos.' using errcode = 'P0002';
  end if;
  if p_pontos is null or p_pontos = 0 or p_pontos not between -100000 and 100000 then
    raise exception 'Informe os pontos (diferente de zero, entre -100000 e 100000).';
  end if;
  if char_length(v_motivo) not between 3 and 300 then
    raise exception 'Informe o motivo do ajuste (3 a 300 caracteres).';
  end if;
  if p_sessao_id is not null then
    select * into v_sess from public.sessoes where id = p_sessao_id;
    if not found or (v_sess.curso is not null and v_sess.curso <> v_est.curso) then
      raise exception 'Atividade inválida para este aluno.';
    end if;
  end if;

  insert into public.ajustes_pontuacao (estudante_id, pontos, motivo, sessao_id)
  values (v_est.id, p_pontos, v_motivo, p_sessao_id)
  returning id into v_id;

  perform interno.auditar('PONTUACAO_AJUSTADA', 'ESTUDANTE', v_est.id::text,
                          jsonb_build_object('ajuste_id', v_id, 'pontos', p_pontos, 'motivo', v_motivo,
                                             'sessao_id', p_sessao_id));
  return v_id;
end;
$$;

create or replace function public.excluir_ajuste_pontuacao(p_id bigint)
returns void
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_aj  public.ajustes_pontuacao;
begin
  if not interno.is_gestor() then
    raise exception 'Acesso restrito à coordenação.' using errcode = '42501';
  end if;
  select a.* into v_aj from public.ajustes_pontuacao a
    join public.estudantes e on e.id = a.estudante_id
   where a.id = p_id and interno.gestor_alcanca(e.curso);
  if not found then
    raise exception 'Ajuste não encontrado.' using errcode = 'P0002';
  end if;
  delete from public.ajustes_pontuacao where id = p_id;
  perform interno.auditar('AJUSTE_PONTUACAO_EXCLUIDO', 'ESTUDANTE', v_aj.estudante_id::text,
                          jsonb_build_object('ajuste_id', v_aj.id, 'pontos', v_aj.pontos, 'motivo', v_aj.motivo));
end;
$$;

-- -----------------------------------------------------------------------------
-- Placar com a origem dos pontos
-- -----------------------------------------------------------------------------
create or replace function interno.placar_detalhado(p_desde timestamptz)
returns table (estudante_id uuid, pontos bigint, pontos_questoes bigint, pontos_atividades bigint,
               pontos_extras bigint, pontos_ajustes bigint, respondidas bigint, objetivas bigint,
               acertos bigint, ultima_atividade timestamptz)
language sql stable security definer set search_path = ''
as $$
  with resp as (
    select r.estudante_id,
           sum(r.pontos_ganhos + coalesce(c.pontos, 0))                           as pontos,
           count(distinct r.questao_id)                                           as respondidas,
           count(*) filter (where r.alternativa is not null and r.tentativa_n = 1) as objetivas,
           count(*) filter (where r.correta and r.tentativa_n = 1)                as acertos,
           max(r.criado_em)                                                       as ultima
      from public.respostas r
      left join public.correcoes_discursivas c on c.resposta_id = r.id
     where r.criado_em >= p_desde
       and (r.sessao_id is null or interno.simulado_liberado(r.sessao_id, r.estudante_id))
     group by r.estudante_id
  ),
  ativ as (
    select p.estudante_id,
           sum(interno.pontos_atividade(s.id, p.estudante_id)) as pontos,
           max(f.fim)                                           as ultima
      from public.sessoes_participacao p
      join public.sessoes s on s.id = p.sessao_id
     cross join lateral (select interno.fim_aluno(s.id, p.estudante_id) as fim) f
     where s.pontos_atividade > 0 and f.fim >= p_desde and now() > f.fim
     group by p.estudante_id
  ),
  extras as (
    select x.estudante_id, sum(x.pontos) as pontos, max(x.criado_em) as ultima
      from public.pontos_extras x
     where x.criado_em >= p_desde
     group by x.estudante_id
  ),
  ajustes as (
    select a.estudante_id, sum(a.pontos) as pontos, max(a.criado_em) as ultima
      from public.ajustes_pontuacao a
     where a.criado_em >= p_desde
     group by a.estudante_id
  )
  select e.id,
         coalesce(resp.pontos, 0) + coalesce(ativ.pontos, 0) + coalesce(extras.pontos, 0)
           + coalesce(ajustes.pontos, 0),
         coalesce(resp.pontos, 0),
         coalesce(ativ.pontos, 0),
         coalesce(extras.pontos, 0),
         coalesce(ajustes.pontos, 0),
         coalesce(resp.respondidas, 0),
         coalesce(resp.objetivas, 0),
         coalesce(resp.acertos, 0),
         greatest(resp.ultima, ativ.ultima, extras.ultima, ajustes.ultima)
    from public.estudantes e
    left join resp    on resp.estudante_id = e.id
    left join ativ    on ativ.estudante_id = e.id
    left join extras  on extras.estudante_id = e.id
    left join ajustes on ajustes.estudante_id = e.id
   where e.status = 'ATIVO';
$$;

create or replace function interno.placar(p_desde timestamptz)
returns table (estudante_id uuid, pontos bigint, respondidas bigint, objetivas bigint, acertos bigint,
               ultima_atividade timestamptz)
language sql stable security definer set search_path = ''
as $$
  select d.estudante_id, d.pontos, d.respondidas, d.objetivas, d.acertos, d.ultima_atividade
    from interno.placar_detalhado(p_desde) d;
$$;

-- Pontuação de todos os alunos do perfil, com a origem dos pontos (tela de gestão).
create or replace function public.pontuacao_equipe(p_curso public.curso default null)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not interno.is_gestor() then
    raise exception 'Acesso restrito à coordenação.' using errcode = '42501';
  end if;
  return (
    select coalesce(jsonb_agg(jsonb_build_object(
             'estudante_id', e.id, 'nome', e.nome, 'curso', e.curso, 'turma', e.turma, 'tipo', e.tipo,
             'pontos', d.pontos, 'pontos_questoes', d.pontos_questoes,
             'pontos_atividades', d.pontos_atividades, 'pontos_extras', d.pontos_extras,
             'pontos_ajustes', d.pontos_ajustes)
             order by d.pontos desc, e.nome), '[]'::jsonb)
      from interno.placar_detalhado('-infinity') d
      join public.estudantes e on e.id = d.estudante_id
     where interno.gestor_alcanca(e.curso) and (p_curso is null or e.curso = p_curso)
  );
end;
$$;

-- Detalhe da pontuação de um aluno: origem dos pontos, atividades e ajustes.
create or replace function public.pontuacao_aluno(p_estudante_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_est public.estudantes;
begin
  select * into v_est from public.estudantes where id = p_estudante_id;
  if not found or not interno.is_gestor() or not interno.gestor_alcanca(v_est.curso) then
    raise exception 'Aluno não encontrado nos seus cursos.' using errcode = 'P0002';
  end if;

  return jsonb_build_object(
    'aluno', jsonb_build_object('id', v_est.id, 'nome', v_est.nome, 'curso', v_est.curso,
                                'turma', v_est.turma, 'tipo', v_est.tipo, 'status', v_est.status),
    'resumo', (select to_jsonb(d) - 'estudante_id' from interno.placar_detalhado('-infinity') d
                where d.estudante_id = v_est.id),
    'atividades', (select coalesce(jsonb_agg(jsonb_build_object(
                     'sessao_id', s.id, 'titulo', s.titulo, 'inicio', s.inicio,
                     'fim', interno.fim_aluno(s.id, v_est.id), 'valor', s.pontos_atividade,
                     'participou', p.sessao_id is not null,
                     'finalizada_em', p.finalizada_em,
                     'liberado', interno.simulado_liberado(s.id, v_est.id),
                     'nota', case when p.sessao_id is not null
                                  then interno.desempenho_simulado(s.id, v_est.id)->'nota' end,
                     'pontos', interno.pontos_atividade(s.id, v_est.id))
                     order by s.fim desc), '[]'::jsonb)
                     from public.sessoes s
                     left join public.sessoes_participacao p on p.sessao_id = s.id and p.estudante_id = v_est.id
                    where s.tipo = 'SIMULADO' and s.publicada and s.pontos_atividade > 0
                      and (s.curso is null or s.curso = v_est.curso)),
    'ajustes', (select coalesce(jsonb_agg(jsonb_build_object(
                  'id', a.id, 'pontos', a.pontos, 'motivo', a.motivo, 'criado_em', a.criado_em,
                  'sessao_id', a.sessao_id, 'sessao_titulo', s.titulo,
                  'autor', coalesce(st.nome, 'Equipe'))
                  order by a.criado_em desc), '[]'::jsonb)
                  from public.ajustes_pontuacao a
                  left join public.sessoes s on s.id = a.sessao_id
                  left join public.staff st on st.user_id = a.autor_id
                 where a.estudante_id = v_est.id)
  );
end;
$$;

-- -----------------------------------------------------------------------------
-- Aluno: valor da atividade na lista e no resultado
-- -----------------------------------------------------------------------------
create or replace function public.meus_simulados()
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_est public.estudantes := interno.estudante_ativo();
begin
  return (
    select coalesce(jsonb_agg(jsonb_build_object(
             'id', s.id, 'titulo', s.titulo, 'curso', s.curso,
             'inicio', s.inicio, 'fim', t.fim, 'duracao_minutos', s.duracao_minutos,
             'total_questoes', cardinality(s.questoes),
             'pontos_atividade', s.pontos_atividade,
             'iniciada_em', p.iniciada_em, 'finalizada_em', p.finalizada_em,
             'termina_em', case when p.sessao_id is not null then t.termina_em end,
             'tentativa', interno.tentativa_atual(s.id, v_est.id),
             'nova_tentativa', p.sessao_id is null
                               and exists (select 1 from public.sessoes_liberacoes l
                                            where l.sessao_id = s.id and l.estudante_id = v_est.id),
             'situacao', case
                when p.sessao_id is null and now() < s.inicio then 'AGENDADO'
                when p.sessao_id is null and now() >= t.fim  then 'PERDIDO'
                when p.sessao_id is null                     then 'DISPONIVEL'
                when p.finalizada_em is null and now() < t.termina_em then 'EM_ANDAMENTO'
                else 'CONCLUIDO' end,
             'gabarito_liberado', now() > t.fim
           ) order by s.inicio desc), '[]'::jsonb)
      from public.sessoes s
      left join public.sessoes_participacao p on p.sessao_id = s.id and p.estudante_id = v_est.id
      cross join lateral (select interno.fim_aluno(s.id, v_est.id) as fim) f
      cross join lateral (select f.fim,
                                 least(f.fim, p.iniciada_em + make_interval(mins => s.duracao_minutos)) as termina_em) t
     where s.publicada and s.tipo = 'SIMULADO' and (s.curso is null or s.curso = v_est.curso)
  );
end;
$$;

-- resultado_simulado ganha o valor da atividade e os pontos obtidos nela
-- (envolve a versão anterior para não duplicar a lógica de liberação).
alter function public.resultado_simulado(uuid) rename to resultado_simulado_base;
revoke all on function public.resultado_simulado_base(uuid) from public, anon, authenticated;
alter function public.resultado_simulado_base(uuid) set schema interno;

create or replace function public.resultado_simulado(p_sessao_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_est public.estudantes := interno.estudante_ativo();
  v_res jsonb := interno.resultado_simulado_base(p_sessao_id);
begin
  return v_res || jsonb_build_object(
    'pontos_atividade', (select s.pontos_atividade from public.sessoes s where s.id = p_sessao_id),
    'pontos_atividade_obtidos', case when (v_res->>'gabarito_liberado')::boolean
                                     then interno.pontos_atividade(p_sessao_id, v_est.id) end
  );
end;
$$;

-- -----------------------------------------------------------------------------
-- Privilégios
-- -----------------------------------------------------------------------------
revoke all on function interno.pontos_atividade(uuid, uuid), interno.placar_detalhado(timestamptz)
  from public, anon, authenticated;
revoke all on function public.ajustar_pontuacao(uuid, integer, text, uuid),
                       public.excluir_ajuste_pontuacao(bigint),
                       public.pontuacao_equipe(public.curso),
                       public.pontuacao_aluno(uuid),
                       public.resultado_simulado(uuid)
  from public, anon;
grant execute on function public.ajustar_pontuacao(uuid, integer, text, uuid),
                          public.excluir_ajuste_pontuacao(bigint),
                          public.pontuacao_equipe(public.curso),
                          public.pontuacao_aluno(uuid),
                          public.resultado_simulado(uuid)
  to authenticated;
