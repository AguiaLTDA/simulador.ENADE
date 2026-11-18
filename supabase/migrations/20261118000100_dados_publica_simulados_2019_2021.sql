-- =============================================================================
-- Publica os simulados que estavam em rascunho, com encerramento em
-- 29/11/2026, 23:59 (Brasília). Com isso cada curso fica com 2 simulados
-- liberados (os de 2017/2023 seguem até 27/11).
-- A abertura (16/11) e as questões não mudam. A publicação passa pelas
-- validações do banco (questões publicadas e válidas para o curso).
-- =============================================================================

update public.sessoes
   set publicada = true,
       fim = timestamptz '2026-11-29 23:59:00-03'
 where id in (
   'fe0f69be-cfff-5b40-a8eb-7d68ede329c0',  -- ENADE 2019 — Engenharia Mecânica (prova completa)
   '5ec5d029-c232-5139-9af9-426ea146af72',  -- ENADE 2019 — Engenharia de Produção (prova completa)
   '2b2c3d7a-489c-5d30-9775-9f65a9615513'   -- ENADE 2021 — Análise e Desenvolvimento de Sistemas (prova completa)
 );

-- Registra no repositório o que já vale em produção para o ENADE 2017 de ADS:
-- publicado, com abertura em 02/11/2026 23:32 (o encerramento, 27/11, está na
-- migration 20261117000100). Em produção os valores já são estes.
update public.sessoes
   set publicada = true,
       inicio = timestamptz '2026-11-02 23:32:00-03'
 where id = '8add8b6c-e81a-5bce-b054-d541c6fb0da6'
   and (not publicada or inicio is distinct from timestamptz '2026-11-02 23:32:00-03');
