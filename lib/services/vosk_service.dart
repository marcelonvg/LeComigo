import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

import '../core/idioma.dart';
import '../core/resultado_vosk.dart';

/// Envolve o vosk_flutter: carrega o modelo de cada idioma uma vez e
/// controla uma sessão de reconhecimento por vez (o plugin só aceita um
/// SpeechService ativo).
///
/// O áudio vai direto do microfone para o reconhecedor, em memória.
/// Nada é gravado em disco.
class VoskService {
  static const _taxaAmostragem = 16000;

  late final _plugin = VoskFlutterPlugin.instance();

  /// Modelos já carregados, por idioma. No Android o plugin guarda o modelo
  /// do lado Java e não o libera (Model.dispose só age em desktop), então
  /// cada idioma é criado uma vez só e reaproveitado.
  final _modelos = <Idioma, Model>{};
  Idioma? _idioma;

  Model? get _modelo => _modelos[_idioma];

  Recognizer? _reconhecedor;
  SpeechService? _servico;
  StreamSubscription<String>? _subParcial;
  StreamSubscription<String>? _subResultado;

  /// Completa quando chega o resultado final depois de parar().
  Completer<void>? _aguardandoFinal;

  bool get modeloCarregado => _modelo != null;
  bool get gravando => _servico != null;

  /// Idioma do modelo ativo; null antes do primeiro carregamento.
  Idioma? get idiomaCarregado => _idioma;

  /// Torna [idioma] o modelo ativo. Na primeira vez de cada idioma,
  /// descompacta o zip (alguns segundos). Se falhar, o anterior continua.
  Future<void> carregarModelo(Idioma idioma) async {
    if (_idioma == idioma) return;
    await cancelar();
    _modelos[idioma] ??= await criarModelo(idioma);
    _idioma = idioma;
  }

  /// Descompacta o zip do [idioma] (só na primeira vez) e cria o modelo.
  @protected
  Future<Model> criarModelo(Idioma idioma) async {
    final caminho = await ModelLoader().loadFromAssets(idioma.modelo);
    return _plugin.createModel(caminho);
  }

  /// Pede a permissão do microfone. Retorna true se foi concedida.
  Future<bool> pedirMicrofone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Inicia o reconhecimento.
  ///
  /// [gramatica]: lista de palavras permitidas (inclua "[unk]"); null = vocabulário livre.
  /// [aoParcial]: texto parcial, chamado várias vezes por segundo.
  /// [aoResultado]: palavras com tempos, chamado a cada pausa e ao parar.
  Future<void> iniciar({
    List<String>? gramatica,
    required void Function(String texto) aoParcial,
    required void Function(List<PalavraReconhecida> palavras) aoResultado,
  }) async {
    if (_modelo == null) throw StateError('Modelo não carregado.');
    if (_servico != null) await parar();

    _reconhecedor = await _plugin.createRecognizer(
      model: _modelo!,
      sampleRate: _taxaAmostragem,
      grammar: gramatica,
    );
    // Tempos por palavra (start/end) nos resultados finais.
    await _reconhecedor!.setWords(words: true);

    _servico = await _plugin.initSpeechService(_reconhecedor!);

    _subParcial = _servico!.onPartial().listen((json) {
      aoParcial(lerParcial(json));
    });
    _subResultado = _servico!.onResult().listen((json) {
      final palavras = lerResultado(json);
      if (palavras.isNotEmpty) aoResultado(palavras);
      // Depois do stop(), o próximo resultado é o final.
      final espera = _aguardandoFinal;
      if (espera != null && !espera.isCompleted) espera.complete();
    });

    await _servico!.start();
  }

  /// Para a gravação, espera o último resultado (com o trecho final da fala)
  /// e libera os recursos.
  Future<void> parar() async {
    final servico = _servico;
    if (servico == null) return;

    _aguardandoFinal = Completer<void>();
    await servico.stop();
    // O resultado final chega de forma assíncrona; não espera para sempre.
    await _aguardandoFinal!.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () {},
    );
    _aguardandoFinal = null;

    await _liberar();
  }

  /// Interrompe sem esperar o resultado final (ex.: ao sair da tela).
  Future<void> cancelar() async {
    if (_servico == null) return;
    await _servico!.cancel();
    await _liberar();
  }

  Future<void> _liberar() async {
    await _subParcial?.cancel();
    await _subResultado?.cancel();
    _subParcial = null;
    _subResultado = null;

    await _servico?.dispose();
    _servico = null;
    await _reconhecedor?.dispose();
    _reconhecedor = null;
  }
}
