import { test, before } from 'node:test';
import assert from 'node:assert/strict';
import { criarBanco, como, criarUsuario } from './harness.mjs';

let db;
const u = {}; // ids de usuários
const q = {}; // ids de questões

async function erro(promessa, padrao) {
  await assert.rejects(promessa, (e) => {
    assert.match(e.message, padrao);
    return true;
  });
}

async function criarQuestao(dados) {
  const d = {
    componente: 'CE', cursos: '{ENG_MEC}', eixo: 'Mecânica dos Sólidos', formato: 'OBJETIVA',
    dificuldade: 2, gabarito: 'C', justificativa: 'Porque sim.', status: 'PUBLICADA', ...dados,
  };
  const obj = d.formato === 'OBJETIVA';
  const { rows } = await db.query(
    `insert into public.questoes (componente, cursos, eixo, formato, enunciado,
       alt_a, alt_b, alt_c, alt_d, alt_e, dificuldade, status)
     values ($1::public.componente, $2::public.curso_alvo[], $3, $4::public.formato_questao, $5,
       $6, $7, $8, $9, $10, $11, 'RASCUNHO') returning id`,
    [d.componente, d.cursos, d.eixo, d.formato, `Enunciado ${d.eixo}`,
     obj ? 'a' : null, obj ? 'b' : null, obj ? 'c' : null, obj ? 'd' : null, obj ? 'e' : null, d.dificuldade],
  );
  const id = rows[0].id;
  await db.query('insert into public.questoes_gabarito (questao_id, gabarito, justificativa) values ($1, $2, $3)',
    [id, obj ? d.gabarito : null, d.justificativa]);
  if (d.status !== 'RASCUNHO') {
    await db.query('update public.questoes set status = $2::public.status_questao where id = $1', [id, d.status]);
  }
  return id;
}

// Treino: exibe e responde. atrasoSeg simula o tempo que o aluno levou.
async function responderTreino(uid, questaoId, alternativa, atrasoSeg = 0, texto = null) {
  await como(db, uid, () => db.query('select public.exibir_questao($1)', [questaoId]));
  if (atrasoSeg) {
    await db.query(
      `update public.exibicoes_questao set exibida_em = exibida_em - make_interval(secs => $3)
        where id = (select max(id) from public.exibicoes_questao where estudante_id = $1 and questao_id = $2)`,
      [uid, questaoId, atrasoSeg]);
  }
  const { rows } = await como(db, uid, () =>
    db.query('select public.responder_questao($1, $2, $3) as r', [questaoId, alternativa, texto]));
  return rows[0].r;
}

before(async () => {
  db = await criarBanco();

  u.admin   = await criarUsuario(db, 'coord@univc.edu.br');
  u.docente = await criarUsuario(db, 'docente@univc.edu.br');
  u.mec     = await criarUsuario(db, 'Aluno.Mec@Gmail.com');
  u.ads     = await criarUsuario(db, 'aluna.ads@gmail.com');
  u.prod    = await criarUsuario(db, 'aluno.prod@gmail.com');
  u.intruso = await criarUsuario(db, 'intruso@gmail.com');
  u.semCad  = await criarUsuario(db, 'semcadastro@gmail.com');

  await db.query(`insert into public.staff (user_id, nome, papel, cursos) values
    ($1, 'Coordenação', 'ADMIN', null), ($2, 'Docente', 'DOCENTE', '{ENG_MEC,ENG_PROD,ADS,VET,ARQ}')`, [u.admin, u.docente]);

  u.forca1  = await criarUsuario(db, 'forca1@gmail.com');

  q.fg       = await criarQuestao({ componente: 'FG', cursos: '{ALL}', eixo: 'Ética', dificuldade: 2, gabarito: 'B' });
  q.fg2      = await criarQuestao({ componente: 'FG', cursos: '{ALL}', eixo: 'Sustentabilidade', dificuldade: 1, gabarito: 'A' });
  q.nucleo   = await criarQuestao({ cursos: '{ENG_MEC,ENG_PROD}', eixo: 'Cálculo', dificuldade: 1, gabarito: 'D' });
  q.mec      = await criarQuestao({ cursos: '{ENG_MEC}', eixo: 'Termodinâmica', dificuldade: 3, gabarito: 'E' });
  q.mec2     = await criarQuestao({ cursos: '{ENG_MEC}', eixo: 'Termodinâmica', dificuldade: 2, gabarito: 'A' });
  q.ads      = await criarQuestao({ cursos: '{ADS}', eixo: 'Banco de Dados', dificuldade: 3, gabarito: 'C' });
  q.rascunho = await criarQuestao({ cursos: '{ENG_MEC}', eixo: 'Termodinâmica', status: 'RASCUNHO' });
  q.disc     = await criarQuestao({ componente: 'FG', cursos: '{ALL}', eixo: 'Ética', formato: 'DISCURSIVA',
                                    dificuldade: 3, justificativa: 'Padrão de resposta esperado.' });
});

// ---------------------------------------------------------------------------
test('RLS ativado em todas as tabelas de public', async () => {
  const { rows } = await db.query(`
    select c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
     where n.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity`);
  assert.deepEqual(rows, []);
});

test('seed da config com as chaves de pontuação e valores iniciais', async () => {
  const { rows } = await db.query(`select chave, valor from public.config where chave not like 'diagnostico%' and chave <> 'pontos_diagnostico' order by chave`);
  const cfg = Object.fromEntries(rows.map((r) => [r.chave, Number(r.valor)]));
  assert.deepEqual(cfg, {
    bonus_tempo_max: 1, bonus_tempo_min: 0.7, limite_bonus_tempo_seg: 120, multiplicador_fg: 1.3,
    enade_peso_fg: 0.25, enade_fg_peso_objetivas: 0.6, enade_ce_peso_objetivas: 0.85,
    pontos_dificil: 35, pontos_facil: 10, pontos_media: 20, sequencia_incremento: 0.05, sequencia_teto: 1.5,
  });
});

// ---------------------------------------------------------------------------
test('anon não lê nenhuma tabela nem chama RPCs', async () => {
  await como(db, null, async () => {
    for (const t of ['config', 'questoes', 'questoes_gabarito', 'respostas', 'estudantes', 'matriculas_autorizadas']) {
      await erro(db.query(`select * from public.${t}`), /permission denied/);
    }
    await erro(db.query(`select public.exibir_questao($1)`, [q.fg]), /permission denied/);
    await erro(db.query(`select public.concluir_cadastro('Ana Mecânica', '12345678909', '2000-03-15', '27999991234', 'ENG_MEC', 'MEC', 'CONCLUINTE', null, true)`), /permission denied/);
  });
});

test('funções internas não são executáveis pelo aluno', async () => {
  await como(db, u.intruso, async () => {
    await erro(db.query(`select interno.calcular_pontos(35, 0, 0, 'FG')`), /permission denied/);
    await erro(db.query(`select interno.questao_json(q) from public.questoes q`), /permission denied/);
  });
});

// ---------------------------------------------------------------------------
const ALUNO_PADRAO = {
  nome: 'Aluno Teste', cpf: '52998224725', nasc: '2000-01-01', tel: '27999990000',
  curso: 'ADS', turma: 'ADS-2023', tipo: 'CONCLUINTE', matricula: null, lgpd: true,
};

async function cadastrar(uid, dados = {}) {
  const d = { ...ALUNO_PADRAO, ...dados };
  const { rows } = await como(db, uid, () => db.query(
    `select public.concluir_cadastro($1, $2, $3::date, $4, $5::public.curso, $6, $7::public.tipo_estudante, $8, $9) as r`,
    [d.nome, d.cpf, d.nasc, d.tel, d.curso, d.turma, d.tipo, d.matricula, d.lgpd]));
  return rows[0].r;
}

test('cadastro livre: validações de formato e LGPD', async () => {
  const cod = async (dados) => (await cadastrar(u.mec, dados)).codigo;
  assert.equal(await cod({ lgpd: false }), 'LGPD_OBRIGATORIO');
  assert.equal(await cod({ nome: 'Ana' }), 'NOME_INVALIDO');
  assert.equal(await cod({ cpf: '12345678900' }), 'CPF_INVALIDO');
  assert.equal(await cod({ cpf: '11111111111' }), 'CPF_INVALIDO');
  assert.equal(await cod({ tel: '9999' }), 'TELEFONE_INVALIDO');
  assert.equal(await cod({ nasc: '2030-01-01' }), 'DATA_INVALIDA');
  assert.equal(await cod({ turma: '   ' }), 'TURMA_INVALIDA');
  assert.equal(await cod({ curso: null }), 'CURSO_INVALIDO');
  assert.equal(await cod({ tipo: null }), 'TIPO_INVALIDO');
});

test('usuário sem cadastro não acessa questões', async () => {
  await como(db, u.semCad, async () => {
    await erro(db.query(`select public.proxima_questao_treino()`), /Cadastro não concluído/);
  });
});

test('cadastro livre: aluno informa os próprios dados, sem pré-cadastro', async () => {
  const r = await cadastrar(u.mec, {
    nome: '  Ana   Mecânica ', cpf: '123.456.789-09', nasc: '2000-03-15', tel: '(27) 99999-1234',
    curso: 'ENG_MEC', turma: ' mec-2021 ', tipo: 'CONCLUINTE', matricula: '2021001',
  });
  assert.equal(r.ok, true, JSON.stringify(r));
  const e = (await db.query(`select * from public.estudantes where id = $1`, [u.mec])).rows[0];
  assert.equal(e.nome, 'Ana Mecânica');
  assert.equal(e.email_pessoal, 'aluno.mec@gmail.com');
  assert.equal(e.cpf, '12345678909');
  assert.equal(e.matricula, '2021001');
  assert.equal(e.curso, 'ENG_MEC');
  assert.equal(e.turma, 'MEC-2021');
  assert.equal(e.telefone, '27999991234');
  assert.equal(e.status, 'ATIVO');
  assert.ok(e.consentimento_lgpd && e.consentimento_data);

  // Matrícula é opcional
  assert.equal((await cadastrar(u.ads, { nome: 'Bia ADS Silva', cpf: '98765432100', curso: 'ADS' })).ok, true);
  assert.equal((await cadastrar(u.prod, { nome: 'Caio Produção', cpf: '11144477735', curso: 'ENG_PROD',
                                          turma: 'PROD-2024', tipo: 'INGRESSANTE' })).ok, true);
});

test('cadastro livre: um cadastro por CPF e por matrícula', async () => {
  assert.equal((await cadastrar(u.intruso, { cpf: '12345678909' })).codigo, 'JA_VINCULADO');
  assert.equal((await cadastrar(u.intruso, { cpf: '22233366638', matricula: '2021001' })).codigo, 'MATRICULA_EM_USO');
  assert.equal((await cadastrar(u.mec, { cpf: '12345678909' })).codigo, 'CADASTRO_EXISTENTE');
});

test('cadastro livre: conta da coordenação não vira aluno', async () => {
  assert.equal((await cadastrar(u.admin, { cpf: '22233366638' })).codigo, 'CONTA_STAFF');
});

test('cadastro livre: limite de 5 conflitos por hora por conta', async () => {
  for (let i = 0; i < 5; i++) {
    assert.equal((await cadastrar(u.forca1, { cpf: '12345678909' })).codigo, 'JA_VINCULADO');
  }
  assert.equal((await cadastrar(u.forca1, { cpf: '22233366638' })).codigo, 'LIMITE_TENTATIVAS');
});

test('tentativas de cadastro: aluno não lê; CPF não fica em claro', async () => {
  await como(db, u.mec, async () => {
    assert.equal((await db.query(`select * from public.tentativas_cadastro`)).rows.length, 0);
  });
  const { rows } = await db.query(`select cpf_hash from public.tentativas_cadastro`);
  assert.ok(rows.length > 0 && rows.every((r) => !r.cpf_hash || !r.cpf_hash.includes('12345678909')));
});

test('aluno não lê CPF de outros alunos', async () => {
  await como(db, u.ads, async () => {
    const { rows } = await db.query(`select cpf from public.estudantes`);
    assert.deepEqual(rows.map((r) => r.cpf), ['98765432100']);
  });
});

test('meu_contexto identifica staff, estudante e sem cadastro', async () => {
  const ctx = async (uid) => (await como(db, uid, () => db.query(`select public.meu_contexto() as c`))).rows[0].c;
  assert.equal((await ctx(u.admin)).staff.papel, 'ADMIN');
  assert.equal((await ctx(u.mec)).estudante.curso, 'ENG_MEC');
  assert.deepEqual(await ctx(u.semCad), { staff: null, estudante: null });
});

test('aluno vê só o próprio registro e não consegue se alterar', async () => {
  await como(db, u.mec, async () => {
    const { rows } = await db.query(`select id from public.estudantes`);
    assert.deepEqual(rows.map((r) => r.id), [u.mec]);
    const up = await db.query(`update public.estudantes set curso = 'ADS', status = 'ATIVO' where id = $1`, [u.mec]);
    assert.equal(up.affectedRows, 0);
    await erro(db.query(`delete from public.estudantes where id = $1`, [u.mec]), /permission denied/);
    await erro(db.query(`insert into public.estudantes (id, email_pessoal, nome, matricula, curso, turma, tipo)
                         values ($1, 'x@x.com', 'x', '2021002', 'ADS', 'x', 'CONCLUINTE')`, [u.intruso]),
               /permission denied/);
  });
});

// ---------------------------------------------------------------------------
// REGRA 1 — gabarito nunca exposto antes de responder
// ---------------------------------------------------------------------------
test('REGRA 1: aluno não lê questoes nem questoes_gabarito diretamente', async () => {
  await como(db, u.mec, async () => {
    assert.equal((await db.query(`select * from public.questoes_gabarito`)).rows.length, 0);
    assert.equal((await db.query(`select * from public.questoes`)).rows.length, 0);
    const up = await db.query(`update public.questoes_gabarito set gabarito = 'A'`);
    assert.equal(up.affectedRows, 0);
  });
});

test('REGRA 1: payload da questão não contém gabarito nem justificativa', async () => {
  const { rows } = await como(db, u.mec, () => db.query(`select public.exibir_questao($1) as j`, [q.mec]));
  const j = rows[0].j;
  assert.equal(j.enunciado, 'Enunciado Termodinâmica');
  assert.deepEqual(Object.keys(j.alternativas), ['A', 'B', 'C', 'D', 'E']);
  const texto = JSON.stringify(j);
  assert.ok(!('gabarito' in j) && !('justificativa' in j));
  assert.ok(!texto.includes('Porque sim.'));
});

test('REGRA 1: devolutiva_questao bloqueada antes de responder', async () => {
  await como(db, u.mec, () => erro(db.query(`select public.devolutiva_questao($1)`, [q.mec2]), /responda a questão primeiro/));
});

test('visibilidade por curso: FG para todos, núcleo comum MEC+PROD, CE isolado', async () => {
  await como(db, u.ads, async () => {
    await db.query(`select public.exibir_questao($1)`, [q.fg]);
    await erro(db.query(`select public.exibir_questao($1)`, [q.mec]), /indisponível/);
    await erro(db.query(`select public.exibir_questao($1)`, [q.nucleo]), /indisponível/);
  });
  await como(db, u.prod, async () => {
    await db.query(`select public.exibir_questao($1)`, [q.nucleo]);
    await erro(db.query(`select public.exibir_questao($1)`, [q.mec]), /indisponível/);
  });
  await como(db, u.mec, async () => {
    await erro(db.query(`select public.exibir_questao($1)`, [q.rascunho]), /indisponível/);
    const { rows } = await db.query(`select * from public.eixos_disponiveis()`);
    assert.deepEqual(rows.map((r) => `${r.componente}:${r.eixo}`).sort(),
      ['CE:Cálculo', 'CE:Termodinâmica', 'FG:Sustentabilidade', 'FG:Ética']);
  });
});

test('proxima_questao_treino respeita filtros e não repete respondidas', async () => {
  await como(db, u.ads, async () => {
    const { rows } = await db.query(`select public.proxima_questao_treino('CE', null, null) as j`);
    assert.equal(rows[0].j.id, q.ads);
    const nada = await db.query(`select public.proxima_questao_treino('CE', 'Cálculo', null) as j`);
    assert.equal(nada.rows[0].j, null);
  });
});

// ---------------------------------------------------------------------------
// REGRA 2 — respostas append-only
// ---------------------------------------------------------------------------
test('REGRA 2: aluno não insere/altera/apaga respostas diretamente', async () => {
  await como(db, u.mec, async () => {
    await erro(db.query(`insert into public.respostas (estudante_id, questao_id, alternativa, correta, tempo_segundos, pontos_ganhos, tentativa_n)
                         values ($1, $2, 'E', true, 1, 999, 1)`, [u.mec, q.mec]), /permission denied/);
    await erro(db.query(`update public.respostas set pontos_ganhos = 999`), /permission denied/);
    await erro(db.query(`delete from public.respostas`), /permission denied/);
  });
});

test('responder exige exibição prévia da questão', async () => {
  await como(db, u.mec, () =>
    erro(db.query(`select public.responder_questao($1, 'A')`, [q.fg2]), /Abra a questão/));
});

// ---------------------------------------------------------------------------
// Motor de pontuação + REGRAS 3 e 4
// ---------------------------------------------------------------------------
test('motor: fórmula, decaimento do tempo, teto da sequência e multiplicador FG', async () => {
  const calc = async (...a) =>
    (await db.query(`select interno.calcular_pontos($1, $2, $3, $4::public.componente) as p`, a)).rows[0].p;
  assert.equal(await calc(20, 0, 0, 'CE'), 20);     // instantâneo
  assert.equal(await calc(20, 60, 0, 'CE'), 17);    // 20 × 0.85
  assert.equal(await calc(20, 120, 0, 'CE'), 14);   // 20 × 0.7
  assert.equal(await calc(20, 999, 0, 'CE'), 14);   // não passa do mínimo
  assert.equal(await calc(20, 0, 4, 'CE'), 24);     // 20 × 1.20
  assert.equal(await calc(10, 0, 50, 'CE'), 15);    // teto 1.5
  assert.equal(await calc(20, 0, 0, 'FG'), 26);     // 20 × 1.3
  assert.equal(await calc(35, 120, 10, 'FG'), 48);  // 35 × 0.7 × 1.5 × 1.3 = 47.775
});

test('treino: acerto na 1ª tentativa pontua e devolve justificativa', async () => {
  const r = await responderTreino(u.mec, q.mec, 'e', 60); // dif 3 = 35 pts, 60s → ×0.85
  assert.equal(r.correta, true);
  assert.equal(r.gabarito, 'E');
  assert.equal(r.justificativa, 'Porque sim.');
  assert.equal(r.tentativa_n, 1);
  assert.equal(r.pontos, 30); // round(35 × 0.85) = 29.75
  assert.equal(r.sequencia, 1);
  assert.ok(r.tempo_segundos >= 60 && r.tempo_segundos < 65);
});

test('treino: sequência aplica +5% no acerto seguinte', async () => {
  const r = await responderTreino(u.mec, q.nucleo, 'D'); // 10 × 1.0 × 1.05
  assert.equal(r.sequencia, 2);
  assert.equal(r.pontos, 11); // round(10.5) = 11 (half away from zero)
});

test('REGRA 4: erro vale 0 pontos e zera a sequência', async () => {
  const r = await responderTreino(u.mec, q.fg, 'A');
  assert.equal(r.correta, false);
  assert.equal(r.pontos, 0);
  assert.equal(r.sequencia, 0);
  assert.equal(r.gabarito, 'B');
});

test('REGRA 3: só a 1ª tentativa pontua (e não mexe na sequência)', async () => {
  const r = await responderTreino(u.mec, q.fg, 'B');
  assert.equal(r.correta, true);
  assert.equal(r.tentativa_n, 2);
  assert.equal(r.pontos, 0);
  assert.equal(r.pontuou, false);
  assert.equal(r.sequencia, null);

  const prox = await responderTreino(u.mec, q.fg2, 'A'); // sequência voltou de 0 → 1
  assert.equal(prox.sequencia, 1);
  assert.equal(prox.pontos, 13); // 10 × 1.0 × 1.0 × 1.3
});

test('reabrir a questão não reinicia o cronômetro (anti-trapaça no bônus de tempo)', async () => {
  const id = await criarQuestao({ cursos: '{ENG_PROD}', eixo: 'Logística', dificuldade: 2, gabarito: 'A' });
  await como(db, u.prod, () => db.query('select public.exibir_questao($1)', [id]));
  await db.query(`update public.exibicoes_questao set exibida_em = exibida_em - interval '120 seconds'
                   where estudante_id = $1 and questao_id = $2`, [u.prod, id]);
  await como(db, u.prod, () => db.query('select public.exibir_questao($1)', [id])); // reabre agora
  const r = (await como(db, u.prod, () => db.query('select public.responder_questao($1, $2) as r', [id, 'A']))).rows[0].r;
  assert.ok(r.tempo_segundos >= 120);
  assert.equal(r.pontos, 14); // 20 × 0.7, não 20
});

test('aluno lê as próprias respostas de treino; não vê as de outros', async () => {
  await responderTreino(u.ads, q.fg, 'B');
  await como(db, u.mec, async () => {
    const { rows } = await db.query(`select estudante_id from public.respostas`);
    assert.ok(rows.length >= 4 && rows.every((r) => r.estudante_id === u.mec));
    const dev = (await db.query(`select public.devolutiva_questao($1) as j`, [q.fg])).rows[0].j;
    assert.equal(dev.gabarito, 'B');
    assert.equal(dev.respostas.length, 2);
  });
});

test('REGRA 2: append-only vale até para o superusuário', async () => {
  await erro(db.query(`update public.respostas set pontos_ganhos = 999`), /append-only/);
  await erro(db.query(`delete from public.respostas`), /append-only/);
  await erro(db.query(`truncate public.respostas cascade`), /append-only/);
});

// ---------------------------------------------------------------------------
// REGRA 5 — config editável sem redeploy
// ---------------------------------------------------------------------------
test('REGRA 5: admin edita config e o motor usa o novo valor; aluno não edita', async () => {
  await como(db, u.mec, async () => {
    const up = await db.query(`update public.config set valor = '99' where chave = 'multiplicador_fg'`);
    assert.equal(up.affectedRows, 0);
  });
  await como(db, u.admin, () => db.query(`update public.config set valor = '2' where chave = 'multiplicador_fg'`));
  const p = (await db.query(`select interno.calcular_pontos(10, 0, 0, 'FG') as p`)).rows[0].p;
  assert.equal(p, 20);
  await como(db, u.admin, () => db.query(`update public.config set valor = '1.3' where chave = 'multiplicador_fg'`));
});

test('peso_pontos derivado da dificuldade, mas editável', async () => {
  await como(db, u.admin, async () => {
    const { rows } = await db.query(`
      insert into public.questoes (componente, cursos, eixo, formato, enunciado, alt_a, alt_b, alt_c, alt_d, alt_e, dificuldade)
      values ('CE', '{ADS}', 'Redes', 'OBJETIVA', 'x', 'a','b','c','d','e', 1) returning id, peso_pontos, autor_id`);
    const id = rows[0].id;
    assert.equal(rows[0].peso_pontos, 10);
    assert.equal(rows[0].autor_id, u.admin);
    let r = await db.query(`update public.questoes set dificuldade = 3 where id = $1 returning peso_pontos`, [id]);
    assert.equal(r.rows[0].peso_pontos, 35);
    r = await db.query(`update public.questoes set peso_pontos = 40 where id = $1 returning peso_pontos`, [id]);
    assert.equal(r.rows[0].peso_pontos, 40);
    // Não publica sem gabarito
    await erro(db.query(`update public.questoes set status = 'PUBLICADA' where id = $1`, [id]), /sem gabarito/);
    await db.query(`insert into public.questoes_gabarito (questao_id, gabarito, justificativa) values ($1, 'B', 'j')`, [id]);
    await db.query(`update public.questoes set status = 'PUBLICADA' where id = $1`, [id]);
    await erro(db.query(`update public.questoes_gabarito set gabarito = null where questao_id = $1`, [id]), /sem gabarito/);
  });
});

test('restrições: FG só com ALL; CE sem ALL; objetiva com 5 alternativas', async () => {
  const ins = (comp, cursos, alts = true) => db.query(
    `insert into public.questoes (componente, cursos, eixo, enunciado, alt_a, alt_b, alt_c, alt_d, alt_e, dificuldade)
     values ($1::public.componente, $2::public.curso_alvo[], 'e', 'x', $3, 'b', 'c', 'd', 'e', 1)`,
    [comp, cursos, alts ? 'a' : null]);
  await erro(ins('FG', '{ADS}'), /questoes_cursos_coerentes/);
  await erro(ins('CE', '{ALL}'), /questoes_cursos_coerentes/);
  await erro(ins('CE', '{}'), /questoes_cursos_coerentes/);
  await erro(ins('CE', '{ADS}', false), /questoes_alternativas_coerentes/);
});

test('docente não cria questões; aluno não cria sessões', async () => {
  await como(db, u.docente, () => erro(db.query(`
    insert into public.questoes (componente, cursos, eixo, enunciado, alt_a, alt_b, alt_c, alt_d, alt_e, dificuldade)
    values ('CE', '{ADS}', 'e', 'x', 'a','b','c','d','e', 1)`), /row-level security/));
  await como(db, u.mec, () => erro(db.query(`
    insert into public.sessoes (titulo, inicio, fim, duracao_minutos) values ('x', now(), now() + interval '1h', 60)`),
    /row-level security/));
});

// ---------------------------------------------------------------------------
// Discursivas
// ---------------------------------------------------------------------------
test('discursiva: não pontua automaticamente; docente corrige depois', async () => {
  const r = await responderTreino(u.ads, q.disc, null, 0, 'Minha resposta sobre ética.');
  assert.equal(r.aguardando_correcao, true);
  assert.equal(r.correta, null);
  assert.equal(r.pontos, 0);

  await como(db, u.ads, () =>
    erro(db.query(`select public.corrigir_discursiva($1, 100)`, [r.resposta_id]), /equipe docente/));
  const c = (await como(db, u.docente, () =>
    db.query(`select * from public.corrigir_discursiva($1, 80, 'Bom argumento')`, [r.resposta_id]))).rows[0];
  assert.equal(c.pontos, 36); // 35 × 0.8 × 1.3 = 36.4
  const vis = await como(db, u.ads, () => db.query(`select nota from public.correcoes_discursivas`));
  assert.equal(Number(vis.rows[0].nota), 80);
});

// ---------------------------------------------------------------------------
// Simulado: sem devolutiva durante a prova
// ---------------------------------------------------------------------------
test('simulado: questões reservadas saem do treino e não há devolutiva durante a prova', async () => {
  const { rows } = await db.query(`
    insert into public.sessoes (tipo, titulo, curso, inicio, fim, duracao_minutos, questoes, publicada)
    values ('SIMULADO', 'Simulado 1', 'ENG_MEC', now() - interval '1 minute', now() + interval '1 day', 60,
            array[$1, $2]::uuid[], true) returning id`, [q.mec2, q.fg2]);
  const sid = rows[0].id;

  await como(db, u.mec, async () => {
    await erro(db.query(`select public.exibir_questao($1)`, [q.mec2]), /indisponível/); // reservada
    await erro(db.query(`select public.responder_questao($1, 'A', null, $2)`, [q.mec2, sid]), /não iniciado/);

    const ini = (await db.query(`select public.iniciar_simulado($1) as j`, [sid])).rows[0].j;
    assert.equal(ini.questoes.length, 2);
    assert.ok(!JSON.stringify(ini).includes('Porque sim.'));
    assert.ok(ini.questoes.every((x) => !('gabarito' in x)));

    const r = (await db.query(`select public.responder_questao($1, 'A', null, $2) as j`, [q.mec2, sid])).rows[0].j;
    assert.deepEqual(Object.keys(r).sort(), ['registrada', 'resposta_id']);
    await erro(db.query(`select public.responder_questao($1, 'B', null, $2)`, [q.mec2, sid]), /já respondida/);

    // Resposta de simulado em andamento invisível (a coluna "correta" vazaria).
    const vis = await db.query(`select * from public.respostas where sessao_id = $1`, [sid]);
    assert.equal(vis.rows.length, 0);
    await erro(db.query(`select public.devolutiva_questao($1)`, [q.mec2]), /indisponível/);
  });

  await como(db, u.ads, () => erro(db.query(`select public.iniciar_simulado($1)`, [sid]), /indisponível/));

  await como(db, u.mec, async () => {
    await db.query(`select public.finalizar_simulado($1)`, [sid]);
    await erro(db.query(`select public.responder_questao($1, 'A', null, $2)`, [q.fg2, sid]), /finalizado/);
    // Finalizou, mas a janela segue aberta para os colegas: gabarito ainda retido.
    assert.equal((await db.query(`select * from public.respostas where sessao_id = $1`, [sid])).rows.length, 0);
    await erro(db.query(`select public.devolutiva_questao($1)`, [q.mec2]), /indisponível/);
  });

  // Janela fecha para todos: gabarito liberado.
  await db.query(`update public.sessoes set fim = now() - interval '1 second' where id = $1`, [sid]);
  await como(db, u.mec, async () => {
    const vis = await db.query(`select correta from public.respostas where sessao_id = $1`, [sid]);
    assert.equal(vis.rows.length, 1);
    assert.equal(vis.rows[0].correta, true);
    const dev = (await db.query(`select public.devolutiva_questao($1) as j`, [q.mec2])).rows[0].j;
    assert.equal(dev.gabarito, 'A');
  });
});

test('simulado: resposta após o tempo esgotado é recusada', async () => {
  const { rows } = await db.query(`
    insert into public.sessoes (tipo, titulo, inicio, fim, duracao_minutos, questoes, publicada)
    values ('SIMULADO', 'Simulado curto', now() - interval '2 hours', now() + interval '1 day', 30,
            array[$1]::uuid[], true) returning id`, [q.fg]);
  const sid = rows[0].id;
  await como(db, u.prod, () => db.query(`select public.iniciar_simulado($1)`, [sid]));
  await db.query(`update public.sessoes_participacao set iniciada_em = now() - interval '31 minutes'
                   where sessao_id = $1 and estudante_id = $2`, [sid, u.prod]);
  await como(db, u.prod, () =>
    erro(db.query(`select public.responder_questao($1, 'B', null, $2)`, [q.fg, sid]), /esgotado/));
});

// ---------------------------------------------------------------------------
// LGPD
// ---------------------------------------------------------------------------
test('LGPD: só admin elimina estudante (única via que remove respostas)', async () => {
  await como(db, u.ads, () => erro(db.query(`select public.excluir_estudante_lgpd($1)`, [u.ads]), /coordenação/));
  await como(db, u.admin, () => db.query(`select public.excluir_estudante_lgpd($1)`, [u.ads]));
  const { rows } = await db.query(`select count(*)::int n from public.respostas where estudante_id = $1`, [u.ads]);
  assert.equal(rows[0].n, 0);
  await erro(db.query(`delete from public.respostas`), /append-only/); // flag não vaza da transação
});
