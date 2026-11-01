-- =============================================================================
-- Migration 13: diagnóstico inicial com no máximo 20 questões
--
--   * 20 ativas: Português 7 · Conhecimentos gerais 6 · Matemática e raciocínio
--     lógico 7. As outras 10 ficam inativas (não são apagadas: alunos que já
--     concluíram mantêm o resultado e as respostas).
--   * Trigger impede mais de 20 questões ativas.
--   * Quem estava no meio do diagnóstico e já respondeu todas as 20 que ficaram
--     é concluído ao reabrir o diagnóstico (antes só concluía ao responder).
-- =============================================================================

update public.diagnostico_questoes
   set ativa = false
 where (area = 'PORTUGUES'   and ordem in (4, 6, 8))
    or (area = 'ATUALIDADES' and ordem in (5, 6, 8, 9))
    or (area = 'MATEMATICA'  and ordem in (2, 5, 10));

create or replace function interno.tg_diagnostico_limite()
returns trigger
language plpgsql
as $$
begin
  if (select count(*) from public.diagnostico_questoes where ativa) > 20 then
    raise exception 'O diagnóstico inicial pode ter no máximo 20 questões ativas.' using errcode = '23514';
  end if;
  return null;
end;
$$;

create trigger diagnostico_limite
  after insert or update of ativa on public.diagnostico_questoes
  for each statement execute function interno.tg_diagnostico_limite();

-- Conclusão: nível por área (visível só à equipe), badge e pontos de participação.
create or replace function interno.concluir_diagnostico(p_estudante uuid)
returns integer
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_pontos integer;
  v_result jsonb;
begin
  select jsonb_object_agg(area, jsonb_build_object(
           'acertos', acertos, 'total', total,
           'percentual', round(100.0 * acertos / total, 1),
           'nivel', interno.nivel_diagnostico(100.0 * acertos / total)))
    into v_result
    from (select q.area::text as area,
                 count(*) filter (where r.correta) as acertos,
                 count(*) as total
            from public.diagnostico_questoes q
            join public.diagnostico_respostas r on r.questao_id = q.id and r.estudante_id = p_estudante
           where q.ativa
           group by q.area) t;

  v_pontos := round(interno.cfg_num('pontos_diagnostico'))::integer;

  update public.diagnostico_resultados
     set concluido_em = clock_timestamp(),
         resultado    = v_result,
         acertos      = (select sum((x.value->>'acertos')::int) from jsonb_each(v_result) x),
         total        = (select sum((x.value->>'total')::int) from jsonb_each(v_result) x),
         pontos       = v_pontos
   where estudante_id = p_estudante;

  insert into public.pontos_extras (estudante_id, origem, pontos)
  values (p_estudante, 'DIAGNOSTICO_INICIAL', v_pontos)
  on conflict (estudante_id, origem) do nothing;

  insert into public.conquistas_estudante (estudante_id, conquista)
  values (p_estudante, 'DIAGNOSTICO_INICIAL')
  on conflict do nothing;

  return v_pontos;
end;
$$;

create or replace function public.iniciar_diagnostico()
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_est    public.estudantes := interno.estudante_ativo();
  v_estado jsonb;
begin
  perform pg_advisory_xact_lock(hashtextextended('diag:' || v_est.id::text, 0));

  if not exists (select 1 from public.diagnostico_resultados where estudante_id = v_est.id and concluido_em is not null) then
    insert into public.diagnostico_resultados (estudante_id) values (v_est.id)
    on conflict (estudante_id) do nothing;

    v_estado := interno.diagnostico_estado(v_est.id);
    if (v_estado->>'total')::int > 0 and (v_estado->>'respondidas')::int >= (v_estado->>'total')::int then
      perform interno.concluir_diagnostico(v_est.id);
    end if;
  end if;

  if exists (select 1 from public.diagnostico_resultados where estudante_id = v_est.id and concluido_em is not null) then
    return interno.diagnostico_estado(v_est.id) || jsonb_build_object('questoes', '[]'::jsonb, 'respondidas_ids', '[]'::jsonb);
  end if;

  return interno.diagnostico_estado(v_est.id) || jsonb_build_object(
    'questoes', (select coalesce(jsonb_agg(jsonb_build_object(
                    'id', q.id, 'area', q.area, 'texto_apoio', q.texto_apoio, 'enunciado', q.enunciado,
                    'alternativas', jsonb_build_object('A', q.alt_a, 'B', q.alt_b, 'C', q.alt_c, 'D', q.alt_d, 'E', q.alt_e))
                  order by q.area, q.ordem), '[]'::jsonb)
                   from public.diagnostico_questoes q where q.ativa),
    'respondidas_ids', (select coalesce(jsonb_agg(r.questao_id), '[]'::jsonb)
                          from public.diagnostico_respostas r
                          join public.diagnostico_questoes q on q.id = r.questao_id and q.ativa
                         where r.estudante_id = v_est.id)
  );
end;
$$;

create or replace function public.responder_diagnostico(p_questao_id uuid, p_alternativa text)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_est     public.estudantes := interno.estudante_ativo();
  v_alt     text := upper(nullif(btrim(coalesce(p_alternativa, '')), ''));
  v_gab     text;
  v_estado  jsonb;
  v_pontos  integer;
begin
  perform pg_advisory_xact_lock(hashtextextended('diag:' || v_est.id::text, 0));

  if not exists (select 1 from public.diagnostico_resultados where estudante_id = v_est.id) then
    raise exception 'Inicie o diagnóstico antes de responder.' using hint = 'DIAGNOSTICO_NAO_INICIADO';
  end if;
  if exists (select 1 from public.diagnostico_resultados where estudante_id = v_est.id and concluido_em is not null) then
    raise exception 'Você já concluiu o diagnóstico.' using hint = 'DIAGNOSTICO_CONCLUIDO';
  end if;
  if v_alt is null or v_alt not in ('A', 'B', 'C', 'D', 'E') then
    raise exception 'Alternativa inválida.' using errcode = '22023';
  end if;

  select g.gabarito into v_gab
    from public.diagnostico_questoes q
    join public.diagnostico_gabarito g on g.questao_id = q.id
   where q.id = p_questao_id and q.ativa;
  if v_gab is null then
    raise exception 'Questão indisponível.' using errcode = 'P0002';
  end if;
  if exists (select 1 from public.diagnostico_respostas where estudante_id = v_est.id and questao_id = p_questao_id) then
    raise exception 'Questão já respondida.' using hint = 'JA_RESPONDIDA';
  end if;

  insert into public.diagnostico_respostas (estudante_id, questao_id, alternativa, correta, criado_em)
  values (v_est.id, p_questao_id, v_alt, v_alt = v_gab, clock_timestamp());

  v_estado := interno.diagnostico_estado(v_est.id);
  if (v_estado->>'respondidas')::int < (v_estado->>'total')::int then
    return jsonb_build_object('registrada', true, 'concluido', false,
                              'respondidas', v_estado->'respondidas', 'total', v_estado->'total');
  end if;

  v_pontos := interno.concluir_diagnostico(v_est.id);
  return jsonb_build_object('registrada', true, 'concluido', true,
                            'respondidas', v_estado->'respondidas', 'total', v_estado->'total',
                            'pontos', v_pontos, 'conquista', 'DIAGNOSTICO_INICIAL');
end;
$$;

revoke all on function interno.concluir_diagnostico(uuid), interno.tg_diagnostico_limite() from public, anon, authenticated;
revoke all on function public.iniciar_diagnostico(), public.responder_diagnostico(uuid, text) from public, anon;
grant execute on function public.iniciar_diagnostico(), public.responder_diagnostico(uuid, text) to authenticated;
