import { Marca } from "@/components/marca";

export const metadata = { title: "Termo de consentimento (LGPD) — Portal Simulado ENADE" };

// RASCUNHO: revisar com o jurídico / encarregado de dados (DPO) da UNIVC antes do lançamento.
export default function TermoLgpdPage() {
  return (
    <main className="mx-auto w-full max-w-2xl px-4 py-10">
      <Marca />
      <article className="mt-8 space-y-4 rounded-xl border bg-background p-6 text-sm leading-relaxed">
        <h2 className="text-lg font-semibold">Termo de consentimento para tratamento de dados pessoais</h2>

        <p>
          Este termo segue a Lei Geral de Proteção de Dados (Lei nº 13.709/2018). Ao aceitá-lo,
          você autoriza o Centro Universitário Vale do Cricaré (UNIVC) a tratar seus dados
          pessoais no Portal Simulado ENADE, conforme descrito abaixo.
        </p>

        <h3 className="font-semibold">1. Dados tratados</h3>
        <ul className="list-disc space-y-1 pl-5">
          <li>E-mail pessoal, usado para login.</li>
          <li>
            CPF e data de nascimento, usados só para confirmar que você é estudante da UNIVC,
            comparando com o cadastro da secretaria acadêmica.
          </li>
          <li>Telefone, para contato da coordenação sobre simulados e o ENADE.</li>
          <li>Nome, matrícula, curso, turma e tipo (concluinte/ingressante), vindos do sistema acadêmico.</li>
          <li>Respostas, tempos de resposta, pontuação, conquistas e datas de acesso.</li>
        </ul>

        <h3 className="font-semibold">2. Para que usamos</h3>
        <ul className="list-disc space-y-1 pl-5">
          <li>Oferecer treino e simulados, com devolutiva e acompanhamento do seu desempenho.</li>
          <li>
            Produzir relatórios para a coordenação e o NDE planejarem ações de preparação para o ENADE.
          </li>
          <li>
            Ranking: se você estiver entre os 10 primeiros de um recorte (geral, curso, turma ou
            Formação Geral), seu <strong>nome</strong> e sua pontuação aparecem para os outros
            estudantes. Fora do top 10, só você vê a sua posição.
          </li>
        </ul>

        <h3 className="font-semibold">3. Compartilhamento</h3>
        <p>
          Os dados não são vendidos nem cedidos a terceiros. São guardados em provedores de
          infraestrutura contratados pela UNIVC (banco de dados, hospedagem e envio de e-mail),
          apenas para o funcionamento do portal.
        </p>

        <h3 className="font-semibold">4. Seus direitos</h3>
        <p>
          Você pode, a qualquer momento, pedir acesso, correção ou eliminação dos seus dados, ou
          revogar este consentimento, falando com a coordenação do seu curso. Se você revogar, seu
          acesso ao portal é encerrado e seu histórico é excluído.
        </p>

        <h3 className="font-semibold">5. Por quanto tempo</h3>
        <p>
          Os dados ficam guardados enquanto houver vínculo acadêmico ativo com a UNIVC. Depois
          disso, são eliminados ou anonimizados para fins estatísticos.
        </p>

        <p className="text-xs text-muted-foreground">Versão 1 — setembro de 2026.</p>
      </article>
    </main>
  );
}
