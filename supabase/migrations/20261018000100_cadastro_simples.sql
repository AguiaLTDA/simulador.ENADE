-- =============================================================================
-- Migration 9: cadastro simples do estudante
--   Campos: nome completo, e-mail (da conta), telefone, CPF e curso.
--   Data de nascimento, turma, tipo (concluinte/ingressante) e matrícula passam
--   a ser opcionais (cadastros antigos mantêm os valores).
-- =============================================================================

alter table public.estudantes
  alter column data_nascimento drop not null,
  alter column turma           drop not null,
  alter column tipo            drop not null;

-- A checagem antiga exigia turma preenchida; agora só valida quando informada.
alter table public.estudantes drop constraint if exists estudantes_turma_valida;
alter table public.estudantes
  add constraint estudantes_turma_valida check (turma is null or char_length(btrim(turma)) between 1 and 40);

drop function if exists public.concluir_cadastro(text, text, date, text, public.curso, text, public.tipo_estudante, text, boolean);

create or replace function public.concluir_cadastro(
  p_nome text,
  p_cpf text,
  p_telefone text,
  p_curso public.curso,
  p_aceite_lgpd boolean
)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  c_max_falhas constant int := 5;  -- conflitos de CPF por hora, por conta
  v_uid   uuid := auth.uid();
  v_nome  text := regexp_replace(btrim(coalesce(p_nome, '')), '\s+', ' ', 'g');
  v_cpf   text := interno.so_digitos(p_cpf);
  v_tel   text := interno.so_digitos(p_telefone);
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

  if not coalesce(p_aceite_lgpd, false) then
    return jsonb_build_object('ok', false, 'codigo', 'LGPD_OBRIGATORIO',
                              'mensagem', 'É necessário aceitar o termo de consentimento (LGPD).');
  end if;
  if char_length(v_nome) < 3 or char_length(v_nome) > 120 or v_nome !~ '\S+\s+\S+' then
    return jsonb_build_object('ok', false, 'codigo', 'NOME_INVALIDO', 'mensagem', 'Informe seu nome completo.');
  end if;
  if v_tel is null or v_tel !~ '^[1-9]{2}\d{8,9}$' then
    return jsonb_build_object('ok', false, 'codigo', 'TELEFONE_INVALIDO',
                              'mensagem', 'Informe o telefone com DDD (10 ou 11 dígitos).');
  end if;
  if not interno.cpf_valido(v_cpf) then
    return jsonb_build_object('ok', false, 'codigo', 'CPF_INVALIDO', 'mensagem', 'CPF inválido.');
  end if;
  if p_curso is null then
    return jsonb_build_object('ok', false, 'codigo', 'CURSO_INVALIDO', 'mensagem', 'Selecione o seu curso.');
  end if;

  if exists (select 1 from public.estudantes where cpf = v_cpf) then
    insert into public.tentativas_cadastro (user_id, cpf_hash, sucesso, motivo)
    values (v_uid, encode(sha256(convert_to('enade-univc:' || v_cpf, 'UTF8')), 'hex'), false, 'CPF_EM_USO');
    return jsonb_build_object('ok', false, 'codigo', 'JA_VINCULADO',
                              'mensagem', 'Este CPF já está cadastrado em outra conta. Procure a coordenação.');
  end if;

  select lower(btrim(email)) into v_email from auth.users where id = v_uid;
  if coalesce(v_email, '') = '' then
    raise exception 'Conta sem e-mail.';
  end if;

  insert into public.estudantes
    (id, email_pessoal, nome, cpf, telefone, curso, status, consentimento_lgpd, consentimento_data, ultimo_acesso)
  values
    (v_uid, v_email, v_nome, v_cpf, v_tel, p_curso, 'ATIVO', true, now(), now())
  returning * into v_est;

  insert into public.tentativas_cadastro (user_id, sucesso) values (v_uid, true);

  return jsonb_build_object('ok', true, 'estudante', jsonb_build_object('nome', v_est.nome, 'curso', v_est.curso));
end;
$$;

revoke all on function public.concluir_cadastro(text, text, text, public.curso, boolean) from public, anon;
grant execute on function public.concluir_cadastro(text, text, text, public.curso, boolean) to authenticated;

-- -----------------------------------------------------------------------------
-- Edição pela coordenação: data de nascimento, turma e situação passam a ser
-- opcionais (mesma função da migration 20261004000200; só as validações mudam).
-- p_dados: { nome, cpf, data_nascimento?, telefone, curso, turma?, tipo?, matricula?, status }
-- -----------------------------------------------------------------------------
create or replace function public.atualizar_estudante(p_id uuid, p_dados jsonb)
returns void
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_atual public.estudantes;
  v_nome  text := regexp_replace(btrim(coalesce(p_dados->>'nome', '')), '\s+', ' ', 'g');
  v_cpf   text := interno.so_digitos(p_dados->>'cpf');
  v_tel   text := interno.so_digitos(p_dados->>'telefone');
  v_turma text := nullif(upper(regexp_replace(btrim(coalesce(p_dados->>'turma', '')), '\s+', ' ', 'g')), '');
  v_mat   text := nullif(btrim(coalesce(p_dados->>'matricula', '')), '');
  v_nasc  date;
  v_curso public.curso;
  v_tipo  public.tipo_estudante;
  v_status public.status_estudante;
  v_antes jsonb;
  v_depois jsonb;
begin
  select * into v_atual from public.estudantes where id = p_id for update;
  if not found or not interno.gestor_alcanca(v_atual.curso) then
    raise exception 'Aluno não encontrado ou fora dos seus cursos.' using errcode = '42501';
  end if;

  begin
    v_nasc   := nullif(p_dados->>'data_nascimento', '')::date;
    v_curso  := (p_dados->>'curso')::public.curso;
    v_tipo   := nullif(p_dados->>'tipo', '')::public.tipo_estudante;
    v_status := (p_dados->>'status')::public.status_estudante;
  exception when others then
    raise exception 'Dados inválidos (data, curso, situação ou status).';
  end;

  if char_length(v_nome) < 3 or v_nome !~ '\S+\s+\S+' then raise exception 'Informe o nome completo.'; end if;
  if not interno.cpf_valido(v_cpf) then raise exception 'CPF inválido.'; end if;
  if v_nasc is not null and (v_nasc > current_date - interval '14 years' or v_nasc < date '1920-01-01') then
    raise exception 'Data de nascimento inválida.';
  end if;
  if v_tel is null or v_tel !~ '^[1-9]{2}\d{8,9}$' then raise exception 'Telefone inválido (DDD + número).'; end if;
  if v_curso is null or v_status is null then raise exception 'Preencha curso e status.'; end if;
  if v_turma is not null and char_length(v_turma) > 40 then raise exception 'Turma muito longa (máx. 40).'; end if;
  if v_mat is not null and char_length(v_mat) > 30 then raise exception 'Matrícula inválida.'; end if;
  if v_curso <> v_atual.curso and not interno.gestor_alcanca(v_curso) then
    raise exception 'Você não pode transferir o aluno para um curso que não coordena.' using errcode = '42501';
  end if;
  if exists (select 1 from public.estudantes where cpf = v_cpf and id <> p_id) then
    raise exception 'Este CPF já pertence a outro aluno.';
  end if;
  if v_mat is not null and exists (select 1 from public.estudantes where matricula = v_mat and id <> p_id) then
    raise exception 'Esta matrícula já pertence a outro aluno.';
  end if;

  v_antes := jsonb_build_object('nome', v_atual.nome, 'cpf', v_atual.cpf, 'data_nascimento', v_atual.data_nascimento,
                                'telefone', v_atual.telefone, 'curso', v_atual.curso, 'turma', v_atual.turma,
                                'tipo', v_atual.tipo, 'matricula', v_atual.matricula, 'status', v_atual.status);
  v_depois := jsonb_build_object('nome', v_nome, 'cpf', v_cpf, 'data_nascimento', v_nasc, 'telefone', v_tel,
                                 'curso', v_curso, 'turma', v_turma, 'tipo', v_tipo, 'matricula', v_mat,
                                 'status', v_status);
  if v_antes = v_depois then
    return;
  end if;

  update public.estudantes
     set nome = v_nome, cpf = v_cpf, data_nascimento = v_nasc, telefone = v_tel, curso = v_curso,
         turma = v_turma, tipo = v_tipo, matricula = v_mat, status = v_status
   where id = p_id;

  -- Só o que mudou vai para a auditoria.
  perform interno.auditar('ESTUDANTE_ALTERADO', 'ESTUDANTE', p_id::text,
    (select jsonb_object_agg(k, jsonb_build_object('de', v_antes->k, 'para', v_depois->k))
       from jsonb_object_keys(v_depois) k
      where v_antes->k is distinct from v_depois->k));
end;
$$;
