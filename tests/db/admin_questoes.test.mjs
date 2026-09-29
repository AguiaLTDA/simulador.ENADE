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

const BASE = {
  componente: 'CE', cursos: ['ENG_MEC', 'ENG_PROD'], eixo: 'Resistência dos Materiais', formato: 'OBJETIVA',
  texto_apoio: 'Uma viga biapoiada...', enunciado: 'Qual o momento fletor máximo?',
  alt_a: 'qL²/2', alt_b: 'qL²/4', alt_c: 'qL²/8', alt_d: 'qL²/12', alt_e: 'qL²/16',
  gabarito: 'c', justificativa: 'Para carga distribuída, Mmax = qL²/8.', dificuldade: 2, status: 'PUBLICADA',
};

async function salvar(uid, dados) {
  const { rows } = await como(db, uid, () => db.query(`select public.salvar_questao($1::jsonb) as id`, [JSON.stringify(dados)]));
  return rows[0].id;
}

before(async () => {
  db = await criarBanco();
  u.admin   = await criarUsuario(db, 'coord@univc.edu.br');
  u.docente = await criarUsuario(db, 'docente@univc.edu.br');
  u.aluno   = await criarUsuario(db, 'aluno@gmail.com');
  await db.query(`insert into public.staff (user_id, nome, papel, cursos) values ($1, 'Coord', 'ADMIN', null), ($2, 'Doc', 'DOCENTE', '{ENG_MEC,ENG_PROD,ADS,VET,ARQ}')`,
    [u.admin, u.docente]);
  await como(db, u.aluno, () => db.query(
    `select public.concluir_cadastro('Aluno Mecânica', '12345678909', '2000-01-01', '27999990000',
                                     'ENG_MEC', 'MEC-2022', 'CONCLUINTE', null, true)`));
});

test('só ADMIN salva ou exclui questões', async () => {
  await erro(salvar(u.docente, BASE), /restrito à coordenação/);
  await erro(salvar(u.aluno, BASE), /restrito à coordenação/);
  await como(db, null, () => erro(db.query(`select public.salvar_questao('{}'::jsonb)`), /permission denied/));
});

test('admin cria questão publicada com gabarito, justificativa e peso padrão', async () => {
  const id = await salvar(u.admin, BASE);
  const q = (await db.query(`select * from public.questoes where id = $1`, [id])).rows[0];
  assert.equal(q.status, 'PUBLICADA');
  assert.equal(q.peso_pontos, 20); // dificuldade 2 → pontos_media
  assert.equal(String(q.cursos), '{ENG_MEC,ENG_PROD}');
  assert.equal(q.autor_id, u.admin);
  const g = (await db.query(`select * from public.questoes_gabarito where questao_id = $1`, [id])).rows[0];
  assert.equal(g.gabarito, 'C');
  assert.match(g.justificativa, /qL²\/8/);

  // O aluno vê a questão, sem gabarito
  const j = (await como(db, u.aluno, () => db.query(`select public.exibir_questao($1) as j`, [id]))).rows[0].j;
  assert.equal(j.enunciado, BASE.enunciado);
  assert.ok(!('gabarito' in j));
});

test('peso editável pelo admin', async () => {
  const id = await salvar(u.admin, { ...BASE, peso_pontos: 50 });
  assert.equal((await db.query(`select peso_pontos from public.questoes where id = $1`, [id])).rows[0].peso_pontos, 50);
  await salvar(u.admin, { ...BASE, id, dificuldade: 3, peso_pontos: '' }); // vazio = padrão da dificuldade
  assert.equal((await db.query(`select peso_pontos from public.questoes where id = $1`, [id])).rows[0].peso_pontos, 35);
  await erro(salvar(u.admin, { ...BASE, peso_pontos: 0 }), /maior que zero/);
});

test('validações com mensagens claras', async () => {
  await erro(salvar(u.admin, { ...BASE, gabarito: '' }), /gabarito/);
  await erro(salvar(u.admin, { ...BASE, alt_e: ' ' }), /cinco alternativas/);
  await erro(salvar(u.admin, { ...BASE, cursos: [] }), /ao menos um curso/);
  await erro(salvar(u.admin, { ...BASE, enunciado: '' }), /enunciado/);
  await erro(salvar(u.admin, { ...BASE, eixo: '' }), /eixo/);
  await erro(salvar(u.admin, { ...BASE, dificuldade: 5 }), /dificuldade/);
});

test('Formação Geral vale para todos os cursos', async () => {
  const id = await salvar(u.admin, { ...BASE, componente: 'FG', cursos: ['ADS'], eixo: 'Ética' });
  assert.equal((await db.query(`select cursos::text c from public.questoes where id = $1`, [id])).rows[0].c, '{ALL}');
});

test('edição troca gabarito de questão publicada e continua publicada', async () => {
  const id = await salvar(u.admin, BASE);
  await salvar(u.admin, { ...BASE, id, gabarito: 'E', enunciado: 'Enunciado revisado' });
  const q = (await db.query(`select q.status, q.enunciado, g.gabarito from public.questoes q
                              join public.questoes_gabarito g on g.questao_id = q.id where q.id = $1`, [id])).rows[0];
  assert.deepEqual(q, { status: 'PUBLICADA', enunciado: 'Enunciado revisado', gabarito: 'E' });
});

test('discursiva: sem alternativas nem gabarito; justificativa = padrão de resposta', async () => {
  const id = await salvar(u.admin, { ...BASE, formato: 'DISCURSIVA', gabarito: 'A', justificativa: 'Padrão esperado' });
  const q = (await db.query(`select q.alt_a, g.gabarito, g.justificativa from public.questoes q
                              join public.questoes_gabarito g on g.questao_id = q.id where q.id = $1`, [id])).rows[0];
  assert.deepEqual(q, { alt_a: null, gabarito: null, justificativa: 'Padrão esperado' });
});

test('rascunho não aparece para o aluno', async () => {
  const id = await salvar(u.admin, { ...BASE, status: 'RASCUNHO' });
  await como(db, u.aluno, () => erro(db.query(`select public.exibir_questao($1)`, [id]), /indisponível/));
});

test('excluir: sem respostas exclui; com respostas arquiva', async () => {
  const livre = await salvar(u.admin, BASE);
  const r1 = (await como(db, u.admin, () => db.query(`select public.excluir_questao($1) as r`, [livre]))).rows[0].r;
  assert.equal(r1, 'EXCLUIDA');

  const usada = await salvar(u.admin, BASE);
  await como(db, u.aluno, async () => {
    await db.query(`select public.exibir_questao($1)`, [usada]);
    await db.query(`select public.responder_questao($1, 'C')`, [usada]);
  });
  const r2 = (await como(db, u.admin, () => db.query(`select public.excluir_questao($1) as r`, [usada]))).rows[0].r;
  assert.equal(r2, 'ARQUIVADA');
  await como(db, u.docente, () => erro(db.query(`select public.excluir_questao($1)`, [usada]), /restrito/));
});
