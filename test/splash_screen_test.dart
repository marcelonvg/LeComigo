import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/idioma.dart';
import 'package:le_comigo/screens/splash/splash_screen.dart';
import 'package:le_comigo/services/idioma_controller.dart';
import 'package:le_comigo/services/vosk_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'apoio.dart';

/// Vosk cujo modelo nunca carrega (ex.: sem espaço para descompactar).
class _VoskQueFalha extends VoskService {
  final pedidos = <Idioma>[];

  @override
  Future<void> carregarModelo(Idioma idioma) async {
    pedidos.add(idioma);
    throw Exception('sem espaço');
  }
}

void main() {
  // Sem isto, um idioma salvo cujo modelo falha prenderia o app na splash:
  // a tela inicial, onde dá para trocar de idioma, nunca apareceria.
  testWidgets('se o modelo do idioma salvo falha, segue para a tela inicial', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({IdiomaController.chave: 'es'});
    final idioma = await IdiomaController.carregar();
    final vosk = _VoskQueFalha();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<VoskService>.value(value: vosk),
          ChangeNotifierProvider<IdiomaController>.value(value: idioma),
        ],
        child: appTeste(
          SplashScreen(proximaTela: (_) => const Text('tela inicial')),
        ),
      ),
    );
    // A splash anima sem parar: avança o relógio em vez de pumpAndSettle.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(vosk.pedidos, [Idioma.es]);
    expect(find.text('tela inicial'), findsOneWidget);
  });
}
