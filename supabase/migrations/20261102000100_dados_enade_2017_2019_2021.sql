-- =============================================================================
-- Migration 16 (dados): provas ENADE 2017, 2019 e 2021 no banco de questões
--
--   * 144 questões oficiais do Inep transcritas dos cadernos de prova
--     (fg19 9, mec19 26, prod19 30, fg21 10, ads21 30, fg17 10, ads17 29): Formação Geral (D1, D2 + 01–08,
--     para todos os cursos) e Componente Específico (D3–D5 + 09–35) de Eng.
--     Mecânica 2019, Eng. de Produção 2019, ADS 2021 e ADS 2017. Gabarito
--     definitivo nas objetivas e padrão de resposta oficial nas discursivas.
--     Questões anuladas pelo Inep ficaram de fora. Figuras em public/enade20xx/.
--   * Publicadas no banco (entram no treino do curso e ficam disponíveis para
--     montar simulados).
--   * Um simulado por prova, completo e na ordem do caderno, como RASCUNHO
--     (publicada = false, sem valor em pontos): a coordenação ajusta a janela e
--     publica quando quiser aplicar.
--   * Idempotente: ids fixos e "on conflict do nothing".
-- =============================================================================

insert into public.questoes
  (id, componente, cursos, eixo, formato, texto_apoio, figura_url, enunciado, figura_alternativas_url,
   alt_a, alt_b, alt_c, alt_d, alt_e, dificuldade, fonte)
values
  ('cef13b07-c329-5453-96bc-770582e7eca5', 'FG', array['ALL']::public.curso_alvo[], 'Desastres naturais e sustentabilidade', 'DISCURSIVA', 'Conforme levantamento patrocinado pelo Ministério da Integração Nacional, o Brasil sofreu mais de 30 mil desastres naturais entre 1990 e 2012, o que confere a média de 1 363 eventos por ano. O Atlas Brasileiro de Desastres Naturais de 2013 mostra que, entre 1991 e 2012, foram registradas 31 909 catástrofes no país, sendo que 73% ocorreram na última década. O banco de dados do histórico dos desastres brasileiros associados a fenômenos naturais indica que estiagens, secas, inundações bruscas e alagamentos são as tipologias mais recorrentes do país.

LICCO, E.; DOWELL, S. Alagamentos, enchentes, enxurradas e inundações: digressões sobre seus impactos sócio econômicos e governança. Revista de Iniciação Científica, Tecnológica e Artística. Edição Temática em Sustentabilidade, v. 5, n. 3, São Paulo: Centro Universitário Senac, 2015 (adaptado).

De acordo com o relatório do Escritório das Nações Unidas para a Redução do Risco de Desastres de 2014, a necessidade de minimizar os riscos e os impactos de futuros desastres naturais é algo fundamental para as comunidades em todo o mundo. Reduzir os níveis existentes de riscos que favorecem os desastres, fortalecendo a resiliência social, ambiental e econômica é uma das soluções encontradas para que as cidades consigam conviver com esses fenômenos naturais.

RIBEIRO, J.; VIEIRA, R.; TÔMIO, D. Análise da percepção do risco de desastres naturais por meio da expressão gráfica de estudantes do Projeto Defesa Civil na Escola. UFPR, Desenvolvimento e Meio Ambiente, v. 42, dezembro 2017 (adaptado).', null, 'A partir da análise dos textos, apresente duas propostas de intervenção no âmbito da sustentabilidade socioambiental, de modo a contemplar ações de restauração ou recuperação após a ocorrência de desastres. (valor: 10,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2019 — Formação Geral, Questão Discursiva 1 (INEP)'),
  ('c433a3c9-e02d-56ca-81aa-4ca0b83ba065', 'FG', array['ALL']::public.curso_alvo[], 'Ciência, tecnologia e inovação', 'DISCURSIVA', null, 'enade2019/fg/fg19-d2.png', 'O Brasil está longe de ser um país atrasado do ponto de vista científico e tecnológico. O país está em posição intermediária em praticamente todos os indicadores de produção e utilização de conhecimento e de novas tecnologias. Em alguns indicadores, a situação do país é melhor até do que em alguns países europeus como Portugal ou Espanha e, de modo geral, estamos à frente de todos os demais países latino-americanos. Talvez nosso pior desempenho esteja nos depósitos de patentes, seja no Brasil ou no exterior.

Disponível em: <http://www.ipea.gov.br/portal/index.php?option=com_content&view=article&id=33511&Itemid=433> Acesso em: 01 out. 2019 (adaptado).

A partir das informações apresentadas, faça o que se pede nos itens a seguir.
a) Cite dois ganhos possíveis para o campo científico do país, resultantes de uma boa articulação entre os entes representados na figura. (valor: 5,0 pontos)
b) Cite dois ganhos possíveis para o campo econômico do país, resultantes de uma boa articulação entre os entes representados na figura. (valor: 5,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2019 — Formação Geral, Questão Discursiva 2 (INEP)'),
  ('69796919-322d-565b-82cd-a76c16f9d278', 'FG', array['ALL']::public.curso_alvo[], 'Poesia concreta', 'OBJETIVA', null, 'enade2019/fg/fg19-q02.png', 'Augusto de Campos é um artista concretista brasileiro cuja poética estabelece a relação de diálogo entre o aspecto visual, sonoro e tátil do texto verbal.

Com base no poema apresentado, avalie as afirmações a seguir.

I. O aspecto sensorial é construído por meio da exploração da dimensão visual das palavras, sendo a imagem um elemento essencial do texto.
II. O artista utiliza técnicas de diagramação, harmonizando os componentes gráficos e espaciais, que se transformam em elementos de construção de sentidos diversos.
III. A impressão de movimento caótico cria o efeito de uma espécie de big-bang que atua sobre ambas as palavras: poema e bomba.
IV. A utilização do espaço é secundária para a construção de sentidos da obra, já que a palavra escrita, nesse caso, é suficiente para a leitura do poema.

É correto o que se afirma em', null,
   'I, apenas.', 'II e IV, apenas.', 'III e IV, apenas.', 'I, II e III, apenas.', 'I, II, III e IV.', 2, 'ENADE 2019 — Formação Geral, Questão 02 (INEP)'),
  ('a74430e4-4512-5a5b-9735-217b280d35fc', 'FG', array['ALL']::public.curso_alvo[], 'Segurança alimentar e nutricional', 'OBJETIVA', 'Na história das civilizações humanas, a agricultura esteve relacionada à origem de um fenômeno que se tornaria o marco da economia alimentar: o aumento demográfico. Entretanto, apesar de toda a força civilizatória da agricultura, muitos povos tornaram-se vulneráveis por falta de alimentos.

Mesmo com o aumento do volume de alimentos, o número de indivíduos subnutridos é grande, como demonstrado pelos dados estatísticos da Organização das Nações Unidas para a Agricultura e Alimentação (FAO). A análise dos dados revela que, até 2014, a quantidade de pessoas desnutridas no mundo estava diminuindo, porém, entre 2015 e 2017, esse número aumenta.

LIMA, J. S. G. Segurança alimentar e nutricional: sistemas agroecológicos são a mudança que a intensificação ecológica não alcança. Ciência e Cultura, v. 69, n. 2, 2017 (adaptado).', null, 'Considerando a segurança alimentar e a nutrição no mundo, avalie as afirmações a seguir.

I. O conceito de segurança alimentar e nutricional admite que a fome e a desnutrição são problemas de oferta adequada e garantia de alimentos saudáveis, respeitando-se a diversidade cultural e a sustentabilidade socioeconômica e ambiental.
II. A segurança alimentar e nutricional compreende a produção e a disponibilidade de alimentos, bem como o acesso à alimentação adequada e saudável.
III. A escassez da oferta de alimentos nas últimas décadas decorre da falta de processos de produção e disseminação tecnológica que garantam a produção no campo frente às mudanças climáticas.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Formação Geral, Questão 03 (INEP)'),
  ('af6a861f-7ad1-5163-ba3e-dbceeba3a496', 'FG', array['ALL']::public.curso_alvo[], 'Saneamento básico', 'OBJETIVA', 'Segundo resultados da última Pesquisa Nacional de Saneamento Básico (PNSB) de 2008, a quase totalidade dos municípios brasileiros tinha serviço de abastecimento de água em pelo menos um distrito (99,4%). Além da existência da rede, uma das formas de se avaliar a eficiência do serviço de abastecimento de água à população é examinar o volume diário per capita da água distribuída por rede geral. No ano de 2008, foram distribuídos diariamente, no conjunto do país, 320 litros per capita, média que variou bastante entre as regiões. Na Região Sudeste, o volume distribuído alcançou 450 litros per capita, enquanto na Região Nordeste ele não chegou à metade desta marca, apresentando uma média de 210 litros per capita. Embora o volume total tenha aumentado em todas as regiões do país, comparando-se com os números apresentados pela PNSB de 2000, as diferenças regionais permaneceram praticamente inalteradas.

Disponível em: <https://biblioteca.ibge.gov.br/index.php/biblioteca-catalogo?view=detalhes&id=280933> Acesso em: 01 out. 2019 (adaptado).', null, 'Com base nas informações apresentadas, avalie as asserções a seguir e a relação proposta entre elas.

I. Em algumas regiões do Brasil, os índices referidos estão abaixo da média nacional, indicando diferenças de acesso de qualidade a abastecimento de água que podem impactar a saúde pública.
PORQUE
II. O aumento da eficiência da política pública de abastecimento de água no Brasil contribui para o desenvolvimento nacional, para a redução dos desequilíbrios regionais e para a promoção da inclusão social.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa e a II é uma proposição verdadeira.', 'As asserções I e II são falsas.', 2, 'ENADE 2019 — Formação Geral, Questão 04 (INEP)'),
  ('9edea88f-3206-5cdc-bc48-2551271cad5f', 'FG', array['ALL']::public.curso_alvo[], 'Direitos dos povos indígenas', 'OBJETIVA', null, 'enade2019/fg/fg19-q05.png', 'O Supremo Tribunal Federal definiu, em 2009, os critérios para o reconhecimento de determinada terra como território indígena, sendo eles: o marco da tradicionalidade da ocupação; o marco temporal da ocupação; o marco da concreta abrangência e finalidade prática da ocupação tradicional; e, por fim, o marco da proporcionalidade, que consiste na aplicação do princípio da proporcionalidade em matéria indígena. De acordo com o marco da tradicionalidade da ocupação, para que uma terra indígena possa ser considerada tradicional, as comunidades indígenas devem demonstrar o caráter de perdurabilidade de sua relação com a terra, caráter este demonstrado em sentido de continuidade etnográfica.

Disponível em: <https://doi.org/10.12957/publicum.2018.37271>. Acesso em: 27 set. 2019 (adaptado).

Com base nas imagens e informações acerca dos referidos marcos para o reconhecimento de determinada terra como indígena, avalie as afirmações a seguir.

I. A tradicionalidade é um elemento fundamental para a perpetuação dos vínculos territoriais das populações indígenas, já que remete ao caráter estático de seus modos de vida.
II. Os marcos de reconhecimento da ocupação viabilizam o alcance do direito de utilização das terras em diferentes tipos de atividades produtivas por parte das comunidades indígenas.
III. O critério de ocupação tradicional considera que a terra indígena proporciona elementos materiais e simbólicos essenciais à transmissão dos legados culturais entre gerações.
IV. O reconhecimento de terras ancestrais integra-se à lógica da homogeneidade cultural, já que esta medida valoriza a cultura e a participação dos povos indígenas como elementos do amálgama cultural brasileiro.

É correto apenas o que se afirma em', null,
   'I e III.', 'I e IV.', 'II e III.', 'I, II e IV.', 'II, III e IV.', 2, 'ENADE 2019 — Formação Geral, Questão 05 (INEP)'),
  ('6aa20def-8e25-5570-9cd3-12f390e3cd36', 'FG', array['ALL']::public.curso_alvo[], 'Violência contra a mulher', 'OBJETIVA', 'Conforme dados do Atlas da Violência 2019, apresentados no gráfico a seguir, verifica-se o crescimento no número de homicídios de mulheres no país durante o período de 2007 a 2017. Nesse período, a taxa de homicídios entre as mulheres negras cresceu mais do que a taxa de homicídios entre as mulheres não negras. A classificação de raça/cor do IBGE agrega negras como a soma de pretas e pardas e não negras como a soma de brancas, amarelas e indígenas.', 'enade2019/fg/fg19-q06.png', 'Considerando as informações apresentadas, avalie as asserções a seguir e a relação proposta entre elas.

I. O maior crescimento dos casos de homicídios de mulheres negras em comparação com os casos de mulheres não negras indica a relevância dos estudos a respeito das múltiplas variáveis relacionadas a este fenômeno social.
PORQUE
II. A análise do gráfico permite concluir que, no início da série histórica, havia um contexto favorável à superação da situação social de maior vulnerabilidade da mulher negra, em razão da menor diferença entre as taxas de homicídios.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa e a II é uma proposição verdadeira.', 'As asserções I e II são falsas.', 2, 'ENADE 2019 — Formação Geral, Questão 06 (INEP)'),
  ('412ba6be-0dff-5a75-870f-a425d12b12fe', 'FG', array['ALL']::public.curso_alvo[], 'Acessibilidade e inclusão', 'OBJETIVA', null, 'enade2019/fg/fg19-q07.png', 'O princípio da acessibilidade dispõe que na construção de espaços, na formatação de produtos e no planejamento de serviços deve-se considerar que as pessoas com deficiência (PCD) são usuárias legítimas, dignas e independentes. Nenhum serviço pode ser concedido, permitido, autorizado ou delegado sem acessibilidade plena, para não obstaculizar o exercício pleno dos direitos pelas pessoas com deficiência. A acessibilidade é um direito de todos os cidadãos e, por isso, não se limita a propiciar a inclusão de pessoas com deficiência, mas também de pessoas com mobilidade reduzida, idosos, gestantes e em situação vulnerável.

OLIVEIRA, S. M. de. Cidade e acessibilidade: inclusão social das pessoas com deficiências. In: VIII Simpósio Iberoamericano em comércio internacional, desenvolvimento e integração regional, 2017 (adaptado).

Considerando a imagem e as informações apresentadas, avalie as afirmações a seguir.

I. Projetar e adaptar as vias públicas facilita a circulação das pessoas com dificuldade de locomoção e usuários de cadeiras de rodas, sendo uma medida adequada de acessibilidade.
II. Padronizar as calçadas com implantação universal de rampas, faixas de circulação livres de barreiras, guias e pisos antiderrapantes atende ao princípio da acessibilidade.
III. Garantir a ajuda de terceiros a pessoas com deficiências, nos edifícios públicos e em espaços abertos públicos, é uma previsão legal convergente ao princípio da acessibilidade.
IV. Implantar sinalização sonora nos semáforos e informações em braille nas sinalizações dos espaços urbanos para pessoas com deficiência visual são providências de acessibilidade adequadas.

É correto o que se afirma em', null,
   'III, apenas.', 'I e IV, apenas.', 'II e III, apenas.', 'I, II e IV, apenas.', 'I, II, III e IV.', 1, 'ENADE 2019 — Formação Geral, Questão 07 (INEP)'),
  ('049e249f-4cd8-5242-b2b5-1b8c645f9302', 'FG', array['ALL']::public.curso_alvo[], 'Saúde do trabalhador', 'OBJETIVA', 'O esgotamento profissional, conhecido como Síndrome de Burnout, foi incluído na Classificação Internacional de Doenças da Organização Mundial da Saúde (OMS). Essa síndrome, que foi incluída no capítulo de problemas associados ao emprego ou ao desemprego, foi descrita como uma síndrome resultante de um estresse crônico no trabalho não administrado com êxito e caracterizado por três elementos: sensação de esgotamento, cinismo ou sentimentos negativos relacionados a seu trabalho e eficácia profissional reduzida. A nova classificação, publicada em 2018 e aprovada durante a 72ª Assembleia Mundial da OMS, entrará em vigor no dia 1º de janeiro de 2022. A Classificação Internacional de Doenças da OMS estabelece uma linguagem comum que facilita o intercâmbio de informações entre os profissionais da área da saúde ao redor do planeta.

Disponível em: <https://noticias.uol.com.br/ultimas-noticias/afp/2019/05/27/oms-inclui-a-sindrome-de-burnout-na-lista-de-doencas.htm>. Acesso em: 06 jul. 2019 (adaptado).', null, 'Considerando as informações apresentadas, avalie as afirmações a seguir.

I. Os programas de formação de lideranças focados na obstinação e na resistência ao erro têm sido eficazes na redução da vulnerabilidade a esse tipo de síndrome.
II. A compreensão dos sintomas de forma isolada do contexto sociocultural dificulta o estabelecimento do chamado nexo causal entre trabalho e adoecimento.
III. As relações de trabalho onde predominam o sentido de realização profissional tendem a reforçar elos de coesão e reconhecimento social favoráveis à saúde psíquica.
IV. A prevalência do protocolo clínico pautado no tratamento medicamentoso é condição determinante para a superação desse problema de saúde pública.

É correto o que se afirma em', null,
   'I, apenas.', 'II e III, apenas.', 'III e IV, apenas.', 'I, II e IV, apenas.', 'I, II, III e IV.', 2, 'ENADE 2019 — Formação Geral, Questão 08 (INEP)'),
  ('9a9c3f25-12c1-5e2a-945f-505c88436b45', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Segurança do trabalho (NR 15)', 'DISCURSIVA', 'A parada de um carro no box, durante uma prova da Fórmula Indy (competição de corrida de automóveis monopostos que acontece na América do Norte), é ilustrada na figura a seguir. Essa operação envolve o trabalho de 11 mecânicos, dos quais apenas 6 atuam diretamente no carro para trocar pneus, ajustar a asa dianteira e reabastecê-lo com cerca de 70 litros de combustível E85R (à base de etanol e gasolina), atividades que ocorrem em pouco menos de 10 segundos.', 'enade2019/mec/mec19-d3.png', 'Sabe-se que, em corridas, o trabalho do mecânico durante a parada de um carro no box é considerado uma operação perigosa e, de acordo com a NR 15, insalubre.

Considerando esse contexto, descreva quatro condições insalubres às quais os mecânicos estão expostos, segundo a NR 15, e especifique, para cada uma, pelo menos um Equipamento de Proteção Individual (EPI) necessário para mitigá-las. (valor: 10,0 pontos)', null,
   null, null, null, null, null, 1, 'ENADE 2019 — Engenharia Mecânica, Questão Discursiva 3 (INEP)'),
  ('99d16d90-20c1-577f-a937-bd808b582de7', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Termodinâmica (ciclo Rankine)', 'DISCURSIVA', 'Uma central termelétrica opera segundo um ciclo de Rankine ideal, conforme apresentado na figura a seguir. O fluido de trabalho é a água e a potência gerada pela turbina a vapor é utilizada para acionar um gerador de energia elétrica. A vazão mássica no estado 1 corresponde a 180 t/h (toneladas por hora).', 'enade2019/mec/mec19-d5.png', 'Com base nos dados apresentados, faça o que se pede nos itens a seguir.

a) Assumindo que a caldeira e o condensador operam isobaricamente e que a turbina a vapor e a bomba são isentrópicas, faça um esboço do diagrama T–s (temperatura por entropia específica) do ciclo mostrado na figura. (valor: 3,0 pontos)

b) Calcule o rendimento térmico do ciclo de Rankine, apresentando o resultado em termos percentuais. (valor: 4,0 pontos)

c) Considerando que o rendimento global do gerador de energia elétrica acoplado à turbina a vapor seja igual a 80%, determine a potência elétrica gerada pelo ciclo em MW. (valor: 3,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2019 — Engenharia Mecânica, Questão Discursiva 5 (INEP)'),
  ('860267d7-9af8-56f6-901a-b0476303b978', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Diagramas de fases', 'OBJETIVA', 'As diretivas de restrições para uso de certas substâncias perigosas provocaram o desenvolvimento de ligas de soldagem de componentes eletrônicos que não contivessem chumbo (Pb) em sua composição, como, por exemplo, a liga de estanho (Sn) e de bismuto (Bi), cujo diagrama de fases é apresentado a seguir. Considere que esses materiais apresentam, entre outras características, temperatura de fusão relativamente baixa.', 'enade2019/mec/mec19-q10.png', 'Com base nas informações e no diagrama apresentados, a composição mássica da liga Sn-Bi mais adequada para a soldagem de componentes eletrônicos é de', null,
   '100% de Sn e 0% de Bi.', '79% de Sn e 21% de Bi.', '60% de Sn e 40% de Bi.', '43% de Sn e 57% de Bi.', '0% de Sn e 100% de Bi.', 1, 'ENADE 2019 — Engenharia Mecânica, Questão 10 (INEP)'),
  ('eac03f9c-42ed-5fcd-ae64-1173905f114f', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Metrologia', 'OBJETIVA', 'Considere a figura a seguir, em que se apresenta a leitura de um micrômetro com escala métrica, no qual cada rotação do fuso representa 0,5 mm de movimento linear; conectado a esse fuso, é colocado um colar (tambor) com 50 divisões.', 'enade2019/mec/mec19-q11.png', 'Com base nas informações e no micrômetro representado na figura, assinale a opção correta.', null,
   'A resolução desse instrumento de medida é igual a 0,01 mm.', 'O deslocamento do colar nesse instrumento é superior a 14 mm na escala fixa.', 'A parte da medida do micrômetro atribuída à leitura da escala do tambor é igual a 0,039 mm.', 'A escala do nônio amplia em 1 000 vezes a precisão de um micrômetro similar que possui apenas escala fixa e a escala do tambor.', 'Os comprimentos lineares que exijam tolerâncias de milésimos de milímetro são medidos adequadamente por esse instrumento.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 11 (INEP)'),
  ('d5a1a31e-01d7-5aac-a647-7c5da23ca543', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Energia eólica', 'OBJETIVA', 'A energia eólica, abundante, renovável, limpa e disponível em muitos lugares, é produzida por meio de aerogeradores, nos quais a força do vento é captada por pás de uma turbina que aciona um gerador elétrico. A quantidade de energia convertida é função da densidade do ar, da área coberta pela rotação das pás e da velocidade do vento. Para que a energia eólica seja considerada tecnicamente aproveitável, é necessário que sua densidade de potência seja maior ou igual a 500 W/m² a uma altura de 50 m, o que requer uma velocidade mínima do vento de 7 a 8 m/s ao nível do solo.

Disponível em: <http://www.brasilengenharia.com>. Acesso em: 14 jun. 2019 (adaptado).', null, 'A partir dessas informações e considerando que a densidade de potência disponível no vento seja dada pela equação DP = (1/2)pV³, em que p = 1,23 kg/m³ é a densidade do ar, e V é a velocidade do vento na altura das pás, avalie as afirmações a seguir.

I. Com uma velocidade do vento na altura das pás de 7 m/s, a energia eólica gerada será considerada tecnicamente aproveitável.
II. A densidade de potência eólica será reduzida nos aerogeradores se eles estiverem a uma altura superior a 50 m.
III. A potência disponível será maior se houver aumento da área coberta pela rotação das pás.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 12 (INEP)'),
  ('5e26a161-21f5-5b0d-881a-323e232206af', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Transferência de calor', 'OBJETIVA', 'Uma equipe de trabalho decide adquirir uma garrafa térmica para armazenar seu café ao longo do dia e seus membros precisam entrar em acordo quanto ao modelo de garrafa a ser escolhido. Para tanto, depois de uma pesquisa, um deles adquiriu uma garrafa cujo folheto de instruções apresentava a imagem e as características conforme figura a seguir.', 'enade2019/mec/mec19-q13.png', 'Considerando as informações apresentadas e com relação às características da garrafa térmica selecionada, avalie as afirmações a seguir.

I. O material isolante térmico da tampa e do apoio é essencial para aumentar a resistência térmica de condução e convecção.
II. O vácuo é necessário para reduzir a troca de calor por condução e convecção entre o café e o ambiente externo.
III. As superfícies espelhadas possuem a função de inibir a troca de calor por radiação.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 1, 'ENADE 2019 — Engenharia Mecânica, Questão 13 (INEP)'),
  ('22d8085c-2c51-529a-901b-ce5ca08b40fb', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Resistência dos materiais', 'OBJETIVA', 'Suponha o projeto do chassi de um caminhão constituído por duas vigas prismáticas, longitudinais, biapoiadas sobre dois eixos transversais que servirá para transportar uma carga de 7,2 toneladas uniformemente distribuída na carroceria, em que se desconsidera o peso da cabine. Sabe-se que o carregamento é igualmente distribuído entre as vigas, que a distância entre os eixos é de 7 metros e que a seção transversal de cada viga é retangular, com 100 mm de largura e 300 mm de altura (Considere g = 10 m/s²).', null, 'Nessa situação, o momento fletor máximo em cada viga e a tensão normal associada são, respectivamente,', null,
   '31,5 kN.m e 21 MPa.', '31,5 kN.m e 189 MPa.', '31,5 N.m e 21 kPa.', '63,0 kN.m e 42 MPa.', '63,0 N.m e 189 kPa.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 14 (INEP)'),
  ('328b9d17-f813-5b85-a424-a715cd80ec58', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Simulação numérica (CFD)', 'OBJETIVA', 'A simulação numérica do movimento de um fluido é realizada utilizando-se as equações de conservação de massa, energia, quantidade de movimento, entre outras.

Considere um estudo que utiliza simulação computacional para analisar o escoamento de um fluido ao redor de um automóvel.', null, 'Nesse contexto, pode-se afirmar que, em regime', null,
   'transiente, com incremento grande de tempo, é possível capturar oscilações de alta frequência.', 'permanente, com incremento variado de tempo, é possível capturar oscilações de todas as faixas de frequência.', 'permanente, com incremento pequeno de tempo, é possível capturar oscilações de alta frequência.', 'permanente, com incremento grande de tempo, é possível capturar oscilações de baixa frequência.', 'transiente, com incremento pequeno de tempo, é possível capturar oscilações de alta frequência.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 15 (INEP)'),
  ('c9de0e09-db95-5c9e-9c7d-b8ff80e75ede', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Estática', 'OBJETIVA', 'Considere a figura a seguir que ilustra um mesmo corpo rígido sujeito a forças e momentos em duas situações (a) e (b).', 'enade2019/mec/mec19-q16.png', 'Com base nas informações apresentadas, avalie as asserções a seguir e a relação proposta entre elas.

I. Se a força Fr for igual à somatória vetorial F1 + F2 + F3 + F4 e M_RO for igual à somatória vetorial M1 + M2 adicionada aos momentos das forças F1, F2, F3 e F4 em relação ao ponto O, os sistemas (a) e (b) serão considerados equivalentes.

PORQUE

II. O momento das forças depende da escolha do ponto de referência.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 16 (INEP)'),
  ('59e430a7-d747-5ab0-a013-666528de9388', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Vibrações mecânicas', 'OBJETIVA', 'A modelagem adequada de sistemas mecânicos é de fundamental importância para que as respostas das simulações computacionais sejam condizentes com as respostas dos sistemas físicos. Na figura a seguir, m é a massa; k₁, k₂ e k₃ são os coeficientes de rigidez; e c₁, c₂ e c₃ são os coeficientes de amortecimento. Considere k₁ = k₂ = k₃ = k e c₁ = c₂ = c₃ = c.', 'enade2019/mec/mec19-q17.png', 'A partir das informações apresentadas no texto e na figura, avalie as afirmações a seguir.

I. Considerando-se que o deslocamento da massa m em função do tempo seja x, o modelo matemático utilizado em uma simulação computacional será mẍ + (3c)ẋ + (3k / 2)x = 0.
II. A frequência angular natural do sistema é ω_n = √((3k) / m)
III. Caso o sistema da figura seja excitado com uma frequência igual à natural, a amplitude tende para o infinito com quaisquer valores de k₁, k₂, k₃, c₁, c₂ e c₃.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e II apenas.', 'I e III apenas.', 'I, II e III.', 3, 'ENADE 2019 — Engenharia Mecânica, Questão 17 (INEP)'),
  ('114cf68e-db11-534d-ae33-f0b400915e79', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Combustão e meio ambiente', 'OBJETIVA', 'Os combustíveis fósseis, particularmente os derivados de petróleo, têm larga aplicação na sociedade moderna, sendo utilizados para a alimentação de motores a combustão interna de veículos, de queimadores a gás e de fornos industriais. De sua queima, resulta o fenômeno conhecido como chuva ácida, que se caracteriza pelo reduzido valor do seu pH (< 4,5) e tem como principais consequências a alteração química das águas dos rios e lagos, a degradação de monumentos históricos construídos a partir de carbonatos (mármore) e o comprometimento da vida útil de estruturas metálicas e de equipamentos.', null, 'Nesse contexto, é correto afirmar que, a partir da combustão do óleo combustível derivado de petróleo, favorecem a ocorrência da chuva ácida os gases', null,
   'CO₂ e N₂.', 'C₂H₅ e N₂.', 'SO₂ e CH₄.', 'CO₂ e SO₂.', 'CH₄ e O₂.', 1, 'ENADE 2019 — Engenharia Mecânica, Questão 18 (INEP)'),
  ('30d1dcf5-fc71-58cb-8b44-17bb4af5704a', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Impactos ambientais', 'OBJETIVA', 'Em relação aos impactos ambientais decorrentes do funcionamento de barragens de rejeito, sabe-se que a alteração

• da paisagem está relacionada, atualmente, à presença da barragem desativada, que, devido à praia de rejeito e à vegetação com baixa densidade, continua causando impacto visual;
• do metabolismo vegetal, devido à deposição de material particulado na superfície das folhas, assim como nas demais fases desse processo, é um impacto negativo e indireto, consequência da alteração da qualidade do ar;
• na dinâmica de ecossistemas aquáticos pode ser considerada um impacto indireto da alteração tanto da qualidade da água quanto da alteração da dinâmica hídrica superficial;
• da dinâmica hídrica superficial e subterrânea é um impacto que persiste desde a construção da barragem, uma vez que esta modifica permanentemente o regime de escoamento superficial de água, podendo afetar negativamente a vazão dos cursos d''água a jusante e a recarga de aquíferos;
• da qualidade do ar e da qualidade da água ocorre já na fase de construção da barragem e permanece devido à presença das praias de rejeito.

ANDRADE, L. C. R. Barragens de rejeitos da mineração de ferro: panorama geral brasileiro e avaliação de impactos associados. Revista de Ciências Exatas e Tecnologia. v. 13, n. 13, 2018 (adaptado).', null, 'Com base no texto, é correto afirmar que os impactos ambientais descritos afetam, respectivamente, os meios', null,
   'físico, biológico, biológico, físico e físico.', 'biológico, biológico, físico, físico e físico.', 'físico, físico, biológico, biológico e físico.', 'físico, biológico, físico, biológico e físico.', 'biológico, físico, físico, físico e biológico.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 19 (INEP)'),
  ('8b5c94ba-801b-58b9-b3dd-57f2ad7759f8', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Trocadores de calor', 'OBJETIVA', 'Um trocador de calor é utilizado para aquecer a água de uma linha industrial por meio do aproveitamento da energia do gás de exaustão de uma central termelétrica, conforme ilustrado na figura a seguir. O gás de exaustão entra pela seção (1) a 150 ºC e sai pela seção (2) a 50 ºC, a uma vazão de 2,1 kg/s. Um sistema de bombeamento promove a passagem da água pelo tubo (3 – 4) a uma vazão de 0,8 kg/s. A temperatura de entrada da água na seção (3) é de 25 ºC. Em virtude das ineficiências deste equipamento, apenas 80% do calor disponibilizado internamente pelo gás de exaustão é aproveitado pela água no processo de aquecimento.', 'enade2019/mec/mec19-q20.png', 'Nessa situação, considerando-se que o gás de exaustão pode ser modelado como um gás ideal, com calor específico, à pressão constante, de 1,1 kJ/(kg ºC) e que o calor específico da água seja de 4,2 kJ/(kg ºC), qual a temperatura da água na saída do equipamento?', null,
   '55,0 ºC.', '68,8 ºC.', '80,0 ºC.', '93,8 ºC.', '125,0 ºC.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 20 (INEP)'),
  ('1bcfab70-6a28-5904-9141-433e4b74ff10', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Fadiga e critérios de falha', 'OBJETIVA', 'No gráfico a seguir, que mostra um diagrama de tensão média versus tensão alternada com os envelopes dos principais critérios de falha para carregamento flutuante, observam-se as seguintes grandezas:

• S_y = resistência ao escoamento;
• S_ut = resistência última à tração;
• S_a = resistência alternante;
• S_m = resistência média;
• S_e = limite de resistência à fadiga corrigido.', 'enade2019/mec/mec19-q22.png', 'Considere o dimensionamento de um eixo de transmissão de máquina-ferramenta sujeito a flexo-torção com fadiga de alto ciclo.

Nessa situação, para um projeto seguro e otimizado, com vistas à maior relação potência/peso possível, deve-se utilizar o critério', null,
   'de Langer de escoamento.', 'de Goodman modificado.', 'da ASME elíptico.', 'de Gerber.', 'de Soderberg.', 3, 'ENADE 2019 — Engenharia Mecânica, Questão 22 (INEP)'),
  ('a9824830-d85f-5363-9982-2e55f7a69c74', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Metrologia e estatística', 'OBJETIVA', 'Suponha que quatro robôs A, B, C e D tenham sido testados para realizar uma tarefa de medição de peças, que a diferença entre a medida real da peça e a encontrada por cada robô é μ, e que as distribuições normais dessas diferenças são apresentadas na figura a seguir.', 'enade2019/mec/mec19-q23.png', 'Com base nas informações apresentadas, avalie as asserções a seguir e a relação proposta entre elas.

I. O robô D não deve ser utilizado para realizar a tarefa de medição.
PORQUE
II. O desvio padrão do robô D é maior que o desvio padrão do robô B.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 23 (INEP)'),
  ('1e3132a8-8d6d-50e2-9269-c82f89302b22', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Vibrações mecânicas', 'OBJETIVA', 'Ao se projetar sistemas vibratórios, devem ser considerados vários aspectos, principalmente os relacionados às massas e aos coeficientes de rigidez, pois tais parâmetros influenciam diretamente nas frequências naturais desses sistemas.

Na figura a seguir, representa-se a resposta no tempo de um sistema vibratório com um grau de liberdade.', 'enade2019/mec/mec19-q24.png', 'A partir das informações apresentadas no texto e na figura, avalie as afirmações a seguir.

I. O amortecimento existente faz com que a frequência natural do sistema diminua com o tempo.
II. Se a massa diminuir quatro vezes o seu valor, a frequência natural do sistema aumentará duas vezes.
III. O sistema está em regime permanente, com frequência de excitação de 5 Hz.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 24 (INEP)'),
  ('74edfa3d-af1d-562d-ac8d-396bdce649fe', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Ciência dos materiais', 'OBJETIVA', 'A tenacidade nos materiais metálicos, cerâmicos e em alguns polímeros é influenciada pela temperatura de trabalho, portanto, existe um valor de temperatura (ou um intervalo de temperatura) acima do qual o comportamento do material é predominantemente dúctil e abaixo do qual é predominantemente frágil. Essa temperatura é definida como temperatura de transição dúctil-frágil. Para fins de projeto, o conhecimento da temperatura de transição é essencial, pois a partir dela pode-se planejar as condições de serviço de forma a não ocorrer fratura frágil do componente projetado. Essa temperatura é determinada durante ensaios de impacto. A figura a seguir ilustra os resultados de ensaios de impacto realizados em alguns metais.', 'enade2019/mec/mec19-q25.png', 'Considerando as informações e os dados apresentados, avalie as asserções a seguir e a relação proposta entre elas.

I. Os materiais com estrutura CCC apresentam uma transição dúctil-frágil nítida com a redução da temperatura.
PORQUE
II. As estruturas CCC possuem como característica a presença de muitos planos de escorregamento disponíveis.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II, é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II, é uma proposição verdadeira.', 'As asserções I e II é são proposições falsas.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 25 (INEP)'),
  ('c0e4923e-f5b5-5540-8a31-6d1f2e1ccb21', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Máquinas de fluxo', 'OBJETIVA', 'Usinas hidrelétricas podem ser consideradas uma fonte limpa para a produção de energia elétrica, porém, causam impacto ambiental devido à necessidade de construção de grandes reservatórios de água. Uma forma de minimizar o impacto ambiental é selecionar corretamente o tipo de equipamento a partir da altura da queda de água e da vazão disponível no local de instalação. Um dos parâmetros iniciais utilizados para a seleção de uma turbina é a velocidade específica. O gráfico a seguir mostra valores típicos da velocidade específica para diferentes tipos de turbina, relacionando-os à altura de queda disponível.', 'enade2019/mec/mec19-q26.png', 'Considerando as informações apresentadas, avalie as afirmações a seguir.

I. Conhecendo-se a altura de queda e a vazão, pode-se determinar a eficiência energética máxima da turbina.
II. Conhecendo-se a velocidade específica, calcula-se a rotação de trabalho esperada da turbina para uma determinada altura de queda e vazão.
III. Sabendo-se a velocidade específica, seleciona-se a turbina para que esta funcione próxima ao ponto de eficiência máxima.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 26 (INEP)'),
  ('80adb5c1-21fc-5daa-83d8-77369fef93c3', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Transferência de calor', 'OBJETIVA', 'Uma casa com paredes de concreto recebe uma camada de isolamento térmico em seu exterior para manter o ambiente interno aquecido, sendo a madeira o material isolante.

A figura representa o corte de uma parede da casa, com as respectivas dimensões e temperaturas.', 'enade2019/mec/mec19-q27.png', 'Considere a seguinte equação, que representa a taxa de transferência de calor trocado por convecção entre a superfície externa da camada isolante e o meio externo:

Q̇_c = hA(T_pe − T_exterior)

em que h é o coeficiente de troca de calor por convecção, A é a área de troca de calor, T_pe é a temperatura da superfície externa da camada de madeira e T_exterior é a temperatura do meio externo.

Considere ainda a seguinte equação, que representa a taxa de transferência de calor devido à condução na parede:

Q̇_p = (T_pi − T_pe) / (L_c/(k_c·A) + L_iso/(k_iso·A))

em que T_pi é a temperatura da superfície interna da parede de concreto; L_c e L_iso são, respectivamente, as espessuras do concreto e do isolante (madeira), e k_c e k_iso são as condutividades térmicas do concreto e do isolante, respectivamente.

Nessa situação, sabendo-se que as condutividades térmicas do concreto e da madeira são, respectivamente, iguais a 2 W/(m.K) e 0,08 W/(m.K), que o coeficiente de troca de calor por convecção no meio externo é de 4 W/(m².K) e que a área da parede é de 2 m², é correto afirmar que a temperatura da superfície interna da parede de concreto (T_pi) é de', null,
   '18,0 °C.', '18,8 °C.', '19,6 °C.', '20,4 °C.', '21,2 °C.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 27 (INEP)'),
  ('335d8ab6-03e6-5f21-8352-3aca66d9b896', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Instrumentação industrial', 'OBJETIVA', 'Nos últimos anos, o controle das estações de tratamento de água e esgoto passou a ser obrigatório, pois contribui tanto para o aumento da sua produtividade (maior eficiência) quanto para a redução do volume dos rejeitos produzidos, específicos para cada tipo de processo. Para tal controle, é necessária a utilização de diversos tipos de sensores, especificamente adequados à grandeza a ser monitorada.', null, 'Os tipos de sensores que permitem a realização de medições das grandezas pressão, temperatura, vazão e nível são, respectivamente,', null,
   'diafragma, bimetal, placa de orifício e flutuador.', 'magnético, termopar, radar e flutuador.', 'bourdon, capacitivo, ultrassom e turbina.', 'diafragma, termopar, radar e placa de orifício.', 'bourdon, capacitivo, placa de orifício e turbina.', 1, 'ENADE 2019 — Engenharia Mecânica, Questão 29 (INEP)'),
  ('79ae22b0-91f4-5f26-941c-37483c1812b0', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Manutenção preditiva', 'OBJETIVA', 'O monitoramento, o acompanhamento e a inspeção de equipamentos e sistemas em pleno funcionamento de forma contínua compõem a chamada manutenção preditiva, que permite determinar o tempo adequado para a realização de intervenção de reparo ou substituição. Esse procedimento leva à redução das ações da denominada manutenção corretiva, diminuindo a necessidade de paradas nas atividades e garantindo a confiabilidade dos equipamentos.', null, 'Considerando-se esse tema, as duas técnicas de inspeção usualmente aplicadas na manutenção preditiva de vasos de pressão são', null,
   'técnica de ultrassom e técnica de aplicação de partícula magnética.', 'técnica de ultrassom e técnica de termografia infravermelha.', 'técnica de medição de espessura e técnica de aplicação de líquido penetrante.', 'técnica de medição de espessura e técnica de aplicação de partícula magnética.', 'técnica de termografia infravermelha e técnica de aplicação de líquido penetrante.', 1, 'ENADE 2019 — Engenharia Mecânica, Questão 30 (INEP)'),
  ('05e5138c-206f-5680-a1e6-d946b81668de', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Automação e CLP', 'OBJETIVA', 'O CLP, ou controlador lógico programável, é um suporte eletrônico digital que armazena instruções de funções específicas, como lógica, sequenciamento, temporização, contagem e aritmética, para controlar, por meio de módulos de entradas e saídas, vários tipos de máquinas ou processos. Esse dispositivo opera com variáveis de entrada (sinais externos) e variáveis de saída (dispositivos controlados), que podem ser programados pela linguagem de programação Ladder. Essa linguagem é a mais utilizada por ser a forma mais clara para se apresentar uma lógica de controle semelhante aos diagramas de portas digitais, como ilustra a figura a seguir. Sabe-se, ainda, que, no CLP, o contato pode ser normalmente aberto (NA) ou normalmente fechado (NF) e que o principal componente de saída é a bobina.', 'enade2019/mec/mec19-q31.png', 'Considerando essas informações e o diagrama de programação Ladder apresentado na figura, avalie as asserções a seguir e a relação proposta entre elas.

I. A saída Q1 estará acionada se as entradas I1 e I2 estiverem acionadas.
PORQUE
II. A saída Q2 não estará acionada se a entrada I4 estiver acionada.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 31 (INEP)'),
  ('3f070f23-313e-5a77-922a-1e1e016e554d', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Planejamento da capacidade', 'OBJETIVA', 'Na gestão da capacidade de produção de uma empresa há três estratégias disponíveis para lidar com variações de demanda do mercado:

• manter o nível de produção constante o ano todo;
• ajustar a capacidade para atender, da maneira mais próxima possível, à demanda;
• tentar mudar a demanda visando ajustá-la à capacidade.

SLACK, S.; SLACK, J.; Administração da produção. 2. ed., São Paulo: Atlas, 2008 (adaptado).', null, 'Com relação ao planejamento da capacidade de produção de uma empresa, avalie as afirmações a seguir.

I. A política de capacidade de produção constante deve prever a formação de estoques nos períodos de baixa demanda visando ao seu atendimento nos períodos em que ela esteja acima da capacidade.
II. A política de ajuste da demanda é uma estratégia muito utilizada por setores como o da aviação civil, que ajusta os preços das passagens de acordo com a taxa de ocupação dos voos e a proximidade das viagens.
III. Mesclando-se as três estratégias mencionadas, busca-se melhorar o desempenho de produtividade e o faturamento da empresa, sem deixar de atender à demanda.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 1, 'ENADE 2019 — Engenharia Mecânica, Questão 32 (INEP)'),
  ('ee1940ce-69f8-5e31-af1a-427af041361d', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Circuitos elétricos', 'OBJETIVA', 'A figura a seguir representa um circuito elétrico contendo um gerador ideal (G) de tensão 9 V, três lâmpadas idênticas (L1, L2 e L3) de resistências elétricas de 30 Ω cada uma, um amperímetro ideal (A), um voltímetro ideal (V) e dois interruptores ideais (S1 e S2).', 'enade2019/mec/mec19-q33.png', 'Com base no circuito elétrico apresentado, avalie as afirmações a seguir.

I. Com o interruptor S1 fechado e o S2 aberto, apenas duas lâmpadas acendem.
II. Com ambos os interruptores fechados, o brilho da lâmpada L1 aumenta se comparado à situação em que S1 esteja fechado e S2 esteja aberto.
III. Com ambos os interruptores fechados, a intensidade de corrente elétrica medida pelo amperímetro será de 0,15 A.
IV. Com ambos os interruptores fechados, a diferença de potencial na lâmpada L3 será de 3 V.

É correto apenas o que se afirma em', null,
   'I e III.', 'I e IV.', 'II e III.', 'I, II e IV.', 'II, III e IV.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 33 (INEP)'),
  ('50c098f2-615b-5e20-ab98-69d008934644', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Desenvolvimento de produto', 'OBJETIVA', 'Considere o gráfico a seguir, que representa o grau de comprometimento da definição dos custos de um produto com relação às etapas do seu desenvolvimento.', 'enade2019/mec/mec19-q34.png', 'Com base no gráfico apresentado, avalie as asserções a seguir e a relação proposta entre elas.

I. A definição dos componentes a serem fabricados e os respectivos processos de fabricação estabelecem as exigências de capacidade produtiva, bem como a qualidade necessária aos mesmos.
PORQUE
II. A fase inicial do desenvolvimento de um produto é uma fase crítica com relação às decisões de projeto que implicam no comprometimento dos gastos em todas as etapas do ciclo de vida do produto.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 1, 'ENADE 2019 — Engenharia Mecânica, Questão 34 (INEP)'),
  ('3abee0af-eecc-5bff-bb1c-1c3c9609c747', 'CE', array['ENG_MEC']::public.curso_alvo[], 'Elementos de máquinas', 'OBJETIVA', 'Os trens de engrenagens compostos se caracterizam por possuírem duas engrenagens no mesmo eixo e, consequentemente, com a mesma rotação. A relação de transmissão entre a rotação de saída e a de entrada em um par de engrenagens em contato não deve exceder 10:1. Para um ângulo de pressão de 25°, o número mínimo de dentes que o pinhão deve conter, para se evitar o fenômeno indesejável de interferência, é 12.', null, 'Considerando as informações apresentadas e a teoria de engrenamento, assinale a opção que representa corretamente o menor número de dentes das engrenagens de um trem composto por dois estágios, com uma redução de 28:1, em que N_2 representa o número de dentes do pinhão de entrada.', null,
   'N_2 = 12 e N_3 = 336.', 'N_2 = 12, N_3 = 84 e N_4 = 336.', 'N_2 = 12, N_3 = 48, N_4 = 12 e N_5 = 84.', 'N_2 = 12, N_3 = 42, N_4 = 15 e N_5 = 150.', 'N_2 = 12, N_3 = 72 e N_4 = 336.', 2, 'ENADE 2019 — Engenharia Mecânica, Questão 35 (INEP)'),
  ('692c6a0c-f132-5daa-a0aa-4e146f7749f3', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Sistemas ERP', 'DISCURSIVA', 'Uma empresa de distribuição de material de construção, com 350 funcionários e atuação no âmbito nacional, chega a entregar para sua rede de clientes, na maioria, lojas de material de construção de pequeno e médio porte, mais de 4 mil itens. Todo o controle das atividades organizacionais dessa empresa vinha sendo feito por meio de planilhas, entretanto, o novo diretor decidiu pela implantação de um sistema integrado de gestão (ERP), com vistas ao alinhamento de todos os dados, antes inseridos nessas planilhas, dentro de um sistema único.

Muitos insumos financeiros e de capital humano foram empregados na implantação do ERP, mas, oito meses depois do início do processo de implantação, nenhum resultado concreto foi colhido, do ponto de vista dos trabalhadores da empresa. Um dos supervisores de logística fez a seguinte avaliação: “Parece que tudo piorou, queremos voltar às nossas planilhas, mais simples e mais bem controladas”.', null, 'Considerando essa situação, faça o que se pede nos itens a seguir.

a) Cite uma possível desvantagem da implantação do ERP na referida empresa e justifique sua resposta. (valor: 5,0 pontos)
b) Cite uma vantagem da correta implantação do ERP na referida empresa e justifique sua resposta. (valor: 5,0 pontos)', null,
   null, null, null, null, null, 1, 'ENADE 2019 — Engenharia de Produção, Questão Discursiva 3 (INEP)'),
  ('1f594c6f-6f13-52c9-b689-38f0e2fe7260', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Logística reversa e PNRS', 'DISCURSIVA', 'Um programa de logística reversa, realizado no âmbito da Política Nacional de Resíduos Sólidos (PNRS), Lei n. 12.305 de 2 de agosto de 2010, instalou máquinas em estações de metrô de uma grande metrópole brasileira para coletar latas de alumínio, embalagens longa-vida, garrafas PET e de vidro descartadas. As pessoas que entregam esses materiais recicláveis na estação recebem benefícios, como descontos no transporte público, na fatura de energia elétrica e na recarga de telefones celulares pré-pagos.

Disponível em: <https://www1.folha.uol.com.br/empreendedorsocial/2019/06/empresa-coleta-5-milhoes-de-embalagens-com-programa-de-beneficios.shtml>. Acesso em: 16 jun. 2019 (adaptado).', null, 'Considerando esse contexto, faça o que se pede nos itens a seguir.

a) Com base no princípio da responsabilidade compartilhada adotado na PNRS, cite três atores das cadeias produtivas de um dos materiais mencionados no texto e descreva suas responsabilidades com relação ao meio ambiente nos processos que envolvem esse material. (valor: 5,0 pontos)
b) Descreva três impactos ambientais causados pela disposição inadequada de um desses materiais. (valor: 5,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2019 — Engenharia de Produção, Questão Discursiva 4 (INEP)'),
  ('a5ec299f-3494-5fed-a874-b3a78316ec64', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Custos e ponto de equilíbrio', 'DISCURSIVA', 'O ponto de equilíbrio de uma empresa é o volume de vendas que cobre os custos fixos dos recursos comprometidos em determinado período. A empresa começa a obter lucro quando as vendas superam o ponto de equilíbrio.

A partir dessas informações, considere a seguinte situação.

O custo total de uma empresa para produção de determinada quantidade do produto X é de R$ 900.000,00 por mês. Sabe-se que o custo total mensal da empresa é composto pelo custo fixo de R$ 200.000,00 e pelo custo variável de R$ 50,00 por unidade produzida, e que o preço de venda desse produto é de R$ 70,00 por unidade.', null, 'Com base nessa situação, faça o que se pede nos itens a seguir.

a) Calcule a quantidade do produto X produzida pela empresa por mês. (valor: 5,0 pontos)
b) Calcule a quantidade do produto X que a empresa deve produzir e vender por mês para que alcance seu ponto de equilíbrio. (valor: 5,0 pontos)', null,
   null, null, null, null, null, 1, 'ENADE 2019 — Engenharia de Produção, Questão Discursiva 5 (INEP)'),
  ('0aaad1cb-885d-515b-950b-16a07a43db3e', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Desenvolvimento de produtos', 'OBJETIVA', 'Novos produtos chegam ao mercado desenvolvidos a partir de novas ideias, materiais e tecnologias. Empreendedores, em busca de oportunidades, acompanham as inovações. Paralelamente, surgem formas inovadoras de desenvolvimento do produto e da produção. Alguns produtos, antes confeccionados somente pela subtração de materiais, passaram a ser produzidos com manufatura aditiva. Termos como Internet das Coisas e Design Thinking tornaram-se expressões do dia a dia.', null, 'Considerando esse contexto, avalie as asserções a seguir e a relação proposta entre elas.

I. Os novos espaços de criação e desenvolvimento estão se espalhando e se tornando mais acessíveis a cada dia, o que contribui para a alavancagem dos negócios.

PORQUE

II. O desenvolvimento de produtos, que abrange as fases: ideia inicial e triagem, especificações do produto, formulação de alternativas, construção do modelo ou mock-up, construção de um protótipo e aprovação, tem sido realizado em tempos totais de ciclo cada vez mais curtos.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 09 (INEP)'),
  ('3a6e76b8-904f-5d2a-b78a-dbb5a52cf2af', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Otimização com derivadas', 'OBJETIVA', 'A gerência de produção de uma empresa fabricante de calculadoras definiu como objetivo garantir o custo mínimo de estocagem. O perfil de produção da empresa indica, por meio de dados históricos, que o custo de estoque C(x), em milhares de reais, é dado pela expressão

C(x) = (1/3)x³ − (11/2)x² + 24x + 31

para x > 0, em que x representa, em milhares, o número de calculadoras produzidas diariamente.

HOFFMANN, L. D.; BRADLEY, G. L. Cálculo: um curso moderno e suas aplicações. 11. ed., Rio de Janeiro: LTC, 2015 (adaptado).', null, 'Nesse contexto, o número de calculadoras produzidas por dia que miminiza o custo de estocagem é', null,
   '3 000.', '5 500.', '8 000.', '41 000.', '62 500.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 10 (INEP)'),
  ('64f65282-cbf5-598a-bbab-602f2cab0be3', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Simulação de filas', 'OBJETIVA', 'Em uma simulação manual de um posto bancário, os tempos (em minutos) entre as chegadas de clientes sucessivos seguem a série de números aleatórios R1 (2,5,6,2,4). Os tempos (em minutos) de atendimentos de um único caixa seguem a série de números aleatórios R2 (2,3,2,4,3). Caso o cliente chegue e encontre o caixa ocupado, ele aguarda na fila até a sua vez de ser atendido. No instante 0 de simulação, que corresponde à abertura do banco, o sistema encontra-se com um único cliente, que acabou de chegar e que está iniciando seu atendimento.', null, 'Considerando essa situação, para o período de simulação, que compreende o instante 0 até o instante 20 minutos, assinale a opção que apresenta a taxa de utilização correta do caixa.', null,
   '50%.', '60%.', '70%.', '80%.', '90%.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 11 (INEP)'),
  ('cdaeedc9-5035-51eb-b607-6c9d1bb8dd9c', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Estatística descritiva', 'OBJETIVA', 'Uma empresa de eletrônicos portáteis, interessada em traçar um perfil de seus potenciais consumidores, realizou uma pesquisa com 30 pessoas, indagando quanto cada uma delas gastou com aparelhos eletrônicos e acessórios no último mês. Os resultados obtidos foram tratados e apresentados na forma de um histograma de frequência, conforme o apresentado na figura a seguir.', 'enade2019/prod/prod19-q12.png', 'Com base nessa situação e nos dados da figura, avalie as afirmações a seguir.

I. Entre os entrevistados, a média de gastos com compra de aparelhos e acessórios eletrônicos foi superior a R$ 145,00.
II. Entre os entrevistados, 2% gastaram entre R$ 340,00 e R$ 380,00 na compra de aparelhos e acessórios eletrônicos.
III. Entre os entrevistados, 40% gastaram entre R$ 100,00 e R$ 140,00 na compra de aparelhos e acessórios eletrônicos.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 12 (INEP)'),
  ('a4109639-0e8a-52ab-baf2-7b15e9a3d132', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Inovação e desenvolvimento de produtos', 'OBJETIVA', 'A inovação diz respeito ao desenvolvimento de novas soluções que atendam aos mercados ou gerem valor para a sociedade. De modo geral, a inovação pode ser entendida como a busca de novidade de valor agregado por meio de novos produtos, serviços ou mercados, métodos de produção ou sistemas de gestão. Para auxiliar o processo de desenvolvimento de novos produtos, são aplicadas algumas ferramentas, como: QFD (Quality Function Deployment), FMEA (Failure Mode and Effect Analysis), Pugh, Design Thinking e Manufatura Aditiva.

Disponível em: <https://www.oecd-ilibrary.org/science-and-technology/oslo-manual 9789264013100-en>. Acesso em: 18 jun. 2019 (adaptado).', null, 'A partir do tema tratado no texto, avalie as afirmações a seguir.

I. O uso isolado do QFD pode gerar um produto atrativo ao cliente, porém sem confiabilidade para o exercício de todas as suas funções.
II. O modelo proposto por Pugh analisa as etapas de desenvolvimento do produto considerando os aspectos ergonômicos.
III. A primeira fase do processo de Design Thinking é chamada imersão ou empatia.
IV. A Manufatura Aditiva utiliza-se da impressão 3D para a produção customizada.

É correto apenas o que se afirma em', null,
   'I e II.', 'II e III.', 'III e IV.', 'I, II e IV.', 'I, III e IV.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 13 (INEP)'),
  ('46fd179b-afda-51c7-858c-0f6a0961f23a', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Ergonomia', 'OBJETIVA', 'A análise ergonômica busca adaptar as situações de trabalho às características psicofisiológicas dos trabalhadores. Conhecer a distância entre o trabalho prescrito (tarefa) e o trabalho real (atividade) é essencial nos projetos do trabalho, uma vez que essa distância pode gerar consequências danosas à produtividade e à saúde dos trabalhadores. No projeto do trabalho, é importante analisar a margem de manobra resultante da tarefa, os modos operatórios adotados na atividade e, consequentemente, a carga de trabalho.

GUÉRIN, F. et al. Compreender o trabalho para transformá-lo: a prática da ergonomia. São Paulo: Edgard Blucher, 2001 (adaptado).', null, 'Nesse contexto, quando se aumenta a margem de manobra,', null,
   'a carga de trabalho e os modos operatórios diminuem.', 'a carga de trabalho e os modos operatórios aumentam.', 'a carga de trabalho aumenta e os modos operatórios diminuem.', 'a carga de trabalho diminui e os modos operatórios aumentam.', 'a carga de trabalho e os modos operatórios se mantém inalterados.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 14 (INEP)'),
  ('c5b19d4e-06b5-5ca7-9d15-d074c342eab2', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Estratégia competitiva', 'OBJETIVA', 'Atualmente, as organizações estão inseridas em ambientes com mudanças contínuas e, nesse cenário, planejar estrategicamente é uma alternativa para que se mantenham competitivas no mercado. A escolha da estratégia correta é um dos grandes diferenciais em tempos de crise.

O quadro a seguir apresenta um conjunto de estratégias que podem ser utilizadas pelas organizações para alcançar uma ótima posição no mercado a longo prazo.', 'enade2019/prod/prod19-q15.png', 'PORTER, M. E. Vantagem competitiva: criando e sustentando um desempenho superior. 7 ed. Rio de Janeiro: Ed. Campus, 1986 (adaptado).

Nesse contexto, avalie as afirmações a seguir.

I. Na estratégia denominada Liderança no custo total, considera-se que a organização tem um escopo amplo e atende a muitos segmentos e que suas fontes de vantagens incluem a busca de economias de escala, tecnologia patenteada e acesso preferencial a matérias-primas.
II. Na estratégia denominada Diferenciação, a organização seleciona um ou mais atributos considerados importantes em seus segmentos-alvo, posicionando-se singularmente para satisfazer tais atributos.
III. Quando se utiliza da estratégia denominada Enfoque em custos, a organização procura uma vantagem de custo em seu segmento-alvo.
IV. Na estratégia denominada Enfoque em diferenciação, a organização procura uma vantagem de diferenciação em seu segmento-alvo.

É correto o que se afirma em', null,
   'II, apenas.', 'I e III, apenas.', 'III e IV, apenas.', 'I, II e IV, apenas.', 'I, II, III e IV.', 1, 'ENADE 2019 — Engenharia de Produção, Questão 15 (INEP)'),
  ('3690a022-f681-5592-91d4-b888b85bf463', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Segurança e saúde ocupacional', 'OBJETIVA', 'A ISO 45001:2018, norma de sistemas de gestão de segurança e saúde ocupacional, é uma ferramenta em que podem se apoiar organizações públicas e privadas, em casos de sinistros ou situações irregulares, como incêndios e desabamentos.', null, 'Considerando os requisitos dessa norma, avalie as afirmações a seguir.

I. Essa norma, além de um certificado, é, também, uma ferramenta preditiva.
II. A seção de planejamento e controle operacional da ISO 45001:2018 determina que as empresas certificadas planejem, implementem e controlem procedimentos para os riscos identificados.
III. A referida norma determina que as empresas certificadas adotem medidas de preparação e resposta a emergências.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 16 (INEP)'),
  ('d9e4cf15-722a-5030-a164-df9ee94e7005', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Planejamento da produção', 'OBJETIVA', 'A competência de uma empresa para prever cenários e planejar a produção determina a sua sobrevivência e o seu crescimento.', null, 'Considerando esse contexto, avalie as afirmações a seguir.

I. São variáveis para o cálculo da previsão da demanda de uma empresa: dados históricos de vendas e de demanda, pedidos e contratos assinados, prognóstico da força de vendas, prognóstico de especialistas e tendências de mercado.
II. São variáveis para o cálculo da capacidade de produção de uma empresa: maquinário disponível, número de funcionários e de estações de trabalho.
III. São variáveis para o cálculo dos níveis de estoque de uma empresa: informações sobre promoções e descontos e a confiabilidade dos equipamentos.

É correto o que se afirma em', null,
   'II, apenas.', 'III, apenas.', 'I e II, apenas.', 'I e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 17 (INEP)'),
  ('c26ee4c6-d3cd-5aa0-9a07-df026ac538aa', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Previsão de demanda', 'OBJETIVA', 'A tabela a seguir indica o número de pães produzidos por uma padaria em cada dia da semana.', 'enade2019/prod/prod19-q18.png', 'A previsão de produção de pães no sábado corresponde à média ponderada das quantidades de pães produzidos na sexta-feira, com peso de 0,5; na quinta-feira, com peso de 0,3; e na quarta-feira, com peso de 0,2.

Nessa situação, o número de pães produzidos no sábado está entre', null,
   '2 000 e 2 150.', '2 200 e 2 350.', '2 375 e 2 400.', '2 435 e 2 480.', '2 500 e 2 525.', 1, 'ENADE 2019 — Engenharia de Produção, Questão 18 (INEP)'),
  ('0a532afa-51e1-5b29-8ded-1676feb23b9e', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Just in Time e Kanban', 'OBJETIVA', 'O Just in Time (JIT), um dos pilares do Sistema Toyota de Produção, baseia-se no princípio do abastecimento de produtos e matérias-primas nas quantidades solicitadas e nos momentos adequados, ou seja, nada deve ser produzido, comprado ou transportado sem que seja necessário. Um importante subsistema do JIT é o Kanban.', null, 'Nesse contexto, avalie as afirmações a seguir.

I. O Kanban foi criado para controlar o nível de inventário, a produção e o fornecimento de componentes e, em alguns casos, de matéria-prima.
II. O Kanban apresenta resultados positivos quando aplicado em situações nas quais os estoques das estações de trabalho estão desbalanceados.
III. O e-Kanban é definido como uma variação do Kanban tradicional, em que os cartões são substituídos por sinais eletrônicos.
IV. O sistema Kanban funciona com sistemas produtivos puxados, ou seja, sistemas cuja ordem de produção depende do cliente, interno ou externo.

É correto apenas o que se afirma em', null,
   'I e II.', 'II e IV.', 'III e IV.', 'I, II e III.', 'I, III e IV.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 19 (INEP)'),
  ('5405c6c6-89a2-5a23-a5a5-1c867ce49279', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Capacidade e gargalos', 'OBJETIVA', 'Os vários materiais utilizados na fabricação de tijolos são extraídos e transportados até o misturador e o laminador, que deixam a mistura homogênea. Por meio de correias transportadoras, esses materiais chegam à maromba, que, em um fluxo contínuo, dá forma e corta o produto no tamanho especificado pelo cliente. Nessa etapa, os tijolos estão úmidos e ficam em uma estufa até estarem preparados para a queima no forno. Esse processo é resumido no fluxograma a seguir.', 'enade2019/prod/prod19-q20.png', 'Uma fábrica de tijolos recebeu demanda pela produção de tijolos de 5 kg e com 25 cm de comprimento. O misturador e o laminador conseguem produzir 20 000 kg de material seco por hora. A maromba trabalha em uma velocidade máxima de 10 m/min para esse tipo de tijolo. A estufa, onde os tijolos devem repousar por 4 horas, comporta 12 000 unidades desse tipo de tijolo. O forno tem capacidade de queimar 800 tijolos em 48 minutos.

Considerando as informações apresentadas, bem como a situação descrita, avalie as asserções a seguir e a relação proposta entre elas.

I. A máxima produção diária da fábrica, em um turno de 8 horas ininterruptas, é de 8 000 tijolos.

PORQUE

II. A capacidade da estufa está subdimensionada.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 3, 'ENADE 2019 — Engenharia de Produção, Questão 20 (INEP)'),
  ('cb94fb32-324a-56e8-9a6e-728d8ed19114', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Análise de investimentos', 'OBJETIVA', 'A instalação de painéis residenciais de captação de energia solar é uma opção de investimento que permite ao usuário economia na conta de energia ou até a independência das concessionárias de energia elétrica. Outra opção, mais tradicional, é a instalação de equipamentos que aquecem a água com energia solar. Esses equipamentos permitem a substituição, principalmente, dos chuveiros elétricos, uma das maiores fontes domésticas de consumo de energia elétrica.

A partir dessas informações, considere que, em uma residência, há dois chuveiros elétricos que ficam ligados duas horas por dia cada um. Esses chuveiros têm potências de 3 600 W e 4 400 W. A tarifa de consumo de energia é de R$ 0,50 por kWh, acrescida de 30% de imposto. O dono da residência, visando substituir os dois chuveiros elétricos, solicitou orçamento a uma empresa especializada na instalação de sistemas de energia solar. O orçamento recebido foi de R$ 3.000,00 e envolvia a instalação de um kit solar completo, composto por coletores, boiler, materiais e serviço.', null, 'Considerando que o dono da residência aceitou o orçamento da empresa e que o mês possui 30 dias, assinale a opção que apresenta o tempo de recuperação do capital investido', null,
   '21,1 meses.', '17,5 meses.', '14,2 meses.', '9,6 meses.', '6,3 meses.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 21 (INEP)'),
  ('4b88acfa-c441-539e-a77b-d9bf0ef8b627', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Gestão de projetos', 'OBJETIVA', 'No projeto de construção de uma casa, o tempo de duração de cada etapa foi modelado por uma distribuição triangular com os tempos mínimos, os mais prováveis e os máximos. Nesse projeto, cada etapa pôde ser iniciada assim que a etapa precedente estivesse concluída.

O quadro a seguir apresenta as etapas, os tempos de duração e as precedências de etapas do projeto.', 'enade2019/prod/prod19-q22.png', 'Com base nessas informações, o tempo de duração mínimo, o mais provável e o máximo do projeto são, respectivamente,', null,
   '7, 12 e 16.', '7, 12 e 17.', '7, 13 e 16.', '8, 12 e 16.', '8, 13 e 17.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 22 (INEP)'),
  ('7800ecde-961a-588e-9b7d-724d686c3a5d', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Gestão ambiental e PNRS', 'OBJETIVA', 'O volume crescente e a complexidade dos resíduos gerados atualmente, em decorrência da economia moderna, representam um sério risco para os ecossistemas e para a saúde humana. Todos os anos, estima-se que 11,2 bilhões de toneladas de resíduos sólidos são coletadas em todo o mundo.

Disponível em: <https://www.unenvironment.org/explore-topics/resource-efficiency/what-we-do/cities/solid-waste-management>. Acesso em: 06 jun. 2019 (adaptado).

A preocupação com os resíduos vem sendo discutida há algumas décadas nas esferas nacional e internacional, devido à expansão da consciência coletiva com relação ao meio ambiente e à qualidade de vida das pessoas. Após vinte e um anos de discussões no Congresso Nacional, a aprovação da Política Nacional de Resíduos Sólidos (PNRS) por meio da Lei n. 12.305 de 2010 marcou o início de uma forte articulação institucional entre os três entes federados (União, Estados e Municípios), o setor produtivo e a sociedade em geral na busca de soluções para os problemas na gestão dos resíduos sólidos.

Disponível em: <http://www.mma.gov.br/>. Acesso em: 06 jun. 2019 (adaptado).', null, 'Nesse contexto, avalie as afirmações a seguir.

I. A PNRS contém instrumentos importantes tanto para permitir ao país o avanço necessário no enfrentamento dos principais problemas ambientais, sociais e econômicos decorrentes do manejo inadequado dos resíduos sólidos, quanto para promover sua gestão e sua correta destinação.
II. A produção mais limpa (P+L) é uma estratégia mais antiga do que a política de tratamento de resíduos de fim de tubo (end of pipe).
III. A logística reversa de pós-consumo é apontada na PNRS como elemento norteador da gestão dos resíduos sólidos e trata de procedimentos como a reciclagem, que podem trazer benefícios ao meio ambiente.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 1, 'ENADE 2019 — Engenharia de Produção, Questão 23 (INEP)'),
  ('5d76fd36-1e58-5b52-81ae-90fd7e2700ef', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Indústria 4.0', 'OBJETIVA', 'Pesquisa realizada pela Confederação Nacional da Indústria (CNI) apontou que grande parte dos setores industriais brasileiros está defasado em relação à adoção de tecnologias digitais. Tais setores estão ameaçados de ficarem para trás na corrida tecnológica devido a desvantagens competitivas referentes à quarta revolução industrial, denominada indústria 4.0.

Disponível em: <https://economia.estadao.com.br/noticias/geral,mais-da-metade-da-industria-brasileira-esta-atrasada-na-corrida-tecnologica,70002176605>. Acesso em: 15 jun. 2019 (adaptado).

De forma geral, há uma percepção de que captar dados e saber usá-los de forma eficiente é o que gera valor, competitividade e redução de riscos nos negócios. Na indústria 4.0, essa percepção é acentuada, pois estamos diante de uma nova era de possibilidades de mineração e processamento de uma grande quantidade de dados disponibilizados em nuvem. Mas temos que questionar o que eles nos permitem fazer, quais modelos de negócios podemos criar e quais propósitos atingir para atender às necessidades e exigências dos clientes, o que continuará sendo essencial em qualquer tipo de negócio.

Disponível em: <https://epocanegocios.globo.com/Tecnologia/noticia/2018/04/4-tendencias-da-industria-40.html>. Acesso em: 18 jun. 2019 (adaptado).', null, 'A partir das informações apresentadas, avalie as afirmações a seguir.

I. A indústria 4.0 trouxe o conceito de coleta, tratamento e mineração de dados (data mining) e tornará obsoletos os modelos de negócios tradicionais que não a adotarem.
II. A dinâmica competitiva tende a selecionar as empresas que se adaptam melhor e mais rápido às exigências do mercado, e alguns setores industriais brasileiros podem ficar para trás nessa corrida tecnológica.
III. Novos modelos de negócio, como as fintechs e os bancos digitais, que operam serviços mais ágeis via internet e aplicativos de celular, têm inserido inteligência artificial no atendimento virtual aos clientes.
IV. A computação em nuvem (cloud computing) amplia a capacidade analítica de tomada de decisão dos gestores, fortalecendo as vantagens competitivas das empresas e dos setores industriais.

É correto apenas o que se afirma em', null,
   'I e III.', 'I e IV.', 'II e III.', 'I, II e IV.', 'II, III e IV.', 1, 'ENADE 2019 — Engenharia de Produção, Questão 24 (INEP)'),
  ('31019a37-328a-515d-bfd3-bbb9fb615c14', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Engenharia econômica', 'OBJETIVA', 'Uma empresa está avaliando a substituição de um equipamento obsoleto por um novo, com investimento inicial de R$ 500.000,00 e benefícios esperados de R$ 20.000,00 no primeiro ano, de R$ 30.000,00 no segundo ano e de R$ 90.000,00 por ano, do terceiro ao décimo segundo ano, o que leva ao seguinte perfil de valor presente líquido (VPL).', 'enade2019/prod/prod19-q25.png', 'Nessa situação, a taxa interna de retorno (TIR) do projeto de substituição do equipamento é de', null,
   '25% ao ano.', '20% ao ano.', '15% ao ano.', '10% ao ano.', '5% ao ano.', 1, 'ENADE 2019 — Engenharia de Produção, Questão 25 (INEP)'),
  ('15b21d87-441c-54c1-b6f6-d5b750ca066f', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Programação linear', 'OBJETIVA', 'Um gerente de produção de uma fábrica de pneus deseja definir qual é o mix de pneus grandes e pequenos para maximização do lucro. Ele dispõe das seguintes informações acerca do processo de produção/consumo da fábrica:

O lucro de cada unidade de pneu pequeno é de R$ 20,00, e o de cada unidade de pneu grande, R$ 50,00. O processo de produção do pneu é realizado em duas etapas subsequentes: confecção e vulcanização. A capacidade diária máxima do processo de confecção é de 3 000 pneus pequenos, quando confecciona-se apenas pneus pequenos; ou de 2 000 pneus grandes, quando confecciona-se apenas pneus grandes, sendo possível a produção combinada de pneus pequenos e grandes, desde que respeitada a capacidade de confecção. A capacidade diária máxima do processo de vulcanização é de 2 000 pneus pequenos, quando vulcaniza-se apenas pneus pequenos, ou de 1 000 pneus grandes, quando vulcaniza-se apenas pneus grandes. É possível a produção combinada de pneus pequenos e grandes, desde que respeitada a capacidade de vulcanização. O mercado consegue absorver a totalidade da produção diária de pneus pequenos, mas absorve, no máximo, 800 pneus grandes por dia.

Para a resolução desse problema, ou seja, a definição do mix de produção, o gerente considera as variáveis de decisão x_1 e x_2, em que:
• x_1 é a quantidade de pneus pequenos a serem produzidos diariamente;
• x_2 é a quantidade de pneus grandes a serem produzidos diariamente.', null, 'Nessa situação, a opção que corresponde à solução correta do problema, na forma (x_1, x_2), é', null,
   '(400; 800).', '(400; 1 000).', '(1 000; 800).', '(1 200; 400).', '(0; 1 000).', 2, 'ENADE 2019 — Engenharia de Produção, Questão 26 (INEP)'),
  ('21f81a66-e35f-50c4-8d6b-14f2b5fb1e7d', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Problema de transporte', 'OBJETIVA', 'Uma empresa possui três fábricas, localizadas em São Paulo, Manaus e Recife, as quais devem abastecer consumidores de duas regiões do Brasil: Sudeste e Nordeste. As tabelas a seguir apresentam dados sobre as fábricas e os centros consumidores em questão.', 'enade2019/prod/prod19-q27.png', 'Define-se a variável de decisão do problema como sendo x_ij, quantidade de produtos (em milhares de unidades) enviados da fábrica i para o centro consumidor j, em que i = 1 (São Paulo), 2 (Manaus) ou 3 (Recife) e j = 1 (Sudeste) ou 2 (Nordeste).

São, então, propostas as seguintes opções para os envios:
• opção 1: x_11 = 2 500, x_21 = 0, x_31 = 0, x_12 = 0, x_22 = 500, x_32 = 1 000;
• opção 2: x_11 = 2 000, x_21 = 0, x_31 = 500, x_12 = 0, x_22 = 300, x_32 = 1 200;
• opção 3: x_11 = 2 000, x_21 = 500, x_31 = 0, x_12 = 0, x_22 = 500, x_32 = 1 000;
• opção 4: x_11 = 1 500, x_21 = 0, x_31 = 1 000, x_12 = 500, x_22 = 500, x_32 = 0.

Com base nessa situação, considerando que as demandas dos consumidores devem ser atendidas, avalie as afirmações a seguir.

I. As opções 1 e 2 são inviáveis, pois nelas há extrapolação da capacidade das fábricas.
II. A opção 3 é viável, pois todas as demandas dos consumidores são atendidas, sem que haja extrapolação da capacidade das fábricas.
III. A opção 4 é viável, pois todas as demandas dos consumidores são atendidas, sem que haja extrapolação da capacidade das fábricas.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 27 (INEP)'),
  ('a3e0c507-2aee-5abd-8657-b1e19c629fdc', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Capacidade produtiva', 'OBJETIVA', 'A capacidade produtiva é um indicador fundamental para analisar o fluxo operacional de uma organização. O planejamento e o controle da capacidade de produção determinam a capacidade efetiva da operação produtiva, de forma que ela possa responder à demanda.

Considere uma empresa têxtil que pode utilizar um regime de trabalho de três turnos diários, de 8 horas cada um, nos sete dias da semana. A capacidade de produção é de 200 peças de determinado item por hora. Em uma semana, a empresa trabalhou dois turnos por dia, durante cinco dias. Os registros de produção dessa semana de trabalho apresentaram ocorrências conforme tabela a seguir.', 'enade2019/prod/prod19-q28.png', 'Com base nesses dados, avalie as afirmações a seguir.

I. A capacidade máxima de produção da empresa é de 33 600 peças por semana.
II. A capacidade programada de produção na semana avaliada foi de 16 000 peças.
III. A máxima produção possível na semana avaliada foi de 13 200 peças.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 28 (INEP)'),
  ('ebf7a95e-59c0-55dc-a916-3104e7d8b8ef', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Manutenção (MTBF e MTTR)', 'OBJETIVA', 'Em uma fábrica, a manutenção dos equipamentos é uma forma de melhoria da produtividade. Vários indicadores são importantes nesse controle, destacando-se o MTBF (Mean Time Between Failures) e o MTTR (Mean Time To Repair).

Uma prensa funciona diariamente em turno de 12 horas. Em um turno de trabalho, o equipamento ficou parado por 2 horas para manutenção e apresentou MTBF de 2 horas e 30 minutos.

Considere que:
MTBF = (TD − TM) / P;
MTTR = TM / P;
em que:
TD = tempo total de disponibilidade;
TM = tempo total de manutenção;
P = número de paradas.', null, 'Com base nos dados apresentados, avalie as afirmações a seguir.

I. O MTTR da prensa foi de 180 minutos.
II. O equipamento teve 4 paradas durante o turno de 12 horas.
III. Quanto maior for o MTBF e menor for o MTTR, melhor será o desempenho do equipamento.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 29 (INEP)'),
  ('fd2e2acf-57c5-5699-a73d-fc35b6bb239f', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Controle estatístico de processo', 'OBJETIVA', 'Uma fábrica dispõe na linha de produção de duas máquinas de peças plásticas injetadas. É sabido que as condições de injeção, como o tempo de resfriamento dos moldes, afetam diretamente a qualidade das peças, sobretudo no que diz respeito às propriedades mecânicas que serão alcançadas, como a resistência ao impacto. Nesse contexto, para avaliar o desempenho das máquinas, foi realizado teste de resistência ao impacto de um conjunto de corpos de prova produzidos em cada uma das máquinas, obtidos por meio de amostragem aleatória. A seguir, são apresentadas as cartas de controle de variáveis para dados individuais, incluindo limites superiores e inferiores de controle (LSC e LIC, respectivamente), construídas com os resultados obtidos no teste.', 'enade2019/prod/prod19-q30.png', 'Nessa situação, a análise das cartas de controle indica que', null,
   'o ajuste da máquina 1 é melhor do que o da máquina 2, pois a máquina 1 produz peças que apresentam resistência ao impacto com LSC maior do que as produzidas na máquina 2.', 'o ajuste da máquina 1 é pior do que o da máquina 2, pois a máquina 1 produz peças com valores de resistência ao impacto mais próximos do LSC e do LIC, em comparação com as produzidas na máquina 2.', 'o ajuste da máquina 1 é pior do que o da máquina 2, pois a máquina 2 produz peças mais homogêneas do que a máquina 1.', 'o ajuste da máquina 1 é pior do que o da máquina 2, pois a máquina 1 produz peças que, em sua maioria, apresentam resistência ao impacto que não atinge o LIC ou o LSC.', 'o ajuste da máquina 1 é melhor do que o da máquina 2, pois a máquina 2 produz peças que apresentam maior amplitude dos valores de resistência ao impacto do que as produzidas na máquina 1.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 30 (INEP)'),
  ('398d1a4e-64c5-5785-a27a-bf278bfacfaf', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Gestão da qualidade (SIPOC)', 'OBJETIVA', 'A norma ISO 9001:2015, que foca na adoção da abordagem por processos para desenvolver, implementar e melhorar a eficácia de um Sistema de Gestão da Qualidade, permite, se implementada, a compreensão e a satisfação consistentes dos requisitos da norma; a consideração dos processos em termos de valor acrescentado; a obtenção de um desempenho eficaz dos processos e a sua melhoria com base na avaliação de dados e informações. Muito utilizado em metodologias Seis Sigma, o Sipoc (supplier, input, process, output e customer) é uma ferramenta para mapear processos em que os fatores que impactam diretamente a execução do trabalho são definidos e formalizados.

CARPINETTI, L. C. R.; GEROLAMO, M. C. Gestão da Qualidade ISO 9001:2015: requisitos e integração com a ISO 14001. São Paulo: Atlas, 2016 (adaptado).', null, 'Nesse contexto, avalie as afirmações a seguir, acerca da aplicação da ferramenta Sipoc em um restaurante japonês.

I. A realização da inspeção de qualidade do sushi montado está no output do Sipoc.
II. O vendedor de peixe está no supplier, já o atum e o salmão estão no input do Sipoc.
III. Pessoas que procuram comida japonesa estão no customer do Sipoc.
IV. Resíduos de peixe são posicionados como process do Sipoc.

É correto apenas o que se afirma em', null,
   'I e II.', 'II e III.', 'III e IV.', 'I, III e IV.', 'I, II e IV.', 1, 'ENADE 2019 — Engenharia de Produção, Questão 31 (INEP)'),
  ('4e3697e9-6608-564c-9c8d-e90fbac309c2', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Indústria 4.0', 'OBJETIVA', 'Na transição das nações industriais para a quarta revolução industrial, potências como Alemanha, China e Estados Unidos investem na estruturação da manufatura avançada para garantir que suas economias sejam competitivas no mercado global. Essas iniciativas internacionais na conhecida indústria 4.0 apresentam relação temática com trabalhos realizados no Brasil em convergência e integração tecnológica, desenvolvimento de cadeias produtivas, recursos humanos, regulação e infraestrutura. Porém destaque-se que os trabalhos internacionais estão concentrados na gestão da informação e do conhecimento tecnológico, na digitalização, nos sistemas ciberfísicos, na inteligência artificial (IA), na internet das coisas (IoT), na interoperabilidade, na robótica colaborativa, e em novos materiais e máquinas híbridas.

BRASIL. Ministério da Indústria, Comércio Exterior e Serviços; Ministério da Ciência, Tecnologia, Inovações e Comunicações. Perspectivas de especialistas brasileiros sobre a manufatura avançada no Brasil: um relato de workshops realizados em sete capitais brasileiras em contraste com as experiências internacionais. Brasília, 2016 (adaptado).', null, 'A partir desse contexto, avalie as afirmações a seguir.

I. A gestão da informação e do conhecimento tecnológico é um desafio para a integração das tecnologias nos mercados globais.
II. A integração de sistemas de plantas industriais depende da implantação de sistemas ciberfísicos e da robótica colaborativa.
III. A gestão da informação e do conhecimento tecnológico engloba o entendimento estratégico dos setores por meio de análise de metadados e da criação de inteligência de mercado.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 32 (INEP)'),
  ('fde79f87-57b8-51b2-93f8-ebfc227f7fab', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Arranjo físico (layout)', 'OBJETIVA', 'O planejamento do arranjo físico (layout) tem como objetivo garantir a maior eficiência possível na combinação dos recursos utilizados nas atividades produtivas. O custo total de um arranjo físico, considerando-se que a alocação de atividades, pode ser calculado pela seguinte expressão:

C = ∑_{i=1}^{n} ∑_{j=1}^{n} w_ij · k_ij · d_ij + ∑_{i=1}^{n} c_i ,

em que:
• W_ij é uma medida de interação entre as atividades i e j;
• d_ij é uma medida de distância entre as atividades i e j;
• K_ij é o fator de conversão para custos entre as atividades i e j;
• C_i é o custo fixo de localização de cada atividade.

Considere um processo produtivo que utilize seis máquinas (M1, M2, M3, M4, M5 e M6), cada uma devendo ser alocada em uma das posições indicadas no esquema a seguir. Por restrições de infraestrutura, as posições das máquinas M5 e M6 são predefinidas e fixas nas posições 6 e 5, respectivamente.', 'enade2019/prod/prod19-q33.png', 'Com base nessas informações, assinale a opção que apresenta a associação (máquina, posição) que leva ao arranjo físico com custo mínimo de movimentação de materiais.', null,
   '(M3,1); (M2,2); (M4,3); (M1,4); (M5,5); (M6,6).', '(M2,1); (M1,2); (M3,3); (M4,4); (M6,5); (M5,6).', '(M4,1); (M2,2); (M1,3); (M3,4); (M6,5); (M5,6).', '(M1,1); (M2,2); (M4,3); (M3,4); (M6,5); (M5,6).', '(M1,1); (M2,2); (M4,3); (M3,4); (M5,5); (M6,6).', 3, 'ENADE 2019 — Engenharia de Produção, Questão 33 (INEP)'),
  ('0afe0fcc-c805-5596-bcaa-ae6ece0cf82a', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Logística e custos', 'OBJETIVA', 'A gestão da cadeia de suprimentos diz respeito às práticas necessárias a uma empresa para que suas operações agreguem valor ao cliente, não só no fornecimento de materiais e na produção de bens e serviços, mas também na distribuição e entrega final do produto ao cliente, sem desconsiderar, ainda, a importância do reaproveitamento dos resíduos.

Uma empresa com três fábricas de refrigerantes elaborou um planejamento para recuperar o seu maior resíduo, os vasilhames de plástico. Foi planejado, para cada fábrica, um sistema logístico de recuperação de resíduos oriundos do principal ponto de coleta dos vasilhames descartados pelos usuários.

A tabela a seguir apresenta os custos fixos e os custos variáveis unitários para o transporte de até 30 000 vasilhames do ponto de coleta até as fábricas localizadas nas cidades F, G e H.', 'enade2019/prod/prod19-q34.png', 'Com base nas informações e nos dados apresentados, avalie as afirmações a seguir.

I. O sistema logístico de recuperação de resíduos da fábrica situada na cidade F é o que apresenta o menor custo total para o transporte de 10 000 vasilhames.
II. O sistema logístico de recuperação de resíduos da fábrica situada na cidade H é o que apresenta o menor custo total para o transporte de 30 000 vasilhames.
III. Para 25 000 vasilhames, o custo total de transporte do sistema de recuperação de resíduos é igual para as fábricas localizadas nas cidades G e H.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2019 — Engenharia de Produção, Questão 34 (INEP)'),
  ('84661ed6-af14-5262-ae32-b55e5bf200f4', 'CE', array['ENG_PROD']::public.curso_alvo[], 'Gestão de pessoas e BSC', 'OBJETIVA', 'A área de gestão de pessoas está diretamente ligada à alta liderança de uma empresa, podendo interagir, de forma abrangente, com as demais áreas organizacionais, repassando informações acerca dos funcionários e influenciando de forma positiva e assertiva as atividades desempenhadas em cada uma delas. Porém, para se obter êxito na gestão estratégica, todos na empresa precisam assumir a responsabilidade de gerenciar e liderar pessoas.

Com o intuito de melhorar o seu clima organizacional, uma empresa resolve utilizar o Balanced Scorecard (BSC).', null, 'Considerando-se as informações apresentadas, as perspectivas que compõem o BSC e a sua aplicação nessa empresa, é correto afirmar que', null,
   'o BSC possibilitará a cada unidade administrativa da empresa o estabelecimento de estilos de liderança únicos e distintos entre si.', 'o desdobramento de estratégias de longo prazo para estratégias de curto prazo, por meio do BSC, induz melhorias no clima organizacional da empresa.', 'a escolha do BSC mostra-se adequada à gestão estratégica de pessoas, pois as diversas perspectivas do BSC conduzirão, como resultado final, à perspectiva de aprendizagem e crescimento.', 'o BSC, ao integrar os indicadores de desempenho, permitirá que a perspectiva de aprendizagem e crescimento seja organizada de forma desvinculada das demais perspectivas, o que contribuirá para a autonomia de cada unidade administrativa da empresa.', 'o BSC, por utilizar-se de indicadores de desempenho e de relações de causa e efeito, contribuirá para o entendimento pelas unidades administrativas da empresa dos fatores-chave para a motivação dos funcionários, o que permitirá a cada unidade identificar sua contribuição no resultado final da empresa.', 1, 'ENADE 2019 — Engenharia de Produção, Questão 35 (INEP)'),
  ('daceab06-17c0-581b-bbcd-dd5b71c070ee', 'FG', array['ALL']::public.curso_alvo[], 'Arte, cultura e censura', 'DISCURSIVA', 'TEXTO I

Em época de censura, a própria existência da arte passa a ser questionada. Surgem debates em jornais, na rua, em casa, para discutir sua relevância. Não podemos deixar de nos perguntar como chegamos a essa estranha situação em que precisamos justificar a própria existência da arte. Ela pode ser julgada apressadamente como boa ou ruim, mas nem por isso deixa de ser arte.

O cineasta franco-suíço Jean-Luc Godard aponta para o fato de que "a cultura é a regra; a arte é a exceção". A arte é, dentro da cultura, o que tensiona a própria cultura para assim levá-la para outros lugares. Enquanto a cultura regula, a arte destoa e movimenta. A arte questiona, incomoda e transforma. Arte e cultura se contradizem, mas andam de mãos dadas.

Os psicanalistas Suely Rolnik e Félix Guattari consideram que o conceito de cultura é profundamente reacionário. É uma maneira de separar atividades semióticas em esferas, às quais os homens são remetidos. Tais atividades, assim isoladas, são padronizadas para o modo de semiotização dominante. A arte, por sua vez, existe plenamente quando junta o que é separado, questiona o que é geralmente aceito, grita onde há silêncio, desorganizando e reorganizando a cultura. Quando se discutem os limites da arte, são, na verdade, os limites da nossa tolerância que estão sendo debatidos.

SEROUSSI, B. O que faz a arte? In: OLIVIERE, C.; NATALE, E. (org.). Direito, arte e liberdade. São Paulo: Edições Sesc SP, 2018. p. 26-42 (adaptado).

TEXTO II

Capítulo I
Dos Direitos e Deveres Individuais e Coletivos

Art. 5º Todos são iguais perante a lei, sem distinção de qualquer natureza, garantindo-se aos brasileiros e aos estrangeiros residentes no País a inviolabilidade do direito à vida, à liberdade, à igualdade, à segurança e à propriedade, nos termos seguintes:

[...]

IX - é livre a expressão da atividade intelectual, artística, científica e de comunicação, independentemente de censura ou licença.

BRASIL. Constituição Federal do Brasil. Disponível em: https://www.senado.leg.br/atividade/const/con1988/con1988_15.12.2016/art_5_.asp. Acesso em: 2 maio 2020.', null, 'Considerando as informações e os argumentos presentes nos textos I e II, discorra a respeito da relação entre arte, cultura e censura, à luz da ideia de liberdade artística garantida pela Constituição Federal de 1988. Apresente, em seu texto, duas ações educativas que podem contribuir para minimizar essas tensões e garantir a liberdade artística prevista pela lei. (valor: 10,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2021 — Formação Geral, Questão Discursiva 1 (INEP)'),
  ('cfadec24-b416-5be4-adeb-47fc05b52236', 'FG', array['ALL']::public.curso_alvo[], 'Cidades inteligentes e sustentabilidade', 'DISCURSIVA', 'TEXTO I

Uma cidade é considerada inteligente quando: i) nela se utiliza a tecnologia para melhorar a sua infraestrutura e seus serviços, tornando os setores de administração, educação, saúde, segurança pública, moradia e transporte mais inteligentes, interconectados e eficientes, beneficiando toda a população; e ii) está comprometida com o meio ambiente e com sua herança histórica e cultural.

AQUINO, A. L. L. et al. Cidades inteligentes, um novo paradigma da sociedade do conhecimento. Blucher Education Proceedings, v. 1, n. 1, p. 165-178, 2015 (adaptado).

TEXTO II

A evolução para uma cidade mais inteligente, mais integrada, mais inovadora pressupõe uma visão holística e sistêmica do espaço urbano e a integração efetiva dos vários atores e setores. Para tal, é necessário ir além dos investimentos em inovação tecnológica e inovar também na gestão, no planejamento, no modelo de governança e no desenvolvimento de políticas públicas.

CAMPOS, C. C. et al. Cidades inteligentes e mobilidade urbana. Cadernos FGV Projetos, n. 24, 2014 (adaptado).', null, 'A partir do conceito de cidade inteligente exposto nos textos, faça o que se pede nos itens a seguir.

a) Explique de que modo as cidades inteligentes podem contribuir para a melhoria das questões relacionadas ao desenvolvimento sustentável. (valor: 5,0 pontos)
b) Apresente uma proposta de intervenção urbana que pode gerar impacto social e contribuir para a melhoria da vida em comunidade. (valor: 5,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2021 — Formação Geral, Questão Discursiva 2 (INEP)'),
  ('8fc8ed6e-a127-5e89-8aa2-6a1fec3eefeb', 'FG', array['ALL']::public.curso_alvo[], 'Mobilidade social e desigualdade', 'OBJETIVA', 'A chance de uma criança de baixa renda ter um futuro melhor que a realidade em que nasceu está, em maior ou menor grau, relacionada à escolaridade e ao nível de renda de seus pais. Nos países ricos, o "elevador social" anda mais rápido. Nos emergentes, mais devagar. No Brasil, ainda mais lentamente. O país ocupa a segunda pior posição em um estudo sobre mobilidade social feito pela Organização para a Cooperação e Desenvolvimento Econômico (OCDE), em 2018, com dados de 30 países. Segundo os resultados, seriam necessárias nove gerações para que os descendentes de um brasileiro entre os 10% mais pobres atingissem o nível médio de rendimento do país. A estimativa é a mesma para a África do Sul e só perde para a Colômbia, onde o período de ascensão levaria 11 gerações. Mais de 1/3 daqueles que nascem entre os 20% mais pobres no Brasil permanece na base da pirâmide, enquanto apenas 7% consegue chegar aos 20% mais ricos. Filhos de pais na base da pirâmide têm dificuldade de acesso à saúde e maior probabilidade de frequentar uma escola com ensino de baixa qualidade. A educação precária, em geral, limita as opções para esses jovens no mercado de trabalho. Sobram-lhes empregos de baixa remuneração, em que a possibilidade de crescimento salarial para quem tem pouca qualificação é pequena – e a chance de perpetuação do ciclo de pobreza, grande.

LEMOS, V. Brasil é o segundo pior em mobilidade social em ranking de 30 países. BBC News Brasil, 15 jun. 2018 (adaptado).', null, 'A partir das informações apresentadas, é correto afirmar que', null,
   'o fator ambiental e o fator demográfico afetam a mobilidade social observada, sendo ela menor nos países que apresentam as maiores taxas de natalidade.', 'a baixa organização social dos economicamente menos favorecidos determina a baixa mobilidade social da base para o topo da pirâmide.', 'a mobilidade social é caracterizada por um fator ancestral que se revela ao longo das gerações, sendo um limitador da eficácia de políticas públicas de redução das desigualdades sociais.', 'a análise de mobilidade social permite a observação de um ciclo vicioso, que se caracteriza por uma subida nas camadas sociais seguida de uma queda, repetindo-se esse ciclo de modo sucessivo.', 'a ascensão social depende de fatores viabilizadores que estão fora do alcance das camadas pobres, o que ocasiona conflitos sociais em busca do acesso a tais fatores.', 2, 'ENADE 2021 — Formação Geral, Questão 01 (INEP)'),
  ('51d86b62-83b9-521c-976e-d92a55446106', 'FG', array['ALL']::public.curso_alvo[], 'Desperdício de alimentos', 'OBJETIVA', 'TEXTO I', 'enade2021/fg/fg21-q02.png', 'TEXTO II

Em alguns países da Europa, permite-se que um produto de menor valor estético seja comercializado. Estamos falando de um pepino deformado ou de uma cebola pequena, mas não de um produto contaminado com resíduos químicos ou agentes biológicos. No caso do Brasil, o problema vai além da aparência, porque há hortaliças ruins – contaminadas, murchas, machucadas – que chegam às bancas para ser comercializadas.

Mas, se nos dois contextos há perda de alimentos e preconceito em relação às hortaliças fora do padrão visual, mas boas para o consumo, quais seriam as alternativas para evitar o desperdício e melhorar a qualidade dos produtos? Para os pesquisadores do assunto, não adianta replicar a experiência europeia no Brasil, de exigir hortaliças esteticamente perfeitas, porque também teríamos produtos sendo desprezados ainda na etapa de produção. Não devemos passar de um mercado pouco exigente, que gera desperdício no varejo e nas residências, para um mercado exigente que gera perda no campo.

A solução do problema é conscientizar os diversos elos da cadeia produtiva, especialmente varejistas e consumidores, para que sejam esclarecidos sobre quais aspectos da aparência das hortaliças comprometem a qualidade. Quanto maior a exigência do mercado por hortaliças de aparência perfeita, maior o desperdício de alimentos. Por sua vez, quanto maior a exigência por hortaliças sem danos, causados pela falta de cuidado e pela falta de higiene, menor será a perda de alimentos e maior a qualidade da alimentação da população brasileira.

Disponível em: https://www.embrapa.br/busca-de-noticias/-/noticia/29626389/manuseio-correto-preserva-a-qualidade-e-a-vida-util-das-hortalicas. Acesso em: 27 maio 2020 (adaptado).

Considerando as informações apresentadas nos textos, avalie as asserções a seguir e a relação proposta entre elas.

I. O texto I sintetiza uma informação principal do texto II, ao apresentar critérios distintivos de alterações visuais que têm efeitos puramente estéticos em produtos alimentícios daquelas que têm implicações na qualidade desses produtos.

PORQUE

II. O texto II divulga que o aumento das perdas na cadeia produtiva de hortaliças no Brasil é proporcional à elevação de exigências dos consumidores pela aparência de produtos agropecuários.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 2, 'ENADE 2021 — Formação Geral, Questão 02 (INEP)'),
  ('3da5aabd-9461-54ad-a263-613265b27315', 'FG', array['ALL']::public.curso_alvo[], 'Mobilidade urbana sustentável', 'OBJETIVA', 'TEXTO I

Na Alemanha nazista, no auge da Segunda Guerra Mundial, surgiu a necessidade de abrir mais espaço para os veículos automotivos. Com muitos ciclistas, as bicicletas viraram um empecilho, forçando a criação de um espaço exclusivo para elas – talvez as primeiras ciclovias do mundo. Mas, se na década de 1940 os veículos eram prioridade, hoje, o uso de bicicletas – e das ciclovias – surge como uma das principais alternativas para melhorar a qualidade de vida nas grandes metrópoles. Quando políticas públicas incentivam o uso de bicicletas como meio de transporte para curtas e médias distâncias, um novo panorama se abre.

COSTA, J. Ciclovias ajudam a humanizar o espaço urbano. Ciência e Cultura. v. 68, n. 2, São Paulo, 2016 (adaptado).

TEXTO II', 'enade2021/fg/fg21-q03.png', 'Considerando as informações apresentadas e o uso de bicicletas como alternativa para melhorar a qualidade de vida nas cidades, avalie as afirmações a seguir.

I. Dado que as bicicletas são veículos que ocupam pouco espaço na malha viária, prescinde-se de investimentos públicos em construção de ciclovias, sendo prioritárias campanhas de conscientização de motoristas a respeito dos benefícios do uso da bicicleta como meio de transporte.
II. O uso das bicicletas como meio de transporte contribui para a melhoria da qualidade de vida nas grandes metrópoles, pois elas não emitem poluentes, além de esse uso proporcionar a prática de atividade física.
III. A partir da Segunda Guerra Mundial, durante o governo da Alemanha nazista, o uso da bicicleta como meio de transporte tornou-se eficaz e passou a prevalecer nas cidades europeias.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 1, 'ENADE 2021 — Formação Geral, Questão 03 (INEP)'),
  ('689eb746-0e4c-5001-be86-ed27a0b537b4', 'FG', array['ALL']::public.curso_alvo[], 'Gig Economy e trabalho informal', 'OBJETIVA', 'Além do contexto econômico, o avanço da tecnologia também é um dos responsáveis pelo aumento dos trabalhadores informais. E a tendência de contratação de freelancers por meio de plataformas digitais, como aplicativos de delivery e de mobilidade urbana, ganhou até um nome: Gig Economy, ou economia dos bicos. Para os gigantes de tecnologia detentores desses aplicativos, os motoristas são trabalhadores autônomos, que não possuem vínculo empregatício. Além de não estarem sujeitos a nenhuma regulamentação e proteção legal, os profissionais que desenvolvem esse tipo de trabalho deixam de contribuir para a Previdência Social e de possuir benefícios como Fundo de Garantia por Tempo de Serviço (FGTS), férias e décimo terceiro salário. Não obstante, ainda arcam com todo o custo da atividade que exercem. Em uma reportagem que ouviu alguns desses trabalhadores, motoristas afirmaram sofrer com problemas de coluna e com o estresse no trânsito, além das longas jornadas de trabalho. Por esses motivos, a Gig Economy está no centro de uma discussão mundial acerca da responsabilidade dessas companhias milionárias sobre as condições de trabalho da mão de obra que contratam. No meio do limbo jurídico, quem sofre são os trabalhadores dessas plataformas, que ficam duplamente desprotegidos — pelas empresas e pelo Estado.

Disponível em: https://exame.abril.com.br/carreira/quais-sao-as-consequencia-do-trabalho-informal-no-pais/. Acesso em: 18 abr. 2020 (adaptado).', null, 'A partir das informações apresentadas, avalie as asserções a seguir e a relação proposta entre elas.

I. Trabalhadores autônomos informais que atuam em plataformas digitais sem qualquer vínculo empregatício, desprotegidos de regulamentação ou lei trabalhista, compõem a Gig Economy.

PORQUE

II. Os trabalhadores, na Gig Economy, arcam com todos os custos necessários para desempenhar o seu trabalho, ganham por produção e enfrentam longas jornadas diárias, o que os deixa mais desgastados e com problemas de saúde.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 2, 'ENADE 2021 — Formação Geral, Questão 04 (INEP)'),
  ('d782eb86-a38e-5273-bc23-6e36444bc011', 'FG', array['ALL']::public.curso_alvo[], 'Suicídio na população indígena', 'OBJETIVA', 'TEXTO I

Segundo o Ministério da Saúde, em 2017 o Brasil registrou uma média nacional de 5,7 óbitos para 100 mil habitantes. Na população indígena, foi registrado um número de óbitos três vezes maior que a média nacional – 15,2. Destes registros, 44,8% (aproximadamente, 6,8 óbitos), são suicídios de crianças e adolescentes entre 10 e 19 anos. Esses dados contrastam com o panorama nacional, em que o maior índice é entre adolescentes e adultos de 15 a 20 anos.

Disponível em: https://www.cvv.org.br/blog/o-suicidio-do-povo-indigena/. Acesso em: 30 de abr. 2020 (adaptado).

TEXTO II

Evidências apontam que, em determinadas minorias étnico-raciais, como os indígenas (aborígines ou populações nativas), o suicídio entre crianças apresenta taxas bem mais elevadas do que as observadas na população geral. No Brasil, o enforcamento foi utilizado mais frequentemente entre indígenas do que entre não indígenas, não se observando, no primeiro grupo, suicídios por intoxicação ou por armas de fogo. O mapa a seguir apresenta a distribuição dos óbitos por suicídio entre crianças e adolescentes indígenas no Brasil, entre os anos de 2010 e 2014.', 'enade2021/fg/fg21-q05.png', 'Considerando as informações apresentadas e o alto índice de suicídio da população indígena, avalie as afirmações a seguir.

I. O elevado índice de suicídios entre crianças e adolescentes indígenas no país evidencia a necessidade de ações com foco nos direitos fundamentais desses indivíduos.
II. Os estados do Pará e de Tocantins são os que possuem os maiores índices de suicídio de indígenas na faixa etária de 10 a 14 anos.
III. Os povos das tribos originárias do Brasil, no que tange a sua história e preservação cultural, não estão amparados por direitos e garantias constitucionais.
IV. O estabelecimento de ações preventivas ao suicídio nas comunidades indígenas deve considerar os elementos globais que afetam a população em geral, na faixa etária entre 15 e 20 anos.

É correto apenas o que se afirma em', null,
   'I.', 'II.', 'I e III.', 'II e IV.', 'III e IV.', 2, 'ENADE 2021 — Formação Geral, Questão 05 (INEP)'),
  ('97762bde-ec43-5a75-b6a2-60084f7b6fd0', 'FG', array['ALL']::public.curso_alvo[], 'Covid-19 e vulnerabilidade social', 'OBJETIVA', 'A pandemia ocasionada pelo novo Coronavírus gerou impactos negativos na economia e nos negócios, intensificando problemas sociais no mundo todo. Nos Estados Unidos, um estudo realizado com a parceria de duas importantes universidades verificou que a expectativa de vida dos norte-americanos caiu 1,1 ano em 2020. A nova expectativa é de 77,4 anos. De acordo com o estudo, esta foi a maior queda anual da expectativa de vida já registrada nos últimos 40 anos. O declínio é ainda maior se considerada a expectativa de vida para negros que moram no país, cuja queda foi de 2,1 anos. Para a população latina, essa queda foi de 3 anos. O declínio na expectativa de vida dos latinos é significativo, uma vez que eles apresentam menor incidência de condições crônicas que são fatores de risco para a Covid-19 em relação às populações de brancos e negros.

LOUREIRO, R. Covid-19 reduz gravemente expectativa de vida de negros e latinos nos EUA. Revista Exame, 2021 (adaptado).', null, 'Considerando as informações apresentadas no texto, avalie as asserções a seguir e a relação proposta entre elas.

I. O efeito desproporcional da pandemia da Covid-19 na expectativa de vida da população negra e latino-americana estabelece relação com sua situação de vulnerabilidade social.

PORQUE

II. Uma hipótese que pode ser levantada quanto à diminuição da expectativa de vida de negros e latino-americanos está relacionada às suas precárias condições de trabalho, levando-os a maior possibilidade de exposição ao contágio pelo novo Coronavírus.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 2, 'ENADE 2021 — Formação Geral, Questão 06 (INEP)'),
  ('f41f49e5-4161-5305-9ba1-7f9ac9398338', 'FG', array['ALL']::public.curso_alvo[], 'Informação em saúde na internet', 'OBJETIVA', 'TEXTO I

O estudo Internet and American Life Project, do Pew Research Center, demonstrou que, em 2009, metade das buscas de temas relacionados à saúde na internet era feita para terceiros, e quase seis em cada dez pessoas que usaram meios digitais para se informar sobre saúde mudaram o enfoque com que cuidavam da própria saúde ou da de algum parente. Estima-se que exista uma correlação positiva entre o grau de conhecimento das doenças (seus fatores de risco, formas de prevenção e tratamento) e a taxa de adoção de hábitos saudáveis pela sociedade. O aumento nos diagnósticos precoces do câncer de mama e a diminuição do tabagismo são dois exemplos clássicos a favor dessa ideia. Acredita-se que indivíduos mais bem informados aderem a comportamentos preventivos e reagem melhor a uma enfermidade.

Infelizmente, a divulgação de temas médicos é uma faca de dois gumes: quem não sabe nada está mais perto da verdade do que a pessoa cuja mente está cheia de informações equivocadas. Conseguir que a mensagem seja bem decodificada pelos receptores é o grande desafio que preocupa (ou deveria preocupar) tanto médicos quanto jornalistas.

TABAKMAN, R. A saúde na mídia: medicina para jornalistas, jornalismo para médicos. Trad. Lizandra Magon de Almeida. São Paulo: Summus Editorial, 2013 (adaptado).

TEXTO II

De acordo com os dados da última TIC Domicílios — pesquisa realizada anualmente com o objetivo de mapear formas de uso das tecnologias de informação e comunicação no país —, aproximadamente 46% dos usuários de Internet no Brasil utilizam a rede à procura de informações médicas sobre saúde em geral e serviços de saúde. Para uma médica e pesquisadora da Fiocruz, os indivíduos sempre procuraram informações sobre seu estado de saúde, mas é inegável que o surgimento da Internet trouxe um aumento significativo do acesso a informações amplificando assim os reflexos deste processo e alterando a relação entre os indivíduos. A pesquisadora chama a atenção para o perigo do autodiagnóstico e da automedicação, que podem gerar consequências nefastas tanto para os indivíduos quanto para a saúde pública, uma vez que boa parte dos estudos mostra que não são adotados critérios durante as buscas na Internet.

Disponível em: https://agencia.fiocruz.br/conteudos-sobre-saude-na-web-alteram-relacao-medico-paciente. Acesso em: 16 abr. 2020 (adaptado).', null, 'Considerando a abordagem dos textos, avalie as afirmações a seguir.

I. Os textos I e II evidenciam a importância de critérios nas buscas realizadas pelos usuários da Internet por informações sobre patologias, pois algumas informações podem trazer riscos à saúde por fomentarem a compreensão equivocada de sintomas e profilaxias.
II. O texto I afirma que a disponibilização de informações sobre temas de saúde nos meios de comunicação tem contribuído para o esclarecimento da população acerca de hábitos saudáveis.
III. No texto II, defende-se o acesso a informações relativas a pesquisas da área da saúde nos veículos de comunicação, pois elas permitem que o indivíduo seja proativo na prevenção de patologias.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2021 — Formação Geral, Questão 07 (INEP)'),
  ('23451b55-fe4d-546b-aa04-b5c153abd8a0', 'FG', array['ALL']::public.curso_alvo[], 'Democracia majoritária e consensual', 'OBJETIVA', 'Que é democracia? Em seu famoso discurso em Gettysburg, Abraham Lincoln disse que "a democracia é o governo do povo, feito para o povo e pelo povo, e responsável perante o povo". O crédito desta definição é, na verdade, de Daniel Webster, que a elaborou 33 anos antes de Lincoln em outro discurso. Nesta ideia de "governo pelo povo e para o povo" surge uma questão essencial: e quando o povo estiver em desacordo? E quando o povo tiver preferências divergentes? O politólogo Arend Lijphart ressalta que há duas respostas principais: a resposta da "democracia majoritária" e a resposta da "democracia consensual". Na democracia majoritária, a resposta é simples e direta: deve-se governar para a maioria do povo. A resposta alternativa, no modelo da democracia consensual é: deve-se governar para o máximo possível de pessoas.

A virtude da democracia consensual é buscar consensos mais amplos no que é interesse de todos; o desafio da democracia consensual pressupõe lideranças políticas mais maduras, tanto no governo quanto na oposição. Democratas genuínos têm aversão à ideia do totalitarismo e combatem os delírios daqueles que desejam poder sem limites.

Disponível em: https://g1.globo.com/politica/blog/matheus-leitao/post/2020/02/25/democracia-consensual-contra-a-tirania-da-maioria.ghtml. Acesso em: 2 maio 2020 (adaptado).', null, 'A partir dos argumentos expostos no texto, avalie as afirmações a seguir.

I. O bem comum, a ser estabelecido por um governo democrático, nem sempre está associado às opiniões da maioria do povo.
II. A democracia consensual é caracterizada pelo consenso a ser alcançado entre situação e oposição, nas decisões governamentais.
III. Circunstâncias políticas de polarização, marcadas pela alta competitividade e combatividade entre posições divergentes, caracterizam um modelo de democracia majoritária.
IV. Democracia consensual pressupõe que a situação política no poder considere em suas decisões as necessidades das minorias, no sentido de governar para todo o povo.

É correto apenas o que se afirma em', null,
   'I e II.', 'I e IV.', 'II e III.', 'I, III e IV.', 'II, III e IV.', 2, 'ENADE 2021 — Formação Geral, Questão 08 (INEP)'),
  ('2075435d-d928-5990-bafb-647a9d498171', 'CE', array['ADS']::public.curso_alvo[], 'Algoritmos e pseudocódigo', 'DISCURSIVA', 'Considere a realização de uma pesquisa com 1 000 pessoas para obtenção das seguintes informações: o valor da maior altura; o valor da menor altura; a média das alturas; quantas pessoas têm altura inferior à média das alturas.

Considere, ainda, que um programador foi selecionado para desenvolver um modelo de código que soluciona o problema automatizando a coleta das alturas e a geração das informações.', null, 'Com base nas informações apresentadas, desenvolva o código adequado para resolver o problema usando pseudocódigo ou uma linguagem de programação. (valor: 10,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão Discursiva 3 (INEP)'),
  ('80c1c033-0cf1-54d0-908c-fe9801c17b0d', 'CE', array['ADS']::public.curso_alvo[], 'Modelagem UML de classes', 'DISCURSIVA', 'Um analista de requisitos identificou as seguintes histórias de usuários para um sistema web de reserva de passagens de uma empresa aérea:
HST 01: COMO cliente, GOSTARIA de me cadastrar no site da empresa informando meu e-mail, nome, CPF, telefone e endereço PARA poder usar os serviços web da empresa.
HST 02: COMO cliente, GOSTARIA de pesquisar por preços das passagens aéreas informando data, hora, cidade e aeroporto de ida e de volta PARA poder escolher uma opção de reserva que me interessa.
HST 03: COMO cliente, GOSTARIA de confirmar uma reserva de passagem aérea selecionada, escolhendo uma das formas de pagamento disponibilizada pela empresa PARA poder viajar para o local escolhido na reserva.
HST 04: COMO cliente, GOSTARIA de fazer o check-in online da reserva PARA poder realizar meu embarque.', null, 'Tendo por base essas histórias de usuários, elabore um diagrama de classes da UML (Unified Modeling Language) para o sistema, identificando as classes (máximo seis), atributos e associações entre as classes com as respectivas multiplicidades. Deverão ser representadas as reservas de ida e de volta como classes de uma associação do tipo generalização (herança) e também ser identificados pelo menos três métodos para a classe Reserva. Para as demais classes não é necessário identificar os métodos. Também não há necessidade de identificar a multiplicidade dos atributos nas classes. (valor: 10,0 pontos).', null,
   null, null, null, null, null, 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão Discursiva 4 (INEP)'),
  ('b0ef092c-aaf4-588d-9fc6-8bfb406d9aa8', 'CE', array['ADS']::public.curso_alvo[], 'Estruturas de dados: listas encadeadas', 'DISCURSIVA', 'Com a finalidade de melhorar o atendimento e priorizar os casos mais urgentes, a direção de um hospital criou um sistema de triagem em que um profissional da saúde classifica a ordem de atendimento com base numa avaliação prévia do paciente, entregando-lhe um cartão numerado verde (V) ou amarelo (A), que define o menor ou maior grau de urgência da ocorrência, respectivamente. Para informatizar esse processo, o software desenvolvido tem como base o seguinte trecho de código-fonte:

 1 struct lista {
 2     int numero;
 3     char cor;
 4     struct lista* prox;
 5 };
 6
 7 typedef struct lista Lista;
 8
 9 Lista* inserir_fim(Lista* l, Lista* no) {
10     Lista* aux;
11
12     no->prox = NULL;
13     aux = l;
14     while (aux->prox != NULL)
15         aux = aux->prox;
16     aux->prox = no;
17
18     return l;
19 }
20
21 Lista* inserir(Lista* l, int numero, char cor) {
22     Lista* no = (Lista*) malloc(sizeof(Lista));
23     no->numero = numero;
24     no->cor = cor;
25
26     if (l == NULL) {
27         no->prox = l;
28         l = no;
29     } else {
30         if (no->cor == ''V'')
31             l = inserir_fim(l, no);
32         else
33             l = inserir_prioridade(l, no);
34     }
35
36     return l;
37 }

Na linha 21, a função inserir recebe o número e a cor do cartão entregue ao paciente na triagem. Pacientes com cartão verde são inseridos no final da fila pela função inserir_fim (linhas 9-19). Pacientes com cartão amarelo têm prioridade no atendimento e são inseridos no início da fila, em ordem de chegada, pela função inserir_prioridade. Portanto, se são entregues os cartões 10-V, 11-V, 5-A, 12-V e 6-A, nessa ordem, a fila deve ficar assim organizada:', 'enade2021/ads/ads21-d5.png', 'Considerando o processo de triagem descrito e o trecho de código-fonte apresentado, implemente a função inserir_prioridade conforme indicado.

Lista* inserir_prioridade(Lista* l, Lista* no)

(valor: 10,0 pontos)', null,
   null, null, null, null, null, 3, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão Discursiva 5 (INEP)'),
  ('6636c9a0-b05f-5050-afd1-44a7b6daafc4', 'CE', array['ADS']::public.curso_alvo[], 'Engenharia de requisitos', 'OBJETIVA', 'A etapa de definição de requisitos é voltada para estabelecer quais as funções são requeridas pelo sistema e as restrições sobre a operação e o desenvolvimento do software. Os requisitos de software podem ser classificados como requisitos funcionais e não funcionais.

SOMMERVILLE, I. Engenharia de Software, 10. ed. São Paulo: Pearson Education, 2019 (adaptado).', null, 'Considerando as informações do texto, assinale a alternativa em que o item é um requisito funcional.', null,
   'O software deve ser operacionalizado no sistema Linux.', 'O tempo de desenvolvimento não deve ultrapassar seis meses.', 'O software deve emitir relatórios de compras a cada quinze dias.', 'O tempo de resposta do sistema não deve ultrapassar 30 segundos.', 'A base de dados deve ser protegida para acesso apenas de usuários autorizados.', 1, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 09 (INEP)'),
  ('01fc6691-038f-504e-8d7d-3232ec3b524a', 'CE', array['ADS']::public.curso_alvo[], 'Programação em C: matrizes e ponteiros', 'OBJETIVA', 'Uma fábrica adquiriu máquinas de costura industrial para a produção de jogos de toalhas de mesa e guardanapos de tecido com estampas quadriculadas. Cada quadrículo tem tamanho padrão de 5 cm X 5 cm. Para a configuração da costura, é preciso um programa de computador para criar um molde em que sejam informadas as quantidades de quadrículos por comprimento e por largura, além do desenho da estampa a ser costurada. Por exemplo, para um guardanapo de tecido que tenha 30 cm X 30 cm, com uma estampa representada pelo caractere “#”, o seguinte molde precisa ser criado:', 'enade2021/ads/ads21-q10.png', 'Como uma toalha pode ter, no máximo, 250 cm de comprimento e 200 cm de largura, o programador declarou uma matriz char molde[40][50] para ser possível representar moldes cujas medidas compreendam esses limites. Ele também implementou, entre outras, as seguintes funções:

- criar_molde, para a qual os seguintes parâmetros são esperados, nessa ordem: uma referência à matriz molde, o comprimento e a largura do tecido (em quantidades de quadrículos) e o caractere que representa a estampa;
- alternar_estampa, que tem a tarefa de controlar a disposição alternada das estampas no molde.

Considerando o cenário descrito, que alternativa a seguir apresenta a implementação correta das funções criar_molde e alternar_estampa?', null,
   'char alternar_estampa(char estampa, char *proxima) {
    *proxima = *proxima == estampa ? '' '' : estampa;
    return *proxima;
}

void criar_molde(char molde[][50], int c, int l, char estampa) {
    char proxima = estampa;
    for (int i = 0; i < l; i++)
        for (int j = 0; j < c; j++)
            molde[i][j] = alternar_estampa(estampa, &proxima);
}', 'char alternar_estampa(char estampa, char proxima) {
    proxima = proxima == estampa ? '' '' : estampa;
    return proxima;
}

void criar_molde(char molde[][50], int c, int l, char estampa) {
    char proxima = estampa;
    for (int i = 0; i < l; i++)
        for (int j = 0; j < c; j++)
            molde[i][j] = alternar_estampa(estampa, proxima);
}', 'char alternar_estampa(char estampa, char *proxima) {
    return *proxima == estampa ? '' '' : estampa;
}

void criar_molde(char molde[][50], int c, int l, char estampa) {
    char proxima = estampa;
    for (int i = 0; i < l; i++)
        for (int j = 0; j < c; j++)
            molde[i][j] = alternar_estampa(estampa, &proxima);
}', 'char alternar_estampa(char estampa, char *proxima) {
    *proxima = *proxima == estampa ? '' '' : estampa;
    return *proxima;
}

void criar_molde(char molde[][50], int c, int l, char estampa) {
    char proxima = estampa;
    for (int i = 0; i < l; i++) {
        for (int j = 0; j < c; j++)
            molde[i][j] = alternar_estampa(estampa, &proxima);
        proxima = molde[i][0];
    }
}', 'char alternar_estampa(char estampa, char proxima) {
    proxima = proxima == estampa ? '' '' : estampa;
    return proxima;
}

void criar_molde(char molde[][50], int c, int l, char estampa) {
    char proxima = estampa;
    for (int i = 0; i < l; i++) {
        for (int j = 0; j < c; j++)
            molde[i][j] = alternar_estampa(estampa, proxima);
        proxima = molde[i][0];
    }
}', 3, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 10 (INEP)'),
  ('f87fd59d-8f62-514c-847e-0a8dd00b3723', 'CE', array['ADS']::public.curso_alvo[], 'Estruturas de dados: pilha', 'OBJETIVA', 'O código Java, a seguir, contém a implementação de uma Pilha utilizando a estratégia encadeada.

public class No{
  public int dado;
  public No prox;
  public No(int dado){
    this.dado = dado;
  }
}
public class PilhaEncadeada{
  private No topo;
  public int pop(){
    if (topo == null)
      return -1;
    No lixo = topo;
    topo = topo.prox;
    lixo.prox = null;
    return lixo.dado;
  }

  public int top(){
    if (topo == null)
      return -1;
    return (topo.dado);
  }
}', null, 'Com base no exposto, assinale a opção que possui a implementação correta do método push para essa Pilha.', null,
   'public void push(int elemento){
  No novo = new No(elemento);
  if(topo == null)
    topo = novo;
  else
    topo.prox = novo;
}', 'public void push(int elemento){
  No novo = new No(elemento);
  topo = novo;
}', 'public void push(int elemento){
  topo.dado = elemento;
}', 'public void push(int elemento){
  No novo = new No(elemento);
  while (topo != null)
    topo = topo.prox;
  topo.prox = novo;
}', 'public void push(int elemento){
  No novo = new No(elemento);
  novo.prox = topo;
  topo = novo;
}', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 11 (INEP)'),
  ('fbbcec2a-d3a5-592a-b2f8-f0f7238d44bd', 'CE', array['ADS']::public.curso_alvo[], 'Métodos ágeis', 'OBJETIVA', 'Uma fábrica de software está realizando entrevistas para contração de um profissional que esteja alinhado às exigências do atual mundo corporativo. Sabe-se que processos ágeis de desenvolvimento têm se tornado essenciais para empresas que desejam realizar entregas rápidas e frequentes de produtos e/ou serviços de software. Essa empresa possui uma equipe de desenvolvimento que faz uso de processos ágeis como o Scrum e eXtreme Programming (XP) e o acompanhamento por meio do quadro Kanban. Sendo assim, um conjunto de características deve ser verificado durante a entrevista para garantir que o candidato a ser contratado possua conhecimentos necessários para atuar juntamente a esta equipe.', null, 'Com base no texto e nos processos ágeis de desenvolvimento de software, avalie as afirmações a seguir.

I. Métodos Ágeis são baseados em ciclos iterativo e incremental que se concentram no desenvolvimento rápido e na flexibilidade às mudanças, com a participação do cliente no processo de software.
II. Uma forte característica da XP é a garantia da qualidade do código produzido e, para isso, os desenvolvedores produzem testes automatizados antes mesmo de codificar uma funcionalidade.
III. O planejamento no Scrum é baseado na elaboração dos itens do product backlog, que é uma lista de funcionalidades desejadas pelo cliente, sendo o Scrum Master o responsável por gerenciá-lo.
IV. O quadro Kanban permite monitorar a evolução das tarefas necessárias durante o processo ágil de desenvolvimento de software, possibilitando um acompanhamento de forma visual das atividades em construção.

É correto apenas o que se afirma em', null,
   'II.', 'I e III.', 'I, II e IV.', 'I, III e IV.', 'II, III e IV.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 12 (INEP)'),
  ('8ab6bc35-b972-5769-8633-35617f34b64d', 'CE', array['ADS']::public.curso_alvo[], 'Estruturas de dados: pilha e fila', 'OBJETIVA', 'Considere que as variáveis pilha e fila correspondem, respectivamente, às estruturas de dados do tipo Pilha e Fila. Para testar as duas estruturas, um programador realizou a série de operações a seguir.

Pilha pilha = new Pilha();
Fila fila = new Fila();
pilha.push(‘A’);
pilha.push(‘B’);
pilha.push(‘C’);
fila.enqueue(pilha.top());
fila.enqueue(pilha.top());
fila.enqueue(‘D’);
pilha.push(fila.dequeue());
fila.enqueue(fila.dequeue());
fila.enqueue(pilha.pop());
pilha.push(‘E’);
fila.enqueue(‘E’);
pilha.pop();', null, 'Após essas operações, ao imprimir o conteúdo de pilha e fila, respectivamente, seria exibido:', null,
   'pilha: topo → C → A → E.
fila: início → D → A → A → E.', 'pilha: topo →A.
fila: início → D → B → C → E.', 'pilha: topo → C → B → A.
fila: início → D → C → C → E.', 'pilha: topo → B → A.
fila: início → D → B → C → E.', 'pilha: topo → C → B → A.
fila: início → D → B → C → E.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 13 (INEP)'),
  ('a83d4f98-ab34-5798-b4eb-47974624fc1c', 'CE', array['ADS']::public.curso_alvo[], 'Gerenciamento de projetos', 'OBJETIVA', 'Um projeto de integração de um ERP com um CRM não implementou todos os serviços esperados e há falhas nos serviços já implementados. Uma auditoria avaliou a situação e identificou que há desentendimentos entre os membros da equipe; os membros da qualidade não compreendem o que deve ser avaliado; demandas de novos solicitantes aparecem constantemente; e o patrocinador demora muito a responder às solicitações da equipe. Tudo isso fez com que o projeto ficasse bastante atrasado e com orçamento excedido.', null, 'Considerando o cenário descrito, o gerente de projeto deve priorizar o gerenciamento de', null,
   'custo.', 'tempo.', 'escopo.', 'qualidade.', 'partes interessadas.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 14 (INEP)'),
  ('184bfbb4-24a1-5382-ab6e-faa9bc3179e7', 'CE', array['ADS']::public.curso_alvo[], 'Modelagem UML de classes', 'OBJETIVA', 'Uma fundação municipal de arte e cultura oferece cursos para crianças e adolescentes de até 16 anos. Os registros de matrículas são realizados em uma planilha eletrônica ilustrada a seguir, o que dificulta bastante o controle dos dados frente ao número expressivo de estudantes, muitos dos quais solicitam matrícula em mais de um curso. A administração da fundação, então, solicitou o desenvolvimento de um programa para facilitar o registro e a consulta desses dados, incluindo-se a data de efetivação de cada matrícula, para fins de controles específicos da secretaria.', 'enade2021/ads/ads21-q15.png', 'A equipe de desenvolvimento de softwares da prefeitura, após uma breve entrevista com a administração da fundação e de posse da planilha eletrônica, modelou um Diagrama de Classes como parte da especificação dos requisitos do sistema.

Considerando o cenário descrito, assinale a opção a seguir que exibe o Diagrama de Classes modelado corretamente pela equipe de desenvolvimento.', 'enade2021/ads/ads21-q15-alt.png',
   'Opção A — ver figura das alternativas', 'Opção B — ver figura das alternativas', 'Opção C — ver figura das alternativas', 'Opção D — ver figura das alternativas', 'Opção E — ver figura das alternativas', 3, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 15 (INEP)'),
  ('c0a3dff4-229f-586e-a40f-5e8ddabfdf6d', 'CE', array['ADS']::public.curso_alvo[], 'UML: diagrama de sequência', 'OBJETIVA', 'Uma ONG decidiu construir um hospital de campanha para tratamento de pacientes diagnosticados com a Covid-19. Para auxiliar na gerência hospitalar, a ONG contratou alguns programadores voluntários para desenvolver um Sistema de Suporte à Decisão para Gestão Hospitalar. Esse sistema irá auxiliar no registro de todos os procedimentos diários realizados no paciente que dá entrada no hospital, desde sua internação até a saída, seja essa saída por recebimento de alta, por transferência ou óbito. O sistema foi todo desenvolvido em Java de acordo com o Paradigma Orientado a Objetos. Durante o curto processo de análise, devido à urgência, foram construídos diversos diagramas em UML (Unified Modeling Language). Um desses diagramas relaciona a interação entre os objetos do sistema, o Diagrama de Sequência. Esse diagrama é apresentado a seguir.', 'enade2021/ads/ads21-q16.png', 'Considerando o Diagrama de Sequência apresentado, assinale a opção correta.', null,
   'Leito é uma subclasse de UTI.', 'O método registraPaciente() é implementado por Paciente.', 'Todos os objetos foram criados no instante de execução do Caso de Uso representado.', 'O diagrama apresenta um erro ao não representar as mensagens de retorno depois da destruição dos objetos.', 'A mensagem 4 pode ser substituída pelo estereótipo <<create>> sem causar prejuízo à interpretação correta do Diagrama de Sequência representado.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 16 (INEP)'),
  ('3fdd3afb-4759-56ee-8913-d9a3e9afaac8', 'CE', array['ADS']::public.curso_alvo[], 'Banco de dados: SQL', 'OBJETIVA', 'O modelo de dados relacional a seguir representa de forma simplificada o banco de dados para um sistema de informação bancário:', 'enade2021/ads/ads21-q17.png', 'Usando a linguagem SQL (Structured Query Language) indique a consulta que recupera o nome dos clientes e o valor médio movimentado por eles em sua conta até o momento. Primeiro devem ser exibidos os clientes com maior média de valor movimentado.', null,
   'SELECT CL.NOME, HM.VAL_MOVIMENTADO
FROM CLIENTE CL INNER JOIN CONTA CO ON CL.COD_CLIENTE = CO.COD_CLIENTE
INNER JOIN HISTORICO_MOVIMENTACAO HM ON CO.NUM_CONTA = HM.NUM_CONTA
ORDER BY HM.VAL_MOVIMENTADO', 'SELECT CL.NOME, AVG(HM.VAL_MOVIMENTADO)
FROM CLIENTE CL INNER JOIN CONTA CO ON CL.COD_CLIENTE = CO.COD_CLIENTE
INNER JOIN HISTORICO_MOVIMENTACAO HM ON CO.NUM_CONTA = HM.NUM_CONTA
ORDER BY HM.VAL_MOVIMENTADO DESC', 'SELECT CL.NOME, AVG(HM.VAL_MOVIMENTADO)
FROM CLIENTE CL INNER JOIN CONTA CO ON CL.COD_CLIENTE = CO.COD_CLIENTE
INNER JOIN HISTORICO_MOVIMENTACAO HM ON CO.NUM_CONTA = HM.NUM_CONTA
GROUP BY CL.COD_CLIENTE, CL.NOME
ORDER BY AVG(HM.VAL_MOVIMENTADO) DESC', 'SELECT CL.NOME, AVG(HM.VAL_MOVIMENTADO)
FROM CLIENTE CL LEFT OUTER JOIN CONTA CO ON CL.COD_CLIENTE = CO.NUM_CONTA
LEFT OUTER JOIN HISTORICO_MOVIMENTACAO HM ON CO.NUM_CONTA = HM.COD_HISTORICO_MOVIMENTACAO
GROUP BY CL.NOME
ORDER BY AVG(HM.VAL_MOVIMENTADO) DESC', 'SELECT CL.NOME, AVG(HM.VAL_MOVIMENTADO)
FROM CLIENTE CL LEFT OUTER JOIN CONTA CO ON CL.COD_CLIENTE = CO.COD_CLIENTE
LEFT OUTER JOIN HISTORICO_MOVIMENTACAO HM ON CO.NUM_CONTA = HM.NUM_CONTA
GROUP BY CL.NOME
ORDER BY AVG(HM.VAL_MOVIMENTADO) DESC', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 17 (INEP)'),
  ('9dd85e41-f184-5550-bbbf-d0f7e75a46ca', 'CE', array['ADS']::public.curso_alvo[], 'Engenharia de requisitos', 'OBJETIVA', 'A engenharia de requisitos é uma área que inclui quatro subprocessos relacionados de alto nível. Esses subprocessos são: 1) avaliação se o sistema será útil para a empresa (estudo de viabilidade); 2) obtenção de requisitos (elicitação de requisitos); 3) conversão desses requisitos em alguma forma padrão (especificação); 4) verificação se os requisitos realmente definem o sistema que o cliente deseja (validação).

SOMMERVILLE, I. Engenharia de Software. São Paulo: Pearson Addison-Wesley, 2017 (adaptado).

Uma equipe de Tecnologia da Informação de uma empresa de consultoria desenvolverá um software de Suporte Técnico para uma grande empresa fornecedora de equipamentos eletrônicos. O estudo de viabilidade do software já foi realizado e aprovado. A equipe de Tecnologia da Informação seguirá os três subprocessos seguintes de alto nível de engenharia de requisitos descritos no texto de Sommerville, ou seja, os subprocessos de elicitação de requisitos, especificação e validação.', null, 'Para esses três subprocessos, quais são os artefatos que podem ser utilizados por essa equipe de Tecnologia da Informação?', null,
   'Documento de entrevista com usuários; modelo de caso de uso para os requisitos funcionais; prototipação de telas.', 'Documento de estudo de viabilidade; modelo de caso de uso para os requisitos funcionais; prototipação de telas.', 'Matriz de rastreabilidade; modelo de caso de uso para os requisitos não-funcionais; prototipação de telas.', 'Documento de entrevista com usuários; modelo de caso de uso para os requisitos não-funcionais; matriz de rastreabilidade.', 'Documento de estudo de viabilidade; modelo de caso de uso para os requisitos funcionais; matriz de rastreabilidade.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 18 (INEP)'),
  ('fea0ce34-c974-557e-bea8-5f83b72bd240', 'CE', array['ADS']::public.curso_alvo[], 'Arquitetura de software', 'OBJETIVA', 'Arquitetura de software é uma representação que permite analisar a efetividade do projeto no entendimento dos requisitos declarados. Durante a fase de concepção da arquitetura, podem-se considerar alternativas de arquitetura em um estágio em que mudanças ainda são realizadas com menor esforço, diminuindo riscos associados à construção do software ainda na fase inicial.

PRESSMAN, R. S. Engenharia de Software: uma abordagem profissional. 8. ed. Porto Alegue: AMGH, 2016 (adaptado).', null, 'A respeito dos estilos e padrões arquiteturais contidos na engenharia de software, avalie as afirmações a seguir.

I. Em arquiteturas orientadas a objetos, a comunicação entre os componentes do software é realizada por intermédio da troca de mensagens.
II. As arquiteturas monolíticas consistem de um sistema dividido em pequenas partes, possibilitando que estas tenham sua manutenção, execução e evolução individual.
III. No padrão arquitetural Modelo-Visão-Controle (MVC), a camada de Modelo armazena as interações realizadas no Controle, podendo ser apresentados/manipulados posteriormente na Visão.
IV. Nas arquiteturas microsserviços, o software possui componentes altamente acoplados, dificultando a manutenção.

É correto apenas o que se afirma em', null,
   'I e III.', 'II e III.', 'II e IV.', 'I, II e IV.', 'I, III e IV.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 19 (INEP)'),
  ('20165afd-fcc1-59b4-bfd0-5ca2ae9f29f5', 'CE', array['ADS']::public.curso_alvo[], 'Interação humano-computador', 'OBJETIVA', 'Uma secretaria municipal de esportes decidiu criar e disponibilizar um site que sirva como portal de comunicação com pessoas da terceira idade. A finalidade é fornecer orientações que propiciem práticas para uma vida mais saudável, além de divulgar eventos esportivos ofertados pelo município para esse público-alvo. O projeto ainda prevê a interação entre os usuários do site, por meio da publicação de fotos, que podem ser curtidas e comentadas.

A iniciativa de criação do site foi embasada em uma pesquisa mostrando que a maioria da população de terceira idade do município dispõe de acesso à internet, especialmente por meio de dispositivos móveis (smartphones e tablets), embora uma parcela dessa população prefira realizar o acesso com computadores de mesa e notebooks.', null, 'Considerando as informações do texto e as responsabilidades inerentes ao desenvolvimento do site, avalie as afirmações a seguir.

I. A segurança no uso é um fator crítico de usabilidade a ser considerado no projeto de interface para o site, tendo em vista que pessoas da terceira idade são temerosas quanto ao registro de dados pessoais e confidenciais em sites e aplicativos.
II. A responsividade, que pressupõe o uso de valores relativos para definir as dimensões de elementos na estilização de páginas HTML, deve ser considerada na construção do site, tendo em vista que o acesso deve ocorrer através de dispositivos com diferentes tamanhos de tela.
III. A construção de protótipos pode antecipar problemas de design de interação e minimizar custos de desenvolvimento e, por isso, é viável para estabelecer uma comunicação mais objetiva com o público-alvo e assim possibilitar a validação de usabilidade e da experiência do usuário.
IV. O design participativo é um processo de design de Interação Humano-Computador (IHC) viável para direcionar o projeto de interfaces e de experiência com o usuário do site, pois o público-alvo tende a apresentar dificuldades no manuseio de tecnologias da informação e da comunicação.

É correto apenas o que se afirma em', null,
   'I e II.', 'I e III.', 'II e IV.', 'I, III e IV.', 'II, III e IV.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 20 (INEP)'),
  ('84740262-503c-5fb8-8693-69739d1895e2', 'CE', array['ADS']::public.curso_alvo[], 'Gerência de configuração', 'OBJETIVA', 'No decorrer de um projeto de desenvolvimento de software é compreensível que mudanças venham a ocorrer, sejam por novos entendimentos dos atores envolvidos ou até mesmo de novas demandas apresentadas pelos clientes. Nesta perspectiva, a Gestão de Configuração de Software estabelece um conjunto de atividades para gerenciar alterações através de todo o ciclo de vida de um software.

PRESSMAN, R. S. Engenharia de Software: uma abordagem profissional. 8. ed. Porto Alegre: Artmed Editora S.A. e McGraw-Hill Education, 2016 (adaptado).', null, 'Com base no texto, assinale a opção correta acerca das atividades de gestão de configuração de software.', null,
   'Identificação de itens na configuração de software, gerenciamento de alterações, validação de versões e controle de qualidade.', 'Identificação de objetos na configuração de software, controle de versão, controle de alterações, auditoria de configuração e relatório de status.', 'Gerência de projeto, gerência de configuração de software, ciclo de vida do projeto, processo de software e evolução das configurações.', 'Construção de modelo de requisitos, métricas para modelo de projeto, métricas de controle de versão e relatório de manutenção.', 'Identificação de alterações, controle de versão, mapeamento de alteração e notificação da alteração aos envolvidos.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 21 (INEP)'),
  ('371754ac-0642-547e-bceb-10a8df7c37c8', 'CE', array['ADS']::public.curso_alvo[], 'Gerência de configuração', 'OBJETIVA', 'Um ponto importante para fábricas de software é a garantia de que seus produtos e/ou serviços acompanhem as diversas mudanças ocasionadas pelo mundo corporativo. As restrições de orçamento ou cronograma, reestruturação do negócio, modificações de regras de negócio ou novas necessidades do cliente, geram mudanças inevitáveis. Nesse cenário, a utilização de um processo de Gerência de Configuração de Software (GCS) que contemple características necessárias para gerenciar e controlar a evolução de um software, através do controle formal de versão e solicitação de mudanças, é extremamente importante.', null, 'Sobre o processo de Gerência de Configuração de Software (GCS), avalie as afirmações a seguir.

I. O controle de versão possibilita o compartilhamento de dados e a edição colaborativa, permitindo a gestão de diferentes ramos de desenvolvimento e possibilitando a existência de diferentes versões de forma simultânea.
II. A auditoria de configuração é uma atividade de garantia de qualidade do sistema que tem por objetivo assegurar que a qualidade do software seja mantida quando feitas alterações requisitadas.
III. O relatório de status de configuração possui informações sobre o GCS, tendo por objetivo manter o cliente informado sobre as alterações, e deve ser gerado ao final do processo.
IV. A GCS proporciona um conjunto de atividades de acompanhamento e controle de mudanças que é iniciado logo depois que o software for fornecido ao cliente e colocado em operação.

É correto apenas o que se afirma em', null,
   'I e II.', 'II e III.', 'III e IV.', 'I, II e IV.', 'I, III e IV.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 22 (INEP)'),
  ('40cdc04e-ebe2-5429-a2d3-2d926264bc8c', 'CE', array['ADS']::public.curso_alvo[], 'Manutenção de software', 'OBJETIVA', 'A evolução de sistemas de software legados pode ser dividida em três categorias: manutenção, modernização e substituição. De acordo com a figura a seguir, conforme o tempo aumenta, a quantidade de funcionalidades também cresce. No primeiro período de evolução a manutenção é realizada, pois as necessidades de negócio são alteradas e o sistema precisa suprir as mudanças por meio da manutenção. No segundo período é realizada a modernização do sistema, pois as necessidades de negócio continuam a crescer, mas há mudanças mais significativas que se fazem necessárias. Além da substituição do sistema de software, nos casos em que o modelo de negócio não atende mais a necessidade da empresa, a manutenção e modernização também não são mais suficientes.

SEACORD, R. C.; PLAKOSH, D.; LEWIS, G. A. Modernizing Legancy Systems. Boston: Pearson Education, 2003 (adaptado).', 'enade2021/ads/ads21-q23.png', 'De acordo com a figura apresentada e considerando um sistema de software implantado de ERP (Enterprise Resource Planning - Planejamento de Recursos Empresariais) contendo um conjunto de módulos que integra todos os departamentos existentes de uma empresa, observou-se a necessidade de criação de um relatório gerencial de comissão da equipe de vendas. Nesse contexto, é correto afirmar que a manutenção a ser realizada é', null,
   'corretiva.', 'evolutiva.', 'funcional.', 'preventiva.', 'adaptativa.', 1, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 23 (INEP)'),
  ('3f368c08-94a8-56a8-af68-ed997afb384f', 'CE', array['ADS']::public.curso_alvo[], 'Teste de software', 'OBJETIVA', 'Em razão da Covid-19, muitos estabelecimentos viram no delivery uma forma de manter os negócios funcionando. As mudanças de hábitos dos brasileiros revelaram um aumento do interesse nesse tipo de serviço.

Nesse contexto, um restaurante solicitou o desenvolvimento de um sistema web que possibilite gerenciar automaticamente os pedidos de entrega. O sistema foi projetado com base em tecnologias web e modelado com UML (Unified Modeling Language). Durante o processo de desenvolvimento foram descritos alguns itens importantes que merecem atenção no processo de teste de software.

Considerem as seguintes descrições definidas pelo analista de teste:
01 – Verificar se o método “Finalizar Pedido” da classe “Pedido” está funcionando corretamente.
02 – Garantir que o sistema funcione corretamente em diferentes navegadores de internet.
03 – O sistema deve passar por testes rigorosos na estrutura lógica interna do software.
04 – O sistema deve garantir, no mínimo, o registro de 100 pedidos simultâneos.
05 – O usuário deve testar o sistema em um ambiente controlado sob a supervisão dos desenvolvedores.', null, 'Considerando o texto e as descrições apresentadas, avalie as afirmações a seguir.

I. A descrição 01 deve ser verificada com teste unitário.
II. A descrição 02 deve ser executada com a abordagem caixa-branca.
III. A descrição 03 deve ser executada com a abordagem caixa-preta.
IV. A descrição 04 deve ser verificada com teste carga.
V. A descrição 05 deve ser classificada como teste alfa.

É correto apenas o que se afirma em', null,
   'II e III.', 'I, II e IV.', 'I, III e V.', 'I, IV e V.', 'II, III, IV e V.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 24 (INEP)'),
  ('f4274832-b451-57f2-b9ee-f500ca900944', 'CE', array['ADS']::public.curso_alvo[], 'Processos de desenvolvimento de software', 'OBJETIVA', 'Uma determinada empresa do ramo de piscicultura solicitou a uma instituição especializada no desenvolvimento de softwares de gestão a construção de um sistema que fosse capaz de gerenciar o processo de criação dos peixes, que começava ainda na fase de alevinos, estendia-se para a engorda, finalizando na fase adulta com a venda do peixe. O sistema deveria disponibilizar funcionalidades para armazenar informações sobre toda a etapa da criação, mortandade e rações utilizadas na engorda dos peixes, viabilizando uma melhor tomada de decisão dos investidores. Como não havia nenhuma solução e a demanda por peixes estava aumentando, a empresa solicitou extrema urgência na construção da aplicação.', null, 'Considerando o processo de desenvolvimento de software que deverá ser utilizado para construir o sistema mencionado no texto, avalie as afirmações a seguir.

I. Para desenvolver o sistema, deve ser adotado um processo baseado no modelo cascata, pois ele se adapta melhor a cenários com muitas mudanças.
II. Por se tratar de uma aplicação com escopo pequeno, o modelo espiral deverá ser utilizado no desenvolvimento do sistema solicitado, já que reduzirá riscos por meio da prototipação de especificações de cada fase dos peixes e diminuirá o tempo de entrega.
III. O modelo incremental deve ser utilizado na construção do software descrito no cenário, já que partes do sistema referentes à fase inicial dos peixes poderiam ser disponibilizadas, enquanto as demais estão nas etapas de concepção e desenvolvimento.
IV. Em razão da extrema urgência no desenvolvimento do software solicitado, a empresa deve elaborar seu processo utilizando o modelo RAD (Rapid Application Development).

É correto apenas o que se afirma em', null,
   'I.', 'IV.', 'I e II.', 'II e III.', 'III e IV.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 25 (INEP)'),
  ('58edc0fe-4af5-51ec-ac1a-6e73248a644f', 'CE', array['ADS']::public.curso_alvo[], 'LGPD e empreendedorismo', 'OBJETIVA', 'Empreender em computação não se resume apenas ao fato de ter uma ideia sobre um aplicativo, implementá-la e disponibilizá-la aos seus usuários finais. Esse conceito vai além, é preciso analisar uma série de variáveis, como questões sociais e humanísticas, profissionais, ambientais, legais, políticas e tecnológicas.

Dentre as ações necessárias para empreender em computação, é imprescindível observar a legislação vigente. No Brasil, a Lei Geral de Proteção de Dados Pessoais (LGPD), n. 13.709/2018, dispõe sobre o tratamento de dados pessoais, inclusive nos meios digitais, por pessoa natural ou por pessoa jurídica de direito público ou privado, com o objetivo de proteger os direitos fundamentais de liberdade e de privacidade e o livre desenvolvimento da personalidade da pessoa natural.', null, 'Acerca das providências dispostas no art. 2º da LGPD, assinale os fundamentos da disciplina da proteção de dados pessoais.', null,
   'O direito ao usuário; das obrigações das organizações nacionais ou estrangeiras; obrigatoriedade do consentimento; a livre iniciativa, a livre concorrência e a defesa do consumidor; os direitos humanos, o livre desenvolvimento da personalidade, a dignidade e o exercício da cidadania pelas pessoas naturais e regulação da Autoridade Nacional de Proteção de Dados Pessoais (ANPD).', 'O direito à revogação de um consentimento; a transferência de dados para outro fornecedor de serviços; a solicitação de remoção de dados pessoais; a inviolabilidade da intimidade, da honra e da imagem; o desenvolvimento econômico e tecnológico e inovação; a preservação da vida e da integridade física de uma pessoa.', 'O respeito à privacidade; obrigatoriedade do consentimento; os deveres e obrigações dos usuários finais; os deveres e obrigações das organizações nacionais ou estrangeiras; a observação ao código de defesa do consumidor; e, a obrigatoriedade do respeito à honra e à imagem.', 'O direito ao anonimato; a liberdade de expressão; a inviolabilidade da intimidade; a adoção de medidas preventivas de segurança; o direito ao recurso e revisão; a administração de riscos e falhas; o estabelecimento de agentes de tratamento; e, regulação da Autoridade Nacional de Proteção de Dados Pessoais (ANPD).', 'O respeito à privacidade; a autodeterminação informativa; a liberdade de expressão, de informação, de comunicação e de opinião; a inviolabilidade da intimidade, da honra e da imagem; o desenvolvimento econômico e tecnológico e a inovação; a livre iniciativa, a livre concorrência e a defesa do consumidor; e, os direitos humanos, o livre desenvolvimento da personalidade, dignidade e o exercício da cidadania pelas pessoas naturais.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 26 (INEP)'),
  ('92c70bcf-0848-58ba-9156-32a380e169b2', 'CE', array['ADS']::public.curso_alvo[], 'Sistemas de numeração', 'OBJETIVA', 'O sistema de numeração, inserido na arquitetura e no funcionamento dos computadores, sempre foi muito utilizado na área computacional e pode ser escrito em diferentes bases numéricas, como: binária, octal, decimal ou hexadecimal. Durante a execução dos programas, a Unidade Central de Processamento (CPU) trabalha com os dados e instruções convertidos para dois estados distintos: 0 (zero) e 1 (um), que podem ser entendidos como “com energia” e “sem energia”, a chamada linguagem binária ou 0 e 1. Durante o processamento dos dados, instruções e os dados são armazenados no formato binário na memória principal do computador. A CPU, trabalhando com dados no formato binário, aumenta sua capacidade e velocidade no processamento dos dados.

Alguns exemplos dos dados, representados em diferentes bases, são utilizados nos sistemas computacionais diariamente: o endereçamento IP dos computadores em uma rede são configurados na base decimal pontuada se for o IPv4, exemplo: 192.168.70.10; o número do endereço MAC-Address da placa de rede do computador é hexadecimal, exemplo: 00-15-5D-01-F2-00; já o sistema octal foi muito utilizado na computação, como uma alternativa mais compacta do sistema binário, na programação em linguagem de máquina.

Os profissionais que atuam na área da Tecnologia da Informação (TI) precisam constantemente interpretar, fazer cálculos ou converter dados entre as bases binária, decimal, octal ou hexadecimal. A tabela abaixo mostra os dígitos, a notação e alguns exemplos nas bases numéricas: 2, 8, 10 e 16.

STALLINGS, W. Arquitetura e Organização de Computadores. São Paulo: Pearson Education do Brasil, 2017 (adaptado).', 'enade2021/ads/ads21-q27.png', 'Fazendo a conversão da soma de: (1001)₂ + (15)₈ + (FF)₁₆, qual é o número equivalente na base decimal?', null,
   '(188)₁₀', '(215)₁₀', '(277)₁₀', '(316)₁₀', '(345)₁₀', 1, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 27 (INEP)'),
  ('0bf21b2a-a8d3-51c1-a7d5-f2bc90ce191f', 'CE', array['ADS']::public.curso_alvo[], 'Sistemas operacionais', 'OBJETIVA', 'O modo clássico de encarar um sistema operacional é como um gerenciador de recursos. Desse ponto de vista, o sistema operacional é responsável pelo hardware do sistema. Nesse papel, ele recebe solicitações de acesso a recursos por parte das aplicações e concede ou nega tais acessos. Ao conceder solicitações de alocação, ele deve dispor com cuidado os recursos, de modo que os programas não interfiram uns nos outros.

Por exemplo, é uma péssima ideia permitir que os programas tenham acesso sem restrição à memória uns dos outros. Se um programa com defeito (ou malicioso) escreve no espaço de memória do outro programa, o segundo programa travará, na melhor das hipóteses, ou produzirá resultados incorretos, na pior das hipóteses. Ou ainda, se o programa ofensivo modificar a memória do sistema operacional poderá afetar o comportamento de todo o sistema.

STUART. B. L. Princípios de Sistemas Operacionais: projetos e aplicações. São Paulo: Cengage Learning, 2011 (adaptado).', null, 'Considerando que o texto alerta para a possibilidade de um programa interferir no outro, a atividade que um sistema operacional garante essa proteção é', null,
   'o programa antivírus.', 'o gerenciamento de memória.', 'o gerenciamento de arquivos.', 'o gerenciamento de processos.', 'o gerenciamento de entrada e saída.', 1, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 28 (INEP)'),
  ('cc6eaa98-255d-53ba-930c-38fb8c730154', 'CE', array['ADS']::public.curso_alvo[], 'Algoritmos e matrizes', 'OBJETIVA', 'Um algoritmo é qualquer procedimento computacional bem definido que toma algum valor ou conjunto de valores como entrada e produz algum valor ou conjunto de valores como saída.

CORMEN, T. H. et al. Algoritmos Teoria e Prática. Rio de Janeiro: Elsevier, 2002 (adaptado).

Considere o algoritmo a seguir.

Algoritmo Calcular
   var
      mat [1..3][1..5] de inteiro =
      {{1, 2, -1, 2, 3}, {1, -3, 4, 2, 0}, {-3, 5, 2, 3, 4}}
      sl[1..3] de inteiro = {0, 0, 0}
      x, i, j : inteiro
      x <- 0
   início
      para i <- 1 até 3 faça
          para j <- 1 até 5 faça
             sl[i] <- sl[i] + mat[i][j]
          fimpara
          x <- x + sl[i]
      fimpara
      imprima x
   fim', null, 'No fim da execução do código apresentado, será exibido o valor', null,
   '4.', '7.', '11.', '22.', '30.', 1, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 29 (INEP)'),
  ('a08496d2-e1c1-53ea-ad74-2916c8bb47ef', 'CE', array['ADS']::public.curso_alvo[], 'Redes de computadores', 'OBJETIVA', 'Suponha que sua faculdade tendo, em sua rede de computadores, máquinas que compartilham arquivos e serviços, contratou você para uma consultoria de TI. Atualmente, na sala dos professores, existem 3 máquinas ligadas à rede, com as configurações conforme a imagem a seguir. Porém, a estação de trabalho “PROFESSORES01” não consegue enviar documentos para impressão em uma impressora, corretamente instalada e compartilhada na estação de trabalho “PROFESSORES03”.', 'enade2021/ads/ads21-q30.png', 'Nesse caso, que alteração deve ser realizada para que o problema seja resolvido?', null,
   'Alterar o gateway da estação PROFESSORES03 para 175.16.10.200.', 'Alterar o endereço de IP da estação PROFESSORES01 para 175.16.30.200.', 'Alterar a máscara de sub-rede da estação PROFESSORES01 para 255.255.0.0.', 'Alterar a máscara de sub-rede da estação PROFESSORES03 para 255.255.255.0.', 'Alterar o gateway da estação PROFESSORES01 para o endereço de IP 175.16.30.200.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 30 (INEP)'),
  ('4c28ea9f-b6ea-586d-93c8-d14dcee07eaf', 'CE', array['ADS']::public.curso_alvo[], 'UML – casos de uso', 'OBJETIVA', 'Foi solicitado o desenvolvimento de um software para o controle e gestão das matrículas dos alunos em uma universidade. Os alunos poderão realizá-las diretamente no sistema, em um terminal a ser disponibilizado na universidade. Além dessas características, o sistema deverá considerar as restrições representadas no diagrama a seguir:', 'enade2021/ads/ads21-q31.png', 'Com base no texto e no diagrama, avalie as afirmações a seguir.

I. O aluno poderá realizar a matrícula fora do prazo e as tratativas são as mesmas da matrícula feita dentro do prazo.
II. O aluno poderá, opcionalmente, realizar a matrícula fora do prazo.
III. O sistema, obrigatoriamente, deverá validar o aluno que realizar a matrícula fora do prazo.
IV. A validação do aluno deverá ser feita a partir da sua matrícula informada no sistema.
V. A validação do aluno, a ser feita por retina, é diferente da validação feita pela digital.

É correto apenas o que se afirma em', null,
   'I e IV.', 'I, II e IV.', 'I, III e V.', 'II, III e V.', 'II, III, IV e V.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 31 (INEP)'),
  ('3f3de941-29ea-5306-9d46-2b00a1bdf703', 'CE', array['ADS']::public.curso_alvo[], 'Empreendedorismo e Canvas', 'OBJETIVA', 'Um modelo de negócios descreve a lógica de criação, entrega e captura de valor por parte de uma organização. A ferramenta de geração de modelo de negócios Canvas, desenvolvida por Osterwalder, tem sido uma das mais utilizadas, principalmente entre as startups. O Canvas é dividido em nove componentes básicos, que cobrem as quatro áreas principais de um negócio: clientes, oferta, infraestrutura e viabilidade financeira. Os componentes são os seguintes: 1) segmentos de clientes; 2) proposta de valor; 3) canais; 4) relacionamento com cliente; 5) fontes de receita; 6) recursos principais; 7) atividades-chave; 8) parcerias principais; e 9) estrutura de custo.

OSTERWALDER, A.; PIGNEUR, Y. Business Model Generation - Inovação em Modelos de Negócios: um manual para visionários, inovadores e revolucionários. Rio de Janeiro: Alta Books, 2011 (adaptado).', null, 'Diante deste contexto, conclui-se que as startups', null,
   'financeiras desenvolvem primeiro o plano de negócios, para em seguida partir para o Canvas.', 'de big data utilizam o Canvas para a modelagem da validação da ideia de negócio, ou seja, do problema a ser resolvido.', 'de educação dispensam a utilização do Canvas, ou seja, os modelos de negócios deste segmento já nascem validados.', 'de logística utilizam o plano de negócios ao invés do Canvas, ou seja, elas nascem a partir de um produto mínimo viável (MVP).', 'de impacto social podem desconsiderar o componente 1 (segmentos de clientes), pois possuem somente um segmento.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 32 (INEP)'),
  ('dade7e91-361a-5d1c-b7e6-d38a432a2825', 'CE', array['ADS']::public.curso_alvo[], 'Qualidade de processo – CMMI', 'OBJETIVA', 'Um dos fatores essenciais para o sucesso de um Processo de Software é a habilidade de capturar e gerenciar as mudanças e oportunidades de negócio. Muitas vezes as oportunidades de negócio são perdidas em função do tempo requerido para efetivar mudanças nos sistemas de software ou em função de defeitos nesse sistema. Basicamente, o software é o Produto do Processo de Software. Assim, identificar o grau de desenvolvimento do processo de software de uma empresa é o passo inicial para o seu melhoramento. O Modelo de Maturidade da Capacidade (CMMi) descreve práticas, processos e atividades de gestão, guiando o melhoramento do Processo de Software para atingir o mais elevado nível de maturidade da capacidade.', null, 'Considerando os diversos aspectos do processo de desenvolvimento de um produto ou sistema de software, avalie as afirmações a seguir.

I. A maturidade implica no crescimento da capacidade e indica tanto a efetividade do Processo de Software quanto o grau de consistência com que este é aplicado nos diferentes projetos desenvolvidos pela organização.
II. A maturidade do Processo de Software implica melhorias contínuas do processo com base em etapas evolutivas que se caracterizam pela capacidade de inovação e absorção de novas tecnologias.
III. A maturidade do Processo de Software implica na sua institucionalização por meio de políticas e padrões organizacionais levando a uma cultura corporativa de métodos, práticas e procedimentos com efetividade plenamente reconhecida.
IV. Cada nível do CMMi implica na satisfação de um conjunto de metas de processo que estabilizam um componente importante do Processo de Software e representa o seu estágio de maturidade da capacidade.

É correto apenas o que se afirma em', null,
   'III.', 'I e II.', 'II e IV.', 'I, III e IV.', 'I, II, III e IV.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 33 (INEP)'),
  ('f79972c8-f314-560f-b3c8-f345a0a02af7', 'CE', array['ADS']::public.curso_alvo[], 'Sistemas especialistas', 'OBJETIVA', 'Sistemas especialistas são aqueles que fazem uso intensivo do conhecimento especializado para resolver problemas de modo semelhante àquele de um especialista humano. Uma das diversas utilizações de sistemas especialistas é na elaboração de diagnósticos destinados a inferir sobre o mau funcionamento de um sistema, a partir de observações, de modo a prescrever soluções para a anomalia detectada. A medicina, atualmente, já se beneficia do uso de sistemas especialistas em conjunto com técnicas de inferência estatística.

Uma das formas de trabalhar com sistemas especialistas é por meio do uso de “regras de produção”, que são instruções do tipo “se - então”. As regras de produção aplicam-se à memória de trabalho, que contém dados, e se tiverem êxito, contribuirão com alguma nova informação para a memória.

A metodologia de trabalho de um médico do serviço de emergência inclui a utilização de um sistema especialista para diagnóstico de dengue, para o qual se encontra a seguinte regra de produção.

Se ((temperatura > 38º) e (dores musculares intensas))
então (quadro de dengue, com 70% de chance);
senão(quadro de resfriado comum com 30% de chance);', null, 'Levando em conta a regra de produção do sistema especialista utilizado pelo médico, é correto afirmar que', null,
   'cada pessoa que procura atendimento apresentando ambos os sintomas, possui a probabilidade “0,7” de estar contaminada pela dengue.', 'se 50 pessoas procurarem o atendimento apresentando um dos dois sintomas, provavelmente 15 pessoas estarão com resfriado comum.', 'se 100 pessoas procurarem o atendimento apresentando ambos os sintomas, a quantidade de pessoas com dengue será igual a 70.', 'cada pessoa que chega apresentando um dos dois sintomas estará com resfriado comum.', 'a cada 100 pessoas que procuram atendimento, no máximo 30 estarão doentes.', 2, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 34 (INEP)'),
  ('f0228ba3-a6f0-5df2-bd26-b8c04abc0943', 'CE', array['ADS']::public.curso_alvo[], 'Lógica de predicados e programação', 'OBJETIVA', 'Uma equipe de matemáticos foi contratada para proceder com a análise e especificação de critérios para a identificação de potenciais clientes para uma empresa de seguros. Após a análise, a equipe determinou que deve-se considerar as seguintes variáveis:
a) ser maior de idade.
b) possuir residência própria ou não.
c) possuir algum parente que já possui seguro da companhia.

Em função da análise realizada, a companhia pretende estipular a viabilidade ou não do seguro, além de decidir seu preço. A equipe contratada modelou cada variável identificada utilizando as seguintes funções booleanas.

I(x): função que verifica se a pessoa x é maior de idade.
R(x): função que verifica se a pessoa x possui residência própria.
P(x,y): função que verifica se as pessoas x e y são parentes.
S(x): função que verifica se a pessoa x já possui seguro da companhia.

Após essa modelagem matemática, a seguinte tabela foi obtida. Ela expressa, utilizando a notação de lógica quantitativa, os critérios para estabelecimento de viabilidade e eventuais preços de seguros a serem concedidos.', 'enade2021/ads/ads21-q35.png', 'Considerando as informações apresentadas, avalie as afirmações a seguir.

I. A tabela apresentada é ambígua, pois há pessoas para as quais a análise resultaria em dois resultados diferentes.
II. Embora a tabela seja ambígua, não existe a possibilidade de o programa exibir mais de um resultado para uma pessoa.
III. Segundo a tabela, não existe a possibilidade de pessoas sem residência própria serem contempladas com o seguro.
IV. Segundo o funcionamento do programa, o seguro para uma pessoa menor de idade e sem residência própria é viável e lhe custará R$500.

É correto apenas o que se afirma em', null,
   'I e II.', 'II e III.', 'III e IV.', 'I, II e IV.', 'I, III e IV.', 3, 'ENADE 2021 — Análise e Desenvolvimento de Sistemas, Questão 35 (INEP)'),
  ('1f7c87d9-a1d3-5376-8bd1-d621714aa93e', 'FG', array['ALL']::public.curso_alvo[], 'Saúde pública e gênero', 'DISCURSIVA', 'TEXTO 1

Em 2001, a incidência da sífilis congênita — transmitida da mulher para o feto durante a gravidez — era de um caso a cada mil bebês nascidos vivos. Havia uma meta da Organização Pan-Americana de Saúde e da Unicef de essa ocorrência diminuir no Brasil, chegando, em 2015, a 5 casos de sífilis congênita por 10 mil nascidos vivos. O país não atingiu esse objetivo, tendo se distanciado ainda mais dele, embora o tratamento para sífilis seja relativamente simples, à base de antibióticos. Trata-se de uma doença para a qual a medicina já encontrou a solução, mas a sociedade ainda não.

Disponível em: <http://www1.folha.uol.com.br>. Acesso em: 23 jul. 2017 (adaptado).

TEXTO 2

O Ministério da Saúde anunciou que há uma epidemia de sífilis no Brasil. Nos últimos cinco anos, foram 230 mil novos casos, um aumento de 32% somente entre 2014 e 2015. Por que isso aconteceu?

Primeiro, ampliou-se o diagnóstico com o teste rápido para sífilis realizado na unidade básica de saúde e cujo resultado sai em 30 minutos. Aí vem o segundo ponto, um dos mais negativos, que foi o desabastecimento, no país, da matéria-prima para a penicilina. O Ministério da Saúde importou essa penicilina, mas, por um bom tempo, não esteve disponível, e isso fez com que mais pessoas se infectassem. O terceiro ponto é a prevenção. Houve, nos últimos dez anos, uma redução do uso do preservativo, o que aumentou, e muito, a transmissão.

A incidência de casos de sífilis, que, em 2010, era maior entre homens, hoje recai sobre as mulheres. Por que a vulnerabilidade neste grupo está aumentando?

As mulheres ainda são as mais vulneráveis a doenças sexualmente transmissíveis (DST), de uma forma geral. Elas têm dificuldade de negociar o preservativo com o parceiro, por exemplo. Mas o acesso da mulher ao diagnóstico também é maior, por isso, é mais fácil contabilizar essa população. Quando um homem faz exame para a sífilis? Somente quando tem sintoma aparente ou outra doença. E a sífilis pode ser uma doença silenciosa. A mulher, por outro lado, vai fazer o pré-natal e, automaticamente, faz o teste para a sífilis. No Brasil, estima-se que apenas 12% dos parceiros sexuais recebam tratamento para sífilis.

Entrevista com Ana Gabriela Travassos, presidente da regional baiana da Sociedade Brasileira de Doenças Sexualmente Transmissíveis. Disponível em: <http://www.agenciapatriciagalvao.org.br>. Acesso em: 25 jul. 2017 (adaptado).

TEXTO 3

Vários estudos constatam que os homens, em geral, padecem mais de condições severas e crônicas de saúde que as mulheres e morrem mais que elas em razão de doenças que levam a óbito. Entretanto, apesar de as taxas de morbimortalidade masculinas assumirem um peso significativo, observa-se que a presença de homens nos serviços de atenção primária à saúde é muito menor que a de mulheres.

GOMES, R.; NASCIMENTO, E.; ARAUJO, F. Por que os homens buscam menos os serviços de saúde do que as mulheres? As explicações de homens com baixa escolaridade e homens com ensino superior. Cad. Saúde Pública [online], v. 23, n. 3, 2007 (adaptado).', null, 'A partir das informações apresentadas, redija um texto acerca do tema:

Epidemia de sífilis congênita no Brasil e relações de gênero

Em seu texto, aborde os seguintes aspectos:
• a vulnerabilidade das mulheres às DSTs e o papel social do homem em relação à prevenção dessas doenças;
• duas ações especificamente voltadas para o público masculino, a serem adotadas no âmbito das políticas públicas de saúde ou de educação, para reduzir o problema.
(valor: 10,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2017 — Formação Geral, Questão Discursiva 1 (INEP)'),
  ('502ddda6-36cd-581f-9dbc-5f099fd79849', 'FG', array['ALL']::public.curso_alvo[], 'Direitos e cidadania trans', 'DISCURSIVA', 'A pessoa trans precisa que alguém ateste, confirme e comprove que ela pode ser reconhecida pelo nome que ela escolheu. Não aceitam que ela se autodeclare mulher ou homem. Exigem que um profissional de saúde diga quem ela é. Sua declaração é o que menos conta na hora de solicitar, judicialmente, a mudança dos documentos.

Disponível em: <http://www.ebc.com.br>. Acesso em: 31 ago. 2017 (adaptado).

No chão, a travesti morre
Ninguém jamais saberá seu nome
Nos jornais, fala-se de outra morte
De tal homem que ninguém conheceu

Disponível em: <http://www.aminoapps.com>. Acesso em: 31 ago. 2017 (adaptado).

Usava meu nome oficial, feminino, no currículo porque diziam que eu estava cometendo um crime, que era falsidade ideológica se eu usasse outro nome. Depois fui pesquisar e descobri que não é assim. Infelizmente, ainda existe muita desinformação sobre os direitos das pessoas trans.

Disponível em: <https://www.brasil.elpais.com>. Acesso em: 31 ago. 2017 (adaptado).

Uma vez o segurança da balada achou que eu tinha, por engano, mostrado o RG do meu namorado. Isso quando insistem em não colocar meu nome social na minha ficha de consumação.

Disponível em: <https://www.brasil.elpais.com >. Acesso em: 31 ago. 2017 (adaptado).', null, 'Com base nessas falas, discorra sobre a importância do nome para as pessoas transgêneras e, nesse contexto, proponha uma medida, no âmbito das políticas públicas, que tenha como objetivo facilitar o acesso dessas pessoas à cidadania. (valor: 10,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2017 — Formação Geral, Questão Discursiva 2 (INEP)'),
  ('30ef90a9-3e72-5427-8cff-3e2b561d649c', 'FG', array['ALL']::public.curso_alvo[], 'Interpretação de gráficos', 'OBJETIVA', 'Os britânicos decidiram sair da União Europeia (UE). A decisão do referendo abalou os mercados financeiros em meio às incertezas sobre os possíveis impactos dessa saída.

Os gráficos a seguir apresentam, respectivamente, as contribuições dos países integrantes do bloco para a UE, em 2014, que somam € 144,9 bilhões de euros, e a comparação entre a contribuição do Reino Unido para a UE e a contrapartida dos gastos da UE com o Reino Unido.', 'enade2017/fg/fg17-q01.png', 'Disponível em: <http://www.g1.globo.com>. Acesso em: 6 set. 2017 (adaptado).

Considerando o texto e as informações apresentadas nos gráficos acima, assinale a opção correta.', null,
   'A contribuição dos quatro maiores países do bloco somou 41,13%.', 'O grupo “Outros países” contribuiu para esse bloco econômico com 42,1%.', 'A diferença da contribuição do Reino Unido em relação ao recebido do bloco econômico foi 38,94%.', 'A soma das participações dos três países com maior contribuição para o bloco econômico supera 50%.', 'O percentual de participação do Reino Unido com o bloco econômico em 2014 foi de 17,8%, o que o colocou entre os quatro maiores participantes.', 2, 'ENADE 2017 — Formação Geral, Questão 01 (INEP)'),
  ('5581085f-ce21-5a59-8247-a401c90aaaf5', 'FG', array['ALL']::public.curso_alvo[], 'Agricultura familiar e sustentabilidade', 'OBJETIVA', 'Segundo o relatório da Organização das Nações Unidas para a Alimentação e a Agricultura de 2014, a agricultura familiar produz cerca de 80% dos alimentos no mundo e é guardiã de aproximadamente 75% de todos os recursos agrícolas do planeta. Nesse sentido, a agricultura familiar é fundamental para a melhoria da sustentabilidade ecológica.

Disponível em: <http://www.fao.org>. Acesso em: 29 ago. 2017 (adaptado).', null, 'Considerando as informações apresentadas no texto, avalie as afirmações a seguir.

I. Os principais desafios da agricultura familiar estão relacionados à segurança alimentar, à sustentabilidade ambiental e à capacidade produtiva.
II. As políticas públicas para o desenvolvimento da agricultura familiar devem fomentar a inovação, respeitando o tamanho das propriedades, as tecnologias utilizadas, a integração de mercados e as configurações ecológicas.
III. A maioria das propriedades agrícolas no mundo tem caráter familiar, entretanto o trabalho realizado nessas propriedades é majoritariamente resultante da contratação de mão de obra assalariada.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2017 — Formação Geral, Questão 02 (INEP)'),
  ('bb8d88de-7191-5649-ae80-f3ead52d333b', 'FG', array['ALL']::public.curso_alvo[], 'Consumo de energia elétrica', 'OBJETIVA', 'O sistema de tarifação de energia elétrica funciona com base em três bandeiras. Na bandeira verde, as condições de geração de energia são favoráveis e a tarifa não sofre acréscimo. Na bandeira amarela, a tarifa sofre acréscimo de R$ 0,020 para cada kWh consumido, e na bandeira vermelha, condição de maior custo de geração de energia, a tarifa sofre acréscimo de R$ 0,035 para cada kWh consumido. Assim, para saber o quanto se gasta com o consumo de energia de cada aparelho, basta multiplicar o consumo em kWh do aparelho pela tarifa em questão.

Disponível em: <http://www.aneel.gov.br>. Acesso em: 17 jul. 2017 (adaptado).

Na tabela a seguir, são apresentadas a potência e o tempo de uso diário de alguns aparelhos eletroeletrônicos usuais em residências.', 'enade2017/fg/fg17-q03.png', 'Disponível em: <https://www.educandoseubolso.blog.br>. Acesso em: 17 jul. 2017 (adaptado).

Considerando as informações do texto, os dados apresentados na tabela, uma tarifa de R$ 0,50 por kWh em bandeira verde e um mês de 30 dias, avalie as afirmações a seguir.

I. Em bandeira amarela, o valor mensal da tarifa de energia elétrica para um chuveiro de 3 500 W seria de R$ 1,05, e de R$ 1,65, para um chuveiro de 5 500 W.
II. Deixar um carregador de celular e um modem de internet em stand-by conectados na rede de energia durante 24 horas representa um gasto mensal de R$ 5,40 na tarifa de energia elétrica em bandeira verde, e de R$ 5,78, em bandeira amarela.
III. Em bandeira verde, o consumidor gastaria mensalmente R$ 3,90 a mais na tarifa de energia elétrica em relação a cada lâmpada incandescente usada no lugar de uma lâmpada LED.

É correto o que se afirma em', null,
   'II, apenas.', 'III, apenas.', 'I e II, apenas.', 'I e III, apenas.', 'I, II e III.', 3, 'ENADE 2017 — Formação Geral, Questão 03 (INEP)'),
  ('fb87cecf-ac34-549f-9132-ce319f5c4bac', 'FG', array['ALL']::public.curso_alvo[], 'Televisão e comunicação', 'OBJETIVA', 'Sobre a televisão, considere a tirinha e o texto a seguir.

TEXTO 1', 'enade2017/fg/fg17-q04.png', 'Disponível em: <https://www.coletivando.files.wordpress.com>. Acesso em: 25 jul. 2015.

TEXTO 2

A televisão é este contínuo de imagens, em que o telejornal se confunde com o anúncio de pasta de dentes, que é semelhante à novela, que se mistura com a transmissão de futebol. Os programas mal se distinguem uns dos outros. O espetáculo consiste na própria sequência, cada vez mais vertiginosa, de imagens.

PEIXOTO, N. B. As imagens de TV têm tempo? In: NOVAES, A. Rede imaginária: televisão e democracia. São Paulo: Companhia das Letras, 1991 (adaptado).

Com base nos textos 1 e 2, é correto afirmar que o tempo de recepção típico da televisão como veículo de comunicação estimula a', null,
   'contemplação das imagens animadas como meio de reflexão acerca do estado de coisas no mundo contemporâneo, traduzido em forma de espetáculo.', 'fragmentação e o excesso de informação, que evidenciam a opacidade do mundo contemporâneo, cada vez mais impregnado de imagens e informações superficiais.', 'especialização do conhecimento, com vistas a promover uma difusão de valores e princípios amplos, com espaço garantido para a diferença cultural como capital simbólico valorizado.', 'atenção concentrada do telespectador em determinado assunto, uma vez que os recursos expressivos próprios do meio garantem a motivação necessária para o foco em determinado assunto.', 'reflexão crítica do telespectador, uma vez que permite o acesso a uma sequência de assuntos de interesse público que são apresentados de forma justaposta, o que permite o estabelecimento de comparações.', 1, 'ENADE 2017 — Formação Geral, Questão 04 (INEP)'),
  ('87362b70-75c4-50ed-ab83-16c3045ac91f', 'FG', array['ALL']::public.curso_alvo[], 'Tecnologia agrícola', 'OBJETIVA', 'Hidrogéis são materiais poliméricos em forma de pó, grão ou fragmentos semelhantes a pedaços de plástico maleável. Surgiram nos anos 1950, nos Estados Unidos da América e, desde então, têm sido usados na agricultura. Os hidrogéis ou polímeros hidrorretentores podem ser criados a partir de polímeros naturais ou sintetizados em laboratório. Os estudos com polímeros naturais mostram que eles são viáveis ecologicamente, mas ainda não comercialmente.

No infográfico abaixo, explica-se como os polímeros naturais superabsorventes, quando misturados ao solo, podem viabilizar culturas agrícolas em regiões áridas.', 'enade2017/fg/fg17-q05.png', 'Disponível em: <http://www.revistapesquisa.fapesp.br>. Acesso em: 18 jul. 2017 (adaptado).

A partir das informações apresentadas, assinale a opção correta.', null,
   'O uso do hidrogel, em caso de estiagem, propicia a mortalidade dos pés de café.', 'O hidrogel criado a partir de polímeros naturais deve ter seu uso restrito a solos áridos.', 'Os hidrogéis são usados em culturas agrícolas e florestais e em diferentes tipos de solos.', 'O uso de hidrogéis naturais é economicamente viável em lavouras tradicionais de larga escala.', 'O uso dos hidrogéis permite que as plantas sobrevivam sem a água da irrigação ou das chuvas.', 1, 'ENADE 2017 — Formação Geral, Questão 05 (INEP)'),
  ('55ccce18-0615-582e-a49c-765bb158b3b1', 'FG', array['ALL']::public.curso_alvo[], 'Imigração e xenofobia', 'OBJETIVA', 'A imigração haitiana para o Brasil passou a ter grande repercussão na imprensa a partir de 2010. Devido ao pior terremoto do país, muitos haitianos redescobriram o Brasil como rota alternativa para migração. O país já havia sido uma alternativa para os haitianos desde 2004, e isso se deve à reorientação da política externa nacional para alcançar liderança regional nos assuntos humanitários.

A descoberta e a preferência pelo Brasil também sofreram influência da presença do exército brasileiro no Haiti, que intensificou a relação de proximidade entre brasileiros e haitianos. Em meio a esse clima amistoso, os haitianos presumiram que seriam bem acolhidos em uma possível migração ao país que passara a liderar a missão da ONU.

No entanto, os imigrantes haitianos têm sofrido ataques xenofóbicos por parte da população brasileira. Recentemente, uma das grandes cidades brasileiras serviu como palco para uma marcha anti-imigração, com demonstrações de um crescente discurso de ódio em relação a povos imigrantes marginalizados.

Observa-se, na maneira como esses discursos se conformam, que a reação de uma parcela dos brasileiros aos imigrantes se dá em termos bem específicos: os que sofrem com a violência dos atos de xenofobia, em geral, são negros e têm origem em países mais pobres.

SILVA, C. A. S.; MORAES, M. T. A política migratória brasileira para refugiados e a imigração haitiana. Revista do Direito. Santa Cruz do Sul, v. 3, n. 50, p. 98-117, set./dez. 2016 (adaptado).', null, 'A partir das informações do texto, conclui-se que', null,
   'o processo de acolhimento dos imigrantes haitianos tem sido pautado por características fortemente associadas ao povo brasileiro: a solidariedade e o respeito às diferenças.', 'as reações xenófobas estão relacionadas ao fato de que os imigrantes são concorrentes diretos para os postos de trabalho de maior prestígio na sociedade, aumentando a disputa por boas vagas de emprego.', 'o acolhimento promovido pelos brasileiros aos imigrantes oriundos de países do leste europeu tende a ser semelhante ao oferecido aos imigrantes haitianos, pois no Brasil vigora a ideia de democracia racial e do respeito às etnias.', 'o nacionalismo exacerbado de classes sociais mais favorecidas, no Brasil, motiva a rejeição aos imigrantes haitianos e a perseguição contra os brasileiros que pretendem morar fora do seu país em busca de melhores condições de vida.', 'a crescente onda de xenofobia que vem se destacando no Brasil evidencia que o preconceito e a rejeição por parte dos brasileiros em relação aos imigrantes haitianos é pautada pela discriminação social e pelo racismo.', 1, 'ENADE 2017 — Formação Geral, Questão 06 (INEP)'),
  ('5dcfa937-48ad-58fe-b708-cf282d113924', 'FG', array['ALL']::public.curso_alvo[], 'Patrimônio cultural imaterial', 'OBJETIVA', 'A produção artesanal de panela de barro é uma das maiores expressões da cultura popular do Espírito Santo. A técnica de produção pouco mudou em mais de 400 anos, desde quando a panela de barro era produzida em comunidades indígenas. Atualmente, apresenta-se com modelagem própria e original, adaptada às necessidades funcionais da culinária típica da região. As artesãs, vinculadas à Associação das Paneleiras de Goiabeiras, do município de Vitória-ES, trabalham em um galpão com cabines individuais preparadas para a realização de todas as etapas de produção. Para fazer as panelas, as artesãs retiram a argila do Vale do Mulembá e do manguezal que margeia a região e coletam a casca da Rhysophora mangle, popularmente chamada de mangue vermelho. Da casca dessa planta as artesãs retiram a tintura impermeabilizante com a qual açoitam as panelas ainda quentes. Por tradição, as autênticas moqueca e torta capixabas, dois pratos típicos regionais, devem ser servidas nas panelas de barro assim produzidas. Essa fusão entre as panelas de barro e os pratos preparados com frutos do mar, principalmente a moqueca, pelo menos no estado do Espírito Santo, faz parte das tradições deixadas pelas comunidades indígenas.

Disponível em: <http://www.vitoria.es.gov.br>. Acesso em: 14 jul. 2017 (adaptado).

Como principal elemento cultural na elaboração de pratos típicos da cultura capixaba, a panela de barro de Goiabeiras foi tombada, em 2002, tornando-se a primeira indicação geográfica brasileira na área do artesanato, considerada bem imaterial, registrado e protegido no Instituto do Patrimônio Histórico e Artístico Nacional (Iphan), no Livro de Registro dos Saberes e declarada patrimônio cultural do Brasil.

SILVA, A. Comunidade tradicional, práticas coletivas e reconhecimento: narrativas contemporâneas do patrimônio cultural. 40° Encontro Anual da Anpocs. Caxambu, 2016 (adaptado).

Atualmente, o trabalho foi profissionalizado e a concorrência para atender ao mercado ficou mais acirrada, a produção que se desenvolve no galpão ganhou um ritmo mais empresarial com maior visibilidade publicitária, enquanto as paneleiras de fundo de quintal se queixam de ficarem ofuscadas comercialmente depois que o galpão ganhou notoriedade.

MERLO, P. Repensando a tradição: a moqueca capixaba e a construção da identidade local. Interseções. Rio de Janeiro. v. 13, n. 1, 2011 (adaptado).', null, 'Com base nas informações apresentadas, assinale a alternativa correta.', null,
   'A produção das panelas de barro abrange interrelações com a natureza local, de onde se extrai a matéria-prima indispensável à confecção das peças ceramistas.', 'A relação entre as tradições das panelas de barro e o prato típico da culinária indígena permanece inalterada, o que viabiliza a manutenção da identidade cultural capixaba.', 'A demanda por bens culturais produzidos por comunidades tradicionais insere o ofício das paneleiras no mercado comercial, com retornos positivos para toda a comunidade.', 'A inserção das panelas de barro no mercado turístico reduz a dimensão histórica, cultural e estética do ofício das paneleiras à dimensão econômica da comercialização de produtos artesanais.', 'O ofício das paneleiras representa uma forma de resistência sociocultural da comunidade tradicional na medida em que o estado do Espírito Santo mantém-se alheio aos modos de produção, divulgação e comercialização dos produtos.', 2, 'ENADE 2017 — Formação Geral, Questão 07 (INEP)'),
  ('a626ab6d-0f82-59f5-9dd8-1dbe005a9929', 'FG', array['ALL']::public.curso_alvo[], 'Desenvolvimento sustentável (ODS)', 'OBJETIVA', 'Os Objetivos de Desenvolvimento Sustentável (ODS) compõem uma agenda mundial adotada durante a Cúpula das Nações Unidas sobre o Desenvolvimento Sustentável, em setembro de 2015. Nessa agenda, representada na figura a seguir, são previstas ações em diversas áreas para o estabelecimento de parcerias, grupos e redes que favoreçam o cumprimento desses objetivos.', 'enade2017/fg/fg17-q08.png', 'Disponível em: <http://www.stockholmresilience.org>. Acesso em: 26 set. 2017 (adaptado).

Considerando que os ODS devem ser implementados por meio de ações que integrem a economia, a sociedade e a biosfera, avalie as afirmações a seguir.

I. O capital humano deve ser capacitado para atender às demandas por pesquisa e inovação em áreas estratégicas para o desenvolvimento sustentável.
II. A padronização cultural dinamiza a difusão do conhecimento científico e tecnológico entre as nações para a promoção do desenvolvimento sustentável.
III. Os países devem incentivar políticas de desenvolvimento do empreendedorismo e de atividades produtivas com geração de empregos que garantam a dignidade da pessoa humana.

É correto o que se afirma em', null,
   'II, apenas.', 'III, apenas.', 'I e II, apenas.', 'I e III, apenas.', 'I, II e III.', 1, 'ENADE 2017 — Formação Geral, Questão 08 (INEP)'),
  ('0faa56e2-7009-55c5-8548-db36f9346e57', 'CE', array['ADS']::public.curso_alvo[], 'Algoritmos e matrizes', 'DISCURSIVA', 'Uma empresa de cosméticos comercializa cinco diferentes tipos de produtos e os armazena em uma estante de 40 x 40 posições. Em cada posição da estante, pode ficar armazenada apenas uma caixa com um desses produtos. Para facilitar sua identificação, os produtos foram codificados da forma a seguir:

1: xampu;
2: condicionador;
3: hidratante;
4: tintura;
5: demaquilante;
0: vazio.

Nessa situação e considerando o desenvolvimento de um sistema para gerenciar a organização dos produtos na estante, estabeleceu-se a declaração de variáveis a seguir.

Var
    Estante: matriz [1..40][1..40] de inteiro
    Produtos: vetor [0..5] de texto = {"vazio","xampu","condicionador",
                                       "hidratante", "tintura", "demaquilante"}
    Contador: vetor [0..5] de inteiro = {0,0,0,0,0,0}
    i, j: inteiro', null, 'Com base nessa declaração e considerando a codificação dos produtos exposta, faça o que se pede nos itens a seguir, apresentando as soluções em pseudocódigo ou em linguagem de programação.

a) Escreva um trecho de código para ler os códigos dos produtos e armazená-los na matriz Estante. (valor: 4,0 pontos)
b) Escreva um trecho de código para contar e imprimir a quantidade de caixas de cada tipo de produto na estante. (valor: 6,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão Discursiva 3 (INEP)'),
  ('9b3817c1-dd37-5a9e-8d48-2b38f467e682', 'CE', array['ADS']::public.curso_alvo[], 'Estruturas de dados: fila', 'DISCURSIVA', 'Uma empresa trabalha na produção de concreto e terceiriza o serviço de transporte do produto. Os caminhoneiros telefonam para a empresa e registram seu interesse pelo trabalho. Todas as manhãs, os caminhoneiros estacionam o caminhão no pátio da empresa e aguardam sua vez. O atendimento segue o critério de ordem de chegada. Esse processo é, atualmente, controlado pela secretária, que utiliza sua agenda para gerenciar os motoristas diariamente. A empresa, que carrega, no máximo, 10 caminhões por dia, pretende informatizar esse processo.

Para a solução do problema, apresenta-se, a seguir, um pseudocódigo que utiliza o conceito de fila, mantendo os elementos sempre nas primeiras posições do vetor.

Algoritmo Fila_Caminhoneiros
início
   var
      caminhoneiros : vetor[1..10] de texto
      total : inteiro
      procedimento inicializa()
      início
         total <- 0
      fim
      função estaVazia() : lógico
      início
         se (total = 0) então
            retorna verdadeiro
         senão
            retorna falso
         fim-se
      fim
      função estaCheia() : lógico
      início
         se (total >= 10) então
            retorna verdadeiro
         senão
            retorna falso
         fim-se
      fim
      procedimento enfileirar(caminhoneiro : texto)
      início
         se (estaCheia() = falso) então
            total <- total + 1
            caminhoneiros[total] <- caminhoneiro
         senão
            imprima("Fila cheia")
         fim-se
      fim
fim', null, 'Com base nas informações apresentadas, faça o que se pede nos itens a seguir, expondo cada solução em pseudocódigo ou em linguagem de programação.

a) Implemente a função desenfileirar, que deve remover e retornar um elemento representado por um caminhoneiro da fila ou a mensagem "Fila vazia" se não houver elementos. (valor: 6,0 pontos)
b) Implemente o procedimento mostrarFila, que deve apresentar a lista de elementos, ou seja, os caminhoneiros que estão na fila. (valor: 4,0 pontos)', null,
   null, null, null, null, null, 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão Discursiva 4 (INEP)'),
  ('b5189b93-faeb-5da6-94f1-d7ed1a5f544e', 'CE', array['ADS']::public.curso_alvo[], 'Diagrama de classes UML', 'DISCURSIVA', 'A coordenação de gestão de pessoas (CGP) de uma empresa solicitou à equipe de TI que desenvolvesse um aplicativo (app) para criação de uma rede social on-line que incentivasse os empregados a idealizar e executar projetos. A fim de realizar o levantamento de requisitos, a equipe de desenvolvimento se reuniu com a CGP e alguns empregados e, para melhorar a comunicação entre os envolvidos, os analistas de sistemas da empresa optaram pela prototipação de telas do app, conforme os exemplos a seguir.', 'enade2017/ads/ads17-d5.png', 'Tendo-se usado a abordagem de prototipação, foram documentados os seguintes requisitos:

• todo colaborador deve informar número de matrícula, nome, endereço de e-mail e senha de login para se cadastrar no app e poder registrar projetos e enviar comentários; a coordenação de um projeto é atribuída automaticamente ao colaborador que o registrar;
• cada projeto pode ser classificado em uma de duas possíveis categorias: "Melhoria de Processo" ou "Social"; além dos dados em comum para ambas as categorias, um projeto de "Melhoria de Processo" deve ser alocado ao departamento (selecionado de uma lista) em que ele será aplicado e os resultados esperados devem ser informados (conforme o protótipo 1); para um projeto "Social", deve-se indicar o público beneficiário (conforme o protótipo 2);
• uma vez registrado o projeto, qualquer colaborador pode visualizá-lo no app e registrar um ou mais comentários para contribuir com o refinamento da ideia (conforme o protótipo 3); os comentários são visualizados em ordem cronológica, por data e horário;
• o coordenador do projeto pode incluir até três colaboradores para participarem da equipe.

Considerando a situação e as informações apresentadas, construa um diagrama de classe que esteja em conformidade com os requisitos, indicando os atributos de cada classe e as associações entre as classes. (valor: 10,0 pontos)', null,
   null, null, null, null, null, 3, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão Discursiva 5 (INEP)'),
  ('7d78ac2f-e070-5791-af9e-f04acdc0286e', 'CE', array['ADS']::public.curso_alvo[], 'Estatística descritiva', 'OBJETIVA', 'Em uma pesquisa de satisfação com notas de 0 a 10, sendo 0 muito insatisfeito e 10 muito satisfeito, uma empresa construiu uma tabela, mostrada a seguir, com o resumo das notas atribuídas pelos seus clientes aos serviços recebidos.', 'enade2017/ads/ads17-q09.png', 'Considerando essa situação e as informações apresentadas, avalie as afirmações a seguir.

I. A média das notas dos clientes é igual a 6,0.
II. A mediana das notas dos clientes é igual a 6,0.
III. O desvio padrão populacional é menor do que 3,0.
IV. O conjunto de dados é amodal.
V. Um cliente que atribuiu nota 3,0 encontra-se no 1º quartil.

É correto apenas o que se afirma em', null,
   'I, II e III.', 'I, II e V.', 'I, III e IV.', 'II, IV e V.', 'III, IV e V.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 09 (INEP)'),
  ('a3b08535-7649-515e-a61c-497c7b3b7124', 'CE', array['ADS']::public.curso_alvo[], 'Lógica e álgebra booleana', 'OBJETIVA', 'A álgebra booleana possui um operador unário ~, conhecido como NÃO, e os operadores binários * e +, conhecidos como E e OU, respectivamente. A tabela verdade é utilizada para validar uma fórmula composta de operadores da álgebra booleana. A seguir, é apresentada a tabela verdade para as proposições p, q e r diante da fórmula G, em que V representa uma proposição verdadeira e F uma proposição falsa.', 'enade2017/ads/ads17-q10.png', 'Considerando as informações contidas na tabela acima e a ordem de precedência dos operadores booleanos, a fórmula G possui a mesma tabela verdade da proposição', null,
   'p + ~q * r.', 'p + q * ~r.', '~p + q * r.', '~p + ~q * r.', '~p + q * ~r.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 10 (INEP)'),
  ('41c7434d-ed82-57c0-805a-f3a0663085dc', 'CE', array['ADS']::public.curso_alvo[], 'Modelagem de dados UML', 'OBJETIVA', 'No desenvolvimento de um sistema de automação para um clube recreativo, serão implementados módulos para o departamento administrativo, tais como os módulos de cadastro de associados e de gestão de mensalidades. Na construção desses módulos, algumas regras de negócio serão aplicadas conforme o diagrama abaixo.', 'enade2017/ads/ads17-q11.png', 'Com base nesse diagrama, avalie as afirmações a seguir.

I. Haverá somente 12 mensalidades para cada associado, ou seja, as mensalidades do associado não poderão ultrapassar os 12 meses do ano.
II. Não existem associados sem mensalidades, nem mensalidades sem associado a elas relacionado.
III. Alterando-se o valor da mensalidade definido para cada tipo de associado cadastrado, o sistema automaticamente altera os valores das mensalidades geradas anteriormente.
IV. Poderão existir tipos de associados que não terão nenhum associado relacionado a eles.

É correto apenas o que se afirma em', null,
   'I e II.', 'I e III.', 'II e IV.', 'I, III e IV.', 'II, III e IV.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 11 (INEP)'),
  ('02f4b0f6-bc74-56a2-a0ca-c1f7678a961b', 'CE', array['ADS']::public.curso_alvo[], 'Engenharia de requisitos', 'OBJETIVA', 'A engenharia de requisitos, do ponto de vista do processo de software, é uma ação de engenharia de software importante, que se inicia durante a atividade de comunicação e continua na de modelagem. Ela deve ser adaptada às necessidades do processo, do projeto, do produto e das pessoas que estão realizando o trabalho.

PRESSMAN, R. S. Engenharia de software: uma abordagem profissional. 8. ed. Porto Alegre: AMGH, 2016 (adaptado).

Considere os requisitos, a seguir, de um sistema para uma universidade, na qual se pretenda gerenciar o setor acadêmico.

• R1: o sistema deve permitir que cada professor realize o lançamento de notas das turmas nas quais lecionou;
• R2: o sistema deverá ser desenvolvido de forma a possibilitar seu transporte para outro sistema operacional em, no máximo, sessenta dias;
• R3: o sistema deve permitir que um estudante realize a sua matrícula nas disciplinas oferecidas em um semestre letivo;
• R4: o sistema atualiza a nota do estudante, permitindo sua visualização, em até dois segundos depois do momento que o professor a registra;
• R5: o sistema deve permitir que o auxiliar de serviços acadêmicos realize o cadastro de um estudante em não mais do que dez minutos de orientação.', null, 'Nessa situação, representam descrições de requisitos não funcionais apenas os requisitos', null,
   'R1, R2 e R3.', 'R1, R2 e R5.', 'R1, R3 e R4.', 'R2, R4 e R5.', 'R3, R4 e R5.', 1, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 12 (INEP)'),
  ('5bb6bc29-5b7e-51a6-b658-b7dcdef736f0', 'CE', array['ADS']::public.curso_alvo[], 'Qualidade de software: CMMI', 'OBJETIVA', 'Na área de desenvolvimento de software, prazos, custos e qualidade são questões que demandam gerenciamento, para que se evitem atrasos, estouros orçamentários e sistemas que não atendam aos requisitos.', null, 'Sobre o modelo CMMI, avalie as asserções a seguir e a relação proposta entre elas.

I. O CMMI fornece diretrizes para a melhoria dos processos e habilidades organizacionais, incluindo o ciclo de vida de produtos e serviços, que abrange as fases de concepção, desenvolvimento, aquisição, entrega e manutenção.

PORQUE

II. As empresas brasileiras estão aderindo a programas de fomento à melhoria da qualidade de software, por meio da aplicação do modelo de maturidade CMMI, que é mais direcionado às pequenas e médias empresas, apesar de também ser um modelo aplicável em grandes organizações, sejam elas públicas ou privadas.

A respeito dessas asserções, assinale a opção correta.', null,
   'As asserções I e II são proposições verdadeiras, e a II é uma justificativa correta da I.', 'As asserções I e II são proposições verdadeiras, mas a II não é uma justificativa correta da I.', 'A asserção I é uma proposição verdadeira, e a II é uma proposição falsa.', 'A asserção I é uma proposição falsa, e a II é uma proposição verdadeira.', 'As asserções I e II são proposições falsas.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 13 (INEP)'),
  ('96e063a2-104c-5293-9b8f-272727fb1953', 'CE', array['ADS']::public.curso_alvo[], 'Gerência de projetos: caminho crítico', 'OBJETIVA', 'O método do caminho crítico identifica a sequência de atividades que o gerente de projetos deve dar mais atenção, porque, caso uma delas atrase, todo o projeto estará atrasado. A tabela a seguir apresenta a estrutura de atividades de um projeto.', 'enade2017/ads/ads17-q14.png', 'A partir das informações apresentadas na tabela, avalie as afirmações a seguir.

I. O caminho crítico é composto pelas atividades A, B, I e J.
II. O caminho crítico tem 27 dias.
III. A atividade H faz parte do caminho crítico.
IV. O projeto em pauta possui dois caminhos críticos.

É correto apenas o que se afirma em', null,
   'I e II.', 'I e IV.', 'II e III.', 'I, III e IV.', 'II, III e IV.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 14 (INEP)'),
  ('f05a8435-dfd6-520b-aa7c-f2abc8fadc07', 'CE', array['ADS']::public.curso_alvo[], 'Diagrama de classes UML', 'OBJETIVA', 'O seguinte diagrama de classe representa a modelagem de um serviço de transferência de materiais entre funcionários de uma empresa.', 'enade2017/ads/ads17-q16.png', 'Considerando o diagrama de classe apresentado, avalie as afirmações a seguir.

I. A classe Funcionario é abstrata.
II. Uma RequisicaoTransferencia só existe se estiver vinculada a um Material.
III. A classe Funcionario, em razão de sua associação, possui um atributo do tipo RequisicaoTransferencia.
IV. Em uma implementação da classe RequisicaoTransferencia, é necessário adicionar um atributo simples do tipo Material.

É correto o que se afirma em', null,
   'II, apenas.', 'I e II, apenas.', 'III e IV, apenas.', 'I, III e IV, apenas.', 'I, II, III e IV.', 3, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 16 (INEP)'),
  ('05187aeb-283f-5bfa-9da9-c78916adc7e9', 'CE', array['ADS']::public.curso_alvo[], 'Manutenção de software', 'OBJETIVA', 'Após a implantação de um sistema em ambiente de produção, este passa para a fase de manutenção dentro do ciclo de vida do desenvolvimento de software. Os sistemas geralmente necessitam de diversos tipos de manutenção durante sua existência.', null, 'Considerando a etapa de manutenção no processo de desenvolvimento de software, avalie as afirmações a seguir.

I. A fase de manutenção é uma parte explícita do modelo em cascata do processo de desenvolvimento de software.
II. A atualização do sistema para inserir customizações é considerada um tipo de manutenção.
III. A depuração do programa é um processo específico da fase de desenvolvimento e um tipo de manutenção.
IV. O acréscimo de novas funções a um sistema existente, sem perturbar sua operação, é considerado um tipo de manutenção.
V. A manutenção do sistema está relacionada ao aumento do ciclo de vida do software.

É correto apenas o que se afirma em', null,
   'I e III.', 'IV e V.', 'I, II e III.', 'I, II, IV e V.', 'II, III, IV e V.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 17 (INEP)'),
  ('147bd849-ae72-5c84-a446-b10bbb45189a', 'CE', array['ADS']::public.curso_alvo[], 'Sistemas distribuídos', 'OBJETIVA', 'As redes de computadores estão por toda parte. A internet é uma delas, assim como as várias redes das quais ela é composta, que compartilham recursos por meio de Sistemas Distribuídos. Como o número de dispositivos tem crescido exponencialmente, em vez de paralelizar tarefas em várias máquinas, tornou-se cada vez mais importante empregar sistemas distribuídos, comunicando e coordenando dispositivos e, assim, contribuindo para o cotidiano de empresas, governos e demais instituições.

COULOURIS, G. et al. Sistemas Distribuídos: conceitos e projeto, 5. ed. Porto Alegre: Bookman, 2013 (adaptado).', null, 'Nesse contexto, assinale a opção que apresenta exemplos atuais de sistemas distribuídos.', null,
   'Pesquisa na web, jogos on-line, E-Commerce e o banco de dados das agências bancárias.', 'Jogos on-line, E-Commerce, pesquisa no Windows e e-mails.', 'E-Commerce, jogos em mídia física, pesquisa no Windows e redes sociais.', 'Pesquisa na web, jogos em mídia física, E-Commerce e e-mails.', 'Pesquisa no Windows, pesquisa na web, jogos on-line e o banco de dados das agências bancárias.', 1, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 18 (INEP)'),
  ('c174b2bd-a3db-5a27-bc24-02af8b23f0bd', 'CE', array['ADS']::public.curso_alvo[], 'Sistemas operacionais: processos', 'OBJETIVA', 'Conceitualmente, cada processo tem sua própria CPU (Central Processing Unit) virtual. É claro que, na realidade, a CPU troca a execução, a todo momento, de um processo para outro, mas, para entender esse sistema, é muito mais fácil pensar em um conjunto de processos sendo executados (pseudo) paralelamente do que tentar controlar o modo como a CPU faz esses chaveamentos.

TANENBAUM, A. S. Sistemas operacionais modernos. 3. ed. São Paulo: Person, 2010 (adaptado).', null, 'De acordo com o exposto, o conceito descrito denomina-se', null,
   'thread.', 'multiprocessador.', 'multiprogramação.', 'processo monothread.', 'máquina de estados finitos.', 1, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 19 (INEP)'),
  ('55aa15f5-7a5b-50dc-b894-f0a711dbaf07', 'CE', array['ADS']::public.curso_alvo[], 'Casos de uso UML', 'OBJETIVA', 'O quadro a seguir apresenta um exemplo de documentação de caso de uso Encerrar Conta para um Sistema de Controle Bancário.', 'enade2017/ads/ads17-q20.png', 'Com base no quadro apresentado, assinale a opção na qual o diagrama corresponde a documentação descrita para o caso de uso Encerrar Conta usando associação de extensão com restrição e ponto de extensão.', 'enade2017/ads/ads17-q20-alt.png',
   'Opção A — ver figura das alternativas', 'Opção B — ver figura das alternativas', 'Opção C — ver figura das alternativas', 'Opção D — ver figura das alternativas', 'Opção E — ver figura das alternativas', 3, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 20 (INEP)'),
  ('51b7bfec-fba8-5c10-b3c2-3555e49540ef', 'CE', array['ADS']::public.curso_alvo[], 'Modelos de processo de software', 'OBJETIVA', 'Os modelos de processo foram propostos para trazer ordem ao caos existente na área de desenvolvimento de software. A história mostra que esses modelos trouxeram considerável contribuição no trabalho da engenharia de software.

PRESSMAN, R. S. Engenharia de software: uma abordagem profissional. 8. ed. Porto Alegre: AMGH, 2016 (adaptado).', null, 'A respeito dos modelos de processo, avalie as afirmações a seguir.

I. São atividades do modelo incremental: especificação, desenvolvimento e validação.
II. No modelo espiral, a fase de modelagem é responsável, entre outras atividades, pela estimativa, cronograma e análise de risco.
III. O modelo cascata sugere uma abordagem sequencial e sistemática para o desenvolvimento de software, iniciando na especificação de requisitos e finalizando com a entrega do software concluído.

É correto o que se afirma em', null,
   'II, apenas.', 'III, apenas.', 'I e II, apenas.', 'I e III, apenas.', 'I, II e III.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 21 (INEP)'),
  ('ea55b07c-da11-5a8a-85d2-ecfc30730a6b', 'CE', array['ADS']::public.curso_alvo[], 'Gerência de configuração', 'OBJETIVA', 'Um desenvolvedor de software recém-formado foi contratado para a implementação de um projeto em uma empresa e, em reunião, recebeu várias explicações sobre como a gerência de configuração funcionava.', null, 'Considerando essa situação, avalie as afirmações a seguir, referentes às informações dadas ao desenvolvedor.

I. Inicialmente, para ter acesso à base de desenvolvimento, o profissional deve realizar uma operação de checkout para baixar os arquivos do projeto que estão armazenados no servidor.
II. Na situação em que mais de um desenvolvedor estiver modificando um mesmo documento, ao se tentar realizar uma operação de commit, pode ser necessário realizar uma operação de tag (release) para resolução do conflito entre a versão local e a versão mais recente no repositório, caso algum desenvolvedor tenha submetido uma mudança no documento previamente.
III. No desenvolvimento de um novo caso de uso, em que diversos arquivos sejam modificados, é recomendada a criação de uma ramificação (branch).
IV. A versão estável é o ramo principal de desenvolvimento, que segue do começo do desenvolvimento até o momento presente.

É correto apenas o que se afirma em', null,
   'I e II.', 'I e III.', 'II e IV.', 'I, III e IV.', 'II, III e IV.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 22 (INEP)'),
  ('89e63b39-c136-5c3f-b479-44f28f2915cc', 'CE', array['ADS']::public.curso_alvo[], 'Testes de software', 'OBJETIVA', 'Um software com defeito pode ser consequência de problemas no levantamento dos requisitos, uma vez que o requisito pode ser ambíguo porque o cliente não estava convicto da sua real necessidade ou porque a equipe o interpretou mal e registrou uma especificação de forma incorreta. Por esses motivos, as verificações, as validações e os testes são fundamentais para se certificar da qualidade do software resultante.', null, 'Considerando esse contexto, avalie as afirmações a seguir.

I. O teste funcional certifica se o software desempenha as funções especificadas nos requisitos.
II. O teste de desempenho valida a conformidade da especificação do processo de desenvolvimento de software.
III. O teste de aceitação é realizado pelo cliente a fim de validar se aquilo que foi implementado é o que foi solicitado.
IV. O teste de instalação, invariavelmente, é executado no local determinado pelo cliente para instalação do software.
V. As técnicas de verificação e validação de software asseguram que o sistema que está sendo desenvolvido seja adequado ao seu propósito.

É correto apenas o que se afirma em', null,
   'I e IV.', 'I, III e V.', 'II, III e IV.', 'II, IV e V.', 'I, II, III e V.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 23 (INEP)'),
  ('2dfa70eb-606b-5e70-8484-54a8c72137f4', 'CE', array['ADS']::public.curso_alvo[], 'Reengenharia de software', 'OBJETIVA', 'Nas décadas de 1970 e 1980, muitos sistemas corporativos foram desenvolvidos com a linguagem Cobol, utilizando o Sistema Gerenciador de Banco de dados ADABAS e arquivos indexados do tipo ISAM e VISAM. Alguns desses produtos de implementação foram, ou estão sendo, descontinuados pelos seus fabricantes. Por isso, o trabalho de reengenharia desses sistemas, utilizando linguagens mais modernas, como Python, Java ou mesmo C++, associadas com sistemas de banco de dados mais atuais, apresenta-se como uma boa oportunidade de negócios.', null, 'Considerando esse cenário, avalie as afirmações a seguir.

I. A dificuldade de reengenharia de sistemas antigos deve-se ao fato de que, na maioria das vezes, o desenvolvedor definia o sistema e esse já era o próprio processo da organização.
II. O custo de alteração para modernização de uma linha de código em Cobol é alto, por isso, fazer a manutenção desses sistemas é menos despendioso.
III. Uma estratégia de conversão dos referidos sistemas para uma linguagem orientada a objetos é definir uma estrutura de classes e métodos e realizar o refatoramento do código.

É correto o que se afirma em', null,
   'I, apenas.', 'III, apenas.', 'I e II, apenas.', 'II e III, apenas.', 'I, II e III.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 24 (INEP)'),
  ('979ac1ae-177f-59f6-bb44-85b0d8efc545', 'CE', array['ADS']::public.curso_alvo[], 'Estruturas de dados', 'OBJETIVA', 'O fragmento de código C++, a seguir, contém a implementação da inserção de um nó em uma árvore binária.

...
struct noArvore {
   int dado;
   noArvore *esquerda;
   noArvore *direita;
};

noArvore *insere(noArvore *arvore, int valor) {
   if (arvore == NULL) {
      arvore = new noArvore;
      arvore->esquerda = NULL;
      arvore->direita = NULL;
      arvore->dado = valor;
   } else if(valor < arvore->dado) {
        arvore->esquerda = insere (arvore->esquerda, valor);
     }
     else {
        arvore->direita = insere (arvore->direita, valor);
     }
     return(arvore);
}
...', null, 'Com base no exposto, assinale a opção que apresenta o fragmento de programa para imprimir os valores contidos nos nós, percorrendo a árvore em pré-ordem.', null,
   'void preorder(noArvore *raiz) {
   if (raiz != NULL) {
      cout << raiz->dado << " ";
      preorder(raiz->esquerda);
      preorder(raiz->direita);
   }
}', 'void preorder(noArvore *raiz) {
   if (raiz != NULL) {
      preorder(raiz->direita);
      preorder(raiz->esquerda);
      cout << raiz->dado << " ";
   }
}', 'void preorder(noArvore *raiz) {
   if (raiz != NULL) {
      preorder(raiz->esquerda);
      cout << raiz->dado << " ";
      preorder(raiz->direita);
   }
}', 'void preorder(noArvore *raiz) {
   if (raiz != NULL) {
      preorder(raiz->esquerda);
      preorder(raiz->direita);
      cout << raiz->dado << " ";
   }
}', 'void preorder(noArvore *raiz) {
   if (raiz != NULL) {
      preorder(raiz->direita);
      cout << raiz->dado << " ";
      preorder(raiz->esquerda);
   }
}', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 25 (INEP)'),
  ('e3ec63e5-2a7d-5a4b-8969-0f1f1e92b970', 'CE', array['ADS']::public.curso_alvo[], 'Padrões de projeto', 'OBJETIVA', 'Para que se realize a multiplicação de probabilidades com maior facilidade, foi desenvolvida, utilizando-se o padrão MVC (Model-View-Controller), uma calculadora que pode ser configurada de dois modos: comum e probabilista. No primeiro, as multiplicações ocorrem de forma ordinária. No segundo, as multiplicações são feitas utilizando-se uma fórmula específica.

A classe a seguir, escrita na linguagem Java, define o método multiplica. Ele é executado quando o botão da multiplicação é pressionado, e recebe como parâmetro os valores que o usuário deseja usar na operação, além de possuir uma variável de instância do tipo CalculadoraController. O método alteraModo é encarregado de alterar a instância para a qual essa variável faz referência conforme o modo selecionado pelo usuário. A instância interage com as partes do model apropriadas à solicitação realizada pelo usuário. Quando o usuário deseja usar o modo probabilista, a variável modo tem o valor 1, caso contrário, ela tem o valor 0.

public class Calculadora {

   private CalculadoraController c;
   private int modo;

   public double multiplica (double[] valores) {
      return c.multiplica (valores);
   }

   public void alteraModo () {

      if ( modo == 1)
         c = new ProbabilistaController();
      else
         c = new OrdinarioController();
      }
}

O diagrama de classe que se segue mostra a hierarquia de controllers definida para a implementação da calculadora descrita. A hierarquia de classes de controle representa uma família de algoritmos intercambiáveis, por isso, o comportamento dos componentes da view, a cada instante, pode ser dinamicamente alterado, bastando trocar o tipo da instância referenciada pela variável c.', 'enade2017/ads/ads17-q26.png', 'Considerando esse cenário, avalie as afirmações a seguir.

I. A hierarquia exibida ilustra o uso do padrão de projetos Strategy.
II. O padrão composto MVC define a existência de um único controller e, portanto, a solução proposta não caracteriza o uso desse padrão.
III. O método multiplica da classe Calculadora chama o método multiplica de CalculadoraController, o que caracteriza uma conversão de interfaces e, portanto, o uso do padrão de projetos Adapter.

É correto o que se afirma em', null,
   'I, apenas.', 'II, apenas.', 'I e III, apenas.', 'II e III, apenas.', 'I, II e III.', 3, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 26 (INEP)'),
  ('402bf7a2-58a4-5e3e-a4b6-daf1d3ddc972', 'CE', array['ADS']::public.curso_alvo[], 'Padrões de projeto', 'OBJETIVA', 'O diagrama de classe apresentado na figura a seguir mapeia um processo de um simulador de voo. Nesse diagrama, é utilizado o padrão de projeto Strategy, que define uma família de algoritmos, encapsula cada um deles e os torna intercambiáveis. O padrão Strategy, que deixa o algoritmo variar independentemente dos clientes que o utilizam, aplica o princípio de projeto: “programar para uma interface, não para uma implementação”.

LARMAN, C. Utilizando UML e padrões: uma introdução à análise e ao projeto orientados a objetos e ao desenvolvimento iterativo. Porto Alegre: Bookman, 2007 (adaptado).

Considere o diagrama de classe a seguir que descreve um simulador de voo.', 'enade2017/ads/ads17-q27.png', 'Considere ainda o seguinte código em linguagem Java como implementação do simulador.

public interface Voar {
   public void voar();
}
public interface Pousar {
   public void pousar();
}
public class VoarDia implements Voar {
   public void voar() {
      System.out.println(“Voar durante o dia.”);
   }
}
public class VoarNoite implements Voar {
   public void voar() {
      System.out.println(“Voar durante a noite.”);
   }
}
public class PousarDia implements Pousar {
   public void pousar() {
      System.out.println(“Pousar durante o dia.”);
   }
}
public class PousarNoite implements Pousar {
   public void pousar() {
      System.out.println(“Pousar durante a noite.”);
   }
}
public abstract class Aviao {
   Voar voarForma;
   Pousar pousarForma;
   public Aviao() {}
   public abstract void informarDados();
   public void performanceVoar() {
      voarForma.voar();
   }
   public void performancePousar() {
      pousarForma.pousar();
   }
   public void setVoar(Voar v) {
      voarForma = v;
   }
   public void setPousar(Pousar p) {
      pousarForma = p;
   }
}
public class Boeing757 extends Aviao {
   public Boeing757() {
      voarForma = new VoarDia();
      pousarForma = new PousarDia();
   }
   public void informarDados() {
      System.out.println(“Informando dados de um Boeing 757.”);
   }
}
public class SimuladorBoeing757 {
   public static void main(String[] args) {
      Boeing757 b757 = new Boeing757();
      b757.performanceVoar();
      b757.performancePousar();
      b757.setVoar(new VoarNoite());
      b757.setPousar(new PousarNoite());
      b757.performanceVoar();
      b757.performancePousar();
   }
}

Com base no diagrama de classe, no código em linguagem Java e no conceito do padrão de projeto Strategy, assinale a opção correta.', null,
   'A classe Aviao implementa as interfaces Voar e Pousar.', 'A classe Boeing757 não aplica o princípio de herança, uma vez que esse princípio já foi aplicado pela classe Aviao, nas interfaces Voar e Pousar.', 'Por implementarem as interfaces Voar e Pousar, as classes VoarDia, VoarNoite, PousarDia e PousarNoite também são uma interface.', 'Na classe SimuladorBoeing757, os métodos setVoar e setPousar são os responsáveis por aplicar, respectivamente, as saídas “Voar durante o dia” e “Pousar durante o dia” para as saídas “Voar durante a noite” e “Pousar durante a noite”.', 'Quando for executada, a classe SimuladorBoeing757 apresentará um erro em tempo de execução porque os métodos setVoar e setPousar recebem respectivamente, como parâmetros, variáveis do tipo classe, o que não é permitido na orientação a objetos.', 3, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 27 (INEP)'),
  ('19a8b61b-3b0a-5cf1-a6e9-35e33659ff33', 'CE', array['ADS']::public.curso_alvo[], 'Engenharia de requisitos', 'OBJETIVA', 'Os requisitos de um sistema consistem nas descrições daquilo que o sistema deve fazer, dos serviços que oferece e das restrições a seu funcionamento. Esses requisitos refletem as necessidades específicas dos clientes do sistema, como controlar um dispositivo, realizar um pedido ou encontrar informações. O processo de descobrir, analisar, documentar e verificar esses serviços e restrições é denominado de engenharia de requisitos.

SOMMERVILLE, I. Engenharia de software. 9. Ed. São Paulo: Pearson, 2011 (adaptado).', null, 'Tendo o texto como referência, avalie as atribuições listadas a seguir, no que se refere à etapa de especificação de requisitos em projetos de software.

I. Identificar as expectativas e necessidades dos stakeholders com relação ao software a ser desenvolvido.
II. Distribuir os requisitos em categorias, explorar as relações entre eles e classificar sua importância para os stakeholders.
III. Produzir um documento de especificação de requisitos, de forma que todos os stakeholders possam entendê-lo.
IV. Examinar a especificação do software para assegurar que todos os requisitos foram definidos sem inconsistências.

São atribuições na etapa de especificação de requisitos os itens', null,
   'I e III, apenas.', 'I e IV, apenas.', 'II e III, apenas.', 'II e IV, apenas.', 'I, II, III e IV.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 28 (INEP)'),
  ('9f6a0e21-b3d7-5bbb-adac-fe13e99567c1', 'CE', array['ADS']::public.curso_alvo[], 'Lógica e teoria dos conjuntos', 'OBJETIVA', 'Uma pesquisa está sendo realizada para identificar a renda média de um grupo de profissionais, em função de algumas variáveis de interesse. As variáveis utilizadas são “possui ensino superior”, “possui pós-graduação” e “possui pelo menos 5 anos de experiência em sua área de atuação”. Os conjuntos de pessoas representados por essas variáveis são denotados A, B e C, respectivamente. Dado que as variáveis não são mutuamente exclusivas, uma pessoa pode pertencer a mais de um conjunto. As expressões a seguir representam subconjuntos para os quais se deseja obter a renda média das pessoas a eles pertencentes, tarefa que será realizada posteriormente.

• Expressão 1: x ∈ A ∧ x ∉ (B ∪ C);
• Expressão 2: x ∈ A − (B ∪ C);
• Expressão 3: x ∈ A ∧ x ∈ B ∧ x ∈ C.

Considere que, em função das expressões dadas, o seguinte programa em linguagem de programação C foi escrito, para que posteriormente se realize os cálculos desejados. Considere, ainda, que A, B e C são estruturas de dados apropriadamente definidas e que contém as pessoas exatamente como especificado. A função contem opera sobre elas e devolve um valor booleano, indicando se a pessoa apontada por p existe ou não na estrutura especificada.

void determina_renda (pessoa *p) {
   /* condição 1 */
   if (contem (A, p) && !contem (B, p) && !contem (C, p)) {
      //renda será determinada posteriormente
   }
   /* condição 2 */
   else if (contem (A, p) || contem (B, p) || contem (C, p)) {
     //renda será determinada posteriormente
   }
}', null, 'Com base nessa situação e nas informações apresentadas, assinale a opção correta.', null,
   'A condição 2 do programa é equivalente à expressão 3.', 'Pessoas com pós-graduação pertencem ao conjunto definido pela expressão 2.', 'A condição 1 do programa é verdadeira para todas as pessoas com ensino superior.', 'A condição 1 do programa e as expressões 1 e 2, que representam o mesmo subconjunto, são equivalentes.', 'A condição 2 do programa define o conjunto de pessoas que tem ensino superior, pós-graduação e pelo menos cinco anos de experiência em sua área de atuação.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 29 (INEP)'),
  ('ec5b10fe-98dd-5917-b08f-74213ba47923', 'CE', array['ADS']::public.curso_alvo[], 'Programação orientada a objetos', 'OBJETIVA', 'A área de desenvolvimento de software está se tornando cada vez mais complexa. Para lidar com essa realidade, os desenvolvedores contam com linguagens de programação baseadas no paradigma de orientação a objetos, cujos pilares são abstração, encapsulamento, herança e polimorfismo. No código a seguir, observa-se a implementação de classes relacionadas.

public abstract class Impressora {
   String nome;

   Impressora() {}

   Impressora(String n) {
      this.nome = n;
   }

   public void imprimir() {}
}

public class Laser extends Impressora {

   public Laser() {}

   public void imprimir() {
      System.out.println(“Imprimindo na Laser”);
   }
}

class Matricial extends Impressora {

   public Matricial () {}

   public void imprimir() {
      System.out.println(“Imprimindo na Matricial”);
   }
}

public class JatoDeTinta extends Impressora {

   public JatoDeTinta() {}

   public void imprimir(){
      System.out.println(“Imprimindo na Jato de tinta”);
   }

}

public class Main {

   public static void main(String args[]) {
      Impressora imp[] = new Impressora[3];
      imp[0] = new Laser();
      imp[1] = new JatoDeTinta();
      imp[2] = new Matricial();

      for(int i = imp.length - 1; i >= 0; i--){
         imp[i].imprimir();
      }
   }
}', null, 'Com base nas informações do texto e no código apresentado, avalie as afirmações a seguir.

I. A execução do código, via classe Main, resulta na seguinte saída:
Imprimindo na Laser
Imprimindo na Matricial
Imprimindo na Jato de tinta
II. O código faz uso da técnica denominada polimorfismo.
III. O código não será compilado, pois o vetor imp foi instanciado por meio da classe abstrata Impressora.

É correto o que se afirma em', null,
   'II, apenas.', 'III, apenas.', 'I e II, apenas.', 'I e III, apenas.', 'I, II e III.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 30 (INEP)'),
  ('1f2f2408-a60f-54b7-ad3f-59fc60b6bac8', 'CE', array['ADS']::public.curso_alvo[], 'Requisitos não funcionais', 'OBJETIVA', 'À medida que o projeto de uma interface do usuário evolui, quatro questões de projeto comuns quase sempre vêm à tona: tempo de resposta do sistema, recursos de ajuda ao usuário, informações de tratamento de erros e atribuição de nomes a comandos.

PRESSMAN, R. S. Engenharia de software: uma abordagem profissional. 8. ed. São Paulo: AMGH, 2016 (adaptado).', null, 'Nesse contexto, avalie as afirmações a seguir, a respeito do projeto de interface e dos requisitos de software.

I. A análise de interfaces tem por objetivo identificar o perfil dos usuários e auxiliar na especificação do requisito não funcional de segurança pertinente ao perfil de acesso dos usuários.
II. O requisito não funcional de segurança descreve as características relacionadas a inteligibilidade, modo de usar ou operar o sistema.
III. O requisito não funcional de confiabilidade descreve as características relacionadas ao tempo de resposta para processamento de dados ou informações.
IV. O requisito não funcional de usabilidade descreve diretrizes de acessibilidade para pessoas com deficiência.

É correto apenas o que se afirma em', null,
   'I e III.', 'I e IV.', 'II e IV.', 'I, II e III.', 'II, III e IV.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 31 (INEP)'),
  ('ea1d65b4-3798-57b5-b1a0-eed629a6c07c', 'CE', array['ADS']::public.curso_alvo[], 'Banco de dados e SQL', 'OBJETIVA', 'Um cliente solicitou a uma empresa a criação de um banco de dados para armazenar o resultado de uma eleição presidencial, com dados sobre os partidos políticos, os candidatos e a votação obtida por cada candidato em cada unidade da federação. O seguinte diagrama de Entidade-Relacionamento foi elaborado como representação dos requisitos obtidos com o cliente.', 'enade2017/ads/ads17-q32.png', 'Com base nas informações e na situação apresentada, qual o comando SQL que seleciona corretamente os nomes dos candidatos, seus partidos e o total de votos de cada partido nessa eleição?', null,
   'SELECT c.nome, p.nome, SUM(v.votos) FROM Partido p, Candidato c, Votacao v WHERE c.numero = p.numero and v.partido = c.numero;', 'SELECT c.nome, p.nome, COUNT(v.votos) FROM Partido p, Candidato c, Votacao v WHERE c.numero = p.numero and v.partido = c.numero GROUP BY c.nome, p.nome;', 'SELECT c.nome, p.nome, SUM(v.votos) FROM Partido p, Candidato c, Votacao v WHERE c.numero = p.numero and v.partido = c.numero GROUP BY c.nome, p.nome;', 'SELECT c.nome, p.nome, v.votos FROM Partido p, Candidato c, Votacao v WHERE c.numero = p.numero and v.partido = c.numero GROUP BY c.nome, p.nome, SUM(v.votos);', 'SELECT c.nome, p.nome, COUNT(v.votos) FROM Partido p, Candidato c, Votacao v WHERE c.numero = p.numero and v.partido = c.numero GROUP BY c.nome, p.nome, v.votos;', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 32 (INEP)'),
  ('86e59dfc-78af-5564-bf23-473ca27a7f8e', 'CE', array['ADS']::public.curso_alvo[], 'Algoritmos de ordenação', 'OBJETIVA', 'A ordenação por inserção funciona de modo semelhante à forma como algumas pessoas ordenam cartas de baralho. Inicia-se com a mão esquerda vazia e as cartas empilhadas na mesa. Remove-se da pilha uma carta de cada vez, inserindo-a na posição correta na mão esquerda. Para se identificar a posição correta de uma carta, deve-se compará-la com as cartas presentes na mão esquerda, no sentido da direita para a esquerda. Em todos os momentos, as cartas na mão esquerda estão ordenadas, tendo sido obtidas no topo da pilha da mesa.

CORMEN, T. H. et al. Introduction to algorithms. 3. ed. Cambridge: The MIT Press, 2009 (adaptado).

Um programador implementou um algoritmo de ordenação semelhante à forma de ordenação de cartas descrita no texto. Ao realizar um teste com um vetor de nove posições (vetor[1..9]), verificou que o algoritmo não funcionava corretamente.

01 para i <- 2 até 9 faça
02    valor <- vetor[i]
03    j <- i - 1
04    enquanto ((j >= 1) e (valor < vetor[j])) faça
05       vetor[i] <- vetor[j]
06          j <- j - 1
07          se (j = 0) então
08             interrompa
09          fim se
10    fim enquanto
11    vetor[j + 1] <- valor
12 fim para', null, 'Com base nessas informações, assinale a opção em que se apresentam a linha e o respectivo comando a ser substituído, para que o algoritmo ordene corretamente um vetor de inteiros de forma crescente.', null,
   'Linha 01; para i <- 1 até 9 faça', 'Linha 03; j <- i', 'Linha 04; enquanto ((j >= 1) ou (valor < vetor[j])) faça', 'Linha 05; vetor[j + 1] <- vetor[j]', 'Linha 11; vetor[j] <- valor', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 33 (INEP)'),
  ('85a1ddfc-3d36-59b0-9249-cd5704fbf609', 'CE', array['ADS']::public.curso_alvo[], 'Modelagem de dados', 'OBJETIVA', 'JOÃO GRILO: — Isso é coisa de seca. Acaba nisso, essa fome: ninguém pode ter menino e haja cavalo no mundo. A comida é mais barata e é coisa que se pode vender. Mas seu cavalo, como foi?

CHICÓ: — Foi uma velha que me vendeu barato, porque ia se mudar, mas recomendou todo cuidado, porque o cavalo era bento. E só podia ser mesmo, porque cavalo bom como aquele eu nunca tinha visto.

SUASSUNA, A. Auto da Compadecida. Rio de Janeiro: Agir, 2000 (adaptado).

A seguir apresenta-se um modelo de dados elaborado a partir do diálogo entre Chicó e João Grilo.', 'enade2017/ads/ads17-q34.png', 'Com base no diálogo e no diagrama apresentados, avalie as afirmações a seguir.

I. O Chicó e a velha poderão ser cadastrados na entidade pessoa.
II. O Chicó e a velha poderão ter mais que um cavalo cadastrados.
III. O atributo rg da entidade pessoa pode ter a função de chave primária nessa entidade.
IV. O cavalo deverá ter no mínimo uma pessoa e uma pessoa poderá ser cadastrada sem a necessidade de ter um cavalo.

É correto apenas o que se afirma em', null,
   'I e III.', 'I e IV.', 'II e III.', 'I, II e IV.', 'II, III e IV.', 2, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 34 (INEP)'),
  ('c70ff41b-6515-51cd-ad57-90b54374c637', 'CE', array['ADS']::public.curso_alvo[], 'Interação humano-computador', 'OBJETIVA', 'Em um sistema web para venda de ingressos para shows musicais, a equipe de marketing solicitou a um web designer que, na página inicial, os links para a área de venda de ingressos de cada show fossem imagens, para tornar a navegação pelos conteúdos da página mais atrativa e para que o próprio link já servisse como material de divulgação.', 'enade2017/ads/ads17-q35.png', 'A partir do protótipo da página inicial apresentado e usando HTML, o web designer optou por implementar cada link de forma que a imagem forneça um texto informativo (por meio do atributo alt) para usuários que usem leitores de tela, conforme a seguir.

<a href="link-area-venda-ingresso">
   <img src="imagem-show.jpg" alt="identificação do show" />
</a>

Considerando a situação apresentada, o uso do atributo alt e aspectos da interação humano-computador, pode-se afirmar que o web designer atendeu, em sua implementação, o requisito de', null,
   'segurança no uso, pois se uma imagem tiver baixa resolução e impossibilitar a correta visualização, o texto informativo associado à imagem possibilita a identificação do conteúdo do respectivo link.', 'facilidade de aprendizado, pois a comunicação visual do sistema web, por meio do uso de imagens, aliada à comunicação textual, por meio do uso de textos informativos para cada imagem, ajuda o usuário a aprender os caminhos de navegação.', 'acessibilidade, pois a possibilidade de acesso à página por pessoas com deficiência visual, para que interajam com os conteúdos, oferece condições de igualdade às pessoas na interação com o sistema web.', 'ergonomia, pois o uso de imagens em links causa um cansaço visual quando o sistema web é aberto em um smartphone ou em um tablet com baixa resolução, e o atributo alt substitui a imagem por texto.', 'comunicabilidade, pois se uma imagem não comunica adequadamente a informação desejada, um texto alternativo deve complementar a respectiva informação, de forma que a interação com o sistema web não seja prejudicada.', 1, 'ENADE 2017 — Análise e Desenvolvimento de Sistemas, Questão 35 (INEP)')
on conflict (id) do nothing;

insert into public.questoes_gabarito (questao_id, gabarito, justificativa)
values
  ('cef13b07-c329-5453-96bc-770582e7eca5', null, 'ÁREAS DAS AÇÕES / AÇÕES

CAMPO PSICOSOCIAL
• Organização de mutirão de voluntários para distribuição de vestuários, remédios, alimentos e outros insumos entre os atingidos pelo desastre etc.
• Mobilização de voluntários para auxílio ao trabalho de recuperação parcial das casas dos desabrigados.
• Realocação da população afetada para locais seguros.
• Resgate de pessoas afetadas por inundações ou deslizamentos para abrigos emergenciais temporários.
• Mobilização de sistemas de saúde para atendimento de emergência de pessoas feridas.
• Mobililzação de voluntários para campanhas de vacinação.
• Mobilização de sistemas de saúde para ações de prevenção de surtos e epidemias.
• Mobilização de sistemas de saúde para acompanhamento biopsicossocial da população atingida.
• Resgate e/ou proteção de animais domésticos.
• Construção de abrigos para acomodação dos animais resgatados.
• Acompanhamento médico veterinário de animais atingidos pelo desastre.

CAMPO ECONÔMICO E SOCIOCULTURAL
• Estratégias de recomposição de áreas agropecuárias.
• Implementação e recuperação de áreas agrícolas e agroflorestais.
• Liberação de crédito rural para agricultores e criadores atingidos por desastres.
• Recuperação de patrimônios histórico, artístico, cultural ou natural.
• Restauração de museus, igrejas, instituições culturais etc.
• Mobilização de recursos financeiros para auxílio às vítimas.
• Liberação de aluguel social para apoio à população atingida.
• Aplicação e uso de multas para recuperação de áreas atingidas.
• Recuperação de bens materiais das vítimas.
• Liberação pelo governo de fundo emergencial para a reconstrução das moradias da população atingida.
• Campanha de captação de recursos financeiros para reconstrução de casas atingidas.
• Facilitação na liberação de crédito para compra de mobiliário residencial.

CAMPO AMBIENTAL
• Atividades de recuperação do ecossistema da área atingida.
• Reflorestamento das áreas degradadas com vegetação nativa.
• Resgate de animais silvestres.
• Recuperação e/ou proteção de mananciais.
• Reflorestamento de nascentes com vegetação nativa.
• Monitoramento e/ou controle da qualidade da água.
• Monitoramento e/ou controle da qualidade do solo.
• Verificação periódica dos padrões de potabilidade da água depois de desastres.
• Descontaminação do solo com presença de metais pesados.

CAMPO INFRAESTRUTURA
• Restauração de serviços públicos essenciais.
• Restauração no abastecimento de água, energia elétrica, combustíveis, comunicações.
• Limpeza de bueiros para facilitar escoamento das águas em caso de alagamentos.
• Retirada de entulhos e lixo para facilitar o escoamento da água acumulada.
• Implementação de sistemas de alertas.
• Alertas através da programação de emissoras.
• Avisos sonoros em locais críticos para resgate de vítimas.
• Recuperação de artefatos de acesso e mobilidade.
• Restauração de pontes, rodovias etc.
• Desenvolvimento de gerenciamento de sistemas de monitoramento remoto.
• Utilização de drones para localização de vítimas de desastres.
• Monitoramento de manchas de óleo em áreas costeiras por meio de imagens de satélite.
• Desenvolvimento de processos, produtos e tecnologias para recuperação ou restauração.
• Reconstrução da malha viária com asfalto poroso de alta permeabilidade.
• Tecnologias para descontaminação e desintegração de manchas de óleo.
• Utilização de “lama” de barragem como material de construção civil para recuperação habitacional.

CAMPO SISTÊMICO
• Remodelagem de procedimentos de segurança e de processos industriais.
• Convocação e treinamento de pessoal de segurança para evitar saques.
• Treinamento da população para ações durante e/ou após ocorrência de desastres.
• Palestras para voluntários em ações de reflorestamento de áreas degradadas.
• Treinamento de equipes e comunidade para apoio no resgate de vítimas.
• Treinamento emergencial de voluntários para limpeza de praias poluídas por vazamento de óleo.
• Orientação sobre riscos à saúde a voluntários por conta da manipulação de material tóxico na limpeza de praias sem proteção adequada.
• Promoção de ações de restauração da ordem pública.
• Parceria entre diferentes esferas governamentais para fortalecimento da segurança pública.

SECA/ESTIAGEM
• Implementação de tecnologias de dessalinização da água do mar.
• Aproveitamento da água da chuva nos períodos de pouca chuva ou estiagem.
• Construção de cisternas para armazenamento de água da chuva.
• Reflorestamento da mata ciliar.
• Racionamento de água em níveis críticos de vazão/disponibilidade hídrica.
• Reúso da água (Exemplo citado: água de banho pode ser captada e usada para lavagem de quintal e para dar descarga em vasos sanitários).
• Monitoramento da qualidade da água de reúso.'),
  ('c433a3c9-e02d-56ca-81aa-4ca0b83ba065', null, 'O estudante deve apontar dois ganhos possíveis, como os apresentados, resultantes de uma boa articulação entre pelo menos dois dos entes representados na figura:

Item ‘a’ - CAMPO CIENTÍFICO –
• Ampliação dos recursos para a produção de conhecimento científico voltado para resolução de problemas
• Transferência mútua de conhecimento e de tecnologia.
• Ampliação das fontes de financiamento para desenvolvimento de pesquisa, tais como bolsas, montagem e manutenção de laboratórios, disponibilização de equipamentos e de prestação de serviços.

Item ‘b’ CAMPO ECONÔMICO
• Ampliação do investimento na criação de soluções tecnológicas mais acessíveis e mais adequadas às necessidades locais.
• Desenvolvimento de tecnologias que propiciem uso sustentável de recursos naturais e de insumos diversos.
• Desenvolvimento de novos produtos, processos e materiais ajustados às demandas e potencialidades do contexto local;
• Desenvolvimento de tecnologias e arranjos que propiciem a constituição de cadeias produtivas mais sustentáveis, com maiores aportes e insumos locais.
• Desenvolvimento de arranjos produtivos locais com participação das IES;
• Ampliação de canais de inserção laboral dos estudantes e egressos.
• Diversificação de estruturas produtivas e empresariais do país (startups, incubadoras, empresa júnior, fundação de apoio, joint venture).
• Ampliação dos investimentos voltados para o alcance de novas patentes'),
  ('69796919-322d-565b-82cd-a76c16f9d278', 'D', null),
  ('a74430e4-4512-5a5b-9735-217b280d35fc', 'C', null),
  ('af6a861f-7ad1-5163-ba3e-dbceeba3a496', 'B', null),
  ('9edea88f-3206-5cdc-bc48-2551271cad5f', 'C', null),
  ('6aa20def-8e25-5570-9cd3-12f390e3cd36', 'C', null),
  ('412ba6be-0dff-5a75-870f-a425d12b12fe', 'D', null),
  ('049e249f-4cd8-5242-b2b5-1b8c645f9302', 'B', null),
  ('9a9c3f25-12c1-5e2a-945f-505c88436b45', null, 'No trabalho do mecânico durante a parada no box existem condições cujas características, segundo a NR 15, tornam o trabalho insalubre, das quais o estudante deverá citar 4. Abaixo são listadas 5 possíveis condições:

1) Condição: exposição a ruídos de impacto devido ao funcionamento das pistolas pneumáticas (ruído);
EPI: protetor auricular;
2) Condição: exposição a ruído contínuo e/ou intermitente de alta intensidade devido ao funcionamento do carro;
EPI: protetor auricular;
3) Condição: exposição a altas temperaturas;
EPI: vestimentas isolantes (luvas, balaclavas, macacão, ETC);
4) Condição: exposição a agentes químicos devido a manipulação de combustíveis contendo etanol e gasolina;
EPI: respiradores, óculos de proteção, luvas etc.;
5) Condição: exposição ao sol no trabalho ao ar livre;
EPI: roupa com proteção UV, protetor solar e óculos de proteção;'),
  ('99d16d90-20c1-577f-a937-bd808b582de7', null, 'a) O estudante deve desenhar um diagrama tal como:

[Diagrama T–s: eixo vertical T (temperatura) e eixo horizontal s (entropia específica), com a curva de saturação em forma de "sino". O estado 1 fica sobre a linha de líquido saturado, na pressão baixa; de 1 a 2 (w_bomba,ent), compressão isentrópica vertical até a isobárica de alta pressão (estado 2, líquido comprimido, ligeiramente acima de 1). De 2 a 3 (q_ent), aquecimento a pressão constante: a isobárica sobe pela região de líquido, atravessa horizontalmente a região de mudança de fase sob o sino e sobe na região de vapor superaquecido até o estado 3. De 3 a 4 (w_turb,sai), expansão isentrópica vertical até o estado 4, sobre a linha de vapor saturado. De 4 a 1 (q_sai), condensação a pressão e temperatura constantes, linha horizontal sob o sino de volta ao estado 1. Setas indicam o sentido de cada processo.]

No diagrama será avaliado se o estudante fez a:

I - identificação dos eixos, inserindo "T" (Temperatura) na ordenada e "s" (Entropia específica) na abcissa;

II - representação das duas linhas isobáricas cruzando as linhas de líquido saturado e vapor saturado, identificadas pela curva com formato de "sino";

III - identificação dos 4 estados respeitando a definição das regiões apresentadas na tabela junto ao enunciado da questão;

IV - apresentação do sentido em que ocorre cada processo através de uma seta.

b) O rendimento térmico do ciclo é calculado através da razão entre o trabalho específico líquido gerado e o calor por unidade de massa fornecido à caldeira

η = w_liq / q_ent = 1 − q_sai / q_ent

Por sua vez, o trabalho específico líquido pode ser obtido pela subtração entre o trabalho específico gerado pela turbina e o trabalho específico consumido pela bomba. O estudante deve aplicar o módulo no trabalho específico consumido pela bomba, visando obter um balanço entre as duas energias específicas.

w_liq = w_turb,sai − |w_bomba,ent|

w_turb,sai = h₃ − h₄ = 3510 kJ/kg − 2490 kJ/kg = 1020 kJ/kg

|w_bomba,ent| = h₂ − h₁ = 210 kJ/kg − 190 kJ/kg = 20 kJ/kg

q_ent = h₃ − h₂ = 3510 kJ/kg − 210 kJ/kg = 3300 kJ/kg

Substituindo os resultados obtidos para os trabalhos específicos e o calor por unidade de massa fornecido à caldeira, tem-se

η = (1020 kJ/kg − 20 kJ/kg)/(3300 kJ/kg) = 0,3030 = 30,3%

c) A potência elétrica é obtida pelo produto entre a potência de eixo gerada pela turbina a vapor e o rendimento global do gerador de energia elétrica

Ẇ_ger = η_g × Ẇ_turb,sai

Com base na primeira lei da termodinâmica, a potência de eixo gerada pela turbina a vapor isentrópica é calculada a partir do produto entre a vazão mássica e o trabalho específico gerado pelo equipamento

Ẇ_turb,sai = ṁ × w_turb,sai

Convertendo a vazão mássica para kg/s

ṁ = 180 t/h = 50 kg/s

Substituindo os valores, tem-se

Ẇ_ger = 0,8 × 50 kg/s × 1020 kJ/kg = 40800 kW = 40,8 MW'),
  ('860267d7-9af8-56f6-901a-b0476303b978', 'D', null),
  ('eac03f9c-42ed-5fcd-ae64-1173905f114f', 'E', null),
  ('d5a1a31e-01d7-5aac-a647-7c5da23ca543', 'B', null),
  ('5e26a161-21f5-5b0d-881a-323e232206af', 'D', null),
  ('22d8085c-2c51-529a-901b-ce5ca08b40fb', 'A', null),
  ('328b9d17-f813-5b85-a424-a715cd80ec58', 'E', null),
  ('c9de0e09-db95-5c9e-9c7d-b8ff80e75ede', 'B', null),
  ('59e430a7-d747-5ab0-a013-666528de9388', 'A', null),
  ('114cf68e-db11-534d-ae33-f0b400915e79', 'D', null),
  ('30d1dcf5-fc71-58cb-8b44-17bb4af5704a', 'A', null),
  ('8b5c94ba-801b-58b9-b3dd-57f2ad7759f8', 'C', null),
  ('1bcfab70-6a28-5904-9141-433e4b74ff10', 'D', null),
  ('a9824830-d85f-5363-9982-2e55f7a69c74', 'C', null),
  ('1e3132a8-8d6d-50e2-9269-c82f89302b22', 'B', null),
  ('74edfa3d-af1d-562d-ac8d-396bdce649fe', 'C', null),
  ('c0e4923e-f5b5-5540-8a31-6d1f2e1ccb21', 'D', null),
  ('80adb5c1-21fc-5daa-83d8-77369fef93c3', 'C', null),
  ('335d8ab6-03e6-5f21-8352-3aca66d9b896', 'A', null),
  ('79ae22b0-91f4-5f26-941c-37483c1812b0', 'B', null),
  ('05e5138c-206f-5680-a1e6-d946b81668de', 'B', null),
  ('3f070f23-313e-5a77-922a-1e1e016e554d', 'E', null),
  ('ee1940ce-69f8-5e31-af1a-427af041361d', 'D', null),
  ('50c098f2-615b-5e20-ab98-69d008934644', 'B', null),
  ('3abee0af-eecc-5bff-bb1c-1c3c9609c747', 'C', null),
  ('692c6a0c-f132-5daa-a0aa-4e146f7749f3', null, 'a) O estudante deve citar uma das seguintes desvantagens desse sistema:

• complexidade, com processo de implementação trabalhoso e demorado;
• complexidade na manutenção do sistema;
• retorno de esforços no médio prazo, o que dificulta, de imediato, uma visualização clara da relação custo/benefício;
• tempo de implementação longo, necessidade de planejamento de treinamento aprofundado, para evitar problemas de implementação;
• necessidade de investimento considerável de tempo e esforço em treinamento, associada à curva de aprendizado elevada exigida para operação do sistema;
• alto investimento de implantação e customização, sendo normalmente adotado por empresas de grande porte;
• mudança na cultura organizacional, que é bastante complicada caso não seja bem trabalhada em todas as áreas funcionais;
• necessidade de mudanças nos processos em função da lógica própria dos processos do sistema ERP;
• possibilidade de desalinhamento do ERP com a estrutura de processos da empresa;
• possibilidade de dados inconsistentes;
• necessidade de integração de diferentes sistemas;

b) O estudante deve citar uma das seguintes vantagens desse sistema:

• em níveis de excelência operacional;
• relacionamento mais estreito com clientes e fornecedores;
• melhor tomada de decisão e vantagem competitiva.

Na sequência, deve justificar sua resposta mobilizando formulações como as mencionadas a seguir:

• o ERP integra todo o fluxo de informação da organização em um único sistema;
• aprimora a comunicação entre os diferentes setores da organização, reduzindo o tempo de processamento da informação e consequentemente da tomada de decisões;
• aumenta a eficiência de atividades como compras, produção e estoque;
• aumenta o controle de todo o fluxo de processo, desde o nível operacional até o estratégico;
• controla desde a compra de matéria prima de fornecedores até a entrega de produtos para clientes;
• elimina redundância de informação e, consequentemente, de atividade em toda a organização;
• centralização de informações em banco de dados único, evitando redundâncias;
• maior segurança da informação, possibilitando controle de acesso;
• integração e controle de todo o fluxo de informação da organização e partes interessadas em um único sistema, desde o nível operacional até o estratégico;
• padronização das atividades, permitindo entendimento unificado dos colaboradores;
• aumento da eficiência de atividades (como compras, produção e estoque), contribuindo para a excelência operacional;
• aprimoramento da comunicação entre os diferentes setores da organização, reduzindo o tempo de processamento da informação e consequentemente da tomada de decisões;
• eliminação de redundância de informação e, consequentemente, de atividade em toda a organização;
• eliminação de inconsistências de informação, diminuindo chances de erros na tomada de decisão;
• redução do uso de papel na execução dos processos, diminuindo as chances de erros e contribuindo para a sustentabilidade;
• contribuição para a identificação de problemas e condução de projetos de melhoria de processos e melhor tomada de decisão para sustentação da vantagem competitiva.'),
  ('1f594c6f-6f13-52c9-b689-38f0e2fe7260', null, 'a) O estudante pode citar três dos seguintes atores:

• fabricantes, importadores, distribuidores e comerciantes, os consumidores e os titulares dos serviços públicos de limpeza urbana e de manejo de resíduos sólidos.
• União, estados, Distrito Federal e municípios em suas políticas de incentivo e de regulação.
• As responsabilidades mencionadas devem incluir os cuidados com o descarte, o aproveitamento sistêmico, a reutilização, o reuso, a economia circular.

b) O estudante não deve deixar de mencionar os impactos relacionados à destinação final ambientalmente adequada, incluindo:

• contaminação dos rios, mares e mananciais de água, tanto superficial, quanto subterrâneo;
• proliferação de doenças transmitidas por vetores que desenvolvem-se nos resíduos;
• aumento dos índices de alagamentos, em decorrência de entupimento das bocas de lobo que dão acesso às galerias pluviais;
• assoreamento dos rios;
• danos à biodiversidade e ao ecossistema (ex.: ingestão dos materiais por parte dos animais);
• aumento dos custos operacionais das estações de tratamento de água, por conta da necessidade de aumento de capacidade da etapa de gradeamento (tratamento primário do processo de tratamento de águas, responsável pela separação dos elementos sólidos mais grosseiros);
• dispersão de substâncias químicas a longo prazo. A garrafa pet e o alumínio se degradam com o tempo e, durante esse período, liberam substâncias químicas danosas ao ambiente.'),
  ('a5ec299f-3494-5fed-a874-b3a78316ec64', null, 'a) O estudante compreende a situação e raciocina corretamente para resolver a questão formulada.

Para resolver a questão no que diz respeito ao cálculo da quantidade produzida no período, o estudante compreende que:

O custo total do período (R$ 900 000,00) é igual ao custo fixo total do período (R$ 200 000,00) mais o custo variável total do período, sendo este último resultado da multiplicação do custo variável por unidade (R$ 50,00) pela quantidade de produtos produzidos no período (variável a ser calculada).

Desta forma, a quantidade produzida é resultado da seguinte equação:

(900 000 - 200 000) / 50 = 14 000 unidades.

b) Para calcular a quantidade de equilíbrio, o estudante deve considerar que a quantidade de equilíbrio é aquela que gera lucro contábil igual a zero.

Calcular a quantidade de equilíbrio como resultado da divisão do custo fixo total do período (R$ 200 000,00) pela margem de contribuição unitária do produto, sendo esta calculada pela diferença entre o preço de venda por unidade (R$ 70,00) e o custo variável por unidade (R$ 50,00).

Como resultado, tem-se uma quantidade de equilíbrio igual a 10 000 unidades.'),
  ('0aaad1cb-885d-515b-950b-16a07a43db3e', 'B', null),
  ('3a6e76b8-904f-5d2a-b78a-dbb5a52cf2af', 'C', null),
  ('64f65282-cbf5-598a-bbab-602f2cab0be3', 'C', null),
  ('cdaeedc9-5035-51eb-b607-6c9d1bb8dd9c', 'A', null),
  ('a4109639-0e8a-52ab-baf2-7b15e9a3d132', 'E', null),
  ('46fd179b-afda-51c7-858c-0f6a0961f23a', 'D', null),
  ('c5b19d4e-06b5-5ca7-9d15-d074c342eab2', 'E', null),
  ('3690a022-f681-5592-91d4-b888b85bf463', 'D', null),
  ('d9e4cf15-722a-5030-a164-df9ee94e7005', 'C', null),
  ('c26ee4c6-d3cd-5aa0-9a07-df026ac538aa', 'B', null),
  ('0a532afa-51e1-5b29-8ded-1676feb23b9e', 'E', null),
  ('5405c6c6-89a2-5a23-a5a5-1c867ce49279', 'C', null),
  ('cb94fb32-324a-56e8-9a6e-728d8ed19114', 'D', null),
  ('4b88acfa-c441-539e-a77b-d9bf0ef8b627', 'A', null),
  ('7800ecde-961a-588e-9b7d-724d686c3a5d', 'C', null),
  ('5d76fd36-1e58-5b52-81ae-90fd7e2700ef', 'E', null),
  ('31019a37-328a-515d-bfd3-bbb9fb615c14', 'D', null),
  ('15b21d87-441c-54c1-b6f6-d5b750ca066f', 'A', null),
  ('21f81a66-e35f-50c4-8d6b-14f2b5fb1e7d', 'C', null),
  ('a3e0c507-2aee-5abd-8657-b1e19c629fdc', 'A', null),
  ('ebf7a95e-59c0-55dc-a916-3104e7d8b8ef', 'D', null),
  ('fd2e2acf-57c5-5699-a73d-fc35b6bb239f', 'E', null),
  ('398d1a4e-64c5-5785-a27a-bf278bfacfaf', 'B', null),
  ('4e3697e9-6608-564c-9c8d-e90fbac309c2', 'C', null),
  ('fde79f87-57b8-51b2-93f8-ebfc227f7fab', 'B', null),
  ('0afe0fcc-c805-5596-bcaa-ae6ece0cf82a', 'B', null),
  ('84661ed6-af14-5262-ae32-b55e5bf200f4', 'E', null),
  ('daceab06-17c0-581b-bbcd-dd5b71c070ee', null, 'O respondente deve, a partir dos argumentos presentes no texto I, refletir sobre as tensões existentes entre a arte e a cultura no Brasil contemporâneo e sobre a liberdade artística explicitado no artigo 5º da Constituição Federal (Texto II), de modo a perceber a ilegitimidade dos movimentos de censura que tem eclodido em determinados segmentos da sociedade brasileira.

O respondente deve, ainda, apresentar duas ações educativas para a superação das tensões citadas, como: encontros de artistas e público em escolas e outros espaços públicos; projetos de visitação a espaços culturais, como museus e galerias, voltados para a formação de público/plateia; debates em espaços públicos a respeito da liberdade artística, etc.

(Valor: 10,0 pontos)'),
  ('cfadec24-b416-5be4-adeb-47fc05b52236', null, 'a) O respondente deve mencionar que as cidades inteligentes podem diminuir o impacto ambiental dos aglomerados urbanos, pois, ao utilizarem a tecnologia como um fator indispensável para modernizar e oferecer melhor infraestrutura e serviços, colaboram, por exemplo, com a redução no consumo de energia e na emissão de CO2.

b) O respondente deve elaborar uma proposta de intervenção que gere impacto social e contribua para a melhoria da vida em comunidade. Exemplos de intervenção incluem:
✓ Proposição de aplicativos para:
  • compartilhamento de transporte (caronas);
  • oferecimento de pequenos serviços (babá, petsitter, acompanhamento de idosos, acompanhamento psicológico);
  • doação de produtos, alimentos, etc.
✓ Plano de ação a fim de oferecer serviços específicos a grupos menos favorecidos, como idosos ou população de rua.
✓ Concepção de artefatos urbanos para melhorar a mobilidade urbana ou para permitir a passagem de fauna.
Etc.'),
  ('8fc8ed6e-a127-5e89-8aa2-6a1fec3eefeb', 'E', null),
  ('51d86b62-83b9-521c-976e-d92a55446106', 'C', null),
  ('3da5aabd-9461-54ad-a263-613265b27315', 'B', null),
  ('689eb746-0e4c-5001-be86-ed27a0b537b4', 'B', null),
  ('d782eb86-a38e-5273-bc23-6e36444bc011', 'A', null),
  ('97762bde-ec43-5a75-b6a2-60084f7b6fd0', 'A', null),
  ('f41f49e5-4161-5305-9ba1-7f9ac9398338', 'C', null),
  ('23451b55-fe4d-546b-aa04-b5c153abd8a0', 'D', null),
  ('2075435d-d928-5990-bafb-647a9d498171', null, 'O respondente deve desenvolver o seguinte código:

algoritmo “pesquisa”
var altura[1000], menor, maior, total=0, media:real
var qtdmenor=0, ctpessoas: inteiro
inicio
leia altura[1]
menor = altura[1]

maior = altura[1]
total = altura[1]
para ctpessoas=2 até 1000 faça

    leia (altura[ctpessoas])
    total=total + altura[ctpessoas]
fimpara
media = total/1000

para ctpessoas=1 até 1000 faça

    se menor > altura[ctpessoas] então menor = altura[ctpessoas]
    se maior < altura[ctpessoas] então maior = altura[ctpessoas]
    se media > altura[ctpessoas] então qtdmenor = qtdmenor + 1
fimpara
escreva (“Maior = “, maior, “ Menor= “,menor,” Média= “,media, “ Quantidade de alturas menores que a média= “,qtdmenor)'),
  ('80c1c033-0cf1-54d0-908c-fe9801c17b0d', null, 'O respondente deve elaborar um diagrama da UML para o sistema, contendo no mínimo, as classes, atributos, métodos e associações a seguir:

[Diagrama de classes do padrão de resposta, descrito em texto]
• Classe CLIENTE — atributos: CPF, Nome, Email, Telefone, Endereco.
• Classe RESERVA — atributos: Codigo, Status, Valor_Total; métodos: Solicitar(), Pagar(), Emitir_Check_In().
• Classe FORMA_PAGAMENTO — atributo: Descricao.
• Classe RESERVA_IDA — atributos: Data_Ida, Hora_Ida, Valor_Ida (subclasse de RESERVA, generalização/herança).
• Classe RESERVA_VOLTA — atributos: Data_Volta, Hora_Volta, Valor_Volta (subclasse de RESERVA, generalização/herança).
• Classe CIDADE — atributos: Nome, Aeroporto, Pais.
• Associação "Realiza": CLIENTE (1..1) — RESERVA (0..*).
• Associação "Possui": RESERVA (0..*) — FORMA_PAGAMENTO (1..*).
• Associação "Ida": RESERVA_IDA (0..*) — CIDADE (1..1).
• Associação "Volta": RESERVA_VOLTA (0..*) — CIDADE (1..1).'),
  ('b0ef092c-aaf4-588d-9fc6-8bfb406d9aa8', null, 'O respondente deve implementar a função inserir_prioridade no código fonte apresentado. Assim, a lógica do algoritmo deve atender a dois fundamentos básicos de inserção de nós em uma lista simplesmente encadeada.
1) INSERÇÃO NO INÍCIO: caso ainda não haja nenhum cartão amarelo na fila, o novo nó é inserido no início, como primeiro elemento da fila;
2) INSERÇÃO NO MEIO: se já houver cartões amarelos na fila, o novo nó é inserido no meio ou no final da fila, a depender, respectivamente, da presença ou da ausência de algum cartão verde; para ambos os casos, contudo, a lógica de inserção do nó é exatamente a mesma, pois as variáveis ant e aux são usadas para percorrer a lista simultaneamente e atualizar as referências (ponteiros) entre os nós.

É natural que o estudante siga essa sequência lógica e, portanto, espera-se que escreva a função

 1 Lista* inserir_prioridade(Lista* l, Lista* no) {
 2     if (l->cartao == ''V'') {
 3         no->prox = l;
 4         l = no;
 5     } else {
 6         Lista* ant = l;
 7         Lista* aux = ant->prox;
 8         while (aux != NULL && aux->cartao == ''A'') {
 9             ant = aux;
10             aux = aux->prox;
11         }
12         ant->prox = no;
13         no->prox = aux;
14     }
15
16     return l;
17 }

Observação: Serão aceitas respostas em outra linguagem de programação compatível ou pseudo-código.'),
  ('6636c9a0-b05f-5050-afd1-44a7b6daafc4', 'C', null),
  ('01fc6691-038f-504e-8d7d-3232ec3b524a', 'D', null),
  ('f87fd59d-8f62-514c-847e-0a8dd00b3723', 'E', null),
  ('fbbcec2a-d3a5-592a-b2f8-f0f7238d44bd', 'C', null),
  ('8ab6bc35-b972-5769-8633-35617f34b64d', 'C', null),
  ('a83d4f98-ab34-5798-b4eb-47974624fc1c', 'E', null),
  ('184bfbb4-24a1-5382-ab6e-faa9bc3179e7', 'B', null),
  ('c0a3dff4-229f-586e-a40f-5e8ddabfdf6d', 'E', null),
  ('3fdd3afb-4759-56ee-8913-d9a3e9afaac8', 'C', null),
  ('9dd85e41-f184-5550-bbbf-d0f7e75a46ca', 'A', null),
  ('fea0ce34-c974-557e-bea8-5f83b72bd240', 'A', null),
  ('20165afd-fcc1-59b4-bfd0-5ca2ae9f29f5', 'E', null),
  ('84740262-503c-5fb8-8693-69739d1895e2', 'B', null),
  ('371754ac-0642-547e-bceb-10a8df7c37c8', 'A', null),
  ('40cdc04e-ebe2-5429-a2d3-2d926264bc8c', 'B', null),
  ('3f368c08-94a8-56a8-af68-ed997afb384f', 'D', null),
  ('f4274832-b451-57f2-b9ee-f500ca900944', 'E', null),
  ('58edc0fe-4af5-51ec-ac1a-6e73248a644f', 'E', null),
  ('92c70bcf-0848-58ba-9156-32a380e169b2', 'C', null),
  ('0bf21b2a-a8d3-51c1-a7d5-f2bc90ce191f', 'B', null),
  ('cc6eaa98-255d-53ba-930c-38fb8c730154', 'D', null),
  ('a08496d2-e1c1-53ea-ad74-2916c8bb47ef', 'C', null),
  ('4c28ea9f-b6ea-586d-93c8-d14dcee07eaf', 'D', null),
  ('3f3de941-29ea-5306-9d46-2b00a1bdf703', 'B', null),
  ('dade7e91-361a-5d1c-b7e6-d38a432a2825', 'D', null),
  ('f79972c8-f314-560f-b3c8-f345a0a02af7', 'A', null),
  ('f0228ba3-a6f0-5df2-bd26-b8c04abc0943', 'A', null),
  ('1f7c87d9-a1d3-5376-8bd1-d621714aa93e', null, 'Em seu texto, o estudante deve abordar os seguintes aspectos:

A proporção crescente de casos novos de sífilis no segmento feminino é evidência que tem sido cada vez mais encontrada no perfil epidemiológico não apenas dessa doença, mas também de várias outras doenças sexualmente transmissíveis (DST).

A vulnerabilidade desse grupo específico resulta da conjuntura de diversos fatores, sendo os fatores sociais e culturais de grande relevância. Nesse sentido, questões relacionadas ao padrão de comportamento de homens e mulheres no contexto das relações sexuais, bem como crenças morais, valores, relações de poder, entre outras, são muito influentes no grau de suscetibilidade feminina às DST.

A hierarquia de poder muitas vezes encontrada nas relações afetivas influenciam o papel das mulheres na tomada de decisões a respeito da relação sexual, afetando o espaço que têm (ou não) para negociar o uso do preservativo com seus parceiros, bem como as habilidades para abordar temas de DST junto a eles.

Aspectos culturais e morais afetam as atitudes de homens e mulheres no que diz respeito ao acesso e porte de preservativos, pois elas muitas vezes se sentem constrangidas tanto para comprar os preservativos quando para levá-los consigo. Cabe ressaltar que, no contexto dos cuidados em relação à saúde sexual e reprodutiva, a responsabilidade costumeiramente recai sobre a mulher. Além disso, culturalmente, o público masculino não costuma buscar os serviços de atenção primária à saúde e não se sente vulnerável às DST. Ademais, tendo em vista que os sintomas no público masculino são mais raros e/ou discretos, os homens muitas vezes sequer têm conhecimento de que estão contaminados, infectando suas parceiras e, muitas vezes, reinfectando-as, o que no contexto da sífilis congênita é ainda mais perigoso.

Com o intuito de fortalecer as ações de prevenção à sífilis e outras DST, são importantes ações no âmbito das políticas públicas de saúde e de educação especificamente dirigidas ao público masculino. O estudante pode citar, pelo menos, duas entre as ações listadas a seguir.

1. Ações de atenção primária voltadas à prevenção, que incentivem que o público masculino faça exames para detecção precoce de DST regularmente;
2. Programas de incentivo e atendimento ao público masculino no contexto dos exames de pré-natal, para ajudar a conter a reinfecção das gestantes no caso de parceiros já contaminados;
3. Programas especializados voltados para atender ao público masculino nos serviços de atenção primária, considerando suas especificidades e oferecendo serviços voltados à prevenção;
4. Campanhas de educação voltadas para a problematização da questão em ambiente escolar, a fim de introduzir uma cultura de responsabilidade com a saúde;
5. Inserção, em materiais didáticos, de textos sensibilizadores direcionados à importância do papel dos homens em relação à prevenção das DST;
6. Propostas de projetos educacionais em ambiente escolar direcionados ao desenvolvimento de relações afetivas saudáveis em que o diálogo entre os parceiros a respeito da saúde sexual seja viabilizado;
7. Campanhas educativas em espaços formais e não formais para desmistificar crenças e padrões morais de compreensão do protagonismo feminino diante da compra, do porte e da negociação do uso de preservativo com os parceiros;
8. Propostas de políticas públicas para a promoção de qualidade de vida seja na atenção primária, seja em campanhas educativas.'),
  ('502ddda6-36cd-581f-9dbc-5f099fd79849', null, 'O estudante deve mencionar que o nome, materializado nos documentos oficiais de identificação, quando não condiz com a identidade de gênero, pode gerar diversos problemas relacionados ao acesso das pessoas à cidadania, tais como: acesso à saúde e educação, direito ao voto e inserção no mundo do trabalho.

Como política pública, o estudante pode mencionar:

• Facilitar a mudança dos documentos para pessoas transgêneras, reconhecendo a autonomia das pessoas em relação à definição de sua identidade de gênero;
• Elaboração de leis que garantam a mudança do nome e assegurem outros direitos para as pessoas transexuais;
• Ampliação do acesso à saúde, através de atendimento pelo SUS e implementação de núcleos de assistência psicológica para pessoas transgêneras e familiares;
• Tornar obrigatório que estabelecimentos comerciais e empresas utilizem o nome social das pessoas que assim solicitarem, sejam clientes ou empregados;
• Campanhas de conscientização social contra o preconceito e campanhas educativas específicas a serem realizadas em ambiente escolar;
• Desenvolvimento de ações afirmativas de inclusão pessoas transgêneras;
• Adoção de sanções legais para quem violar o direito à autodeterminação de gênero.'),
  ('30ef90a9-3e72-5427-8cff-3e2b561d649c', 'C', null),
  ('5581085f-ce21-5a59-8247-a401c90aaaf5', 'C', null),
  ('bb8d88de-7191-5649-ae80-f3ead52d333b', 'B', null),
  ('fb87cecf-ac34-549f-9132-ce319f5c4bac', 'B', null),
  ('87362b70-75c4-50ed-ab83-16c3045ac91f', 'C', null),
  ('55ccce18-0615-582e-a49c-765bb158b3b1', 'E', null),
  ('5dcfa937-48ad-58fe-b708-cf282d113924', 'A', null),
  ('a626ab6d-0f82-59f5-9dd8-1dbe005a9929', 'D', null),
  ('0faa56e2-7009-55c5-8548-db36f9346e57', null, 'a) O estudante deve apresentar um algoritmo tal como:

/* Colocação dos produtos na estante */
Para i de 1 até 40 passo 1 Faça
   Para j de 1 até 40 passo 1 Faça
      imprima "Digite o código do produto da posição", i , " e ", j, ":"
      leia Estante[i][j]

/* o Estudante pode ou não fazer a validação da entrada de dados aqui */

      Se  (Estante[i][j]<0 ou Estante[i][j]>5)
        imprima "Codigo de produto invalido"
        j <- j-1
      Fim_Se
   Fim Para
Fim Para

b) O estudante deve apresentar um algoritmo tal como:

/* Trecho para contar a quantidade de cada tipo de produto, caso a entrada de dados tenha sido validada */
Para i de 1 até 40 passo 1 Faça
   Para j de 1 até 40  passo 1 Faça
      Contador[Estante[i][j]]=Contador[Estante[i][j]]+1
   Fim Para
Fim Para

/* Caso o aluno não tenha validado a entrada de dados, o trecho de contagem deve ser este abaixo, que verifica o código do produto antes de fazer a contagem: */
Para i de 1 até 40 passo 1 Faça
   Para j de 1 até 40  passo 1 Faça
      Se  (Estante[i][j]>=0 e Estante[i][j]<=5)
        Contador[Estante[i][j]]=Contador[Estante[i][j]]+1
      Fim_Se
   Fim Para
Fim Para

/* imprimir a quantidade de caixas de cada tipo de produto na Estante */
Para i de 1 até 5 passo 1 Faça
   imprima "Produto ", Produto[i],  " possui ", Contador[i], " caixas na Estante"
Fim Para'),
  ('9b3817c1-dd37-5a9e-8d48-2b38f467e682', null, 'a) O estudante deve apresentar um algoritmo tal como:

Função desenfileirar() : texto
   var
      retirado : texto
      x : inteiro
   inicio
      Se(total = 0) então
         retirado <- "Fila vazia"
      Senão
         retirado <- caminhoneiros[1]
         total <- total - 1
         Para(x <- 1 até total passo 1) faça
           caminhoneiros[x] <- caminhoneiros[x+1]
         fim-para
      fim-se
      retorna retirado
   fim

b) O estudante deve apresentar um algoritmo tal como:

Procedimento mostrarFila()
   var
      x : inteiro
   início
      Se(total = 0) então
        imprima("Fila vazia")
      Senão
         Para(x <- 1 até total passo 1) faça
           imprima(caminhoneiros[x])
         fim-para
      fim-se
   fim

ou

Procedimento mostrarFila()
   var
      x : inteiro
   início
      Para(x <- 1 até total passo 1) faça
        imprima(caminhoneiros[x])
      fim-para
   fim'),
  ('b5189b93-faeb-5da6-94f1-d7ed1a5f544e', null, 'O estudante deve construir um diagrama de classe conforme o apresentado a seguir.

[Diagrama de classes do padrão de resposta, descrito em texto:]
• Classe Colaborador: - matricula : int; - nome : String; - senha : String; - email : String.
• Classe Projeto: - id : int; - nome : String; - descricao : String; - duracao : int.
• Classe Melhoria (subclasse de Projeto, herança): - resultadosEsperados : String.
• Classe Social (subclasse de Projeto, herança): - publico : String.
• Classe Departamento: - nome : String.
• Classe Comentario (classe de associação, ligada por linha tracejada à associação entre Colaborador e Projeto): - texto : String; - dataHora : Date.
• Associação Colaborador–Projeto (Comentario): Colaborador 0..* — Projeto 0..*.
• Associação "coordenador": Colaborador 1 — Projeto 0..*.
• Associação "participante": Colaborador 0..3 — Projeto 0..*.
• Associação Melhoria 0..* — Departamento 1.

Espera-se que o estudante:

• Use o princípio de herança para distinguir as categorias de projetos.
• Especifique as duas associações necessárias entre as classes Colaborador e Projeto, para representar os distintos papéis que um colaborador pode assumir; neste caso, é aceitável que o estudante use agregação no lugar das associações “coordenador” e “participante”, desde que especifique a classe Projeto como o “todo” e a classe Colaborador como a “parte”, em ambos os papéis que assume.
• Crie uma classe de associação para representar os comentários, embora também seja aceitável que o estudante crie a classe Comentario, associada às classes Colaborador e Projeto, com associações que tenham multiplicidade 1 partindo-se dessas classes e chegando à classe Comentario com multiplicidade 0..*.
• Crie a classe Departamento, a fim de que o departamento possa ser selecionado de uma lista no cadastro de projetos de melhoria de processos.'),
  ('7d78ac2f-e070-5791-af9e-f04acdc0286e', 'B', null),
  ('a3b08535-7649-515e-a61c-497c7b3b7124', 'C', null),
  ('41c7434d-ed82-57c0-805a-f3a0663085dc', 'C', null),
  ('02f4b0f6-bc74-56a2-a0ca-c1f7678a961b', 'D', null),
  ('5bb6bc29-5b7e-51a6-b658-b7dcdef736f0', 'C', null),
  ('96e063a2-104c-5293-9b8f-272727fb1953', 'C', null),
  ('f05a8435-dfd6-520b-aa7c-f2abc8fadc07', 'A', null),
  ('05187aeb-283f-5bfa-9da9-c78916adc7e9', 'D', null),
  ('147bd849-ae72-5c84-a446-b10bbb45189a', 'A', null),
  ('c174b2bd-a3db-5a27-bc24-02af8b23f0bd', 'C', null),
  ('55aa15f5-7a5b-50dc-b894-f0a711dbaf07', 'E', null),
  ('51b7bfec-fba8-5c10-b3c2-3555e49540ef', 'D', null),
  ('ea55b07c-da11-5a8a-85d2-ecfc30730a6b', 'B', null),
  ('89e63b39-c136-5c3f-b479-44f28f2915cc', 'B', null),
  ('2dfa70eb-606b-5e70-8484-54a8c72137f4', 'E', null),
  ('979ac1ae-177f-59f6-bb44-85b0d8efc545', 'A', null),
  ('e3ec63e5-2a7d-5a4b-8969-0f1f1e92b970', 'A', null),
  ('402bf7a2-58a4-5e3e-a4b6-daf1d3ddc972', 'D', null),
  ('19a8b61b-3b0a-5cf1-a6e9-35e33659ff33', 'E', null),
  ('9f6a0e21-b3d7-5bbb-adac-fe13e99567c1', 'D', null),
  ('ec5b10fe-98dd-5917-b08f-74213ba47923', 'A', null),
  ('1f2f2408-a60f-54b7-ad3f-59fc60b6bac8', 'B', null),
  ('ea1d65b4-3798-57b5-b1a0-eed629a6c07c', 'C', null),
  ('86e59dfc-78af-5564-bf23-473ca27a7f8e', 'D', null),
  ('85a1ddfc-3d36-59b0-9249-cd5704fbf609', 'B', null),
  ('c70ff41b-6515-51cd-ad57-90b54374c637', 'C', null)
on conflict (questao_id) do nothing;

update public.questoes set status = 'PUBLICADA'
 where id in ('cef13b07-c329-5453-96bc-770582e7eca5', 'c433a3c9-e02d-56ca-81aa-4ca0b83ba065', '69796919-322d-565b-82cd-a76c16f9d278', 'a74430e4-4512-5a5b-9735-217b280d35fc', 'af6a861f-7ad1-5163-ba3e-dbceeba3a496', '9edea88f-3206-5cdc-bc48-2551271cad5f', '6aa20def-8e25-5570-9cd3-12f390e3cd36', '412ba6be-0dff-5a75-870f-a425d12b12fe', '049e249f-4cd8-5242-b2b5-1b8c645f9302', '9a9c3f25-12c1-5e2a-945f-505c88436b45', '99d16d90-20c1-577f-a937-bd808b582de7', '860267d7-9af8-56f6-901a-b0476303b978', 'eac03f9c-42ed-5fcd-ae64-1173905f114f', 'd5a1a31e-01d7-5aac-a647-7c5da23ca543', '5e26a161-21f5-5b0d-881a-323e232206af', '22d8085c-2c51-529a-901b-ce5ca08b40fb', '328b9d17-f813-5b85-a424-a715cd80ec58', 'c9de0e09-db95-5c9e-9c7d-b8ff80e75ede', '59e430a7-d747-5ab0-a013-666528de9388', '114cf68e-db11-534d-ae33-f0b400915e79', '30d1dcf5-fc71-58cb-8b44-17bb4af5704a', '8b5c94ba-801b-58b9-b3dd-57f2ad7759f8', '1bcfab70-6a28-5904-9141-433e4b74ff10', 'a9824830-d85f-5363-9982-2e55f7a69c74', '1e3132a8-8d6d-50e2-9269-c82f89302b22', '74edfa3d-af1d-562d-ac8d-396bdce649fe', 'c0e4923e-f5b5-5540-8a31-6d1f2e1ccb21', '80adb5c1-21fc-5daa-83d8-77369fef93c3', '335d8ab6-03e6-5f21-8352-3aca66d9b896', '79ae22b0-91f4-5f26-941c-37483c1812b0', '05e5138c-206f-5680-a1e6-d946b81668de', '3f070f23-313e-5a77-922a-1e1e016e554d', 'ee1940ce-69f8-5e31-af1a-427af041361d', '50c098f2-615b-5e20-ab98-69d008934644', '3abee0af-eecc-5bff-bb1c-1c3c9609c747', '692c6a0c-f132-5daa-a0aa-4e146f7749f3', '1f594c6f-6f13-52c9-b689-38f0e2fe7260', 'a5ec299f-3494-5fed-a874-b3a78316ec64', '0aaad1cb-885d-515b-950b-16a07a43db3e', '3a6e76b8-904f-5d2a-b78a-dbb5a52cf2af', '64f65282-cbf5-598a-bbab-602f2cab0be3', 'cdaeedc9-5035-51eb-b607-6c9d1bb8dd9c', 'a4109639-0e8a-52ab-baf2-7b15e9a3d132', '46fd179b-afda-51c7-858c-0f6a0961f23a', 'c5b19d4e-06b5-5ca7-9d15-d074c342eab2', '3690a022-f681-5592-91d4-b888b85bf463', 'd9e4cf15-722a-5030-a164-df9ee94e7005', 'c26ee4c6-d3cd-5aa0-9a07-df026ac538aa', '0a532afa-51e1-5b29-8ded-1676feb23b9e', '5405c6c6-89a2-5a23-a5a5-1c867ce49279', 'cb94fb32-324a-56e8-9a6e-728d8ed19114', '4b88acfa-c441-539e-a77b-d9bf0ef8b627', '7800ecde-961a-588e-9b7d-724d686c3a5d', '5d76fd36-1e58-5b52-81ae-90fd7e2700ef', '31019a37-328a-515d-bfd3-bbb9fb615c14', '15b21d87-441c-54c1-b6f6-d5b750ca066f', '21f81a66-e35f-50c4-8d6b-14f2b5fb1e7d', 'a3e0c507-2aee-5abd-8657-b1e19c629fdc', 'ebf7a95e-59c0-55dc-a916-3104e7d8b8ef', 'fd2e2acf-57c5-5699-a73d-fc35b6bb239f', '398d1a4e-64c5-5785-a27a-bf278bfacfaf', '4e3697e9-6608-564c-9c8d-e90fbac309c2', 'fde79f87-57b8-51b2-93f8-ebfc227f7fab', '0afe0fcc-c805-5596-bcaa-ae6ece0cf82a', '84661ed6-af14-5262-ae32-b55e5bf200f4', 'daceab06-17c0-581b-bbcd-dd5b71c070ee', 'cfadec24-b416-5be4-adeb-47fc05b52236', '8fc8ed6e-a127-5e89-8aa2-6a1fec3eefeb', '51d86b62-83b9-521c-976e-d92a55446106', '3da5aabd-9461-54ad-a263-613265b27315', '689eb746-0e4c-5001-be86-ed27a0b537b4', 'd782eb86-a38e-5273-bc23-6e36444bc011', '97762bde-ec43-5a75-b6a2-60084f7b6fd0', 'f41f49e5-4161-5305-9ba1-7f9ac9398338', '23451b55-fe4d-546b-aa04-b5c153abd8a0', '2075435d-d928-5990-bafb-647a9d498171', '80c1c033-0cf1-54d0-908c-fe9801c17b0d', 'b0ef092c-aaf4-588d-9fc6-8bfb406d9aa8', '6636c9a0-b05f-5050-afd1-44a7b6daafc4', '01fc6691-038f-504e-8d7d-3232ec3b524a', 'f87fd59d-8f62-514c-847e-0a8dd00b3723', 'fbbcec2a-d3a5-592a-b2f8-f0f7238d44bd', '8ab6bc35-b972-5769-8633-35617f34b64d', 'a83d4f98-ab34-5798-b4eb-47974624fc1c', '184bfbb4-24a1-5382-ab6e-faa9bc3179e7', 'c0a3dff4-229f-586e-a40f-5e8ddabfdf6d', '3fdd3afb-4759-56ee-8913-d9a3e9afaac8', '9dd85e41-f184-5550-bbbf-d0f7e75a46ca', 'fea0ce34-c974-557e-bea8-5f83b72bd240', '20165afd-fcc1-59b4-bfd0-5ca2ae9f29f5', '84740262-503c-5fb8-8693-69739d1895e2', '371754ac-0642-547e-bceb-10a8df7c37c8', '40cdc04e-ebe2-5429-a2d3-2d926264bc8c', '3f368c08-94a8-56a8-af68-ed997afb384f', 'f4274832-b451-57f2-b9ee-f500ca900944', '58edc0fe-4af5-51ec-ac1a-6e73248a644f', '92c70bcf-0848-58ba-9156-32a380e169b2', '0bf21b2a-a8d3-51c1-a7d5-f2bc90ce191f', 'cc6eaa98-255d-53ba-930c-38fb8c730154', 'a08496d2-e1c1-53ea-ad74-2916c8bb47ef', '4c28ea9f-b6ea-586d-93c8-d14dcee07eaf', '3f3de941-29ea-5306-9d46-2b00a1bdf703', 'dade7e91-361a-5d1c-b7e6-d38a432a2825', 'f79972c8-f314-560f-b3c8-f345a0a02af7', 'f0228ba3-a6f0-5df2-bd26-b8c04abc0943', '1f7c87d9-a1d3-5376-8bd1-d621714aa93e', '502ddda6-36cd-581f-9dbc-5f099fd79849', '30ef90a9-3e72-5427-8cff-3e2b561d649c', '5581085f-ce21-5a59-8247-a401c90aaaf5', 'bb8d88de-7191-5649-ae80-f3ead52d333b', 'fb87cecf-ac34-549f-9132-ce319f5c4bac', '87362b70-75c4-50ed-ab83-16c3045ac91f', '55ccce18-0615-582e-a49c-765bb158b3b1', '5dcfa937-48ad-58fe-b708-cf282d113924', 'a626ab6d-0f82-59f5-9dd8-1dbe005a9929', '0faa56e2-7009-55c5-8548-db36f9346e57', '9b3817c1-dd37-5a9e-8d48-2b38f467e682', 'b5189b93-faeb-5da6-94f1-d7ed1a5f544e', '7d78ac2f-e070-5791-af9e-f04acdc0286e', 'a3b08535-7649-515e-a61c-497c7b3b7124', '41c7434d-ed82-57c0-805a-f3a0663085dc', '02f4b0f6-bc74-56a2-a0ca-c1f7678a961b', '5bb6bc29-5b7e-51a6-b658-b7dcdef736f0', '96e063a2-104c-5293-9b8f-272727fb1953', 'f05a8435-dfd6-520b-aa7c-f2abc8fadc07', '05187aeb-283f-5bfa-9da9-c78916adc7e9', '147bd849-ae72-5c84-a446-b10bbb45189a', 'c174b2bd-a3db-5a27-bc24-02af8b23f0bd', '55aa15f5-7a5b-50dc-b894-f0a711dbaf07', '51b7bfec-fba8-5c10-b3c2-3555e49540ef', 'ea55b07c-da11-5a8a-85d2-ecfc30730a6b', '89e63b39-c136-5c3f-b479-44f28f2915cc', '2dfa70eb-606b-5e70-8484-54a8c72137f4', '979ac1ae-177f-59f6-bb44-85b0d8efc545', 'e3ec63e5-2a7d-5a4b-8969-0f1f1e92b970', '402bf7a2-58a4-5e3e-a4b6-daf1d3ddc972', '19a8b61b-3b0a-5cf1-a6e9-35e33659ff33', '9f6a0e21-b3d7-5bbb-adac-fe13e99567c1', 'ec5b10fe-98dd-5917-b08f-74213ba47923', '1f2f2408-a60f-54b7-ad3f-59fc60b6bac8', 'ea1d65b4-3798-57b5-b1a0-eed629a6c07c', '86e59dfc-78af-5564-bf23-473ca27a7f8e', '85a1ddfc-3d36-59b0-9249-cd5704fbf609', 'c70ff41b-6515-51cd-ad57-90b54374c637') and status = 'RASCUNHO';

insert into public.sessoes (id, tipo, titulo, curso, inicio, fim, duracao_minutos, questoes, publicada, pontos_atividade)
values
  ('fe0f69be-cfff-5b40-a8eb-7d68ede329c0', 'SIMULADO', 'ENADE 2019 — Engenharia Mecânica (prova completa)', 'ENG_MEC', '2026-11-16 00:00:00-03', '2026-12-18 23:59:59-03', 240,
   array['cef13b07-c329-5453-96bc-770582e7eca5', 'c433a3c9-e02d-56ca-81aa-4ca0b83ba065', '69796919-322d-565b-82cd-a76c16f9d278', 'a74430e4-4512-5a5b-9735-217b280d35fc', 'af6a861f-7ad1-5163-ba3e-dbceeba3a496', '9edea88f-3206-5cdc-bc48-2551271cad5f', '6aa20def-8e25-5570-9cd3-12f390e3cd36', '412ba6be-0dff-5a75-870f-a425d12b12fe', '049e249f-4cd8-5242-b2b5-1b8c645f9302', '9a9c3f25-12c1-5e2a-945f-505c88436b45', '99d16d90-20c1-577f-a937-bd808b582de7', '860267d7-9af8-56f6-901a-b0476303b978', 'eac03f9c-42ed-5fcd-ae64-1173905f114f', 'd5a1a31e-01d7-5aac-a647-7c5da23ca543', '5e26a161-21f5-5b0d-881a-323e232206af', '22d8085c-2c51-529a-901b-ce5ca08b40fb', '328b9d17-f813-5b85-a424-a715cd80ec58', 'c9de0e09-db95-5c9e-9c7d-b8ff80e75ede', '59e430a7-d747-5ab0-a013-666528de9388', '114cf68e-db11-534d-ae33-f0b400915e79', '30d1dcf5-fc71-58cb-8b44-17bb4af5704a', '8b5c94ba-801b-58b9-b3dd-57f2ad7759f8', '1bcfab70-6a28-5904-9141-433e4b74ff10', 'a9824830-d85f-5363-9982-2e55f7a69c74', '1e3132a8-8d6d-50e2-9269-c82f89302b22', '74edfa3d-af1d-562d-ac8d-396bdce649fe', 'c0e4923e-f5b5-5540-8a31-6d1f2e1ccb21', '80adb5c1-21fc-5daa-83d8-77369fef93c3', '335d8ab6-03e6-5f21-8352-3aca66d9b896', '79ae22b0-91f4-5f26-941c-37483c1812b0', '05e5138c-206f-5680-a1e6-d946b81668de', '3f070f23-313e-5a77-922a-1e1e016e554d', 'ee1940ce-69f8-5e31-af1a-427af041361d', '50c098f2-615b-5e20-ab98-69d008934644', '3abee0af-eecc-5bff-bb1c-1c3c9609c747']::uuid[], false, 0),
  ('5ec5d029-c232-5139-9af9-426ea146af72', 'SIMULADO', 'ENADE 2019 — Engenharia de Produção (prova completa)', 'ENG_PROD', '2026-11-16 00:00:00-03', '2026-12-18 23:59:59-03', 240,
   array['cef13b07-c329-5453-96bc-770582e7eca5', 'c433a3c9-e02d-56ca-81aa-4ca0b83ba065', '69796919-322d-565b-82cd-a76c16f9d278', 'a74430e4-4512-5a5b-9735-217b280d35fc', 'af6a861f-7ad1-5163-ba3e-dbceeba3a496', '9edea88f-3206-5cdc-bc48-2551271cad5f', '6aa20def-8e25-5570-9cd3-12f390e3cd36', '412ba6be-0dff-5a75-870f-a425d12b12fe', '049e249f-4cd8-5242-b2b5-1b8c645f9302', '692c6a0c-f132-5daa-a0aa-4e146f7749f3', '1f594c6f-6f13-52c9-b689-38f0e2fe7260', 'a5ec299f-3494-5fed-a874-b3a78316ec64', '0aaad1cb-885d-515b-950b-16a07a43db3e', '3a6e76b8-904f-5d2a-b78a-dbb5a52cf2af', '64f65282-cbf5-598a-bbab-602f2cab0be3', 'cdaeedc9-5035-51eb-b607-6c9d1bb8dd9c', 'a4109639-0e8a-52ab-baf2-7b15e9a3d132', '46fd179b-afda-51c7-858c-0f6a0961f23a', 'c5b19d4e-06b5-5ca7-9d15-d074c342eab2', '3690a022-f681-5592-91d4-b888b85bf463', 'd9e4cf15-722a-5030-a164-df9ee94e7005', 'c26ee4c6-d3cd-5aa0-9a07-df026ac538aa', '0a532afa-51e1-5b29-8ded-1676feb23b9e', '5405c6c6-89a2-5a23-a5a5-1c867ce49279', 'cb94fb32-324a-56e8-9a6e-728d8ed19114', '4b88acfa-c441-539e-a77b-d9bf0ef8b627', '7800ecde-961a-588e-9b7d-724d686c3a5d', '5d76fd36-1e58-5b52-81ae-90fd7e2700ef', '31019a37-328a-515d-bfd3-bbb9fb615c14', '15b21d87-441c-54c1-b6f6-d5b750ca066f', '21f81a66-e35f-50c4-8d6b-14f2b5fb1e7d', 'a3e0c507-2aee-5abd-8657-b1e19c629fdc', 'ebf7a95e-59c0-55dc-a916-3104e7d8b8ef', 'fd2e2acf-57c5-5699-a73d-fc35b6bb239f', '398d1a4e-64c5-5785-a27a-bf278bfacfaf', '4e3697e9-6608-564c-9c8d-e90fbac309c2', 'fde79f87-57b8-51b2-93f8-ebfc227f7fab', '0afe0fcc-c805-5596-bcaa-ae6ece0cf82a', '84661ed6-af14-5262-ae32-b55e5bf200f4']::uuid[], false, 0),
  ('2b2c3d7a-489c-5d30-9775-9f65a9615513', 'SIMULADO', 'ENADE 2021 — Análise e Desenvolvimento de Sistemas (prova completa)', 'ADS', '2026-11-16 00:00:00-03', '2026-12-18 23:59:59-03', 240,
   array['daceab06-17c0-581b-bbcd-dd5b71c070ee', 'cfadec24-b416-5be4-adeb-47fc05b52236', '8fc8ed6e-a127-5e89-8aa2-6a1fec3eefeb', '51d86b62-83b9-521c-976e-d92a55446106', '3da5aabd-9461-54ad-a263-613265b27315', '689eb746-0e4c-5001-be86-ed27a0b537b4', 'd782eb86-a38e-5273-bc23-6e36444bc011', '97762bde-ec43-5a75-b6a2-60084f7b6fd0', 'f41f49e5-4161-5305-9ba1-7f9ac9398338', '23451b55-fe4d-546b-aa04-b5c153abd8a0', '2075435d-d928-5990-bafb-647a9d498171', '80c1c033-0cf1-54d0-908c-fe9801c17b0d', 'b0ef092c-aaf4-588d-9fc6-8bfb406d9aa8', '6636c9a0-b05f-5050-afd1-44a7b6daafc4', '01fc6691-038f-504e-8d7d-3232ec3b524a', 'f87fd59d-8f62-514c-847e-0a8dd00b3723', 'fbbcec2a-d3a5-592a-b2f8-f0f7238d44bd', '8ab6bc35-b972-5769-8633-35617f34b64d', 'a83d4f98-ab34-5798-b4eb-47974624fc1c', '184bfbb4-24a1-5382-ab6e-faa9bc3179e7', 'c0a3dff4-229f-586e-a40f-5e8ddabfdf6d', '3fdd3afb-4759-56ee-8913-d9a3e9afaac8', '9dd85e41-f184-5550-bbbf-d0f7e75a46ca', 'fea0ce34-c974-557e-bea8-5f83b72bd240', '20165afd-fcc1-59b4-bfd0-5ca2ae9f29f5', '84740262-503c-5fb8-8693-69739d1895e2', '371754ac-0642-547e-bceb-10a8df7c37c8', '40cdc04e-ebe2-5429-a2d3-2d926264bc8c', '3f368c08-94a8-56a8-af68-ed997afb384f', 'f4274832-b451-57f2-b9ee-f500ca900944', '58edc0fe-4af5-51ec-ac1a-6e73248a644f', '92c70bcf-0848-58ba-9156-32a380e169b2', '0bf21b2a-a8d3-51c1-a7d5-f2bc90ce191f', 'cc6eaa98-255d-53ba-930c-38fb8c730154', 'a08496d2-e1c1-53ea-ad74-2916c8bb47ef', '4c28ea9f-b6ea-586d-93c8-d14dcee07eaf', '3f3de941-29ea-5306-9d46-2b00a1bdf703', 'dade7e91-361a-5d1c-b7e6-d38a432a2825', 'f79972c8-f314-560f-b3c8-f345a0a02af7', 'f0228ba3-a6f0-5df2-bd26-b8c04abc0943']::uuid[], false, 0),
  ('8add8b6c-e81a-5bce-b054-d541c6fb0da6', 'SIMULADO', 'ENADE 2017 — Análise e Desenvolvimento de Sistemas (prova completa)', 'ADS', '2026-11-16 00:00:00-03', '2026-12-18 23:59:59-03', 240,
   array['1f7c87d9-a1d3-5376-8bd1-d621714aa93e', '502ddda6-36cd-581f-9dbc-5f099fd79849', '30ef90a9-3e72-5427-8cff-3e2b561d649c', '5581085f-ce21-5a59-8247-a401c90aaaf5', 'bb8d88de-7191-5649-ae80-f3ead52d333b', 'fb87cecf-ac34-549f-9132-ce319f5c4bac', '87362b70-75c4-50ed-ab83-16c3045ac91f', '55ccce18-0615-582e-a49c-765bb158b3b1', '5dcfa937-48ad-58fe-b708-cf282d113924', 'a626ab6d-0f82-59f5-9dd8-1dbe005a9929', '0faa56e2-7009-55c5-8548-db36f9346e57', '9b3817c1-dd37-5a9e-8d48-2b38f467e682', 'b5189b93-faeb-5da6-94f1-d7ed1a5f544e', '7d78ac2f-e070-5791-af9e-f04acdc0286e', 'a3b08535-7649-515e-a61c-497c7b3b7124', '41c7434d-ed82-57c0-805a-f3a0663085dc', '02f4b0f6-bc74-56a2-a0ca-c1f7678a961b', '5bb6bc29-5b7e-51a6-b658-b7dcdef736f0', '96e063a2-104c-5293-9b8f-272727fb1953', 'f05a8435-dfd6-520b-aa7c-f2abc8fadc07', '05187aeb-283f-5bfa-9da9-c78916adc7e9', '147bd849-ae72-5c84-a446-b10bbb45189a', 'c174b2bd-a3db-5a27-bc24-02af8b23f0bd', '55aa15f5-7a5b-50dc-b894-f0a711dbaf07', '51b7bfec-fba8-5c10-b3c2-3555e49540ef', 'ea55b07c-da11-5a8a-85d2-ecfc30730a6b', '89e63b39-c136-5c3f-b479-44f28f2915cc', '2dfa70eb-606b-5e70-8484-54a8c72137f4', '979ac1ae-177f-59f6-bb44-85b0d8efc545', 'e3ec63e5-2a7d-5a4b-8969-0f1f1e92b970', '402bf7a2-58a4-5e3e-a4b6-daf1d3ddc972', '19a8b61b-3b0a-5cf1-a6e9-35e33659ff33', '9f6a0e21-b3d7-5bbb-adac-fe13e99567c1', 'ec5b10fe-98dd-5917-b08f-74213ba47923', '1f2f2408-a60f-54b7-ad3f-59fc60b6bac8', 'ea1d65b4-3798-57b5-b1a0-eed629a6c07c', '86e59dfc-78af-5564-bf23-473ca27a7f8e', '85a1ddfc-3d36-59b0-9249-cd5704fbf609', 'c70ff41b-6515-51cd-ad57-90b54374c637']::uuid[], false, 0)
on conflict (id) do nothing;
