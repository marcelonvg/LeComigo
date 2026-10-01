import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/normalizacao.dart';
import '../../data/biblioteca.dart';
import '../../services/idioma_controller.dart';
import '../../services/sons.dart';
import '../../tema/tema_app.dart';
import '../leitura/leitura_screen.dart';
import '../../l10n/app_localizations.dart';

/// Escolha do texto, feita pelo professor antes de entregar o aparelho
/// à criança: ano escolar no topo, textos do ano em cartões.
class BibliotecaScreen extends StatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  State<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends State<BibliotecaScreen> {
  /// Fica no estado da tela: ao voltar da leitura, continua o mesmo ano.
  int _ano = 1;

  void _abrir(TextoBiblioteca texto) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LeituraScreen(texto: texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final idioma = context.watch<IdiomaController>().atual;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
            children: [
              Text(t.bibliotecaTitulo, style: Estilos.tituloGrande),
              const SizedBox(height: 6),
              Text(
                t.bibliotecaSubtitulo,
                style: Estilos.corpo.copyWith(color: Cores.textoSuave),
              ),
              const SizedBox(height: 24),
              _SeletorAno(
                ano: _ano,
                aoEscolher: (ano) => setState(() => _ano = ano),
              ),
              const SizedBox(height: 20),
              for (final texto in textosDoAno(idioma, _ano)) ...[
                _CartaoBiblioteca(texto: texto, aoTocar: () => _abrir(texto)),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Cinco chips (1º a 5º) no estilo 3D dos cartões de personagem.
class _SeletorAno extends StatelessWidget {
  const _SeletorAno({required this.ano, required this.aoEscolher});

  final int ano;
  final ValueChanged<int> aoEscolher;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var a = 1; a <= 5; a++) ...[
          if (a > 1) const SizedBox(width: 8),
          Expanded(
            child: _ChipAno(
              ano: a,
              selecionado: a == ano,
              aoTocar: () => aoEscolher(a),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChipAno extends StatelessWidget {
  const _ChipAno({
    required this.ano,
    required this.selecionado,
    required this.aoTocar,
  });

  final int ano;
  final bool selecionado;
  final VoidCallback aoTocar;

  static const _duracao = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cor = selecionado ? Cores.tealSombra : Cores.texto;
    // O GestureDetector fica por fora: o excludeSemantics esconderia
    // a ação de toque dele do leitor de tela.
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Sons.tocar(Som.escolha);
        aoTocar();
      },
      child: Semantics(
        button: true,
        selected: selecionado,
        label: t.anoCompleto('$ano'),
        excludeSemantics: true,
        child: AnimatedContainer(
          duration: _duracao,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selecionado ? Cores.tealClaro : Cores.fundo,
            borderRadius: BorderRadius.circular(16),
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
              Text(
                t.anoNumero('$ano'),
                style: Estilos.destaque.copyWith(color: cor),
              ),
              Text(t.anoPalavra, style: Estilos.pequeno.copyWith(color: cor)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cartão de um texto: título, começo do texto e número de palavras.
class _CartaoBiblioteca extends StatelessWidget {
  const _CartaoBiblioteca({required this.texto, required this.aoTocar});

  final TextoBiblioteca texto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final palavras = tokenizar(texto.conteudo).length;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Sons.tocar(Som.toque);
          aoTocar();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Cores.fundo,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Cores.borda, width: 2),
            boxShadow: const [
              BoxShadow(color: Cores.borda, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(texto.titulo, style: Estilos.destaque),
              const SizedBox(height: 6),
              Text(
                texto.conteudo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Estilos.corpo.copyWith(color: Cores.textoSuave),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 18,
                    color: Cores.teal,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      t.palavras(palavras),
                      style: Estilos.pequeno
                          .comPeso(600)
                          .copyWith(color: Cores.tealSombra),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Cores.teal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
