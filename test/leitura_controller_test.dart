import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/avaliacao_leitura.dart';
import 'package:le_comigo/core/resultado_vosk.dart';
import 'package:le_comigo/screens/leitura/leitura_controller.dart';
import 'package:le_comigo/services/vosk_service.dart';

/// Vosk de mentira: guarda os callbacks para o teste "falar" por eles.
class VoskFalso extends VoskService {
  VoskFalso({this.permitirMicrofone = true});

  final bool permitirMicrofone;
  bool iniciou = false;
  bool parou = false;
  void Function(String)? falarParcial;
  void Function(List<PalavraReconhecida>)? falarResultado;

  @override
  Future<bool> pedirMicrofone() async => permitirMicrofone;

  @override
  Future<void> iniciar({
    List<String>? gramatica,
    required void Function(String) aoParcial,
    required void Function(List<PalavraReconhecida>) aoResultado,
  }) async {
    iniciou = true;
    falarParcial = aoParcial;
    falarResultado = aoResultado;
  }

  @override
  Future<void> parar() async => parou = true;

  @override
  Future<void> cancelar() async {}
}

const _texto = 'O gato da Lia dorme no sofá.';

void main() {
  late VoskFalso vosk;
  late DateTime agora;
  late LeituraController c;

  setUp(() {
    vosk = VoskFalso();
    agora = DateTime(2026, 10, 1, 9);
    c = LeituraController(texto: _texto, vosk: vosk, agora: () => agora);
  });

  /// Escolhe personagem, toca em Começar e passa pela contagem 3-2-1.
  Future<void> comecarLeitura(WidgetTester tester) async {
    c.escolherPersonagem(menina: true);
    c.confirmarPersonagem();
    final comecando = c.comecar();
    await tester.pump(const Duration(seconds: 3));
    await comecando;
  }

  test('começa na escolha e só avança depois de escolher', () {
    expect(c.fase, FaseLeitura.escolha);
    c.confirmarPersonagem();
    expect(c.fase, FaseLeitura.escolha);

    c.escolherPersonagem(menina: true);
    c.confirmarPersonagem();
    expect(c.fase, FaseLeitura.pronto);
    expect(c.menina, isTrue);
  });

  test('trocar personagem só funciona antes de começar', () {
    c.escolherPersonagem(menina: false);
    c.confirmarPersonagem();
    c.trocarPersonagem();
    expect(c.fase, FaseLeitura.escolha);
  });

  test('sem permissão do microfone, mostra erro e não começa', () async {
    c = LeituraController(
      texto: _texto,
      vosk: VoskFalso(permitirMicrofone: false),
    );
    c.escolherPersonagem(menina: false);
    c.confirmarPersonagem();
    await c.comecar();
    expect(c.fase, FaseLeitura.pronto);
    expect(c.erro, ErroLeitura.semPermissao);
  });

  testWidgets('contagem 3-2-1 e depois começa a ouvir', (tester) async {
    c.escolherPersonagem(menina: true);
    c.confirmarPersonagem();
    final comecando = c.comecar();
    await tester.pump();
    expect(c.fase, FaseLeitura.contagem);
    expect(c.contagem, 3);
    await tester.pump(const Duration(seconds: 1));
    expect(c.contagem, 2);
    expect(vosk.iniciou, isFalse);

    await tester.pump(const Duration(seconds: 2));
    await comecando;
    expect(c.fase, FaseLeitura.lendo);
    expect(vosk.iniciou, isTrue);
    c.dispose(); // para o relógio da leitura
  });

  testWidgets('parcial e resultados avançam o destaque', (tester) async {
    await comecarLeitura(tester);
    vosk.falarParcial!('o gato');
    expect(c.alcancadas, 2);

    vosk.falarResultado!([
      for (final p in ['o', 'gato', 'da'])
        PalavraReconhecida(palavra: p, inicio: 0, fim: 0),
    ]);
    vosk.falarParcial!('lia');
    expect(c.alcancadas, 4);
    c.dispose();
  });

  testWidgets('ao terminar, mantém o parcial que não virou resultado', (
    tester,
  ) async {
    await comecarLeitura(tester);
    vosk.falarParcial!('o gato da');
    await c.terminar();
    expect(c.fase, FaseLeitura.fim);
    expect(vosk.parou, isTrue);
    expect(c.alcancadas, 3);
  });

  testWidgets('para sozinho ao atingir o tempo máximo', (tester) async {
    await comecarLeitura(tester);
    agora = agora.add(const Duration(seconds: 30));
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.decorrido.value, const Duration(seconds: 30));
    expect(c.fase, FaseLeitura.lendo);

    agora = agora.add(const Duration(seconds: 31));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(c.fase, FaseLeitura.fim);
    expect(c.decorrido.value, c.duracaoMaxima);
  });

  testWidgets('ler de novo zera o reconhecimento e o tempo', (tester) async {
    await comecarLeitura(tester);
    vosk.falarParcial!('o gato');
    agora = agora.add(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 100));
    await c.terminar();

    c.lerDeNovo();
    expect(c.fase, FaseLeitura.pronto);
    expect(c.alcancadas, 0);
    expect(c.decorrido.value, Duration.zero);
    expect(c.menina, isTrue); // mantém o personagem
  });

  group('avaliação', () {
    PalavraReconhecida p(String palavra, double fim) =>
        PalavraReconhecida(palavra: palavra, inicio: fim - 0.3, fim: fim);

    testWidgets('só existe depois de terminar', (tester) async {
      await comecarLeitura(tester);
      vosk.falarResultado!([p('o', 0.5)]);
      expect(c.avaliacao, isNull);
      await c.terminar();
      expect(c.avaliacao, isNotNull);
    });

    testWidgets('avalia as palavras e usa o fim da última como tempo', (
      tester,
    ) async {
      await comecarLeitura(tester);
      vosk.falarResultado!([p('o', 0.5), p('rato', 1.0), p('da', 1.5)]);
      agora = agora.add(const Duration(seconds: 20));
      await tester.pump(const Duration(milliseconds: 100));
      await c.terminar();

      final a = c.avaliacao!;
      expect(a.status.take(3), [
        StatusPalavra.certa,
        StatusPalavra.trocada,
        StatusPalavra.certa,
      ]);
      expect(a.tempo, const Duration(milliseconds: 1500));
    });

    testWidgets('com fala que ficou só no parcial, usa o cronômetro', (
      tester,
    ) async {
      await comecarLeitura(tester);
      vosk.falarResultado!([p('o', 0.5)]);
      vosk.falarParcial!('gato');
      agora = agora.add(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 100));
      await c.terminar();

      expect(c.avaliacao!.certas, 2);
      expect(c.avaliacao!.tempo, const Duration(seconds: 4));
    });

    testWidgets('ler de novo apaga a avaliação', (tester) async {
      await comecarLeitura(tester);
      await c.terminar();
      c.lerDeNovo();
      expect(c.avaliacao, isNull);
    });
  });

  testWidgets('sair da tela durante a contagem não liga o microfone', (
    tester,
  ) async {
    c.escolherPersonagem(menina: false);
    c.confirmarPersonagem();
    final comecando = c.comecar();
    await tester.pump(const Duration(seconds: 1));
    c.dispose();
    await tester.pump(const Duration(seconds: 3));
    await comecando;
    expect(vosk.iniciou, isFalse);
  });
}
