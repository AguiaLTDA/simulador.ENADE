-- =============================================================================
-- Migration 6: Diagnóstico inicial de habilidades
--
-- Questionário básico (Português, Atualidades, Matemática/raciocínio lógico).
-- * O aluno responde uma vez, sem devolutiva. O resultado (nível por área) só
--   é visível para a equipe (staff).
-- * Ao concluir: badge DIAGNOSTICO_INICIAL + pontos (config pontos_diagnostico),
--   concedidos pela participação — não dependem de acertos (erro não penaliza).
-- * pontos_extras: pontuação que não vem de respostas de questões; o ranking
--   (Sprint 5) soma respostas + correções de discursivas + pontos_extras.
-- =============================================================================

create type public.area_diagnostico as enum ('PORTUGUES', 'ATUALIDADES', 'MATEMATICA');

create table public.diagnostico_questoes (
  id          uuid primary key default gen_random_uuid(),
  area        public.area_diagnostico not null,
  ordem       integer not null,
  habilidade  text not null,           -- o que a questão avalia (para relatório)
  texto_apoio text,
  enunciado   text not null,
  alt_a text not null, alt_b text not null, alt_c text not null, alt_d text not null, alt_e text not null,
  ativa       boolean not null default true,
  criado_em   timestamptz not null default now(),
  unique (area, ordem)
);

create table public.diagnostico_gabarito (
  questao_id uuid primary key references public.diagnostico_questoes (id) on delete cascade,
  gabarito   char(1) not null check (gabarito in ('A', 'B', 'C', 'D', 'E'))
);

-- Uma linha por aluno: criada ao iniciar, concluída ao responder a última questão.
create table public.diagnostico_resultados (
  estudante_id  uuid primary key references public.estudantes (id) on delete cascade,
  iniciado_em   timestamptz not null default now(),
  concluido_em  timestamptz,
  resultado     jsonb,          -- { AREA: {acertos, total, percentual, nivel} }
  acertos       integer,
  total         integer,
  pontos        integer
);

create table public.diagnostico_respostas (
  id            bigint generated always as identity primary key,
  estudante_id  uuid not null references public.estudantes (id) on delete cascade,
  questao_id    uuid not null references public.diagnostico_questoes (id) on delete restrict,
  alternativa   char(1) not null check (alternativa in ('A', 'B', 'C', 'D', 'E')),
  correta       boolean not null,
  criado_em     timestamptz not null default now(),
  unique (estudante_id, questao_id)
);

-- Append-only, como respostas (mesma exceção para exclusão LGPD).
create trigger diagnostico_respostas_append_only_row
  before update or delete on public.diagnostico_respostas
  for each row execute function interno.tg_respostas_append_only();

create table public.pontos_extras (
  id            bigint generated always as identity primary key,
  estudante_id  uuid not null references public.estudantes (id) on delete cascade,
  origem        text not null,
  pontos        integer not null check (pontos >= 0),
  criado_em     timestamptz not null default now(),
  unique (estudante_id, origem)
);

insert into public.config (chave, valor, descricao) values
  ('pontos_diagnostico',               '50', 'Pontos por concluir o diagnóstico inicial (independe de acertos)'),
  ('diagnostico_corte_intermediario',  '50', 'Percentual mínimo de acertos para o nível Intermediário'),
  ('diagnostico_corte_avancado',       '80', 'Percentual mínimo de acertos para o nível Avançado')
on conflict (chave) do nothing;

insert into public.conquistas (codigo, nome, descricao, icone, ordem) values
  ('DIAGNOSTICO_INICIAL', 'Ponto de partida', 'Concluiu o diagnóstico inicial de habilidades', 'target', 0)
on conflict (codigo) do nothing;

-- -----------------------------------------------------------------------------
-- RLS: aluno não lê nada disto diretamente (nem gabarito, nem resultado).
-- -----------------------------------------------------------------------------
alter table public.diagnostico_questoes   enable row level security;
alter table public.diagnostico_gabarito   enable row level security;
alter table public.diagnostico_resultados enable row level security;
alter table public.diagnostico_respostas  enable row level security;
alter table public.pontos_extras          enable row level security;

revoke all on public.diagnostico_questoes, public.diagnostico_gabarito, public.diagnostico_resultados,
              public.diagnostico_respostas, public.pontos_extras from anon, authenticated;
grant select on public.diagnostico_questoes, public.diagnostico_gabarito, public.diagnostico_resultados,
                public.diagnostico_respostas to authenticated;
grant insert, update on public.diagnostico_questoes, public.diagnostico_gabarito to authenticated;
grant select on public.pontos_extras to authenticated;

create policy diag_questoes_staff   on public.diagnostico_questoes   for select to authenticated using (interno.is_staff());
create policy diag_questoes_admin_i on public.diagnostico_questoes   for insert to authenticated with check (interno.is_admin());
create policy diag_questoes_admin_u on public.diagnostico_questoes   for update to authenticated
  using (interno.is_admin()) with check (interno.is_admin());
create policy diag_gabarito_staff   on public.diagnostico_gabarito   for select to authenticated using (interno.is_staff());
create policy diag_gabarito_admin_i on public.diagnostico_gabarito   for insert to authenticated with check (interno.is_admin());
create policy diag_gabarito_admin_u on public.diagnostico_gabarito   for update to authenticated
  using (interno.is_admin()) with check (interno.is_admin());
create policy diag_resultados_staff on public.diagnostico_resultados for select to authenticated using (interno.is_staff());
create policy diag_respostas_staff  on public.diagnostico_respostas  for select to authenticated using (interno.is_staff());
create policy pontos_extras_select  on public.pontos_extras          for select to authenticated
  using (estudante_id = auth.uid() or interno.is_staff());

-- -----------------------------------------------------------------------------
-- Funções
-- -----------------------------------------------------------------------------
create or replace function interno.nivel_diagnostico(p_percentual numeric)
returns text
language sql stable security definer set search_path = ''
as $$
  select case
    when p_percentual >= interno.cfg_num('diagnostico_corte_avancado')      then 'AVANCADO'
    when p_percentual >= interno.cfg_num('diagnostico_corte_intermediario') then 'INTERMEDIARIO'
    else 'INICIAL'
  end;
$$;

-- Estado do diagnóstico do aluno logado (sem revelar acertos).
create or replace function interno.diagnostico_estado(p_estudante uuid)
returns jsonb
language sql stable security definer set search_path = ''
as $$
  select jsonb_build_object(
    'iniciado',    exists (select 1 from public.diagnostico_resultados where estudante_id = p_estudante),
    'concluido',   exists (select 1 from public.diagnostico_resultados
                            where estudante_id = p_estudante and concluido_em is not null),
    'respondidas', (select count(*) from public.diagnostico_respostas r
                      join public.diagnostico_questoes q on q.id = r.questao_id and q.ativa
                     where r.estudante_id = p_estudante),
    'total',       (select count(*) from public.diagnostico_questoes where ativa)
  );
$$;

-- Inicia (ou retoma) o diagnóstico. Devolve as questões sem gabarito.
create or replace function public.iniciar_diagnostico()
returns jsonb
language plpgsql volatile security definer set search_path = ''
as $$
declare
  v_est public.estudantes := interno.estudante_ativo();
begin
  if exists (select 1 from public.diagnostico_resultados where estudante_id = v_est.id and concluido_em is not null) then
    return interno.diagnostico_estado(v_est.id) || jsonb_build_object('questoes', '[]'::jsonb, 'respondidas_ids', '[]'::jsonb);
  end if;

  insert into public.diagnostico_resultados (estudante_id) values (v_est.id)
  on conflict (estudante_id) do nothing;

  return interno.diagnostico_estado(v_est.id) || jsonb_build_object(
    'questoes', (select coalesce(jsonb_agg(jsonb_build_object(
                    'id', q.id, 'area', q.area, 'texto_apoio', q.texto_apoio, 'enunciado', q.enunciado,
                    'alternativas', jsonb_build_object('A', q.alt_a, 'B', q.alt_b, 'C', q.alt_c, 'D', q.alt_d, 'E', q.alt_e))
                  order by q.area, q.ordem), '[]'::jsonb)
                   from public.diagnostico_questoes q where q.ativa),
    'respondidas_ids', (select coalesce(jsonb_agg(r.questao_id), '[]'::jsonb)
                          from public.diagnostico_respostas r where r.estudante_id = v_est.id)
  );
end;
$$;

-- Grava uma resposta (sem devolutiva). Na última, conclui: calcula o nível por
-- área (visível só à equipe), concede o badge e os pontos de participação.
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
  v_result  jsonb;
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

  -- Conclusão
  select jsonb_object_agg(area, jsonb_build_object(
           'acertos', acertos, 'total', total,
           'percentual', round(100.0 * acertos / total, 1),
           'nivel', interno.nivel_diagnostico(100.0 * acertos / total)))
    into v_result
    from (select q.area::text as area,
                 count(*) filter (where r.correta) as acertos,
                 count(*) as total
            from public.diagnostico_questoes q
            join public.diagnostico_respostas r on r.questao_id = q.id and r.estudante_id = v_est.id
           where q.ativa
           group by q.area) t;

  v_pontos := round(interno.cfg_num('pontos_diagnostico'))::integer;

  update public.diagnostico_resultados
     set concluido_em = clock_timestamp(),
         resultado    = v_result,
         acertos      = (select sum((x.value->>'acertos')::int) from jsonb_each(v_result) x),
         total        = (select sum((x.value->>'total')::int) from jsonb_each(v_result) x),
         pontos       = v_pontos
   where estudante_id = v_est.id;

  insert into public.pontos_extras (estudante_id, origem, pontos)
  values (v_est.id, 'DIAGNOSTICO_INICIAL', v_pontos)
  on conflict (estudante_id, origem) do nothing;

  insert into public.conquistas_estudante (estudante_id, conquista)
  values (v_est.id, 'DIAGNOSTICO_INICIAL')
  on conflict do nothing;

  return jsonb_build_object('registrada', true, 'concluido', true,
                            'respondidas', v_estado->'respondidas', 'total', v_estado->'total',
                            'pontos', v_pontos, 'conquista', 'DIAGNOSTICO_INICIAL');
end;
$$;

-- Resumo do perfil do aluno logado.
create or replace function public.meu_resumo()
returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_est public.estudantes := interno.estudante_ativo();
begin
  return jsonb_build_object(
    'pontos', coalesce((select sum(pontos_ganhos) from public.respostas where estudante_id = v_est.id), 0)
            + coalesce((select sum(c.pontos) from public.correcoes_discursivas c
                          join public.respostas r on r.id = c.resposta_id
                         where r.estudante_id = v_est.id), 0)
            + coalesce((select sum(pontos) from public.pontos_extras where estudante_id = v_est.id), 0),
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

revoke all on function interno.nivel_diagnostico(numeric), interno.diagnostico_estado(uuid) from public, anon, authenticated;
revoke all on function public.iniciar_diagnostico(), public.responder_diagnostico(uuid, text), public.meu_resumo()
  from public, anon;
grant execute on function public.iniciar_diagnostico()                to authenticated;
grant execute on function public.responder_diagnostico(uuid, text)    to authenticated;
grant execute on function public.meu_resumo()                         to authenticated;

-- -----------------------------------------------------------------------------
-- Banco de questões do diagnóstico (nível básico).
-- Autoria própria, inspirada nas competências da Formação Geral do ENADE e nas
-- matrizes de referência do ENEM (Linguagens e Matemática) e do SAEB. Revisar
-- com o NDE antes do uso em larga escala.
-- -----------------------------------------------------------------------------
create or replace function interno.seed_diag(
  p_area public.area_diagnostico, p_ordem int, p_habilidade text, p_apoio text, p_enunciado text,
  a text, b text, c text, d text, e text, p_gabarito char
) returns void
language plpgsql
as $$
declare v_id uuid;
begin
  insert into public.diagnostico_questoes (area, ordem, habilidade, texto_apoio, enunciado, alt_a, alt_b, alt_c, alt_d, alt_e)
  values (p_area, p_ordem, p_habilidade, p_apoio, p_enunciado, a, b, c, d, e)
  on conflict (area, ordem) do nothing
  returning id into v_id;
  if v_id is not null then
    insert into public.diagnostico_gabarito (questao_id, gabarito) values (v_id, p_gabarito);
  end if;
end;
$$;

-- ---------------- PORTUGUÊS ----------------
select interno.seed_diag('PORTUGUES', 1, 'Compreensão de texto: ideia principal',
  'Estudar um pouco todos os dias costuma trazer resultados melhores do que estudar muitas horas apenas na véspera da prova. Isso acontece porque a memória se fortalece quando o mesmo conteúdo é revisto em intervalos.',
  'De acordo com o texto:',
  'estudar muitas horas na véspera é a melhor estratégia.',
  'rever o conteúdo em intervalos ajuda a fortalecer a memória.',
  'a memória não depende de revisão.',
  'estudar todos os dias prejudica o desempenho.',
  'apenas quem estuda muitas horas seguidas obtém bons resultados.', 'B');

select interno.seed_diag('PORTUGUES', 2, 'Ortografia', null,
  'Assinale a alternativa em que a palavra está escrita corretamente.',
  'excessão', 'exceção', 'excesão', 'esseção', 'exeção', 'B');

select interno.seed_diag('PORTUGUES', 3, 'Vocabulário: sinonímia',
  'O professor foi sucinto na explicação e terminou a aula no horário.',
  'A palavra "sucinto", no trecho acima, tem sentido equivalente a:',
  'prolixo.', 'breve.', 'confuso.', 'grosseiro.', 'demorado.', 'B');

select interno.seed_diag('PORTUGUES', 4, 'Uso de "mas" e "mais"', null,
  'Complete corretamente: "Estudei bastante, ______ não consegui terminar a prova a tempo."',
  'mais', 'mas', 'mau', 'mal', 'más', 'B');

select interno.seed_diag('PORTUGUES', 5, 'Coesão: referência pronominal',
  'Os alunos chegaram cedo ao auditório. Eles queriam garantir um bom lugar para assistir à palestra.',
  'No texto, o pronome "Eles" retoma:',
  'o auditório.', 'os alunos.', 'a palestra.', 'o lugar.', 'o palestrante.', 'B');

select interno.seed_diag('PORTUGUES', 6, 'Pontuação: vocativo', null,
  'Assinale a frase pontuada corretamente.',
  'Maria, feche a porta, por favor.',
  'Maria feche, a porta por favor.',
  'Maria feche a porta por, favor.',
  'Maria, feche, a porta por favor.',
  'Maria feche a, porta, por favor.', 'A');

select interno.seed_diag('PORTUGUES', 7, 'Gêneros textuais: finalidade', null,
  'A principal finalidade de uma bula de remédio é:',
  'contar uma história ficcional.',
  'orientar sobre o uso correto e os cuidados com o medicamento.',
  'convencer o leitor a votar em um candidato.',
  'divulgar notícias do dia.',
  'expressar sentimentos do autor em versos.', 'B');

select interno.seed_diag('PORTUGUES', 8, 'Uso de "por que"', null,
  'Complete corretamente: "______ você faltou à aula ontem?"',
  'Porque', 'Por que', 'Porquê', 'Por quê', 'Por-que', 'B');

select interno.seed_diag('PORTUGUES', 9, 'Concordância verbal (norma-padrão)', null,
  'Assinale a frase que está de acordo com a norma-padrão da língua portuguesa.',
  'Haviam muitos alunos na palestra.',
  'Faz dois anos que me formei.',
  'Fazem dois anos que me formei.',
  'Existia muitos problemas na obra.',
  'Houveram várias reclamações.', 'B');

select interno.seed_diag('PORTUGUES', 10, 'Crase', null,
  'Complete corretamente: "Hoje vou ___ biblioteca e, depois, volto ___ casa."',
  'à / à', 'a / à', 'à / a', 'a / a', 'há / a', 'C');

-- ---------------- ATUALIDADES E CONHECIMENTOS GERAIS ----------------
select interno.seed_diag('ATUALIDADES', 1, 'Leitura crítica: desinformação', null,
  'Antes de compartilhar uma notícia recebida por aplicativo de mensagens, a atitude mais adequada é:',
  'compartilhar logo, para que todos saibam o quanto antes.',
  'verificar a fonte e conferir se veículos confiáveis confirmam a informação.',
  'confiar na notícia se ela tiver muitos compartilhamentos.',
  'acreditar sempre que o texto estiver em letras maiúsculas.',
  'repassar apenas para familiares, pois assim não há problema.', 'B');

select interno.seed_diag('ATUALIDADES', 2, 'Sustentabilidade: Agenda 2030', null,
  'A Agenda 2030 da Organização das Nações Unidas (ONU) reúne quantos Objetivos de Desenvolvimento Sustentável (ODS)?',
  '8', '10', '12', '17', '20', 'D');

select interno.seed_diag('ATUALIDADES', 3, 'Cidadania digital: LGPD', null,
  'A Lei Geral de Proteção de Dados Pessoais (LGPD — Lei nº 13.709/2018) trata principalmente:',
  'das regras de trânsito nas cidades.',
  'do tratamento e da proteção de dados pessoais.',
  'do cálculo do imposto de renda.',
  'da organização dos campeonatos esportivos.',
  'dos direitos autorais de músicas.', 'B');

select interno.seed_diag('ATUALIDADES', 4, 'Meio ambiente: efeito estufa', null,
  'Qual gás, liberado em grande quantidade pela queima de combustíveis fósseis, é o principal responsável pelo agravamento do efeito estufa?',
  'Oxigênio (O₂)', 'Nitrogênio (N₂)', 'Dióxido de carbono (CO₂)', 'Hélio (He)', 'Hidrogênio (H₂)', 'C');

select interno.seed_diag('ATUALIDADES', 5, 'Cidadania: Constituição Federal', null,
  'A Constituição Federal brasileira atualmente em vigor foi promulgada em:',
  '1946', '1964', '1988', '1998', '2002', 'C');

select interno.seed_diag('ATUALIDADES', 6, 'Políticas públicas: SUS', null,
  'Um dos princípios do Sistema Único de Saúde (SUS) é a universalidade, que significa:',
  'garantir o acesso à saúde a todas as pessoas.',
  'atender apenas quem tem plano de saúde.',
  'atender somente pessoas acima de 60 anos.',
  'cobrar por todos os atendimentos.',
  'funcionar apenas nas capitais.', 'A');

select interno.seed_diag('ATUALIDADES', 7, 'Tecnologia e sociedade: inteligência artificial', null,
  'Um risco frequentemente apontado no uso de ferramentas de inteligência artificial que geram textos é:',
  'produzir informações falsas com aparência de verdadeiras.',
  'nunca cometer erros.',
  'funcionar sem utilizar nenhum dado.',
  'dispensar o uso de energia elétrica.',
  'impedir automaticamente qualquer plágio.', 'A');

select interno.seed_diag('ATUALIDADES', 8, 'Cidadania: direito ao voto', null,
  'No Brasil, o voto é facultativo (não obrigatório) para jovens de:',
  '14 e 15 anos.', '16 e 17 anos.', '18 a 20 anos.', '21 a 25 anos.', '30 a 35 anos.', 'B');

select interno.seed_diag('ATUALIDADES', 9, 'Economia: inflação', null,
  'Em economia, "inflação" é:',
  'o aumento generalizado e contínuo dos preços.',
  'a queda de todos os preços da economia.',
  'o aumento do número de empregos.',
  'a redução dos impostos.',
  'o valor do salário mínimo.', 'A');

select interno.seed_diag('ATUALIDADES', 10, 'Diversidade e inclusão: Libras', null,
  'A Língua Brasileira de Sinais (Libras) é reconhecida por lei federal como:',
  'meio legal de comunicação e expressão da comunidade surda.',
  'o único idioma oficial do Brasil.',
  'uma linguagem proibida nas escolas.',
  'um código usado apenas em hospitais.',
  'um dialeto regional do Nordeste.', 'A');

-- ---------------- MATEMÁTICA E RACIOCÍNIO LÓGICO ----------------
select interno.seed_diag('MATEMATICA', 1, 'Porcentagem', null,
  'Quanto é 20% de 150?',
  '15', '20', '30', '35', '50', 'C');

select interno.seed_diag('MATEMATICA', 2, 'Porcentagem: desconto', null,
  'Um produto custa R$ 80,00 e está com 25% de desconto. Qual é o preço com desconto?',
  'R$ 55,00', 'R$ 60,00', 'R$ 65,00', 'R$ 70,00', 'R$ 75,00', 'B');

select interno.seed_diag('MATEMATICA', 3, 'Proporcionalidade: regra de três', null,
  'Três cadernos iguais custam R$ 12,00. Quanto custam cinco desses cadernos?',
  'R$ 15,00', 'R$ 18,00', 'R$ 20,00', 'R$ 24,00', 'R$ 25,00', 'C');

select interno.seed_diag('MATEMATICA', 4, 'Sequências numéricas', null,
  'Qual é o próximo número da sequência 2, 5, 8, 11, ...?',
  '12', '13', '14', '15', '16', 'C');

select interno.seed_diag('MATEMATICA', 5, 'Sequências: padrão multiplicativo', null,
  'Qual é o próximo número da sequência 1, 2, 4, 8, 16, ...?',
  '18', '24', '30', '32', '36', 'D');

select interno.seed_diag('MATEMATICA', 6, 'Raciocínio lógico: dedução', null,
  'Considere as afirmações: "Todo engenheiro estudou cálculo" e "Paulo é engenheiro". Pode-se concluir que:',
  'Paulo estudou cálculo.',
  'Paulo não estudou cálculo.',
  'todo mundo que estudou cálculo é engenheiro.',
  'Paulo é professor de cálculo.',
  'nada se pode concluir sobre Paulo.', 'A');

select interno.seed_diag('MATEMATICA', 7, 'Raciocínio lógico: negação', null,
  'Qual é a negação lógica da frase "Todos os alunos passaram na prova"?',
  'Nenhum aluno passou na prova.',
  'Todos os alunos reprovaram.',
  'Pelo menos um aluno não passou na prova.',
  'Alguns alunos passaram na prova.',
  'Somente um aluno passou na prova.', 'C');

select interno.seed_diag('MATEMATICA', 8, 'Estatística básica: média', null,
  'Um estudante tirou as notas 6, 7, 8 e 9. Qual é a média aritmética dessas notas?',
  '7,0', '7,5', '8,0', '8,5', '30', 'B');

select interno.seed_diag('MATEMATICA', 9, 'Frações', null,
  'Uma turma tem 40 alunos e 3/4 deles compareceram à aula. Quantos alunos compareceram?',
  '10', '25', '30', '32', '35', 'C');

select interno.seed_diag('MATEMATICA', 10, 'Grandezas e medidas: tempo', null,
  'Duas horas e meia correspondem a quantos minutos?',
  '125', '130', '150', '200', '250', 'C');

drop function interno.seed_diag(public.area_diagnostico, int, text, text, text, text, text, text, text, text, char);
