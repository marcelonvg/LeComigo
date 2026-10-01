import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/idioma.dart';
import '../../l10n/app_localizations.dart';
import '../../services/idioma_controller.dart';
import '../../services/sons.dart';
import '../../services/vosk_service.dart';
import '../../tema/tema_app.dart';
import '../../widgets/botao_3d.dart';
import '../biblioteca/biblioteca_screen.dart';

/// Primeira tela depois da splash, em toda abertura: mostra o idioma atual,
/// deixa trocá-lo e, em "Entrar", prepara o modelo de voz desse idioma.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  bool _carregando = false;
  bool _falhou = false;

  Future<void> _entrar() async {
    // O botão só desabilita no próximo quadro; um toque duplo chega aqui.
    if (_carregando) return;
    setState(() {
      _carregando = true;
      _falhou = false;
    });
    final idioma = context.read<IdiomaController>().atual;
    try {
      await context.read<VoskService>().carregarModelo(idioma);
    } catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _falhou = true;
        });
      }
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const BibliotecaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final atual = context.watch<IdiomaController>().atual;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Cores.fundoSplash,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  children: [
                    Center(
                      // Limitada pela altura: em celular pequeno, os três
                      // idiomas precisam caber sem rolar.
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 260,
                          maxHeight: MediaQuery.sizeOf(context).height * 0.22,
                        ),
                        child: Image.asset(
                          'assets/images/splash_ilustracao.png',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lê Comigo',
                      textAlign: TextAlign.center,
                      style: Estilos.tituloGrande.copyWith(color: Cores.teal),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t.inicioEscolhaIdioma,
                      textAlign: TextAlign.center,
                      style: Estilos.titulo,
                    ),
                    const SizedBox(height: 16),
                    for (final idioma in Idioma.values) ...[
                      _CartaoIdioma(
                        idioma: idioma,
                        selecionado: idioma == atual,
                        aoTocar: _carregando
                            ? null
                            : () => context.read<IdiomaController>().escolher(
                                idioma,
                              ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_falhou) ...[
                      Text(
                        t.inicioErroModelo,
                        textAlign: TextAlign.center,
                        style: Estilos.corpo.copyWith(color: Cores.erro),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Botao3D(
                      rotulo: _carregando ? t.inicioCarregando : t.inicioEntrar,
                      icone: _carregando
                          ? Icons.hourglass_top_rounded
                          : Icons.arrow_forward_rounded,
                      aoTocar: _carregando ? null : _entrar,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bandeira e nome do idioma, no estilo 3D dos chips de ano.
class _CartaoIdioma extends StatelessWidget {
  const _CartaoIdioma({
    required this.idioma,
    required this.selecionado,
    required this.aoTocar,
  });

  final Idioma idioma;
  final bool selecionado;

  /// null = desabilitado (enquanto o modelo carrega).
  final VoidCallback? aoTocar;

  static const _duracao = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final cor = selecionado ? Cores.tealSombra : Cores.texto;
    // O GestureDetector fica por fora: o excludeSemantics esconderia
    // a ação de toque dele do leitor de tela.
    return GestureDetector(
      onTap: aoTocar == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              Sons.tocar(Som.escolha);
              aoTocar!();
            },
      child: Semantics(
        button: true,
        selected: selecionado,
        enabled: aoTocar != null,
        label: idioma.nome,
        excludeSemantics: true,
        child: AnimatedContainer(
          duration: _duracao,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selecionado ? Cores.tealClaro : Cores.fundo,
            borderRadius: BorderRadius.circular(18),
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
          child: Row(
            children: [
              Text(idioma.bandeira, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  idioma.nome,
                  style: Estilos.destaque.copyWith(color: cor),
                ),
              ),
              AnimatedOpacity(
                opacity: selecionado ? 1 : 0,
                duration: _duracao,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Cores.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
