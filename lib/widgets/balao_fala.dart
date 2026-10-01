import 'package:flutter/material.dart';

import '../tema/tema_app.dart';

/// Balão de fala com a "cauda" apontando para a esquerda (para o mascote).
class BalaoFala extends StatelessWidget {
  const BalaoFala({super.key, required this.child});

  final Widget child;

  static const _cauda = 10.0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BalaoPainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_cauda + 14, 12, 14, 12),
        child: child,
      ),
    );
  }
}

class _BalaoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const r = 16.0;
    const c = BalaoFala._cauda;
    final w = size.width;
    final h = size.height;
    const raio = Radius.circular(r);

    final contorno = Path()
      ..moveTo(c + r, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: raio)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: raio)
      ..lineTo(c + r, h)
      ..arcToPoint(Offset(c, h - r), radius: raio)
      ..lineTo(c, h / 2 + c)
      ..lineTo(0, h / 2)
      ..lineTo(c, h / 2 - c)
      ..lineTo(c, r)
      ..arcToPoint(const Offset(c + r, 0), radius: raio)
      ..close();

    canvas.drawPath(contorno, Paint()..color = Colors.white);
    canvas.drawPath(
      contorno,
      Paint()
        ..color = Cores.borda
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_BalaoPainter antigo) => false;
}
