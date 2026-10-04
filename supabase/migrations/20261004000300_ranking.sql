-- =============================================================================
-- Migration 11: Classificação (ranking) de alunos
--
--   * Pontos = respostas (objetivas pontuadas + discursivas corrigidas)
--     + pontos extras (ex.: diagnóstico inicial). Só alunos ATIVOS.
--   * Pontos de simulado só contam depois que o gabarito é liberado ao aluno:
--     antes disso, ver o total subir revelaria o acerto durante a prova.
--     (Corrige também meu_resumo, que somava esses pontos na hora.)
--   * Aluno vê o próprio curso, a própria turma ou todos os cursos, com nome
--     abreviado dos colegas ("Maria S."). A equipe vê nomes completos e
--     indicadores, só dos alunos dos cursos do seu perfil.
--   * Empate divide a posição (rank).
-- =============================================================================

create or replace function interno.inicio_periodo(p_periodo text)
returns timestamptz
language sql stable
as $$
  select case upper(coalesce(p_periodo, 'TOTAL'))
           when 'SEMANA' then now() - interval '7 days'
           when 'MES'    then now() - interval '30 days'
           else '-infinity'::timestamptz end;
$$;

-- Placar de todos os alunos ativos a partir de p_desde.
create or replace function interno.placar(p_desde timestamptz)
returns table (estudante_id uuid, pontos bigint, respondidas bigint, objetivas bigint, acertos bigint,
               ultima_atividade timestamptz)
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
  extras as (
    select x.estudante_id, sum(x.pontos) as pontos, max(x.criado_em) as ultima
      from public.pontos_extras x
     where x.criado_em >= p_desde
     group by x.estudante_id
  )
  select e.id,
         coalesce(resp.pontos, 0) + coalesce(extras.pontos, 0),
         coalesce(resp.respondidas, 0),
         coalesce(resp.objetivas, 0),
         coalesce(resp.acertos, 0),
         greatest(resp.ultima, extras.ultima)
    from public.estudantes e
    left join resp   on resp.estudante_id = e.id
    left join extras on extras.estudante_id = e.id
   where e.status = 'ATIVO';
$$;

-- "Maria Souza Lima" → "Maria L."
create or replace function interno.nome_abreviado(p_nome text)
returns text
language sql immutable
as $$
  select case when btrim(p_nome) ~ '\s'
              then split_part(btrim(p_nome), ' ', 1) || ' ' || left(regexp_replace(btrim(p_nome), '^.*\s', ''), 1) || '.'
              else btrim(p_nome) end;
$$;

-- Classificação vista pelo aluno. p_escopo: CURSO | TURMA | GERAL.
create or replace function public.ranking_aluno(p_escopo text default 'CURSO', p_periodo text default 'TOTAL')
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_est    public.estudantes := interno.estudante_ativo();
  v_escopo text := upper(coalesce(p_escopo, 'CURSO'));
begin
  if v_escopo not in ('CURSO', 'TURMA', 'GERAL') then
    raise exception 'Escopo inválido.' using errcode = '22023';
  end if;

  return (
    with base as (
      select p.*, e.nome, e.curso, e.turma
        from interno.placar(interno.inicio_periodo(p_periodo)) p
        join public.estudantes e on e.id = p.estudante_id
       where v_escopo = 'GERAL'
          or (e.curso = v_est.curso and (v_escopo = 'CURSO' or e.turma = v_est.turma))
    ),
    rk as (
      select b.*, rank() over (order by b.pontos desc) as posicao
        from base b where b.pontos > 0
    )
    select jsonb_build_object(
      'escopo', v_escopo,
      'periodo', upper(coalesce(p_periodo, 'TOTAL')),
      'participantes', (select count(*) from rk),
      'eu', (select jsonb_build_object('posicao', rk.posicao, 'pontos', b.pontos, 'respondidas', b.respondidas,
                                       'acertos', b.acertos, 'objetivas', b.objetivas)
               from base b left join rk on rk.estudante_id = b.estudante_id
              where b.estudante_id = v_est.id),
      'lideres', (select coalesce(jsonb_agg(jsonb_build_object(
                    'posicao', rk.posicao,
                    'nome', interno.nome_abreviado(rk.nome),
                    'curso', rk.curso,
                    'turma', rk.turma,
                    'pontos', rk.pontos,
                    'eu', rk.estudante_id = v_est.id) order by rk.posicao, rk.nome), '[]'::jsonb)
                    from rk where rk.posicao <= 50)
    )
  );
end;
$$;

-- Classificação para a equipe: todos os alunos dos cursos do perfil, com indicadores.
create or replace function public.ranking_equipe(
  p_curso public.curso default null, p_turma text default null,
  p_tipo public.tipo_estudante default null, p_periodo text default 'TOTAL'
)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not interno.is_staff() then
    raise exception 'Acesso restrito à equipe.' using errcode = '42501';
  end if;

  return (
    with base as (
      select p.*, e.nome, e.curso, e.turma, e.tipo, e.email_pessoal
        from interno.placar(interno.inicio_periodo(p_periodo)) p
        join public.estudantes e on e.id = p.estudante_id
       where interno.staff_alcanca(e.curso)
         and (p_curso is null or e.curso = p_curso)
         and (nullif(btrim(p_turma), '') is null or e.turma = upper(btrim(p_turma)))
         and (p_tipo is null or e.tipo = p_tipo)
    ),
    rk as (
      select b.*, case when b.pontos > 0 then rank() over (order by b.pontos desc) end as posicao,
             (select count(*) from public.sessoes_participacao sp
               where sp.estudante_id = b.estudante_id and sp.finalizada_em is not null) as simulados
        from base b
    )
    select jsonb_build_object(
      'alunos', (select coalesce(jsonb_agg(jsonb_build_object(
                   'estudante_id', rk.estudante_id, 'posicao', rk.posicao, 'nome', rk.nome,
                   'email', rk.email_pessoal, 'curso', rk.curso, 'turma', rk.turma, 'tipo', rk.tipo,
                   'pontos', rk.pontos, 'respondidas', rk.respondidas, 'objetivas', rk.objetivas,
                   'acertos', rk.acertos, 'simulados', rk.simulados, 'ultima_atividade', rk.ultima_atividade)
                   order by rk.pontos desc, rk.nome), '[]'::jsonb) from rk),
      'turmas', (select coalesce(jsonb_agg(distinct e.turma order by e.turma), '[]'::jsonb)
                   from public.estudantes e
                  where interno.staff_alcanca(e.curso) and (p_curso is null or e.curso = p_curso))
    )
  );
end;
$$;

-- Resumo do perfil: mesma regra de pontos do placar.
create or replace function public.meu_resumo()
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_est public.estudantes := interno.estudante_ativo();
begin
  return jsonb_build_object(
    'pontos', (select p.pontos from interno.placar('-infinity') p where p.estudante_id = v_est.id),
    'questoes_respondidas', (select count(distinct questao_id) from public.respostas where estudante_id = v_est.id),
    'conquistas', (select coalesce(jsonb_agg(jsonb_build_object(
                      'codigo', c.codigo, 'nome', c.nome, 'descricao', c.descricao, 'icone', c.icone,
                      'obtida_em', ce.obtida_em) order by c.ordem), '[]'::jsonb)
                     from public.conquistas_estudante ce
                     join public.conquistas c on c.codigo = ce.conquista
                    where ce.estudante_id = v_est.id),
    'diagnostico', interno.diagnostico_estado(v_est.id)
  );
end;
$$;

revoke all on function interno.placar(timestamptz), interno.inicio_periodo(text), interno.nome_abreviado(text)
  from public, anon, authenticated;
revoke all on function public.ranking_aluno(text, text),
                       public.ranking_equipe(public.curso, text, public.tipo_estudante, text),
                       public.meu_resumo()
  from public, anon;
grant execute on function public.ranking_aluno(text, text),
                          public.ranking_equipe(public.curso, text, public.tipo_estudante, text),
                          public.meu_resumo()
  to authenticated;
