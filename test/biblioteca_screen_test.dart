import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/idioma.dart';
import 'package:le_comigo/data/biblioteca.dart';
import 'package:le_comigo/screens/biblioteca/biblioteca_screen.dart';
import 'package:le_comigo/screens/leitura/leitura_screen.dart';
import 'package:le_comigo/services/idioma_controller.dart';
import 'package:le_comigo/services/vosk_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tela de celular: [largura] x [altura] pontos.
void usarCelular(
  WidgetTester tester, {
  double largura = 360,
  double altura = 800,
}) {
  tester.view.physicalSize = Size(largura * 3, altura * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> abrir(WidgetTester tester, {double escalaFonte = 1}) async {
  SharedPreferences.setMockInitialValues({IdiomaController.chave: 'pt'});
  final idioma = await IdiomaController.carregar();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<VoskService>(create: (_) => VoskService()),
        ChangeNotifierProvider<IdiomaController>.value(value: idioma),
      ],
      child: MaterialApp(
        builder: (context, filho) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(escalaFonte)),
          child: filho!,
        ),
        home: const BibliotecaScreen(),
      ),
    ),
  );
}

void esperarTitulosDoAno(int ano) {
  for (final t in textosDoAno(Idioma.pt, ano)) {
    expect(find.text(t.titulo), findsOneWidget, reason: t.id);
  }
}

void main() {
  testWidgets('abre mostrando os textos do 1º ano', (tester) async {
    usarCelular(tester);
    await abrir(tester);
    esperarTitulosDoAno(1);
    expect(find.text(textosDoAno(Idioma.pt, 3).first.titulo), findsNothing);
  });

  testWidgets('o chip do 3º ano mostra os textos do 3º', (tester) async {
    usarCelular(tester);
    await abrir(tester);
    await tester.tap(find.text('3º'));
    await tester.pumpAndSettle();
    esperarTitulosDoAno(3);
    expect(find.text(textosDoAno(Idioma.pt, 1).first.titulo), findsNothing);
  });

  testWidgets('só o ano escolhido fica selecionado', (tester) async {
    usarCelular(tester);
    final semantica = tester.ensureSemantics();
    await abrir(tester);
    await tester.tap(find.text('2º'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3º'));
    await tester.pumpAndSettle();
    for (var ano = 1; ano <= 5; ano++) {
      expect(
        tester.getSemantics(find.bySemanticsLabel('$anoº ano')),
        matchesSemantics(
          label: '$anoº ano',
          isButton: true,
          hasSelectedState: true,
          isSelected: ano == 3,
          hasTapAction: true,
        ),
        reason: '$anoº ano',
      );
    }
    semantica.dispose();
  });

  testWidgets('tocar no cartão abre a leitura daquele texto', (tester) async {
    usarCelular(tester);
    await abrir(tester);
    await tester.tap(find.text('2º'));
    await tester.pumpAndSettle();
    final escolhido = textosDoAno(Idioma.pt, 2)[1];
    await tester.tap(find.text(escolhido.titulo));
    await tester.pumpAndSettle();
    final tela = tester.widget<LeituraScreen>(find.byType(LeituraScreen));
    expect(tela.texto.id, escolhido.id);
  });

  testWidgets('voltar da leitura mantém o ano escolhido', (tester) async {
    usarCelular(tester);
    await abrir(tester);
    await tester.tap(find.text('4º'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(textosDoAno(Idioma.pt, 4).first.titulo));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    esperarTitulosDoAno(4);
  });

  testWidgets('mostra os textos do idioma atual', (tester) async {
    usarCelular(tester);
    await abrir(tester);
    final idioma = Provider.of<IdiomaController>(
      tester.element(find.byType(BibliotecaScreen)),
      listen: false,
    );
    await idioma.escolher(Idioma.es);
    await tester.pumpAndSettle();
    for (final t in textosDoAno(Idioma.es, 1)) {
      expect(find.text(t.titulo), findsOneWidget, reason: t.id);
    }
    expect(find.text(textosDoAno(Idioma.pt, 1).first.titulo), findsNothing);
  });

  testWidgets('cabe em celular pequeno com fonte aumentada', (tester) async {
    usarCelular(tester, largura: 320, altura: 640);
    await abrir(tester, escalaFonte: 1.3);
    for (var ano = 1; ano <= 5; ano++) {
      await tester.tap(find.text('$anoº'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$anoº ano');
    }
  });
}
