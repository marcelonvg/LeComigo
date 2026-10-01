import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/sons.dart';
import '../tema/tema_app.dart';

/// Botão "3D" (estilo Duolingo): a face fica sobre uma sombra sólida
/// e afunda quando é pressionada.
class Botao3D extends StatefulWidget {
  const Botao3D({
    super.key,
    required this.rotulo,
    this.icone,
    this.aoTocar,
    this.cor = Cores.amarelo,
    this.corSombra = Cores.amareloSombra,
    this.corTexto = Cores.grafite,
  }) : contorno = null;

  /// Botão secundário: branco com borda cinza.
  const Botao3D.secundario({
    super.key,
    required this.rotulo,
    this.icone,
    this.aoTocar,
  }) : cor = Colors.white,
       corSombra = Cores.bordaSombra,
       corTexto = Cores.texto,
       contorno = Cores.borda;

  final String rotulo;
  final IconData? icone;

  /// null = desabilitado (fica cinza).
  final VoidCallback? aoTocar;
  final Color cor;
  final Color corSombra;
  final Color corTexto;
  final Color? contorno;

  @override
  State<Botao3D> createState() => _Botao3DState();
}

class _Botao3DState extends State<Botao3D> {
  static const _altura = 56.0;
  static const _profundidade = 4.0;
  static const _duracao = Duration(milliseconds: 70);

  bool _pressionado = false;

  void _pressionar(bool valor) => setState(() => _pressionado = valor);

  @override
  Widget build(BuildContext context) {
    final ativo = widget.aoTocar != null;
    final cor = ativo ? widget.cor : Cores.borda;
    final sombra = ativo ? widget.corSombra : Cores.bordaSombra;
    final corTexto = ativo ? widget.corTexto : Cores.textoDesabilitado;
    final desce = _pressionado ? _profundidade : 0.0;
    final raio = BorderRadius.circular(16);

    return Semantics(
      button: true,
      enabled: ativo,
      child: GestureDetector(
        onTapDown: ativo ? (_) => _pressionar(true) : null,
        onTapUp: ativo ? (_) => _pressionar(false) : null,
        onTapCancel: ativo ? () => _pressionar(false) : null,
        onTap: ativo
            ? () {
                HapticFeedback.lightImpact();
                Sons.tocar(Som.toque);
                widget.aoTocar!();
              }
            : null,
        // Altura fixa: ao pressionar, a face desce e a sombra visível encolhe.
        child: AnimatedContainer(
          duration: _duracao,
          height: _altura + _profundidade,
          padding: EdgeInsets.only(top: desce),
          child: AnimatedContainer(
            duration: _duracao,
            padding: EdgeInsets.only(bottom: _profundidade - desce),
            decoration: BoxDecoration(color: sombra, borderRadius: raio),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cor,
                borderRadius: raio,
                border: widget.contorno == null
                    ? null
                    : Border.all(color: widget.contorno!, width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              // Com fonte grande do sistema, o rótulo encolhe em vez de vazar.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icone != null) ...[
                      Icon(widget.icone, color: corTexto, size: 24),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.rotulo.toUpperCase(),
                      style: Estilos.botao.copyWith(color: corTexto),
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
