import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/sons.dart';
import '../../../tema/tema_app.dart';

/// "Quem vai ler com você?": dois cartões grandes, menino e menina.
class EscolhaPersonagem extends StatelessWidget {
  const EscolhaPersonagem({
    super.key,
    required this.menina,
    required this.aoEscolher,
  });

  /// null = nenhum escolhido ainda.
  final bool? menina;
  final ValueChanged<bool> aoEscolher;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
      children: [
        const Text(
          'Quem vai ler com você?',
          textAlign: TextAlign.center,
          style: Estilos.tituloGrande,
        ),
        const SizedBox(height: 8),
        Text(
          'Toque para escolher seu amigo de leitura',
          textAlign: TextAlign.center,
          style: Estilos.corpo.copyWith(color: Cores.textoSuave),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: _CartaoPersonagem(
                imagem: 'assets/images/personagens/menino_corpo.png',
                rotulo: 'Menino',
                selecionado: menina == false,
                aoTocar: () => aoEscolher(false),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _CartaoPersonagem(
                imagem: 'assets/images/personagens/menina_corpo.png',
                rotulo: 'Menina',
                selecionado: menina == true,
                aoTocar: () => aoEscolher(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Cartão selecionável no estilo Duolingo: borda e "sombra" sólida
/// ficam teal quando escolhido.
class _CartaoPersonagem extends StatelessWidget {
  const _CartaoPersonagem({
    required this.imagem,
    required this.rotulo,
    required this.selecionado,
    required this.aoTocar,
  });

  final String imagem;
  final String rotulo;
  final bool selecionado;
  final VoidCallback aoTocar;

  static const _duracao = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      label: rotulo,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          Sons.tocar(Som.escolha);
          aoTocar();
        },
        child: AnimatedScale(
          scale: selecionado ? 1.03 : 1.0,
          duration: _duracao,
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: _duracao,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            decoration: BoxDecoration(
              color: selecionado ? Cores.tealClaro : Cores.fundo,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selecionado ? Cores.teal : Cores.borda,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: selecionado ? Cores.teal : Cores.borda,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(imagem),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: AnimatedOpacity(
                        opacity: selecionado ? 1 : 0,
                        duration: _duracao,
                        child: const _SeloSelecionado(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  rotulo,
                  style: Estilos.destaque.copyWith(
                    color: selecionado ? Cores.tealSombra : Cores.texto,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeloSelecionado extends StatelessWidget {
  const _SeloSelecionado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Cores.teal,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
    );
  }
}
