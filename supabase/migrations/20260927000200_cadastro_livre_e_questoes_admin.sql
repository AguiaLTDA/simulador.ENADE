-- =============================================================================
-- Migration 5:
--   (a) Cadastro livre: o aluno informa os próprios dados (sem pré-cadastro).
--       Um cadastro por CPF. A coordenação pode bloquear contas.
--   (b) RPCs de administração de questões (questão + gabarito numa transação).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- (a) Cadastro livre
-- -----------------------------------------------------------------------------
alter table public.estudantes drop constraint if exists estudantes_matricula_fkey;
alter table public.estudantes alter column matricula drop not null;
alter table public.estudantes
  add column cpf             text,
  add column data_nascimento date;
-- Tabela vazia em produção: NOT NULL é seguro.
alter table public.estudantes
  alter column cpf set not null,
  alter column data_nascimento set not null,
  add constraint estudantes_cpf_valido check (interno.cpf_valido(cpf)),
  add constraint estudantes_cpf_unico unique (cpf),
  add constraint estudantes_nome_valido check (char_length(btrim(nome)) between 3 and 120),
  add constraint estudantes_turma_valida check (char_length(btrim(turma)) between 1 and 40);

comment on table public.matriculas_autorizadas is
  'Não usada desde o cadastro livre (migration 5). Mantida para uma eventual conferência com o sistema acadêmico.';

drop function if exists public.concluir_cadastro(text, date, text, boolean);

create or replace function public.concluir_cadastro(
  p_nome text,
  p_cpf text,
  p_data_nascimento date,
  p_telefone text,
  p_curso public.curso,
  p_turma text,
  p_tipo public.tipo_estudante,
  p_matricula text,
  p_aceite_lgpd boolean
)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  c_max_falhas constant int := 5;  -- conflitos de CPF/matrícula por hora, por conta
  v_uid   uuid := auth.uid();
  v_nome  text := regexp_replace(btrim(coalesce(p_nome, '')), '\s+', ' ', 'g');
  v_cpf   text := interno.so_digitos(p_cpf);
  v_tel   text := interno.so_digitos(p_telefone);
  v_turma text := upper(regexp_replace(btrim(coalesce(p_turma, '')), '\s+', ' ', 'g'));
  v_mat   text := nullif(btrim(coalesce(p_matricula, '')), '');
  v_email text;
  v_est   public.estudantes;
begin
  if v_uid is null then
    raise exception 'Não autenticado.' using errcode = '28000';
  end if;
  if exists (select 1 from public.estudantes where id = v_uid) then
    return jsonb_build_object('ok', false, 'codigo', 'CADASTRO_EXISTENTE', 'mensagem', 'Seu cadastro já foi concluído.');
  end if;
  if exists (select 1 from public.staff where user_id = v_uid) then
    return jsonb_build_object('ok', false, 'codigo', 'CONTA_STAFF',
                              'mensagem', 'Esta conta é da equipe da coordenação e não pode ser usada como aluno.');
  end if;
  if (select count(*) from public.tentativas_cadastro
       where user_id = v_uid and not sucesso and criado_em > now() - interval '1 hour') >= c_max_falhas then
    return jsonb_build_object('ok', false, 'codigo', 'LIMITE_TENTATIVAS',
                              'mensagem', 'Muitas tentativas. Aguarde 1 hora ou procure a coordenação.');
  end if;

  -- Validações de formato
  if not coalesce(p_aceite_lgpd, false) then
    return jsonb_build_object('ok', false, 'codigo', 'LGPD_OBRIGATORIO',
                              'mensagem', 'É necessário aceitar o termo de consentimento (LGPD).');
  end if;
  if char_length(v_nome) < 3 or v_nome !~ '\S+\s+\S+' then
    return jsonb_build_object('ok', false, 'codigo', 'NOME_INVALIDO', 'mensagem', 'Informe seu nome completo.');
  end if;
  if not interno.cpf_valido(v_cpf) then
    return jsonb_build_object('ok', false, 'codigo', 'CPF_INVALIDO', 'mensagem', 'CPF inválido.');
  end if;
  if p_data_nascimento is null or p_data_nascimento > current_date - interval '14 years'
     or p_data_nascimento < date '1920-01-01' then
    return jsonb_build_object('ok', false, 'codigo', 'DATA_INVALIDA', 'mensagem', 'Data de nascimento inválida.');
  end if;
  if v_tel is null or v_tel !~ '^[1-9]{2}\d{8,9}$' then
    return jsonb_build_object('ok', false, 'codigo', 'TELEFONE_INVALIDO',
                              'mensagem', 'Informe o telefone com DDD (10 ou 11 dígitos).');
  end if;
  if p_curso is null then
    return jsonb_build_object('ok', false, 'codigo', 'CURSO_INVALIDO', 'mensagem', 'Selecione o seu curso.');
  end if;
  if p_tipo is null then
    return jsonb_build_object('ok', false, 'codigo', 'TIPO_INVALIDO',
                              'mensagem', 'Informe se você é concluinte ou ingressante.');
  end if;
  if char_length(v_turma) not between 1 and 40 then
    return jsonb_build_object('ok', false, 'codigo', 'TURMA_INVALIDA', 'mensagem', 'Informe a sua turma.');
  end if;
  if v_mat is not null and char_length(v_mat) > 30 then
    return jsonb_build_object('ok', false, 'codigo', 'MATRICULA_INVALIDA', 'mensagem', 'Matrícula inválida.');
  end if;

  -- Unicidade (conta como tentativa falha: evita testar CPFs alheios em série)
  if exists (select 1 from public.estudantes where cpf = v_cpf) then
    insert into public.tentativas_cadastro (user_id, cpf_hash, sucesso, motivo)
    values (v_uid, encode(sha256(convert_to('enade-univc:' || v_cpf, 'UTF8')), 'hex'), false, 'CPF_EM_USO');
    return jsonb_build_object('ok', false, 'codigo', 'JA_VINCULADO',
                              'mensagem', 'Este CPF já está cadastrado em outra conta. Procure a coordenação.');
  end if;
  if v_mat is not null and exists (select 1 from public.estudantes where matricula = v_mat) then
    insert into public.tentativas_cadastro (user_id, sucesso, motivo) values (v_uid, false, 'MATRICULA_EM_USO');
    return jsonb_build_object('ok', false, 'codigo', 'MATRICULA_EM_USO',
                              'mensagem', 'Esta matrícula já está cadastrada em outra conta. Procure a coordenação.');
  end if;

  select lower(btrim(email)) into v_email from auth.users where id = v_uid;
  if coalesce(v_email, '') = '' then
    raise exception 'Conta sem e-mail.';
  end if;

  insert into public.estudantes
    (id, email_pessoal, nome, matricula, cpf, data_nascimento, curso, turma, tipo, status, telefone,
     consentimento_lgpd, consentimento_data, ultimo_acesso)
  values
    (v_uid, v_email, v_nome, v_mat, v_cpf, p_data_nascimento, p_curso, v_turma, p_tipo, 'ATIVO', v_tel,
     true, now(), now())
  returning * into v_est;

  insert into public.tentativas_cadastro (user_id, sucesso) values (v_uid, true);

  return jsonb_build_object('ok', true, 'estudante', jsonb_build_object(
    'nome', v_est.nome, 'curso', v_est.curso, 'turma', v_est.turma, 'tipo', v_est.tipo));
end;
$$;

revoke all on function public.concluir_cadastro(text, text, date, text, public.curso, text, public.tipo_estudante, text, boolean)
  from public, anon;
grant execute on function public.concluir_cadastro(text, text, date, text, public.curso, text, public.tipo_estudante, text, boolean)
  to authenticated;

-- -----------------------------------------------------------------------------
-- (b) Administração de questões
-- -----------------------------------------------------------------------------

-- Cria ou atualiza questão + gabarito atomicamente. Retorna o id.
-- p_dados: { id?, componente, cursos[], eixo, formato, texto_apoio, enunciado,
--            alt_a..alt_e, gabarito, justificativa, dificuldade, peso_pontos?,
--            fonte, status }
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
begin
  if not interno.is_admin() then
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
    -- Passa por RASCUNHO para poder trocar gabarito/formato com segurança.
    update public.questoes
       set componente = v_comp, cursos = v_cursos, eixo = v_eixo, formato = v_formato,
           texto_apoio = v_apoio, enunciado = v_enunciado,
           alt_a = v_alts[1], alt_b = v_alts[2], alt_c = v_alts[3], alt_d = v_alts[4], alt_e = v_alts[5],
           dificuldade = v_dif,
           peso_pontos = coalesce(v_peso, interno.peso_por_dificuldade(v_dif)),
           fonte = v_fonte, status = 'RASCUNHO'
     where id = v_id;
    if not found then
      raise exception 'Questão não encontrada.' using errcode = 'P0002';
    end if;
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

-- Exclui a questão; se já tiver respostas ou estiver num simulado, arquiva.
create or replace function public.excluir_questao(p_id uuid)
returns text
language plpgsql volatile security definer set search_path = ''
as $$
begin
  if not interno.is_admin() then
    raise exception 'Acesso restrito à coordenação.' using errcode = '42501';
  end if;
  if exists (select 1 from public.respostas where questao_id = p_id)
     or exists (select 1 from public.sessoes where p_id = any (questoes)) then
    update public.questoes set status = 'ARQUIVADA' where id = p_id;
    return 'ARQUIVADA';
  end if;
  delete from public.questoes where id = p_id;
  if not found then
    raise exception 'Questão não encontrada.' using errcode = 'P0002';
  end if;
  return 'EXCLUIDA';
end;
$$;

revoke all on function public.salvar_questao(jsonb) from public, anon;
revoke all on function public.excluir_questao(uuid) from public, anon;
grant execute on function public.salvar_questao(jsonb)  to authenticated;
grant execute on function public.excluir_questao(uuid)  to authenticated;
