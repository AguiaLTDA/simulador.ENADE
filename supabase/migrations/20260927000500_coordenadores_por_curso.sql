-- =============================================================================
-- Migration 8: coordenadores com escopo por curso + convites da equipe
--
--   ADMIN       → administração geral: todos os cursos, equipe e configuração.
--   COORDENADOR → alunos, resultados e questões apenas dos cursos em staff.cursos.
--                 Questões de Formação Geral (compartilhadas): qualquer
--                 coordenador cria; só o autor ou o ADMIN edita/exclui.
--   DOCENTE     → leitura e correção de discursivas dos cursos em staff.cursos.
-- =============================================================================

alter table public.staff add column cursos public.curso[];

update public.staff set cursos = enum_range(null::public.curso)
 where papel <> 'ADMIN' and cursos is null;

alter table public.staff
  add constraint staff_escopo_coerente check (
    case when papel = 'ADMIN' then cursos is null
         else cursos is not null and cardinality(cursos) >= 1 end);

-- -----------------------------------------------------------------------------
-- Helpers de escopo
-- -----------------------------------------------------------------------------
create or replace function interno.meu_staff()
returns public.staff
language sql stable security definer set search_path = ''
as $$ select * from public.staff where user_id = auth.uid() $$;

-- A equipe logada alcança este curso? (ADMIN alcança todos)
create or replace function interno.staff_alcanca(p_curso public.curso)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.staff s
                  where s.user_id = auth.uid() and (s.papel = 'ADMIN' or p_curso = any (s.cursos)));
$$;

-- Pode gerir (alterar) dados deste curso? (ADMIN ou COORDENADOR do curso)
create or replace function interno.gestor_alcanca(p_curso public.curso)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.staff s
                  where s.user_id = auth.uid()
                    and (s.papel = 'ADMIN' or (s.papel = 'COORDENADOR' and p_curso = any (s.cursos))));
$$;

create or replace function interno.staff_ve_estudante(p_estudante_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.estudantes e
                  where e.id = p_estudante_id and interno.staff_alcanca(e.curso));
$$;

-- Questão visível para a equipe: ADMIN; Formação Geral; ou curso em comum.
create or replace function interno.staff_ve_questao(p_cursos public.curso_alvo[])
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.staff s
                  where s.user_id = auth.uid()
                    and (s.papel = 'ADMIN' or 'ALL' = any (p_cursos) or p_cursos::text[] && s.cursos::text[]));
$$;

-- Pode criar uma questão com estes cursos?
create or replace function interno.pode_criar_questao(p_cursos public.curso_alvo[])
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.staff s
                  where s.user_id = auth.uid()
                    and (s.papel = 'ADMIN'
                         or (s.papel = 'COORDENADOR'
                             and ('ALL' = any (p_cursos) or p_cursos::text[] <@ s.cursos::text[]))));
$$;

-- Pode alterar/excluir esta questão existente?
create or replace function interno.pode_editar_questao(p_cursos public.curso_alvo[], p_autor uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (select 1 from public.staff s
                  where s.user_id = auth.uid()
                    and (s.papel = 'ADMIN'
                         or (s.papel = 'COORDENADOR'
                             and case when 'ALL' = any (p_cursos) then p_autor = auth.uid()
                                      else p_cursos::text[] <@ s.cursos::text[] end)));
$$;

create or replace function interno.is_gestor()
returns boolean
language sql stable security definer set search_path = ''
as $$ select exists (select 1 from public.staff where user_id = auth.uid() and papel in ('ADMIN', 'COORDENADOR')) $$;

revoke all on function interno.meu_staff() from public, anon, authenticated;
grant execute on function interno.staff_alcanca(public.curso),
                          interno.gestor_alcanca(public.curso),
                          interno.staff_ve_estudante(uuid),
                          interno.staff_ve_questao(public.curso_alvo[]),
                          interno.pode_criar_questao(public.curso_alvo[]),
                          interno.pode_editar_questao(public.curso_alvo[], uuid),
                          interno.is_gestor()
  to authenticated;

-- -----------------------------------------------------------------------------
-- Políticas com escopo por curso
-- -----------------------------------------------------------------------------
drop policy estudantes_select        on public.estudantes;
drop policy estudantes_admin_update  on public.estudantes;
create policy estudantes_select on public.estudantes for select to authenticated
  using (id = auth.uid() or interno.staff_alcanca(curso));
create policy estudantes_gestor_update on public.estudantes for update to authenticated
  using (interno.gestor_alcanca(curso)) with check (interno.gestor_alcanca(curso));

drop policy questoes_staff_select  on public.questoes;
drop policy questoes_admin_insert  on public.questoes;
drop policy questoes_admin_update  on public.questoes;
drop policy questoes_admin_delete  on public.questoes;
create policy questoes_staff_select on public.questoes for select to authenticated
  using (interno.staff_ve_questao(cursos));
create policy questoes_gestor_insert on public.questoes for insert to authenticated
  with check (interno.pode_criar_questao(cursos));
create policy questoes_gestor_update on public.questoes for update to authenticated
  using (interno.pode_editar_questao(cursos, autor_id)) with check (interno.pode_criar_questao(cursos));
create policy questoes_gestor_delete on public.questoes for delete to authenticated
  using (interno.pode_editar_questao(cursos, autor_id));

drop policy gabarito_staff_select on public.questoes_gabarito;
create policy gabarito_staff_select on public.questoes_gabarito for select to authenticated
  using (exists (select 1 from public.questoes q
                  where q.id = questao_id and interno.staff_ve_questao(q.cursos)));

drop policy participacao_select on public.sessoes_participacao;
create policy participacao_select on public.sessoes_participacao for select to authenticated
  using (estudante_id = auth.uid() or interno.staff_ve_estudante(estudante_id));

drop policy exibicoes_staff_select on public.exibicoes_questao;
create policy exibicoes_staff_select on public.exibicoes_questao for select to authenticated
  using (interno.staff_ve_estudante(estudante_id));

drop policy respostas_select on public.respostas;
create policy respostas_select on public.respostas for select to authenticated
  using (
    interno.staff_ve_estudante(estudante_id)
    or (estudante_id = auth.uid()
        and (sessao_id is null or interno.simulado_encerrado(sessao_id, estudante_id)))
  );

drop policy correcoes_select on public.correcoes_discursivas;
create policy correcoes_select on public.correcoes_discursivas for select to authenticated
  using (exists (select 1 from public.respostas r
                  where r.id = resposta_id
                    and (interno.staff_ve_estudante(r.estudante_id)
                         or (r.estudante_id = auth.uid()
                             and (r.sessao_id is null or interno.simulado_encerrado(r.sessao_id, r.estudante_id))))));

drop policy conquistas_estudante_select on public.conquistas_estudante;
create policy conquistas_estudante_select on public.conquistas_estudante for select to authenticated
  using (estudante_id = auth.uid() or interno.staff_ve_estudante(estudante_id));

drop policy diag_resultados_staff on public.diagnostico_resultados;
drop policy diag_respostas_staff  on public.diagnostico_respostas;
create policy diag_resultados_staff on public.diagnostico_resultados for select to authenticated
  using (interno.staff_ve_estudante(estudante_id));
create policy diag_respostas_staff on public.diagnostico_respostas for select to authenticated
  using (interno.staff_ve_estudante(estudante_id));

drop policy pontos_extras_select on public.pontos_extras;
create policy pontos_extras_select on public.pontos_extras for select to authenticated
  using (estudante_id = auth.uid() or interno.staff_ve_estudante(estudante_id));

-- -----------------------------------------------------------------------------
-- RPCs com escopo
-- -----------------------------------------------------------------------------
create or replace function public.meu_contexto()
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select jsonb_build_object(
    'staff', (select jsonb_build_object('nome', s.nome, 'papel', s.papel, 'cursos', s.cursos)
                from public.staff s where s.user_id = auth.uid()),
    'estudante', (select jsonb_build_object('nome', e.nome, 'curso', e.curso, 'turma', e.turma,
                                            'tipo', e.tipo, 'status', e.status)
                    from public.estudantes e where e.id = auth.uid())
  );
$$;

-- salvar_questao / excluir_questao: mesma lógica, checagem de escopo no lugar de is_admin.
create or replace function public.salvar_questao(p_dados jsonb)
returns uuid
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_id          uuid := nullif(p_dados->>'id', '')::uuid;
  v_comp        public.componente := (p_dados->>'componente')::public.componente;
  v_formato     public.formato_questao := coalesce(nullif(p_dados->>'formato', ''), 'OBJETIVA')::public.formato_questao;
  v_status      public.status_questao := coalesce(nullif(p_dados->>'status', ''), 'RASCUNHO')::public.status_questao;
  v_dif         smallint := (p_dados->>'dificuldade')::smallint;
  v_peso        integer := nullif(p_dados->>'peso_pontos', '')::integer;
  v_eixo        text := btrim(coalesce(p_dados->>'eixo', ''));
  v_enunciado   text := btrim(coalesce(p_dados->>'enunciado', ''));
  v_apoio       text := nullif(btrim(coalesce(p_dados->>'texto_apoio', '')), '');
  v_fonte       text := nullif(btrim(coalesce(p_dados->>'fonte', '')), '');
  v_just        text := nullif(btrim(coalesce(p_dados->>'justificativa', '')), '');
  v_gab         text := upper(nullif(btrim(coalesce(p_dados->>'gabarito', '')), ''));
  v_alts        text[];
  v_cursos      public.curso_alvo[];
  v_atual       public.questoes;
begin
  if not interno.is_gestor() then
    raise exception 'Acesso restrito à coordenação.' using errcode = '42501';
  end if;

  if v_comp is null then raise exception 'Selecione o componente (Formação Geral ou Específico).'; end if;
  if v_eixo = '' then raise exception 'Informe o eixo/conteúdo da questão.'; end if;
  if v_enunciado = '' then raise exception 'O enunciado é obrigatório.'; end if;
  if v_dif is null or v_dif not between 1 and 3 then raise exception 'Selecione a dificuldade (1 a 3).'; end if;
  if v_peso is not null and v_peso <= 0 then raise exception 'O peso deve ser maior que zero.'; end if;

  if v_comp = 'FG' then
    v_cursos := array['ALL']::public.curso_alvo[];
  else
    select coalesce(array_agg(distinct c::public.curso_alvo), '{}')
      into v_cursos
      from jsonb_array_elements_text(coalesce(p_dados->'cursos', '[]'::jsonb)) c
     where c <> 'ALL';
    if cardinality(v_cursos) = 0 then
      raise exception 'Selecione ao menos um curso para a questão de Componente Específico.';
    end if;
  end if;

  if not interno.pode_criar_questao(v_cursos) then
    raise exception 'Você só pode cadastrar questões dos cursos que coordena.' using errcode = '42501';
  end if;

  if v_formato = 'OBJETIVA' then
    v_alts := array[
      nullif(btrim(coalesce(p_dados->>'alt_a', '')), ''), nullif(btrim(coalesce(p_dados->>'alt_b', '')), ''),
      nullif(btrim(coalesce(p_dados->>'alt_c', '')), ''), nullif(btrim(coalesce(p_dados->>'alt_d', '')), ''),
      nullif(btrim(coalesce(p_dados->>'alt_e', '')), '')];
    if array_position(v_alts, null) is not null then
      raise exception 'Preencha as cinco alternativas (A a E).';
    end if;
    if v_gab is null or v_gab not in ('A', 'B', 'C', 'D', 'E') then
      raise exception 'Marque a alternativa correta (gabarito).';
    end if;
  else
    v_alts := array[null, null, null, null, null];
    v_gab  := null;
  end if;

  if v_id is null then
    insert into public.questoes
      (componente, cursos, eixo, formato, texto_apoio, enunciado, alt_a, alt_b, alt_c, alt_d, alt_e,
       dificuldade, peso_pontos, fonte, status, autor_id)
    values
      (v_comp, v_cursos, v_eixo, v_formato, v_apoio, v_enunciado, v_alts[1], v_alts[2], v_alts[3], v_alts[4], v_alts[5],
       v_dif, v_peso, v_fonte, 'RASCUNHO', auth.uid())
    returning id into v_id;
  else
    select * into v_atual from public.questoes where id = v_id;
    if not found then
      raise exception 'Questão não encontrada.' using errcode = 'P0002';
    end if;
    if not interno.pode_editar_questao(v_atual.cursos, v_atual.autor_id) then
      raise exception 'Você não pode editar esta questão (ela é de outro curso ou de outro autor).' using errcode = '42501';
    end if;
    update public.questoes
       set componente = v_comp, cursos = v_cursos, eixo = v_eixo, formato = v_formato,
           texto_apoio = v_apoio, enunciado = v_enunciado,
           alt_a = v_alts[1], alt_b = v_alts[2], alt_c = v_alts[3], alt_d = v_alts[4], alt_e = v_alts[5],
           dificuldade = v_dif,
           peso_pontos = coalesce(v_peso, interno.peso_por_dificuldade(v_dif)),
           fonte = v_fonte, status = 'RASCUNHO'
     where id = v_id;
  end if;

  insert into public.questoes_gabarito (questao_id, gabarito, justificativa)
  values (v_id, v_gab, v_just)
  on conflict (questao_id) do update set gabarito = excluded.gabarito, justificativa = excluded.justificativa;

  if v_status <> 'RASCUNHO' then
    update public.questoes set status = v_status where id = v_id;
  end if;

  return v_id;
end;
$$;

create or replace function public.excluir_questao(p_id uuid)
returns text
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_q public.questoes;
begin
  if not interno.is_gestor() then
    raise exception 'Acesso restrito à coordenação.' using errcode = '42501';
  end if;
  select * into v_q from public.questoes where id = p_id;
  if not found then
    raise exception 'Questão não encontrada.' using errcode = 'P0002';
  end if;
  if not interno.pode_editar_questao(v_q.cursos, v_q.autor_id) then
    raise exception 'Você não pode excluir esta questão (ela é de outro curso ou de outro autor).' using errcode = '42501';
  end if;
  if exists (select 1 from public.respostas where questao_id = p_id)
     or exists (select 1 from public.sessoes where p_id = any (questoes)) then
    update public.questoes set status = 'ARQUIVADA' where id = p_id;
    return 'ARQUIVADA';
  end if;
  delete from public.questoes where id = p_id;
  return 'EXCLUIDA';
end;
$$;

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
  if not interno.staff_ve_estudante(v_r.estudante_id) then
    raise exception 'Esta resposta é de um aluno de outro curso.' using errcode = '42501';
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

-- -----------------------------------------------------------------------------
-- Convites da equipe: o ADMIN cadastra o e-mail; no primeiro login por magic
-- link a conta já nasce como coordenador/docente (não passa pelo cadastro de aluno).
-- -----------------------------------------------------------------------------
create table public.staff_convites (
  email      text primary key check (email = lower(btrim(email)) and email like '%@%'),
  nome       text not null,
  papel      public.papel_staff not null,
  cursos     public.curso[],
  criado_por uuid references auth.users (id) on delete set null default auth.uid(),
  criado_em  timestamptz not null default now(),
  constraint convites_escopo_coerente check (
    case when papel = 'ADMIN' then cursos is null
         else cursos is not null and cardinality(cursos) >= 1 end)
);
alter table public.staff_convites enable row level security;
revoke all on public.staff_convites from anon, authenticated;
grant select on public.staff_convites to authenticated;
create policy convites_admin_select on public.staff_convites for select to authenticated
  using (interno.is_admin());

create or replace function interno.tg_aplicar_convite_staff()
returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  v_c public.staff_convites;
begin
  select * into v_c from public.staff_convites where email = lower(btrim(new.email));
  if found then
    insert into public.staff (user_id, nome, papel, cursos)
    values (new.id, v_c.nome, v_c.papel, v_c.cursos)
    on conflict (user_id) do nothing;
    delete from public.staff_convites where email = v_c.email;
  end if;
  return new;
end;
$$;

create trigger aplicar_convite_staff
  after insert on auth.users
  for each row execute function interno.tg_aplicar_convite_staff();

-- Cria/atualiza um membro da equipe pelo e-mail.
create or replace function public.definir_membro_equipe(
  p_email text, p_nome text, p_papel public.papel_staff, p_cursos public.curso[]
)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_email  text := lower(btrim(coalesce(p_email, '')));
  v_nome   text := btrim(coalesce(p_nome, ''));
  v_cursos public.curso[] := case when p_papel = 'ADMIN' then null
                                  else (select array_agg(distinct c) from unnest(p_cursos) c) end;
  v_uid    uuid;
begin
  if not interno.is_admin() then
    raise exception 'Apenas a administração geral gerencia a equipe.' using errcode = '42501';
  end if;
  if v_email !~ '^[^\s@]+@[^\s@]+\.[^\s@]+$' then raise exception 'E-mail inválido.'; end if;
  if v_nome = '' then raise exception 'Informe o nome.'; end if;
  if p_papel is null then raise exception 'Selecione o perfil.'; end if;
  if p_papel <> 'ADMIN' and coalesce(cardinality(v_cursos), 0) = 0 then
    raise exception 'Selecione ao menos um curso.';
  end if;

  select id into v_uid from auth.users where lower(email) = v_email;
  if v_uid is not null and exists (select 1 from public.estudantes where id = v_uid) then
    raise exception 'Este e-mail já está cadastrado como aluno. Use outro e-mail para a coordenação.';
  end if;
  if v_uid = auth.uid() and p_papel <> 'ADMIN' then
    raise exception 'Você não pode remover o seu próprio acesso de administração geral.';
  end if;

  if v_uid is not null then
    insert into public.staff (user_id, nome, papel, cursos) values (v_uid, v_nome, p_papel, v_cursos)
    on conflict (user_id) do update set nome = excluded.nome, papel = excluded.papel, cursos = excluded.cursos;
    delete from public.staff_convites where email = v_email;
    return jsonb_build_object('situacao', 'ATIVO', 'email', v_email);
  end if;

  insert into public.staff_convites (email, nome, papel, cursos) values (v_email, v_nome, p_papel, v_cursos)
  on conflict (email) do update set nome = excluded.nome, papel = excluded.papel, cursos = excluded.cursos;
  return jsonb_build_object('situacao', 'CONVIDADO', 'email', v_email);
end;
$$;

create or replace function public.remover_membro_equipe(p_email text)
returns void
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_email text := lower(btrim(coalesce(p_email, '')));
  v_uid   uuid;
begin
  if not interno.is_admin() then
    raise exception 'Apenas a administração geral gerencia a equipe.' using errcode = '42501';
  end if;
  select id into v_uid from auth.users where lower(email) = v_email;
  if v_uid = auth.uid() then
    raise exception 'Você não pode remover o seu próprio acesso.';
  end if;
  delete from public.staff_convites where email = v_email;
  if v_uid is not null then
    delete from public.staff where user_id = v_uid;
  end if;
end;
$$;

-- Lista da equipe (ativos + convites pendentes), só para o ADMIN.
create or replace function public.listar_equipe()
returns table (email text, nome text, papel public.papel_staff, cursos public.curso[], situacao text, desde timestamptz)
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not interno.is_admin() then
    raise exception 'Apenas a administração geral gerencia a equipe.' using errcode = '42501';
  end if;
  return query
    select lower(u.email)::text, s.nome, s.papel, s.cursos, 'ATIVO'::text, s.criado_em
      from public.staff s join auth.users u on u.id = s.user_id
    union all
    select c.email, c.nome, c.papel, c.cursos, 'CONVIDADO'::text, c.criado_em
      from public.staff_convites c
    order by 3, 2;
end;
$$;

revoke all on function interno.tg_aplicar_convite_staff() from public, anon, authenticated;
revoke all on function public.definir_membro_equipe(text, text, public.papel_staff, public.curso[]),
                       public.remover_membro_equipe(text), public.listar_equipe()
  from public, anon;
grant execute on function public.definir_membro_equipe(text, text, public.papel_staff, public.curso[]),
                          public.remover_membro_equipe(text), public.listar_equipe()
  to authenticated;
