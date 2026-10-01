import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../tema/tema_app.dart';
import '../../../l10n/app_localizations.dart';

final _estiloRodape = Estilos.corpo.copyWith(
  fontSize: 20,
  color: Cores.textoAzulado,
);

/// Barra de progresso com "Carregando..." e os pontinhos acendendo.
class BarraCarregamento extends StatelessWidget {
  const BarraCarregamento({
    super.key,
    required this.progresso,
    required this.t,
  });

  final Animation<double> progresso;

  /// Ciclo de 0 a 1 que anima os pontinhos.
  final double t;

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final largura = math.min(320.0, MediaQuery.sizeOf(context).width * 0.7);
    final raio = BorderRadius.circular(7);
    return Column(
      children: [
        Container(
          width: largura,
          height: 14,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(color: Cores.trilho, borderRadius: raio),
          child: AnimatedBuilder(
            animation: progresso,
            builder: (context, _) => Container(
              width: largura * progresso.value,
              decoration: BoxDecoration(
                borderRadius: raio,
                gradient: const LinearGradient(
                  colors: [Cores.teal, Cores.tealVivo],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(textos.splashCarregando, style: _estiloRodape),
            for (var i = 0; i < 3; i++)
              Opacity(
                opacity: ((t * 3 - i * 0.2) % 1.0) < 0.5 ? 1.0 : 0.25,
                child: Text('.', style: _estiloRodape),
              ),
          ],
        ),
      ],
    );
  }
}
