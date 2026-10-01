import 'package:flutter/material.dart';

import '../../../tema/tema_app.dart';

/// Cartão branco com borda que mostra o título e o texto da leitura.
class CartaoTexto extends StatelessWidget {
  const CartaoTexto({super.key, required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Cores.fundo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Cores.borda, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo.toUpperCase(), style: Estilos.rotulo),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
