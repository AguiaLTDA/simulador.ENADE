-- Dados de DESENVOLVIMENTO (rodam só em `supabase db reset` local).
-- A config e o catálogo de conquistas de produção estão nas migrations.

insert into public.matriculas_autorizadas (matricula, nome, curso, turma, tipo, cpf, data_nascimento) values
  -- CPFs fictícios (dígitos verificadores válidos)
  ('DEV0001', 'Estudante Mecânica (dev)', 'ENG_MEC',  'MEC-DEV',  'CONCLUINTE', '12345678909', '2000-01-01'),
  ('DEV0002', 'Estudante Produção (dev)', 'ENG_PROD', 'PROD-DEV', 'CONCLUINTE', '98765432100', '2000-01-01'),
  ('DEV0003', 'Estudante ADS (dev)',      'ADS',      'ADS-DEV',  'CONCLUINTE', '11144477735', '2000-01-01')
on conflict (matricula) do nothing;

do $$
declare
  v_id uuid;
begin
  insert into public.questoes (componente, cursos, eixo, enunciado, alt_a, alt_b, alt_c, alt_d, alt_e, dificuldade, fonte)
  values ('FG', '{ALL}', 'Ética e cidadania',
          'Exemplo de questão de Formação Geral. Qual alternativa está correta?',
          'Alternativa A', 'Alternativa B', 'Alternativa C', 'Alternativa D', 'Alternativa E', 2, 'Seed de desenvolvimento')
  returning id into v_id;
  insert into public.questoes_gabarito (questao_id, gabarito, justificativa)
  values (v_id, 'B', 'Justificativa de exemplo.');
  update public.questoes set status = 'PUBLICADA' where id = v_id;

  insert into public.questoes (componente, cursos, eixo, enunciado, alt_a, alt_b, alt_c, alt_d, alt_e, dificuldade, fonte)
  values ('CE', '{ENG_MEC,ENG_PROD}', 'Cálculo',
          'Exemplo de questão do núcleo comum de engenharia.',
          'Alternativa A', 'Alternativa B', 'Alternativa C', 'Alternativa D', 'Alternativa E', 1, 'Seed de desenvolvimento')
  returning id into v_id;
  insert into public.questoes_gabarito (questao_id, gabarito, justificativa)
  values (v_id, 'D', 'Justificativa de exemplo.');
  update public.questoes set status = 'PUBLICADA' where id = v_id;
end $$;
