import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/formatacao.dart';
import '../../../tema/tema_app.dart';
import '../../../l10n/app_localizations.dart';

/// Barra amarela no topo que encolhe conforme o tempo passa, com o
/// tempo restante e o botão ⓘ dos dados do reconhecimento.
///
/// Escuta [decorrido] sozinha: só ela é redesenhada a cada tique.
class BarraTempo extends StatelessWidget {
  const BarraTempo({
    super.key,
    required this.decorrido,
    required this.duracaoMaxima,
    required this.aoAlternarDetalhes,
  });

  final ValueListenable<Duration> decorrido;
  final Duration duracaoMaxima;
  final VoidCallback aoAlternarDetalhes;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 4, 4),
      child: ValueListenableBuilder<Duration>(
        valueListenable: decorrido,
        builder: (context, tempo, _) {
          final fracao = tempo.inMilliseconds / duracaoMaxima.inMilliseconds;
          return Row(
            children: [
              const Icon(Icons.timer_outlined, color: Cores.textoSuave),
              const SizedBox(width: 10),
              Expanded(child: _Barra(restante: 1 - fracao.clamp(0.0, 1.0))),
              const SizedBox(width: 12),
              Text(
                formatarMinSeg(duracaoMaxima - tempo),
                style: Estilos.destaque.copyWith(
                  fontSize: 18,
                  color: Cores.texto,
                ),
              ),
              IconButton(
                tooltip: t.dadosReconhecimento,
                onPressed: aoAlternarDetalhes,
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Cores.textoSuave,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({required this.restante});

  final double restante;

  @override
  Widget build(BuildContext context) {
    final raio = BorderRadius.circular(8);
    return Container(
      height: 16,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: Cores.borda, borderRadius: raio),
      child: FractionallySizedBox(
        widthFactor: restante,
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          decoration: BoxDecoration(color: Cores.amarelo, borderRadius: raio),
          // Brilho na parte de cima, como nas barras do Duolingo.
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
