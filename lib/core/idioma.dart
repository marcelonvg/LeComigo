// Idiomas do app. Dart puro: o Locale do Flutter é montado a partir do código.

/// Idioma das telas e da leitura. Cada um traz o modelo Vosk que reconhece
/// a fala naquele idioma.
enum Idioma {
  pt(
    codigo: 'pt',
    nome: 'Português',
    bandeira: '🇧🇷',
    modelo: 'assets/models/vosk-model-small-pt-0.3.zip',
  ),
  en(
    codigo: 'en',
    nome: 'English',
    bandeira: '🇺🇸',
    modelo: 'assets/models/vosk-model-small-en-us-0.15.zip',
  ),
  es(
    codigo: 'es',
    nome: 'Español',
    bandeira: '🇪🇸',
    modelo: 'assets/models/vosk-model-small-es-0.42.zip',
  );

  const Idioma({
    required this.codigo,
    required this.nome,
    required this.bandeira,
    required this.modelo,
  });

  /// Código ISO 639-1 ("pt"), usado no Locale e no que fica salvo.
  final String codigo;

  /// Sempre no próprio idioma: quem não lê português acha o seu.
  final String nome;
  final String bandeira;

  /// Zip do modelo Vosk nos assets.
  final String modelo;

  /// O idioma com esse [codigo], ou null se não houver.
  static Idioma? doCodigo(String? codigo) {
    for (final idioma in values) {
      if (idioma.codigo == codigo) return idioma;
    }
    return null;
  }
}
