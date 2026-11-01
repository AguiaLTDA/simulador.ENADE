-- =============================================================================
-- Migration 15 (dados): prova ENADE 2023 de Engenharia Mecânica e de Produção
--
--   * 70 questões oficiais do Inep transcritas dos cadernos de prova: Formação
--     Geral (D1 + 01–09, comum aos dois cursos) e Componente Específico de cada
--     curso (D2 + 10–38). Gabarito definitivo nas objetivas e padrão de resposta
--     oficial nas discursivas. Figuras em public/enade2023/.
--   * Uma atividade avaliativa por curso, aberta até 10/11/2026 23h59 (Brasília),
--     4 horas de prova, valendo 1000 pontos (× nota estimada / 100). Gabarito e
--     padrão de resposta liberados ao aluno quando a atividade encerra.
--   * Idempotente: ids fixos e "on conflict do nothing".
-- =============================================================================

insert into public.questoes
  (id, componente, cursos, eixo, formato, texto_apoio, figura_url, enunciado, figura_alternativas_url,
   alt_a, alt_b, alt_c, alt_d, alt_e, dificuldade, fonte)
values
  ('8bff2eeb-5abe-5d4c-b5a5-339d90429954', 'FG', array['ALL']::public.curso_alvo[], 'Desigualdade e riscos socioambientais', 'DISCURSIVA', 'Na publicação Síntese de Indicadores Sociais, divulgada pelo Instituto Brasileiro de Geografia e Estatística (IBGE) em 2022, é sistematizado um conjunto de informações sobre a realidade social brasileira. Os indicadores ilustram a heterogeneidade da sociedade sob a perspectiva das desigualdades sociais e, de modo geral, demonstram que todas as Grandes Regiões do Brasil registraram aumento da extrema pobreza em 2021. Pelos critérios do Banco Mundial, cerca de 29,4% da população do Brasil estavam em situação de pobreza e 8,4%, de extrema pobreza, sendo esses os maiores percentuais de ambos os grupos desde o início da série, em 2012. O índice de Gini, indicador que permite analisar o nível de igualdade ou desigualdade de uma região ou de um país, teve seu valor elevado e atingiu o segundo maior patamar da série. Com esses resultados, o Brasil permanece entre os países mais desiguais do mundo. Além disso, a urbanização desigual e acelerada resultou na expansão e no agravamento de diversos problemas socioambientais. São evidentes as desigualdades territoriais no acesso a áreas com infraestrutura adequada nas cidades brasileiras. É na periferia, marcada pela estratificação e segregação socioespacial, que se consolida a exclusão da população vulnerabilizada socioeconomicamente.

Disponível em: https://agenciadenoticias.ibge.gov.br/agencia-noticias/2012-agencia-de-noticias/noticias/35687-em-2021-pobreza-tem-aumento-recorde-e-atinge-62-5-milhoes-de-pessoas-maior-nivel-desde-2012. Acesso em: 9 jun. 2023 (adaptado).', null, 'A partir das ideias apresentadas no texto, faça o que se pede nos itens a seguir.

a) Explique a relação entre o perfil da população brasileira atingida pelas desigualdades sociais nas cidades e os fenômenos de risco socioambiental. (valor: 5,0 pontos)
b) Apresente duas propostas que possam ser desenvolvidas em bairros periféricos com condições habitacionais precárias, de forma a serem minimizados os riscos socioambientais, e que envolvam ação governamental e participação da comunidade. (valor: 5,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2023 — Formação Geral, Questão Discursiva 1 (INEP)'),
  ('6f9da5ff-6c67-55ea-ba88-8866175bce87', 'FG', array['ALL']::public.curso_alvo[], 'Fome e segurança alimentar', 'OBJETIVA', 'A fome e a insegurança alimentar, antigos problemas da sociedade, são agravados em regiões com elevados índices de desigualdade social. Propor soluções para esse quadro requer uma abordagem multidimensional, que possibilite a interação entre as dimensões sociais, culturais, políticas, econômicas e ambientais envolvidas na produção e na distribuição de alimentos.', 'enade2023/fg/fg-q01.png', 'Disponível em: https://news.un.org/pt/story/2022/05/1788102. Acesso em: 10 jun. 2023.

Considerando o texto e as imagens apresentados, avalie as asserções a seguir e a relação proposta entre elas.

I. A fome no mundo é um fenômeno biológico e sociológico inevitável.
PORQUE
II. A disponibilidade desigual de alimentos, o acirramento de conflitos geopolíticos, a formação de cadeias agrícolas globais e o aumento das catástrofes climáticas são fatores que impactam a segurança alimentar de um grande número de populações.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 1, 'ENADE 2023 — Formação Geral, Questão 01 (INEP)'),
  ('c49b2776-4f4f-5c29-b613-e875e1dc54e0', 'FG', array['ALL']::public.curso_alvo[], 'Saneamento básico', 'OBJETIVA', 'O crescimento das cidades promove o aumento da demanda por serviços de água tratada, esgotamento sanitário, manejo das águas pluviais, limpeza urbana e coleta de resíduos sólidos. No Brasil, o processo de urbanização ocorreu de forma rápida e desigual, o que resultou no agravamento de injustiças sociais e econômicas. Os serviços de saneamento básico considerados direitos humanos fundamentais não são acessíveis a uma parcela significativa da população, principalmente àquela em que se concentram os segmentos populacionais em situação de vulnerabilidade.

O atendimento integral e universalizado junto às populações periféricas e em situação de vulnerabilidade constitui um grande desafio, por demandar políticas públicas e investimentos subsidiados e permanentes.

Disponível em: https://www.periodicos.unimontes.br/index.php/verdegrande/article/view/6018. Acesso em: 22 jun. 2023 (adaptado).', null, 'Acerca do saneamento básico no Brasil, avalie as afirmações a seguir.

I. A grave desigualdade social, evidenciada pela segregação nos espaços urbanos, é uma das barreiras para a universalização do acesso aos serviços de saneamento básico.
II. O serviço de abastecimento de água no Brasil situa-se no mesmo patamar de fornecimento e de infraestrutura que o sistema de coleta e tratamento do esgoto.
III. A universalização do acesso aos serviços de saneamento básico requer investimentos em políticas públicas e em tecnologias sociais que priorizem a democratização e o atendimento às populações em situação de vulnerabilidade.
IV. O aumento da incidência de doenças transmitidas pela água resulta não somente da inadequação dos serviços de saneamento, mas também da precariedade das condições de moradia da população em situação de vulnerabilidade.

É correto apenas o que se afirma em', null,
   'I e II.', 'I e IV.', 'II e III.', 'I, III e IV.', 'II, III e IV.', 1, 'ENADE 2023 — Formação Geral, Questão 02 (INEP)'),
  ('e4a6cb5e-081c-540b-b0ae-59d8a60aa763', 'FG', array['ALL']::public.curso_alvo[], 'Saúde pública e vacinação', 'OBJETIVA', 'Estudos realizados em 2021 pelo Fundo das Nações Unidas para a Infância (Unicef), em parceria com a Organização Mundial da Saúde (OMS), mostraram que, no Brasil, houve uma queda brusca da taxa de vacinação infantil nos últimos anos: entre 2017 e 2021, a taxa caiu de 93,1% para 71,49%, considerando-se crianças com menos de um ano de idade.

Essa redução da cobertura vacinal deixa a população infantil muito vulnerável e exposta a doenças que já estavam praticamente erradicadas, tal como o sarampo, que em 2018 voltou a ser uma preocupação para os brasileiros. Além do sarampo, corre-se o risco de outras doenças voltarem a acometer as crianças, como a poliomielite, a meningite, a rubéola e a difteria.

O gráfico a seguir mostra as taxas de vacinação infantil, em crianças menores de um ano de idade, no período de 2017 a 2021.', 'enade2023/fg/fg-q03.png', 'Disponível em: https://portal.fiocruz.br/noticia/vacinacao-infantil-sofre-queda-brusca-no-brasil. Acesso em: 23 de jun. 2023 (adaptado).

Considerando as informações apresentadas no texto e no gráfico, assinale a opção correta.', null,
   'O percentual de vacinação com o imunizante da poliomielite se manteve constante na maior parte do período de 2017 a 2021.', 'A baixa cobertura vacinal de crianças menores de um ano de idade é um dos indicadores de baixo desempenho das políticas públicas de atenção primária em saúde.', 'A cobertura vacinal de crianças menores de um ano de idade foi muito variável, com alto índice vacinal da BCG e média cobertura da vacina tetraviral, no período de 2017 a 2021.', 'O aumento da taxa de vacinação infantil contra a febre amarela em 2021, em comparação com o índice registrado em 2017, revela que as campanhas de conscientização da população foram bem-sucedidas quanto ao alcance da meta de vacinação contra essa enfermidade.', 'A pandemia de Covid-19, ao ampliar a conscientização da população sobre a necessidade de manter alto índice vacinal para evitar o reaparecimento de doenças infectocontagiosas, contribuiu para o aumento da cobertura vacinal contra outras doenças, conforme indicado no gráfico.', 2, 'ENADE 2023 — Formação Geral, Questão 03 (INEP)'),
  ('811fe912-0583-5e00-a100-fb0e72d017af', 'FG', array['ALL']::public.curso_alvo[], 'Inteligência artificial e sociedade', 'OBJETIVA', 'TEXTO 1
A Inteligência Artificial (IA) generativa é capaz de criar novos dados, únicos, que possibilitam aprender por conta própria, indo além do que a tecnologia tradicional proporciona, visto que esta precisa de intervenção humana. Um exemplo da IA generativa é o ChatGPT, que pode gerar imagens, músicas e textos completamente novos. Entre outras coisas, por meio da IA generativa, é possível elaborar modelos de previsão de testes clínicos, realizar a identificação de padrões em exames médicos e, ainda, auxiliar no diagnóstico de doenças.

Disponível em: https://olhardigital.com.br/2023/07/12/internet-e-redes-sociais/inteligencia-artificial-generativa-o-que-e-como-funciona-e-onde-usar/. Acesso em: 2 ago. 2023 (adaptado).

TEXTO 2
Acredita-se que a tecnologia de IA generativa será disruptiva e, portanto, capaz de alterar drasticamente a maneira como o ser humano se relaciona com as máquinas. O uso da IA generativa pode causar importante revolução no segmento de produção de conteúdo. Muitas dessas consequências poderão ser maléficas para diversos setores da sociedade. Além do mau uso dessa tecnologia e das questões éticas, avalia-se que ela pode agravar a desigualdade econômico-social, tanto entre nações quanto entre indivíduos da mesma nação.

Disponível em: https://canaltech.com.br/inteligencia-artificial/o-que-e-ia-generativa/. Acesso em: 2 ago. 2023 (adaptado).', null, 'Considerando os textos apresentados, é correto afirmar que a IA generativa', null,
   'proporciona novos recursos de linguagem que geram tecnologias capazes de realizar interações próprias dos seres humanos.', 'restringe o aprendizado ao que é legalmente estabelecido e útil ao ser humano, o que facilita seu modo de agir no mundo do conhecimento e do trabalho.', 'promove a igualdade econômico-social ao substituir o ser humano no exercício de profissões cujas atividades sejam repetitivas e exijam pouco conhecimento.', 'gera pouco impacto socioeconômico em países com elevado desenvolvimento tecnológico, pois, neles, os processos de criação e inovação já estão bem consolidados.', 'estimula o desenvolvimento intelectual dos seres humanos, uma vez que ela assume parte do conhecimento, resolvendo problemas antes delegados apenas a especialistas.', 1, 'ENADE 2023 — Formação Geral, Questão 04 (INEP)'),
  ('6a80053b-5cd1-5421-8202-be7f0d0141dc', 'FG', array['ALL']::public.curso_alvo[], 'Mobilidade urbana e gênero', 'OBJETIVA', 'Os seguintes ícones foram utilizados em um estudo realizado por um grupo de trabalho de monitoramento da relação das mulheres com a mobilidade urbana na cidade de São Paulo. Na pesquisa, perguntou-se às mulheres como elas se sentiam nas situações representadas por tais imagens.

As respostas relativas a cada tipo de mobilidade urbana são apresentadas a seguir.', 'enade2023/fg/fg-q05.png', 'Coletivo Fórum Regional das Mulheres da Zona Norte, Rede MÁS, Sampapé! (2018). Relatório de Análises, Resultados e Recomendações. Projeto Mulheres Caminhantes! Auditoria de Segurança de Gênero e Caminhabilidade Terminal Santana, São Paulo, SP (adaptado).

Considerando o estudo apresentado e relacionando o trabalho de monitoramento social das necessidades de mulheres no contexto urbano aos pressupostos do direito à cidade, avalie as afirmações a seguir.

I. A predominância de comentários negativos indica o medo generalizado que as mulheres sentem ao se deslocarem ativamente pela cidade, inclusive quanto à percepção de seu corpo no espaço urbano.
II. Os comentários negativos sobre os modos coletivos de transporte estão relacionados à lotação nesses meios e a situações de assédio, tendo sido o metrô avaliado como um espaço um pouco mais seguro para as mulheres, em comparação com outras formas de mobilidade.
III. Os comentários negativos refletem a percepção das mulheres quanto ao perigo a que se expõem e sugerem que o medo relacionado à vulnerabilidade de gênero aponta para uma geografia particular nas cidades, em que os meios de transporte afetam os movimentos rotineiros das mulheres no espaço urbano.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2023 — Formação Geral, Questão 05 (INEP)'),
  ('24ae8cea-9385-52dc-8406-d4bdbe36d64f', 'FG', array['ALL']::public.curso_alvo[], 'Identidade cultural e memória', 'OBJETIVA', 'TEXTO 1
Maria Bárbara tinha o verdadeiro tipo das velhas maranhenses criadas na fazenda. Tratava muito dos avós, quase todos portugueses. Quando falava dos pretos, dizia “os sujos” e, quando se referia a um mulato dizia “o cabra”. Maria Bárbara tinha grande admiração pelos portugueses, dedicava-lhes um entusiasmo sem limites, preferia-os em tudo aos brasileiros. Quando a filha foi pedida por Manuel Pedroso, então principiante no comércio da capital, ela dissera: “Bem! Ao menos tenho a certeza de que é branco!”

AZEVEDO, A. O mulato. São Luís: Typografia o Paiz, 1881 (adaptado).

TEXTO 2
A morte brinca com balas nos dedos gatilhos dos meninos. Dorvi se lembrou do combinado, o juramento feito em voz uníssona, gritado sob o pipocar dos tiros:

— A gente combinamos de não morrer!

Balas enfeitam o coração da noite. Não gosto de filmes da tevê. Morre e mata de mentira. Aqui, não. Às vezes a morte é leve como a poeira. E a vida se confunde com um pó branco qualquer. Às vezes é uma fumaça adocicada enchendo o pulmão da gente.

EVARISTO, C. Olhos d´agua. Rio de Janeiro: Pallas. Fundação Biblioteca Nacional, 2016 (adaptado).

TEXTO 3', 'enade2023/fg/fg-q06.png', 'DEL NUNES. O Cria. Disponível em: https://www.instagram.com/p/CgCSOKegX4J/. Acesso em: 13 jun. 2023.

O Cria é uma releitura da pintura “O Mestiço” de Cândido Portinari. Em sua obra, Del Nunes personifica a identidade do jovem brasileiro das periferias do Brasil. Oriundo de São Cristóvão, bairro periférico de Salvador, o artista transmite em suas produções a essência da cultura preta, cria e recria momentos do povo negro apagados pela história, divulgando-as nas redes sociais.

A partir das informações apresentadas e tendo em vista a possibilidade das várias manifestações culturais estabelecerem relação com a construção da memória e a definição da identidade cultural de um povo, avalie as afirmações a seguir.

I. Os trechos das obras apresentadas nos textos 1 e 2 e a ressignificação artística proposta no texto 3 resgatam uma reflexão acerca da condição histórica da maioria da população brasileira.
II. Ao longo do processo histórico de constituição da identidade do povo brasileiro, o convívio cooperativo e cordial entre as diferentes culturas contribuiu para a integração e o respeito às diferenças étnicas e religiosas.
III. A produção de conteúdo artístico que proponha a reflexão sobre a condição social da população negra provoca a quebra do silenciamento imposto pelo processo de segregação historicamente promovido pelo processo de colonização.
IV. A arte expressa no texto 3, ao imitar uma obra clássica de Portinari, apresenta limitação na promoção do empoderamento da população afrodescendente, provocando um acirramento cultural.

É correto apenas o que se afirma em', null,
   'II.', 'IV.', 'I e III.', 'I e IV.', 'II e III.', 2, 'ENADE 2023 — Formação Geral, Questão 06 (INEP)'),
  ('6ae5c152-c2b5-5321-bac5-0095d644e9e0', 'FG', array['ALL']::public.curso_alvo[], 'Envelhecimento e trabalho', 'OBJETIVA', 'No Brasil, os idosos têm sido cada vez mais obrigados a permanecer no trabalho formal ou informal, mesmo após a aposentadoria, visto que os recursos provenientes desta, na maioria dos casos, são insuficientes para a manutenção dos indivíduos. Um fator que pode ter agravado essa situação foi a aprovação da reforma previdenciária de 2019, que modificou as regras de idade e contribuição para o acesso ao direito ao benefício da aposentadoria. Tal mudança pode ter resultado em um número ainda maior de idosos que disputam com as populações jovens e com sistemas de automação, no mercado atual, o trabalho precarizado. Essa situação contribui para o acirramento do preconceito contra essa faixa etária, denominado etarismo.', null, 'Considerando o texto apresentado, avalie as afirmações a seguir.

I. O conceito de etarismo fundamenta-se no fato de os idosos terem capacidade de trabalho reduzida e imporem custo elevado à previdência social, o que compromete a sua sustentabilidade econômica.
II. As ações legislativas que visem ao prolongamento do tempo de atuação da população idosa no mercado de trabalho devem ser acompanhadas por uma política de promoção da saúde e da qualidade de vida.
III. As ações intergeracionais no mercado de trabalho têm como premissa o desenvolvimento de tecnologias que dotem o idoso de capacidade de trabalho equivalente à de seus colegas jovens.

É correto o que se afirma em', null,
   'II, apenas.', 'III, apenas.', 'I e II, apenas.', 'I e III, apenas.', 'I, II e III.', 1, 'ENADE 2023 — Formação Geral, Questão 07 (INEP)'),
  ('6b1e3f3a-f327-5004-8972-f94b753c203d', 'FG', array['ALL']::public.curso_alvo[], 'Encarceramento feminino', 'OBJETIVA', 'Recentemente, a população carcerária feminina do Brasil tornou-se a terceira maior do mundo. A situação do encarceramento feminino por tráfico de drogas e outras situações que circundam o assunto foi tema de discussão da Secretaria de Políticas sobre Drogas do Ministério da Justiça e Segurança Pública (Senad/MJSP), em seminário realizado em abril de 2023. O evento contou com a participação de 23 países. Segundo os dados apresentados pela Senad, a incidência penal sobre drogas no Brasil é uma das principais causas de prisão de mulheres, chegando a 54% dos casos de encarceramento, contra 28% dos homens, índice que impacta em aspectos como maternidade e primeira infância.

Disponível em: https://www.gov.br/mj/pt-br/assuntos/noticias/senad-discute-situacao-de-mulheres-encarceradas-no-contexto-de-drogas-no-brasil. Acesso em: 15 jun. 2023 (adaptado).', null, 'Acerca do tema apresentado, avalie as asserções a seguir e a relação proposta entre elas.

I. A maioria das mulheres envolvidas em atividades do tráfico encontra-se em posições hierarquicamente inferiores, sendo classificadas como “mulas e aviões”, o que revela a reprodução, no mercado ilegal, da divisão sexual do trabalho observada no mercado formal.
PORQUE
II. O sistema penal agrava a situação de vulnerabilidade das mulheres encarceradas, seja pela invisibilização com que as trata, seja por meio da violência institucional que reproduz a violência estrutural das relações sociais patriarcais.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 2, 'ENADE 2023 — Formação Geral, Questão 08 (INEP)'),
  ('55381946-8cf3-5e78-802a-8568cee4f932', 'FG', array['ALL']::public.curso_alvo[], 'Tecnologia e saúde mental', 'OBJETIVA', 'A sociedade do século XXI não é mais uma sociedade disciplinar, mas, sim, uma sociedade do desempenho. Os seus habitantes também não se chamam mais sujeitos de obediência, mas, sim, sujeitos de desempenho e produção. São empresários de si mesmos.

BYUNG-CHUL HAN. Sociedade do Cansaço. Petrópolis: Vozes, 2015 (adaptado).', null, 'Considerando o texto apresentado, avalie as afirmações a seguir.

I. Os recursos tecnológicos, como notificações de mensagens em tempo real e controle da velocidade de áudio em redes de mensagens, são fatores que podem contribuir para a precarização das relações de trabalho na sociedade contemporânea.
II. As medidas pessoais de proteção à saúde mental e de promoção da qualidade de vida incluem a desativação de aplicativos e mecanismos de notificações instantâneas, bem como a fixação de horários para uso profissional e uso recreativo das tecnologias digitais.
III. As medidas públicas de prevenção das doenças e dos danos sociais associados ao uso excessivo dos recursos tecnológicos de comunicação envolvem estímulos ao letramento digital, à alfabetização midiática e à regulamentação do uso de plataformas digitais no ambiente de trabalho.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 1, 'ENADE 2023 — Formação Geral, Questão 09 (INEP)'),
  ('459f1ab8-a3d0-5c53-9cdf-d6203bf45abb', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Elementos de máquinas — eixos', 'DISCURSIVA', 'Nos projetos mecânicos, principalmente em sistemas de transmissão, é necessário que sejam conhecidas as tensões atuantes, para que elas não ultrapassem os valores das tensões admissíveis e para que o dimensionamento seja adequado, o que minimiza os custos de produção. A esse respeito, a figura a seguir mostra um sistema de transmissão com forças de 3 kN nas engrenagens localizadas em B e C. Considere os raios das engrenagens em B e C iguais a 50 mm.', 'enade2023/mec/mec-d2.png', 'HIBBELLER, R. C. Resistência dos Materiais. São Paulo: Pearson, 2009 (adaptado).

Com base nas informações apresentadas, faça o que se pede nos itens a seguir.

a) Determine o módulo do torque presente no sistema entre os pontos AB, BC e CD. (valor: 4,0 pontos)
b) Determine as componentes das reações nos apoios A e D. (valor: 6,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2023 — Engenharia Mecânica, Questão Discursiva 2 (INEP)'),
  ('4e831f17-cb21-56e8-84f7-66fdaf43dce2', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Processos de usinagem', 'OBJETIVA', 'A figura a seguir representa um dos tipos mais comuns de furo, o furo cego.', 'enade2023/mec/mec-q10.png', 'Na situação representada na figura, tem-se disponível uma broca helicoidal de aço rápido para usinar o furo com diâmetro Ø = 8 mm e profundidade A = 25 mm num aço de baixo carbono. Para essa situação, a velocidade de corte apropriada é de 35 m/min e o avanço é de 0,18 mm/rotação.

Considerando a situação apresentada, avalie as afirmações a seguir.

I. Utilizando-se a broca de 8 mm de diâmetro, desconsiderando a ponta da broca para efeito de deslocamento da ferramenta e com avanço automático, o tempo principal de corte será menor que 10 s.
II. O risco de ocorrer excentricidade no formato do furo é desconsiderado, pois é pequeno o diâmetro da broca utilizada na usinagem da peça.
III. No projeto da peça, o furo em questão é considerado de alta precisão, de forma que, após sua furação, haverá a operação de acabamento.

É correto o que se afirma em', null,
   'II, apenas.', 'III, apenas.', 'I e II, apenas.', 'I e III, apenas.', 'I, II e III.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 10 (INEP)'),
  ('11cc2853-ffc0-5bd9-90e9-c54084ce353b', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Tratamentos térmicos', 'OBJETIVA', 'Suponha que uma indústria metalomecânica queira produzir peças com característica de resistência ao desgaste. A empresa tem experiência na fabricação de peças a partir de dois tipos de materiais para a produção do mesmo tipo de componente, conforme descrito a seguir.

Material A — Aço com alto teor de carbono
Material B — Aço com baixo teor de carbono

Considere que a rota comum de fabricação para componentes com essa exigência de resistência ao desgaste envolve a usinagem, seguida de tratamento térmico, e que essa empresa possui equipamentos e competência para realizar diferentes operações de tratamento térmico para essa demanda.', null, 'A partir das informações apresentadas, assinale a opção correta.', null,
   'Se o componente for fabricado com o material A, este deve ser aquecido por tempos prolongados de exposição a temperaturas ligeiramente subcríticas, visando-se produzir cementita esferoidal em uma matriz de ferrita e eliminando-se a presença de perlita.', 'Se o componente for fabricado com o material A, este deve ser aquecido abaixo da zona crítica, seguido-se o resfriamento prolongado e, após esses procedimentos, deve ser realizado um revenido, para alívio de tensões internas.', 'Se o componente for fabricado com o material B, este deve ser aquecido acima da temperatura crítica, acrescentando-se carbono em sua superfície, por certo período de tempo.', 'Se o componente for fabricado com qualquer um dos materiais, A ou B, estes devem ser aquecidos acima da zona crítica e, em seguida devem ser retirados do forno e resfriados ao ar natural.', 'Se o componente for fabricado com o material B, deve ser aplicado um recozimento, com o objetivo de aumentar a dureza do material e a resistência ao desgaste.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 11 (INEP)'),
  ('9a26a19c-bd64-569d-8430-e790e8784443', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Máquinas de fluxo — bombas', 'OBJETIVA', 'Considere que, para abastecer uma cidade de 360 000 habitantes, será construída uma nova estação de tratamento de água (ETA), com vazão total de 3 600 m³/h. O engenheiro responsável pelo projeto da ETA calculou que a bomba hidráulica do tipo centrífuga, responsável pelo processo de filtragem, deve vencer a altura estática de 3 m, a perda de carga deve ser de 42 m e o peso específico da água igual a 10 kN/m³. A bomba escolhida tem modernas características construtivas e, de acordo com informações técnicas obtidas no manual do fabricante, há a garantia de que o conjunto moto-bomba apresenta rendimento global de 50%.', null, 'Considerando a situação apresentada, conclui-se que a potência do motor elétrico que acionará a bomba hidráulica da referida ETA corresponde a', null,
   '30 kW.', '60 kW.', '450 kW.', '840 kW.', '900 kW.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 12 (INEP)'),
  ('ff743ed5-5684-5f89-8698-2ef67dbd33d8', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Mecânica dos fluidos — semelhança', 'OBJETIVA', 'Uma empresa foi contratada para obter, experimentalmente, a força de arrasto em uma partícula metálica esférica com diâmetro de 1 mm quando submetida a escoamento de ar a 75 m/s. Diante das dificuldades de se trabalhar com um protótipo de pequenas dimensões, a equipe de engenheiros propôs a construção de um modelo em escala 200 vezes maior, o qual será testado em glicerina. Considere que as viscosidades cinemáticas do ar e da glicerina correspondam, respectivamente, a 1,5x10⁻⁵ m²/s e 1,2x10⁻³ m²/s.', null, 'Dado que existe relação de semelhança entre o modelo e o protótipo, a velocidade de escoamento da glicerina, no referido experimento, deve ser de', null,
   '35 m/s.', '30 m/s.', '25 m/s.', '20 m/s.', '15 m/s.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 13 (INEP)'),
  ('c1976d2d-fc17-5ce1-8685-54ce2940a2ba', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Transferência de calor — isolamento', 'OBJETIVA', 'Suponha que um engenheiro tenha analisado o isolamento de um tubo fino que evita a condensação do fluido refrigerante conduzido. Usando um paquímetro, ele verificou que o tubo tem 0,54 cm de raio externo, mas esse raio chega a 0,6 cm com o isolamento de lã de vidro.

Considerou-se que a condutividade térmica da lã de vidro é de 0,038 W/(m °C) e, após consulta na literatura, o engenheiro observou que o raio crítico de isolamento é dado por

r_crit = k/h

em que k é a condutividade térmica, e h = 7,0 W/(m² °C) é o coeficiente de transferência de calor por convecção.

O engenheiro analisou também, como material alternativo, o isolamento de silicato de sódio, cuja condutividade térmica é de 0,055 W/(m °C).', null, 'Com base nas análises realizadas, o engenheiro concluiu corretamente que', null,
   'a lã de vidro e o silicato de sódio têm o mesmo fluxo de calor.', 'a lã de vidro tem melhor isolamento com o aumento do raio do isolante.', 'a lã de vidro tem menor fluxo de calor com a redução do raio do isolante.', 'o silicato de sódio tem melhor isolamento com o aumento do raio do isolante.', 'o silicato de sódio tem menor fluxo de calor com o aumento do raio do isolante.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 14 (INEP)'),
  ('32185f3e-24b3-5483-9295-981843b14aa6', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Transferência de calor — convecção', 'OBJETIVA', 'Suponha que um sistema de condicionamento de ar é utilizado para manter a temperatura interna de um quarto a 23 °C no verão. Após serem realizadas diversas medidas da temperatura superficial interna de uma parede do quarto, com 5 m de comprimento e 4 m de altura, foi obtido o valor médio de 27 °C.', null, 'Considerando-se os dados apresentados e que o coeficiente de transferência de calor por convecção no interior do quarto corresponde a 5 W/(m² °C), desprezados os efeitos da radiação nesse ambiente, verifica-se que a taxa de transferência de calor que passa pela referida parede é de', null,
   '20 W.', '100 W.', '180 W.', '360 W.', '400 W.', 1, 'ENADE 2023 — Engenharia Mecânica, Questão 15 (INEP)'),
  ('fb4667b8-f596-5c44-956a-c91119c73c32', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Termodinâmica — ciclo Rankine', 'OBJETIVA', 'Conforme a bibliografia de sistemas de geração de potência a vapor, que inclui a norma API-611, a qual trata de turbinas a vapor, ciclos de geração de potência a vapor requerem um título no interior de qualquer parte da turbina acima de 90%, de forma a serem evitados ou minimizados problemas com a erosão das pás.

O diagrama T × s, apresentado a seguir, mostra um ciclo Rankine Irreversível, com vapor saturado na entrada da turbina, tendo a saída um título perto da faixa crítica.', 'enade2023/mec/mec-q16.png', 'MORAN, M. J.; SHAPIRO, H. N. Princípios de Termodinâmica para Engenharia. Rio de Janeiro: editora LTC, 2013 (adaptado).

Considere a intenção de se aumentar a eficiência desse ciclo mudando parâmetros, como pressão da caldeira, pressão do condensador, condições na entrada da turbina e/ou condições na entrada da bomba.

Acerca da situação apresentada, assinale a opção que indica a melhor ação para se alcançar o aumento de eficiência desejado, sem reduzir-se o título na saída da turbina.', null,
   'Aumentar a temperatura do vapor na saída da turbina, sem modificar a pressão da caldeira.', 'Superaquecer o vapor na caldeira, sem modificar a pressão na caldeira e no condensador.', 'Apenas reduzir a pressão no condensador, sem modificar a pressão do vapor saturado na saída da caldeira.', 'Apenas aumentar a pressão do vapor saturado na saída da caldeira, sem modificar a pressão no condensador.', 'Subresfriar o líquido na entrada da bomba, mantendo a pressão do vapor saturado na saída da caldeira inalterada.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 16 (INEP)'),
  ('422c073a-c6a3-5449-8fee-99c61ee459b7', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Controle e dinâmica de sistemas', 'OBJETIVA', 'Considere que um reservatório cilíndrico armazena água à pressão e à temperatura ambientes. A área da base do reservatório é de 0,5 m², e seu nível máximo corresponde a 2 m. No instante inicial, o nível da água no interior do reservatório é de 1 m. Após 10 s, o reservatório passa a ser abastecido com a vazão de 5 L/s de água.', null, 'Considerando essas condições, assinale a opção em que está representado o comportamento dinâmico do nível a ser medido por um sensor.', 'enade2023/mec/mec-q17-alt.png',
   'Opção A — ver figura das alternativas', 'Opção B — ver figura das alternativas', 'Opção C — ver figura das alternativas', 'Opção D — ver figura das alternativas', 'Opção E — ver figura das alternativas', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 17 (INEP)'),
  ('3980c105-0cfc-5ac9-8553-824f707f75d5', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Transferência de calor — diferenças finitas', 'OBJETIVA', 'Suponha que uma placa plana retangular esteja sujeita à condução de calor bidimensional em regime permanente, imposta pelas condições de contorno em suas extremidades. Suponha, ainda, que a placa foi dividida em seis elementos quadrados, sendo identificados 12 nós, conforme apresentado na figura a seguir.', 'enade2023/mec/mec-q18.png', 'CENGEL, Y. A.; GHAJAR, A. J. Transferência de calor e massa: uma abordagem prática. 4. ed. Porto Alegre: AMGH, 2012 (adaptado).

Considerando que o material possa ser modelado como isotrópico, verifica-se que a equação que representa a temperatura do nó 7, obtida com base na equação de diferenças finitas, é', null,
   'T₇ = (T₁ + T₃ + T₉ + T₁₁)/4', 'T₇ = (T₂ + T₅ + T₇ + T₁₀)/4', 'T₇ = (T₃ + T₆ + T₈ + T₁₁)/4', 'T₇ = (T₁ + T₃ + T₈ + T₁₁)/2', 'T₇ = (T₂ + T₄ + T₈ + T₁₀)/2', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 18 (INEP)'),
  ('35090056-f2ee-5c93-8f95-ccea22d75309', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Segurança do trabalho — NR15', 'OBJETIVA', 'O termo insalubridade tem o seguinte significado: o que é nocivo ou prejudicial à saúde. Um ambiente insalubre é composto por agentes (substâncias ou condições) que podem causar dano ao colaborador. Com base nessas características, a Consolidação das Leis Trabalhistas (CLT) preconiza que as atividades são insalubres quando levam à exposição do colaborador a um nível acima do limite tolerável, predefinidos por normas, conforme sua natureza, intensidade e tempo de exposição. Os parâmetros de insalubridade são definidos pela NR15, em que são apresentadas as disposições gerais acerca das atividades de insalubridade, de acordo com os agentes presentes, sendo eles o químico, o físico, o biológico ou alguma condição adversa.

Disponível em: https://www.gov.br/trabalho-e-emprego/pt-br/acesso-a-informacao/participacao-social/conselhos-e-orgaos-colegiados/comissao-tripartite-partitaria-permanente/arquivos/normas-regulamentadoras/nr-15-atualizada-2022.pdf. Acesso em: 8 ago. 2023 (adaptado).', null, 'Com base no que é preconizado na NR15, assinale a opção correta.', null,
   'O pagamento do adicional de insalubridade está atrelado a uma condição em que o ambiente não apresentará mais risco.', 'A insalubridade é identificada por meio de avaliação do ambiente, a qual deve ser realizada por um profissional qualificado, com formação em segurança do trabalho e, portanto, habilitado a identificar os riscos do ambiente de atuação dos colaboradores.', 'O adicional de insalubridade ou periculosidade é um direito adquirido e só deve cessar quando o colaborador fizer uso de equipamentos de proteção individuais apropriados às atividades exercidas ao longo da sua jornada de trabalho.', 'O valor acrescido ao salário do colaborador, no caso de ser identificado mais de um fator de insalubridade, corresponderá à média dos valores percentuais que forem determinados pela norma, de acordo com os parâmetros elegíveis.', 'Ao se analisar a insalubridade de um ambiente, deve-e proceder à consulta ao colaborador que esteja atuando na condição de risco e, com base na sua experiência, determinar o grau de risco a que ele está exposto, devendo-se, em seguida, informar o profissional superior para que providências possam ser tomadas em prol da saúde da equipe de trabalho.', 1, 'ENADE 2023 — Engenharia Mecânica, Questão 19 (INEP)'),
  ('4aaf32b8-515e-56a1-aecb-9d4f13369a7e', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Resistência dos materiais — círculo de Mohr', 'OBJETIVA', 'Para serem evitadas falhas estruturais em dimensionamento de máquinas e estruturas, é necessária a análise dos elementos de tensões mais críticas. Para a análise das tensões principais e de cisalhamento, um método simples para os cálculos é a utilização do círculo de Mohr, apresentado na figura a seguir.', 'enade2023/mec/mec-q20.png', 'BEER, F. P. Resistência dos Materiais. São Paulo: Makron Books, 1995 (adaptado).

Sabendo-se que a tensão normal máxima é de 80 MPa, os valores dos módulos de τ_xy e da tensão de cisalhamento máxima serão, respectivamente, iguais a', null,
   '40 MPa e 50 MPa.', '40 MPa e 100MPa.', '50 MPa e 50 MPa.', '50 MPa e 100 MPa.', '100 MPa e 50 MPa.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 20 (INEP)'),
  ('f3e87768-36c1-5590-80e2-72452949df43', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Resistência dos materiais — flexão', 'OBJETIVA', 'A flexão ocorre na grande maioria das estruturas e máquinas existentes, sendo que a demanda da sociedade em projetar equipamentos com menor custo e segurança faz com que o projetista analise todos os elementos estruturais, garantindo que os pontos mais críticos da seção mais crítica sejam avaliados. Para isso, é necessário o conhecimento dos esforços internos das estruturas, os quais, no caso de estruturas planas, são momento fletor, força cortante e força normal axial.

A figura a seguir representa um elemento de máquina sujeito à aplicação de momentos em dois pontos específicos.', 'enade2023/mec/mec-q21.png', 'GERE, J. M. Mecânica dos Materiais, 5. ed. São Paulo: Cengage Learning, 2013 (adaptado).

Considerando as informações apresentadas, avalie as afirmações a seguir.

I. A soma das reações em A e B são nulas.
II. A reação em B tem módulo de 3M₁/L.
III. O momento fletor máximo tem módulo 3M₁.
IV. A força cortante máxima tem módulo (3/2)M₁/L.

É correto apenas o que se afirma em', null,
   'I e II.', 'I e IV.', 'II e III.', 'I, III e IV.', 'II, III e IV.', 3, 'ENADE 2023 — Engenharia Mecânica, Questão 21 (INEP)'),
  ('acac1a2e-3779-5158-a660-251033cb72a0', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Estática — mecanismos', 'OBJETIVA', 'Considere que um momento M de intensidade 180 kN cm seja aplicado na manivela do motor mostrado na figura a seguir. Na posição mostrada, a força F é necessária para manter o sistema em equilíbrio.', 'enade2023/mec/mec-q22.png', 'Com base nos dados apresentados, verifica-se que, para a determinação dos esforços de projeto atuantes no pistão e considerando-se os pesos desprezíveis, o valor da força F é igual a', null,
   '30 kN.', '45 kN.', '60 kN.', '90 kN.', '105 kN.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 22 (INEP)'),
  ('953ef6f5-e297-53ea-829b-6a8e3b42781e', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Elementos de máquinas — transmissões', 'OBJETIVA', 'Suponha que uma indústria de manufatura tenha encomendado um projeto de uma esteira de transporte para alimentação nas células de produção. Durante a implantação, foram analisados dispositivos que, controlados eletronicamente, utilizam servo-motores e sistemas mecânicos com velocidade constante. Utilizando como critério de seleção o custo, a diretoria optou por sistemas mecânicos desenvolvidos pelo departamento de engenharia da própria empresa.

A figura a seguir representa o dispositivo mecânico de tração de uma esteira, o qual é composto por um motor elétrico, uma caixa de transmissão por engrenagens e uma transmissão por polias e correia, que é, então, acoplada ao cilindro de tração da esteira. As polias apresentam relação de diâmetros d₂/d₁ = 5 e o motor acoplado à caixa de redução tem potência nominal de 2 cv e opera com rotação fixa de 880 rpm.', 'enade2023/mec/mec-q23.png', 'Considerando que, ao utilizar um tacômetro, o engenheiro verificou que a rotação no eixo de tração da esteira é de 44 rpm, conclui-se que a relação de transmissão da caixa de transmissão por engrenagens é igual a', null,
   '20:1.', '19,8:1.', '9:1.', '5:1.', '4:1.', 1, 'ENADE 2023 — Engenharia Mecânica, Questão 23 (INEP)'),
  ('d4bc0e1a-6c46-50b1-be98-8c67aeb4fd08', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Dinâmica do corpo rígido', 'OBJETIVA', 'Nos projetos de máquinas, os conceitos de dinâmica do corpo rígido são fundamentais para o desenvolvimento de modelos matemáticos, evitando-se a construção de protótipos e, consequentemente, minimizando-se custos.

A figura a seguir representa um disco com um cordão enrolado em torno de seu centro geométrico, simulando o comportamento de um ioiô. O disco tem massa M, raio R e momento de inércia em relação ao centro de massa igual a I = MR²/2. Considere M = 0,2 kg, R = 10 cm e aceleração da gravidade g = 10 m/s².', 'enade2023/mec/mec-q24.png', 'Nessa situação, se o disco é solto a partir do repouso, o valor da velocidade após 9 segundos é', null,
   '4 m/s.', '6 m/s.', '40 m/s.', '60 m/s.', '600 m/s.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 24 (INEP)'),
  ('c354653a-966a-53a7-9bad-0497f5d3f41d', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Vibrações mecânicas', 'OBJETIVA', 'Considere que um mecanismo do tipo Scotch Yoke tenha sido utilizado em uma mesa de vibração em um processo industrial e que ensaios experimentais determinaram o gráfico do deslocamento do êmbolo do mencionado mecanismo, conforme mostra a figura a seguir.', 'enade2023/mec/mec-q25.png', 'Considerando o gráfico desse mecanismo, avalie as afirmações a seguir.

I. O tempo para que o movimento se repita, a partir do repouso, é de 4π segundos.
II. O máximo valor atingido pelo êmbolo, ou seja, sua amplitude, é de 8,0 mm.
III. A frequência desse sistema é dada por f = 1/(2π) Hz.
IV. A frequência angular do êmbolo é de 1 rad/s.

É correto o que se afirma em', null,
   'I e II, apenas.', 'I e IV, apenas.', 'II e III, apenas.', 'III e IV, apenas.', 'I, II, III e IV.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 25 (INEP)'),
  ('37ed1fb2-8202-52fe-b896-b548a4a0aebd', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Gestão da manutenção', 'OBJETIVA', 'Um novo tipo de indústria está nascendo devido à “quarta revolução industrial”, o que facilita os processos e as demandas referentes ao setor de manutenção e às atribuições que lhe competem, visto que se favorecem o controle e os acessos remotos, os processos automatizados e os seus dispositivos. Um Planejamento e Controle da Manutenção (PCM) deverá levar a uma configuração por meio da qual se busca a excelência diante dos desafios apresentados, favorecendo-se uma melhor qualidade no processo e na interação entre os setores.

SILVA, D. S.; LIMA, E. V. O Planejamento e Controle da Manutenção na Indústria 4.0. IX Congresso Brasileiro de Engenharia de Produção. Ponta Grossa, PR, Brasil, 04 a 06 de dezembro de 2019 (adaptado).

Visando à competitividade mais eficiente e a um processo operacional de melhor qualidade, as organizações têm recorrido à manutenção de forma estratégica, dada sua importância vital para a relação direta entre eficiência e melhoria de gestão.', null, 'Considerando as informações apresentadas, assinale a opção correta.', null,
   'A manutenção não programada prevê que todas as tarefas sejam realizadas conforme o limitador de tempo estabelecido de forma prévia.', 'A manutenção corretiva é planejada de forma programada para que se possa realizar o reparo quando houver falha durante um processo.', 'A manutenção efetiva ocorre de acordo com a manutenção realizada, não se levando em conta o tempo de execução em cada uma das etapas.', 'A elaboração de um plano de manutenção deverá ser realizada pelo gerente da empresa, visto que ele conhece os colaboradores envolvidos e o ambiente de trabalho em questão.', 'A manutenção preditiva garante um processo qualificado em sua execução, baseado na supervisão centralizada e na aplicação de sistematização das técnicas de acompanhamento, reduzindo, assim, a necessidade de manutenção corretiva.', 1, 'ENADE 2023 — Engenharia Mecânica, Questão 26 (INEP)'),
  ('1ff075ac-06af-5eb9-8d96-9aca53d1b0f8', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Tolerâncias e ajustes', 'OBJETIVA', 'Tolerâncias dimensionais são desvios aceitáveis das dimensões nominais e destinam-se a limitar os erros dimensionais na fabricação de peças. A figura a seguir apresenta o desenho de um conjunto com peças montadas com as representações das cotas, tolerâncias e do ajuste adequado.', 'enade2023/mec/mec-q27.png', 'Com base nas informações apresentadas, assinale a opção correta.', null,
   'A tolerância da peça hachurada é igual a 0,030 mm.', 'A interferência mínima verificada no conjunto é 0,002 mm.', 'O ajuste da figura é descrito como a situação em que a dimensão mínima do furo é maior que a dimensão máxima do eixo.', 'A peça hachurada pode ter a dimensão verificada no controle de qualidade da produção por um calibrador tampão passa/não passa adequado.', 'A dimensão real da peça com furo do conjunto representado na figura é igual a 60,15 mm e, portanto, o referido furo está dentro das dimensões da tolerância estipulada.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 27 (INEP)'),
  ('87e785a5-5417-56d4-a730-c96dd5f1f6a3', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Corrosão e eletroquímica', 'OBJETIVA', 'A galvanização é uma operação de revestimento, obtida por imersão de uma peça de aço em um banho de zinco, por um determinado período de tempo, em que o aço é trazido até a temperatura do banho. Ao ser alcançada essa temperatura, ou próximo dela, forma-se uma camada aderente de liga de zinco-ferro na superfície do aço e outra de zinco puro. Ambas as camadas contribuem para a capacidade de resistência à corrosão e para a vida útil do revestimento aplicado.

GENTIL, V. Corrosão. 7.ed. Rio de Janeiro: LTC, 2022 (adaptado).', null, 'A respeito desse tema, e considerando Fe²⁺/Fe = - 0,44 V, conclui-se que o metal a ser reduzido na aplicação da galvanização do ferro corresponde a', null,
   'Ni²⁺(aq) + 2e⁻ → Ni(s) E⁰ = - 0,25 V.', 'Cd²⁺(aq) + 2e⁻ → Cd(s) E⁰ = - 0,40 V.', 'Zn²⁺(aq) + 2e⁻ → Zn(s) E⁰ = - 0,76 V.', 'Pb²⁺(aq) + 2e⁻ → Pb(s) E⁰ = - 0,13 V.', 'Cu²⁺(aq) + 2e⁻ → Cu(s) E⁰ = - 0,34 V.', 1, 'ENADE 2023 — Engenharia Mecânica, Questão 28 (INEP)'),
  ('da94ae46-a25f-5078-a918-d787f83a805b', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Materiais compósitos', 'OBJETIVA', 'Atualmente, as bicicletas utilizadas no ciclismo devem ser extremamente leves, para propiciarem melhor desempenho e menor desgaste ao atleta. Nesse sentido, para atender às necessidades dos atletas, diversos materiais foram desenvolvidos em substituição aos materiais metálicos tradicionais (aço e alumínio).', null, 'Considerando que, entre os materiais desenvolvidos para o ciclismo, incluem-se os materiais compósitos, avalie as afirmações a seguir.

I. Os materiais compósitos com fibras de carbono são extremamente leves e resistentes, o que permite a redução do peso da bicicleta e do desgaste sofrido pelo atleta.
II. Os materiais compósitos com fibras de carbono apresentam baixa densidade, uma vez que são constituídos por fibras de carbono e resina, que são materiais poliméricos.
III. Os materiais compósitos com fibras de carbono permitem que as fibras de carbono sejam posicionadas em determinada direção na matriz de resina, o que promove o aumento da resistência mecânica, e a resina, menos resistente, distribui os carregamentos sofridos para as fibras.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 1, 'ENADE 2023 — Engenharia Mecânica, Questão 29 (INEP)'),
  ('0bd58fe6-931f-55ed-ac91-8cfba186c0b8', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Refrigeração e bombas de calor', 'OBJETIVA', 'Considere que uma construtora tenha solicitado um projeto de piscina aquecida que apresente ótima eficiência energética, seja ecologicamente correto e economicamente viável. Para atender essas exigências, foi utilizada uma bomba de calor com COP = 4, fornecendo uma taxa de calor de 4 kW para a água da piscina, e cujo compressor consome uma potência de 1 kW, conforme apresentado na figura a seguir.', 'enade2023/mec/mec-q30.png', 'MORAN, M. J.; SHAPIRO, H. N. Princípios de Termodinâmica para Engenharia. Rio de Janeiro: editora LTC, 2018 (adaptado).

Considerando que, depois de um determinado tempo, a demanda de aquecimento da piscina passou a ser de 6 kW e que é necessário satisfazer essa nova demanda, avalie as afirmações a seguir.

I. O calor extraído do ar exterior deve ter um aumento de 2 kW.
II. A bomba de calor de COP = 4 deve ser substituída por uma de COP = 6.
III. O consumo do compressor deve ter aumento de 2 kW.

É correto o que se afirma em', null,
   'II, apenas.', 'III, apenas.', 'I e II, apenas.', 'I e III, apenas.', 'I, II e III.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 30 (INEP)'),
  ('9e6339da-b404-59bb-8713-fcbc402c9458', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Processos de conformação', 'OBJETIVA', 'O processo de fabricação por laminação é importante para a fabricação de inúmeros componentes, como, por exemplo, terminais elétricos. Tais componentes são fabricados a partir de chapas laminadas de cobre, que partem de tarugos (espessura de 500 mm) provenientes do processo de lingotamento contínuo. Inicialmente, sofrem processos de laminação a quente e, posteriormente, laminação a frio, até ser atingida a espessura necessária (1,2 mm). Os terminais apresentam encruamento e excelente acabamento superficial, resultantes de processos subsequentes de corte e dobramento.', null, 'Com base nas informações apresentadas, avalie as afirmações a seguir.

I. A laminação a frio promove melhor acabamento do produto, garantindo um bom controle dimensional e boa resistência mecânica, resultantes do encruamento.
II. No processo de laminação a quente, os esforços são menores que no processo de laminação a frio, além de se permitir a eliminação de vazios de solidificação e porosidades inerentes aos produtos brutos de fusão.
III. A laminação a quente, que diz respeito à execução do processo em temperatura acima da temperatura de recristalização do material, facilita a deformação plástica (maior trabalhabilidade), mas promove elevado encruamento, gerado pelas grandes deformações.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 31 (INEP)'),
  ('24b0898e-1339-51cc-9e9e-c90e67eefeea', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Gestão da inovação', 'OBJETIVA', 'O atual cenário empresarial se caracteriza por rápidas transformações nos mercados, nas tecnologias e nos desenhos organizacionais. Diante desse panorama, as empresas buscam inovação para crescerem e se manterem nos mercados.

POSSOLLI, G. E. Gestão da inovação e do conhecimento. Curitiba: InterSaberes, 2012 (adaptado).', null, 'Acerca do processo de inovação, avalie as afirmações a seguir.

I. A realização de pequena alteração em um produto ou serviço representa uma inovação incremental.
II. O desenvolvimento de um novo serviço de internet para acesso a bancos ou sistemas de pagamentos de contas é considerado uma inovação de produto.
III. A inovação radical alcança um grau que permite criar mercados e modelos de negócio, apresentando soluções mais eficientes que as existentes até então.
IV. Um ecossistema de inovação é um ambiente formado por diferentes agentes (empresas, universidades, institutos de pesquisa, entidades governamentais etc.) comprometidos com o estímulo à inovação por meio da interação e cooperação.

É correto apenas o que se afirma em', null,
   'I e III.', 'I e IV.', 'II e III.', 'I, II e IV.', 'II, III e IV.', 1, 'ENADE 2023 — Engenharia Mecânica, Questão 32 (INEP)'),
  ('6eda3deb-b8a9-5fe0-b543-f1515cd6b8f4', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Gestão da manutenção', 'OBJETIVA', 'As falhas contribuem para reduzir a confiabilidade das operações produtivas, e isso pode trazer uma série de implicações: ambientes de trabalho inseguros, perdas de produção, redução da qualidade e, por consequência, menor lucratividade para o negócio. Sendo assim, o planejamento, a organização e o controle da manutenção industrial assumem um papel estratégico na organização.

GREGÓRIO, G. F. P.; SANTOS, D. F.; PRATA, A. B. Engenharia de Manutenção. Porto Alegre: SAGAH, 2018 (adaptado).

Sabe-se que, na manutenção, deve-se considerar o ativo ao longo de todo o seu ciclo de vida, que corresponde ao período entre a identificação da necessidade do ativo até a desativação dele ou o término de todas as responsabilidades posteriores.', null, 'A respeito do papel da manutenção industrial e considerando as informações apresentadas, avalie as afirmações a seguir.

I. O defeito é um evento que faz com que o equipamento pare de funcionar.
II. A taxa de falhas indica o número médio de falhas de um equipamento em determinado período.
III. Na estrutura centralizada, é facilitado o compartilhamento das melhores práticas de trabalho e de experiências entre os membros da equipe de manutenção, pois os profissionais de manutenção ficam alocados em uma oficina central.
IV. A manutenção preditiva consiste no monitoramento de um ou mais parâmetros de um equipamento com o objetivo de serem realizadas as ações necessárias antes que a falha aconteça, independentemente da condição do item monitorado.

É correto apenas o que se afirma em', null,
   'I.', 'III.', 'I e IV.', 'II e III.', 'II e IV.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 33 (INEP)'),
  ('3a561dc6-5639-53e0-b858-9aeb3ce92487', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Processos de soldagem', 'OBJETIVA', 'A soldagem a arco submerso é usada em uma larga faixa de aplicações industriais, sendo de grande utilidade em estaleiros, caldeirarias, mineradoras, siderúrgicas e fábricas de perfis e estruturas metálicas. É usada, ainda, na fabricação de vasos de pressão, navios, barcos, vagões e no revestimento ou na recuperação de peças que necessitam de ligas, com propriedades específicas como resistência ao desgaste abrasivo e tenacidade.

MARQUES, P. V.; MODENESI, P. J.; BRACARENSE, A. Q. Soldagem: fundamentos e tecnologia. Belo Horizonte: Editora UFMG, 2005 (adaptado).

Sabe-se que nesse processo de soldagem, o arco elétrico, que aquece e funde o eletrodo nu e a parte do metal de base em contato com o metal de adição, está coberto por uma camada de material granular fusível, conhecido como fluxo.', null, 'Considerando as informações apresentadas sobre o processo de soldagem a arco submerso, avalie as asserções a seguir e a relação proposta entre elas.

I. A alta qualidade da solda e sua alteração da composição química são atribuídas à presença do fluxo no processo, inclusive influenciando nas propriedades mecânicas da união soldada.

PORQUE

II. Os fluxos para soldagem a arco submerso são compostos por uma mistura de óxidos e outros minerais, podendo, ainda, conter ferro-ligas com diversas funções de operações.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 34 (INEP)'),
  ('0fa65d15-fbb7-548e-b5b3-77dc305696c8', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Desenho técnico mecânico', 'OBJETIVA', 'Quando um desenho de engenharia é passado ao setor de produção, ele deve conter todas as informações necessárias para se construir a peça ou sistema, sendo acompanhado de dimensões e notas explicativas que descrevam o tamanho e a localização de todos os componentes.

LEAKE, J. M. Manual de desenho técnico para engenharia: desenho, modelagem e visualização. 2. ed. Rio de Janeiro: LTC, 2015 (adaptado).

Considere que o sistema a ser fabricado seja o macaco de parafuso apresentado na figura a seguir, com destaque para a peça 4, denominada corpo do macaco.', 'enade2023/mec/mec-q35.png', 'PROVENZA, F. Desenhista de máquinas. 46. ed. São Paulo: editora F. Provenza, 1991 (adaptado).

Considerando a figura apresentada e a respeito da comunicação normativa das informações do desenho técnico-mecânico, para fins de produção do conjunto, avalie as afirmações a seguir.

I. O desenho que mostra o dispositivo montado deveria, conforme exigência normativa, apresentar as cotas dimensionais das peças do conjunto.
II. De acordo com a hachura representada na vista em meio corte da peça 4, sabe-se que o corpo do macaco deverá ser fabricado em liga de ferro fundido.
III. Na mesma vista em meio corte da peça 4, a cotagem da rosca indica que o passo desse perfil é normal.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 35 (INEP)'),
  ('0fc4e0c6-25f5-5e4e-b19d-ba864f2779f8', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Propriedades dos materiais', 'OBJETIVA', 'Com o avanço da tecnologia, os materiais da impressora 3D estão se multiplicando, bem como a necessidade de atender às solicitações específicas de aplicações. Inicialmente, os filamentos foram desenvolvidos para um padrão geral de peças, entretanto, verificou-se que, quanto mais funcionais se tornam as peças, maior é a necessidade de os materiais suportarem determinados requisitos de cada projeto.

O gráfico a seguir ilustra a curva tensão x deformação para três tipos de filamento comuns de impressoras 3D - FDM: o ácido poliláctico (PLA), o acrilonitrila-butadieno-estireno (ABS) e o polietileno tereftalato de etileno glicol (PETG).', 'enade2023/mec/mec-q36.png', 'Acerca do gráfico apresentado, avalie as afirmações a seguir.

I. O PETG foi o material com a maior tenacidade entre os testados.
II. O PLA, entre os materiais testados, é o com maior módulo de elasticidade.
III. O ABS, comparado ao PLA, suportou uma carga menor até a ruptura, porém se mostrou um material mais frágil entre os testados.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 36 (INEP)'),
  ('65df35fa-1d28-51e7-83cc-0e95c3411199', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Sustentabilidade na produção', 'OBJETIVA', 'Suponha que uma empresa especializada em fabricação de peças cortadas a laser tenha contabilizado um desperdício anual de 40% de toda a matéria prima utilizada. Após uma análise do seu processo produtivo, constatou-se que grande parte do resíduo gerado era oriundo de partes não aproveitadas das chapas de aço utilizadas na produção das peças, conforme exemplificado na figura a seguir. Decidiu-se, então, que a empresa iria buscar alternativas a fim de melhorar sua sustentabilidade e reduzir o impacto ambiental causado pelo resíduo gerado.', 'enade2023/mec/mec-q37.png', 'A partir das informações apresentadas, avalie as afirmações a seguir.

I. A implementação de medidas que possibilitem o reuso da sucata podem eliminar o impacto ambiental relacionado à geração de resíduos sólidos resultantes do processo produtivo.
II. A venda, para empresas de reciclagem, do resíduo gerado no processo de corte de chapas de aço pode ser uma solução para a redução do impacto ambiental e do prejuízo por desperdício de material.
III. O desperdício de material é inerente ao processo de corte a laser em chapa de aço, mas pode ser minimizado, por exemplo, pelo uso de técnicas que se baseiam em projeto assistido por computador e que maximizem a área de chapa de aço utilizada na produção de peças.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 1, 'ENADE 2023 — Engenharia Mecânica, Questão 37 (INEP)'),
  ('28d21d46-d1f4-5738-932d-7f5a8b844f4b', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Transmissão por engrenagens', 'OBJETIVA', 'Na manutenção dos sistemas mecânicos, é fundamental a análise dos sistemas elétricos, como, por exemplo, do motor de acionamento de sistemas de engrenamento. Caso haja alguma restrição no giro das engrenagens, a potência exigida do motor poderá aumentar, causando danos ao sistema.

A seguir, é apresentado um motor elétrico com sistema de engrenamento, sendo os raios das engrenagens B e C iguais a 96 mm e 60 mm, respectivamente. O eixo AB gira a 480 rpm e a potência original é de 96 kW. Considere π = 3.', 'enade2023/mec/mec-q38.png', 'BEER, F. P; JOHNSTON, E. R. Resistência dos Materiais. 3. ed. São Paulo: Makron Book, 1996 (adaptado).

A respeito do motor apresentado na figura e considerando as informações do texto, avalie as afirmações a seguir.

I. O torque necessário para acionamento é de 2000 N.m.
II. A velocidade linear no ponto de engrenamento é nula.
III. A velocidade angular da engrenagem C é de 300 rpm.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2023 — Engenharia Mecânica, Questão 38 (INEP)'),
  ('54b34377-08bc-58fc-a1d7-8e90e814f120', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Programação linear', 'DISCURSIVA', 'Uma empresa apresenta, em seu portfólio, dois produtos considerados substitutos, A e B, com contribuição marginal diferente para o lucro da empresa, a saber: R$ 20,00 por centena do item A e R$ 30,00 por centena do item B. Ambos os produtos consomem um mesmo recurso de produção, cuja disponibilidade total é de 60 horas. Para cada centena do produto A são necessárias 10 horas desse recurso para que ele seja produzido, ao passo que, para cada centena do produto B são necessárias 20 horas desse mesmo recurso.

A empresa foi orientada, por uma consultoria de mercado, a não colocar à venda uma soma de produtos superior a 400 unidades, uma vez que a demanda pelos itens é relacionada. Além disso, atendendo à política institucional de diversificação, o volume produzido do item A não deve ultrapassar o volume produzido do item B em mais de 250 unidades.', null, 'Considerando o caso apresentado, faça o que se pede nos itens a seguir.

a) Utilizando-se de programação linear, apresente a modelagem matemática do problema visando a maximização do lucro da empresa. Considere que as variáveis x_A e x_B representam, respectivamente, o volume produzido, em centenas de itens, dos produtos A e B. (valor: 5,0 pontos)
b) Determine, pelo método gráfico e pelo desenvolvimento da solução do modelo matemático, os valores das variáveis x_A e x_B que maximizam o lucro da empresa e indique o valor desse lucro. (valor: 5,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2023 — Engenharia de Produção, Questão Discursiva 2 (INEP)'),
  ('3b71d343-5b78-5b70-a3db-879f11c9d32c', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Probabilidade e estatística', 'OBJETIVA', 'Uma das preocupações dos gestores de instituições bancárias é o tempo de permanência do cliente na agência. Considere que o tempo gasto por um cliente em um banco, entre meio-dia e uma hora da tarde, apresente o comportamento de uma distribuição de probabilidade uniforme entre 0 e 30 minutos.', null, 'A probabilidade de que o tempo de permanência de um cliente esteja entre 5 e 20 minutos é, aproximadamente, de', null,
   '25%.', '33%.', '45%.', '50%.', '67%.', 1, 'ENADE 2023 — Engenharia de Produção, Questão 10 (INEP)'),
  ('a3d80985-6f36-5f19-94c6-38511977c883', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Estratégia competitiva', 'OBJETIVA', 'No Brasil, os principais produtos fabricados e comercializados por uma empresa são motosserras, roçadeiras e aparadores elétricos, cuja produção aproximada é de 50 000 unidades mensais. A empresa também produz cilindros para motores, fabricando em torno de 500 000 unidades por mês.

Quanto à produção de cilindros para motores, identificou-se que a empresa compete na estratégia de liderança em custos, pois a produção é de alto volume, visto que esses produtos são destinados tanto para produção dos motores dos equipamentos produzidos internamente (motosserras, roçadeiras e aparadores elétricos) quanto para outras empresas que utilizam esses produtos no mercado interno e externo.

Nos mercados agropecuário, de jardinagem e florestal, foi identificado que a empresa compete na estratégia de diferenciação. Tratam-se de produtos com valor agregado, que, depois de produzidos, são comercializados diretamente aos consumidores em lojas próprias.

PIRAN, F.A.S. et al. Posicionamento estratégico, estratégias de manufatura e gestão de custos: estudo de caso em uma empresa do segmento metalomecânico. Revista Contemporânea de Contabilidade. Florianópolis, v. 13, n. 28, p. 81-98, jan./abr., 2016 (adaptado).', null, 'Com base no texto e na classificação das decisões de estratégias competitivas genéricas, avalie as afirmações a seguir.

I. A estratégia de liderança em custos baseia-se na obtenção de economia de escala, decorrente do uso dos cilindros em uma maior variedade de produtos.
II. A diversidade de clientes que adquire os cilindros, evidencia que a empresa adota a estratégia competitiva genérica baseada no enfoque em custo.
III. A estratégia de diferenciação pode ser direcionada para alvos amplos ou estreitos, a depender dos segmentos de clientes que a empresa pretende alcançar.
IV. A referida empresa adota estratégia com enfoque na diferenciação, pois comercializa produtos nos mercados agropecuário, de jardinagem e florestal.

É correto apenas o que se afirma em', null,
   'I e II.', 'I e III.', 'III e IV.', 'I, II e IV.', 'II, III e IV.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 11 (INEP)'),
  ('f62b5901-4527-5a26-a88f-0bc0c6d20f99', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Gestão de estoques', 'OBJETIVA', 'Com o crescimento do mercado de pet shop, os estabelecimentos especializados passaram a gerenciar elevados níveis de estoque. Diante disso, o gestor de um estabelecimento comercial do ramo pet shop contratou um estagiário de Engenharia de Produção para auxiliá-lo na gestão de estoques.

Para calcular o ponto de reposição (demanda média durante o tempo de reposição mais o estoque de segurança) do item ração canina em embalagens de 15 kg, definiu um nível de serviço igual a 99%, sendo essa a probabilidade de não esgotar o estoque em qualquer ciclo de pedido.

A partir dessas definições, o gestor realizou levantamento de dados relativos ao item, e obteve os dados apresentados na tabela a seguir.

| Quantidade | Unidade
Demanda diária média | 160 | Embalagem de 15 kg
Desvio padrão da demanda diária | 25 | Embalagem de 15 kg
Tempo de reposição | 3 | Dia

Após seis meses de implantação do serviço o gestor percebeu que poderia reduzi-lo para 85%.

Com relação à essa situação hipotética, considere que a demanda do item está distribuída normalmente e, portanto, o estoque de segurança é obtido pelo produto do número de desvios padrão (z), associado ao nível de serviço definido, e o desvio padrão da demanda durante o tempo de reposição. Nesse caso, o desvio padrão do tempo de reposição é igual a 43 unidades.

A tabela da distribuição normal é apresentada a seguir.', 'enade2023/prod/prod-q12.png', 'Considerando as informações apresentadas, assinale a opção correta.', null,
   'A demanda média no tempo de reposição é de 320 unidades.', 'O ponto de reposição para o nível de serviço de 85% é de 400 unidades.', 'O estoque de segurança para o nível de serviço de 99% é de 120 unidades.', 'O ponto de reposição teve redução em cerca de 40 unidades, após a diminuição do nível de serviço de 99% para 85%.', 'O estoque de segurança foi aumentado em mais de 45 unidades, em razão da redução do nível de serviço de 99% para 85%.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 12 (INEP)'),
  ('96219148-3ab7-5fa2-993a-2755891fa735', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Previsão de demanda', 'OBJETIVA', 'As estacas pré-fabricadas de concreto são cravadas no terreno para a execução das fundações em profundidades suficientes para absorver as cargas estruturais. As peças podem ser fabricadas em qualquer forma geométrica em sua seção transversal.

A tabela a seguir indica a demanda, a previsão de demanda pelo método da suavização exponencial, com parâmetro suavizador de 0,6, o erro da previsão, o erro absoluto e o sinal de rastreamento para a estaca de 420 mm para um período de 20 dias.', 'enade2023/prod/prod-q13.png', 'Com base nos dados apresentados, avalie as afirmações a seguir.

I. O sinal de rastreamento indica que o modelo de previsão rastreia a variação da demanda.
II. O desvio médio absoluto (MAD) para o período de 20 dias é de aproximadamente -0,4.
III. O MAD para o período de 20 dias é de aproximadamente 27.
IV. A previsão da demanda para o dia 21 é de aproximadamente 217 estacas.

É correto apenas o que se afirma em', null,
   'I e II.', 'II e IV.', 'III e IV.', 'I, II e III.', 'I, III e IV.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 13 (INEP)'),
  ('0f7f9b79-a12d-5f6c-9eb5-9fa138466da3', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Controle estatístico da qualidade', 'OBJETIVA', 'Uma pequena fábrica, que produz artefatos plásticos injetados, possui três máquinas injetoras em suas instalações. Todas as máquinas têm a mesma capacidade de processamento e se encontram em plena operação. No entanto, clientes começaram a reclamar da qualidade dos produtos, pois, em muitos casos, as peças rachavam ao sofrerem pequenas quedas. A fim de verificar o ajuste das injetoras, foram selecionadas aleatoriamente 8 peças injetadas de cada máquina e, subsequentemente, o ensaio de resistência ao impacto foi conduzido em tais peças.

Os resultados experimentais são apresentados por meio do diagrama boxplot a seguir.', 'enade2023/prod/prod-q14.png', 'A análise da figura permite concluir, comparativamente, que', null,
   'a máquina 3 apresenta um melhor ajuste em relação à máquina 2, pois as peças injetadas exibem maior resistência ao impacto.', 'a máquina 3 é a que apresenta o melhor ajuste entre as máquinas da fábrica, pois fornece as peças injetadas de maior resistência ao impacto.', 'a máquina 1 apresenta um melhor ajuste em relação à máquina 2, pois é capaz de produzir 50% das peças injetadas com propriedade de resistência ao impacto superior a 19 J/m.', 'a máquina 3 é a que apresenta o pior ajuste dentre as máquinas da fábrica, pois é capaz de produzir 50% das peças injetadas com propriedade de resistência ao impacto inferior a 17 J/m.', 'a máquina 2 é a que apresenta o pior ajuste dentre as máquinas da fábrica, pois os dados experimentais para a resistência ao impacto são os que exibem o maior intervalo interquartílico.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 14 (INEP)'),
  ('b87db816-468f-5a85-abb6-ade7200eaa7e', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Gestão de projetos', 'OBJETIVA', 'Suponha que Leandro e seu irmão tenham resolvido fazer um macarrão ao alho e óleo seguindo a sequência representada no diagrama de rede a seguir, com os tempos das atividades dados em minutos.', 'enade2023/prod/prod-q15.png', 'Considerando que esse diagrama de rede foi seguido corretamente, avalie as afirmações a seguir.

I. O macarrão ao alho e óleo levou, no mínimo, 19 minutos para ficar pronto.
II. O caminho que inclui as atividades de cortar o alho e refogar o alho é um caminho não crítico.
III. A atividade de temperar o macarrão somente pode ser realizada após a atividade de ferver a água.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 1, 'ENADE 2023 — Engenharia de Produção, Questão 15 (INEP)'),
  ('242c7549-c775-5719-92a7-9e25177c6c3a', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Gestão de projetos (PERT/CPM)', 'OBJETIVA', 'PERT (Program Evaluation and Review Technique) e CPM (Critical Path Method) são técnicas utilizadas na gestão de projetos que foram desenvolvidas na década de 1950.

No diagrama a seguir estão representadas as atividades, e suas respectivas durações em dias, para a instalação de um equipamento de produção.', 'enade2023/prod/prod-q16.png', 'Assinale a alternativa que indica a folga, em dias, do caminho que inclui as atividades A, D e J.', null,
   '3.', '8.', '13.', '15.', '18.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 16 (INEP)'),
  ('7330dd7c-5dd5-53a1-959a-ae0577646477', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Gestão de projetos (CPM)', 'OBJETIVA', 'O quadro a seguir lista as atividades de um projeto, com suas durações e a indicação das atividades predecessoras.', 'enade2023/prod/prod-q17.png', 'De acordo com o cronograma apresentado, o tempo para completar o projeto, em dias, corresponde a', null,
   '15.', '16.', '17.', '18.', '19.', 1, 'ENADE 2023 — Engenharia de Produção, Questão 17 (INEP)'),
  ('1a5b50e0-0035-56af-ab66-15b2fb798888', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Previsão de demanda', 'OBJETIVA', 'A tabela a seguir apresenta os resultados de demanda real e quatro estimativas de previsão de demanda de uma empresa fabricante de bens de capital. A primeira estimativa de previsão de demanda foi obtida por meio da média móvel dos últimos três meses (n = 3) a segunda, pela média exponencial (alfa = 0,5), as duas últimas estimativas foram obtidas considerando-se médias móvel e exponencial, ambas com sazonalidade (SZ).', 'enade2023/prod/prod-q18.png', 'Considerando os dados da tabela, assinale a opção correta.', null,
   'A adoção de qualquer um dos modelos de previsão apresentados é elegível para uma restrição -3 < tracking signal < 3.', 'O tracking signal apresenta valor negativo em todas as estimativas, logo para essa empresa, nenhum dos modelos de previsão utilizados foi adequado.', 'O uso de médias exponenciais deve ser evitado quando se tem mais de um dado real de demanda, pois, nesses modelos, considera-se apenas um valor real de demanda.', 'O modelo de média exponencial com sazonalidade apresentou o menor tracking signal, logo a empresa deve adotar esse modelo para a previsão da demanda do produto, cujo indicador é otimizante.', 'O modelo de média exponencial com sazonalidade, obteve o menor erro acumulado, sendo esse, portanto, o modelo mais indicado, pois os erros de subestimação e superestimação da demanda estão se compensando.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 18 (INEP)'),
  ('13389426-6998-56d3-967e-1e53285dbc0d', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Planejamento da capacidade', 'OBJETIVA', 'Uma empresa automobilística fabrica carros de passeio em três cores: branco, preto e cinza. A unidade fabril dessa empresa conta com três centros de trabalho: estruturação, pintura e acabamento, que operam em dois turnos de oito horas cada. A demanda agregada para este mês foi de 200 carros de passeio, e o setor de vendas prevê que a demanda irá aumentar 10% ao mês durante o próximo semestre. O engenheiro de produção responsável pela análise da capacidade acredita que os centros de trabalho para pintura e acabamento estão ociosos e, por isso, está preocupado momentaneamente apenas com o centro de estruturação, conforme evidencia a tabela 1.', 'enade2023/prod/prod-q19.png', 'Nesse contexto, e considerando que o mês útil tenha sempre 20 dias, avalie as asserções a seguir e a relação proposta entre elas.

I. A empresa, no próximo mês, precisará traçar um plano de aumento da capacidade produtiva do centro de trabalho de estruturação, com o objetivo de atender ao crescimento de sua demanda.

PORQUE

II. Um aumento na demanda exigirá maior utilização do centro de trabalho de estruturação, consumindo um tempo maior de produção.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 19 (INEP)'),
  ('d5d97c42-3e90-50d1-8bb1-40a2fe96921e', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Previsão de consumo', 'OBJETIVA', 'A tabela a seguir apresenta o histórico de consumo de um item em uma empresa.', 'enade2023/prod/prod-q20.png', 'Com base nos dados apresentados e considerando que os estudos acerca de estoques dependem da previsão do consumo de material, assinale a opção correta.', null,
   'Na previsão de consumo para meses futuros, visando reduzir a influência do baixo consumo nos meses de março e abril, pode-se utilizar o método da média móvel ponderada, caracterizado pela aplicação de pesos maiores aos dados de consumo mais recentes e pesos menores aos dados mais antigos.', 'No método da média móvel, a previsão do próximo período é calculada pela média do consumo dos períodos anteriores, obtendo-se valores menores que os ocorridos nos últimos períodos, caso o consumo tenha tendências decrescentes, e maiores se o consumo tiver tendências crescentes.', 'No método da média com ponderação exponencial, apenas o consumo dos meses de julho e dezembro deve ser utilizado na fórmula de cálculo da previsão do consumo para o próximo mês, janeiro.', 'No método da média móvel para três períodos, a previsão de consumo para o próximo mês, janeiro, é superior a 111 unidades, dada a tendência crescente de consumo.', 'No método do último período, a previsão de consumo para o próximo mês, janeiro, é de 70 unidades.', 1, 'ENADE 2023 — Engenharia de Produção, Questão 20 (INEP)'),
  ('0e7e487f-2714-5c4e-a58e-ab4742ba2d98', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Análise custo-volume', 'OBJETIVA', 'Uma fábrica planeja aumentar sua capacidade de produção para atender ao crescimento da demanda previsto para os próximos anos. Após considerar uma dezena de pacotes tecnológicos, o gerente de produção definiu três alternativas tecnológicas, com características diferentes de custo fixo anual, custo variável por unidade e volume de produção anual.

Sabendo que o custo total anual = custo fixo anual + custo variável por unidade × volume de produção anual, analise o gráfico a seguir, que representa a relação custo x volume das três tecnologias avaliadas.', 'enade2023/prod/prod-q21.png', 'Sobre a análise de viabilidade econômica das tecnologias avaliadas nos níveis de produção V1, V2 e V3, assinale a opção correta.', null,
   'Para volumes acima de V2 e abaixo de V3, a tecnologia 1 é a escolha preferencial.', 'Para volumes abaixo de V1, a tecnologia 3 apresenta o melhor resultado econômico.', 'Para volumes entre V1 e V3, a tecnologia 2 apresenta o melhor resultado econômico.', 'Para volumes abaixo de V2 e acima de V3, a tecnologia 1 apresenta custos totais menores.', 'Para volumes acima de V3, a tecnologia 1 apresenta um melhor resultado econômico do que as demais.', 1, 'ENADE 2023 — Engenharia de Produção, Questão 21 (INEP)'),
  ('a80c3958-d6d0-5f7c-b87d-4de04fa1bdae', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Previsão de demanda', 'OBJETIVA', 'O gestor de um estabelecimento comercial adota o modelo de previsão de demanda pela média móvel simples para ração canina para cães adultos e para filhotes. Para a semana atual, os resultados referentes à demanda e previsão de demanda, em kg, são apresentados no quadro a seguir.', 'enade2023/prod/prod-q22.png', 'A falta de produto para atender à demanda de ração para filhotes motivou o gestor a adotar o modelo de suavização exponencial para a previsão de demanda, com parâmetros suavizadores 0,2 e 0,5 para a ração canina para adultos e filhotes, respectivamente.

Diante desses dados, verifica-se que a previsão da demanda de ração para cães adultos e filhotes, para a semana seguinte, deve ser, respectivamente, de', null,
   '6 320 e 645.', '6 320 e 630.', '6 305 e 640.', '6 275 e 645.', '6 275 e 630.', 1, 'ENADE 2023 — Engenharia de Produção, Questão 22 (INEP)'),
  ('2ddffecb-24f1-54eb-bdf9-b7ec78fb0168', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Engenharia econômica (custos marginais)', 'OBJETIVA', 'Suponha que um engenheiro tenha sido contratado para analisar a situação econômica de determinada empresa fabricante de produtos populares. A análise determinou que o custo total para a produção de x unidades pela empresa foi dado pela função C(x) = 15 + 3x + x²; o custo médio de produção foi estimado pela função Q(x) = C(x) / x; a receita total recebida pela venda de x unidades foi projetada pela função R(x) = 3x – x²/2.', null, 'Em seu relatório, o engenheiro pôde concluir corretamente que', null,
   'a função custo marginal é dada por C’(x) = 15 + 2x.', 'o custo real da fabricação da terceira unidade é de R$ 15.', 'o custo médio para a fabricação de dez unidades é de R$ 18.', 'a taxa de variação do custo, quando forem fabricadas três unidades, será de R$ 9 por unidade.', 'o empreendimento é rentável, pois a receita total é superior ao custo total de produção para qualquer quantidade produzida.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 23 (INEP)'),
  ('dcebd8d9-d475-5ff8-8b40-159b752332a1', 'CE', array['ENG_PROD']::public.curso_alvo[], 'MRP e registro de estoque', 'OBJETIVA', 'Um fornecedor de buchas e cunhas recebeu de seu cliente a programação para as semanas 14 a 23, conforme apresentado na tabela 1. Nela são apresentados os seguintes dados fornecidos pelo cliente: quantidade de itens em estoque no início da semana 14, estoque de segurança, a capacidade de produção diária para cada item e as necessidades de materiais referentes às semanas de 14 a 23. O fornecedor utilizou a regra de dimensionamento da quantidade fixa, correspondente à produção diária. Os lotes foram produzidos em múltiplos inteiros da produção diária. O fornecedor trabalha 6 dias por semana, não tendo restrição de capacidade para atender as demandas semanais previstas. O lead time para fabricação é de uma semana para todos os produtos, uma vez que o fornecedor não permite alterações na programação da semana em curso.', 'enade2023/prod/prod-q24.png', 'Com base nos dados apresentados, conclui-se que, para atender a demanda de', null,
   'BUCHA 0025, o fornecedor emite ordem de produção interna de 240 unidades na semana 15.', '160 itens da BUCHA 0025, o fornecedor encerra a semana 23 com estoque projetado de 40 unidades.', '250 itens da CUNHA 0056, o fornecedor encerra a semana 23 com estoque projetado de 30 unidades.', '5 600 itens da BUCHA 0039, o fornecedor emite ordens de produção interna que totalizam 5 220 unidades.', 'BUCHA 0039, o fornecedor mantém o estoque projetado médio de 236 unidades por semana no horizonte planejado.', 3, 'ENADE 2023 — Engenharia de Produção, Questão 24 (INEP)'),
  ('c0d3af64-b828-5083-8660-bbecf70f9c38', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Ponto de equilíbrio', 'OBJETIVA', 'Suponha que a empresa Alfa apresente as seguintes características:

• Tempo disponível para produção: 100 horas;
• Produto A
> preço unitário de venda: R$ 260,00;
> custo variável unitário: R$ 100,00;
> tempo de produção: 2 horas para cada unidade.
• Produto B
> preço unitário de venda: R$ 150,00;
> custo variável unitário: R$ 50,00;
> tempo de produção: 1 hora para cada unidade.', 'enade2023/prod/prod-q25.png', 'Considerando o gráfico e as informações apresentadas, pode-se concluir que a empresa Alfa atingirá o ponto de equilíbrio com o produto', null,
   'B, com 67 unidades vendidas.', 'A, com faturamento de R$ 16 250,00.', 'B, com 100 unidades e 100 horas de produção.', 'A, com o ponto de equilíbrio em 38 unidades vendidas.', 'A, com margem de contribuição unitária no valor de R$ 160,00.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 25 (INEP)'),
  ('1429f302-eb48-5e83-8c97-4d00baf24f02', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Teoria das restrições', 'OBJETIVA', 'Bolas para moagem forjadas em aço alto carbono são utilizadas em unidades de tratamento de minérios e na indústria cimenteira. Em uma empresa de produção de bolas para moagem, o fluxo do processo de fabricação inclui as seguintes operações: (i) aquecimento de barras de aço; (ii) cisalhamento de tarugos com dimensões de projeto e forjamento das bolas em recalcador horizontal; (iii) laminação para acabamento superficial das bolas; (iv) tratamento térmico de têmpera direta da temperatura final de laminação em tanque com solução aquosa; (v) tratamento de revenimento, para alívio das tensões térmicas originárias na etapa anterior, restrito a algumas aplicações específicas.

O engenheiro responsável pela produção, ao receber o programa da semana seguinte, considerando o fluxo do processo, apresentado na figura a seguir, e o fato de cada centro de trabalho possuir capacidade máxima de processamento igual a 2 400 minutos por semana, avaliou a utilização da capacidade do sistema produtivo visando à maximização do resultado econômico da empresa, conforme figura apresentada a seguir.', 'enade2023/prod/prod-q26.png', 'Considerando as informações apresentadas, é correto afirmar que o gargalo da operação é a estação de trabalho', null,
   'V (aquecer barras de aço) e o mix de produtos, para se alcançar o objetivo proposto, é de 12 000 unidades de B25, 48 600 unidades de B50 e 20 300 unidades de B40.', 'Y (tratamento térmico por têmpera) e o mix de produtos, para se alcançar o objetivo proposto, é de 12 000 unidades de B25, 23 100 unidades de B40 e 45 800 unidades de B50.', 'X (laminar) e o mix de produtos, para se alcançar o objetivo proposto, é de 23 100 unidades de B40, 48 600 unidades de B50 e 9 200 unidades de B25.', 'V (aquecer barras de aço) e a priorização de produção, para se alcançar o objetivo proposto, é B40, B50 e B25.', 'X (laminar) e a priorização de produção, para se alcançar o objetivo proposto, é B25, B50 e B40.', 3, 'ENADE 2023 — Engenharia de Produção, Questão 26 (INEP)'),
  ('9b00fcbc-bd1f-5745-b56a-c8bd96871871', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Problema de designação', 'OBJETIVA', 'Uma empresa produz derivados lácteos em sua unidade central, podendo atender clientes de quatro regiões: Norte, Sul, Leste e Oeste. Os vendedores Astolfo, Benício, Carlitos e Demóstenes serão alocados, no próximo semestre, para atender a essas localidades. A tabela a seguir apresenta o potencial de lucro, em milhões de reais, que pode ser gerado pelos vendedores em cada região. Acrescente-se que a empresa não possui recursos para enviar mais de um funcionário para atender a cada região.', 'enade2023/prod/prod-q27.png', 'Acerca desse cenário, avalie as afirmações a seguir.

I. Pelo fato da região Oeste ser a mais lucrativa entre as possíveis alocações, o funcionário Astolfo deverá ser enviado para atender essa região.
II. Pelo fato de ser a opção menos lucrativa entre as possíveis alocações, o funcionário Benício não deverá ser enviado para atender a região Leste.
III. A opção mais lucrativa, entre todas as possíveis alocações, resultará em 73 milhões de reais.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 27 (INEP)'),
  ('7fb242ea-4a95-51d0-bffc-4b691f2523c8', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Programação linear', 'OBJETIVA', 'Uma fábrica pode produzir dois tipos de vidros blindados, o Alfa e o Beta, cujos lotes com 1 000 unidades contribuem para gerar um lucro de, respectivamente, R$ 15 000,00 e R$ 6 000,00. Entre os diversos insumos de produção, há dois que são limitantes: a sílica (vendida em kg) e o corante (vendido em litros). Sabe-se que, na produção unitária de cada um dos produtos, utiliza-se 1 kg de sílica. São, também, consumidos 2 litros de corante para cada unidade de vidro Alfa e 1 litro de corante para cada unidade de vidro Beta. Acrescente-se que os fornecedores entregam, diariamente, 7 000 kg de sílica e 10 000 litros de corante.', null, 'Considerando que o objetivo da empresa é maximizar o seu lucro, avalie as afirmações a seguir.

I. A fábrica deveria produzir exclusivamente os vidros Alfa.
II. A fábrica deveria estabelecer um contrato com um grande cliente e fornecer 6 lotes de vidros Alfa diariamente.
III. A fábrica deveria adquirir mais corante, com o intuito de aumentar a produção de seus vidros.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 28 (INEP)'),
  ('1b3e7377-c9c0-52ae-aace-d79c0c13f742', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Sistema Toyota de Produção', 'OBJETIVA', 'O Sistema Toyota de Produção (STP) é uma filosofia que objetiva a eliminação de desperdícios no processo produtivo, por meio de ações eficientes, sem interrupções no fluxo e sob a demanda do cliente.', null, 'Considerando o STP, avalie as asserções a seguir e a relação proposta entre elas.

I. A troca rápida de ferramentas (TRF) é um dos métodos utilizados para tornar possível a implementação do STP.

PORQUE

II. O método TRF fundamenta-se na premissa de que, quanto menor o tempo de preparação de máquina (setup), menor o tamanho do lote econômico.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a asserção II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a asserção II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 1, 'ENADE 2023 — Engenharia de Produção, Questão 29 (INEP)'),
  ('f34c77ba-ae0e-59de-a44d-feef193e63e6', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Teoria das restrições', 'OBJETIVA', 'Em um determinado sistema de produção, quando a demanda é maior que a capacidade de processamento, tem-se um recurso gargalo (interno) que condiciona a decisão de mix de produtos. No quadro a seguir, são apresentados dados para apoiar a decisão sobre os produtos de um sistema produtivo.', 'enade2023/prod/prod-q30.png', 'Considerando as informações apresentadas e os conceitos da Teoria das Restrições, assinale a opção em que o mix de produtos que maximiza economicamente a utilização da capacidade do sistema de produção corresponde, respectivamente, às seguintes unidades do produto A e do produto B.', null,
   '100 e 200.', '100 e 300.', '200 e 200.', '300 e 100.', '300 e 200.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 30 (INEP)'),
  ('c8674f4b-4a71-5683-8654-b7cf51891921', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Gestão de estoques', 'OBJETIVA', 'O estoque de segurança corresponde a uma fração do estoque total em uma cadeia de suprimentos, afetando os custos logísticos.', null, 'Considerando os conceitos sobre estoque de segurança, analise as afirmações a seguir.

I. Quanto maior a variabilidade da demanda durante o tempo de ressuprimento, maior deverá ser o estoque de segurança a ser mantido para oferecer o mesmo nível de serviço.
II. O estoque de segurança, para um determinado nível de serviço, não acarreta custo de manutenção e armazenagem, pois ele é utilizado apenas quando a demanda esperada é excedida.
III. Quanto maior o nível de serviço, menor deve ser o estoque de segurança a ser mantido.
IV. A redução na variabilidade no tempo de ressuprimento permite a redução do nível de estoque de segurança, sem prejudicar a disponibilidade do produto.
V. Uma das funções do estoque de segurança é garantir a disponibilidade de estoque em face a incerteza na oferta e na demanda.

É correto apenas o que se afirma em', null,
   'I, II e III.', 'I, III e V.', 'I, IV e V.', 'II, III e IV.', 'II, IV e V.', 1, 'ENADE 2023 — Engenharia de Produção, Questão 31 (INEP)'),
  ('7ba2adeb-e0a9-5718-a489-5c09d75fe24a', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Balanceamento de linha', 'OBJETIVA', 'Determinada empresa fabricante de decodificadores para aparelhos de TV deve produzir 300 unidades desse material, por dia, para atender à demanda. Para otimizar o fluxo produtivo, o engenheiro da empresa decidiu realizar o balanceamento da linha de produção, estimando que 600 minutos por dia seria o tempo disponível para produção. A montagem do produto é composta por cinco operações (A, B, C, D e E), com durações (em minutos) e precedências especificadas no diagrama a seguir.', 'enade2023/prod/prod-q32.png', 'Com base nos dados apresentados, avalie as afirmações a seguir, relativas à referida empresa.

I. O takt time do sistema produtivo para atender a demanda é igual a 2 minutos por unidade.
II. A quantidade de estações de trabalho suficiente para balancear a linha de produção é igual a 2.
III. A eficiência do balanceamento da linha de produção é igual a 90%.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 32 (INEP)'),
  ('67580721-ee2e-58d5-83c1-3364e24d65d1', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Mecânica dos fluidos', 'OBJETIVA', 'Comparada às equações de escoamentos viscosos, a equação de movimento (Equação de Euler) empregada para escoamento incompressível e sem viscosidade é matematicamente mais simples, mas sua solução, em conjunto com a equação de conservação de massa, ainda apresenta dificuldades consideráveis. Uma aproximação conveniente resulta na Equação de Bernoulli, a qual é representada por

P/γ + v²/2g + z = Constante

Em que: P = pressão, Pa; γ = massa específica do fluido, N/m³; v = velocidade de escoamento do fluido, m/s; e, z = cota de altura, em relação ao referencial adotado no escoamento.

As restrições para o uso da Equação de Bernoulli são: (i) escoamento em regime permanente; (ii) escoamento incompressível; (iii) escoamento sem atrito; (iv) escoamento ao longo de uma linha de corrente.

FOX, R. W., et al. Introdução à Mecânica dos Fluidos. Rio de Janeiro: LTC, 2014 (adaptado).

Muitos problemas em tubulações estão associados à velocidade de escoamento de líquidos no interior de tubos. Um dos problemas é a separação da coluna líquida ocasionada pela obstrução do escoamento causado por bolhas. Essas bolhas são formadas pelos gases dissolvidos na água, que se desprendem do líquido quando a pressão é reduzida à pressão de vapor. As bolhas tendem a aumentar de tamanho com a liberação dos gases, tornando a vazão intermitente, podendo, até mesmo, interrompê-la.

PORTO, R. M. Hidráulica Básica. São Paulo: EESC-USP, 2006 (adaptado).

Considere a figura a seguir, que representa onde ocorre a separação da coluna líquida no tubo ascendente que transporta água a 60 °C, cuja pressão de vapor (Pv) é, aproximadamente, 19,53 kPa.', 'enade2023/prod/prod-q33.png', 'Para que o problema seja contornado, a solução é', null,
   'a elevação da cota de altura z_2 estipulada para o trecho 2.', 'a redução da vazão volumétrica média do fluido em escoamento.', 'a redução da pressão manométrica P_2, imposta no trecho 2 da tubulação.', 'a diminuição da velocidade de escoamento do fluido no trecho 1 da tubulação.', 'o esfriamento da água em escoamento na tubulação, pois a pressão P_v diminuirá.', 3, 'ENADE 2023 — Engenharia de Produção, Questão 33 (INEP)'),
  ('fbe0ba40-3a0b-538d-a69c-2f1520c7adcb', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Indicadores de manutenção', 'OBJETIVA', 'Para garantir a eficácia da gestão da qualidade, uma organização deve determinar e aplicar critérios e métodos (incluídos monitoramento, medições e indicadores de desempenho) necessários para assegurar a operação e o controle dos seus processos, além de determinar os recursos necessários para esses processos e assegurar sua disponibilidade.

ASSOCIAÇÃO BRASILEIRA DE NORMAS TÉCNICAS. NBR ISO 9001: Sistema de gestão da qualidade – requisitos. Rio de Janeiro: ABNT Editora, 2015.

Dada a necessidade de serem garantidas a disponibilidade e a confiabilidade de equipamentos que possibilitam o atendimento aos clientes, deve-se realizar o monitoramento da eficácia das ações da Engenharia de Manutenção por meio da utilização de indicadores de desempenho.', null, 'Considerando esses indicadores, avalie as afirmações a seguir.

I. O nível de qualidade na produção é o fator que mais influencia a Eficiência Global dos Equipamentos (OEE).
II. O Tempo Médio Entre Falhas (MTBF) é utilizado na determinação da manutenibilidade de equipamentos.
III. A distribuição estatística dos dados de taxa de falha pode ser dos tipos normal, exponencial ou Weibull.
IV. O Tempo Médio para Reparar (MTTR), que indica a eficiência da ação corretiva, é utilizado na determinação da confiabilidade de equipamento.

É correto apenas o que se afirma em', null,
   'I.', 'III.', 'I e II.', 'II e IV.', 'III e IV.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 34 (INEP)'),
  ('dd1e0a9d-1455-5964-9ad2-2e74ac918967', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Capacidade de processo', 'OBJETIVA', 'As cartas de controle fornecem informações sobre o valor de parâmetros de processo e sobre o seu comportamento ao longo do tempo. Isso permite que se faça estimativa da capacidade do processo. Dessa forma, se o processo apresenta apenas variações aleatórias é possível, por meio das propriedades da curva de distribuição normal, determinar a sua capacidade.

MONTGOMERY, D. C. Introdução ao controle estatístico da qualidade. Rio de Janeiro: LTC Editora, 2004 (adaptado).', 'enade2023/prod/prod-q35.png', 'Com base na figura e considerando que o desvio padrão dos processos A e B têm o mesmo valor, avalie as afirmações a seguir, relativas aos índices de capacidade desses processos.

I. Os processos A e B têm a mesma capacidade real.
II. Os processos A e B têm a mesma capacidade potencial.
III. A capacidade potencial do processo B é menor que sua capacidade real.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 35 (INEP)'),
  ('122c3f5d-7e19-5aea-8db2-4b90f1b16af7', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Ergonomia (NR-17)', 'OBJETIVA', 'No desenvolvimento do trabalho manual feito na posição sentado ou que tenha de ser feito em pé, bancadas, mesas, escrivaninhas e painéis devem proporcionar ao trabalhador condições de boa postura, visualização e operação e devem atender aos seguintes requisitos mínimos: a) ter altura e características da superfície de trabalho compatíveis com o tipo de atividade, com a distância requerida dos olhos ao campo de trabalho e com a altura do assento; b) ter área de trabalho de fácil alcance e visualização pelo trabalhador; c) ter características dimensionais que possibilitem posicionamento e movimentação adequados dos segmentos corporais.

Disponível em: https://enit.trabalho.gov.br/portal/images/Arquivos_SST/SST_NR/NR-17.pdf (adaptado). Acesso em: 31 jun.2019.', null, 'Acerca dos mobiliários adequados em postos de trabalhos conforme disposto na Norma Regulamentadora n. 17, avalie as afirmações a seguir.

I. Os assentos utilizados em postos de trabalho devem ter altura fixa, independentemente da estatura do trabalhador e da natureza da função exercida.
II. Os postos de trabalho, em que as atividades são realizadas em pé, devem possuir mobiliário adequado para que o trabalhador descanse no próprio posto de trabalho.
III. O posto de trabalho, em que a atividade puder ser executada na posição sentada, deve ser planejado ou adaptado para esta posição.
IV. Os assentos utilizados nos postos de trabalho devem ter encosto com forma levemente adaptada ao corpo do trabalhador, para a proteção de sua região lombar.

É correto apenas o que se afirma em', null,
   'I e II.', 'II e III.', 'III e IV.', 'I, II e IV.', 'I, III e IV.', 1, 'ENADE 2023 — Engenharia de Produção, Questão 36 (INEP)'),
  ('dff68c7b-3a82-537a-89dd-3823ef37cfbe', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Análise de investimentos', 'OBJETIVA', 'O método do payback simples considera o tempo de retorno do capital investido, quando o investidor estabelece um prazo máximo para recuperação do investimento, que servirá de padrão para a análise da viabilidade econômica do projeto. Nesse sentido, suponha que uma empresa pretende realizar um projeto de investimento com seis anos de duração, sendo de quatro anos o prazo estabelecido para a recuperação do capital investido. A tabela a seguir apresenta os valores para os fluxos de caixa anuais do mencionado projeto.', 'enade2023/prod/prod-q37.png', 'Considerando as informações apresentadas e o método payback simples, avalie as afirmações a seguir.

I. A recuperação do capital, no método payback simples, ocorrerá no prazo de até quatro anos, o que significa que o projeto deve ser aceito, pois atendeu à condição estabelecida.
II. O método payback simples considera o valor do dinheiro no tempo, mas não a distribuição do fluxo de caixa no período de recuperação do investimento.
III. O método payback simples pode ser comparado a um padrão de rentabilidade como, por exemplo, o custo de oportunidade do capital investido.
IV. O método payback simples pode ser adaptado para payback descontado, modelo que se diferencia do anterior apenas pelo fato de nele ser considerada uma taxa de atratividade ou de desconto.
V. A adaptação de payback simples para payback descontado não resolve todos os problemas, mas introduz a taxa de desconto, direcionando-se a solução para o método da taxa interna de retorno.

É correto apenas o que se afirma em', null,
   'I e III.', 'I e IV.', 'II e IV.', 'II e V.', 'III e V.', 2, 'ENADE 2023 — Engenharia de Produção, Questão 37 (INEP)'),
  ('55900461-ba9f-52c8-8936-7cc70cc700fe', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Mapa de riscos', 'OBJETIVA', 'No esquema apresentado a seguir, estão identificados cinco ambientes de trabalho de uma instalação industrial.', 'enade2023/prod/prod-q38.png', 'Para cada um desses ambientes foram identificados os riscos ambientais listados a seguir.

• Ambiente A: alto ruído de máquinas e equipamentos;
• Ambiente B: operação com eletricidade;
• Ambiente C: radiações ionizantes;
• Ambiente D: utilização de óleos e lubrificantes;
• Ambiente E: postura inadequada.

Os riscos mencionados para os ambientes A, B, C, D e E, podem ser classificados no processo de construção de um mapa de riscos, respectivamente, como', null,
   'físico, físico, acidente, físico e ergonômico.', 'ergonômico, físico, químico, químico e físico.', 'acidente, acidente, químico, químico e físico.', 'físico, acidente, químico, ergonômico e físico.', 'físico, acidente, físico, químico e ergonômico.', 1, 'ENADE 2023 — Engenharia de Produção, Questão 38 (INEP)')
on conflict (id) do nothing;

insert into public.questoes_gabarito (questao_id, gabarito, justificativa)
values
  ('8bff2eeb-5abe-5d4c-b5a5-339d90429954', null, 'a) O estudante deve explicar a relação entre desigualdade social e riscos socioambientais percorrendo o seguinte trajeto teórico-argumentativo:
• Descrever o(s) risco(s) socioambiental(is) que afeta(m) a população com perfil pobre ou extremamente pobre, tais como inundações, deslizamentos de terra, contaminação ambiental, maior vulnerabilidade em relação a doenças, discriminação social e criminalidade, entre outros;
• Descrever o meio (geográfico ou social), como morros, áreas próximas a rios, mangues, espaços marcados pela violência urbana, entre outros, nas cidades brasileiras, como fator de criação ou potencialização das condições de vulnerabilidade e risco aos pobres ou extremamente pobres;
• Estabelecer nexo causal entre pobreza ou extrema pobreza, o meio (geográfico ou social) urbano e a situação de risco socioambiental, relacionando ao perfil socioeconômico da população.

b) O estudante deverá apresentar propostas pertinentes, factíveis e bem desenvolvidas que envolvam ação governamental (federal, estadual/distrital ou municipal) e participação da comunidade a fim de minimizar riscos socioambientais, por exemplo:
• Implantar obras de infraestrutura urbana que envolvam contenção de morros e encostas e promover saneamento básico: serviços regulares de abastecimento de água, coleta e tratamento de esgotos, coleta e manejo de resíduos sólidos, manejo de águas pluviais, entre outras;
• Desenvolver políticas sociais, como segurança pública, provisão de moradia adequada, com custo acessível, e regularizada do ponto de vista fundiário; promover educação de qualidade, segurança pública, atendimento psicossocial — com especial atenção para grupos em situação de vulnerabilidade — entre outras ações;
• Garantir o acesso dessas comunidades a equipamentos sociais e culturais, bem como a espaços públicos inclusivos e a áreas verdes;
• Elaborar planos estratégicos participativos urbanos e ambientais a serem desenvolvidos nas comunidades em situação de vulnerabilidade.'),
  ('6f9da5ff-6c67-55ea-ba88-8866175bce87', 'D', null),
  ('c49b2776-4f4f-5c29-b613-e875e1dc54e0', 'D', null),
  ('e4a6cb5e-081c-540b-b0ae-59d8a60aa763', 'B', null),
  ('811fe912-0583-5e00-a100-fb0e72d017af', 'A', null),
  ('6a80053b-5cd1-5421-8202-be7f0d0141dc', 'E', null),
  ('24ae8cea-9385-52dc-8406-d4bdbe36d64f', 'C', null),
  ('6ae5c152-c2b5-5321-bac5-0095d644e9e0', 'A', null),
  ('6b1e3f3a-f327-5004-8972-f94b753c203d', 'B', null),
  ('55381946-8cf3-5e78-802a-8568cee4f932', 'E', null),
  ('459f1ab8-a3d0-5c53-9cdf-d6203bf45abb', null, 'a) Em sua resposta, o estudante deve determinar o seguinte:
• No trecho AB, o torque é nulo, pois não há torção nesse intervalo.
• No trecho BC, o torque é constante e igual a 150 N·m.
T = (3·10³)·(50·10⁻³) = 150 N·m
• No trecho CD, o torque é nulo, pois não há torção nesse intervalo.

b) Em sua resposta, o estudante deve determinar o seguinte:
• No Plano XZ, tem-se:
∑F_Z = 0;  R_AZ + R_DZ = 3·10³ N
∑M_A = 0;  3·10³·0,3 = R_DZ·0,9
▪ R_DZ = 10³ N então
▪ R_AZ = 2·10³ N
• No Plano XY, tem-se:
∑F_Z = 0;  R_AY + R_DY = 3·10³ N
∑M_A = 0;  3·10³·0,6 = R_DY·0,9
▪ R_DY = 2·10³ N então
▪ R_AY = 10³ N'),
  ('4e831f17-cb21-56e8-84f7-66fdaf43dce2', 'D', null),
  ('11cc2853-ffc0-5bd9-90e9-c54084ce353b', 'C', null),
  ('9a26a19c-bd64-569d-8430-e790e8784443', 'E', null),
  ('ff743ed5-5684-5f89-8698-2ef67dbd33d8', 'B', null),
  ('c1976d2d-fc17-5ce1-8685-54ce2940a2ba', 'B', null),
  ('32185f3e-24b3-5483-9295-981843b14aa6', 'E', null),
  ('fb4667b8-f596-5c44-956a-c91119c73c32', 'B', null),
  ('422c073a-c6a3-5449-8fee-99c61ee459b7', 'A', null),
  ('3980c105-0cfc-5ac9-8553-824f707f75d5', 'C', null),
  ('35090056-f2ee-5c93-8f95-ccea22d75309', 'B', null),
  ('4aaf32b8-515e-56a1-aecb-9d4f13369a7e', 'A', null),
  ('f3e87768-36c1-5590-80e2-72452949df43', 'A', null),
  ('acac1a2e-3779-5158-a660-251033cb72a0', 'E', null),
  ('953ef6f5-e297-53ea-829b-6a8e3b42781e', 'E', null),
  ('d4bc0e1a-6c46-50b1-be98-8c67aeb4fd08', 'D', null),
  ('c354653a-966a-53a7-9bad-0497f5d3f41d', 'D', null),
  ('37ed1fb2-8202-52fe-b896-b548a4a0aebd', 'E', null),
  ('1ff075ac-06af-5eb9-8d96-9aca53d1b0f8', 'B', null),
  ('87e785a5-5417-56d4-a730-c96dd5f1f6a3', 'C', null),
  ('da94ae46-a25f-5078-a918-d787f83a805b', 'C', null),
  ('0bd58fe6-931f-55ed-ac91-8cfba186c0b8', 'C', null),
  ('9e6339da-b404-59bb-8713-fcbc402c9458', 'C', null),
  ('24b0898e-1339-51cc-9e9e-c90e67eefeea', 'D', null),
  ('6eda3deb-b8a9-5fe0-b543-f1515cd6b8f4', 'D', null),
  ('3a561dc6-5639-53e0-b858-9aeb3ce92487', 'A', null),
  ('0fa65d15-fbb7-548e-b5b3-77dc305696c8', 'B', null),
  ('0fc4e0c6-25f5-5e4e-b19d-ba864f2779f8', 'C', null),
  ('65df35fa-1d28-51e7-83cc-0e95c3411199', 'D', null),
  ('28d21d46-d1f4-5738-932d-7f5a8b844f4b', 'A', null),
  ('54b34377-08bc-58fc-a1d7-8e90e814f120', null, 'a) Em sua resposta, o estudante deve:

Apresentar a modelagem matemática do problema, considerando que as variáveis x_A e x_B representam, respectivamente, o volume produzido, em centenas de itens, dos produtos A e B.

Função-objetivo:

Maximizar lucro = 20 X_A + 30 X_B

Sujeito às seguintes restrições:

R1: 10 X_A + 20 X_B ≤ 60
R2: X_A - X_B ≤ 2,5 OU R2: X_A ≤ 2,5 + X_B OU R2: X_B ≥ X_A – 2,5 OU R2: 100 X_A – 100 X_B ≤ 250 OU R2: 100 X_A ≤ 250 + 100 X_B OU R2: 100 X_B ≥ 100 X_A – 250
R3: X_A + X_B ≤ 4 OU 100 X_A + 100 X_B ≤ 400
R4: X_A, X_B ≥ 0 OU X_A ≥ 0 E X_B ≥ 0

Considerar a pontuação completa para o estudante que apresentar a função-objetivo correta e as restrições (R1, R2, R3, R4).

b) Em sua resposta, o estudante deve:

Determinar quais são os valores das variáveis X_A e X_B que maximizam a função-objetivo e o lucro máximo, apresentando o desenvolvimento da solução:

• X_A = 2
• X_B = 2
• lucro = 100

Desenvolvimento da solução pelo método gráfico:

[Gráfico do padrão de resposta, plano X_A (eixo horizontal) × X_B (eixo vertical): reta R1 (10 X_A + 20 X_B = 60) passando por (0; 3) e (6; 0); reta R3 (X_A + X_B = 4) passando por (0; 4) e (4; 0); reta R2 (X_A – X_B = 2,5) passando por (0; –2,5) e (2,5; 0); região viável sombreada no 1º quadrante, limitada pelos eixos e pelas retas R1, R3 e R2; reta da função-objetivo (tracejada, 20 X_A + 30 X_B = 100) tocando a região viável no vértice de interseção de R1 com R3, indicado como "Solução ótima" em (X_A; X_B) = (2; 2), com lucro = 20·2 + 30·2 = 100.]

Considerar a pontuação completa para o estudante que apresentar o desenvolvimento da solução pelo método gráfico e que também determinar X_A, X_B e Lucro.

Atenção: caso o estudante NÃO apresente o desenvolvimento da solução pelo método gráfico, deve-se atribuir ZERO em toda a letra “b”.'),
  ('3b71d343-5b78-5b70-a3db-879f11c9d32c', 'D', null),
  ('a3d80985-6f36-5f19-94c6-38511977c883', 'B', null),
  ('f62b5901-4527-5a26-a88f-0bc0c6d20f99', 'D', null),
  ('96219148-3ab7-5fa2-993a-2755891fa735', 'E', null),
  ('0f7f9b79-a12d-5f6c-9eb5-9fa138466da3', 'C', null),
  ('b87db816-468f-5a85-abb6-ade7200eaa7e', 'E', null),
  ('242c7549-c775-5719-92a7-9e25177c6c3a', 'C', null),
  ('7330dd7c-5dd5-53a1-959a-ae0577646477', 'C', null),
  ('1a5b50e0-0035-56af-ab66-15b2fb798888', 'A', null),
  ('13389426-6998-56d3-967e-1e53285dbc0d', 'D', null),
  ('d5d97c42-3e90-50d1-8bb1-40a2fe96921e', 'A', null),
  ('0e7e487f-2714-5c4e-a58e-ab4742ba2d98', 'C', null),
  ('a80c3958-d6d0-5f7c-b87d-4de04fa1bdae', 'A', null),
  ('2ddffecb-24f1-54eb-bdf9-b7ec78fb0168', 'D', null),
  ('dcebd8d9-d475-5ff8-8b40-159b752332a1', 'E', null),
  ('c0d3af64-b828-5083-8660-bbecf70f9c38', 'C', null),
  ('1429f302-eb48-5e83-8c97-4d00baf24f02', 'A', null),
  ('9b00fcbc-bd1f-5745-b56a-c8bd96871871', 'D', null),
  ('7fb242ea-4a95-51d0-bffc-4b691f2523c8', 'C', null),
  ('1b3e7377-c9c0-52ae-aace-d79c0c13f742', 'A', null),
  ('f34c77ba-ae0e-59de-a44d-feef193e63e6', 'D', null),
  ('c8674f4b-4a71-5683-8654-b7cf51891921', 'C', null),
  ('7ba2adeb-e0a9-5718-a489-5c09d75fe24a', 'C', null),
  ('67580721-ee2e-58d5-83c1-3364e24d65d1', 'E', null),
  ('fbe0ba40-3a0b-538d-a69c-2f1520c7adcb', 'B', null),
  ('dd1e0a9d-1455-5964-9ad2-2e74ac918967', 'B', null),
  ('122c3f5d-7e19-5aea-8db2-4b90f1b16af7', 'C', null),
  ('dff68c7b-3a82-537a-89dd-3823ef37cfbe', 'B', null),
  ('55900461-ba9f-52c8-8936-7cc70cc700fe', 'E', null)
on conflict (questao_id) do nothing;

update public.questoes set status = 'PUBLICADA'
 where id in ('8bff2eeb-5abe-5d4c-b5a5-339d90429954', '6f9da5ff-6c67-55ea-ba88-8866175bce87', 'c49b2776-4f4f-5c29-b613-e875e1dc54e0', 'e4a6cb5e-081c-540b-b0ae-59d8a60aa763', '811fe912-0583-5e00-a100-fb0e72d017af', '6a80053b-5cd1-5421-8202-be7f0d0141dc', '24ae8cea-9385-52dc-8406-d4bdbe36d64f', '6ae5c152-c2b5-5321-bac5-0095d644e9e0', '6b1e3f3a-f327-5004-8972-f94b753c203d', '55381946-8cf3-5e78-802a-8568cee4f932', '459f1ab8-a3d0-5c53-9cdf-d6203bf45abb', '4e831f17-cb21-56e8-84f7-66fdaf43dce2', '11cc2853-ffc0-5bd9-90e9-c54084ce353b', '9a26a19c-bd64-569d-8430-e790e8784443', 'ff743ed5-5684-5f89-8698-2ef67dbd33d8', 'c1976d2d-fc17-5ce1-8685-54ce2940a2ba', '32185f3e-24b3-5483-9295-981843b14aa6', 'fb4667b8-f596-5c44-956a-c91119c73c32', '422c073a-c6a3-5449-8fee-99c61ee459b7', '3980c105-0cfc-5ac9-8553-824f707f75d5', '35090056-f2ee-5c93-8f95-ccea22d75309', '4aaf32b8-515e-56a1-aecb-9d4f13369a7e', 'f3e87768-36c1-5590-80e2-72452949df43', 'acac1a2e-3779-5158-a660-251033cb72a0', '953ef6f5-e297-53ea-829b-6a8e3b42781e', 'd4bc0e1a-6c46-50b1-be98-8c67aeb4fd08', 'c354653a-966a-53a7-9bad-0497f5d3f41d', '37ed1fb2-8202-52fe-b896-b548a4a0aebd', '1ff075ac-06af-5eb9-8d96-9aca53d1b0f8', '87e785a5-5417-56d4-a730-c96dd5f1f6a3', 'da94ae46-a25f-5078-a918-d787f83a805b', '0bd58fe6-931f-55ed-ac91-8cfba186c0b8', '9e6339da-b404-59bb-8713-fcbc402c9458', '24b0898e-1339-51cc-9e9e-c90e67eefeea', '6eda3deb-b8a9-5fe0-b543-f1515cd6b8f4', '3a561dc6-5639-53e0-b858-9aeb3ce92487', '0fa65d15-fbb7-548e-b5b3-77dc305696c8', '0fc4e0c6-25f5-5e4e-b19d-ba864f2779f8', '65df35fa-1d28-51e7-83cc-0e95c3411199', '28d21d46-d1f4-5738-932d-7f5a8b844f4b', '54b34377-08bc-58fc-a1d7-8e90e814f120', '3b71d343-5b78-5b70-a3db-879f11c9d32c', 'a3d80985-6f36-5f19-94c6-38511977c883', 'f62b5901-4527-5a26-a88f-0bc0c6d20f99', '96219148-3ab7-5fa2-993a-2755891fa735', '0f7f9b79-a12d-5f6c-9eb5-9fa138466da3', 'b87db816-468f-5a85-abb6-ade7200eaa7e', '242c7549-c775-5719-92a7-9e25177c6c3a', '7330dd7c-5dd5-53a1-959a-ae0577646477', '1a5b50e0-0035-56af-ab66-15b2fb798888', '13389426-6998-56d3-967e-1e53285dbc0d', 'd5d97c42-3e90-50d1-8bb1-40a2fe96921e', '0e7e487f-2714-5c4e-a58e-ab4742ba2d98', 'a80c3958-d6d0-5f7c-b87d-4de04fa1bdae', '2ddffecb-24f1-54eb-bdf9-b7ec78fb0168', 'dcebd8d9-d475-5ff8-8b40-159b752332a1', 'c0d3af64-b828-5083-8660-bbecf70f9c38', '1429f302-eb48-5e83-8c97-4d00baf24f02', '9b00fcbc-bd1f-5745-b56a-c8bd96871871', '7fb242ea-4a95-51d0-bffc-4b691f2523c8', '1b3e7377-c9c0-52ae-aace-d79c0c13f742', 'f34c77ba-ae0e-59de-a44d-feef193e63e6', 'c8674f4b-4a71-5683-8654-b7cf51891921', '7ba2adeb-e0a9-5718-a489-5c09d75fe24a', '67580721-ee2e-58d5-83c1-3364e24d65d1', 'fbe0ba40-3a0b-538d-a69c-2f1520c7adcb', 'dd1e0a9d-1455-5964-9ad2-2e74ac918967', '122c3f5d-7e19-5aea-8db2-4b90f1b16af7', 'dff68c7b-3a82-537a-89dd-3823ef37cfbe', '55900461-ba9f-52c8-8936-7cc70cc700fe') and status = 'RASCUNHO';

insert into public.sessoes (id, tipo, titulo, curso, inicio, fim, duracao_minutos, questoes, publicada, pontos_atividade)
values
  ('c5a221bd-4ea2-5447-84b4-980addff4a7a', 'SIMULADO', 'ENADE 2023 — Engenharia Mecânica (atividade avaliativa)', 'ENG_MEC', '2026-11-01 00:00:00-03', '2026-11-10 23:59:59-03', 240,
   array['8bff2eeb-5abe-5d4c-b5a5-339d90429954', '6f9da5ff-6c67-55ea-ba88-8866175bce87', 'c49b2776-4f4f-5c29-b613-e875e1dc54e0', 'e4a6cb5e-081c-540b-b0ae-59d8a60aa763', '811fe912-0583-5e00-a100-fb0e72d017af', '6a80053b-5cd1-5421-8202-be7f0d0141dc', '24ae8cea-9385-52dc-8406-d4bdbe36d64f', '6ae5c152-c2b5-5321-bac5-0095d644e9e0', '6b1e3f3a-f327-5004-8972-f94b753c203d', '55381946-8cf3-5e78-802a-8568cee4f932', '459f1ab8-a3d0-5c53-9cdf-d6203bf45abb', '4e831f17-cb21-56e8-84f7-66fdaf43dce2', '11cc2853-ffc0-5bd9-90e9-c54084ce353b', '9a26a19c-bd64-569d-8430-e790e8784443', 'ff743ed5-5684-5f89-8698-2ef67dbd33d8', 'c1976d2d-fc17-5ce1-8685-54ce2940a2ba', '32185f3e-24b3-5483-9295-981843b14aa6', 'fb4667b8-f596-5c44-956a-c91119c73c32', '422c073a-c6a3-5449-8fee-99c61ee459b7', '3980c105-0cfc-5ac9-8553-824f707f75d5', '35090056-f2ee-5c93-8f95-ccea22d75309', '4aaf32b8-515e-56a1-aecb-9d4f13369a7e', 'f3e87768-36c1-5590-80e2-72452949df43', 'acac1a2e-3779-5158-a660-251033cb72a0', '953ef6f5-e297-53ea-829b-6a8e3b42781e', 'd4bc0e1a-6c46-50b1-be98-8c67aeb4fd08', 'c354653a-966a-53a7-9bad-0497f5d3f41d', '37ed1fb2-8202-52fe-b896-b548a4a0aebd', '1ff075ac-06af-5eb9-8d96-9aca53d1b0f8', '87e785a5-5417-56d4-a730-c96dd5f1f6a3', 'da94ae46-a25f-5078-a918-d787f83a805b', '0bd58fe6-931f-55ed-ac91-8cfba186c0b8', '9e6339da-b404-59bb-8713-fcbc402c9458', '24b0898e-1339-51cc-9e9e-c90e67eefeea', '6eda3deb-b8a9-5fe0-b543-f1515cd6b8f4', '3a561dc6-5639-53e0-b858-9aeb3ce92487', '0fa65d15-fbb7-548e-b5b3-77dc305696c8', '0fc4e0c6-25f5-5e4e-b19d-ba864f2779f8', '65df35fa-1d28-51e7-83cc-0e95c3411199', '28d21d46-d1f4-5738-932d-7f5a8b844f4b']::uuid[], true, 1000),
  ('e8fc0a44-22be-5838-b01d-fc29b320db05', 'SIMULADO', 'ENADE 2023 — Engenharia de Produção (atividade avaliativa)', 'ENG_PROD', '2026-11-01 00:00:00-03', '2026-11-10 23:59:59-03', 240,
   array['8bff2eeb-5abe-5d4c-b5a5-339d90429954', '6f9da5ff-6c67-55ea-ba88-8866175bce87', 'c49b2776-4f4f-5c29-b613-e875e1dc54e0', 'e4a6cb5e-081c-540b-b0ae-59d8a60aa763', '811fe912-0583-5e00-a100-fb0e72d017af', '6a80053b-5cd1-5421-8202-be7f0d0141dc', '24ae8cea-9385-52dc-8406-d4bdbe36d64f', '6ae5c152-c2b5-5321-bac5-0095d644e9e0', '6b1e3f3a-f327-5004-8972-f94b753c203d', '55381946-8cf3-5e78-802a-8568cee4f932', '54b34377-08bc-58fc-a1d7-8e90e814f120', '3b71d343-5b78-5b70-a3db-879f11c9d32c', 'a3d80985-6f36-5f19-94c6-38511977c883', 'f62b5901-4527-5a26-a88f-0bc0c6d20f99', '96219148-3ab7-5fa2-993a-2755891fa735', '0f7f9b79-a12d-5f6c-9eb5-9fa138466da3', 'b87db816-468f-5a85-abb6-ade7200eaa7e', '242c7549-c775-5719-92a7-9e25177c6c3a', '7330dd7c-5dd5-53a1-959a-ae0577646477', '1a5b50e0-0035-56af-ab66-15b2fb798888', '13389426-6998-56d3-967e-1e53285dbc0d', 'd5d97c42-3e90-50d1-8bb1-40a2fe96921e', '0e7e487f-2714-5c4e-a58e-ab4742ba2d98', 'a80c3958-d6d0-5f7c-b87d-4de04fa1bdae', '2ddffecb-24f1-54eb-bdf9-b7ec78fb0168', 'dcebd8d9-d475-5ff8-8b40-159b752332a1', 'c0d3af64-b828-5083-8660-bbecf70f9c38', '1429f302-eb48-5e83-8c97-4d00baf24f02', '9b00fcbc-bd1f-5745-b56a-c8bd96871871', '7fb242ea-4a95-51d0-bffc-4b691f2523c8', '1b3e7377-c9c0-52ae-aace-d79c0c13f742', 'f34c77ba-ae0e-59de-a44d-feef193e63e6', 'c8674f4b-4a71-5683-8654-b7cf51891921', '7ba2adeb-e0a9-5718-a489-5c09d75fe24a', '67580721-ee2e-58d5-83c1-3364e24d65d1', 'fbe0ba40-3a0b-538d-a69c-2f1520c7adcb', 'dd1e0a9d-1455-5964-9ad2-2e74ac918967', '122c3f5d-7e19-5aea-8db2-4b90f1b16af7', 'dff68c7b-3a82-537a-89dd-3823ef37cfbe', '55900461-ba9f-52c8-8936-7cc70cc700fe']::uuid[], true, 1000)
on conflict (id) do nothing;
