import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/sons.dart';
import '../../../tema/tema_app.dart';
import '../../../l10n/app_localizations.dart';

/// Contagem 3-2-1 por cima da tela. Cada número entra com um "pulo"
/// e o aparelho dá um toque leve e um "ding".
class ContagemRegressiva extends StatefulWidget {
  const ContagemRegressiva({super.key, required this.numero});

  final int numero;

  @override
  State<ContagemRegressiva> createState() => _ContagemRegressivaState();
}

class _ContagemRegressivaState extends State<ContagemRegressiva> {
  @override
  void initState() {
    super.initState();
    _avisar();
  }

  @override
  void didUpdateWidget(ContagemRegressiva antigo) {
    super.didUpdateWidget(antigo);
    if (antigo.numero != widget.numero) _avisar();
  }

  void _avisar() {
    HapticFeedback.selectionClick();
    Sons.tocar(Som.contagem);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Positioned.fill(
      child: ColoredBox(
        color: Cores.fundo.withValues(alpha: 0.95),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(t.prepareSe, style: Estilos.titulo.copyWith(fontSize: 26)),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              key: ValueKey(widget.numero), // reinicia a animação a cada número
              tween: Tween(begin: 0.3, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, escala, filho) =>
                  Transform.scale(scale: escala, child: filho),
              child: Container(
                width: 150,
                height: 150,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Cores.amarelo,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Cores.amareloSombra, offset: Offset(0, 6)),
                  ],
                ),
                child: Text('${widget.numero}', style: Estilos.numeroGrande),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
