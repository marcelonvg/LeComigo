import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../tema/tema_app.dart';

/// "Lê Comigo" com o pingo do "i" amarelo quicando.
/// [t] vai de 0 a 1 e se repete.
class TituloAnimado extends StatelessWidget {
  const TituloAnimado({super.key, required this.t});

  final double t;

  static const _tamanho = 54.0; // = Estilos.logo.fontSize
  static const _pingo = _tamanho * 0.24;

  @override
  Widget build(BuildContext context) {
    // Quique: |sen| dá o formato de uma bolinha batendo no chão.
    final pulo = math.sin(((t * 2) % 1.0) * math.pi).abs() * _tamanho * 0.14;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (area) =>
              const LinearGradient(colors: [Cores.teal, Cores.tealBrilho])
                  .createShader(area),
          child: const Text('Lê', style: Estilos.logo),
        ),
        const SizedBox(width: _tamanho * 0.24),
        const Text('Com', style: Estilos.logo),
        // "ı" sem pingo; o pingo é a bolinha amarela.
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Text('ı', style: Estilos.logo),
            Positioned(
              left: 0,
              right: 0,
              top: _tamanho * 0.16 - pulo,
              child: Center(
                child: Container(
                  width: _pingo,
                  height: _pingo,
                  decoration: const BoxDecoration(
                    color: Cores.amarelo,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
        const Text('go', style: Estilos.logo),
      ],
    );
  }
}
