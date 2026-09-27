-- =============================================================================
-- Migration 3/3: Row Level Security, políticas e privilégios
--
-- Modelo:
--   * anon: não acessa nada.
--   * aluno (authenticated sem linha em staff): lê só o que é seu; NUNCA lê
--     questoes nem questoes_gabarito diretamente — recebe questões e devolutiva
--     apenas pelas RPCs SECURITY DEFINER. Não escreve em nenhuma tabela.
--   * DOCENTE: leitura ampla para correção; escreve via corrigir_discursiva.
--   * ADMIN: CRUD de questões, gabaritos, matrículas, sessões e config.
-- =============================================================================

-- Trigger functions rodam como dono, para não depender das políticas do chamador.
alter function interno.tg_questoes_peso()       security definer set search_path = '';
alter function interno.tg_questoes_publicacao() security definer set search_path = '';
alter function interno.tg_gabarito_protege()    security definer set search_path = '';
alter function interno.tg_sessoes_valida()      security definer set search_path = '';

-- Simulado encerrado para o aluno (finalizou, ou o tempo acabou)?
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
            or now() > s.fim
            or now() > p.iniciada_em + make_interval(mins => s.duracao_minutos))
  );
$$;

-- -----------------------------------------------------------------------------
-- RLS em TODAS as tabelas
-- -----------------------------------------------------------------------------
alter table public.staff                  enable row level security;
alter table public.matriculas_autorizadas enable row level security;
alter table public.estudantes             enable row level security;
alter table public.questoes               enable row level security;
alter table public.questoes_gabarito      enable row level security;
alter table public.sessoes                enable row level security;
alter table public.sessoes_participacao   enable row level security;
alter table public.exibicoes_questao      enable row level security;
alter table public.respostas              enable row level security;
alter table public.correcoes_discursivas  enable row level security;
alter table public.config                 enable row level security;
alter table public.conquistas             enable row level security;
alter table public.conquistas_estudante   enable row level security;

-- -----------------------------------------------------------------------------
-- Privilégios de tabela (camada anterior ao RLS)
-- -----------------------------------------------------------------------------
revoke all on all tables    in schema public from anon;
revoke all on all sequences in schema public from anon;
revoke all on all tables    in schema public from authenticated;

grant select, insert, update, delete on public.staff                  to authenticated;
grant select, insert, update, delete on public.matriculas_autorizadas to authenticated;
grant select, update                 on public.estudantes             to authenticated;
grant select, insert, update, delete on public.questoes               to authenticated;
grant select, insert, update, delete on public.questoes_gabarito      to authenticated;
grant select, insert, update, delete on public.sessoes                to authenticated;
grant select                         on public.sessoes_participacao   to authenticated;
grant select                         on public.exibicoes_questao      to authenticated;
grant select                         on public.respostas              to authenticated;  -- nunca insert/update/delete
grant select                         on public.correcoes_discursivas  to authenticated;
grant select, insert, update         on public.config                 to authenticated;
grant select, insert, update, delete on public.conquistas             to authenticated;
grant select                         on public.conquistas_estudante   to authenticated;

-- -----------------------------------------------------------------------------
-- Políticas
-- -----------------------------------------------------------------------------

-- staff
create policy staff_select on public.staff for select to authenticated
  using (user_id = auth.uid() or interno.is_admin());
create policy staff_admin_write on public.staff for all to authenticated
  using (interno.is_admin()) with check (interno.is_admin());

-- matriculas_autorizadas: só coordenação
create policy matriculas_admin on public.matriculas_autorizadas for all to authenticated
  using (interno.is_admin()) with check (interno.is_admin());

-- estudantes: aluno vê a si mesmo; equipe vê todos; só ADMIN altera (ex.: bloquear).
-- Inserção apenas por concluir_cadastro().
create policy estudantes_select on public.estudantes for select to authenticated
  using (id = auth.uid() or interno.is_staff());
create policy estudantes_admin_update on public.estudantes for update to authenticated
  using (interno.is_admin()) with check (interno.is_admin());

-- questoes: aluno NÃO lê a tabela (usa exibir_questao / proxima_questao_treino).
create policy questoes_staff_select on public.questoes for select to authenticated
  using (interno.is_staff());
create policy questoes_admin_insert on public.questoes for insert to authenticated
  with check (interno.is_admin());
create policy questoes_admin_update on public.questoes for update to authenticated
  using (interno.is_admin()) with check (interno.is_admin());
create policy questoes_admin_delete on public.questoes for delete to authenticated
  using (interno.is_admin());

-- questoes_gabarito: aluno jamais lê. Docente lê (padrão de resposta p/ correção).
create policy gabarito_staff_select on public.questoes_gabarito for select to authenticated
  using (interno.is_staff());
create policy gabarito_admin_insert on public.questoes_gabarito for insert to authenticated
  with check (interno.is_admin());
create policy gabarito_admin_update on public.questoes_gabarito for update to authenticated
  using (interno.is_admin()) with check (interno.is_admin());
create policy gabarito_admin_delete on public.questoes_gabarito for delete to authenticated
  using (interno.is_admin());

-- sessoes: aluno vê as publicadas do seu curso (ou abertas a todos).
create policy sessoes_select on public.sessoes for select to authenticated
  using (
    interno.is_staff()
    or (publicada and (curso is null or curso = (select e.curso from public.estudantes e where e.id = auth.uid())))
  );
create policy sessoes_admin_insert on public.sessoes for insert to authenticated
  with check (interno.is_admin());
create policy sessoes_admin_update on public.sessoes for update to authenticated
  using (interno.is_admin()) with check (interno.is_admin());
create policy sessoes_admin_delete on public.sessoes for delete to authenticated
  using (interno.is_admin());

create policy participacao_select on public.sessoes_participacao for select to authenticated
  using (estudante_id = auth.uid() or interno.is_staff());

create policy exibicoes_staff_select on public.exibicoes_questao for select to authenticated
  using (interno.is_staff());

-- respostas: aluno lê as próprias, EXCETO as de simulado ainda em andamento
-- (a coluna "correta" seria devolutiva durante a prova).
create policy respostas_select on public.respostas for select to authenticated
  using (
    interno.is_staff()
    or (estudante_id = auth.uid()
        and (sessao_id is null or interno.simulado_encerrado(sessao_id, estudante_id)))
  );

create policy correcoes_select on public.correcoes_discursivas for select to authenticated
  using (
    interno.is_staff()
    or exists (select 1 from public.respostas r
                where r.id = resposta_id and r.estudante_id = auth.uid()
                  and (r.sessao_id is null or interno.simulado_encerrado(r.sessao_id, r.estudante_id)))
  );

-- config: todos os logados leem (transparência das regras); só ADMIN edita.
create policy config_select on public.config for select to authenticated using (true);
create policy config_admin_insert on public.config for insert to authenticated
  with check (interno.is_admin());
create policy config_admin_update on public.config for update to authenticated
  using (interno.is_admin()) with check (interno.is_admin());

-- conquistas
create policy conquistas_select on public.conquistas for select to authenticated using (true);
create policy conquistas_admin_write on public.conquistas for all to authenticated
  using (interno.is_admin()) with check (interno.is_admin());

create policy conquistas_estudante_select on public.conquistas_estudante for select to authenticated
  using (estudante_id = auth.uid() or interno.is_staff());

-- -----------------------------------------------------------------------------
-- Privilégios de função
-- -----------------------------------------------------------------------------
revoke all on all functions in schema public  from public, anon, authenticated;
revoke all on all functions in schema interno from public, anon, authenticated;
revoke all on schema interno from public;

-- Necessário para avaliar as políticas (o schema não é exposto pela API).
grant usage on schema interno to authenticated;
grant execute on function interno.is_admin()                      to authenticated;
grant execute on function interno.is_staff()                      to authenticated;
grant execute on function interno.simulado_encerrado(uuid, uuid)  to authenticated;

grant execute on function public.concluir_cadastro(text, boolean)                         to authenticated;
grant execute on function public.registrar_acesso()                                       to authenticated;
grant execute on function public.eixos_disponiveis()                                      to authenticated;
grant execute on function public.exibir_questao(uuid)                                     to authenticated;
grant execute on function public.proxima_questao_treino(public.componente, text, smallint, boolean) to authenticated;
grant execute on function public.responder_questao(uuid, text, text, uuid)                to authenticated;
grant execute on function public.devolutiva_questao(uuid)                                 to authenticated;
grant execute on function public.iniciar_simulado(uuid)                                   to authenticated;
grant execute on function public.finalizar_simulado(uuid)                                 to authenticated;
grant execute on function public.corrigir_discursiva(uuid, numeric, text)                 to authenticated;
grant execute on function public.excluir_estudante_lgpd(uuid)                             to authenticated;

-- Funções criadas no futuro em public não ficam executáveis por padrão.
alter default privileges in schema public revoke execute on functions from public, anon, authenticated;
