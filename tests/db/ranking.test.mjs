import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { criarBanco, como, criarUsuario } from './harness.mjs';

let db;
const u = {};
let sid;
let qVet;

async function erro(promessa, padrao) {
  await assert.rejects(promessa, (e) => {
    assert.match(e.message, padrao);
    return true;
  });
}

const cadastrar = (uid, nome, cpf, curso, turma) => como(db, uid, () => db.query(
  `select public.concluir_cadastro($1, $2, '2000-01-01', '27999990000', $3::public.curso, $4, 'CONCLUINTE', null, true)`,
  [nome, cpf, curso, turma]));
const extra = (uid, origem, pontos, quando = 'now()') =>
  db.query(`insert into public.pontos_extras (estudante_id, origem, pontos, criado_em) values ($1, $2, $3, ${quando})`,
    [uid, origem, pontos]);
const um = async (uid, sql, params = []) => (await como(db, uid, () => db.query(sql, params))).rows[0];

before(async () => {
  db = await criarBanco();
  u.admin = await criarUsuario(db, 'admin@univc.edu.br');
  u.coordVet = await criarUsuario(db, 'coord.vet@univc.edu.br');
  await db.query(`insert into public.staff (user_id, nome, papel, cursos) values
    ($1, 'Admin', 'ADMIN', null), ($2, 'Coord VET', 'COORDENADOR', '{VET}')`, [u.admin, u.coordVet]);

  u.ana = await criarUsuario(db, 'ana@gmail.com');
  u.bruno = await criarUsuario(db, 'bruno@gmail.com');
  u.carla = await criarUsuario(db, 'carla@gmail.com');
  u.davi = await criarUsuario(db, 'davi@gmail.com');
  await cadastrar(u.ana, 'Ana Paula Souza', '98765432100', 'VET', 'T1');
  await cadastrar(u.bruno, 'Bruno Lima', '52998224725', 'VET', 'T2');
  await cadastrar(u.carla, 'Carla Mendes', '11144477735', 'VET', 'T1');
  await cadastrar(u.davi, 'Davi Rocha', '12345678909', 'ADS', 'T1');

  await extra(u.ana, 'A', 50);
  await extra(u.bruno, 'B', 80);
  await extra(u.davi, 'D', 200);
  await extra(u.carla, 'C', 50, `now() - interval '20 days'`);

  qVet = (await como(db, u.admin, () => db.query(`select public.salvar_questao($1::jsonb) as id`, [JSON.stringify({
    componente: 'CE', cursos: ['VET'], eixo: 'Clínica', formato: 'OBJETIVA', enunciado: 'E',
    alt_a: 'a', alt_b: 'b', alt_c: 'c', alt_d: 'd', alt_e: 'e', gabarito: 'A', dificuldade: 3, status: 'PUBLICADA',
  })]))).rows[0].id;
  sid = (await como(db, u.coordVet, () => db.query(`select public.salvar_simulado($1::jsonb) as id`, [JSON.stringify({
    titulo: 'Simulado', curso: 'VET', duracao_minutos: 60, publicada: true, questoes: [qVet],
    inicio: new Date(Date.now() - 60_000).toISOString(), fim: new Date(Date.now() + 86_400_000).toISOString(),
  })]))).rows[0].id;
});

test('aluno vê o próprio curso com nomes abreviados e a própria posição; empate divide a posição', async () => {
  const r = (await um(u.ana, `select public.ranking_aluno('CURSO') as j`)).j;
  assert.equal(r.participantes, 3);
  assert.deepEqual(r.lideres.map((l) => [l.posicao, l.nome, l.eu]),
    [[1, 'Bruno L.', false], [2, 'Ana S.', true], [2, 'Carla M.', false]]);
  assert.equal(r.eu.posicao, 2);
  assert.equal(Number(r.eu.pontos), 50);
  assert.ok(!JSON.stringify(r).includes('Lima'));
  assert.ok(!JSON.stringify(r).includes('estudante_id'));
});

test('escopos turma e geral; período considera a data dos pontos', async () => {
  const turma = (await um(u.ana, `select public.ranking_aluno('TURMA') as j`)).j;
  assert.deepEqual(turma.lideres.map((l) => l.nome), ['Ana S.', 'Carla M.']);
  const geral = (await um(u.ana, `select public.ranking_aluno('GERAL') as j`)).j;
  assert.equal(geral.lideres[0].nome, 'Davi R.');
  assert.equal(geral.participantes, 4);
  const semana = (await um(u.ana, `select public.ranking_aluno('CURSO', 'SEMANA') as j`)).j;
  assert.deepEqual(semana.lideres.map((l) => l.nome), ['Bruno L.', 'Ana S.']);
  await como(db, u.ana, () => erro(db.query(`select public.ranking_aluno('TUDO')`), /Escopo inválido/));
});

test('pontos de simulado só contam quando o gabarito é liberado (não revelam acerto durante a prova)', async () => {
  const antes = (await um(u.ana, `select (public.meu_resumo()->>'pontos')::int p`)).p;
  await como(db, u.ana, async () => {
    await db.query(`select public.iniciar_simulado($1)`, [sid]);
    await db.query(`select public.responder_questao($1, 'A', null, $2)`, [qVet, sid]); // acertou
  });
  assert.equal((await um(u.ana, `select (public.meu_resumo()->>'pontos')::int p`)).p, antes);
  assert.equal(Number((await um(u.ana, `select public.ranking_aluno('CURSO') as j`)).j.eu.pontos), antes);

  await como(db, u.ana, () => db.query(`select public.finalizar_simulado($1)`, [sid]));
  await db.query(`update public.sessoes set fim = now() - interval '1 second' where id = $1`, [sid]);
  const depois = (await um(u.ana, `select (public.meu_resumo()->>'pontos')::int p`)).p;
  assert.ok(depois > antes);
  assert.equal((await um(u.ana, `select public.ranking_aluno('CURSO') as j`)).j.eu.posicao, 1);
});

test('equipe vê nomes completos e indicadores, só dos cursos do perfil; aluno bloqueado sai', async () => {
  const r = (await um(u.coordVet, `select public.ranking_equipe() as j`)).j;
  assert.deepEqual(r.alunos.map((a) => a.nome), ['Ana Paula Souza', 'Bruno Lima', 'Carla Mendes']);
  assert.equal(r.alunos[0].acertos, 1);
  assert.equal(r.alunos[0].simulados, 1);
  assert.deepEqual(r.turmas, ['T1', 'T2']);
  const t2 = (await um(u.coordVet, `select public.ranking_equipe(null, 't2') as j`)).j;
  assert.deepEqual(t2.alunos.map((a) => a.nome), ['Bruno Lima']);

  await db.query(`update public.estudantes set status = 'BLOQUEADO' where id = $1`, [u.bruno]);
  const sem = (await um(u.admin, `select public.ranking_equipe('VET') as j`)).j;
  assert.ok(!sem.alunos.some((a) => a.nome === 'Bruno Lima'));
  await como(db, u.davi, () => erro(db.query(`select public.ranking_equipe()`), /restrito à equipe/));
});
