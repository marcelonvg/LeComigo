import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/idioma.dart';
import 'package:le_comigo/core/normalizacao.dart';
import 'package:le_comigo/data/biblioteca.dart';

/// Caminho do Gr.fst dentro de cada zip (o pt usa o layout antigo, sem graph/).
const _grFst = {
  Idioma.pt: 'vosk-model-small-pt-0.3/Gr.fst',
  Idioma.en: 'vosk-model-small-en-us-0.15/graph/Gr.fst',
  Idioma.es: 'vosk-model-small-es-0.42/graph/Gr.fst',
};

// Palavras que provam que o leitor achou a tabela certa de cada modelo.
const _tipicas = {
  Idioma.pt: ['gato', 'você'],
  Idioma.en: ['cat', "don't"],
  Idioma.es: ['gato', 'está'],
};

/// Vocabulário do modelo Vosk do [idioma], lido da tabela de símbolos
/// embutida no Gr.fst.
///
/// Formato (SymbolTable do OpenFst, little-endian), logo depois do nome
/// ".../words.txt": int64 próxima chave, int64 tamanho e, para cada símbolo,
/// int32 tamanho + bytes UTF-8 + int64 chave.
Set<String> lerVocabularioVosk(Idioma idioma) {
  final zip = ZipDecoder().decodeBytes(File(idioma.modelo).readAsBytesSync());
  final fst = Uint8List.fromList(
    zip.findFile(_grFst[idioma]!)!.content as List<int>,
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
  for (final idioma in Idioma.values) {
    group('vocabulário do Vosk (${idioma.codigo})', () {
      late Set<String> vocabulario;
      setUpAll(() => vocabulario = lerVocabularioVosk(idioma));

      test('a leitura do modelo traz o vocabulário inteiro', () {
        expect(vocabulario.length, greaterThan(90000));
        expect(vocabulario, containsAll(['[unk]', ..._tipicas[idioma]!]));
      });

      test('toda palavra de todo texto existe no modelo', () {
        final faltando = [
          for (final t in biblioteca.where((t) => t.idioma == idioma))
            for (final p in palavrasDaGramatica(t.conteudo))
              if (!vocabulario.contains(p)) '${t.id}: $p',
        ];
        expect(faltando, isEmpty);
      });
    });
  }

  test('ids únicos no conjunto todo', () {
    final ids = biblioteca.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('ids novos levam o prefixo do idioma; os de pt não mudam', () {
    for (final t in biblioteca) {
      if (t.idioma == Idioma.pt) {
        expect(t.id, matches(RegExp(r'^[1-5]-')), reason: t.id);
      } else {
        expect(t.id, startsWith('${t.idioma.codigo}-${t.ano}-'), reason: t.id);
      }
    }
  });

  test('3 textos por ano, do 1º ao 5º, em cada idioma', () {
    expect(biblioteca.length, 45);
    for (final idioma in Idioma.values) {
      for (var ano = 1; ano <= 5; ano++) {
        final textos = textosDoAno(idioma, ano);
        expect(textos.length, 3, reason: '${idioma.codigo} $anoº ano');
        expect(textos.every((t) => t.ano == ano && t.idioma == idioma), isTrue);
      }
    }
  });

  test('o gato curioso continua no 1º ano em português', () {
    expect(textosDoAno(Idioma.pt, 1).first.id, '1-gato-curioso');
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

  test('apóstrofo tipográfico não desalinha os trechos', () {
    const conteudo = 'Lia’s cat doesn’t sleep.';
    final porTrecho = [
      for (final trecho in conteudo.split(RegExp(r'\s+'))) ...tokenizar(trecho),
    ];
    expect(porTrecho, tokenizar(conteudo));
    expect(porTrecho, ["lia's", 'cat', "doesn't", 'sleep']);
  });
}
