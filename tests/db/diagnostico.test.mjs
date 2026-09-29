import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { criarBanco, como, criarUsuario } from './harness.mjs';

let db;
const u = {};

async function erro(promessa, padrao) {
  await assert.rejects(promessa, (e) => {
    assert.match(e.message, padrao);
    return true;
  });
}

const cadastrar = (uid, nome, cpf, curso) => como(db, uid, () => db.query(
  `select public.concluir_cadastro($1, $2, '2000-01-01', '27999990000', $3::public.curso, 'T1', 'CONCLUINTE', null, true)`,
  [nome, cpf, curso]));

const rpc = async (uid, sql, params = []) => (await como(db, uid, () => db.query(sql, params))).rows[0];

before(async () => {
  db = await criarBanco();
  u.admin  = await criarUsuario(db, 'admin@univc.edu.br');
  u.coordVet = await criarUsuario(db, 'vet@univc.edu.br');
  u.a1 = await criarUsuario(db, 'a1@gmail.com');
  u.a2 = await criarUsuario(db, 'a2@gmail.com');
  u.vet = await criarUsuario(db, 'vet.aluno@gmail.com');
  await db.query(`insert into public.staff (user_id, nome, papel) values ($1, 'Admin', 'ADMIN')`, [u.admin]);
  await db.query(`insert into public.staff (user_id, nome, papel, cursos) values ($1, 'Coord VET', 'COORDENADOR', '{VET}')`, [u.coordVet]);
  await cadastrar(u.a1, 'Aluno Um', '12345678909', 'ADS');
  await cadastrar(u.a2, 'Aluno Dois', '98765432100', 'ENG_MEC');
  await cadastrar(u.vet, 'Aluna Vet', '11144477735', 'VET');
});

test('banco do diagnóstico: 10 questões por área, todas com gabarito', async () => {
  const { rows } = await db.query(`
    select q.area, count(*)::int n, count(g.gabarito)::int com_gabarito
      from public.diagnostico_questoes q left join public.diagnostico_gabarito g on g.questao_id = q.id
     group by q.area order by q.area`);
  assert.deepEqual(rows, [
    { area: 'PORTUGUES', n: 10, com_gabarito: 10 },
    { area: 'ATUALIDADES', n: 10, com_gabarito: 10 },
    { area: 'MATEMATICA', n: 10, com_gabarito: 10 },
  ]);
});

test('aluno não lê questões, gabarito, respostas nem resultado do diagnóstico', async () => {
  await como(db, u.a1, async () => {
    for (const t of ['diagnostico_questoes', 'diagnostico_gabarito', 'diagnostico_respostas', 'diagnostico_resultados']) {
      assert.equal((await db.query(`select * from public.${t}`)).rows.length, 0, t);
    }
  });
  await como(db, null, () => erro(db.query(`select public.iniciar_diagnostico()`), /permission denied/));
});

test('iniciar devolve 30 questões sem gabarito', async () => {
  const j = (await rpc(u.a1, `select public.iniciar_diagnostico() as j`)).j;
  assert.equal(j.questoes.length, 30);
  assert.equal(j.concluido, false);
  assert.ok(j.questoes.every((q) => !('gabarito' in q) && Object.keys(q.alternativas).length === 5));
});

test('responder: sem devolutiva; conclusão dá badge e pontos independentemente de acertos', async () => {
  const { rows: questoes } = await db.query(
    `select q.id, q.area, g.gabarito from public.diagnostico_questoes q
       join public.diagnostico_gabarito g on g.questao_id = q.id order by q.area, q.ordem`);

  await rpc(u.a2, `select public.iniciar_diagnostico()`);
  let ultima;
  for (const [i, q] of questoes.entries()) {
    // a2 acerta todo Português, erra todo o resto
    const alt = q.area === 'PORTUGUES' ? q.gabarito : (q.gabarito === 'A' ? 'B' : 'A');
    ultima = (await rpc(u.a2, `select public.responder_diagnostico($1, $2) as r`, [q.id, alt])).r;
    if (i < questoes.length - 1) {
      assert.deepEqual(Object.keys(ultima).sort(), ['concluido', 'registrada', 'respondidas', 'total']);
      assert.equal(ultima.concluido, false);
    }
  }
  assert.equal(ultima.concluido, true);
  assert.equal(ultima.pontos, 50);
  assert.ok(!('resultado' in ultima) && !('acertos' in ultima));

  const resumo = (await rpc(u.a2, `select public.meu_resumo() as r`)).r;
  assert.equal(resumo.pontos, 50);
  assert.equal(resumo.diagnostico.concluido, true);
  assert.deepEqual(resumo.conquistas.map((c) => c.codigo), ['DIAGNOSTICO_INICIAL']);
  assert.ok(!('resultado' in resumo.diagnostico));

  // Não pode responder de novo
  await como(db, u.a2, () => erro(db.query(`select public.responder_diagnostico($1, 'A')`, [questoes[0].id]), /já concluiu/));
  // Append-only
  await erro(db.query(`update public.diagnostico_respostas set correta = true`), /append-only/);

  // Resultado por área (só equipe)
  const r = (await rpc(u.admin, `select resultado, acertos, total from public.diagnostico_resultados where estudante_id = $1`, [u.a2]));
  assert.equal(r.acertos, 10);
  assert.equal(r.total, 30);
  assert.equal(r.resultado.PORTUGUES.nivel, 'AVANCADO');
  assert.equal(r.resultado.MATEMATICA.nivel, 'INICIAL');
  assert.equal(r.resultado.ATUALIDADES.percentual, 0);
});

test('resposta repetida e alternativa inválida são recusadas', async () => {
  const { rows } = await db.query(`select id from public.diagnostico_questoes order by area, ordem limit 1`);
  await como(db, u.a1, async () => {
    await db.query(`select public.responder_diagnostico($1, 'C')`, [rows[0].id]);
    await erro(db.query(`select public.responder_diagnostico($1, 'D')`, [rows[0].id]), /já respondida/);
    await erro(db.query(`select public.responder_diagnostico($1, 'Z')`, [rows[0].id]), /inválida/);
  });
});

test('coordenador só vê resultados dos alunos do seu curso', async () => {
  const doCoordVet = await como(db, u.coordVet, () => db.query(`select estudante_id from public.diagnostico_resultados`));
  assert.equal(doCoordVet.rows.length, 0); // a1 (ADS) e a2 (MEC) não são de VET
  const doAdmin = await como(db, u.admin, () => db.query(`select estudante_id from public.diagnostico_resultados`));
  assert.equal(doAdmin.rows.length, 2);
});
