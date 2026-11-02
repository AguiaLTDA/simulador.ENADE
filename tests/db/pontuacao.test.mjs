import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { criarBanco, como, criarUsuario } from './harness.mjs';

let db;
const u = {};
const q = {};
let sid; // atividade de ENG_MEC valendo 1000 pontos

async function erro(promessa, padrao) {
  await assert.rejects(promessa, (e) => {
    assert.match(e.message, padrao);
    return true;
  });
}

const rpc = async (uid, sql, params = []) => (await como(db, uid, () => db.query(sql, params))).rows[0];
const cadastrar = async (uid, nome, cpf, curso) => {
  await como(db, uid, () => db.query(
    `select public.concluir_cadastro($1, $2, '27999990000', $3::public.curso, true)`, [nome, cpf, curso]));
  await db.query(`update public.estudantes set turma = 'T1', tipo = 'CONCLUINTE', data_nascimento = '2000-01-01' where id = $1`, [uid]);
};
const salvarQuestao = async (dados) =>
  (await rpc(u.admin, `select public.salvar_questao($1::jsonb) as id`, [JSON.stringify({
    componente: 'CE', cursos: ['ENG_MEC'], eixo: 'Eixo', formato: 'OBJETIVA', enunciado: 'Enunciado',
    alt_a: 'a', alt_b: 'b', alt_c: 'c', alt_d: 'd', alt_e: 'e', gabarito: 'A', dificuldade: 2, status: 'PUBLICADA',
    ...dados,
  })])).id;
const pontos = async (uid) => (await rpc(uid, `select (public.meu_resumo()->>'pontos')::int p`)).p;

before(async () => {
  db = await criarBanco({ dados: true });
  u.admin = await criarUsuario(db, 'admin@univc.edu.br');
  u.coordMec = await criarUsuario(db, 'coord.mec@univc.edu.br');
  u.coordVet = await criarUsuario(db, 'coord.vet@univc.edu.br');
  u.docMec = await criarUsuario(db, 'doc.mec@univc.edu.br');
  await db.query(`insert into public.staff (user_id, nome, papel, cursos) values
    ($1, 'Admin', 'ADMIN', null), ($2, 'Coord MEC', 'COORDENADOR', '{ENG_MEC}'),
    ($3, 'Coord VET', 'COORDENADOR', '{VET}'), ($4, 'Docente MEC', 'DOCENTE', '{ENG_MEC}')`,
  [u.admin, u.coordMec, u.coordVet, u.docMec]);

  u.mec = await criarUsuario(db, 'mec@gmail.com');
  u.prod = await criarUsuario(db, 'prod@gmail.com');
  await cadastrar(u.mec, 'Aluno Mecânica', '98765432100', 'ENG_MEC');
  await cadastrar(u.prod, 'Aluna Produção', '52998224725', 'ENG_PROD');

  q.a = await salvarQuestao({ gabarito: 'A' });
  q.b = await salvarQuestao({ gabarito: 'B' });
});

test('prova ENADE 2023 carregada: 70 questões publicadas e uma atividade por curso até 10/11', async () => {
  const { rows: [c] } = await db.query(`
    select count(*)::int total,
           count(*) filter (where status = 'PUBLICADA')::int publicadas,
           count(*) filter (where componente = 'FG')::int fg,
           count(*) filter (where formato = 'DISCURSIVA')::int discursivas,
           count(*) filter (where figura_url is not null or figura_alternativas_url is not null)::int com_figura
      from public.questoes where fonte like 'ENADE 2023%'`);
  assert.deepEqual({ ...c, com_figura: c.com_figura > 0 }, { total: 70, publicadas: 70, fg: 10, discursivas: 3, com_figura: true });

  const { rows: semGabarito } = await db.query(`
    select q.id from public.questoes q left join public.questoes_gabarito g on g.questao_id = q.id
     where q.fonte like 'ENADE 2023%'
       and ((q.formato = 'OBJETIVA' and g.gabarito is null) or (q.formato = 'DISCURSIVA' and coalesce(g.justificativa, '') = ''))`);
  assert.equal(semGabarito.length, 0);

  const { rows: sessoes } = await db.query(`
    select curso, cardinality(questoes) n, pontos_atividade, duracao_minutos, fim = '2026-11-10 23:59:59-03'::timestamptz prazo
      from public.sessoes where titulo like 'ENADE 2023%' order by curso`);
  assert.deepEqual(sessoes, [
    { curso: 'ENG_MEC', n: 40, pontos_atividade: 1000, duracao_minutos: 240, prazo: true },
    { curso: 'ENG_PROD', n: 40, pontos_atividade: 1000, duracao_minutos: 240, prazo: true },
  ]);

  // Aluno de Mecânica vê só a atividade do curso dele, com o valor em pontos.
  const lista = (await rpc(u.mec, `select public.meus_simulados() j`)).j.filter((s) => s.titulo.startsWith('ENADE 2023'));
  assert.equal(lista.length, 1);
  assert.equal(lista[0].curso, 'ENG_MEC');
  assert.equal(lista[0].pontos_atividade, 1000);
});

test('provas ENADE 2017, 2019 e 2021: 144 questões publicadas e um simulado-rascunho por prova', async () => {
  const { rows } = await db.query(`
    select substr(q.fonte, 7, 4) ano, q.cursos::text cursos, count(*)::int n,
           count(*) filter (where q.status = 'PUBLICADA')::int publicadas,
           count(*) filter (where (q.formato = 'OBJETIVA' and g.gabarito is null)
                             or (q.formato = 'DISCURSIVA' and coalesce(g.justificativa, '') = ''))::int sem_resposta
      from public.questoes q left join public.questoes_gabarito g on g.questao_id = q.id
     where q.fonte ~ '^ENADE 20(17|19|21) '
     group by 1, 2 order by 1, 2`);
  assert.deepEqual(rows.map((r) => [r.ano, r.cursos, r.n, r.publicadas, r.sem_resposta]), [
    ['2017', '{ADS}', 29, 29, 0], ['2017', '{ALL}', 10, 10, 0],
    ['2019', '{ALL}', 9, 9, 0], ['2019', '{ENG_MEC}', 26, 26, 0], ['2019', '{ENG_PROD}', 30, 30, 0],
    ['2021', '{ADS}', 30, 30, 0], ['2021', '{ALL}', 10, 10, 0],
  ]);

  const { rows: sessoes } = await db.query(`
    select curso, cardinality(questoes) n, publicada, pontos_atividade
      from public.sessoes where titulo like '%(prova completa)' order by curso, cardinality(questoes)`);
  assert.deepEqual(sessoes, [
    { curso: 'ENG_MEC', n: 35, publicada: false, pontos_atividade: 0 },
    { curso: 'ENG_PROD', n: 39, publicada: false, pontos_atividade: 0 },
    { curso: 'ADS', n: 39, publicada: false, pontos_atividade: 0 },
    { curso: 'ADS', n: 40, publicada: false, pontos_atividade: 0 },
  ]);
  // Rascunho não aparece para o aluno.
  const lista = (await rpc(u.mec, `select public.meus_simulados() j`)).j;
  assert.ok(lista.every((s) => !s.titulo.endsWith('(prova completa)')));
});

test('a prova entrega as figuras e começa pela Formação Geral, sem gabarito', async () => {
  const { rows: [s] } = await db.query(`select id from public.sessoes where titulo like 'ENADE 2023%' and curso = 'ENG_PROD'`);
  const prova = (await rpc(u.prod, `select public.iniciar_simulado($1) j`, [s.id])).j;
  assert.equal(prova.questoes.length, 40);
  assert.equal(prova.questoes[0].componente, 'FG');
  assert.equal(prova.questoes[0].formato, 'DISCURSIVA');
  assert.equal(prova.questoes[10].componente, 'CE');
  assert.ok(prova.questoes.some((x) => x.figura_url?.startsWith('enade2023/')));
  assert.ok(prova.questoes.every((x) => !('gabarito' in x) && !('justificativa' in x)));
});

test('valor da atividade: pontos = valor × nota / 100, só depois que o gabarito sai', async () => {
  await erro(rpc(u.coordMec, `select public.salvar_simulado($1::jsonb) id`, [JSON.stringify({
    titulo: 'Atividade', curso: 'ENG_MEC', duracao_minutos: 60, publicada: true, questoes: [q.a, q.b],
    inicio: new Date(Date.now() - 60_000).toISOString(), fim: new Date(Date.now() + 86_400_000).toISOString(),
    pontos_atividade: -5,
  })]), /valor da atividade/);

  sid = (await rpc(u.coordMec, `select public.salvar_simulado($1::jsonb) id`, [JSON.stringify({
    titulo: 'Atividade', curso: 'ENG_MEC', duracao_minutos: 60, publicada: true, questoes: [q.a, q.b],
    inicio: new Date(Date.now() - 60_000).toISOString(), fim: new Date(Date.now() + 86_400_000).toISOString(),
    pontos_atividade: 1000,
  })])).id;

  await rpc(u.mec, `select public.iniciar_simulado($1)`, [sid]);
  await rpc(u.mec, `select public.responder_questao($1, 'A', null, $2)`, [q.a, sid]); // certa
  await rpc(u.mec, `select public.responder_questao($1, 'C', null, $2)`, [q.b, sid]); // errada
  await rpc(u.mec, `select public.finalizar_simulado($1)`, [sid]);

  const antes = await pontos(u.mec);
  let r = (await rpc(u.mec, `select public.resultado_simulado($1) j`, [sid])).j;
  assert.equal(r.pontos_atividade, 1000);
  assert.equal(r.pontos_atividade_obtidos, null);

  // Encerra a atividade: nota 50 (só CE, 1 de 2 objetivas) → 500 pontos + os pontos da questão.
  await db.query(`update public.sessoes set fim = now() - interval '1 second' where id = $1`, [sid]);
  r = (await rpc(u.mec, `select public.resultado_simulado($1) j`, [sid])).j;
  assert.equal(Number(r.desempenho.nota), 50);
  assert.equal(r.pontos_atividade_obtidos, 500);
  const depois = await pontos(u.mec);
  assert.equal(depois - antes, 500 + Number(r.desempenho.pontos));

  // Coordenação muda o valor: o placar acompanha.
  await db.query(`update public.sessoes set pontos_atividade = 2000 where id = $1`, [sid]);
  assert.equal(await pontos(u.mec), depois + 500);
  await db.query(`update public.sessoes set pontos_atividade = 1000 where id = $1`, [sid]);
});

test('ajustes de pontuação: só a coordenação do curso, com motivo, auditados e no ranking', async () => {
  const antes = await pontos(u.mec);
  const ajustar = (uid, p, motivo = 'Participação no seminário', sessao = null) =>
    rpc(uid, `select public.ajustar_pontuacao($1, $2, $3, $4) id`, [u.mec, p, motivo, sessao]);

  await erro(ajustar(u.coordVet, 100), /não encontrado nos seus cursos/);
  await erro(ajustar(u.docMec, 100), /restrito à coordenação/);
  await erro(ajustar(u.mec, 100), /restrito à coordenação/);
  await erro(ajustar(u.coordMec, 0), /diferente de zero/);
  await erro(ajustar(u.coordMec, 100, 'x'), /motivo/);

  const bonus = (await ajustar(u.coordMec, 150, 'Participação no seminário', sid)).id;
  const desconto = (await ajustar(u.admin, -50, 'Correção de lançamento')).id;
  assert.equal(await pontos(u.mec), antes + 100);

  // Aluno vê os próprios ajustes; colega de outro curso não.
  assert.equal((await como(db, u.mec, () => db.query(`select * from public.ajustes_pontuacao`))).rows.length, 2);
  assert.equal((await como(db, u.prod, () => db.query(`select * from public.ajustes_pontuacao`))).rows.length, 0);
  await erro(como(db, u.coordMec, () => db.query(`delete from public.ajustes_pontuacao`)).then((r) => {
    if (r.affectedRows === 0) throw new Error('sem permissão');
  }), /permission denied|sem permissão/);

  const det = (await rpc(u.coordMec, `select public.pontuacao_aluno($1) j`, [u.mec])).j;
  assert.equal(Number(det.resumo.pontos_ajustes), 100);
  assert.equal(Number(det.resumo.pontos_atividades), 500);
  assert.equal(det.ajustes.length, 2);
  assert.equal(det.atividades.find((a) => a.sessao_id === sid).pontos, 500);
  await erro(rpc(u.coordVet, `select public.pontuacao_aluno($1) j`, [u.mec]), /não encontrado/);

  const equipe = (await rpc(u.coordMec, `select public.pontuacao_equipe() j`)).j;
  assert.deepEqual(equipe.map((a) => a.curso), ['ENG_MEC']);
  const ranking = (await rpc(u.coordMec, `select public.ranking_equipe() j`)).j.alunos;
  assert.equal(ranking.find((a) => a.estudante_id === u.mec).pontos, antes + 100);

  await erro(rpc(u.coordVet, `select public.excluir_ajuste_pontuacao($1)`, [bonus]), /não encontrado/);
  await rpc(u.coordMec, `select public.excluir_ajuste_pontuacao($1)`, [bonus]);
  assert.equal(await pontos(u.mec), antes - 50);
  await rpc(u.admin, `select public.excluir_ajuste_pontuacao($1)`, [desconto]);

  const { rows: aud } = await db.query(
    `select acao from public.auditoria where alvo_id = $1 and acao like '%PONTUACAO%' order by id`, [u.mec]);
  assert.deepEqual(aud.map((a) => a.acao),
    ['PONTUACAO_AJUSTADA', 'PONTUACAO_AJUSTADA', 'AJUSTE_PONTUACAO_EXCLUIDO', 'AJUSTE_PONTUACAO_EXCLUIDO']);
});
