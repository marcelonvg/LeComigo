// Leitura dos JSONs que o Vosk devolve. Dart puro: sem dependência de Flutter.
import 'dart:convert';

/// Uma palavra reconhecida, com tempos em segundos desde o início da gravação.
class PalavraReconhecida {
  final String palavra;
  final double inicio;
  final double fim;
  final double confianca;

  const PalavraReconhecida({
    required this.palavra,
    required this.inicio,
    required this.fim,
    this.confianca = 1.0,
  });

  @override
  String toString() =>
      '$palavra (${inicio.toStringAsFixed(2)}–${fim.toStringAsFixed(2)} s)';
}

/// Resultado parcial: {"partial": "o menino"} → "o menino".
String lerParcial(String json) {
  final mapa = jsonDecode(json) as Map<String, dynamic>;
  return (mapa['partial'] as String?) ?? '';
}

/// Resultado final com setWords(true):
/// {"result": [{"word": "o", "start": 0.6, "end": 0.8, "conf": 1.0}, ...], "text": "o ..."}
/// Quando há só silêncio, o Vosk manda {"text": ""} e a lista volta vazia.
List<PalavraReconhecida> lerResultado(String json) {
  final mapa = jsonDecode(json) as Map<String, dynamic>;
  final lista = (mapa['result'] as List<dynamic>?) ?? const [];
  return lista.map((item) {
    final p = item as Map<String, dynamic>;
    return PalavraReconhecida(
      palavra: p['word'] as String,
      inicio: (p['start'] as num).toDouble(),
      fim: (p['end'] as num).toDouble(),
      confianca: (p['conf'] as num?)?.toDouble() ?? 1.0,
    );
  }).toList();
}
