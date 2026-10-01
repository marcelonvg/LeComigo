import '../core/idioma.dart';
import 'biblioteca_en.dart';
import 'biblioteca_es.dart';
import 'biblioteca_pt.dart';

/// Textos de leitura que vêm com o app, por idioma e ano escolar (1º ao 5º).
///
/// Textos originais. Regras garantidas por test/biblioteca_test.dart:
/// toda palavra existe no vocabulário do modelo Vosk do idioma, ids únicos,
/// 3 textos por ano em cada idioma e tamanho dentro da faixa do ano.
class TextoBiblioteca {
  const TextoBiblioteca({
    required this.id,
    required this.idioma,
    required this.ano,
    required this.titulo,
    required this.conteudo,
  });

  /// Estável: o histórico de leituras vai guardar só ele.
  /// Não mude o id de um texto já publicado.
  final String id;
  final Idioma idioma;

  /// Ano escolar, de 1 a 5.
  final int ano;
  final String titulo;
  final String conteudo;
}

const biblioteca = <TextoBiblioteca>[
  ...bibliotecaPt,
  ...bibliotecaEn,
  ...bibliotecaEs,
];

/// Textos do [idioma] e do [ano], na ordem da [biblioteca].
List<TextoBiblioteca> textosDoAno(Idioma idioma, int ano) => [
  for (final t in biblioteca)
    if (t.idioma == idioma && t.ano == ano) t,
];
