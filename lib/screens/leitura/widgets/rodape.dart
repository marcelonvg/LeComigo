import 'package:flutter/material.dart';

import '../../../tema/tema_app.dart';
import 'microfone_ouvindo.dart';

/// Faixa fixa no pé da tela, separada do conteúdo por uma linha.
class Rodape extends StatelessWidget {
  const Rodape({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Cores.borda, width: 2)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// Microfone pulsando com o recado para a criança, enquanto o app ouve.
class AvisoOuvindo extends StatelessWidget {
  const AvisoOuvindo({super.key, required this.parando});

  /// true depois de "Terminei", enquanto o último trecho é processado.
  final bool parando;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const MicrofoneOuvindo(),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            parando ? 'Só um instante...' : 'Estou ouvindo!\nLeia com calma.',
            style: Estilos.corpo
                .comPeso(500)
                .copyWith(fontSize: 19, height: 1.3),
          ),
        ),
      ],
    );
  }
}
