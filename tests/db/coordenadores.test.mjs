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

const Q = {
  componente: 'CE', eixo: 'Eixo', formato: 'OBJETIVA', enunciado: 'Enunciado',
  alt_a: 'a', alt_b: 'b', alt_c: 'c', alt_d: 'd', alt_e: 'e', gabarito: 'A', dificuldade: 1, status: 'PUBLICADA',
};
const salvar = async (uid, dados) =>
  (await como(db, uid, () => db.query(`select public.salvar_questao($1::jsonb) as id`, [JSON.stringify({ ...Q, ...dados })]))).rows[0].id;
const cadastrar = (uid, nome, cpf, curso) => como(db, uid, () => db.query(
  `select public.concluir_cadastro($1, $2, '2000-01-01', '27999990000', $3::public.curso, 'T1', 'CONCLUINTE', null, true)`,
  [nome, cpf, curso]));

before(async () => {
  db = await criarBanco();
  u.admin = await criarUsuario(db, 'admin@univc.edu.br');
  await db.query(`insert into public.staff (user_id, nome, papel) values ($1, 'Admin', 'ADMIN')`, [u.admin]);
  u.alunoAds = await criarUsuario(db, 'ads@gmail.com');
  u.alunoVet = await criarUsuario(db, 'vet@gmail.com');
  u.alunoArq = await criarUsuario(db, 'arq@gmail.com');
  await cadastrar(u.alunoAds, 'Aluno ADS', '12345678909', 'ADS');
  await cadastrar(u.alunoVet, 'Aluna Veterinária', '98765432100', 'VET');
  await cadastrar(u.alunoArq, 'Aluno Arquitetura', '11144477735', 'ARQ');
});

test('novos cursos: Medicina Veterinária e Arquitetura e Urbanismo', async () => {
  const { rows } = await db.query(`select enum_range(null::public.curso)::text r`);
  assert.equal(rows[0].r, '{ENG_MEC,ENG_PROD,ADS,VET,ARQ}');
});

test('admin convida os três coordenadores; o convite vira perfil no primeiro login', async () => {
  const definir = (email, nome, papel, cursos) => como(db, u.admin, () => db.query(
    `select public.definir_membro_equipe($1, $2, $3::public.papel_staff, $4::public.curso[]) as r`,
    [email, nome, papel, cursos]));

  const r1 = (await definir('Coord.Vet@UNIVC.edu.br', 'Coordenação de Medicina Veterinária', 'COORDENADOR', '{VET}')).rows[0].r;
  assert.deepEqual(r1, { situacao: 'CONVIDADO', email: 'coord.vet@univc.edu.br' });
  await definir('coord.arq@univc.edu.br', 'Coordenação de Arquitetura e Urbanismo', 'COORDENADOR', '{ARQ}');
  await definir('coord.eng@univc.edu.br', 'Coordenação de Engenharias e ADS', 'COORDENADOR', '{ENG_MEC,ENG_PROD,ADS}');

  const lista = await como(db, u.admin, () => db.query(`select email, situacao from public.listar_equipe()`));
  assert.equal(lista.rows.filter((r) => r.situacao === 'CONVIDADO').length, 3);

  // Primeiro login (magic link cria o usuário em auth.users)
  u.coordVet = await criarUsuario(db, 'coord.vet@univc.edu.br');
  u.coordArq = await criarUsuario(db, 'coord.arq@univc.edu.br');
  u.coordEng = await criarUsuario(db, 'coord.eng@univc.edu.br');

  const ctx = (await como(db, u.coordEng, () => db.query(`select public.meu_contexto() as c`))).rows[0].c;
  assert.equal(ctx.staff.papel, 'COORDENADOR');
  assert.deepEqual(ctx.staff.cursos, ['ENG_MEC', 'ENG_PROD', 'ADS']);
  assert.equal(ctx.estudante, null);
  assert.equal((await db.query(`select count(*)::int n from public.staff_convites`)).rows[0].n, 0);
});

test('só o admin gerencia a equipe; coordenador não se promove', async () => {
  await como(db, u.coordVet, async () => {
    await erro(db.query(`select public.definir_membro_equipe('x@y.com', 'X', 'ADMIN', null)`), /administração geral/);
    await erro(db.query(`select * from public.listar_equipe()`), /administração geral/);
    const up = await db.query(`update public.staff set papel = 'ADMIN', cursos = null where user_id = auth.uid()`);
    assert.equal(up.affectedRows, 0);
  });
});

test('e-mail de aluno não vira coordenador; admin não se rebaixa', async () => {
  await como(db, u.admin, async () => {
    await erro(db.query(`select public.definir_membro_equipe('ads@gmail.com', 'X', 'COORDENADOR', '{ADS}')`), /cadastrado como aluno/);
    await erro(db.query(`select public.definir_membro_equipe('admin@univc.edu.br', 'X', 'COORDENADOR', '{ADS}')`), /próprio acesso/);
    await erro(db.query(`select public.definir_membro_equipe('z@univc.edu.br', 'Z', 'COORDENADOR', '{}')`), /ao menos um curso/);
  });
});

test('coordenador vê apenas os alunos dos seus cursos', async () => {
  const nomes = async (uid) =>
    (await como(db, uid, () => db.query(`select nome from public.estudantes order by nome`))).rows.map((r) => r.nome);
  assert.deepEqual(await nomes(u.coordVet), ['Aluna Veterinária']);
  assert.deepEqual(await nomes(u.coordArq), ['Aluno Arquitetura']);
  assert.deepEqual(await nomes(u.coordEng), ['Aluno ADS']);
  assert.equal((await nomes(u.admin)).length, 3);
});

test('coordenador bloqueia só aluno do seu curso', async () => {
  const bloquear = (uid, alvo) =>
    como(db, uid, () => db.query(`update public.estudantes set status = 'BLOQUEADO' where id = $1`, [alvo]));
  assert.equal((await bloquear(u.coordVet, u.alunoAds)).affectedRows, 0);
  assert.equal((await bloquear(u.coordVet, u.alunoVet)).affectedRows, 1);
  await db.query(`update public.estudantes set status = 'ATIVO' where id = $1`, [u.alunoVet]);
  // Não pode "mover" o aluno para fora do seu escopo
  await como(db, u.coordVet, () =>
    erro(db.query(`update public.estudantes set curso = 'ADS' where id = $1`, [u.alunoVet]), /row-level security/));
});

test('questões de CE: coordenador cria e edita só nos seus cursos', async () => {
  const vet = await salvar(u.coordVet, { cursos: ['VET'], eixo: 'Clínica de pequenos animais' });
  await erro(salvar(u.coordVet, { cursos: ['ADS'] }), /cursos que coordena/);
  await erro(salvar(u.coordVet, { cursos: ['VET', 'ARQ'] }), /cursos que coordena/);
  await erro(salvar(u.coordArq, { id: vet, cursos: ['ARQ'] }), /não pode editar/);
  await como(db, u.coordArq, () => erro(db.query(`select public.excluir_questao($1)`, [vet]), /não pode excluir/));

  const nucleo = await salvar(u.coordEng, { cursos: ['ENG_MEC', 'ENG_PROD'], eixo: 'Cálculo' });
  assert.ok(nucleo);

  const visiveis = async (uid) =>
    (await como(db, uid, () => db.query(`select eixo from public.questoes order by eixo`))).rows.map((r) => r.eixo);
  assert.deepEqual(await visiveis(u.coordVet), ['Clínica de pequenos animais']);
  assert.deepEqual(await visiveis(u.coordEng), ['Cálculo']);
  assert.equal((await visiveis(u.admin)).length, 2);

  // Gabarito também respeita o escopo
  const g = await como(db, u.coordArq, () => db.query(`select * from public.questoes_gabarito`));
  assert.equal(g.rows.length, 0);
});

test('Formação Geral: qualquer coordenador cria e vê; só autor ou admin edita', async () => {
  const fg = await salvar(u.coordArq, { componente: 'FG', eixo: 'Ética' });
  const vistas = await como(db, u.coordVet, () => db.query(`select id from public.questoes where id = $1`, [fg]));
  assert.equal(vistas.rows.length, 1);
  await erro(salvar(u.coordVet, { id: fg, componente: 'FG', eixo: 'Ética', enunciado: 'mudei' }), /não pode editar/);
  await salvar(u.coordArq, { id: fg, componente: 'FG', eixo: 'Ética', enunciado: 'revisado pelo autor' });
  await salvar(u.admin, { id: fg, componente: 'FG', eixo: 'Ética', enunciado: 'revisado pelo admin' });
});

test('aluno de VET vê questão de VET no treino e não vê a de engenharia', async () => {
  const { rows } = await db.query(`select id, cursos::text c from public.questoes where componente = 'CE'`);
  const vet = rows.find((r) => r.c === '{VET}').id;
  const eng = rows.find((r) => r.c.includes('ENG_MEC')).id;
  await como(db, u.alunoVet, async () => {
    await db.query(`select public.exibir_questao($1)`, [vet]);
    await erro(db.query(`select public.exibir_questao($1)`, [eng]), /indisponível/);
  });
});

test('admin remove coordenador', async () => {
  await como(db, u.admin, () => db.query(`select public.remover_membro_equipe('coord.arq@univc.edu.br')`));
  const ctx = (await como(db, u.coordArq, () => db.query(`select public.meu_contexto() as c`))).rows[0].c;
  assert.equal(ctx.staff, null);
  await como(db, u.admin, () => erro(db.query(`select public.remover_membro_equipe('admin@univc.edu.br')`), /próprio acesso/));
});
