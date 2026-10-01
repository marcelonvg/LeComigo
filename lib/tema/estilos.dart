import 'package:flutter/painting.dart';

import 'cores.dart';

/// Estilos de texto nomeados (fonte Fredoka).
///
/// Para variar só a cor ou o tamanho, use `copyWith`; para variar o peso,
/// use `comPeso` (Fredoka é fonte variável: FontWeight não muda o traço).
abstract final class Estilos {
  static const _familia = 'Fredoka';

  static const logo = TextStyle(
    fontFamily: _familia,
    fontSize: 54,
    fontVariations: [FontVariation.weight(600)],
    height: 1.0,
    color: Cores.grafite,
  );

  static const numeroGrande = TextStyle(
    fontFamily: _familia,
    fontSize: 84,
    fontVariations: [FontVariation.weight(600)],
    height: 1.0,
    color: Cores.grafite,
  );

  static const tituloGrande = TextStyle(
    fontFamily: _familia,
    fontSize: 28,
    fontVariations: [FontVariation.weight(600)],
    color: Cores.grafite,
  );

  static const titulo = TextStyle(
    fontFamily: _familia,
    fontSize: 24,
    fontVariations: [FontVariation.weight(600)],
    color: Cores.grafite,
  );

  static const destaque = TextStyle(
    fontFamily: _familia,
    fontSize: 20,
    fontVariations: [FontVariation.weight(600)],
    color: Cores.grafite,
  );

  static const corpo = TextStyle(
    fontFamily: _familia,
    fontSize: 17,
    fontVariations: [FontVariation.weight(400)],
    color: Cores.texto,
  );

  static const pequeno = TextStyle(
    fontFamily: _familia,
    fontSize: 14,
    fontVariations: [FontVariation.weight(400)],
    color: Cores.texto,
  );

  /// Rótulo em caixa alta acima de blocos ("O GATO CURIOSO").
  static const rotulo = TextStyle(
    fontFamily: _familia,
    fontSize: 14,
    fontVariations: [FontVariation.weight(600)],
    letterSpacing: 1,
    color: Cores.textoSuave,
  );

  static const botao = TextStyle(
    fontFamily: _familia,
    fontSize: 17,
    fontVariations: [FontVariation.weight(600)],
    letterSpacing: 0.8,
  );

  /// Texto que a criança lê.
  static const leitura = TextStyle(
    fontFamily: _familia,
    fontSize: 25,
    fontVariations: [FontVariation.weight(400)],
    height: 1.4,
    color: Cores.texto,
  );
}

extension PesoFredoka on TextStyle {
  /// Mesmo estilo com outro peso (100 a 700 na Fredoka).
  TextStyle comPeso(double peso) =>
      copyWith(fontVariations: [FontVariation.weight(peso)]);
}
