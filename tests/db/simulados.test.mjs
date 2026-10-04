import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { criarBanco, como, criarUsuario } from './harness.mjs';

let db;
const u = {};
const q = {};
let sid; // simulado de Medicina Veterinária

async function erro(promessa, padrao) {
  await assert.rejects(promessa, (e) => {
    assert.match(e.message, padrao);
    return true;
  });
}

const Q = {
  componente: 'CE', eixo: 'Eixo', formato: 'OBJETIVA', enunciado: 'Enunciado',
  alt_a: 'a', alt_b: 'b', alt_c: 'c', alt_d: 'd', alt_e: 'e', gabarito: 'A', dificuldade: 2, status: 'PUBLICADA',
};
const salvarQuestao = async (dados) =>
  (await como(db, u.admin, () => db.query(`select public.salvar_questao($1::jsonb) as id`,
    [JSON.stringify({ ...Q, ...dados })]))).rows[0].id;
const cadastrar = (uid, nome, cpf, curso) => como(db, uid, () => db.query(
  `select public.concluir_cadastro($1, $2, '2000-01-01', '27999990000', $3::public.curso, 'T1', 'CONCLUINTE', null, true)`,
  [nome, cpf, curso]));
const simulado = (dados) => ({
  titulo: 'Simulado VET', curso: 'VET', duracao_minutos: 60, publicada: true,
  inicio: new Date(Date.now() - 60_000).toISOString(),
  fim: new Date(Date.now() + 86_400_000).toISOString(),
  ...dados,
});
const salvarSimulado = (uid, dados) =>
  como(db, uid, () => db.query(`select public.salvar_simulado($1::jsonb) as id`, [JSON.stringify(dados)]));
const rpc = async (uid, sql, params = []) => (await como(db, uid, () => db.query(sql, params))).rows[0];

before(async () => {
  db = await criarBanco();
  u.admin = await criarUsuario(db, 'admin@univc.edu.br');
  u.coordVet = await criarUsuario(db, 'coord.vet@univc.edu.br');
  u.coordArq = await criarUsuario(db, 'coord.arq@univc.edu.br');
  u.docVet = await criarUsuario(db, 'doc.vet@univc.edu.br');
  await db.query(`insert into public.staff (user_id, nome, papel, cursos) values
    ($1, 'Admin', 'ADMIN', null), ($2, 'Coord VET', 'COORDENADOR', '{VET}'),
    ($3, 'Coord ARQ', 'COORDENADOR', '{ARQ}'), ($4, 'Docente VET', 'DOCENTE', '{VET}')`,
  [u.admin, u.coordVet, u.coordArq, u.docVet]);

  u.vet = await criarUsuario(db, 'vet@gmail.com');
  u.vet2 = await criarUsuario(db, 'vet2@gmail.com');
  u.ads = await criarUsuario(db, 'ads@gmail.com');
  await cadastrar(u.vet, 'Aluna Veterinária', '98765432100', 'VET');
  await cadastrar(u.vet2, 'Aluno Veterinária', '52998224725', 'VET');
  await cadastrar(u.ads, 'Aluno ADS', '12345678909', 'ADS');

  q.fg = await salvarQuestao({ componente: 'FG', eixo: 'Ética', gabarito: 'B' });
  q.fgDisc = await salvarQuestao({ componente: 'FG', eixo: 'Sociedade', formato: 'DISCURSIVA', justificativa: 'Padrão' });
  q.vet = await salvarQuestao({ cursos: ['VET'], eixo: 'Clínica', gabarito: 'C' });
  q.ads = await salvarQuestao({ cursos: ['ADS'], eixo: 'Banco de Dados', gabarito: 'D' });
});

test('coordenador cria simulado só dos seus cursos e só com questões que valem para o curso', async () => {
  await erro(salvarSimulado(u.coordVet, simulado({ curso: 'ADS', questoes: [q.ads] })), /não gerencia este curso/);
  await erro(salvarSimulado(u.coordVet, simulado({ curso: null, questoes: [q.fg] })), /Selecione o curso/);
  await erro(salvarSimulado(u.docVet, simulado({ questoes: [q.fg] })), /restrito à coordenação/);
  await erro(salvarSimulado(u.coordVet, simulado({ questoes: [q.fg, q.ads] })), /fora dos seus cursos/);
  // Admin vê a questão de ADS, mas ela não vale para um simulado de VET.
  await erro(salvarSimulado(u.admin, simulado({ questoes: [q.fg, q.ads] })), /não valem para o curso/);
  await erro(salvarSimulado(u.coordVet, simulado({ questoes: [] })), /ao menos uma questão/);

  sid = (await salvarSimulado(u.coordVet, simulado({ questoes: [q.fgDisc, q.fg, q.vet] }))).rows[0].id;
  assert.ok(sid);
});

test('simulado aberto a todos os cursos: só admin e só Formação Geral', async () => {
  await erro(salvarSimulado(u.admin, simulado({ curso: null, questoes: [q.fg, q.vet] })), /apenas questões de Formação Geral/);
  const id = (await salvarSimulado(u.admin, simulado({ curso: null, questoes: [q.fg], publicada: false }))).rows[0].id;
  // Rascunho não aparece para os alunos.
  const lista = (await rpc(u.ads, `select public.meus_simulados() as j`)).j;
  assert.ok(!lista.some((s) => s.id === id));
  await como(db, u.admin, () => db.query(`select public.excluir_simulado($1)`, [id]));
});

test('aluno vê os simulados do seu curso com a situação', async () => {
  const vet = (await rpc(u.vet, `select public.meus_simulados() as j`)).j;
  assert.equal(vet.length, 1);
  assert.equal(vet[0].situacao, 'DISPONIVEL');
  assert.equal(vet[0].total_questoes, 3);
  assert.equal(vet[0].termina_em, null);
  assert.equal((await rpc(u.ads, `select public.meus_simulados() as j`)).j.length, 0);
});

test('coordenador de outro curso não vê nem altera o simulado', async () => {
  await erro(como(db, u.coordArq, () => db.query(`select public.relatorio_simulado($1)`, [sid])), /não encontrado/);
  await erro(como(db, u.coordArq, () => db.query(`select public.excluir_simulado($1)`, [sid])), /não gerencia/);
  const vis = await como(db, u.coordArq, () => db.query(`select id from public.sessoes`));
  assert.equal(vis.rows.length, 0);
});

test('fluxo do aluno: resultado só depois de finalizar; detalhe só quando a janela fecha', async () => {
  await como(db, u.vet, async () => {
    const ini = (await db.query(`select public.iniciar_simulado($1) as j`, [sid])).rows[0].j;
    assert.equal(ini.questoes.length, 3);
    await erro(db.query(`select public.resultado_simulado($1)`, [sid]), /Finalize/);

    await db.query(`select public.responder_questao($1, null, 'Minha resposta discursiva.', $2)`, [q.fgDisc, sid]);
    await db.query(`select public.responder_questao($1, 'B', null, $2)`, [q.fg, sid]);   // certa
    await db.query(`select public.responder_questao($1, 'A', null, $2)`, [q.vet, sid]);  // errada

    const fim = (await db.query(`select public.finalizar_simulado($1) as j`, [sid])).rows[0].j;
    assert.equal(fim.completo, true);
    const badge = await db.query(`select 1 from public.conquistas_estudante where conquista = 'SIMULADO_COMPLETO'`);
    assert.equal(badge.rows.length, 1);

    const r = (await db.query(`select public.resultado_simulado($1) as j`, [sid])).rows[0].j;
    assert.equal(r.gabarito_liberado, false);
    assert.equal(r.questoes, null);
    assert.equal(r.media_participantes, null);
    // FG: objetiva 100% × 0,6 + discursiva pendente (0) × 0,4 = 60; CE: 0 → nota = 0,25 × 60 = 15
    assert.equal(Number(r.desempenho.nota), 15);
    assert.equal(r.desempenho.pendentes, 1);
    assert.equal(r.desempenho.respondidas, 3);
    assert.ok(!JSON.stringify(r).includes('"gabarito":"C"'));
  });

  // Quem deixou questão em branco não ganha a conquista.
  await como(db, u.vet2, async () => {
    await db.query(`select public.iniciar_simulado($1)`, [sid]);
    await db.query(`select public.responder_questao($1, 'C', null, $2)`, [q.vet, sid]);
    const fim = (await db.query(`select public.finalizar_simulado($1) as j`, [sid])).rows[0].j;
    assert.equal(fim.completo, false);
  });
});

test('depois de iniciado, só título e encerramento mudam; não pode ser excluído', async () => {
  const base = simulado({ id: sid, questoes: [q.fgDisc, q.fg, q.vet] });
  const atual = (await db.query(`select inicio, fim from public.sessoes where id = $1`, [sid])).rows[0];
  base.inicio = atual.inicio.toISOString();
  base.fim = atual.fim.toISOString();

  await erro(salvarSimulado(u.coordVet, { ...base, questoes: [q.fg, q.vet] }), /só o título e o encerramento/);
  await erro(salvarSimulado(u.coordVet, { ...base, duracao_minutos: 90 }), /só o título e o encerramento/);
  await erro(salvarSimulado(u.coordVet, { ...base, publicada: false }), /só o título e o encerramento/);
  await salvarSimulado(u.coordVet, { ...base, titulo: 'Simulado VET — 1º semestre' });
  await erro(como(db, u.coordVet, () => db.query(`select public.excluir_simulado($1)`, [sid])), /participações/);
});

test('docente do curso corrige a discursiva; relatório mostra a distribuição por questão', async () => {
  const rid = (await db.query(`select id from public.respostas where questao_id = $1 and sessao_id = $2`,
    [q.fgDisc, sid])).rows[0].id;
  await como(db, u.coordArq, () =>
    erro(db.query(`select public.corrigir_discursiva($1, 50)`, [rid]), /outro curso/));
  await como(db, u.docVet, () => db.query(`select public.corrigir_discursiva($1, 50, 'Faltou exemplo')`, [rid]));

  const rel = (await rpc(u.docVet, `select public.relatorio_simulado($1) as j`, [sid])).j;
  assert.equal(rel.elegiveis, 2);
  assert.equal(rel.participantes.length, 2);
  const objVet = rel.questoes.find((x) => x.id === q.vet);
  assert.equal(objVet.numero, 3);
  assert.equal(objVet.respostas.total, 2);
  assert.equal(objVet.respostas.acertos, 1);
  assert.equal(objVet.respostas.A, 1);
  assert.equal(objVet.respostas.C, 1);
  const aluna = rel.participantes.find((p) => p.estudante_id === u.vet);
  // FG: 0,6 × 100 + 0,4 × 50 = 80; CE 0 → 0,25 × 80 = 20
  assert.equal(Number(aluna.desempenho.nota), 20);
  assert.equal(aluna.desempenho.pendentes, 0);
});

test('janela fechada: aluno recebe gabarito, correção e média da turma', async () => {
  await db.query(`update public.sessoes set fim = now() - interval '1 second' where id = $1`, [sid]);
  const r = (await rpc(u.vet, `select public.resultado_simulado($1) as j`, [sid])).j;
  assert.equal(r.gabarito_liberado, true);
  assert.equal(r.questoes.length, 3);
  const disc = r.questoes.find((x) => x.id === q.fgDisc);
  assert.equal(Number(disc.nota), 50);
  assert.equal(disc.comentario, 'Faltou exemplo');
  const vet = r.questoes.find((x) => x.id === q.vet);
  assert.equal(vet.gabarito, 'C');
  assert.equal(vet.correta, false);
  // vet2: FG 0 (em branco) ; CE 100 → 75. Média (20 + 75) / 2 = 47,5
  assert.equal(Number(r.media_participantes), 47.5);

  const lista = (await rpc(u.vet, `select public.meus_simulados() as j`)).j;
  assert.equal(lista[0].situacao, 'CONCLUIDO');
  assert.equal(lista[0].gabarito_liberado, true);
});
