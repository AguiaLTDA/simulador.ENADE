import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { criarBanco, como, criarUsuario } from './harness.mjs';

let db;
const u = {};
const q = {};
let sid;

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
const um = async (uid, sql, params = []) => (await como(db, uid, () => db.query(sql, params))).rows[0];
const perfil = (dados = {}) => JSON.stringify({
  nome: 'Aluna Veterinária', cpf: '98765432100', data_nascimento: '2000-01-01', telefone: '27999990000',
  curso: 'VET', turma: 'T1', tipo: 'CONCLUINTE', matricula: null, status: 'ATIVO', ...dados,
});

before(async () => {
  db = await criarBanco();
  u.admin = await criarUsuario(db, 'admin@univc.edu.br');
  u.coordVet = await criarUsuario(db, 'coord.vet@univc.edu.br');
  await db.query(`insert into public.staff (user_id, nome, papel, cursos) values
    ($1, 'Admin', 'ADMIN', null), ($2, 'Coord VET', 'COORDENADOR', '{VET}')`, [u.admin, u.coordVet]);
  u.vet = await criarUsuario(db, 'vet@gmail.com');
  u.vet2 = await criarUsuario(db, 'vet2@gmail.com');
  u.ads = await criarUsuario(db, 'ads@gmail.com');
  await cadastrar(u.vet, 'Aluna Veterinária', '98765432100', 'VET');
  await cadastrar(u.vet2, 'Aluno Veterinária', '52998224725', 'VET');
  await cadastrar(u.ads, 'Aluno ADS', '12345678909', 'ADS');

  q.fg = await salvarQuestao({ componente: 'FG', eixo: 'Ética', gabarito: 'B', dificuldade: 1 });
  q.vet = await salvarQuestao({ cursos: ['VET'], eixo: 'Clínica', gabarito: 'C', dificuldade: 1 });
  q.vetCustom = await salvarQuestao({ cursos: ['VET'], eixo: 'Clínica', dificuldade: 1, peso_pontos: 99 });

  sid = (await como(db, u.coordVet, () => db.query(`select public.salvar_simulado($1::jsonb) as id`, [JSON.stringify({
    titulo: 'Simulado VET', curso: 'VET', duracao_minutos: 60, publicada: true, questoes: [q.fg, q.vet],
    inicio: new Date(Date.now() - 60_000).toISOString(), fim: new Date(Date.now() + 86_400_000).toISOString(),
  })]))).rows[0].id;
});

// ---------------------------------------------------------------------------
// Configuração
// ---------------------------------------------------------------------------
test('config: só o admin altera; limites e coerência validados', async () => {
  await como(db, u.coordVet, () =>
    erro(db.query(`select public.salvar_config('{"pontos_facil": 12}')`), /administração geral/));
  await como(db, u.admin, async () => {
    await erro(db.query(`select public.salvar_config('{"pontos_facil": 0}')`), /entre 1 e 1000/);
    await erro(db.query(`select public.salvar_config('{"pontos_facil": 10.5}')`), /inteiro/);
    await erro(db.query(`select public.salvar_config('{"chave_inventada": 1}')`), /desconhecida/);
    await erro(db.query(`select public.salvar_config('{"bonus_tempo_min": 2}')`), /mínimo não pode ser maior/);
    await erro(db.query(`select public.salvar_config('{"diagnostico_corte_intermediario": 90}')`), /Intermediário/);
  });
  const { rows } = await db.query(`select valor from public.config where chave = 'pontos_facil'`);
  assert.equal(Number(rows[0].valor), 10);
});

test('config: novo peso padrão atualiza só as questões que usavam o padrão antigo', async () => {
  const r = (await um(u.admin, `select public.salvar_config('{"pontos_facil": 15}', true) as r`)).r;
  assert.equal(r.alteradas, 1);
  assert.equal(r.questoes_atualizadas, 2); // q.fg e q.vet; q.vetCustom (99) fica
  const pesos = (await db.query(`select id, peso_pontos from public.questoes`)).rows;
  assert.equal(pesos.find((x) => x.id === q.vet).peso_pontos, 15);
  assert.equal(pesos.find((x) => x.id === q.vetCustom).peso_pontos, 99);
  const novas = await salvarQuestao({ cursos: ['VET'], dificuldade: 1, status: 'RASCUNHO' });
  assert.equal((await db.query(`select peso_pontos from public.questoes where id = $1`, [novas])).rows[0].peso_pontos, 15);

  const aud = await um(u.admin, `select detalhes from public.auditoria where acao = 'CONFIG_ALTERADA'`);
  assert.deepEqual(aud.detalhes.valores.pontos_facil, { de: 10, para: 15 });
});

// ---------------------------------------------------------------------------
// Edição de perfis
// ---------------------------------------------------------------------------
test('perfil: coordenador edita aluno do seu curso; não alcança outros cursos', async () => {
  await como(db, u.coordVet, async () => {
    await db.query(`select public.atualizar_estudante($1, $2::jsonb)`, [u.vet, perfil({ turma: 'vet-2026a', status: 'BLOQUEADO' })]);
    await erro(db.query(`select public.atualizar_estudante($1, $2::jsonb)`,
      [u.ads, perfil({ nome: 'Aluno ADS', cpf: '12345678909', curso: 'ADS' })]), /fora dos seus cursos/);
    await erro(db.query(`select public.atualizar_estudante($1, $2::jsonb)`, [u.vet, perfil({ curso: 'ADS' })]),
      /não coordena/);
    await erro(db.query(`select public.atualizar_estudante($1, $2::jsonb)`, [u.vet, perfil({ cpf: '52998224725' })]),
      /outro aluno/);
    await erro(db.query(`select public.atualizar_estudante($1, $2::jsonb)`, [u.vet, perfil({ cpf: '11111111111' })]),
      /CPF inválido/);
  });
  const e = (await db.query(`select turma, status from public.estudantes where id = $1`, [u.vet])).rows[0];
  assert.deepEqual(e, { turma: 'VET-2026A', status: 'BLOQUEADO' });

  // Só as diferenças vão para a auditoria; o coordenador vê o histórico do aluno.
  const aud = await um(u.coordVet, `select detalhes from public.auditoria where alvo_id = $1`, [u.vet]);
  assert.deepEqual(Object.keys(aud.detalhes).sort(), ['status', 'turma']);
  await como(db, u.vet, async () => {
    await erro(db.query(`select public.atualizar_estudante($1, $2::jsonb)`, [u.vet, perfil()]), /fora dos seus cursos/);
  });

  // Admin desbloqueia e pode transferir de curso.
  await como(db, u.admin, () => db.query(`select public.atualizar_estudante($1, $2::jsonb)`, [u.vet, perfil()]));
});

// ---------------------------------------------------------------------------
// Nova tentativa de simulado
// ---------------------------------------------------------------------------
test('nova tentativa: anula a anterior, guarda histórico e recomeça do zero', async () => {
  await como(db, u.vet, async () => {
    await db.query(`select public.iniciar_simulado($1)`, [sid]);
    const r1 = (await db.query(`select public.responder_questao($1, 'B', null, $2) as j`, [q.fg, sid])).rows[0].j;
    assert.ok(r1.registrada);
    await db.query(`select public.finalizar_simulado($1)`, [sid]);
  });
  // Pontos gravados (no resumo do aluno só aparecem quando o gabarito é liberado).
  const pontosGravados = async () => (await db.query(
    `select coalesce(sum(pontos_ganhos), 0)::int p from public.respostas where estudante_id = $1`, [u.vet])).rows[0].p;
  const pontosAntes = await pontosGravados();
  assert.ok(pontosAntes > 0);

  await como(db, u.vet, () =>
    erro(db.query(`select public.liberar_nova_tentativa($1, $2, 'Queda de internet')`, [sid, u.vet]), /fora dos seus cursos/));
  await como(db, u.coordVet, async () => {
    await erro(db.query(`select public.liberar_nova_tentativa($1, $2, '')`, [sid, u.vet]), /motivo/);
    await erro(db.query(`select public.liberar_nova_tentativa($1, $2, 'Queda de internet')`, [sid, u.vet2]), /não tem tentativa/);
    const r = (await db.query(`select public.liberar_nova_tentativa($1, $2, 'Queda de internet') as j`, [sid, u.vet])).rows[0].j;
    assert.equal(r.proxima_tentativa, 2);
  });

  const lista = (await um(u.vet, `select public.meus_simulados() as j`)).j;
  assert.equal(lista[0].situacao, 'DISPONIVEL');
  assert.equal(lista[0].nova_tentativa, true);

  await como(db, u.vet, async () => {
    const ini = (await db.query(`select public.iniciar_simulado($1) as j`, [sid])).rows[0].j;
    assert.equal(ini.tentativa, 2);
    assert.deepEqual(ini.respondidas, []);
    await db.query(`select public.responder_questao($1, 'A', null, $2)`, [q.fg, sid]); // agora errou
    await db.query(`select public.responder_questao($1, 'C', null, $2)`, [q.vet, sid]); // acertou
    await db.query(`select public.finalizar_simulado($1)`, [sid]);
    const res = (await db.query(`select public.resultado_simulado($1) as j`, [sid])).rows[0].j;
    assert.equal(res.tentativa, 2);
    assert.equal(res.desempenho.respondidas, 2);
    assert.equal(res.desempenho.componentes.FG.obj_acertos, 0);
    assert.equal(res.desempenho.componentes.CE.obj_acertos, 1);
  });

  // Questão já respondida na tentativa anulada não pontua de novo; a inédita pontua.
  const pontosDepois = await pontosGravados();
  assert.ok(pontosDepois > pontosAntes);

  const rev = (await um(u.coordVet, `select public.revisao_simulado_aluno($1, $2) as j`, [sid, u.vet])).j;
  assert.equal(rev.participacao.tentativa, 2);
  assert.equal(rev.anuladas.length, 1);
  assert.equal(rev.anuladas[0].motivo, 'Queda de internet');
  assert.equal(rev.anuladas[0].liberada_por, 'Coord VET');
  assert.equal(rev.questoes.find((x) => x.id === q.fg).alternativa, 'A');

  // Relatório conta só a tentativa vigente.
  const rel = (await um(u.coordVet, `select public.relatorio_simulado($1) as j`, [sid])).j;
  const fg = rel.questoes.find((x) => x.id === q.fg);
  assert.equal(fg.respostas.total, 1);
  assert.equal(fg.respostas.A, 1);
  assert.equal(fg.respostas.B, 0);
});

test('nova tentativa após o encerramento exige prazo individual; gabarito fica retido para o aluno', async () => {
  await como(db, u.vet2, async () => {
    await db.query(`select public.iniciar_simulado($1)`, [sid]);
    await db.query(`select public.responder_questao($1, 'C', null, $2)`, [q.vet, sid]);
    await db.query(`select public.finalizar_simulado($1)`, [sid]);
  });
  await db.query(`update public.sessoes set fim = now() - interval '1 second' where id = $1`, [sid]);

  await como(db, u.coordVet, async () => {
    await erro(db.query(`select public.liberar_nova_tentativa($1, $2, 'Atestado médico')`, [sid, u.vet2]), /informe até quando/);
    await erro(db.query(`select public.liberar_nova_tentativa($1, $2, 'Atestado médico', now() - interval '1 hour')`,
      [sid, u.vet2]), /futuro/);
    await db.query(`select public.liberar_nova_tentativa($1, $2, 'Atestado médico', now() + interval '2 days')`, [sid, u.vet2]);
  });

  // A colega já vê o gabarito (inclusive da tentativa anulada); o aluno com prazo estendido, não.
  assert.equal((await como(db, u.vet, () => db.query(`select 1 from public.respostas where sessao_id = $1`, [sid]))).rows.length, 3);
  await como(db, u.vet2, async () => {
    assert.equal((await db.query(`select 1 from public.respostas where sessao_id = $1`, [sid])).rows.length, 0);
    await erro(db.query(`select public.devolutiva_questao($1)`, [q.vet]), /indisponível/);
    const ini = (await db.query(`select public.iniciar_simulado($1) as j`, [sid])).rows[0].j;
    assert.equal(ini.tentativa, 2);
    await db.query(`select public.responder_questao($1, 'B', null, $2)`, [q.fg, sid]);
  });
  // Questões continuam fora do treino enquanto o prazo individual corre.
  await como(db, u.ads, () => erro(db.query(`select public.exibir_questao($1)`, [q.fg]), /indisponível/));

  // Simulado com tentativa anulada segue travado.
  const s = (await db.query(`select * from public.sessoes where id = $1`, [sid])).rows[0];
  await como(db, u.coordVet, () => erro(db.query(`select public.salvar_simulado($1::jsonb)`, [JSON.stringify({
    id: sid, titulo: s.titulo, curso: 'VET', duracao_minutos: 60, publicada: true, questoes: [q.vet],
    inicio: s.inicio.toISOString(), fim: s.fim.toISOString(),
  })]), /só o título e o encerramento/));
});

// ---------------------------------------------------------------------------
// Importação de questões
// ---------------------------------------------------------------------------
test('importação: simulação aponta erros por linha sem gravar; lote com erro é cancelado', async () => {
  const contar = async () => (await db.query(`select count(*)::int n from public.questoes`)).rows[0].n;
  const antes = await contar();
  const linhas = [
    { ...Q, _linha: 2, cursos: ['VET'], eixo: 'Anatomia', enunciado: 'Importada 1' },
    { ...Q, _linha: 3, cursos: ['VET'], eixo: 'Anatomia', enunciado: 'Importada 2', gabarito: '' },
    { ...Q, _linha: 4, cursos: ['ADS'], eixo: 'Redes', enunciado: 'Importada 3' },
  ];

  const sim = (await um(u.coordVet, `select public.importar_questoes($1::jsonb, true) as r`, [JSON.stringify(linhas)])).r;
  assert.equal(sim.validas, 1);
  assert.deepEqual(sim.erros.map((e) => e.linha), [3, 4]);
  assert.match(sim.erros[0].erro, /gabarito/);
  assert.match(sim.erros[1].erro, /cursos que coordena/);
  assert.equal(await contar(), antes);

  await como(db, u.coordVet, () =>
    erro(db.query(`select public.importar_questoes($1::jsonb, false)`, [JSON.stringify(linhas)]), /Nada foi salvo/));
  assert.equal(await contar(), antes);

  const ok = (await um(u.coordVet, `select public.importar_questoes($1::jsonb, false) as r`, [JSON.stringify([linhas[0]])])).r;
  assert.equal(ok.validas, 1);
  assert.equal(await contar(), antes + 1);
  await como(db, u.vet, () => erro(db.query(`select public.importar_questoes('[{}]'::jsonb)`), /restrito/));
});

// ---------------------------------------------------------------------------
// LGPD
// ---------------------------------------------------------------------------
test('exclusão LGPD apaga o histórico de alterações do aluno', async () => {
  await como(db, u.admin, () => db.query(`select public.excluir_estudante_lgpd($1)`, [u.vet]));
  const { rows } = await db.query(`select 1 from public.auditoria where alvo_id = $1`, [u.vet]);
  assert.equal(rows.length, 0);
  const lib = await db.query(`select 1 from public.sessoes_liberacoes where estudante_id = $1`, [u.vet]);
  assert.equal(lib.rows.length, 0);
});
