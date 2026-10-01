import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../core/avaliacao_leitura.dart';
import '../../core/normalizacao.dart';
import '../../core/progresso_leitura.dart';
import '../../core/resultado_vosk.dart';
import '../../services/vosk_service.dart';

enum FaseLeitura { escolha, pronto, contagem, lendo, fim }

enum ErroLeitura { semPermissao, falhaMicrofone }

/// Estado e regras da tela de leitura. Não conhece widgets: a tela só
/// lê os getters e chama os métodos.
///
/// Fluxo: escolha do personagem → pronto → contagem 3-2-1
/// → lendo (até [duracaoMaxima] ou "Terminei") → fim.
class LeituraController extends ChangeNotifier {
  LeituraController({
    required this.texto,
    required this._vosk, // chamado como vosk:
    this.duracaoMaxima = const Duration(seconds: 60),
    @visibleForTesting DateTime Function()? agora,
  }) : esperadas = tokenizar(texto),
       _agora = agora ?? DateTime.now;

  final String texto;

  /// Palavras do texto, normalizadas.
  final List<String> esperadas;
  final Duration duracaoMaxima;

  final VoskService _vosk;
  final DateTime Function() _agora;

  /// Tempo de leitura decorrido. Fica fora do notifyListeners para que,
  /// a cada tique, só a barra de tempo seja redesenhada.
  final decorrido = ValueNotifier<Duration>(Duration.zero);

  FaseLeitura _fase = FaseLeitura.escolha;
  bool? _menina;
  int _contagem = 3;
  ErroLeitura? _erro;
  bool _parando = false;
  bool _mostrarDetalhes = false;
  DateTime? _inicio;
  Timer? _relogio;
  bool _descartado = false;

  /// Resultados finais (a cada pausa da fala) e o parcial do trecho atual.
  final List<PalavraReconhecida> _finais = [];
  String _parcial = '';

  AvaliacaoLeitura? _avaliacao;

  FaseLeitura get fase => _fase;

  /// Personagem escolhido; null enquanto a criança não escolheu.
  bool? get menina => _menina;
  int get contagem => _contagem;
  ErroLeitura? get erro => _erro;
  bool get parando => _parando;
  bool get mostrarDetalhes => _mostrarDetalhes;
  String get parcial => _parcial;
  UnmodifiableListView<PalavraReconhecida> get finais =>
      UnmodifiableListView(_finais);

  /// Até qual palavra do texto a criança já chegou (destaque ao vivo).
  int get alcancadas => palavrasAlcancadas(esperadas, [
    for (final p in _finais) ...tokenizar(p.palavra),
    ...tokenizar(_parcial),
  ]);

  bool get ouviuAlgo => alcancadas > 0;

  /// Acertos, erros e PCPM da leitura. Só existe na fase [FaseLeitura.fim].
  AvaliacaoLeitura? get avaliacao => _avaliacao;

  // ---------------------------------------------------------------- escolha

  void escolherPersonagem({required bool menina}) {
    _menina = menina;
    notifyListeners();
  }

  void confirmarPersonagem() {
    if (_menina == null) return;
    _mudarFase(FaseLeitura.pronto);
  }

  /// Volta para a escolha (só antes de começar a ler).
  void trocarPersonagem() {
    if (_fase == FaseLeitura.pronto) _mudarFase(FaseLeitura.escolha);
  }

  // ---------------------------------------------------------------- leitura

  Future<void> comecar() async {
    if (_fase != FaseLeitura.pronto) return;

    if (!await _vosk.pedirMicrofone()) {
      _erro = ErroLeitura.semPermissao;
      notifyListeners();
      return;
    }

    _erro = null;
    _limparReconhecimento();
    _fase = FaseLeitura.contagem;
    for (var i = 3; i >= 1; i--) {
      if (_descartado) return;
      _contagem = i;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 1));
    }
    if (_descartado) return;

    try {
      await _vosk.iniciar(
        gramatica: palavrasDaGramatica(texto),
        aoParcial: _aoParcial,
        aoResultado: _aoResultado,
      );
    } catch (_) {
      _erro = ErroLeitura.falhaMicrofone;
      _mudarFase(FaseLeitura.pronto);
      return;
    }

    _inicio = _agora();
    _relogio = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _tique(),
    );
    _mudarFase(FaseLeitura.lendo);
  }

  Future<void> terminar() async {
    if (_fase != FaseLeitura.lendo || _parando) return;
    _relogio?.cancel();
    _parando = true;
    notifyListeners();

    await _vosk.parar(); // espera o último trecho reconhecido
    if (_descartado) return;

    // O parcial NÃO é limpo aqui: se o resultado final não chegou a tempo,
    // ele ainda guarda as últimas palavras lidas (_aoResultado já o limpa).
    _parando = false;
    _avaliacao = _avaliar();
    _mudarFase(FaseLeitura.fim);
  }

  void lerDeNovo() {
    _limparReconhecimento();
    decorrido.value = Duration.zero;
    _mudarFase(FaseLeitura.pronto);
  }

  void alternarDetalhes() {
    _mostrarDetalhes = !_mostrarDetalhes;
    notifyListeners();
  }

  // --------------------------------------------------------------- internos

  void _tique() {
    decorrido.value = _agora().difference(_inicio!);
    if (decorrido.value >= duracaoMaxima) {
      decorrido.value = duracaoMaxima;
      terminar();
    }
  }

  void _aoParcial(String texto) {
    if (_descartado) return;
    _parcial = texto;
    notifyListeners();
  }

  void _aoResultado(List<PalavraReconhecida> palavras) {
    if (_descartado) return;
    _finais.addAll(palavras);
    _parcial = '';
    notifyListeners();
  }

  void _limparReconhecimento() {
    _finais.clear();
    _parcial = '';
    _avaliacao = null;
  }

  AvaliacaoLeitura _avaliar() {
    final parcial = tokenizar(_parcial);
    return avaliarLeitura(
      esperadas: esperadas,
      reconhecidas: [
        for (final p in _finais) ...tokenizar(p.palavra),
        ...parcial,
      ],
      tempo: tempoDeLeitura(
        finais: _finais,
        decorrido: decorrido.value,
        sobrouParcial: parcial.isNotEmpty,
      ),
    );
  }

  void _mudarFase(FaseLeitura nova) {
    _fase = nova;
    notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    _relogio?.cancel();
    _vosk.cancelar();
    decorrido.dispose();
    super.dispose();
  }
}
