import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/avaliacao_leitura.dart';
import 'package:le_comigo/core/normalizacao.dart';
import 'package:le_comigo/core/resultado_vosk.dart';

const _certa = StatusPalavra.certa;
const _trocada = StatusPalavra.trocada;
const _pulada = StatusPalavra.pulada;
const _naoLida = StatusPalavra.naoLida;

/// Avalia com os textos já tokenizados, como o controller faz.
AvaliacaoLeitura avaliar(
  String esperado,
  String reconhecido, {
  Duration tempo = const Duration(seconds: 60),
}) => avaliarLeitura(
  esperadas: tokenizar(esperado),
  reconhecidas: tokenizar(reconhecido),
  tempo: tempo,
);

void main() {
  group('alinhamento', () {
    test('leitura perfeita: todas certas', () {
      final a = avaliar('O gato da Lia', 'o gato da lia');
      expect(a.status, [_certa, _certa, _certa, _certa]);
      expect(a.acrescentadas, 0);
    });

    test('palavra falada diferente vira troca', () {
      final a = avaliar('O gato da Lia', 'o rato da lia');
      expect(a.status, [_certa, _trocada, _certa, _certa]);
    });

    test('palavra que faltou no meio vira pulada', () {
      final a = avaliar('O gato da Lia', 'o gato lia');
      expect(a.status, [_certa, _certa, _pulada, _certa]);
    });

    test('palavra a mais conta como acrescentada', () {
      final a = avaliar('O gato da Lia', 'o gato gato da lia');
      expect(a.status, [_certa, _certa, _certa, _certa]);
      expect(a.acrescentadas, 1);
    });

    test('o que vem depois de onde parou é não lida, não erro', () {
      final a = avaliar('O gato da Lia dorme no sofá', 'o gato da');
      expect(a.status, [
        _certa,
        _certa,
        _certa,
        _naoLida,
        _naoLida,
        _naoLida,
        _naoLida,
      ]);
    });

    test('ignora acentos e pontuação ao comparar', () {
      final a = avaliar('Você já viu?', 'voce ja viu');
      expect(a.status, [_certa, _certa, _certa]);
    });

    test('última palavra lida errada é troca, não acrescentada', () {
      final a = avaliar('O gato da Lia', 'o gato rua');
      expect(a.status, [_certa, _certa, _trocada, _naoLida]);
      expect(a.acrescentadas, 0);
    });

    test('repetir a palavra anterior é acrescentada, não troca', () {
      final a = avaliar('O gato da Lia', 'o gato gato');
      expect(a.status, [_certa, _certa, _naoLida, _naoLida]);
      expect(a.acrescentadas, 1);
    });

    test('[unk] nunca vale como acerto', () {
      final a = avaliar('O gato da Lia', 'o gato [unk] lia');
      expect(a.status, [_certa, _certa, _trocada, _certa]);
    });

    test('nada reconhecido: tudo não lido', () {
      final a = avaliar('O gato', '');
      expect(a.status, [_naoLida, _naoLida]);
      expect(a.acrescentadas, 0);
    });
  });

  group('métricas', () {
    test('conta certas, trocadas, puladas e não lidas', () {
      // o(certa) rato(trocada) [da pulada] lia(certa) dorme(certa) | no sofá não lidas
      final a = avaliar('O gato da Lia dorme no sofá', 'o rato lia dorme');
      expect(a.certas, 3);
      expect(a.trocadas, 1);
      expect(a.puladas, 1);
      expect(a.naoLidas, 2);
    });

    test('PCPM: palavras certas por minuto de leitura', () {
      final a = avaliar(
        'O gato da Lia dorme no sofá',
        'o gato da lia dorme no',
        tempo: const Duration(seconds: 30),
      );
      expect(a.pcpm, closeTo(12, 0.001)); // 6 certas em meio minuto
    });

    test('precisão considera só o trecho lido', () {
      final a = avaliar('O gato da Lia dorme no sofá', 'o rato da lia');
      expect(
        a.precisao,
        closeTo(0.75, 0.001),
      ); // 3 de 4; "dorme no sofá" não conta
    });

    test('sem nada lido: PCPM zero e precisão nula', () {
      final a = avaliar('O gato', '', tempo: Duration.zero);
      expect(a.pcpm, 0);
      expect(a.precisao, isNull);
    });

    test('estrelas pela precisão: 3 (>=95%), 2 (>=80%), 1 (abaixo)', () {
      expect(avaliar('a b c d e', 'a b c d e').estrelas, 3);
      expect(avaliar('a b c d e', 'a b c d x').estrelas, 2); // 80%
      expect(avaliar('a b c d e', 'a x y d e').estrelas, 1); // 60%
      expect(avaliar('a b', '').estrelas, 0);
    });
  });

  group('tempo de leitura', () {
    PalavraReconhecida p(String palavra, double inicio, double fim) =>
        PalavraReconhecida(palavra: palavra, inicio: inicio, fim: fim);

    test('usa o fim da última palavra reconhecida', () {
      final t = tempoDeLeitura(
        finais: [p('o', 0.5, 0.7), p('gato', 0.8, 1.6)],
        decorrido: const Duration(seconds: 60),
      );
      expect(t, const Duration(milliseconds: 1600));
    });

    test('sem palavras com tempo, usa o cronômetro', () {
      final t = tempoDeLeitura(
        finais: const [],
        decorrido: const Duration(seconds: 12),
      );
      expect(t, const Duration(seconds: 12));
    });

    test('se sobrou fala sem tempo (parcial), usa o cronômetro', () {
      final t = tempoDeLeitura(
        finais: [p('o', 0.5, 0.7)],
        decorrido: const Duration(seconds: 12),
        sobrouParcial: true,
      );
      expect(t, const Duration(seconds: 12));
    });

    test('nunca passa do cronômetro', () {
      final t = tempoDeLeitura(
        finais: [p('o', 0.5, 70)],
        decorrido: const Duration(seconds: 60),
      );
      expect(t, const Duration(seconds: 60));
    });
  });
}
