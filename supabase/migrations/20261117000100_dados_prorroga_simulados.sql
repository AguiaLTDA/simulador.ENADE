-- =============================================================================
-- Prorrogação dos simulados publicados até 27/11/2026, 23:59 (Brasília).
--
-- Já aplicada em produção em 17/11/2026 pela coordenação; esta migration
-- registra a mudança no repositório. Só altera o encerramento (permitido mesmo
-- com alunos que já iniciaram); questões, curso, duração e abertura ficam iguais.
-- Enquanto o simulado estiver aberto, o gabarito fica oculto para os alunos.
-- =============================================================================

update public.sessoes
   set fim = timestamptz '2026-11-27 23:59:00-03'
 where id in (
   'e8fc0a44-22be-5838-b01d-fc29b320db05',  -- ENADE 2023 — Engenharia de Produção (atividade avaliativa)
   'c5a221bd-4ea2-5447-84b4-980addff4a7a',  -- ENADE 2023 — Engenharia Mecânica (atividade avaliativa)
   '8add8b6c-e81a-5bce-b054-d541c6fb0da6'   -- ENADE 2017 — Análise e Desenvolvimento de Sistemas (prova completa)
 );
