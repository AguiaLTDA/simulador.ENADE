-- =============================================================================
-- Migration 9: Simulados cronometrados — gestão por curso, resultado e relatórios
--
--   * Coordenador cria simulados dos seus cursos; o ADMIN também cria simulados
--     abertos a todos os cursos (que só aceitam questões de Formação Geral).
--   * Toda questão do simulado precisa valer para o curso do simulado.
--   * Depois que um aluno iniciou, questões/curso/duração/abertura não mudam
--     (título e encerramento ainda podem ser ajustados).
--   * Gabarito e acerto questão a questão só são liberados ao aluno quando a
--     janela do simulado fecha para todos (sessoes.fim): quem termina cedo não
--     consegue repassar respostas a quem ainda vai fazer a prova. A nota geral
--     sai assim que ele finaliza.
--   * Nota estimada no formato ENADE: FG 25% (objetivas 60%, discursivas 40%)
--     + CE 75% (objetivas 85%, discursivas 15%), escala 0–100.
--   * Concluir respondendo todas as questões dá a conquista SIMULADO_COMPLETO.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Liberação do gabarito
-- -----------------------------------------------------------------------------
create or replace function interno.simulado_liberado(p_sessao_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.sessoes s where s.id = p_sessao_id and now() > s.fim);
$$;

drop policy respostas_select on public.respostas;
create policy respostas_select on public.respostas for select to authenticated
  using (
    interno.staff_ve_estudante(estudante_id)
    or (estudante_id = auth.uid() and (sessao_id is null or interno.simulado_liberado(sessao_id)))
  );

drop policy correcoes_select on public.correcoes_discursivas;
create policy correcoes_select on public.correcoes_discursivas for select to authenticated
  using (exists (select 1 from public.respostas r
                  where r.id = resposta_id
                    and (interno.staff_ve_estudante(r.estudante_id)
                         or (r.estudante_id = auth.uid()
                             and (r.sessao_id is null or interno.simulado_liberado(r.sessao_id))))));

-- Devolutiva: respostas de simulado só entram depois que a janela fechou.
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
       select 1 from public.respostas r
        where r.estudante_id = v_est.id and r.questao_id = p_questao_id
          and (r.sessao_id is null or interno.simulado_liberado(r.sessao_id))) then
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
                   where r.estudante_id = v_est.id and r.questao_id = p_questao_id
                     and (r.sessao_id is null or interno.simulado_liberado(r.sessao_id)))
  );
end;
$$;

-- -----------------------------------------------------------------------------
-- Validação do simulado
-- -----------------------------------------------------------------------------
create or replace function interno.tg_sessoes_valida()
returns trigger
language plpgsql security definer set search_path = ''
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
    if exists (
         select 1 from unnest(new.questoes) x
           join public.questoes q on q.id = x
          where not ('ALL' = any (q.cursos)
                     or (new.curso is not null and new.curso::text::public.curso_alvo = any (q.cursos)))) then
      raise exception '%', case when new.curso is null
          then 'Simulado aberto a todos os cursos aceita apenas questões de Formação Geral.'
          else 'Há questões que não valem para o curso do simulado.' end
        using errcode = '23514';
    end if;
  end if;

  if tg_op = 'UPDATE' and exists (select 1 from public.sessoes_participacao p where p.sessao_id = old.id) then
    if new.questoes is distinct from old.questoes
       or new.curso is distinct from old.curso
       or new.duracao_minutos is distinct from old.duracao_minutos
       or new.inicio is distinct from old.inicio
       or new.tipo is distinct from old.tipo
       or not new.publicada then
      raise exception 'Este simulado já foi iniciado por alunos: só o título e o encerramento podem mudar.'
        using errcode = '23514';
    end if;
  end if;
  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- Políticas de sessoes com escopo por curso
-- -----------------------------------------------------------------------------
drop policy sessoes_select       on public.sessoes;
drop policy sessoes_admin_insert on public.sessoes;
drop policy sessoes_admin_update on public.sessoes;
drop policy sessoes_admin_delete on public.sessoes;

create or replace function interno.gestor_alcanca_sessao(p_curso public.curso)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select interno.is_admin() or (p_curso is not null and interno.gestor_alcanca(p_curso));
$$;

create policy sessoes_select on public.sessoes for select to authenticated
  using (
    (interno.is_staff() and (curso is null or interno.staff_alcanca(curso)))
    or (publicada and (curso is null or curso = (select e.curso from public.estudantes e where e.id = auth.uid())))
  );
create policy sessoes_gestor_insert on public.sessoes for insert to authenticated
  with check (interno.gestor_alcanca_sessao(curso));
create policy sessoes_gestor_update on public.sessoes for update to authenticated
  using (interno.gestor_alcanca_sessao(curso)) with check (interno.gestor_alcanca_sessao(curso));
create policy sessoes_gestor_delete on public.sessoes for delete to authenticated
  using (interno.gestor_alcanca_sessao(curso));

-- -----------------------------------------------------------------------------
-- Desempenho de um aluno num simulado (nota estimada no formato ENADE)
-- Questão não respondida conta como erro / nota zero.
-- -----------------------------------------------------------------------------
create or replace function interno.desempenho_simulado(p_sessao_id uuid, p_estudante_id uuid)
returns jsonb
language sql stable security definer set search_path = ''
as $$
  with itens as (
    select q.componente, q.formato, r.id as resposta_id, r.correta, c.nota,
           coalesce(r.pontos_ganhos, 0) + coalesce(c.pontos, 0) as pontos
      from public.sessoes s
     cross join unnest(s.questoes) as x(id)
      join public.questoes q on q.id = x.id
      left join public.respostas r
             on r.sessao_id = s.id and r.estudante_id = p_estudante_id and r.questao_id = q.id
      left join public.correcoes_discursivas c on c.resposta_id = r.id
     where s.id = p_sessao_id
  ),
  comp as (
    select componente,
           count(*) filter (where formato = 'OBJETIVA')                                    as obj_total,
           count(*) filter (where formato = 'OBJETIVA' and correta)                        as obj_acertos,
           count(*) filter (where formato = 'DISCURSIVA')                                  as disc_total,
           count(*) filter (where formato = 'DISCURSIVA' and resposta_id is not null and nota is null) as disc_pendentes,
           coalesce(sum(nota) filter (where formato = 'DISCURSIVA'), 0)                    as disc_soma,
           case componente when 'FG' then 0.60 else 0.85 end                               as peso_obj,
           case componente when 'FG' then 0.40 else 0.15 end                               as peso_disc,
           case componente when 'FG' then 0.25 else 0.75 end                               as peso_comp
      from itens
     group by componente
  ),
  nota_comp as (
    select *,
           ( case when obj_total  > 0 then peso_obj  * 100.0 * obj_acertos / obj_total else 0 end
           + case when disc_total > 0 then peso_disc * disc_soma / disc_total          else 0 end )
           / nullif(case when obj_total > 0 then peso_obj else 0 end
                  + case when disc_total > 0 then peso_disc else 0 end, 0) as nota
      from comp
  )
  select jsonb_build_object(
    'componentes', coalesce(jsonb_object_agg(componente, jsonb_build_object(
                     'obj_total', obj_total, 'obj_acertos', obj_acertos,
                     'disc_total', disc_total, 'disc_pendentes', disc_pendentes,
                     'nota', round(nota, 1))), '{}'::jsonb),
    'nota',        round(sum(nota * peso_comp) / nullif(sum(peso_comp), 0), 1),
    'pendentes',   coalesce(sum(disc_pendentes), 0),
    'respondidas', (select count(resposta_id) from itens),
    'total',       (select count(*) from itens),
    'pontos',      (select coalesce(sum(pontos), 0) from itens)
  )
  from nota_comp;
$$;

-- -----------------------------------------------------------------------------
-- RPCs da coordenação
-- -----------------------------------------------------------------------------

-- Cria ou atualiza um simulado. Retorna o id.
-- p_dados: { id?, titulo, curso (null = todos), inicio, fim, duracao_minutos, questoes[], publicada }
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
    insert into public.sessoes (tipo, titulo, curso, inicio, fim, duracao_minutos, questoes, publicada)
    values ('SIMULADO', v_titulo, v_curso, v_inicio, v_fim, v_duracao, v_questoes, v_publicada)
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
           duracao_minutos = v_duracao, questoes = v_questoes, publicada = v_publicada
     where id = v_id;
  end if;
  return v_id;
end;
$$;

create or replace function public.excluir_simulado(p_id uuid)
returns void
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_s public.sessoes;
begin
  select * into v_s from public.sessoes where id = p_id;
  if not found then
    raise exception 'Simulado não encontrado.' using errcode = 'P0002';
  end if;
  if not interno.gestor_alcanca_sessao(v_s.curso) then
    raise exception 'Você não gerencia este simulado.' using errcode = '42501';
  end if;
  if exists (select 1 from public.sessoes_participacao where sessao_id = p_id) then
    raise exception 'Este simulado já tem participações e não pode ser excluído.';
  end if;
  delete from public.sessoes where id = p_id;
end;
$$;

-- Relatório do simulado para a equipe (só os alunos dos cursos do perfil).
create or replace function public.relatorio_simulado(p_sessao_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_s public.sessoes;
begin
  select * into v_s from public.sessoes where id = p_sessao_id and tipo = 'SIMULADO';
  if not found or not interno.is_staff()
     or (v_s.curso is not null and not interno.staff_alcanca(v_s.curso)) then
    raise exception 'Simulado não encontrado.' using errcode = 'P0002';
  end if;

  return jsonb_build_object(
    'sessao', jsonb_build_object(
      'id', v_s.id, 'titulo', v_s.titulo, 'curso', v_s.curso, 'inicio', v_s.inicio, 'fim', v_s.fim,
      'duracao_minutos', v_s.duracao_minutos, 'publicada', v_s.publicada),
    'elegiveis', (select count(*) from public.estudantes e
                   where e.status = 'ATIVO' and (v_s.curso is null or e.curso = v_s.curso)
                     and interno.staff_alcanca(e.curso)),
    'questoes', (select coalesce(jsonb_agg(jsonb_build_object(
                   'numero', x.ord, 'id', q.id, 'componente', q.componente, 'eixo', q.eixo,
                   'formato', q.formato, 'dificuldade', q.dificuldade, 'enunciado', q.enunciado,
                   'gabarito', g.gabarito,
                   'respostas', (select jsonb_build_object(
                                   'total', count(r.id),
                                   'acertos', count(r.id) filter (where r.correta),
                                   'A', count(*) filter (where r.alternativa = 'A'),
                                   'B', count(*) filter (where r.alternativa = 'B'),
                                   'C', count(*) filter (where r.alternativa = 'C'),
                                   'D', count(*) filter (where r.alternativa = 'D'),
                                   'E', count(*) filter (where r.alternativa = 'E'),
                                   'corrigidas', count(c.resposta_id),
                                   'nota_media', round(avg(c.nota), 1))
                                  from public.respostas r
                                  left join public.correcoes_discursivas c on c.resposta_id = r.id
                                 where r.sessao_id = v_s.id and r.questao_id = q.id
                                   and interno.staff_ve_estudante(r.estudante_id))
                 ) order by x.ord), '[]'::jsonb)
                   from unnest(v_s.questoes) with ordinality as x(id, ord)
                   join public.questoes q on q.id = x.id
                   left join public.questoes_gabarito g on g.questao_id = q.id),
    'participantes', (select coalesce(jsonb_agg(jsonb_build_object(
                        'estudante_id', e.id, 'nome', e.nome, 'curso', e.curso, 'turma', e.turma, 'tipo', e.tipo,
                        'iniciada_em', p.iniciada_em, 'finalizada_em', p.finalizada_em,
                        'encerrado', interno.simulado_encerrado(v_s.id, e.id),
                        'desempenho', interno.desempenho_simulado(v_s.id, e.id)
                      ) order by e.nome), '[]'::jsonb)
                        from public.sessoes_participacao p
                        join public.estudantes e on e.id = p.estudante_id
                       where p.sessao_id = v_s.id and interno.staff_ve_estudante(e.id))
  );
end;
$$;

-- -----------------------------------------------------------------------------
-- RPCs do aluno
-- -----------------------------------------------------------------------------

-- Simulados do curso do aluno, com a situação dele em cada um.
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
             'inicio', s.inicio, 'fim', s.fim, 'duracao_minutos', s.duracao_minutos,
             'total_questoes', cardinality(s.questoes),
             'iniciada_em', p.iniciada_em, 'finalizada_em', p.finalizada_em,
             'termina_em', case when p.sessao_id is not null then t.termina_em end,
             'situacao', case
                when p.sessao_id is null and now() < s.inicio then 'AGENDADO'
                when p.sessao_id is null and now() >= s.fim  then 'PERDIDO'
                when p.sessao_id is null                     then 'DISPONIVEL'
                when p.finalizada_em is null and now() < t.termina_em then 'EM_ANDAMENTO'
                else 'CONCLUIDO' end,
             'gabarito_liberado', now() > s.fim
           ) order by s.inicio desc), '[]'::jsonb)
      from public.sessoes s
      left join public.sessoes_participacao p on p.sessao_id = s.id and p.estudante_id = v_est.id
      cross join lateral (select least(s.fim, p.iniciada_em + make_interval(mins => s.duracao_minutos)) as termina_em) t
     where s.publicada and s.tipo = 'SIMULADO' and (s.curso is null or s.curso = v_est.curso)
  );
end;
$$;

-- Finaliza; quem respondeu todas as questões ganha a conquista "Até o fim".
create or replace function public.finalizar_simulado(p_sessao_id uuid)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_est       public.estudantes := interno.estudante_ativo();
  v_part      public.sessoes_participacao;
  v_completo  boolean;
begin
  update public.sessoes_participacao
     set finalizada_em = clock_timestamp()
   where sessao_id = p_sessao_id and estudante_id = v_est.id and finalizada_em is null
  returning * into v_part;
  if not found then
    raise exception 'Nenhum simulado em andamento para finalizar.' using hint = 'SEM_PARTICIPACAO';
  end if;

  select (select count(*) from public.respostas r
           where r.sessao_id = s.id and r.estudante_id = v_est.id) >= cardinality(s.questoes)
    into v_completo
    from public.sessoes s where s.id = p_sessao_id;

  if v_completo then
    insert into public.conquistas_estudante (estudante_id, conquista)
    values (v_est.id, 'SIMULADO_COMPLETO')
    on conflict do nothing;
  end if;

  return jsonb_build_object('sessao_id', p_sessao_id, 'finalizada_em', v_part.finalizada_em,
                            'completo', v_completo);
end;
$$;

-- Resultado do aluno. Detalhe por questão (gabarito, acerto, correção) só
-- depois que a janela do simulado fecha para todos.
create or replace function public.resultado_simulado(p_sessao_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_est  public.estudantes := interno.estudante_ativo();
  v_s    public.sessoes;
  v_part public.sessoes_participacao;
  v_lib  boolean;
begin
  select * into v_s from public.sessoes where id = p_sessao_id and publicada and tipo = 'SIMULADO';
  if not found or (v_s.curso is not null and v_s.curso <> v_est.curso) then
    raise exception 'Simulado indisponível.' using errcode = 'P0002';
  end if;
  select * into v_part from public.sessoes_participacao where sessao_id = v_s.id and estudante_id = v_est.id;
  if not found then
    raise exception 'Você não participou deste simulado.' using hint = 'SEM_PARTICIPACAO';
  end if;
  if not interno.simulado_encerrado(v_s.id, v_est.id) then
    raise exception 'Finalize o simulado para ver o resultado.' using hint = 'SIMULADO_EM_ANDAMENTO';
  end if;
  v_lib := now() > v_s.fim;

  return jsonb_build_object(
    'sessao', jsonb_build_object('id', v_s.id, 'titulo', v_s.titulo, 'curso', v_s.curso,
                                 'inicio', v_s.inicio, 'fim', v_s.fim, 'duracao_minutos', v_s.duracao_minutos),
    'iniciada_em',   v_part.iniciada_em,
    'finalizada_em', coalesce(v_part.finalizada_em,
                              least(v_s.fim, v_part.iniciada_em + make_interval(mins => v_s.duracao_minutos))),
    'gabarito_liberado', v_lib,
    'desempenho', interno.desempenho_simulado(v_s.id, v_est.id),
    'media_participantes', case when v_lib then
        (select round(avg((interno.desempenho_simulado(v_s.id, p.estudante_id)->>'nota')::numeric), 1)
           from public.sessoes_participacao p where p.sessao_id = v_s.id) end,
    'participantes', (select count(*) from public.sessoes_participacao p where p.sessao_id = v_s.id),
    'questoes', case when v_lib then
        (select jsonb_agg(interno.questao_json(q) || jsonb_build_object(
                  'numero', x.ord, 'gabarito', g.gabarito, 'justificativa', g.justificativa,
                  'alternativa', r.alternativa, 'resposta_texto', r.resposta_texto, 'correta', r.correta,
                  'nota', c.nota, 'comentario', c.comentario, 'tempo_segundos', r.tempo_segundos,
                  'pontos', coalesce(r.pontos_ganhos, 0) + coalesce(c.pontos, 0))
                order by x.ord)
           from unnest(v_s.questoes) with ordinality as x(id, ord)
           join public.questoes q on q.id = x.id
           left join public.questoes_gabarito g on g.questao_id = q.id
           left join public.respostas r on r.sessao_id = v_s.id and r.estudante_id = v_est.id and r.questao_id = q.id
           left join public.correcoes_discursivas c on c.resposta_id = r.id) end
  );
end;
$$;

-- -----------------------------------------------------------------------------
-- Privilégios
-- -----------------------------------------------------------------------------
revoke all on function interno.desempenho_simulado(uuid, uuid) from public, anon, authenticated;
grant execute on function interno.simulado_liberado(uuid)                 to authenticated;
grant execute on function interno.gestor_alcanca_sessao(public.curso)    to authenticated;

revoke all on function public.salvar_simulado(jsonb), public.excluir_simulado(uuid),
                       public.relatorio_simulado(uuid), public.meus_simulados(),
                       public.resultado_simulado(uuid), public.finalizar_simulado(uuid),
                       public.devolutiva_questao(uuid)
  from public, anon;
grant execute on function public.salvar_simulado(jsonb), public.excluir_simulado(uuid),
                          public.relatorio_simulado(uuid), public.meus_simulados(),
                          public.resultado_simulado(uuid), public.finalizar_simulado(uuid),
                          public.devolutiva_questao(uuid)
  to authenticated;
