import 'package:flutter/material.dart';

import '../../../tema/tema_app.dart';

/// Microfone com ondas se espalhando, para mostrar que o app está ouvindo.
class MicrofoneOuvindo extends StatefulWidget {
  const MicrofoneOuvindo({super.key});

  @override
  State<MicrofoneOuvindo> createState() => _MicrofoneOuvindoState();
}

class _MicrofoneOuvindoState extends State<MicrofoneOuvindo>
    with SingleTickerProviderStateMixin {
  late final _ciclo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _ciclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tamanho = 64.0;
    return SizedBox(
      width: tamanho * 1.7,
      height: tamanho * 1.7,
      child: AnimatedBuilder(
        animation: _ciclo,
        builder: (context, filho) => Stack(
          alignment: Alignment.center,
          children: [
            // Duas ondas defasadas: crescem e somem.
            for (final defasagem in [0.0, 0.5])
              Builder(
                builder: (context) {
                  final f = (_ciclo.value + defasagem) % 1.0;
                  return Container(
                    width: tamanho * (1 + 0.7 * f),
                    height: tamanho * (1 + 0.7 * f),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Cores.teal.withValues(alpha: 0.28 * (1 - f)),
                    ),
                  );
                },
              ),
            filho!,
          ],
        ),
        child: Container(
          width: tamanho,
          height: tamanho,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Cores.teal,
            boxShadow: [
              BoxShadow(color: Cores.tealSombra, offset: Offset(0, 4)),
            ],
          ),
          child: const Icon(Icons.mic_rounded, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}
