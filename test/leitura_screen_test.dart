import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/idioma.dart';
import 'package:le_comigo/core/normalizacao.dart';
import 'package:le_comigo/core/resultado_vosk.dart';
import 'package:le_comigo/data/biblioteca.dart';
import 'package:le_comigo/screens/leitura/leitura_screen.dart';
import 'package:le_comigo/screens/leitura/widgets/texto_leitura.dart';
import 'package:le_comigo/services/vosk_service.dart';
import 'package:provider/provider.dart';

import 'apoio.dart';

/// Tela de celular comum: 360 x 800 pontos.
void usarCelular(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

// O VoskService real só toca no plugin ao começar a ouvir; nestes testes
// a leitura não começa, então ele pode ser usado sem o plugin nativo.
Widget _app(TextoBiblioteca texto) => Provider<VoskService>(
  create: (_) => VoskService(),
  child: appTeste(LeituraScreen(texto: texto)),
);

void main() {
  testWidgets('mostra o título do texto recebido', (tester) async {
    usarCelular(tester);
    final texto = textosDoAno(Idioma.pt, 3)[1];
    await tester.pumpWidget(_app(texto));
    await tester.tap(find.text('Menino'));
    await tester.pump();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    expect(find.text(texto.titulo.toUpperCase()), findsOneWidget);
  });

  testWidgets('texto mais longo (5º ano) rola sem overflow', (tester) async {
    usarCelular(tester);
    final texto = textosDoAno(
      Idioma.pt,
      5,
    ).reduce((a, b) => a.conteudo.length >= b.conteudo.length ? a : b);
    await tester.pumpWidget(_app(texto));
    await tester.tap(find.text('Menina'));
    await tester.pump();
    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('rolagem automática', () {
    final texto = textosDoAno(
      Idioma.pt,
      5,
    ).reduce((a, b) => a.conteudo.length >= b.conteudo.length ? a : b);
    final palavras = tokenizar(texto.conteudo);

    late _VoskFalante vosk;

    /// Abre a tela, escolhe o personagem e passa pela contagem 3-2-1.
    Future<void> comecarLeitura(WidgetTester tester) async {
      usarCelular(tester);
      vosk = _VoskFalante();
      await tester.pumpWidget(
        Provider<VoskService>.value(
          value: vosk,
          child: appTeste(LeituraScreen(texto: texto)),
        ),
      );
      await tester.tap(find.text('Menina'));
      await tester.pump();
      await tester.tap(find.text('CONTINUAR'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('COMEÇAR A LEITURA'));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
    }

    /// Avança 1 s em quadros de 100 ms (animações precisam de vários quadros;
    /// pumpAndSettle não serve: o relógio da leitura nunca para).
    Future<void> esperar(WidgetTester tester) async {
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    /// A criança "lê" as [n] primeiras palavras; espera a rolagem terminar.
    Future<void> lerAte(WidgetTester tester, int n) async {
      vosk.falarParcial!(palavras.take(n).join(' '));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    double rolagem(WidgetTester tester) => tester
        .state<ScrollableState>(
          find.descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          ),
        )
        .position
        .pixels;

    /// Retângulo, na tela, do trecho que contém a palavra de índice [i].
    Rect retanguloDaPalavra(WidgetTester tester, int i) {
      var contadas = 0;
      var trecho = 0;
      for (final t in texto.conteudo.split(RegExp(r'\s+'))) {
        if (t.isEmpty) continue;
        contadas += tokenizar(t).length;
        if (contadas > i) break;
        trecho++;
      }
      return tester.getRect(
        find
            .descendant(
              of: find.byType(TextoLeitura),
              matching: find.byType(Text),
            )
            .at(trecho),
      );
    }

    testWidgets('no começo da leitura a tela não rola', (tester) async {
      await comecarLeitura(tester);
      await lerAte(tester, 2);
      expect(rolagem(tester), 0);
    });

    testWidgets('a palavra atual continua visível lá no fim do texto', (
      tester,
    ) async {
      await comecarLeitura(tester);
      // Avança aos poucos, como numa leitura de verdade.
      for (var n = 10; n <= 110; n += 10) {
        await lerAte(tester, n);
      }
      final lista = tester.getRect(find.byType(ListView));
      final atual = retanguloDaPalavra(tester, 110);
      expect(rolagem(tester), greaterThan(0));
      expect(atual.top, greaterThanOrEqualTo(lista.top));
      expect(atual.bottom, lessThanOrEqualTo(lista.bottom));
    });

    testWidgets('ler de novo volta o texto para o topo', (tester) async {
      await comecarLeitura(tester);
      for (var n = 10; n <= 110; n += 10) {
        await lerAte(tester, n);
      }
      expect(rolagem(tester), greaterThan(0));
      await tester.tap(find.text('TERMINEI'));
      await esperar(tester); // o painel final sobe animado
      await tester.tap(find.text('LER DE NOVO'));
      await esperar(tester);
      expect(rolagem(tester), 0);
    });
  });
}

/// Vosk de mentira que guarda o callback de parcial para o teste "falar".
class _VoskFalante extends VoskService {
  void Function(String)? falarParcial;

  @override
  Future<bool> pedirMicrofone() async => true;

  @override
  Future<void> iniciar({
    List<String>? gramatica,
    required void Function(String) aoParcial,
    required void Function(List<PalavraReconhecida>) aoResultado,
  }) async {
    falarParcial = aoParcial;
  }

  @override
  Future<void> parar() async {}

  @override
  Future<void> cancelar() async {}
}
