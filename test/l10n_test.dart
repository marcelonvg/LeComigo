import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/l10n/app_localizations.dart';
import 'package:le_comigo/screens/leitura/widgets/painel_fim.dart';

import 'apoio.dart';

Set<String> _chaves(String arquivo) => (jsonDecode(
  File('lib/l10n/$arquivo').readAsStringSync(),
) as Map<String, dynamic>).keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  test('en e es têm exatamente as chaves do pt', () {
    final pt = _chaves('app_pt.arb');
    expect(_chaves('app_en.arb'), pt);
    expect(_chaves('app_es.arb'), pt);
  });

  test('ano escolar em cada idioma', () {
    final pt = lookupAppLocalizations(const Locale('pt'));
    final en = lookupAppLocalizations(const Locale('en'));
    final es = lookupAppLocalizations(const Locale('es'));
    expect(
      [for (var a = 1; a <= 5; a++) en.anoNumero('$a')],
      ['1st', '2nd', '3rd', '4th', '5th'],
    );
    expect(en.anoCompleto('2'), '2nd grade');
    expect(pt.anoCompleto('2'), '2º ano');
    expect(es.anoCompleto('2'), '2.º grado');
  });

  test('plural de palavras', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.palavras(1), '1 word');
    expect(en.palavras(30), '30 words');
  });

  for (final (locale, concluida, estrelas) in [
    (const Locale('pt'), 'Leitura concluída!', '2 de 3 estrelas'),
    (const Locale('en'), 'Reading complete!', '2 of 3 stars'),
    (const Locale('es'), '¡Lectura terminada!', '2 de 3 estrellas'),
  ]) {
    testWidgets('painel do fim em ${locale.languageCode}', (tester) async {
      await tester.pumpWidget(
        appTeste(
          Scaffold(
            body: PainelFim(
              ouviu: true,
              estrelas: 2,
              aoLerDeNovo: () {},
              aoVerDetalhes: () {},
            ),
          ),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(concluida), findsOneWidget);
      expect(find.bySemanticsLabel(estrelas), findsOneWidget);
    });
  }
}
