import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/normalizacao.dart';
import 'package:le_comigo/core/resultado_vosk.dart';

void main() {
  test('tokenizar remove acentos, pontuação e maiúsculas', () {
    expect(tokenizar('Você já viu? O GATO, pulou!'), [
      'voce',
      'ja',
      'viu',
      'o',
      'gato',
      'pulou',
    ]);
  });

  test('grammar mantém acentos, não repete palavras e inclui [unk]', () {
    expect(palavrasDaGramatica('O gato e o cão. Você?'), [
      'o',
      'gato',
      'e',
      'cão',
      'você',
      '[unk]',
    ]);
  });

  test('lê resultado final do Vosk com tempos', () {
    final palavras = lerResultado(
      '{"result":[{"conf":1.0,"end":0.9,"start":0.6,"word":"o"},'
      '{"conf":0.8,"end":1.5,"start":0.9,"word":"gato"}],"text":"o gato"}',
    );
    expect(palavras.map((p) => p.palavra), ['o', 'gato']);
    expect(palavras[1].inicio, 0.9);
    expect(lerResultado('{"text":""}'), isEmpty);
    expect(lerParcial('{"partial":"o ga"}'), 'o ga');
  });

  test('apóstrofo dentro da palavra fica (como no modelo em inglês)', () {
    expect(tokenizar("Don't stop, it's Lia's cat!"), [
      "don't",
      'stop',
      "it's",
      "lia's",
      'cat',
    ]);
  });

  test('apóstrofo tipográfico vira o apóstrofo reto', () {
    expect(tokenizar('Don’t'), ["don't"]);
    expect(palavrasDaGramatica('It’s'), ["it's", '[unk]']);
  });

  test('apóstrofo nas pontas ou sozinho é separador', () {
    expect(tokenizar("'Hello' ' world'"), ['hello', 'world']);
  });

  test('espanhol: ¿ e ¡ separam; ñ perde o til só na comparação', () {
    expect(tokenizar('¿Qué año? ¡Niño!'), ['que', 'ano', 'nino']);
    expect(palavrasDaGramatica('¿Qué año? ¡Niño!'), [
      'qué',
      'año',
      'niño',
      '[unk]',
    ]);
  });
}
