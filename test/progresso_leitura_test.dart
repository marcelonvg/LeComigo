import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/normalizacao.dart';
import 'package:le_comigo/core/progresso_leitura.dart';

void main() {
  final esperadas = tokenizar('O gato da Lia dorme no sofá. O gato pula.');

  test('leitura em ordem avança palavra a palavra', () {
    expect(palavrasAlcancadas(esperadas, tokenizar('o gato da lia')), 4);
  });

  test('palavra pulada conta como alcançada', () {
    expect(palavrasAlcancadas(esperadas, tokenizar('o gato lia')), 4);
  });

  test('troca ou [unk] não avança', () {
    expect(palavrasAlcancadas(esperadas, tokenizar('o [unk] cachorro')), 1);
  });

  test('palavra repetida no texto não faz pular para longe', () {
    // "gato" aparece duas vezes; deve casar com a primeira.
    expect(palavrasAlcancadas(esperadas, tokenizar('o gato')), 2);
  });

  test('nunca passa do fim do texto', () {
    expect(
      palavrasAlcancadas(esperadas, [...esperadas, 'gato', 'pula']),
      esperadas.length,
    );
  });
}
