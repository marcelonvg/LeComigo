import 'package:flutter/material.dart';

import '../../../tema/tema_app.dart';
import '../../../widgets/balao_fala.dart';
import '../../../widgets/mascote.dart';
import '../leitura_controller.dart';

/// Mascote com o balão de fala; expressão e frase acompanham a fase.
class CabecalhoMascote extends StatelessWidget {
  const CabecalhoMascote({
    super.key,
    required this.fase,
    required this.ouviuAlgo,
    required this.menina,
    this.aoTocarMascote,
  });

  final FaseLeitura fase;
  final bool ouviuAlgo;
  final bool menina;

  /// Se não for null, tocar no mascote chama isto (trocar personagem).
  final VoidCallback? aoTocarMascote;

  @override
  Widget build(BuildContext context) {
    final (expressao, fala) = switch (fase) {
      FaseLeitura.escolha ||
      FaseLeitura.pronto => (Expressao.alegre, 'Vamos ler juntos?'),
      FaseLeitura.contagem => (Expressao.concentrado, 'Já vai começar!'),
      FaseLeitura.lendo => (Expressao.falando, 'Leia em voz alta!'),
      FaseLeitura.fim when ouviuAlgo => (
        Expressao.joinha,
        'Você leu muito bem!',
      ),
      FaseLeitura.fim => (Expressao.pensativo, 'Hum, não ouvi direito...'),
    };

    return Row(
      children: [
        GestureDetector(
          onTap: aoTocarMascote,
          child: Mascote(expressao: expressao, menina: menina),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: BalaoFala(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(fala, key: ValueKey(fala), style: Estilos.destaque),
            ),
          ),
        ),
      ],
    );
  }
}
