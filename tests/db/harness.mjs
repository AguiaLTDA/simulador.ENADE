// Sobe um Postgres (PGlite/WASM) que imita o ambiente do Supabase o suficiente
// para testar schema, RLS e RPCs: papéis anon/authenticated/service_role,
// schema auth com auth.users e auth.uid(), e os default privileges que o
// Supabase concede em public (o pior caso: tudo liberado antes do RLS).
import { PGlite } from '@electric-sql/pglite';
import { readFileSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const raiz = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const pastaMigrations = join(raiz, 'supabase', 'migrations');

const STUB_SUPABASE = `
  create role anon nologin;
  create role authenticated nologin;
  create role service_role nologin bypassrls;

  create schema auth;
  create table auth.users (
    id    uuid primary key default gen_random_uuid(),
    email text
  );
  create function auth.uid() returns uuid language sql stable as $$
    select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
  $$;
  grant usage on schema auth to anon, authenticated, service_role;
  grant execute on function auth.uid() to anon, authenticated, service_role;

  grant usage on schema public to anon, authenticated, service_role;
  alter default privileges in schema public grant all on tables    to anon, authenticated, service_role;
  alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
  alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
`;

export async function criarBanco() {
  const db = new PGlite();
  await db.exec(STUB_SUPABASE);
  const arquivos = readdirSync(pastaMigrations).filter((f) => f.endsWith('.sql')).sort();
  for (const f of arquivos) {
    try {
      await db.exec(readFileSync(join(pastaMigrations, f), 'utf8'));
    } catch (e) {
      throw new Error(`Falha na migration ${f}: ${e.message}`);
    }
  }
  return db;
}

// Executa fn como um usuário (authenticated com sub = uid) ou como anon.
export async function como(db, uid, fn) {
  if (uid) {
    await db.exec(`set role authenticated; select set_config('request.jwt.claim.sub', '${uid}', false);`);
  } else {
    await db.exec(`set role anon; select set_config('request.jwt.claim.sub', '', false);`);
  }
  try {
    return await fn();
  } finally {
    await db.exec(`reset role; select set_config('request.jwt.claim.sub', '', false);`);
  }
}

export async function criarUsuario(db, email) {
  const { rows } = await db.query('insert into auth.users (email) values ($1) returning id', [email]);
  return rows[0].id;
}
