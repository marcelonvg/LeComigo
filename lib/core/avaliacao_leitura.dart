// Avaliação da fluência ao fim da leitura. Dart puro.
import 'dart:math';

import 'resultado_vosk.dart';

/// O que aconteceu com cada palavra do texto.
enum StatusPalavra {
  certa,

  /// A criança falou outra coisa no lugar.
  trocada,

  /// Faltou, no meio do trecho que a criança leu.
  pulada,

  /// Depois do ponto em que a criança parou: não conta como erro.
  naoLida,
}

/// Resultado de uma leitura: um [status] por palavra esperada e as métricas.
class AvaliacaoLeitura {
  const AvaliacaoLeitura({
    required this.status,
    required this.acrescentadas,
    required this.tempo,
  });

  final List<StatusPalavra> status;

  /// Palavras reconhecidas que não correspondem a nenhuma do texto.
  final int acrescentadas;

  /// Tempo de leitura usado no cálculo da PCPM.
  final Duration tempo;

  int _contar(StatusPalavra s) => status.where((x) => x == s).length;

  int get certas => _contar(StatusPalavra.certa);
  int get trocadas => _contar(StatusPalavra.trocada);
  int get puladas => _contar(StatusPalavra.pulada);
  int get naoLidas => _contar(StatusPalavra.naoLida);

  /// Palavras do trecho que a criança percorreu.
  int get tentadas => certas + trocadas + puladas;

  /// Palavras corretas por minuto.
  double get pcpm {
    final segundos = tempo.inMilliseconds / 1000;
    return segundos <= 0 ? 0 : certas * 60 / segundos;
  }

  /// Certas ÷ tentadas (0 a 1). Null se a criança não leu nada.
  double? get precisao => tentadas == 0 ? null : certas / tentadas;

  /// 0 (não leu) a 3, pela precisão. É o que a criança vê.
  int get estrelas {
    final p = precisao;
    if (p == null) return 0;
    if (p >= 0.95) return 3;
    if (p >= 0.8) return 2;
    return 1;
  }
}

/// Alinha o texto esperado com o que o Vosk reconheceu (distância de edição)
/// e classifica cada palavra esperada.
///
/// As duas listas devem vir normalizadas por `tokenizar`. O "[unk]" do Vosk
/// vira "unk" e nunca conta como acerto.
///
/// A criança raramente termina o texto: o fim do alinhamento é livre do
/// lado do texto, então o que vem depois do ponto de parada é [StatusPalavra.naoLida].
AvaliacaoLeitura avaliarLeitura({
  required List<String> esperadas,
  required List<String> reconhecidas,
  required Duration tempo,
}) {
  final n = esperadas.length;
  final m = reconhecidas.length;

  // custo[i][j]: alinhar as i primeiras reconhecidas com as j primeiras esperadas.
  final custo = List.generate(m + 1, (_) => List<double>.filled(n + 1, 0));
  // Custo de acrescentar a i-ésima reconhecida (não depende do texto).
  double acrescentar(int i) =>
      i >= 2 && reconhecidas[i - 1] == reconhecidas[i - 2]
      ? _custoRepetir
      : _custoAcrescentar;

  for (var i = 1; i <= m; i++) {
    custo[i][0] = custo[i - 1][0] + acrescentar(i);
  }
  for (var j = 1; j <= n; j++) {
    custo[0][j] = j.toDouble();
  }
  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      custo[i][j] = min(
        custo[i - 1][j - 1] +
            _custoTroca(reconhecidas[i - 1], esperadas[j - 1]),
        min(custo[i][j - 1] + 1, custo[i - 1][j] + acrescentar(i)),
      );
    }
  }

  // Ponto de parada: a coluna mais barata na última linha (empate: a mais longe).
  var fim = 0;
  for (var j = 1; j <= n; j++) {
    if (custo[m][j] <= custo[m][fim] + _eps) fim = j;
  }

  final status = List<StatusPalavra>.filled(n, StatusPalavra.naoLida);
  var acrescentadas = 0;
  var i = m, j = fim;
  while (i > 0 || j > 0) {
    if (i > 0 && j > 0) {
      final troca = _custoTroca(reconhecidas[i - 1], esperadas[j - 1]);
      if ((custo[i][j] - (custo[i - 1][j - 1] + troca)).abs() < _eps) {
        status[j - 1] = troca == 0
            ? StatusPalavra.certa
            : StatusPalavra.trocada;
        i--;
        j--;
        continue;
      }
    }
    if (j > 0 &&
        (i == 0 || (custo[i][j] - (custo[i][j - 1] + 1)).abs() < _eps)) {
      status[j - 1] = StatusPalavra.pulada;
      j--;
    } else {
      acrescentadas++;
      i--;
    }
  }

  return AvaliacaoLeitura(
    status: status,
    acrescentadas: acrescentadas,
    tempo: tempo,
  );
}

const _eps = 1e-9;

// Custos: pular = 1. Os desvios de 1 só desempatam alinhamentos de mesmo
// número de erros, sem nunca trocar um erro por dois:
// - acrescentar (1,02) custa mais que trocar (1 a 1,01): se a última palavra
//   lida está errada, é troca, não "acrescentou e parou antes";
// - trocar custa menos entre palavras parecidas: "o rato lia" contra
//   "o gato da lia" é gato→rato e "da" pulada, não o contrário.
const _custoAcrescentar = 1.02;

/// Repetir a palavra que acabou de falar ("o gato gato") é comum e não é
/// erro de leitura: custa menos que qualquer troca.
const _custoRepetir = 0.5;

/// 0 se é a mesma palavra; entre 1 e 1,01 se não, menor quanto mais parecidas.
double _custoTroca(String reconhecida, String esperada) {
  if (reconhecida == esperada && reconhecida != 'unk') return 0;
  if (reconhecida == 'unk') return 1.01;
  return 1 + 0.01 * (1 - _similaridade(reconhecida, esperada));
}

/// 1 = iguais, 0 = nada em comum (distância de edição por letras).
double _similaridade(String a, String b) {
  var anterior = List<int>.generate(b.length + 1, (k) => k);
  for (var x = 1; x <= a.length; x++) {
    final atual = List<int>.filled(b.length + 1, 0)..[0] = x;
    for (var y = 1; y <= b.length; y++) {
      atual[y] = min(
        anterior[y - 1] + (a[x - 1] == b[y - 1] ? 0 : 1),
        min(anterior[y] + 1, atual[y - 1] + 1),
      );
    }
    anterior = atual;
  }
  final maior = max(a.length, b.length);
  return maior == 0 ? 1 : 1 - anterior[b.length] / maior;
}

/// Tempo de leitura para a PCPM: o fim da última palavra reconhecida, para
/// que o silêncio depois da leitura (esqueceu de tocar em "Terminei") não
/// conte. Sem esse dado, ou se sobrou fala sem tempo ([sobrouParcial]),
/// usa o cronômetro. Nunca passa de [decorrido].
Duration tempoDeLeitura({
  required List<PalavraReconhecida> finais,
  required Duration decorrido,
  bool sobrouParcial = false,
}) {
  if (finais.isEmpty || sobrouParcial) return decorrido;
  final fim = Duration(milliseconds: (finais.last.fim * 1000).round());
  return fim < decorrido ? fim : decorrido;
}
