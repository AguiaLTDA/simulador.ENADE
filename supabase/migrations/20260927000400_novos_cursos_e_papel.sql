-- =============================================================================
-- Migration 7: novos cursos e papel de coordenador
-- (Arquivo separado: valores novos de enum não podem ser usados na mesma
-- transação em que são criados.)
-- =============================================================================

alter type public.curso      add value if not exists 'VET';  -- Medicina Veterinária
alter type public.curso      add value if not exists 'ARQ';  -- Arquitetura e Urbanismo
alter type public.curso_alvo add value if not exists 'VET';
alter type public.curso_alvo add value if not exists 'ARQ';

-- ADMIN       = administração geral (todos os cursos)
-- COORDENADOR = gere alunos e questões apenas dos cursos em staff.cursos
-- DOCENTE     = corrige discursivas dos cursos em staff.cursos
alter type public.papel_staff add value if not exists 'COORDENADOR';
