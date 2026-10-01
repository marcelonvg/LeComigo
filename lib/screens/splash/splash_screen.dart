import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/vosk_service.dart';
import '../../tema/tema_app.dart';
import 'widgets/carregamento.dart';
import 'widgets/ilustracao_animada.dart';
import 'widgets/titulo_animado.dart';

/// Tela de abertura: anima a ilustração enquanto o modelo de voz é
/// preparado (na primeira vez, o zip de ~31 MB é descompactado).
/// Quando termina, troca para [proximaTela].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.proximaTela});

  final WidgetBuilder proximaTela;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Tempo mínimo na tela, para a animação não virar um "piscar".
  static const _tempoMinimo = Duration(milliseconds: 2400);

  /// Ciclo contínuo: flutuação, ondas, risquinhos, pingo do "i".
  late final _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  /// Entrada em sequência: ilustração → título → barra.
  late final _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();
  late final _entradaIlustracao = _trecho(0.0, 0.55, Curves.easeOutBack);
  late final _entradaTitulo = _trecho(0.3, 0.75, Curves.easeOutCubic);
  late final _entradaRodape = _trecho(0.55, 1.0, Curves.easeOut);

  /// O carregamento não informa porcentagem: a barra avança até 90%
  /// sozinha e só completa quando o modelo está pronto.
  late final _progresso = AnimationController(vsync: this);

  bool _falhou = false;

  Animation<double> _trecho(double inicio, double fim, Curve curva) =>
      CurvedAnimation(
        parent: _entrada,
        curve: Interval(inicio, fim, curve: curva),
      );

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respeita a opção de acessibilidade "remover animações".
    if (MediaQuery.disableAnimationsOf(context)) {
      _loop.stop();
      _entrada.value = 1;
    }
  }

  Future<void> _carregar() async {
    _progresso.value = 0;
    _progresso.animateTo(
      0.9,
      duration: const Duration(seconds: 6),
      curve: Curves.easeOutCubic,
    );
    final esperaMinima = Future.delayed(_tempoMinimo);

    try {
      await context.read<VoskService>().carregarModelo();
      await esperaMinima;
      await _progresso.animateTo(
        1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
      if (mounted) _irParaProximaTela();
    } catch (_) {
      _progresso.stop();
      if (mounted) setState(() => _falhou = true);
    }
  }

  void _tentarDeNovo() {
    setState(() => _falhou = false);
    _carregar();
  }

  void _irParaProximaTela() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, _, _) => widget.proximaTela(context),
        transitionsBuilder: (context, animacao, _, filho) =>
            FadeTransition(opacity: animacao, child: filho),
      ),
    );
  }

  @override
  void dispose() {
    _loop.dispose();
    _entrada.dispose();
    _progresso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Cores.fundoSplash,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: AnimatedBuilder(
                animation: Listenable.merge([_loop, _entrada]),
                builder: (context, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Entrada(
                      valor: _entradaIlustracao.value,
                      escala: true,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: IlustracaoAnimada(t: _loop.value),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Entrada(
                      valor: _entradaTitulo.value,
                      child: TituloAnimado(t: _loop.value),
                    ),
                    const SizedBox(height: 36),
                    _Entrada(
                      valor: _entradaRodape.value,
                      child: _falhou
                          ? ErroCarregamento(aoTentarDeNovo: _tentarDeNovo)
                          : BarraCarregamento(
                              progresso: _progresso,
                              t: _loop.value,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Aparece com fade; sobe um pouco ([escala] = false) ou cresce ([escala] = true).
class _Entrada extends StatelessWidget {
  const _Entrada({
    required this.valor,
    required this.child,
    this.escala = false,
  });

  final double valor;
  final bool escala;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: valor.clamp(0.0, 1.0), // easeOutBack passa de 1
      child: escala
          ? Transform.scale(scale: 0.85 + 0.15 * valor, child: child)
          : Transform.translate(
              offset: Offset(0, 24 * (1 - valor)),
              child: child,
            ),
    );
  }
}
