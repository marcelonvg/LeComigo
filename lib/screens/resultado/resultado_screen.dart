import 'package:flutter/material.dart';

import '../../core/avaliacao_leitura.dart';
import '../../core/formatacao.dart';
import '../../core/normalizacao.dart';
import '../../tema/tema_app.dart';
import '../leitura/widgets/cartao_texto.dart';
import '../../l10n/app_localizations.dart';

/// Detalhes da leitura para o professor: PCPM, precisão, tempo,
/// contagens e o texto com cada palavra marcada pelo status.
class ResultadoScreen extends StatelessWidget {
  const ResultadoScreen({
    super.key,
    required this.titulo,
    required this.texto,
    required this.avaliacao,
  });

  final String titulo;
  final String texto;
  final AvaliacaoLeitura avaliacao;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final a = avaliacao;
    final precisao = a.precisao;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.resultadoTitulo, style: Estilos.destaque),
        backgroundColor: Cores.fundo,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _CartaoPcpm(pcpm: a.pcpm),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CartaoValor(
                  rotulo: t.precisao,
                  valor: precisao == null
                      ? '—'
                      : '${(precisao * 100).round()}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CartaoValor(
                  rotulo: t.tempo,
                  valor: formatarMinSeg(a.tempo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Contagem(t.certas, a.certas, _Visual.certa.cor),
              _Contagem(t.trocadas, a.trocadas, _Visual.trocada.cor),
              _Contagem(t.puladas, a.puladas, _Visual.pulada.cor),
              _Contagem(t.acrescentadas, a.acrescentadas, Cores.textoAzulado),
            ],
          ),
          const SizedBox(height: 16),
          CartaoTexto(
            titulo: titulo,
            child: _TextoAvaliado(texto: texto, status: a.status),
          ),
          const SizedBox(height: 12),
          const _Legenda(),
        ],
      ),
    );
  }
}

class _CartaoPcpm extends StatelessWidget {
  const _CartaoPcpm({required this.pcpm});

  final double pcpm;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Cores.tealClaro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '${pcpm.round()}',
            style: Estilos.numeroGrande.copyWith(color: Cores.tealSombra),
          ),
          const SizedBox(height: 6),
          Text(
            t.palavrasCorretasPorMinuto,
            style: Estilos.corpo.comPeso(600).copyWith(color: Cores.tealSombra),
          ),
        ],
      ),
    );
  }
}

class _CartaoValor extends StatelessWidget {
  const _CartaoValor({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Cores.fundoSuave,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo.toUpperCase(), style: Estilos.rotulo),
          const SizedBox(height: 4),
          Text(valor, style: Estilos.titulo),
        ],
      ),
    );
  }
}

class _Contagem extends StatelessWidget {
  const _Contagem(this.rotulo, this.valor, this.cor);

  final String rotulo;
  final int valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$rotulo: $valor',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Cores.borda, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$valor', style: Estilos.destaque.copyWith(color: cor)),
            const SizedBox(width: 6),
            Text(rotulo, style: Estilos.pequeno),
          ],
        ),
      ),
    );
  }
}

/// Cor, estilo e nome de cada status no texto e na legenda.
enum _Visual {
  certa(Cores.teal),
  trocada(Cores.erro),
  pulada(Cores.textoSuave),
  naoLida(Cores.textoDesabilitado);

  const _Visual(this.cor);
  final Color cor;

  String nome(AppLocalizations t) => switch (this) {
    certa => t.statusCerta,
    trocada => t.statusTrocada,
    pulada => t.statusPulada,
    naoLida => t.statusNaoLida,
  };

  static _Visual de(StatusPalavra s) => switch (s) {
    StatusPalavra.certa => certa,
    StatusPalavra.trocada => trocada,
    StatusPalavra.pulada => pulada,
    StatusPalavra.naoLida => naoLida,
  };

  TextStyle get estilo => switch (this) {
    certa => Estilos.leitura.comPeso(500).copyWith(color: cor),
    trocada =>
      Estilos.leitura
          .comPeso(500)
          .copyWith(color: cor, backgroundColor: const Color(0xFFFDE7E7)),
    pulada => Estilos.leitura.copyWith(
      color: cor,
      decoration: TextDecoration.lineThrough,
      decorationColor: cor,
    ),
    naoLida => Estilos.leitura.copyWith(color: cor),
  };
}

/// O texto original (com pontuação), cada trecho com a cor do seu status.
class _TextoAvaliado extends StatelessWidget {
  const _TextoAvaliado({required this.texto, required this.status});

  final String texto;
  final List<StatusPalavra> status;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final palavras = <Widget>[];
    var indice =
        0; // posição, em palavras normalizadas (mesma conta do TextoLeitura)
    for (final trecho in texto.split(RegExp(r'\s+'))) {
      if (trecho.isEmpty) continue;
      final n = tokenizar(trecho).length;
      final doTrecho = status.sublist(indice, indice + n);
      indice += n;
      if (doTrecho.isEmpty) {
        palavras.add(Text(trecho, style: Estilos.leitura));
        continue;
      }
      final visual = _Visual.de(_pior(doTrecho));
      palavras.add(
        Semantics(
          container: true,
          label: '$trecho: ${visual.nome(t)}',
          excludeSemantics: true,
          child: Text(trecho, style: visual.estilo),
        ),
      );
    }
    return Wrap(spacing: 7, runSpacing: 6, children: palavras);
  }

  /// Um trecho com várias palavras ("guarda-chuva") mostra o pior status.
  static StatusPalavra _pior(List<StatusPalavra> lista) {
    for (final s in const [
      StatusPalavra.trocada,
      StatusPalavra.pulada,
      StatusPalavra.certa,
    ]) {
      if (lista.contains(s)) return s;
    }
    return StatusPalavra.naoLida;
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return ExcludeSemantics(
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          for (final v in _Visual.values)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: v.cor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(v.nome(t), style: Estilos.pequeno),
              ],
            ),
        ],
      ),
    );
  }
}
