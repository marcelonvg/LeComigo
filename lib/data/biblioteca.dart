/// Textos de leitura que vêm com o app, por ano escolar (1º ao 5º).
///
/// Textos originais. Regras garantidas por test/biblioteca_test.dart:
/// toda palavra existe no vocabulário do Vosk, ids únicos, 3 textos por ano
/// e tamanho dentro da faixa do ano.
class TextoBiblioteca {
  const TextoBiblioteca({
    required this.id,
    required this.ano,
    required this.titulo,
    required this.conteudo,
  });

  /// Estável: o histórico de leituras vai guardar só ele.
  /// Não mude o id de um texto já publicado.
  final String id;

  /// Ano escolar, de 1 a 5.
  final int ano;
  final String titulo;
  final String conteudo;
}

/// Textos do [ano], na ordem da [biblioteca].
List<TextoBiblioteca> textosDoAno(int ano) => [
  for (final t in biblioteca)
    if (t.ano == ano) t,
];

const biblioteca = <TextoBiblioteca>[
  // 1º ano
  TextoBiblioteca(
    id: '1-gato-curioso',
    ano: 1,
    titulo: 'O gato curioso',
    conteudo:
        'O gato da Lia dorme no sofá. Quando chove, ele pula na '
        'janela e olha as gotas caindo. Você já viu um gato tão '
        'curioso?',
  ),
  TextoBiblioteca(
    id: '1-bola-azul',
    ano: 1,
    titulo: 'A bola azul',
    conteudo:
        'Davi tem uma bola azul. Ele joga a bola para o pai. O pai '
        'chuta a bola de volta. A bola rola, rola e cai no lago. Que '
        'pena! Agora a bola está molhada, e Davi ri muito.',
  ),
  TextoBiblioteca(
    id: '1-sapo-do-rio',
    ano: 1,
    titulo: 'O sapo do rio',
    conteudo:
        'O sapo mora perto do rio. De manhã, ele pula na pedra e toma '
        'sol. Quando vê uma mosca, o sapo abre a boca bem rápido. '
        'Pronto! O almoço do sapo acabou.',
  ),
  // 2º ano
  TextoBiblioteca(
    id: '2-bolo-da-vovo',
    ano: 2,
    titulo: 'O bolo da vovó',
    conteudo:
        'No domingo, a vovó Rosa fez um bolo de cenoura. A casa ficou '
        'com um cheiro gostoso. — Posso ajudar? — perguntou Pedro. — '
        'Pode, sim! Pegue o açúcar e a farinha — disse a vovó. Pedro '
        'mexeu a massa com cuidado. Quando o bolo saiu do forno, '
        'todos comeram um pedaço e pediram mais.',
  ),
  TextoBiblioteca(
    id: '2-pipa-colorida',
    ano: 2,
    titulo: 'A pipa colorida',
    conteudo:
        'Ana e o irmão fizeram uma pipa com papel colorido e varetas. '
        'No fim da tarde, foram para o campo. O vento estava forte. A '
        'pipa subiu, subiu e ficou bem pequena lá no céu. — Parece um '
        'passarinho! — gritou Ana. Os dois ficaram olhando até o sol '
        'ir embora.',
  ),
  TextoBiblioteca(
    id: '2-cachorro-perdido',
    ano: 2,
    titulo: 'O cachorro perdido',
    conteudo:
        'Na saída da escola, Júlia viu um cachorro sozinho na '
        'calçada. Ele estava com fome e com medo. Júlia deu um pedaço '
        'do seu pão e fez carinho na cabeça dele. Na coleira, havia '
        'um nome: Pipoca. Logo, uma moça apareceu correndo. Era a '
        'dona! Pipoca abanou o rabo de alegria.',
  ),
  // 3º ano
  TextoBiblioteca(
    id: '3-horta-da-escola',
    ano: 3,
    titulo: 'A horta da escola',
    conteudo:
        'A turma do terceiro ano resolveu plantar uma horta no pátio '
        'da escola. Cada criança trouxe uma semente de casa: alface, '
        'tomate, cenoura e até girassol. A professora mostrou como '
        'abrir pequenos buracos na terra e cobrir as sementes com '
        'cuidado.\n\n'
        'Todos os dias, alguém ficava responsável por regar os '
        'canteiros. No começo, nada acontecia. Depois de uma semana, '
        'apareceram os primeiros brotos verdes. Foi uma festa! No fim '
        'do mês, a turma colheu as alfaces e preparou uma salada para '
        'o lanche.',
  ),
  TextoBiblioteca(
    id: '3-dia-de-chuva',
    ano: 3,
    titulo: 'Dia de chuva',
    conteudo:
        'Era sábado, e Lucas queria jogar futebol na praça. Mas, logo '
        'cedo, o céu ficou escuro e começou a chover forte. Ele olhou '
        'pela janela, triste, vendo as poças crescerem na rua.\n\n'
        'A mãe teve uma ideia: montar uma cabana na sala com lençóis '
        'e almofadas. Lucas chamou a irmã, pegaram uma lanterna e '
        'alguns livros. Dentro da cabana, leram histórias de piratas '
        'e de dragões. Quando a chuva parou, Lucas nem lembrava mais '
        'do futebol. Aquele tinha sido o melhor sábado do ano.',
  ),
  TextoBiblioteca(
    id: '3-tartaruga-apressada',
    ano: 3,
    titulo: 'A tartaruga apressada',
    conteudo:
        'Na beira do lago morava uma tartaruga chamada Tina. Ela '
        'vivia dizendo que estava atrasada para tudo. Corria para o '
        'almoço, corria para o banho, corria até para dormir.\n\n'
        'Um dia, um caranguejo perguntou: — Tina, por que você tem '
        'tanta pressa? Ela parou e pensou. Não sabia responder! Então '
        'resolveu fazer diferente. Andou devagar pela areia, sentiu o '
        'vento no casco e viu as nuvens mudando de forma. Descobriu '
        'que, sem pressa, o caminho também podia ser divertido.',
  ),
  // 4º ano
  TextoBiblioteca(
    id: '4-festa-junina',
    ano: 4,
    titulo: 'A festa junina',
    conteudo:
        'Em junho, a escola de Mariana se enche de bandeirinhas '
        'coloridas. Os alunos ensaiam a quadrilha durante semanas, e '
        'cada turma prepara uma barraca com comidas típicas. Este '
        'ano, a turma dela ficou com a barraca de pamonha e milho '
        'cozido.\n\n'
        'No dia da festa, Mariana usou um vestido de chita e fez '
        'pintas no rosto. Seu par na quadrilha era o Rafael, que '
        'tropeçou logo no primeiro passo. Todo mundo riu, inclusive '
        'ele. Depois da dança, as famílias se reuniram em volta da '
        'fogueira para comer pipoca e pé de moleque. No final da '
        'noite, houve até um correio elegante, e Mariana recebeu um '
        'bilhete misterioso que dizia apenas: "Você dança muito bem!"',
  ),
  TextoBiblioteca(
    id: '4-mapa-do-tesouro',
    ano: 4,
    titulo: 'O mapa do tesouro',
    conteudo:
        'Arrumando o quarto do avô, Bia e Theo encontraram uma caixa '
        'de madeira empoeirada. Dentro dela havia um papel amarelado '
        'com desenhos estranhos: uma árvore, uma pedra grande e um X '
        'vermelho. — É um mapa do tesouro! — gritou Theo.\n\n'
        'Os dois saíram pelo quintal seguindo as pistas. Encontraram '
        'a velha mangueira e, ao lado dela, a pedra do desenho. '
        'Contaram dez passos para o norte e começaram a cavar. Depois '
        'de muito esforço, a pá bateu em algo duro. Era uma lata '
        'enferrujada! Lá dentro estavam bolinhas de gude, figurinhas '
        'antigas e uma foto do avô quando era criança. O avô sorriu '
        'ao ver a lata: — Eu escondi isso há cinquenta anos!',
  ),
  TextoBiblioteca(
    id: '4-viagem-ao-litoral',
    ano: 4,
    titulo: 'Viagem ao litoral',
    conteudo:
        'Nas férias de verão, a família de Gabriel viajou de ônibus '
        'para o litoral. Ele nunca tinha visto o mar e passou a '
        'viagem inteira imaginando como seria. Quando finalmente '
        'chegaram, Gabriel ficou parado na areia, de boca aberta. O '
        'mar era enorme, muito maior do que ele tinha pensado.\n\n'
        'Nos dias seguintes, ele aprendeu a pular as ondas, construiu '
        'castelos de areia e recolheu conchas de todos os tamanhos. '
        'Também conheceu um pescador que contou histórias sobre '
        'peixes gigantes e tempestades no oceano. Na volta para casa, '
        'Gabriel levou um pote cheio de conchas e uma certeza: queria '
        'ser biólogo marinho quando crescesse.',
  ),
  // 5º ano
  TextoBiblioteca(
    id: '5-floresta-que-respira',
    ano: 5,
    titulo: 'A floresta que respira',
    conteudo:
        'A Floresta Amazônica é a maior floresta tropical do mundo. '
        'Ela se espalha por vários países da América do Sul, mas a '
        'maior parte fica no Brasil. Lá vivem milhares de espécies de '
        'plantas e animais, muitas delas ainda desconhecidas pelos '
        'cientistas.\n\n'
        'As árvores da floresta funcionam como gigantescas bombas de '
        'água. Elas retiram a umidade do solo pelas raízes e a '
        'liberam no ar pelas folhas. Esse vapor forma nuvens que '
        'viajam por longas distâncias e levam chuva para outras '
        'regiões do país. Por isso, dizem que existem verdadeiros '
        'rios voadores sobre a Amazônia.\n\n'
        'Quando a floresta é derrubada ou queimada, esse ciclo se '
        'enfraquece. Proteger a Amazônia, portanto, não é importante '
        'apenas para quem vive perto dela. É uma forma de cuidar da '
        'água, do clima e da vida de todos nós.',
  ),
  TextoBiblioteca(
    id: '5-campeonato-do-bairro',
    ano: 5,
    titulo: 'O campeonato do bairro',
    conteudo:
        'Todo ano, o bairro organizava um campeonato de futebol entre '
        'as ruas. A equipe da Rua das Flores nunca tinha passado da '
        'primeira fase, e muitos já diziam que ela perderia de novo. '
        'Joana, a capitã, não concordava. Durante as férias, ela '
        'convenceu os amigos a treinarem todas as tardes no campo de '
        'terra.\n\n'
        'No começo, os treinos eram uma bagunça. Ninguém passava a '
        'bola e todos queriam fazer gol. Aos poucos, porém, o time '
        'percebeu que jogar junto era mais importante do que brilhar '
        'sozinho. Cada um descobriu a posição em que se sentia '
        'melhor.\n\n'
        'No dia da final, a arquibancada estava lotada. O jogo '
        'terminou empatado, e a decisão foi para os pênaltis. Joana '
        'bateu o último e acertou o canto. A Rua das Flores, '
        'finalmente, era campeã!',
  ),
  TextoBiblioteca(
    id: '5-pequena-inventora',
    ano: 5,
    titulo: 'A pequena inventora',
    conteudo:
        'Desde pequena, Helena adorava desmontar objetos para '
        'entender como funcionavam. Rádios velhos, relógios quebrados '
        'e até uma bicicleta antiga já tinham passado pela sua mesa '
        'de trabalho, que ficava num canto da garagem.\n\n'
        'Certa vez, a professora de ciências propôs um desafio: cada '
        'aluno deveria criar uma invenção para resolver um problema '
        'da escola. Helena pensou no bebedouro do pátio, que vivia '
        'vazando e desperdiçando água. Com canos, uma boia de '
        'plástico e muita paciência, ela construiu um sistema que '
        'fechava a torneira sozinho quando a garrafa estava cheia.\n\n'
        'Na feira de ciências, a invenção chamou a atenção de todos. '
        'O diretor gostou tanto que pediu para instalar o sistema em '
        'todos os bebedouros. Helena ficou orgulhosa, mas o que mais '
        'a deixou feliz foi saber que a escola economizaria muita '
        'água.',
  ),
];
