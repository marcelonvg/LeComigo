import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/idioma.dart';
import 'package:le_comigo/services/idioma_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<IdiomaController> _criar(
  Map<String, Object> salvo, {
  String? aparelho,
}) async {
  SharedPreferences.setMockInitialValues(salvo);
  return IdiomaController.carregar(codigoAparelho: aparelho);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('doCodigo acha pelo código; desconhecido ou null dá null', () {
    expect(Idioma.doCodigo('pt'), Idioma.pt);
    expect(Idioma.doCodigo('en'), Idioma.en);
    expect(Idioma.doCodigo('es'), Idioma.es);
    expect(Idioma.doCodigo('fr'), isNull);
    expect(Idioma.doCodigo(null), isNull);
  });

  test('cada idioma tem nome próprio e modelo próprio', () {
    expect(Idioma.values.map((i) => i.nome), [
      'Português',
      'English',
      'Español',
    ]);
    final modelos = Idioma.values.map((i) => i.modelo).toSet();
    expect(modelos.length, Idioma.values.length);
    expect(modelos.every((m) => m.startsWith('assets/models/')), isTrue);
  });

  group('IdiomaController', () {
    test('sem nada salvo, usa o idioma do aparelho', () async {
      expect((await _criar({}, aparelho: 'en')).atual, Idioma.en);
      expect((await _criar({}, aparelho: 'es')).atual, Idioma.es);
    });

    test('aparelho em idioma sem suporte começa em português', () async {
      expect((await _criar({}, aparelho: 'fr')).atual, Idioma.pt);
      expect((await _criar({})).atual, Idioma.pt);
    });

    test('o idioma salvo vence o do aparelho', () async {
      final c = await _criar({IdiomaController.chave: 'es'}, aparelho: 'en');
      expect(c.atual, Idioma.es);
    });

    test('código salvo inválido cai no idioma do aparelho', () async {
      final c = await _criar({IdiomaController.chave: 'fr'}, aparelho: 'en');
      expect(c.atual, Idioma.en);
    });

    test('escolher avisa quem escuta e salva', () async {
      final c = await _criar({});
      var avisos = 0;
      c.addListener(() => avisos++);
      await c.escolher(Idioma.es);
      expect(c.atual, Idioma.es);
      expect(avisos, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(IdiomaController.chave), 'es');
    });

    test('escolher o idioma atual não avisa', () async {
      final c = await _criar({}, aparelho: 'en');
      var avisos = 0;
      c.addListener(() => avisos++);
      await c.escolher(Idioma.en);
      expect(avisos, 0);
    });
  });
}
