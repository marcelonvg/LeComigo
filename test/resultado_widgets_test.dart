import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/avaliacao_leitura.dart';
import 'package:le_comigo/core/normalizacao.dart';
import 'package:le_comigo/screens/leitura/widgets/painel_fim.dart';
import 'package:le_comigo/screens/resultado/resultado_screen.dart';

import 'apoio.dart';

const _texto = 'O gato da Lia dorme no sofá.';

AvaliacaoLeitura _avaliar(String reconhecido, {int segundos = 30}) =>
    avaliarLeitura(
      esperadas: tokenizar(_texto),
      reconhecidas: tokenizar(reconhecido),
      tempo: Duration(seconds: segundos),
    );

Widget _app(Widget filho) => appTeste(Scaffold(body: filho));

void main() {
  group('PainelFim (criança)', () {
    testWidgets('mostra as estrelas e não mostra números', (tester) async {
      await tester.pumpWidget(
        _app(
          PainelFim(
            ouviu: true,
            estrelas: 2,
            aoLerDeNovo: () {},
            aoVerDetalhes: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('2 de 3 estrelas'), findsOneWidget);
      expect(find.textContaining(RegExp(r'\d')), findsNothing);
    });

    testWidgets('"Ver detalhes" abre os detalhes', (tester) async {
      var abriu = false;
      await tester.pumpWidget(
        _app(
          PainelFim(
            ouviu: true,
            estrelas: 3,
            aoLerDeNovo: () {},
            aoVerDetalhes: () => abriu = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver detalhes'));
      expect(abriu, isTrue);
    });

    testWidgets('se não ouviu, sem estrelas nem detalhes', (tester) async {
      await tester.pumpWidget(
        _app(
          PainelFim(
            ouviu: false,
            estrelas: 0,
            aoLerDeNovo: () {},
            aoVerDetalhes: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Não consegui ouvir'), findsOneWidget);
      expect(find.text('Ver detalhes'), findsNothing);
      expect(find.bySemanticsLabel(RegExp('estrelas')), findsNothing);
    });
  });

  group('ResultadoScreen (professor)', () {
    Future<void> abrir(WidgetTester tester, AvaliacaoLeitura a) async {
      await tester.pumpWidget(
        appTeste(
          ResultadoScreen(
            titulo: 'O gato curioso',
            texto: _texto,
            avaliacao: a,
          ),
        ),
      );
    }

    testWidgets('mostra PCPM, precisão e tempo', (tester) async {
      // 3 certas de 4 lidas, em 30 s → 6 PCPM, 75%.
      await abrir(tester, _avaliar('o rato da lia'));
      expect(find.text('6'), findsOneWidget);
      expect(find.text('palavras corretas por minuto'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('0:30'), findsOneWidget);
    });

    testWidgets('mostra as contagens por tipo', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester, _avaliar('o rato lia dorme dorme'));
      expect(find.bySemanticsLabel('Certas: 3'), findsOneWidget);
      expect(find.bySemanticsLabel('Trocadas: 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Puladas: 1'), findsOneWidget);
      expect(find.bySemanticsLabel('Acrescentadas: 1'), findsOneWidget);
      semantica.dispose();
    });

    testWidgets('marca cada palavra do texto pelo status', (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester, _avaliar('o rato lia'));
      expect(find.bySemanticsLabel('gato: trocada'), findsOneWidget);
      expect(find.bySemanticsLabel('da: pulada'), findsOneWidget);
      expect(find.bySemanticsLabel('sofá.: não lida'), findsOneWidget);
      semantica.dispose();
    });
  });
}
