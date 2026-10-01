import 'package:flutter/material.dart';

import '../../../core/resultado_vosk.dart';
import '../../../tema/tema_app.dart';
import '../../../l10n/app_localizations.dart';

/// Dados crus do Vosk, para conferir o reconhecimento (botão ⓘ no topo).
class PainelDetalhes extends StatelessWidget {
  const PainelDetalhes({
    super.key,
    required this.parcial,
    required this.finais,
  });

  final String parcial;
  final List<PalavraReconhecida> finais;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final titulo = Estilos.pequeno
        .comPeso(600)
        .copyWith(color: Cores.textoSuave);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Cores.fundoSuave,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.parcialAoVivo, style: titulo),
          Text(parcial.isEmpty ? '—' : parcial, style: Estilos.pequeno),
          const SizedBox(height: 10),
          Text(t.finalPalavraTempo, style: titulo),
          if (finais.isEmpty) const Text('—', style: Estilos.pequeno),
          for (final p in finais) Text(p.toString(), style: Estilos.pequeno),
        ],
      ),
    );
  }
}
