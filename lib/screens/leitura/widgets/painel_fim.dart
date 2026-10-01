import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/sons.dart';
import '../../../tema/tema_app.dart';
import '../../../widgets/botao_3d.dart';
import '../../../l10n/app_localizations.dart';

/// Painel que sobe no fim da leitura: teal se ouviu a criança,
/// amarelo convidando a tentar de novo se não ouviu nada.
///
/// É a tela da criança: estrelas e uma frase, nenhum número.
/// Os números ficam em "Ver detalhes", para o professor.
class PainelFim extends StatefulWidget {
  const PainelFim({
    super.key,
    required this.ouviu,
    required this.estrelas,
    required this.aoLerDeNovo,
    required this.aoVerDetalhes,
  });

  final bool ouviu;

  /// 0 a 3 (ver AvaliacaoLeitura.estrelas).
  final int estrelas;
  final VoidCallback aoLerDeNovo;
  final VoidCallback aoVerDetalhes;

  static String frase(AppLocalizations t, int estrelas) => switch (estrelas) {
    3 => t.fraseTresEstrelas,
    2 => t.fraseDuasEstrelas,
    _ => t.fraseUmaEstrela,
  };

  @override
  State<PainelFim> createState() => _PainelFimState();
}

class _PainelFimState extends State<PainelFim> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    Sons.tocar(widget.ouviu ? Som.sucesso : Som.naoOuvi);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final ouviu = widget.ouviu;
    final corTexto = ouviu ? Cores.tealSombra : Cores.amareloEscuro;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, v, filho) =>
          FractionalTranslation(translation: Offset(0, v), child: filho),
      child: Container(
        width: double.infinity,
        color: ouviu ? Cores.tealClaro : Cores.amareloClaro,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Cores.fundo,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    ouviu ? Icons.check_rounded : Icons.hearing_rounded,
                    color: corTexto,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                // Flexible: com fonte grande do sistema, quebra a linha.
                Flexible(
                  child: Text(
                    ouviu ? t.leituraConcluida : t.naoConseguiOuvir,
                    style: Estilos.titulo.copyWith(color: corTexto),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (ouviu) ...[
              _Estrelas(quantidade: widget.estrelas),
              const SizedBox(height: 8),
            ],
            Text(
              ouviu ? PainelFim.frase(t, widget.estrelas) : t.tenteDeNovoPerto,
              style: Estilos.corpo.copyWith(color: corTexto),
            ),
            const SizedBox(height: 16),
            ouviu
                ? Botao3D(
                    rotulo: t.lerDeNovo,
                    icone: Icons.refresh_rounded,
                    cor: Cores.teal,
                    corSombra: Cores.tealSombra,
                    corTexto: Colors.white,
                    aoTocar: widget.aoLerDeNovo,
                  )
                : Botao3D(
                    rotulo: t.lerDeNovo,
                    icone: Icons.refresh_rounded,
                    aoTocar: widget.aoLerDeNovo,
                  ),
            if (ouviu)
              Center(
                child: TextButton.icon(
                  onPressed: widget.aoVerDetalhes,
                  icon: const Icon(Icons.insights_rounded, size: 20),
                  label: Text(
                    t.verDetalhes,
                    style: Estilos.pequeno.comPeso(600),
                  ),
                  style: TextButton.styleFrom(foregroundColor: corTexto),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Três estrelas; as primeiras [quantidade] acesas, entrando uma de cada vez.
class _Estrelas extends StatelessWidget {
  const _Estrelas({required this.quantidade});

  final int quantidade;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: t.estrelas(quantidade),
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + 200 * i),
              curve: Curves.elasticOut,
              builder: (context, escala, filho) =>
                  Transform.scale(scale: escala, child: filho),
              child: Icon(
                Icons.star_rounded,
                size: 44,
                color: i < quantidade ? Cores.amarelo : Cores.borda,
              ),
            ),
        ],
      ),
    );
  }
}
