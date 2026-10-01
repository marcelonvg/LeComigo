import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ilustração da criança lendo, com as ondas de som e os "risquinhos"
/// animados por cima. A imagem base não tem esses elementos; eles são
/// desenhados aqui, nas mesmas posições do desenho original.
///
/// [t] vai de 0 a 1 e se repete (vem de um AnimationController em loop).
class IlustracaoAnimada extends StatelessWidget {
  const IlustracaoAnimada({super.key, required this.t});

  final double t;

  // Tamanho original da imagem; as coordenadas do painter usam essa escala.
  static const larguraBase = 860.0;
  static const alturaBase = 628.0;

  @override
  Widget build(BuildContext context) {
    // Flutua suavemente para cima e para baixo.
    final flutuacao = math.sin(t * 2 * math.pi) * 5;
    return AspectRatio(
      aspectRatio: larguraBase / alturaBase,
      child: Transform.translate(
        offset: Offset(0, flutuacao),
        child: CustomPaint(
          foregroundPainter: _DetalhesPainter(t),
          child: Image.asset(
            'assets/images/splash_ilustracao.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _DetalhesPainter extends CustomPainter {
  _DetalhesPainter(this.t);

  final double t;

  // Posições em pixels da imagem original (860×628). As cores abaixo foram
  // medidas no desenho e ficam aqui, não em Cores: só existem para combinar
  // com a ilustração.
  static const _centroOndas = Offset(592, 364);
  static const _raios = [24.0, 54.0, 84.0];
  static const _espessuras = [12.0, 14.0, 15.0];
  static const _coresOndas = [
    Color(0xFF2FD8D7),
    Color(0xFF16C8C7),
    Color(0xFF05BABC),
  ];

  // Risquinhos: (ponta perto da cabeça, ponta de fora).
  static const _risquinhos = [
    (Offset(545, 230), Offset(570, 178)),
    (Offset(583, 252), Offset(627, 223)),
  ];
  static const _corRisquinho = Color(0xFFFDBF3C);

  static double _rad(double graus) => graus * math.pi / 180;

  /// Pulso de 0 a 1 que dura metade do ciclo e descansa na outra metade.
  static double _pulso(double fase) {
    final f = fase % 1.0;
    return f < 0.5 ? math.sin(f / 0.5 * math.pi) : 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / IlustracaoAnimada.larguraBase);

    // As ondas "falam" duas vezes por ciclo, acendendo de dentro para fora.
    final tOndas = (t * 2) % 1.0;
    for (var i = 0; i < _raios.length; i++) {
      final brilho = _pulso(tOndas - i * 0.14);
      final pincel = Paint()
        ..color = _coresOndas[i].withValues(alpha: 0.35 + 0.65 * brilho)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _espessuras[i]
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: _centroOndas, radius: _raios[i]),
        _rad(146),
        _rad(94),
        false,
        pincel,
      );
    }

    // Risquinhos esticam e encolhem, um depois do outro.
    for (var i = 0; i < _risquinhos.length; i++) {
      final (dentro, fora) = _risquinhos[i];
      final p = _pulso(t * 2 - i * 0.25);
      final ponta = Offset.lerp(dentro, fora, 0.55 + 0.45 * p)!;
      final pincel = Paint()
        ..color = _corRisquinho.withValues(alpha: 0.8 + 0.2 * p)
        ..strokeWidth = 19
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(dentro, ponta, pincel);
    }
  }

  @override
  bool shouldRepaint(_DetalhesPainter antigo) => antigo.t != t;
}
