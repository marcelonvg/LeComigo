import 'package:flutter/material.dart';

import '../tema/tema_app.dart';

/// Expressões e ações dos personagens (recortadas do guia de personagens).
enum Expressao { alegre, pensativo, concentrado, falando, joinha }

/// Menino ou menina do guia de personagens, num círculo.
/// Ao trocar a [expressao], a imagem nova entra com um "pulinho".
class Mascote extends StatelessWidget {
  const Mascote({
    super.key,
    required this.expressao,
    this.menina = false,
    this.tamanho = 84,
  });

  final Expressao expressao;
  final bool menina;
  final double tamanho;

  String get _arquivo {
    final nome = switch (expressao) {
      Expressao.alegre => 'alegre',
      Expressao.pensativo => menina ? 'pensativa' : 'pensativo',
      Expressao.concentrado => menina ? 'concentrada' : 'concentrado',
      Expressao.falando => 'falando',
      Expressao.joinha => 'joinha',
    };
    return 'assets/images/personagens/${menina ? 'menina' : 'menino'}_$nome.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Cores.borda, width: 2),
      ),
      child: ClipOval(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutBack,
          transitionBuilder: (filho, animacao) => ScaleTransition(
            scale: Tween(begin: 0.7, end: 1.0).animate(animacao),
            child: FadeTransition(opacity: animacao, child: filho),
          ),
          child: Image.asset(
            _arquivo,
            key: ValueKey(_arquivo),
            fit: BoxFit.cover,
            width: tamanho,
            height: tamanho,
          ),
        ),
      ),
    );
  }
}
