import 'package:flutter/material.dart';

import '../../../core/normalizacao.dart';
import '../../../tema/tema_app.dart';

enum _Estado { pendente, atual, lida }

/// Texto da leitura com as palavras mudando de cor conforme a criança lê.
///
/// [alcancadas]: quantas palavras (normalizadas) já foram lidas.
/// [ativo]: false antes de começar (tudo neutro, sem marcação).
/// [marcarAtual]: sublinha a próxima palavra (só durante a leitura).
///
/// Durante a leitura, rola a tela para a palavra atual não sumir: quando ela
/// passa de [_limiteInferior] da altura visível (ou sai da tela), volta para
/// [_alinhamento]. Rola em saltos de algumas linhas, não a cada palavra.
/// Ao sair da leitura (ler de novo), volta o texto para o topo.
class TextoLeitura extends StatefulWidget {
  const TextoLeitura({
    super.key,
    required this.texto,
    required this.alcancadas,
    required this.ativo,
    this.marcarAtual = true,
  });

  final String texto;
  final int alcancadas;
  final bool ativo;
  final bool marcarAtual;

  @override
  State<TextoLeitura> createState() => _TextoLeituraState();
}

class _TextoLeituraState extends State<TextoLeitura> {
  static const _alinhamento = 0.3;
  static const _limiteInferior = 0.6;
  static const _duracao = Duration(milliseconds: 400);

  /// Marca a palavra atual, para achar onde ela está na tela.
  final _chaveAtual = GlobalKey();

  @override
  void didUpdateWidget(TextoLeitura antigo) {
    super.didUpdateWidget(antigo);
    if (widget.marcarAtual && widget.alcancadas != antigo.alcancadas) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _acompanhar());
    }
    if (antigo.ativo && !widget.ativo) {
      Scrollable.maybeOf(context)?.position
          .animateTo(0, duration: _duracao, curve: Curves.easeOutCubic);
    }
  }

  void _acompanhar() {
    final atual = _chaveAtual.currentContext;
    final rolagem = Scrollable.maybeOf(context);
    if (!mounted || atual == null || rolagem == null) return;
    final palavra = atual.findRenderObject() as RenderBox?;
    final visivel = rolagem.context.findRenderObject() as RenderBox?;
    if (palavra == null || visivel == null) return;

    final topo = palavra.localToGlobal(Offset.zero, ancestor: visivel).dy;
    final altura = visivel.size.height;
    if (topo >= 0 && topo + palavra.size.height <= altura * _limiteInferior) {
      return;
    }
    Scrollable.ensureVisible(
      atual,
      alignment: _alinhamento,
      duration: _duracao,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palavras = <Widget>[];
    var indice = 0; // posição, em palavras normalizadas, do início do trecho
    for (final trecho in widget.texto.split(RegExp(r'\s+'))) {
      if (trecho.isEmpty) continue;
      // Um trecho pode valer 0 palavras ("—") ou mais de uma ("guarda-chuva").
      final n = tokenizar(trecho).length;
      final fim = indice + n;
      final estado = _estado(indice, fim, n);
      palavras.add(
        _Palavra(
          trecho,
          estado,
          key: estado == _Estado.atual ? _chaveAtual : null,
        ),
      );
      indice = fim;
    }
    return Wrap(spacing: 7, runSpacing: 6, children: palavras);
  }

  _Estado _estado(int inicio, int fim, int n) {
    if (!widget.ativo || n == 0) return _Estado.pendente;
    if (fim <= widget.alcancadas) return _Estado.lida;
    if (widget.marcarAtual && inicio <= widget.alcancadas) {
      return _Estado.atual;
    }
    return _Estado.pendente;
  }
}

class _Palavra extends StatelessWidget {
  const _Palavra(this.texto, this.estado, {super.key});

  final String texto;
  final _Estado estado;

  static final _lida = Estilos.leitura.comPeso(500).copyWith(color: Cores.teal);
  static final _atual = Estilos.leitura
      .comPeso(500)
      .copyWith(
        color: Cores.grafite,
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
        decorationColor: Cores.amarelo,
        decorationThickness: 3,
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 250),
      style: switch (estado) {
        _Estado.lida => _lida,
        _Estado.atual => _atual,
        _Estado.pendente => Estilos.leitura,
      },
      child: Text(texto),
    );
  }
}
