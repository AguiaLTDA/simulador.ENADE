-- =============================================================================
-- Migration 10: ferramentas de administração
--
--   (a) Auditoria: quem alterou o quê (perfis, configuração, tentativas, importação).
--   (b) Configuração editável pela tela (pesos da pontuação e da nota ENADE).
--   (c) Edição do perfil de alunos pela coordenação (ADMIN: qualquer curso).
--   (d) Nova tentativa de simulado liberada pela coordenação para um aluno
--       (ex.: queda de internet). A tentativa anterior é anulada, mas fica no
--       histórico — respostas continuam append-only, marcadas com o número da
--       tentativa. Prazo individual opcional para refazer após o encerramento.
--   (e) Revisão do simulado de um aluno (resposta por resposta) para a equipe.
--   (f) Importação de questões em lote (planilha), com validação prévia.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- (a) Auditoria
-- -----------------------------------------------------------------------------
create table public.auditoria (
  id         bigint generated always as identity primary key,
  autor_id   uuid references auth.users (id) on delete set null default auth.uid(),
  acao       text not null,
  alvo_tipo  text not null,
  alvo_id    text,
  detalhes   jsonb,
  criado_em  timestamptz not null default now()
);
create index auditoria_alvo_idx on public.auditoria (alvo_tipo, alvo_id, criado_em desc);
alter table public.auditoria enable row level security;
revoke all on public.auditoria from anon, authenticated;
grant select on public.auditoria to authenticated;
-- ADMIN vê tudo; coordenador vê o histórico dos alunos dos seus cursos.
create policy auditoria_select on public.auditoria for select to authenticated
  using (interno.is_admin()
         or (alvo_tipo = 'ESTUDANTE' and interno.is_gestor() and interno.staff_ve_estudante(alvo_id::uuid)));

create or replace function interno.auditar(p_acao text, p_alvo_tipo text, p_alvo_id text, p_detalhes jsonb)
returns void
language sql volatile security definer set search_path = ''
as $$
  insert into public.auditoria (acao, alvo_tipo, alvo_id, detalhes) values (p_acao, p_alvo_tipo, p_alvo_id, p_detalhes);
$$;

-- Exclusão LGPD também apaga o histórico de alterações do aluno (tem dados pessoais).
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
  delete from public.auditoria where alvo_tipo = 'ESTUDANTE' and alvo_id = p_estudante_id::text;
  perform interno.auditar('ESTUDANTE_EXCLUIDO_LGPD', 'ESTUDANTE', null, null);
end;
$$;

-- -----------------------------------------------------------------------------
-- (b) Configuração
-- -----------------------------------------------------------------------------
alter table public.config add column atualizado_por uuid references auth.users (id) on delete set null;

insert into public.config (chave, valor, descricao) values
  ('enade_peso_fg',           '0.25', 'Peso da Formação Geral na nota estimada (o Componente Específico fica com o restante)'),
  ('enade_fg_peso_objetivas', '0.6',  'Peso das objetivas dentro da Formação Geral (discursivas ficam com o restante)'),
  ('enade_ce_peso_objetivas', '0.85', 'Peso das objetivas dentro do Componente Específico (discursivas ficam com o restante)')
on conflict (chave) do nothing;

-- Limites aceitos por chave.
create or replace function interno.config_limites()
returns table (chave text, minimo numeric, maximo numeric, inteiro boolean)
language sql immutable
as $$
  values ('pontos_facil', 1, 1000, true), ('pontos_media', 1, 1000, true), ('pontos_dificil', 1, 1000, true),
         ('bonus_tempo_max', 0.1, 5, false), ('bonus_tempo_min', 0, 5, false),
         ('limite_bonus_tempo_seg', 0, 3600, true),
         ('sequencia_incremento', 0, 1, false), ('sequencia_teto', 1, 5, false),
         ('multiplicador_fg', 0.1, 5, false),
         ('pontos_diagnostico', 0, 1000, true),
         ('diagnostico_corte_intermediario', 0, 100, false), ('diagnostico_corte_avancado', 0, 100, false),
         ('enade_peso_fg', 0, 1, false), ('enade_fg_peso_objetivas', 0, 1, false), ('enade_ce_peso_objetivas', 0, 1, false)
$$;

-- Salva vários valores de uma vez. Com p_atualizar_questoes, questões que
-- estavam com o peso padrão antigo da dificuldade passam ao novo padrão.
create or replace function public.salvar_config(p_valores jsonb, p_atualizar_questoes boolean default false)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_chave   text;
  v_valor   numeric;
  v_lim     record;
  v_antigo  numeric;
  v_mudou   jsonb := '{}'::jsonb;
  v_questoes integer := 0;
  v_n       integer;
begin
  if not interno.is_admin() then
    raise exception 'Apenas a administração geral altera a configuração.' using errcode = '42501';
  end if;
  if jsonb_typeof(p_valores) <> 'object' then
    raise exception 'Valores inválidos.';
  end if;

  for v_chave in select jsonb_object_keys(p_valores) loop
    select * into v_lim from interno.config_limites() l where l.chave = v_chave;
    if not found then
      raise exception 'Configuração desconhecida: %', v_chave;
    end if;
    begin
      v_valor := (p_valores->>v_chave)::numeric;
    exception when others then
      raise exception 'Valor inválido para %.', v_chave;
    end;
    if v_valor is null or v_valor < v_lim.minimo or v_valor > v_lim.maximo then
      raise exception 'O valor de % deve ficar entre % e %.', v_chave, v_lim.minimo, v_lim.maximo;
    end if;
    if v_lim.inteiro and v_valor <> trunc(v_valor) then
      raise exception 'O valor de % deve ser um número inteiro.', v_chave;
    end if;

    v_antigo := interno.cfg_num(v_chave);
    if v_antigo is distinct from v_valor then
      update public.config set valor = to_jsonb(v_valor), atualizado_por = auth.uid() where chave = v_chave;
      v_mudou := v_mudou || jsonb_build_object(v_chave, jsonb_build_object('de', v_antigo, 'para', v_valor));

      if p_atualizar_questoes and v_chave in ('pontos_facil', 'pontos_media', 'pontos_dificil') then
        update public.questoes
           set peso_pontos = v_valor::integer
         where dificuldade = case v_chave when 'pontos_facil' then 1 when 'pontos_media' then 2 else 3 end
           and peso_pontos = v_antigo::integer;
        get diagnostics v_n = row_count;
        v_questoes := v_questoes + v_n;
      end if;
    end if;
  end loop;

  -- Coerência entre chaves
  if interno.cfg_num('bonus_tempo_min') > interno.cfg_num('bonus_tempo_max') then
    raise exception 'O bônus de tempo mínimo não pode ser maior que o máximo.';
  end if;
  if interno.cfg_num('diagnostico_corte_intermediario') >= interno.cfg_num('diagnostico_corte_avancado') then
    raise exception 'O corte do nível Intermediário deve ser menor que o do Avançado.';
  end if;

  if v_mudou <> '{}'::jsonb then
    perform interno.auditar('CONFIG_ALTERADA', 'CONFIG', null,
                            jsonb_build_object('valores', v_mudou, 'questoes_atualizadas', v_questoes));
  end if;
  return jsonb_build_object('alteradas', (select count(*) from jsonb_object_keys(v_mudou)),
                            'questoes_atualizadas', v_questoes);
end;
$$;

-- -----------------------------------------------------------------------------
-- (c) Edição do perfil de alunos
-- -----------------------------------------------------------------------------
-- p_dados: { nome, cpf, data_nascimento, telefone, curso, turma, tipo, matricula, status }
create or replace function public.atualizar_estudante(p_id uuid, p_dados jsonb)
returns void
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_atual public.estudantes;
  v_nome  text := regexp_replace(btrim(coalesce(p_dados->>'nome', '')), '\s+', ' ', 'g');
  v_cpf   text := interno.so_digitos(p_dados->>'cpf');
  v_tel   text := interno.so_digitos(p_dados->>'telefone');
  v_turma text := upper(regexp_replace(btrim(coalesce(p_dados->>'turma', '')), '\s+', ' ', 'g'));
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
    v_nasc   := (p_dados->>'data_nascimento')::date;
    v_curso  := (p_dados->>'curso')::public.curso;
    v_tipo   := (p_dados->>'tipo')::public.tipo_estudante;
    v_status := (p_dados->>'status')::public.status_estudante;
  exception when others then
    raise exception 'Dados inválidos (data, curso, situação ou status).';
  end;

  if char_length(v_nome) < 3 or v_nome !~ '\S+\s+\S+' then raise exception 'Informe o nome completo.'; end if;
  if not interno.cpf_valido(v_cpf) then raise exception 'CPF inválido.'; end if;
  if v_nasc is null or v_nasc > current_date - interval '14 years' or v_nasc < date '1920-01-01' then
    raise exception 'Data de nascimento inválida.';
  end if;
  if v_tel is null or v_tel !~ '^[1-9]{2}\d{8,9}$' then raise exception 'Telefone inválido (DDD + número).'; end if;
  if v_curso is null or v_tipo is null or v_status is null then raise exception 'Preencha curso, situação e status.'; end if;
  if char_length(v_turma) not between 1 and 40 then raise exception 'Informe a turma.'; end if;
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

-- -----------------------------------------------------------------------------
-- (d) Tentativas de simulado
-- -----------------------------------------------------------------------------
alter table public.sessoes_participacao add column tentativa integer not null default 1 check (tentativa >= 1);

-- A coluna nova não dispara o trigger append-only: linhas existentes recebem 1.
alter table public.respostas add column tentativa_sessao integer not null default 1 check (tentativa_sessao >= 1);
drop index public.respostas_simulado_unica_idx;
create unique index respostas_simulado_unica_idx
  on public.respostas (estudante_id, sessao_id, questao_id, tentativa_sessao) where sessao_id is not null;

-- Histórico de tentativas anuladas pela coordenação.
create table public.sessoes_liberacoes (
  sessao_id      uuid not null references public.sessoes (id) on delete cascade,
  estudante_id   uuid not null references public.estudantes (id) on delete cascade,
  tentativa      integer not null,          -- tentativa ANULADA
  iniciada_em    timestamptz not null,
  finalizada_em  timestamptz,
  desempenho     jsonb,                     -- retrato da tentativa anulada
  motivo         text not null check (char_length(btrim(motivo)) >= 5),
  prazo          timestamptz,               -- até quando pode refazer (null = encerramento do simulado)
  liberada_por   uuid references auth.users (id) on delete set null default auth.uid(),
  liberada_em    timestamptz not null default now(),
  primary key (sessao_id, estudante_id, tentativa)
);
alter table public.sessoes_liberacoes enable row level security;
revoke all on public.sessoes_liberacoes from anon, authenticated;
grant select on public.sessoes_liberacoes to authenticated;
create policy liberacoes_select on public.sessoes_liberacoes for select to authenticated
  using (estudante_id = auth.uid() or interno.staff_ve_estudante(estudante_id));

-- Encerramento efetivo do simulado para um aluno (prazo individual prorroga).
create or replace function interno.fim_aluno(p_sessao_id uuid, p_estudante_id uuid)
returns timestamptz
language sql stable security definer set search_path = ''
as $$
  select greatest(s.fim, (select max(l.prazo) from public.sessoes_liberacoes l
                           where l.sessao_id = s.id and l.estudante_id = p_estudante_id))
    from public.sessoes s where s.id = p_sessao_id;
$$;

-- Tentativa vigente (a da participação, ou a próxima, se a anterior foi anulada).
create or replace function interno.tentativa_atual(p_sessao_id uuid, p_estudante_id uuid)
returns integer
language sql stable security definer set search_path = ''
as $$
  select coalesce(
    (select p.tentativa from public.sessoes_participacao p
      where p.sessao_id = p_sessao_id and p.estudante_id = p_estudante_id),
    1 + coalesce((select max(l.tentativa) from public.sessoes_liberacoes l
                   where l.sessao_id = p_sessao_id and l.estudante_id = p_estudante_id), 0));
$$;

create or replace function interno.simulado_encerrado(p_sessao_id uuid, p_estudante_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1
      from public.sessoes s
      left join public.sessoes_participacao p
             on p.sessao_id = s.id and p.estudante_id = p_estudante_id
     where s.id = p_sessao_id
       and (p.finalizada_em is not null
            or now() > interno.fim_aluno(s.id, p_estudante_id)
            or now() > p.iniciada_em + make_interval(mins => s.duracao_minutos))
  );
$$;

-- Gabarito liberado para este aluno: o simulado fechou para ele.
create or replace function interno.simulado_liberado(p_sessao_id uuid, p_estudante_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select now() > interno.fim_aluno(p_sessao_id, p_estudante_id);
$$;

drop policy respostas_select on public.respostas;
create policy respostas_select on public.respostas for select to authenticated
  using (
    interno.staff_ve_estudante(estudante_id)
    or (estudante_id = auth.uid() and (sessao_id is null or interno.simulado_liberado(sessao_id, estudante_id)))
  );

drop policy correcoes_select on public.correcoes_discursivas;
create policy correcoes_select on public.correcoes_discursivas for select to authenticated
  using (exists (select 1 from public.respostas r
                  where r.id = resposta_id
                    and (interno.staff_ve_estudante(r.estudante_id)
                         or (r.estudante_id = auth.uid()
                             and (r.sessao_id is null or interno.simulado_liberado(r.sessao_id, r.estudante_id))))));

-- Questão segue reservada (fora do treino) enquanto alguém ainda pode fazer o simulado.
create or replace function interno.questao_reservada(p_questao_id uuid)
returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.sessoes s
     where s.publicada and s.tipo = 'SIMULADO'
       and p_questao_id = any (s.questoes)
       and (s.fim > now()
            or exists (select 1 from public.sessoes_liberacoes l where l.sessao_id = s.id and l.prazo > now()))
  );
$$;

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
          and (r.sessao_id is null or interno.simulado_liberado(r.sessao_id, v_est.id))) then
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
                     and (r.sessao_id is null or interno.simulado_liberado(r.sessao_id, v_est.id)))
  );
end;
$$;

drop function interno.simulado_liberado(uuid);

-- Travas do simulado também valem quando só há tentativas anuladas.
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

  if tg_op = 'UPDATE'
     and (exists (select 1 from public.sessoes_participacao p where p.sessao_id = old.id)
          or exists (select 1 from public.sessoes_liberacoes l where l.sessao_id = old.id)) then
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
  if exists (select 1 from public.sessoes_participacao where sessao_id = p_id)
     or exists (select 1 from public.respostas where sessao_id = p_id) then
    raise exception 'Este simulado já tem participações e não pode ser excluído.';
  end if;
  delete from public.sessoes where id = p_id;
end;
$$;

-- Desempenho na tentativa vigente.
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
            and r.tentativa_sessao = interno.tentativa_atual(s.id, p_estudante_id)
      left join public.correcoes_discursivas c on c.resposta_id = r.id
     where s.id = p_sessao_id
  ),
  pesos as (
    select interno.cfg_num('enade_peso_fg')           as fg,
           interno.cfg_num('enade_fg_peso_objetivas') as fg_obj,
           interno.cfg_num('enade_ce_peso_objetivas') as ce_obj
  ),
  comp as (
    select i.componente,
           count(*) filter (where i.formato = 'OBJETIVA')                                    as obj_total,
           count(*) filter (where i.formato = 'OBJETIVA' and i.correta)                      as obj_acertos,
           count(*) filter (where i.formato = 'DISCURSIVA')                                  as disc_total,
           count(*) filter (where i.formato = 'DISCURSIVA' and i.resposta_id is not null and i.nota is null) as disc_pendentes,
           coalesce(sum(i.nota) filter (where i.formato = 'DISCURSIVA'), 0)                  as disc_soma,
           max(case i.componente when 'FG' then p.fg_obj else p.ce_obj end)                  as peso_obj,
           max(1 - case i.componente when 'FG' then p.fg_obj else p.ce_obj end)             as peso_disc,
           max(case i.componente when 'FG' then p.fg else 1 - p.fg end)                      as peso_comp
      from itens i cross join pesos p
     group by i.componente
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

-- Coordenação libera nova tentativa: anula a atual (fica no histórico).
create or replace function public.liberar_nova_tentativa(
  p_sessao_id uuid, p_estudante_id uuid, p_motivo text, p_prazo timestamptz default null
)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_s    public.sessoes;
  v_est  public.estudantes;
  v_part public.sessoes_participacao;
  v_mot  text := btrim(coalesce(p_motivo, ''));
begin
  select * into v_est from public.estudantes where id = p_estudante_id;
  if not found or not interno.gestor_alcanca(v_est.curso) then
    raise exception 'Aluno não encontrado ou fora dos seus cursos.' using errcode = '42501';
  end if;
  select * into v_s from public.sessoes where id = p_sessao_id and tipo = 'SIMULADO';
  if not found then
    raise exception 'Simulado não encontrado.' using errcode = 'P0002';
  end if;
  if char_length(v_mot) < 5 then
    raise exception 'Informe o motivo da nova tentativa.';
  end if;
  if p_prazo is not null and p_prazo <= now() then
    raise exception 'O prazo para refazer precisa estar no futuro.';
  end if;
  if p_prazo is null and now() >= v_s.fim then
    raise exception 'O simulado já encerrou: informe até quando o aluno pode refazer.';
  end if;

  select * into v_part from public.sessoes_participacao
   where sessao_id = p_sessao_id and estudante_id = p_estudante_id for update;
  if not found then
    raise exception 'O aluno não tem tentativa a anular neste simulado.';
  end if;

  insert into public.sessoes_liberacoes
    (sessao_id, estudante_id, tentativa, iniciada_em, finalizada_em, desempenho, motivo, prazo)
  values
    (p_sessao_id, p_estudante_id, v_part.tentativa, v_part.iniciada_em, v_part.finalizada_em,
     interno.desempenho_simulado(p_sessao_id, p_estudante_id), v_mot, p_prazo);

  delete from public.sessoes_participacao where sessao_id = p_sessao_id and estudante_id = p_estudante_id;

  perform interno.auditar('NOVA_TENTATIVA', 'ESTUDANTE', p_estudante_id::text,
    jsonb_build_object('sessao_id', p_sessao_id, 'simulado', v_s.titulo, 'tentativa_anulada', v_part.tentativa,
                       'motivo', v_mot, 'prazo', p_prazo));

  return jsonb_build_object('tentativa_anulada', v_part.tentativa, 'proxima_tentativa', v_part.tentativa + 1,
                            'fim', interno.fim_aluno(p_sessao_id, p_estudante_id));
end;
$$;

-- ---- RPCs do aluno, agora cientes da tentativa e do prazo individual ----

create or replace function public.iniciar_simulado(p_sessao_id uuid)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_est  public.estudantes := interno.estudante_ativo();
  v_sess public.sessoes;
  v_part public.sessoes_participacao;
  v_fim  timestamptz;
begin
  select * into v_sess from public.sessoes
   where id = p_sessao_id and publicada and tipo = 'SIMULADO';
  if not found or (v_sess.curso is not null and v_sess.curso <> v_est.curso) then
    raise exception 'Simulado indisponível.' using errcode = 'P0002';
  end if;
  if now() < v_sess.inicio then
    raise exception 'O simulado ainda não abriu.' using hint = 'SIMULADO_FUTURO';
  end if;
  v_fim := interno.fim_aluno(v_sess.id, v_est.id);

  perform pg_advisory_xact_lock(hashtextextended(v_est.id::text, 0));
  select * into v_part from public.sessoes_participacao
   where sessao_id = v_sess.id and estudante_id = v_est.id;
  if not found then
    if now() >= v_fim then
      raise exception 'O simulado já encerrou.' using hint = 'SIMULADO_ENCERRADO';
    end if;
    insert into public.sessoes_participacao (sessao_id, estudante_id, iniciada_em, tentativa)
    values (v_sess.id, v_est.id, clock_timestamp(), interno.tentativa_atual(v_sess.id, v_est.id))
    returning * into v_part;
  elsif v_part.finalizada_em is not null then
    raise exception 'Simulado já finalizado.' using hint = 'SIMULADO_FINALIZADO';
  end if;

  return jsonb_build_object(
    'sessao_id',   v_sess.id,
    'titulo',      v_sess.titulo,
    'tentativa',   v_part.tentativa,
    'iniciada_em', v_part.iniciada_em,
    'termina_em',  least(v_fim, v_part.iniciada_em + make_interval(mins => v_sess.duracao_minutos)),
    'questoes', (select jsonb_agg(interno.questao_json(q) order by x.ord)
                   from unnest(v_sess.questoes) with ordinality as x(id, ord)
                   join public.questoes q on q.id = x.id),
    'respondidas', (select coalesce(jsonb_agg(r.questao_id), '[]'::jsonb)
                      from public.respostas r
                     where r.estudante_id = v_est.id and r.sessao_id = v_sess.id
                       and r.tentativa_sessao = v_part.tentativa)
  );
end;
$$;

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
  v_tent_s   integer := 1;
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
    if v_agora > least(interno.fim_aluno(v_sess.id, v_est.id),
                       v_part.iniciada_em + make_interval(mins => v_sess.duracao_minutos)) then
      raise exception 'Tempo do simulado esgotado.' using hint = 'TEMPO_ESGOTADO';
    end if;
    v_tent_s := v_part.tentativa;
    if exists (select 1 from public.respostas r
                where r.estudante_id = v_est.id and r.sessao_id = v_sess.id and r.questao_id = v_q.id
                  and r.tentativa_sessao = v_tent_s) then
      raise exception 'Questão já respondida neste simulado.' using hint = 'JA_RESPONDIDA';
    end if;
    -- Tempo da questão = desde a resposta anterior nesta tentativa (ou do início).
    select greatest(v_part.iniciada_em, coalesce(max(r.criado_em), v_part.iniciada_em)) into v_ref
      from public.respostas r
     where r.estudante_id = v_est.id and r.sessao_id = v_sess.id and r.tentativa_sessao = v_tent_s;
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
     tempo_segundos, pontos_ganhos, tentativa_n, sequencia_atual, tentativa_sessao, criado_em)
  values
    (v_est.id, v_q.id, p_sessao_id, v_alt, v_texto, v_correta,
     v_tempo, v_pontos, v_tent, v_seq, v_tent_s, v_agora)
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
           where r.sessao_id = s.id and r.estudante_id = v_est.id
             and r.tentativa_sessao = v_part.tentativa) >= cardinality(s.questoes)
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

create or replace function public.resultado_simulado(p_sessao_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_est  public.estudantes := interno.estudante_ativo();
  v_s    public.sessoes;
  v_part public.sessoes_participacao;
  v_fim  timestamptz;
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
  v_fim := interno.fim_aluno(v_s.id, v_est.id);
  v_lib := now() > v_fim;

  return jsonb_build_object(
    'sessao', jsonb_build_object('id', v_s.id, 'titulo', v_s.titulo, 'curso', v_s.curso,
                                 'inicio', v_s.inicio, 'fim', v_fim, 'duracao_minutos', v_s.duracao_minutos),
    'tentativa',     v_part.tentativa,
    'iniciada_em',   v_part.iniciada_em,
    'finalizada_em', coalesce(v_part.finalizada_em,
                              least(v_fim, v_part.iniciada_em + make_interval(mins => v_s.duracao_minutos))),
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
           left join public.respostas r on r.sessao_id = v_s.id and r.estudante_id = v_est.id
                                       and r.questao_id = q.id and r.tentativa_sessao = v_part.tentativa
           left join public.correcoes_discursivas c on c.resposta_id = r.id) end
  );
end;
$$;

-- ---- RPCs da equipe ----

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
                                   and r.tentativa_sessao = interno.tentativa_atual(v_s.id, r.estudante_id)
                                   and interno.staff_ve_estudante(r.estudante_id))
                 ) order by x.ord), '[]'::jsonb)
                   from unnest(v_s.questoes) with ordinality as x(id, ord)
                   join public.questoes q on q.id = x.id
                   left join public.questoes_gabarito g on g.questao_id = q.id),
    'participantes', (select coalesce(jsonb_agg(jsonb_build_object(
                        'estudante_id', e.id, 'nome', e.nome, 'curso', e.curso, 'turma', e.turma, 'tipo', e.tipo,
                        'tentativa', p.tentativa,
                        'iniciada_em', p.iniciada_em, 'finalizada_em', p.finalizada_em,
                        'encerrado', interno.simulado_encerrado(v_s.id, e.id),
                        'desempenho', interno.desempenho_simulado(v_s.id, e.id)
                      ) order by e.nome), '[]'::jsonb)
                        from public.sessoes_participacao p
                        join public.estudantes e on e.id = p.estudante_id
                       where p.sessao_id = v_s.id and interno.staff_ve_estudante(e.id)),
    -- Tentativa anulada e o aluno ainda não recomeçou.
    'aguardando_nova_tentativa', (select coalesce(jsonb_agg(jsonb_build_object(
                        'estudante_id', e.id, 'nome', e.nome, 'turma', e.turma,
                        'fim', interno.fim_aluno(v_s.id, e.id)) order by e.nome), '[]'::jsonb)
                        from public.estudantes e
                       where interno.staff_ve_estudante(e.id)
                         and exists (select 1 from public.sessoes_liberacoes l
                                      where l.sessao_id = v_s.id and l.estudante_id = e.id)
                         and not exists (select 1 from public.sessoes_participacao p
                                          where p.sessao_id = v_s.id and p.estudante_id = e.id))
  );
end;
$$;

-- (e) Revisão do simulado de um aluno, resposta por resposta.
create or replace function public.revisao_simulado_aluno(p_sessao_id uuid, p_estudante_id uuid)
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_s    public.sessoes;
  v_e    public.estudantes;
  v_part public.sessoes_participacao;
  v_tent integer;
begin
  select * into v_s from public.sessoes where id = p_sessao_id and tipo = 'SIMULADO';
  select * into v_e from public.estudantes where id = p_estudante_id;
  if v_s.id is null or v_e.id is null or not interno.staff_ve_estudante(v_e.id)
     or (v_s.curso is not null and v_s.curso <> v_e.curso) then
    raise exception 'Não encontrado.' using errcode = 'P0002';
  end if;
  select * into v_part from public.sessoes_participacao where sessao_id = v_s.id and estudante_id = v_e.id;
  v_tent := interno.tentativa_atual(v_s.id, v_e.id);

  return jsonb_build_object(
    'sessao', jsonb_build_object('id', v_s.id, 'titulo', v_s.titulo, 'curso', v_s.curso, 'inicio', v_s.inicio,
                                 'fim', v_s.fim, 'duracao_minutos', v_s.duracao_minutos),
    'aluno', jsonb_build_object('id', v_e.id, 'nome', v_e.nome, 'curso', v_e.curso, 'turma', v_e.turma),
    'pode_gerir', interno.gestor_alcanca(v_e.curso),
    'fim_aluno', interno.fim_aluno(v_s.id, v_e.id),
    'participacao', case when v_part.sessao_id is not null then jsonb_build_object(
                      'tentativa', v_part.tentativa, 'iniciada_em', v_part.iniciada_em,
                      'finalizada_em', v_part.finalizada_em,
                      'encerrado', interno.simulado_encerrado(v_s.id, v_e.id)) end,
    'desempenho', case when v_part.sessao_id is not null then interno.desempenho_simulado(v_s.id, v_e.id) end,
    'questoes', (select jsonb_agg(jsonb_build_object(
                   'numero', x.ord, 'id', q.id, 'componente', q.componente, 'eixo', q.eixo, 'formato', q.formato,
                   'enunciado', q.enunciado, 'gabarito', g.gabarito,
                   'resposta_id', r.id, 'alternativa', r.alternativa, 'resposta_texto', r.resposta_texto,
                   'correta', r.correta, 'tempo_segundos', r.tempo_segundos,
                   'nota', c.nota, 'comentario', c.comentario,
                   'pontos', coalesce(r.pontos_ganhos, 0) + coalesce(c.pontos, 0))
                 order by x.ord)
                   from unnest(v_s.questoes) with ordinality as x(id, ord)
                   join public.questoes q on q.id = x.id
                   left join public.questoes_gabarito g on g.questao_id = q.id
                   left join public.respostas r on r.sessao_id = v_s.id and r.estudante_id = v_e.id
                                               and r.questao_id = q.id and r.tentativa_sessao = v_tent
                   left join public.correcoes_discursivas c on c.resposta_id = r.id),
    'anuladas', (select coalesce(jsonb_agg(jsonb_build_object(
                   'tentativa', l.tentativa, 'iniciada_em', l.iniciada_em, 'finalizada_em', l.finalizada_em,
                   'nota', l.desempenho->'nota', 'respondidas', l.desempenho->'respondidas',
                   'motivo', l.motivo, 'prazo', l.prazo, 'liberada_em', l.liberada_em,
                   'liberada_por', (select st.nome from public.staff st where st.user_id = l.liberada_por))
                 order by l.tentativa), '[]'::jsonb)
                   from public.sessoes_liberacoes l
                  where l.sessao_id = v_s.id and l.estudante_id = v_e.id)
  );
end;
$$;

-- -----------------------------------------------------------------------------
-- (f) Importação de questões em lote
-- Cada linha passa pelas mesmas regras de salvar_questao. Com p_simular, nada é
-- gravado e a função devolve os erros por linha. Na importação real, qualquer
-- erro cancela o lote inteiro.
-- -----------------------------------------------------------------------------
create or replace function public.importar_questoes(p_linhas jsonb, p_simular boolean default true)
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_item  jsonb;
  v_i     integer := 0;
  v_ok    integer := 0;
  v_erros jsonb := '[]'::jsonb;
begin
  if not interno.is_gestor() then
    raise exception 'Acesso restrito à coordenação.' using errcode = '42501';
  end if;
  if jsonb_typeof(p_linhas) <> 'array' or jsonb_array_length(p_linhas) = 0 then
    raise exception 'A planilha não tem linhas para importar.';
  end if;
  if jsonb_array_length(p_linhas) > 500 then
    raise exception 'Importe no máximo 500 questões por vez.';
  end if;

  for v_item in select value from jsonb_array_elements(p_linhas) loop
    v_i := v_i + 1;
    begin
      perform public.salvar_questao((v_item - 'id') - '_linha');
      if p_simular then
        raise exception 'simulacao' using errcode = 'P0099';  -- desfaz só esta linha
      end if;
      v_ok := v_ok + 1;
    exception
      when sqlstate 'P0099' then
        v_ok := v_ok + 1;
      when others then
        v_erros := v_erros || jsonb_build_object('linha', coalesce((v_item->>'_linha')::int, v_i), 'erro', sqlerrm);
    end;
  end loop;

  if not p_simular then
    if jsonb_array_length(v_erros) > 0 then
      raise exception 'Importação cancelada: % linha(s) com erro. Nada foi salvo.', jsonb_array_length(v_erros);
    end if;
    perform interno.auditar('QUESTOES_IMPORTADAS', 'QUESTAO', null, jsonb_build_object('quantidade', v_ok));
  end if;
  return jsonb_build_object('validas', v_ok, 'erros', v_erros);
end;
$$;

-- -----------------------------------------------------------------------------
-- Privilégios
-- -----------------------------------------------------------------------------
revoke all on function interno.auditar(text, text, text, jsonb), interno.config_limites(),
                       interno.desempenho_simulado(uuid, uuid)
  from public, anon, authenticated;
grant execute on function interno.fim_aluno(uuid, uuid), interno.tentativa_atual(uuid, uuid),
                          interno.simulado_encerrado(uuid, uuid), interno.simulado_liberado(uuid, uuid)
  to authenticated;

revoke all on function public.salvar_config(jsonb, boolean), public.atualizar_estudante(uuid, jsonb),
                       public.liberar_nova_tentativa(uuid, uuid, text, timestamptz),
                       public.revisao_simulado_aluno(uuid, uuid), public.importar_questoes(jsonb, boolean),
                       public.iniciar_simulado(uuid), public.responder_questao(uuid, text, text, uuid),
                       public.finalizar_simulado(uuid), public.meus_simulados(), public.resultado_simulado(uuid),
                       public.relatorio_simulado(uuid), public.excluir_simulado(uuid), public.devolutiva_questao(uuid)
  from public, anon;
grant execute on function public.salvar_config(jsonb, boolean), public.atualizar_estudante(uuid, jsonb),
                          public.liberar_nova_tentativa(uuid, uuid, text, timestamptz),
                          public.revisao_simulado_aluno(uuid, uuid), public.importar_questoes(jsonb, boolean),
                          public.iniciar_simulado(uuid), public.responder_questao(uuid, text, text, uuid),
                          public.finalizar_simulado(uuid), public.meus_simulados(), public.resultado_simulado(uuid),
                          public.relatorio_simulado(uuid), public.excluir_simulado(uuid), public.devolutiva_questao(uuid)
  to authenticated;
