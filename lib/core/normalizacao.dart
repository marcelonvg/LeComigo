// Normalização de texto para comparar o que era esperado com o que foi reconhecido.
// Dart puro: sem dependência de Flutter.

const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
const _semAcento = 'aaaaaeeeeiiiiooooouuuucn';

/// Troca letras acentuadas pela versão sem acento ("Você" → "voce" após minúsculas).
String removerAcentos(String texto) {
  final saida = StringBuffer();
  for (final letra in texto.split('')) {
    final i = _comAcento.indexOf(letra);
    saida.write(i >= 0 ? _semAcento[i] : letra);
  }
  return saida.toString();
}

/// Minúsculas, pontuação vira espaço, separa por espaços.
/// Com [manterAcentos] = false (padrão), também remove os acentos.
List<String> tokenizar(String texto, {bool manterAcentos = false}) {
  var t = texto.toLowerCase();
  if (!manterAcentos) t = removerAcentos(t);
  // Mantém só letras (com ou sem acento) e dígitos; o resto vira separador.
  t = t.replaceAll(RegExp('[^a-z0-9$_comAcento]+'), ' ');
  return t.split(' ').where((p) => p.isNotEmpty).toList();
}

/// Lista de palavras para a grammar do Vosk: palavras únicas do texto + "[unk]".
///
/// Os acentos são MANTIDOS aqui de propósito: o vocabulário do modelo
/// pt-BR tem as palavras acentuadas ("você", "não"). Sem acento, o Vosk
/// descartaria a palavra da grammar. A remoção de acentos acontece só
/// na hora de comparar (alinhamento).
List<String> palavrasDaGramatica(String texto) {
  final unicas = tokenizar(texto, manterAcentos: true).toSet().toList();
  return [...unicas, '[unk]'];
}
