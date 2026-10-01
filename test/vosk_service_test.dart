import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_comigo/core/idioma.dart';
import 'package:le_comigo/services/vosk_service.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

/// Conta quantas vezes cada modelo foi criado, sem tocar no plugin.
class _VoskContador extends VoskService {
  final criados = <Idioma>[];
  Object? falha;

  @override
  Future<Model> criarModelo(Idioma idioma) async {
    if (falha != null) throw falha!;
    criados.add(idioma);
    return Model(idioma.codigo, const MethodChannel('teste'));
  }
}

void main() {
  late _VoskContador vosk;
  setUp(() => vosk = _VoskContador());

  test('carrega o modelo do idioma pedido', () async {
    expect(vosk.modeloCarregado, isFalse);
    await vosk.carregarModelo(Idioma.pt);
    expect(vosk.criados, [Idioma.pt]);
    expect(vosk.idiomaCarregado, Idioma.pt);
    expect(vosk.modeloCarregado, isTrue);
  });

  test('pedir o mesmo idioma de novo não recria o modelo', () async {
    await vosk.carregarModelo(Idioma.pt);
    await vosk.carregarModelo(Idioma.pt);
    expect(vosk.criados, [Idioma.pt]);
  });

  test('trocar e voltar reaproveita o modelo já criado', () async {
    await vosk.carregarModelo(Idioma.pt);
    await vosk.carregarModelo(Idioma.en);
    await vosk.carregarModelo(Idioma.pt);
    expect(vosk.criados, [Idioma.pt, Idioma.en]);
    expect(vosk.idiomaCarregado, Idioma.pt);
  });

  test('se o modelo novo falha, o anterior continua ativo', () async {
    await vosk.carregarModelo(Idioma.pt);
    vosk.falha = Exception('zip corrompido');
    await expectLater(vosk.carregarModelo(Idioma.es), throwsException);
    expect(vosk.idiomaCarregado, Idioma.pt);
    expect(vosk.modeloCarregado, isTrue);
  });
}
