-- =============================================================================
-- Migration 4: cadastro por CPF + data de nascimento (+ telefone)
--
-- O aluno não digita matrícula. Ele informa CPF e data de nascimento, que são
-- conferidos com a base importada do sistema acadêmico, e um telefone de
-- contato. Falhas ficam registradas para limitar tentativas (força bruta).
-- =============================================================================

-- Validação de CPF (dígitos verificadores).
create or replace function interno.cpf_valido(p_cpf text)
returns boolean
language plpgsql immutable
as $$
declare
  d   int[];
  s   int;
  dv1 int;
  dv2 int;
begin
  if p_cpf is null or p_cpf !~ '^\d{11}$' or p_cpf ~ '^(\d)\1{10}$' then
    return false;
  end if;
  d := array(select substr(p_cpf, i, 1)::int from generate_series(1, 11) i);
  s := 0;
  for i in 1..9 loop s := s + d[i] * (11 - i); end loop;
  dv1 := case when s % 11 < 2 then 0 else 11 - s % 11 end;
  s := 0;
  for i in 1..10 loop s := s + d[i] * (12 - i); end loop;
  dv2 := case when s % 11 < 2 then 0 else 11 - s % 11 end;
  return d[10] = dv1 and d[11] = dv2;
end;
$$;

create or replace function interno.so_digitos(p text)
returns text
language sql immutable
as $$ select nullif(regexp_replace(coalesce(p, ''), '\D', '', 'g'), '') $$;

-- A base acadêmica passa a trazer CPF e data de nascimento.
-- (Tabela ainda vazia em produção; o NOT NULL é seguro.)
alter table public.matriculas_autorizadas
  add column cpf             text,
  add column data_nascimento date;
alter table public.matriculas_autorizadas
  alter column cpf set not null,
  alter column data_nascimento set not null,
  add constraint matriculas_cpf_valido check (interno.cpf_valido(cpf)),
  add constraint matriculas_cpf_unico unique (cpf);

alter table public.estudantes
  add column telefone text check (telefone ~ '^\d{10,11}$');

-- Registro de tentativas de cadastro (só para limitar abuso; sem CPF em claro).
create table public.tentativas_cadastro (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  cpf_hash   text,
  sucesso    boolean not null,
  motivo     text,
  criado_em  timestamptz not null default now()
);
create index tentativas_user_idx on public.tentativas_cadastro (user_id, criado_em desc);
create index tentativas_cpf_idx  on public.tentativas_cadastro (cpf_hash, criado_em desc);

alter table public.tentativas_cadastro enable row level security;
revoke all on public.tentativas_cadastro from anon, authenticated;
grant select on public.tentativas_cadastro to authenticated;
create policy tentativas_admin_select on public.tentativas_cadastro for select to authenticated
  using (interno.is_admin());

-- -----------------------------------------------------------------------------
-- Nova RPC de cadastro. Erros de validação voltam como {ok:false, codigo}
-- (e não como exceção) para que a tentativa falha fique gravada.
-- -----------------------------------------------------------------------------
drop function if exists public.concluir_cadastro(text, boolean);

create or replace function public.concluir_cadastro(
  p_cpf text,
  p_data_nascimento date,
  p_telefone text,
  p_aceite_lgpd boolean
)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  c_max_falhas_usuario constant int := 5;   -- por hora, por conta
  c_max_falhas_cpf     constant int := 10;  -- por dia, por CPF
  v_uid   uuid := auth.uid();
  v_cpf   text := interno.so_digitos(p_cpf);
  v_tel   text := interno.so_digitos(p_telefone);
  v_hash  text;
  v_email text;
  v_mat   public.matriculas_autorizadas;
  v_est   public.estudantes;
begin
  if v_uid is null then
    raise exception 'Não autenticado.' using errcode = '28000';
  end if;
  if exists (select 1 from public.estudantes where id = v_uid) then
    return jsonb_build_object('ok', false, 'codigo', 'CADASTRO_EXISTENTE',
                              'mensagem', 'Seu cadastro já foi concluído.');
  end if;

  -- Limites de tentativas
  if (select count(*) from public.tentativas_cadastro
       where user_id = v_uid and not sucesso and criado_em > now() - interval '1 hour') >= c_max_falhas_usuario then
    return jsonb_build_object('ok', false, 'codigo', 'LIMITE_TENTATIVAS',
                              'mensagem', 'Muitas tentativas. Aguarde 1 hora ou procure a coordenação.');
  end if;

  -- Validações de formato (não contam como tentativa)
  if not coalesce(p_aceite_lgpd, false) then
    return jsonb_build_object('ok', false, 'codigo', 'LGPD_OBRIGATORIO',
                              'mensagem', 'É necessário aceitar o termo de consentimento (LGPD).');
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

  v_hash := encode(sha256(convert_to('enade-univc:' || v_cpf, 'UTF8')), 'hex');

  if (select count(*) from public.tentativas_cadastro
       where cpf_hash = v_hash and not sucesso and criado_em > now() - interval '1 day') >= c_max_falhas_cpf then
    insert into public.tentativas_cadastro (user_id, cpf_hash, sucesso, motivo)
    values (v_uid, v_hash, false, 'LIMITE_CPF');
    return jsonb_build_object('ok', false, 'codigo', 'LIMITE_TENTATIVAS',
                              'mensagem', 'Muitas tentativas para este CPF. Procure a coordenação.');
  end if;

  -- Conferência com a base acadêmica. Mesma mensagem para CPF inexistente e
  -- data errada, para não revelar quais CPFs estão na base.
  select * into v_mat from public.matriculas_autorizadas
   where cpf = v_cpf and data_nascimento = p_data_nascimento;
  if not found then
    insert into public.tentativas_cadastro (user_id, cpf_hash, sucesso, motivo)
    values (v_uid, v_hash, false, 'DADOS_NAO_CONFEREM');
    return jsonb_build_object('ok', false, 'codigo', 'DADOS_NAO_CONFEREM',
                              'mensagem', 'CPF e data de nascimento não conferem com o cadastro acadêmico.');
  end if;

  if exists (select 1 from public.estudantes where matricula = v_mat.matricula) then
    insert into public.tentativas_cadastro (user_id, cpf_hash, sucesso, motivo)
    values (v_uid, v_hash, false, 'JA_VINCULADO');
    return jsonb_build_object('ok', false, 'codigo', 'JA_VINCULADO',
                              'mensagem', 'Este CPF já está vinculado a outra conta. Procure a coordenação.');
  end if;

  select lower(btrim(email)) into v_email from auth.users where id = v_uid;
  if coalesce(v_email, '') = '' then
    raise exception 'Conta sem e-mail.';
  end if;

  insert into public.estudantes
    (id, email_pessoal, nome, matricula, curso, turma, tipo, status, telefone,
     consentimento_lgpd, consentimento_data, ultimo_acesso)
  values
    (v_uid, v_email, v_mat.nome, v_mat.matricula, v_mat.curso, v_mat.turma, v_mat.tipo, 'ATIVO', v_tel,
     true, now(), now())
  returning * into v_est;

  insert into public.tentativas_cadastro (user_id, cpf_hash, sucesso, motivo)
  values (v_uid, v_hash, true, null);

  return jsonb_build_object('ok', true, 'estudante', jsonb_build_object(
    'nome', v_est.nome, 'curso', v_est.curso, 'turma', v_est.turma, 'tipo', v_est.tipo));
end;
$$;

revoke all on function public.concluir_cadastro(text, date, text, boolean) from public, anon;
grant execute on function public.concluir_cadastro(text, date, text, boolean) to authenticated;

-- Contexto do usuário logado, para o app decidir para onde encaminhar.
create or replace function public.meu_contexto()
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select jsonb_build_object(
    'staff', (select jsonb_build_object('nome', s.nome, 'papel', s.papel)
                from public.staff s where s.user_id = auth.uid()),
    'estudante', (select jsonb_build_object('nome', e.nome, 'curso', e.curso, 'turma', e.turma,
                                            'tipo', e.tipo, 'status', e.status)
                    from public.estudantes e where e.id = auth.uid())
  );
$$;

revoke all on function public.meu_contexto() from public, anon;
grant execute on function public.meu_contexto() to authenticated;
