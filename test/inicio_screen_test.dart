import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/idioma.dart';
import 'package:le_comigo/data/biblioteca.dart';
import 'package:le_comigo/screens/biblioteca/biblioteca_screen.dart';
import 'package:le_comigo/screens/inicio/inicio_screen.dart';
import 'package:le_comigo/services/idioma_controller.dart';
import 'package:le_comigo/services/vosk_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'apoio.dart';

/// Vosk de mentira: anota os pedidos; pode segurar ou falhar o carregamento.
class _VoskFalso extends VoskService {
  final pedidos = <Idioma>[];
  bool falhar = false;
  Completer<void>? segurar;

  @override
  Future<void> carregarModelo(Idioma idioma) async {
    pedidos.add(idioma);
    if (segurar != null) await segurar!.future;
    if (falhar) throw Exception('modelo não carregou');
  }
}

void usarCelular(
  WidgetTester tester, {
  double largura = 360,
  double altura = 800,
}) {
  tester.view.physicalSize = Size(largura * 3, altura * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  late _VoskFalso vosk;
  late IdiomaController idioma;

  Future<void> abrir(
    WidgetTester tester, {
    String salvo = 'pt',
    double escalaFonte = 1,
  }) async {
    SharedPreferences.setMockInitialValues({IdiomaController.chave: salvo});
    idioma = await IdiomaController.carregar();
    vosk = _VoskFalso();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<VoskService>.value(value: vosk),
          ChangeNotifierProvider<IdiomaController>.value(value: idioma),
        ],
        child: Consumer<IdiomaController>(
          builder: (context, c, _) => appTeste(
            const InicioScreen(),
            locale: Locale(c.atual.codigo),
            builder: (context, filho) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(escalaFonte)),
              child: filho!,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('abre no idioma salvo, com ele marcado', (tester) async {
    usarCelular(tester);
    final semantica = tester.ensureSemantics();
    await abrir(tester, salvo: 'es');
    expect(find.text('Elige el idioma'), findsOneWidget);
    for (final i in Idioma.values) {
      expect(
        tester.getSemantics(find.bySemanticsLabel(i.nome)),
        matchesSemantics(
          label: i.nome,
          isButton: true,
          hasSelectedState: true,
          isSelected: i == Idioma.es,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
        reason: i.nome,
      );
    }
    semantica.dispose();
  });

  testWidgets('tocar numa bandeira traduz a tela na hora e salva', (
    tester,
  ) async {
    usarCelular(tester);
    await abrir(tester);
    expect(find.text('Escolha o idioma'), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('ENTER'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(IdiomaController.chave), 'en');
    expect(vosk.pedidos, isEmpty); // o modelo só carrega em "Entrar"
  });

  testWidgets('Entrar carrega o modelo e abre a biblioteca', (tester) async {
    usarCelular(tester);
    await abrir(tester);
    await tester.tap(find.text('ENTRAR'));
    await tester.pumpAndSettle();
    expect(vosk.pedidos, [Idioma.pt]);
    expect(find.byType(BibliotecaScreen), findsOneWidget);
    expect(find.byType(InicioScreen), findsNothing);
  });

  testWidgets('outro idioma: mostra carregando, trava a escolha e entra '
      'na biblioteca daquele idioma', (tester) async {
    usarCelular(tester);
    await abrir(tester);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    vosk.segurar = Completer<void>();
    await tester.tap(find.text('ENTER'));
    await tester.pump();
    expect(find.text('LOADING...'), findsOneWidget);
    await tester.tap(find.text('Español'));
    await tester.pump();
    expect(idioma.atual, Idioma.en);
    vosk.segurar!.complete();
    await tester.pumpAndSettle();
    expect(vosk.pedidos, [Idioma.en]);
    expect(find.text(textosDoAno(Idioma.en, 1).first.titulo), findsOneWidget);
  });

  testWidgets('toque duplo em Entrar carrega e navega uma vez só', (
    tester,
  ) async {
    usarCelular(tester);
    await abrir(tester);
    vosk.segurar = Completer<void>();
    await tester.tap(find.text('ENTRAR'));
    await tester.tap(find.text('ENTRAR'), warnIfMissed: false);
    vosk.segurar!.complete();
    await tester.pumpAndSettle();
    expect(vosk.pedidos, [Idioma.pt]);
    expect(find.byType(BibliotecaScreen), findsOneWidget);
  });

  testWidgets('falha ao carregar: mostra o erro e deixa tentar de novo', (
    tester,
  ) async {
    usarCelular(tester);
    await abrir(tester);
    vosk.falhar = true;
    await tester.tap(find.text('ENTRAR'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Não foi possível preparar o reconhecimento de voz. Tente de novo.',
      ),
      findsOneWidget,
    );
    expect(find.byType(InicioScreen), findsOneWidget);
    // Ainda dá para trocar de idioma depois da falha.
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(idioma.atual, Idioma.es);
    vosk.falhar = false;
    await tester.tap(find.text('ENTRAR'));
    await tester.pumpAndSettle();
    expect(find.byType(BibliotecaScreen), findsOneWidget);
  });

  testWidgets('cabe em celular pequeno com fonte aumentada nos 3 idiomas', (
    tester,
  ) async {
    usarCelular(tester, largura: 320, altura: 640);
    await abrir(tester, escalaFonte: 1.3);
    for (final i in Idioma.values) {
      // Em tela pequena com fonte grande a lista pode precisar rolar.
      await tester.ensureVisible(find.text(i.nome, skipOffstage: false));
      await tester.pumpAndSettle();
      await tester.tap(find.text(i.nome));
      await tester.pumpAndSettle();
      expect(idioma.atual, i);
      expect(tester.takeException(), isNull, reason: i.nome);
    }
  });
}
