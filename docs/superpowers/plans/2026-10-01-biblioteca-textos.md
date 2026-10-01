# Biblioteca de textos — Plano de implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Trocar o texto único fixo por uma biblioteca de 15 textos originais (3 por ano, do 1º ao 5º), escolhidos pelo professor numa tela nova antes da leitura.

**Architecture:** Os textos ficam numa lista `const` em Dart (`lib/data/biblioteca.dart`), validada por testes, inclusive contra o vocabulário do modelo Vosk lido de dentro do zip. A nova `BibliotecaScreen` vira a primeira tela depois da splash e abre a `LeituraScreen`, que passa a receber um `TextoBiblioteca`. A lógica de leitura (`LeituraController`) não muda.

**Tech Stack:** Flutter/Dart, provider, flutter_test, `archive` (só nos testes, para abrir o zip do modelo).

**Spec:** `docs/superpowers/specs/2026-10-01-biblioteca-textos-design.md`

## Global Constraints

- Faixas de tamanho (palavras contadas por `tokenizar`): 1º 25–40 · 2º 45–65 · 3º 70–95 · 4º 100–125 · 5º 130–160.
- 3 textos por ano, 15 no total; ids únicos e estáveis (formato `<ano>-<slug>`); "O gato curioso" tem id `1-gato-curioso`.
- Toda palavra de `palavrasDaGramatica(conteudo)` existe no vocabulário de `assets/models/vosk-model-small-pt-0.3.zip`.
- A criança não vê a lista de textos; não há botão de voltar na tela de leitura (só o voltar do sistema).
- O ano escolhido fica só em memória (estado da tela).
- Cores e estilos só de `Cores`/`Estilos` (`lib/tema/`); textos de interface em português.
- O projeto **não é um repositório git**: no lugar de commit, cada tarefa termina com a suíte inteira verde (`flutter test`) e `flutter analyze` sem problemas.
- Comandos rodam na raiz `C:\Users\marcelo.souza\Desktop\LeComigo`.

## Review Focus

- Texto do 5º ano (o mais longo) num celular pequeno → a tela de leitura rola sem overflow. Teste na Tarefa 2.
- Fonte do sistema aumentada (130%) num celular de 320 pt de largura → chips e cartões da biblioteca sem overflow em todos os anos. Teste na Tarefa 3.
- Voltar da leitura para a biblioteca → continua no ano que o professor tinha escolhido. Teste na Tarefa 3.
- Travessões, aspas e pontuação colados nas palavras → o destaque por palavra (que divide o texto por espaços) continua alinhado com as palavras do alinhamento. Teste na Tarefa 1.
- Leitor do vocabulário quebrado (formato do `Gr.fst` diferente do esperado) → o teste falha com mensagem clara, em vez de aprovar com vocabulário vazio. Teste na Tarefa 1.

## Mapa de arquivos

| Arquivo | Ação | Responsabilidade |
|---|---|---|
| `lib/data/biblioteca.dart` | Criar | `TextoBiblioteca`, `biblioteca` (15 textos), `textosDoAno` |
| `test/biblioteca_test.dart` | Criar | Regras do conteúdo, incluindo vocabulário do Vosk |
| `pubspec.yaml` | Modificar | `archive` em `dev_dependencies` |
| `lib/screens/leitura/leitura_screen.dart` | Modificar | Recebe `TextoBiblioteca` |
| `test/leitura_screen_test.dart` | Criar | Título do texto e texto longo sem overflow |
| `lib/data/textos_exemplo.dart` | Remover | Substituído pela biblioteca |
| `lib/screens/biblioteca/biblioteca_screen.dart` | Criar | Seletor de ano + cartões; abre a leitura |
| `test/biblioteca_screen_test.dart` | Criar | Comportamento da tela da biblioteca |
| `lib/app.dart` | Modificar | Splash abre a biblioteca |

---

### Tarefa 1: Dados da biblioteca

**Files:**
- Create: `lib/data/biblioteca.dart`
- Create: `test/biblioteca_test.dart`
- Modify: `pubspec.yaml` (dev_dependencies)

**Interfaces:**
- Consumes: `tokenizar(String)` e `palavrasDaGramatica(String)` de `lib/core/normalizacao.dart` (já existem).
- Produces:
  - `class TextoBiblioteca { const TextoBiblioteca({required String id, required int ano, required String titulo, required String conteudo}); final String id; final int ano; final String titulo; final String conteudo; }`
  - `const List<TextoBiblioteca> biblioteca`
  - `List<TextoBiblioteca> textosDoAno(int ano)` — na ordem da lista.

- [ ] **Step 1: Adicionar `archive` como dependência de teste**

Run: `flutter pub add --dev "archive:^3.6.1"`
Expected: `pubspec.yaml` ganha `archive: ^3.6.1` em `dev_dependencies` (a 3.6.1 já está no `pubspec.lock` como transitiva; a 4.x tem outra API).

- [ ] **Step 2: Escrever o teste (falhando)**

Criar `test/biblioteca_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/normalizacao.dart';
import 'package:le_comigo/data/biblioteca.dart';

/// Vocabulário do modelo Vosk, lido da tabela de símbolos embutida no Gr.fst.
///
/// Formato (SymbolTable do OpenFst, little-endian), logo depois do nome
/// ".../words.txt": int64 próxima chave, int64 tamanho e, para cada símbolo,
/// int32 tamanho + bytes UTF-8 + int64 chave.
Set<String> lerVocabularioVosk() {
  final zip = ZipDecoder().decodeBytes(
    File('assets/models/vosk-model-small-pt-0.3.zip').readAsBytesSync(),
  );
  final fst = Uint8List.fromList(
    zip.findFile('vosk-model-small-pt-0.3/Gr.fst')!.content as List<int>,
  );
  final marca = utf8.encode('words.txt');
  final dados = ByteData.sublistView(fst);
  var i = _posicao(fst, marca) + marca.length + 8; // pula a próxima chave
  final tamanho = dados.getInt64(i, Endian.little);
  i += 8;
  final palavras = <String>{};
  for (var k = 0; k < tamanho; k++) {
    final n = dados.getInt32(i, Endian.little);
    i += 4;
    palavras.add(utf8.decode(fst.sublist(i, i + n)));
    i += n + 8; // bytes da palavra + chave
  }
  return palavras;
}

int _posicao(Uint8List dados, List<int> marca) {
  for (var i = 0; i <= dados.length - marca.length; i++) {
    var igual = true;
    for (var j = 0; j < marca.length && igual; j++) {
      igual = dados[i + j] == marca[j];
    }
    if (igual) return i;
  }
  throw StateError('Tabela de símbolos não encontrada no Gr.fst');
}

const _faixas = {
  1: (25, 40),
  2: (45, 65),
  3: (70, 95),
  4: (100, 125),
  5: (130, 160),
};

void main() {
  group('vocabulário do Vosk', () {
    late Set<String> vocabulario;
    setUpAll(() => vocabulario = lerVocabularioVosk());

    test('a leitura do modelo traz o vocabulário inteiro', () {
      expect(vocabulario.length, greaterThan(90000));
      expect(vocabulario, containsAll(['gato', 'você', '[unk]']));
    });

    test('toda palavra de todo texto existe no modelo', () {
      final faltando = [
        for (final t in biblioteca)
          for (final p in palavrasDaGramatica(t.conteudo))
            if (!vocabulario.contains(p)) '${t.id}: $p',
      ];
      expect(faltando, isEmpty);
    });
  });

  test('ids únicos', () {
    final ids = biblioteca.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('3 textos por ano, do 1º ao 5º', () {
    expect(biblioteca.length, 15);
    for (var ano = 1; ano <= 5; ano++) {
      expect(textosDoAno(ano).length, 3, reason: '$anoº ano');
      expect(textosDoAno(ano).every((t) => t.ano == ano), isTrue);
    }
  });

  test('o gato curioso continua no 1º ano', () {
    expect(textosDoAno(1).first.id, '1-gato-curioso');
  });

  test('tamanho de cada texto dentro da faixa do ano', () {
    final fora = [
      for (final t in biblioteca)
        if (tokenizar(t.conteudo).length < _faixas[t.ano]!.$1 ||
            tokenizar(t.conteudo).length > _faixas[t.ano]!.$2)
          '${t.id}: ${tokenizar(t.conteudo).length} palavras',
    ];
    expect(fora, isEmpty);
  });

  test('título e conteúdo preenchidos', () {
    for (final t in biblioteca) {
      expect(t.titulo.trim(), isNotEmpty, reason: t.id);
      expect(t.conteudo.trim(), isNotEmpty, reason: t.id);
    }
  });

  // O destaque ao vivo e o texto colorido dividem o texto por espaços e
  // contam as palavras de cada trecho; a soma tem que bater com o alinhamento.
  test('trechos separados por espaço somam as mesmas palavras', () {
    for (final t in biblioteca) {
      final porTrecho = [
        for (final trecho in t.conteudo.split(RegExp(r'\s+')))
          ...tokenizar(trecho),
      ];
      expect(porTrecho, tokenizar(t.conteudo), reason: t.id);
    }
  });
}
```

- [ ] **Step 3: Rodar e ver falhar**

Run: `flutter test test/biblioteca_test.dart`
Expected: FAIL na compilação — `Error when reading 'lib/data/biblioteca.dart'`.

- [ ] **Step 4: Implementar `lib/data/biblioteca.dart`**

```dart
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
```

- [ ] **Step 5: Rodar e ver passar**

Run: `flutter test test/biblioteca_test.dart`
Expected: PASS (8 testes). A leitura do zip leva alguns segundos.

- [ ] **Step 6: Checkpoint**

Run: `flutter test` e `flutter analyze`
Expected: todos os testes passam; `No issues found!`.

---

### Tarefa 2: Tela de leitura recebe um texto da biblioteca

**Files:**
- Modify: `lib/screens/leitura/leitura_screen.dart:22-36`
- Modify: `lib/app.dart`
- Delete: `lib/data/textos_exemplo.dart`
- Create: `test/leitura_screen_test.dart`

**Interfaces:**
- Consumes: `TextoBiblioteca`, `textosDoAno(int)` (Tarefa 1).
- Produces: `LeituraScreen({Key? key, required TextoBiblioteca texto})`, com o campo público `final TextoBiblioteca texto` (a Tarefa 3 lê `texto.id` nos testes).

- [ ] **Step 1: Escrever o teste (falhando)**

Criar `test/leitura_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/data/biblioteca.dart';
import 'package:le_comigo/screens/leitura/leitura_screen.dart';
import 'package:le_comigo/services/vosk_service.dart';
import 'package:provider/provider.dart';

/// Tela de celular comum: 360 x 800 pontos.
void usarCelular(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

// O VoskService real só toca no plugin ao começar a ouvir; nestes testes
// a leitura não começa, então ele pode ser usado sem o plugin nativo.
Widget _app(TextoBiblioteca texto) => Provider<VoskService>(
  create: (_) => VoskService(),
  child: MaterialApp(home: LeituraScreen(texto: texto)),
);

void main() {
  testWidgets('mostra o título do texto recebido', (tester) async {
    usarCelular(tester);
    final texto = textosDoAno(3)[1];
    await tester.pumpWidget(_app(texto));
    await tester.tap(find.text('Menino'));
    await tester.pump();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    expect(find.text(texto.titulo.toUpperCase()), findsOneWidget);
  });

  testWidgets('texto mais longo (5º ano) rola sem overflow', (tester) async {
    usarCelular(tester);
    final texto = textosDoAno(5).reduce(
      (a, b) => a.conteudo.length >= b.conteudo.length ? a : b,
    );
    await tester.pumpWidget(_app(texto));
    await tester.tap(find.text('Menina'));
    await tester.pump();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/leitura_screen_test.dart`
Expected: FAIL na compilação — `No named parameter with the name 'texto'` / tipo `TextoBiblioteca` incompatível com `String`.

- [ ] **Step 3: Implementar — `LeituraScreen` recebe `TextoBiblioteca`**

Em `lib/screens/leitura/leitura_screen.dart`, acrescentar o import (em ordem alfabética, antes de `../../services/vosk_service.dart`):

```dart
import '../../data/biblioteca.dart';
```

E trocar a classe `LeituraScreen` inteira (linhas 22–36) por:

```dart
class LeituraScreen extends StatelessWidget {
  const LeituraScreen({super.key, required this.texto});

  final TextoBiblioteca texto;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LeituraController(
        texto: texto.conteudo,
        vosk: context.read<VoskService>(),
      ),
      child: _LeituraView(titulo: texto.titulo),
    );
  }
}
```

- [ ] **Step 4: Ajustar `lib/app.dart` e remover o texto de exemplo**

`lib/app.dart` fica (por enquanto abre o primeiro texto do 1º ano; a Tarefa 3 troca pela biblioteca):

```dart
import 'package:flutter/material.dart';

import 'data/biblioteca.dart';
import 'screens/leitura/leitura_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'tema/tema_app.dart';

class LeComigoApp extends StatelessWidget {
  const LeComigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lê Comigo',
      debugShowCheckedModeBanner: false,
      theme: temaApp(),
      home: SplashScreen(
        proximaTela: (_) => LeituraScreen(texto: textosDoAno(1).first),
      ),
    );
  }
}
```

Run: `rm lib/data/textos_exemplo.dart`

- [ ] **Step 5: Rodar e ver passar**

Run: `flutter test test/leitura_screen_test.dart`
Expected: PASS (2 testes).

- [ ] **Step 6: Checkpoint**

Run: `flutter test` e `flutter analyze`
Expected: todos os testes passam; `No issues found!` (nenhuma referência sobrando a `textoDemonstracao`).

---

### Tarefa 3: Tela da biblioteca

**Files:**
- Create: `lib/screens/biblioteca/biblioteca_screen.dart`
- Create: `test/biblioteca_screen_test.dart`
- Modify: `lib/app.dart`

**Interfaces:**
- Consumes: `TextoBiblioteca`, `textosDoAno(int)` (Tarefa 1); `LeituraScreen({required TextoBiblioteca texto})` (Tarefa 2); `Sons.tocar(Som)` de `lib/services/sons.dart`; `tokenizar` de `lib/core/normalizacao.dart`.
- Produces: `BibliotecaScreen({Key? key})`. Os chips mostram o texto `'1º'` … `'5º'`; os cartões mostram o título exato do texto.

- [ ] **Step 1: Escrever o teste (falhando)**

Criar `test/biblioteca_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/data/biblioteca.dart';
import 'package:le_comigo/screens/biblioteca/biblioteca_screen.dart';
import 'package:le_comigo/screens/leitura/leitura_screen.dart';
import 'package:le_comigo/services/vosk_service.dart';
import 'package:provider/provider.dart';

/// Tela de celular: [largura] x [altura] pontos.
void usarCelular(WidgetTester tester, {double largura = 360, double altura = 800}) {
  tester.view.physicalSize = Size(largura * 3, altura * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> abrir(WidgetTester tester, {double escalaFonte = 1}) async {
  await tester.pumpWidget(
    Provider<VoskService>(
      create: (_) => VoskService(),
      child: MaterialApp(
        builder: (context, filho) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(escalaFonte),
          ),
          child: filho!,
        ),
        home: const BibliotecaScreen(),
      ),
    ),
  );
}

void esperarTitulosDoAno(int ano) {
  for (final t in textosDoAno(ano)) {
    expect(find.text(t.titulo), findsOneWidget, reason: t.id);
  }
}

void main() {
  testWidgets('abre mostrando os textos do 1º ano', (tester) async {
    usarCelular(tester);
    await abrir(tester);
    esperarTitulosDoAno(1);
    expect(find.text(textosDoAno(3).first.titulo), findsNothing);
  });

  testWidgets('o chip do 3º ano mostra os textos do 3º', (tester) async {
    usarCelular(tester);
    await abrir(tester);
    await tester.tap(find.text('3º'));
    await tester.pumpAndSettle();
    esperarTitulosDoAno(3);
    expect(find.text(textosDoAno(1).first.titulo), findsNothing);
  });

  testWidgets('tocar no cartão abre a leitura daquele texto', (tester) async {
    usarCelular(tester);
    await abrir(tester);
    await tester.tap(find.text('2º'));
    await tester.pumpAndSettle();
    final escolhido = textosDoAno(2)[1];
    await tester.tap(find.text(escolhido.titulo));
    await tester.pumpAndSettle();
    final tela = tester.widget<LeituraScreen>(find.byType(LeituraScreen));
    expect(tela.texto.id, escolhido.id);
  });

  testWidgets('voltar da leitura mantém o ano escolhido', (tester) async {
    usarCelular(tester);
    await abrir(tester);
    await tester.tap(find.text('4º'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(textosDoAno(4).first.titulo));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    esperarTitulosDoAno(4);
  });

  testWidgets('cabe em celular pequeno com fonte aumentada', (tester) async {
    usarCelular(tester, largura: 320, altura: 640);
    await abrir(tester, escalaFonte: 1.3);
    for (var ano = 1; ano <= 5; ano++) {
      await tester.tap(find.text('$anoº'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$anoº ano');
    }
  });
}
```

- [ ] **Step 2: Rodar e ver falhar**

Run: `flutter test test/biblioteca_screen_test.dart`
Expected: FAIL na compilação — `Error when reading 'lib/screens/biblioteca/biblioteca_screen.dart'`.

- [ ] **Step 3: Implementar `lib/screens/biblioteca/biblioteca_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/normalizacao.dart';
import '../../data/biblioteca.dart';
import '../../services/sons.dart';
import '../../tema/tema_app.dart';
import '../leitura/leitura_screen.dart';

/// Escolha do texto, feita pelo professor antes de entregar o aparelho
/// à criança: ano escolar no topo, textos do ano em cartões.
class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  /// Fica no estado da tela: ao voltar da leitura, continua o mesmo ano.
  int _ano = 1;

  void _abrir(TextoBiblioteca texto) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LeituraScreen(texto: texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
            children: [
              const Text('Escolha o texto', style: Estilos.tituloGrande),
              const SizedBox(height: 6),
              Text(
                'Para o professor: escolha e entregue o aparelho à criança.',
                style: Estilos.corpo.copyWith(color: Cores.textoSuave),
              ),
              const SizedBox(height: 24),
              _SeletorAno(
                ano: _ano,
                aoEscolher: (ano) => setState(() => _ano = ano),
              ),
              const SizedBox(height: 20),
              for (final texto in textosDoAno(_ano)) ...[
                _CartaoBiblioteca(texto: texto, aoTocar: () => _abrir(texto)),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Cinco chips (1º a 5º) no estilo 3D dos cartões de personagem.
class _SeletorAno extends StatelessWidget {
  const _SeletorAno({required this.ano, required this.aoEscolher});

  final int ano;
  final ValueChanged<int> aoEscolher;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var a = 1; a <= 5; a++) ...[
          if (a > 1) const SizedBox(width: 8),
          Expanded(
            child: _ChipAno(
              ano: a,
              selecionado: a == ano,
              aoTocar: () => aoEscolher(a),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChipAno extends StatelessWidget {
  const _ChipAno({
    required this.ano,
    required this.selecionado,
    required this.aoTocar,
  });

  final int ano;
  final bool selecionado;
  final VoidCallback aoTocar;

  static const _duracao = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? Cores.tealSombra : Cores.texto;
    return Semantics(
      button: true,
      selected: selecionado,
      label: '$anoº ano',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          Sons.tocar(Som.escolha);
          aoTocar();
        },
        child: AnimatedContainer(
          duration: _duracao,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selecionado ? Cores.tealClaro : Cores.fundo,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selecionado ? Cores.teal : Cores.borda,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: selecionado ? Cores.teal : Cores.borda,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text('$anoº', style: Estilos.destaque.copyWith(color: cor)),
              Text('ano', style: Estilos.pequeno.copyWith(color: cor)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão de um texto: título, começo do texto e número de palavras.
class _CartaoBiblioteca extends StatelessWidget {
  const _CartaoBiblioteca({required this.texto, required this.aoTocar});

  final TextoBiblioteca texto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final palavras = tokenizar(texto.conteudo).length;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Sons.tocar(Som.toque);
          aoTocar();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Cores.fundo,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Cores.borda, width: 2),
            boxShadow: const [
              BoxShadow(color: Cores.borda, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(texto.titulo, style: Estilos.destaque),
              const SizedBox(height: 6),
              Text(
                texto.conteudo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Estilos.corpo.copyWith(color: Cores.textoSuave),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 18,
                    color: Cores.teal,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$palavras palavras',
                      style: Estilos.pequeno
                          .comPeso(600)
                          .copyWith(color: Cores.tealSombra),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Cores.teal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Rodar e ver passar**

Run: `flutter test test/biblioteca_screen_test.dart`
Expected: PASS (5 testes). Se o teste de fonte aumentada acusar overflow nos chips, reduzir o `Estilos.destaque` do chip com `copyWith(fontSize: 18)` e rodar de novo; não remover o teste.

- [ ] **Step 5: Splash abre a biblioteca**

`lib/app.dart` fica:

```dart
import 'package:flutter/material.dart';

import 'screens/biblioteca/biblioteca_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'tema/tema_app.dart';

class LeComigoApp extends StatelessWidget {
  const LeComigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lê Comigo',
      debugShowCheckedModeBanner: false,
      theme: temaApp(),
      home: SplashScreen(proximaTela: (_) => const BibliotecaScreen()),
    );
  }
}
```

- [ ] **Step 6: Checkpoint completo**

Run: `dart format lib test` depois `flutter test` e `flutter analyze`
Expected: todos os testes passam (46 anteriores + 8 + 2 + 5 = 61); `No issues found!`.

- [ ] **Step 7: Conferir no aparelho**

Run: `flutter build apk --release` depois `flutter install -d 11211997A2824A0RXI --release`
Conferir no Infinix:
1. Depois da splash aparece "Escolha o texto" com o 1º ano selecionado.
2. Trocar de ano toca o "plim" e mostra os 3 textos do ano.
3. Abrir um texto do 5º ano: personagem → começar → o texto longo rola.
4. Voltar (gesto do Android) retorna à biblioteca no mesmo ano.
5. Ler um trecho de um texto do 3º ano em voz alta e conferir o destaque e o resultado.
